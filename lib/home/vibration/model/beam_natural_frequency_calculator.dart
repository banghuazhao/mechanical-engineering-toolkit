import 'dart:math' as math;

/// End conditions for a uniform prismatic beam in transverse (bending)
/// vibration.
enum BeamEndCondition {
  simplySupported,
  cantilever,
  fixedFixed,
  fixedPinned,
  freeFree,
}

extension BeamEndConditionModes on BeamEndCondition {
  /// The first three roots (βL)ₙ of the beam's frequency equation.
  ///
  /// Only the pinned-pinned case has a closed form (βL = nπ); the rest are
  /// the standard tabulated roots of cos(βL)·cosh(βL) = ±1 and its relatives,
  /// quoted here to six figures — far finer than any real E, I or ρ is known.
  ///
  /// Fixed-fixed and free-free share a table: their frequency equations are
  /// the same, cos(βL)·cosh(βL) = 1. Only the mode shapes differ, and a
  /// free-free beam additionally has two zero-frequency rigid-body modes
  /// (translation and rotation) that carry no strain energy and are not
  /// listed here.
  List<double> get betaL => switch (this) {
        BeamEndCondition.simplySupported => [
            math.pi,
            2 * math.pi,
            3 * math.pi,
          ],
        BeamEndCondition.cantilever => [1.875104, 4.694091, 7.854757],
        BeamEndCondition.fixedFixed => [4.730041, 7.853205, 10.995608],
        BeamEndCondition.fixedPinned => [3.926602, 7.068583, 10.210176],
        BeamEndCondition.freeFree => [4.730041, 7.853205, 10.995608],
      };
}

/// One transverse vibration mode of a beam.
class BeamMode {
  const BeamMode({
    required this.order,
    required this.betaL,
    required this.frequencyHz,
  });

  /// Mode number, 1 for the fundamental.
  final int order;

  /// The root (βL)ₙ this mode was computed from.
  final double betaL;

  /// Natural frequency, Hz.
  final double frequencyHz;

  /// Circular natural frequency, rad/s.
  double get omegaRadPerS => 2 * math.pi * frequencyHz;

  /// The same frequency as a shaft speed, rpm — the running speed an
  /// excitation at one-per-rev would have to reach to drive this mode.
  double get rpm => frequencyHz * 60;
}

class BeamNaturalFrequencyResult {
  const BeamNaturalFrequencyResult({
    required this.modes,
    required this.massPerLength,
    required this.flexuralRigidity,
  });

  /// The first three modes, fundamental first.
  final List<BeamMode> modes;

  /// Mass per unit length, ρA — kg/m.
  final double massPerLength;

  /// Flexural rigidity EI — N·m².
  final double flexuralRigidity;

  BeamMode get fundamental => modes.first;
}

/// Transverse natural frequencies of a uniform prismatic beam:
///
///   fₙ = (βL)ₙ² / (2π) · √( EI / (ρA·L⁴) )
///
/// This is the Euler-Bernoulli result — it ignores shear deformation and
/// rotary inertia, so it runs high for a stubby beam (roughly L/d below 10)
/// and for the higher modes of any beam.
abstract final class BeamNaturalFrequencyCalculator {
  /// Inputs are in the app's SI display units: [modulusGPa] in GPa,
  /// [momentOfInertiaMm4] in mm⁴, [areaMm2] in mm², [lengthM] in m,
  /// [densityKgM3] in kg/m³.
  static BeamNaturalFrequencyResult calculate({
    required double modulusGPa,
    required double momentOfInertiaMm4,
    required double areaMm2,
    required double lengthM,
    required double densityKgM3,
    required BeamEndCondition endCondition,
  }) {
    if (modulusGPa <= 0) {
      throw const FormatException('Modulus E must be positive.');
    }
    if (momentOfInertiaMm4 <= 0) {
      throw const FormatException('Moment of inertia I must be positive.');
    }
    if (areaMm2 <= 0) {
      throw const FormatException('Area A must be positive.');
    }
    if (lengthM <= 0) {
      throw const FormatException('Length L must be positive.');
    }
    if (densityKgM3 <= 0) {
      throw const FormatException('Density must be positive.');
    }

    // To SI base units, so EI/(ρA·L⁴) comes out in s⁻².
    final e = modulusGPa * 1e9; // Pa
    final i = momentOfInertiaMm4 * 1e-12; // m⁴
    final a = areaMm2 * 1e-6; // m²
    final massPerLength = densityKgM3 * a; // kg/m
    final ei = e * i; // N·m²

    final root = math.sqrt(ei / (massPerLength * math.pow(lengthM, 4)));
    final betas = endCondition.betaL;

    return BeamNaturalFrequencyResult(
      modes: [
        for (var n = 0; n < betas.length; n++)
          BeamMode(
            order: n + 1,
            betaL: betas[n],
            frequencyHz: betas[n] * betas[n] * root / (2 * math.pi),
          ),
      ],
      massPerLength: massPerLength,
      flexuralRigidity: ei,
    );
  }
}
