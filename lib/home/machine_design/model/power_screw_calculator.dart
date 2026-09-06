/// Torque, efficiency and self-locking for a power screw — a jack, a vice, a
/// clamp, a lead screw on a machine slide.
///
/// Works in mm and N throughout, the component-scale convention the rest of
/// the machine-design tools use, and converts to N·m only where a torque
/// leaves the calculator.
library;

import 'dart:math' as math;

/// The thread form, which enters only as the flank angle.
///
/// A square thread transmits the axial load straight along the screw axis. A
/// flank angle wedges it, raising the normal force between the threads by
/// 1/cos α and the friction torque with it — which is why a square thread is
/// the efficient one and an ACME thread the one that is easy to cut and easy
/// to take up wear on.
enum ThreadForm {
  /// Flanks parallel to the axis: α = 0.
  square,

  /// ACME, 29° included, so a 14.5° flank angle.
  acme,

  /// ISO metric trapezoidal, 30° included, so a 15° flank angle.
  trapezoidal,
}

extension ThreadFormAngle on ThreadForm {
  /// Half the included angle, in radians.
  double get flankAngle => switch (this) {
        ThreadForm.square => 0,
        ThreadForm.acme => 14.5 * math.pi / 180,
        ThreadForm.trapezoidal => 15 * math.pi / 180,
      };

  /// sec α — the factor a flank angle multiplies thread friction by.
  double get secantFactor => 1 / math.cos(flankAngle);
}

class PowerScrewInput {
  const PowerScrewInput({
    required this.majorDiameter,
    required this.pitch,
    required this.load,
    this.form = ThreadForm.acme,
    this.starts = 1,
    this.threadFriction = 0.15,
    this.collarFriction = 0.15,
    this.collarDiameter = 0,
  });

  /// Nominal (major) diameter d, mm.
  final double majorDiameter;

  /// Pitch p, mm — the distance between adjacent threads, not the lead.
  final double pitch;

  /// Axial load F, N, positive in compression as a jack carries it.
  final double load;

  final ThreadForm form;

  /// Number of thread starts. Two starts double the lead, and so the travel
  /// per turn, without changing the thread's own size.
  final int starts;

  /// Coefficient of friction at the thread, μ.
  final double threadFriction;

  /// Coefficient of friction at the thrust collar, μc.
  final double collarFriction;

  /// Mean diameter of the thrust collar dc, mm. Zero for a screw running
  /// against a thrust bearing, whose friction is negligible beside a plain
  /// collar's.
  final double collarDiameter;
}

class PowerScrewResult {
  const PowerScrewResult({
    required this.meanDiameter,
    required this.lead,
    required this.leadAngle,
    required this.threadTorqueRaising,
    required this.threadTorqueLowering,
    required this.collarTorque,
    required this.torqueToRaise,
    required this.torqueToLower,
    required this.efficiency,
    required this.isSelfLocking,
    required this.holdsWithCollar,
  });

  /// Mean (pitch) diameter dm, mm — where the thread friction acts.
  final double meanDiameter;

  /// Lead, mm: how far the nut travels in one turn.
  final double lead;

  /// Lead angle λ, degrees.
  final double leadAngle;

  /// The thread's own share of the raising and lowering torque, N·m.
  ///
  /// Split out from the collar's because they are different problems: the
  /// thread torque is set by the screw's geometry, the collar's by whatever
  /// the screw bears against, and swapping a plain collar for a thrust
  /// bearing removes only the second.
  final double threadTorqueRaising;

  /// Negative when the thread alone would drive itself down under the load.
  final double threadTorqueLowering;

  /// The collar's share, N·m. The same either way round.
  final double collarTorque;

  /// Total torque to raise the load, N·m.
  final double torqueToRaise;

  /// Total torque to lower it, N·m. Negative means the load runs away unless
  /// something holds it.
  final double torqueToLower;

  /// Work out over work in, 0 to 1, collar included.
  final double efficiency;

  /// Whether the thread alone holds the load without a brake.
  final bool isSelfLocking;

  /// Whether the assembly holds once collar friction is counted too.
  ///
  /// The two differ more often than they look: a screw can fail the thread
  /// test and still hold, because the collar makes up the difference. That is
  /// a much weaker guarantee — the collar is what wears and what gets oiled.
  final bool holdsWithCollar;
}

abstract final class PowerScrewCalculator {
  static PowerScrewResult calculate(PowerScrewInput input) {
    if (input.majorDiameter <= 0) {
      throw const FormatException('Major diameter must be positive.');
    }
    if (input.pitch <= 0) {
      throw const FormatException('Pitch must be positive.');
    }
    if (input.pitch >= input.majorDiameter) {
      throw const FormatException(
          'Pitch must be smaller than the major diameter.');
    }
    if (input.starts < 1) {
      throw const FormatException('A screw has at least one thread start.');
    }
    if (input.load <= 0) {
      throw const FormatException('Load must be positive.');
    }
    if (input.threadFriction < 0 || input.collarFriction < 0) {
      throw const FormatException('Friction coefficients cannot be negative.');
    }
    if (input.collarDiameter < 0) {
      throw const FormatException('Collar diameter cannot be negative.');
    }

    final dm = input.majorDiameter - input.pitch / 2;
    final lead = input.pitch * input.starts;
    final f = input.load;
    final mu = input.threadFriction;
    final sec = input.form.secantFactor;
    final piDm = math.pi * dm;

    // The raising denominator goes to zero when friction alone could not be
    // overcome by any torque — physically unreachable for real coefficients,
    // but a guard costs nothing and an infinity in a result costs a lot.
    final raisingDenominator = piDm - mu * lead * sec;
    if (raisingDenominator <= 0) {
      throw const FormatException(
          'Thread friction is too high for this lead; the screw cannot be '
          'turned under load.');
    }

    // Shigley eq. 8-1 and 8-2, with the sec α that a flank angle introduces.
    final threadRaise =
        (f * dm / 2) * (lead + mu * piDm * sec) / raisingDenominator;
    final threadLower =
        (f * dm / 2) * (mu * piDm * sec - lead) / (piDm + mu * lead * sec);
    final collar = f * input.collarFriction * input.collarDiameter / 2;

    final raise = threadRaise + collar;
    final lower = threadLower + collar;

    // Efficiency is the work the load takes over the work the handle puts in,
    // both per turn: F·lead against 2π·T.
    final efficiency = raise <= 0 ? 0.0 : f * lead / (2 * math.pi * raise);

    return PowerScrewResult(
      meanDiameter: dm,
      lead: lead,
      leadAngle: math.atan(lead / piDm) * 180 / math.pi,
      // N·mm to N·m on the way out.
      threadTorqueRaising: threadRaise / 1000,
      threadTorqueLowering: threadLower / 1000,
      collarTorque: collar / 1000,
      torqueToRaise: raise / 1000,
      torqueToLower: lower / 1000,
      efficiency: efficiency,
      // μ·sec α > tan λ, written without the tangent so a vertical screw
      // cannot divide by zero.
      isSelfLocking: mu * piDm * sec > lead,
      holdsWithCollar: lower > 0,
    );
  }
}
