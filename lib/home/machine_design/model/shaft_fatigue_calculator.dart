import 'dart:math' as math;

class ShaftFatigueInput {
  const ShaftFatigueInput({
    required this.alternatingMoment,
    this.meanMoment = 0,
    this.alternatingTorque = 0,
    this.meanTorque = 0,
    required this.kf,
    required this.kfs,
    required this.enduranceLimit,
    required this.ultimateStrength,
    required this.safetyFactor,
  });

  /// Alternating bending moment Ma, N·mm.
  final double alternatingMoment;

  /// Mean bending moment Mm, N·mm.
  final double meanMoment;

  /// Alternating torque Ta, N·mm.
  final double alternatingTorque;

  /// Mean torque Tm, N·mm.
  final double meanTorque;

  /// Bending fatigue stress-concentration factor.
  final double kf;

  /// Torsional fatigue stress-concentration factor.
  final double kfs;

  /// Endurance limit Se, MPa.
  final double enduranceLimit;

  /// Ultimate tensile strength Sut, MPa.
  final double ultimateStrength;

  /// Target factor of safety n.
  final double safetyFactor;
}

class ShaftFatigueResult {
  const ShaftFatigueResult({
    required this.diameterMm,
    required this.alternatingVonMises,
    required this.meanVonMises,
  });

  /// Required shaft diameter, mm.
  final double diameterMm;

  /// Von Mises alternating and mean stresses at that diameter, MPa:
  /// σa′ = (16/πd³)·√(4(Kf·Ma)² + 3(Kfs·Ta)²), and likewise for the means.
  /// They sit on the Goodman line scaled by 1/n by construction — which is
  /// what the diagram on the result page shows.
  final double alternatingVonMises;
  final double meanVonMises;
}

/// Shigley's DE-Goodman shaft-diameter equation:
/// d = { (16n/π) · [ (1/Se)·sqrt(4(Kf·Ma)² + 3(Kfs·Ta)²)
///                  + (1/Sut)·sqrt(4(Kf·Mm)² + 3(Kfs·Tm)²) ] }^(1/3)
/// All moments in N·mm, Se/Sut in MPa, d in mm.
abstract final class ShaftFatigueCalculator {
  static ShaftFatigueResult calculate(ShaftFatigueInput input) {
    if (input.enduranceLimit <= 0 || input.ultimateStrength <= 0) {
      throw const FormatException('Se and Sut must be positive.');
    }
    if (input.safetyFactor <= 0) {
      throw const FormatException('Target factor of safety must be positive.');
    }
    if (input.kf <= 0 || input.kfs <= 0) {
      throw const FormatException(
          'Stress-concentration factors must be positive.');
    }
    if (input.alternatingMoment == 0 &&
        input.alternatingTorque == 0 &&
        input.meanMoment == 0 &&
        input.meanTorque == 0) {
      throw const FormatException('Enter at least one moment or torque.');
    }

    final alternatingTerm = math.sqrt(
      4 * math.pow(input.kf * input.alternatingMoment, 2) +
          3 * math.pow(input.kfs * input.alternatingTorque, 2),
    );
    final meanTerm = math.sqrt(
      4 * math.pow(input.kf * input.meanMoment, 2) +
          3 * math.pow(input.kfs * input.meanTorque, 2),
    );

    final bracket = alternatingTerm / input.enduranceLimit +
        meanTerm / input.ultimateStrength;
    final dCubed = (16 * input.safetyFactor / math.pi) * bracket;
    final d = math.pow(dCubed, 1 / 3).toDouble();
    final stressPerTerm = 16 / (math.pi * dCubed);

    return ShaftFatigueResult(
      diameterMm: d,
      alternatingVonMises: stressPerTerm * alternatingTerm,
      meanVonMises: stressPerTerm * meanTerm,
    );
  }
}
