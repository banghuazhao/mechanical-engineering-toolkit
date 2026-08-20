import 'dart:math' as math;

import 'beam_natural_frequency_calculator.dart';

/// Standard gravity, m/s² — only used to turn the rotor's weight into the
/// static deflection engineers quote alongside a critical speed.
const double _g = 9.80665;

/// How the shaft is carried at its ends.
enum ShaftSupport { simplySupported, fixedFixed, cantilever }

extension ShaftSupportProperties on ShaftSupport {
  /// The end condition the bare shaft vibrates in when its own mass is the
  /// only mass present — used for the Dunkerley self-mass term.
  BeamEndCondition get beamEndCondition => switch (this) {
        ShaftSupport.simplySupported => BeamEndCondition.simplySupported,
        ShaftSupport.fixedFixed => BeamEndCondition.fixedFixed,
        ShaftSupport.cantilever => BeamEndCondition.cantilever,
      };

  /// Transverse stiffness at the rotor, N/m, for a rotor [a] metres from the
  /// left end of a shaft of span [l] metres with rigidity [ei] N·m².
  ///
  /// These are the standard point-load influence coefficients inverted:
  /// at midspan they reduce to 48EI/L³ (simply supported) and 192EI/L³
  /// (fixed-fixed), and a rotor at the tip of a cantilever to 3EI/L³.
  double stiffness({required double ei, required double l, required double a}) {
    final b = l - a;
    return switch (this) {
      ShaftSupport.simplySupported => 3 * ei * l / (a * a * b * b),
      ShaftSupport.fixedFixed =>
        3 * ei * l * l * l / (a * a * a * b * b * b),
      // Fixed at the left end: only the distance out to the rotor matters,
      // and the shaft beyond it is unloaded.
      ShaftSupport.cantilever => 3 * ei / (a * a * a),
    };
  }

  /// Whether the rotor may sit at the far end — true only for a cantilever,
  /// whose free tip is a valid position while a support point is not.
  bool get allowsRotorAtEnd => this == ShaftSupport.cantilever;
}

class ShaftCriticalSpeedResult {
  const ShaftCriticalSpeedResult({
    required this.stiffnessNPerM,
    required this.staticDeflectionMm,
    required this.rotorFrequencyHz,
    required this.shaftFrequencyHz,
    required this.criticalFrequencyHz,
    required this.momentOfInertiaMm4,
    required this.shaftMassKg,
  });

  /// Transverse shaft stiffness at the rotor, N/m.
  final double stiffnessNPerM;

  /// Deflection under the rotor's own weight, mm.
  final double staticDeflectionMm;

  /// Whirl frequency of the rotor alone on a massless shaft, Hz.
  final double rotorFrequencyHz;

  /// First bending frequency of the bare shaft carrying only its own mass,
  /// Hz. Null when the shaft's mass was left out.
  final double? shaftFrequencyHz;

  /// The two combined by Dunkerley's equation, Hz — the answer to use.
  final double criticalFrequencyHz;

  /// Second moment of area of the round shaft, mm⁴.
  final double momentOfInertiaMm4;

  /// Mass of the shaft itself, kg. Zero when its density was left out.
  final double shaftMassKg;

  double get criticalSpeedRpm => criticalFrequencyHz * 60;

  double get rotorSpeedRpm => rotorFrequencyHz * 60;

  double? get shaftSpeedRpm {
    final f = shaftFrequencyHz;
    return f == null ? null : f * 60;
  }
}

/// First lateral critical speed of a round shaft carrying one rotor.
///
/// The rotor-alone frequency is the classic √(k/m) of the shaft treated as a
/// spring, and the shaft's own distributed mass is folded in by Dunkerley's
/// equation, 1/ω² = 1/ω_rotor² + 1/ω_shaft². Dunkerley always errs low, so
/// the critical speed it returns is a conservative one to keep clear of.
abstract final class ShaftCriticalSpeedCalculator {
  /// Inputs are in the app's SI display units: [modulusGPa] in GPa,
  /// [diameterMm] in mm, [spanM] and [rotorPositionM] in m, [rotorMassKg] in
  /// kg, [densityKgM3] in kg/m³.
  ///
  /// Pass a null [densityKgM3] to ignore the shaft's own mass — the result is
  /// then the rotor-alone speed, which is the higher, less conservative one.
  static ShaftCriticalSpeedResult calculate({
    required double modulusGPa,
    required double diameterMm,
    required double spanM,
    required double rotorMassKg,
    required double rotorPositionM,
    required ShaftSupport support,
    double? densityKgM3,
  }) {
    if (modulusGPa <= 0) {
      throw const FormatException('Modulus E must be positive.');
    }
    if (diameterMm <= 0) {
      throw const FormatException('Shaft diameter must be positive.');
    }
    if (spanM <= 0) {
      throw const FormatException('Span L must be positive.');
    }
    if (rotorMassKg <= 0) {
      throw const FormatException('Rotor mass must be positive.');
    }
    // At a support the stiffness is infinite and the formula divides by zero,
    // so the rotor has to sit strictly inside the span — except on a
    // cantilever, whose right-hand end is free.
    if (rotorPositionM <= 0 ||
        rotorPositionM > spanM ||
        (rotorPositionM == spanM && !support.allowsRotorAtEnd)) {
      throw const FormatException(
          'Rotor position must lie along the shaft, clear of the supports.');
    }
    if (densityKgM3 != null && densityKgM3 <= 0) {
      throw const FormatException('Density must be positive.');
    }

    final e = modulusGPa * 1e9; // Pa
    final d = diameterMm * 1e-3; // m
    final iM4 = math.pi * math.pow(d, 4) / 64; // m⁴
    final areaM2 = math.pi * d * d / 4;
    final ei = e * iM4; // N·m²

    final k = support.stiffness(ei: ei, l: spanM, a: rotorPositionM);
    final omegaRotor = math.sqrt(k / rotorMassKg);
    final rotorFrequency = omegaRotor / (2 * math.pi);
    final staticDeflection = rotorMassKg * _g / k; // m

    double? shaftFrequency;
    var shaftMass = 0.0;
    if (densityKgM3 != null) {
      shaftMass = densityKgM3 * areaM2 * spanM;
      shaftFrequency = BeamNaturalFrequencyCalculator.calculate(
        modulusGPa: modulusGPa,
        momentOfInertiaMm4: iM4 * 1e12,
        areaMm2: areaM2 * 1e6,
        lengthM: spanM,
        densityKgM3: densityKgM3,
        endCondition: support.beamEndCondition,
      ).fundamental.frequencyHz;
    }

    // Dunkerley superposes flexibilities, so it combines the two as
    // 1/ω² = Σ 1/ωᵢ² — equivalently 1/f², the 2π cancelling throughout.
    final critical = shaftFrequency == null
        ? rotorFrequency
        : 1 /
            math.sqrt(1 / (rotorFrequency * rotorFrequency) +
                1 / (shaftFrequency * shaftFrequency));

    return ShaftCriticalSpeedResult(
      stiffnessNPerM: k,
      staticDeflectionMm: staticDeflection * 1000,
      rotorFrequencyHz: rotorFrequency,
      shaftFrequencyHz: shaftFrequency,
      criticalFrequencyHz: critical,
      momentOfInertiaMm4: iM4 * 1e12,
      shaftMassKg: shaftMass,
    );
  }
}
