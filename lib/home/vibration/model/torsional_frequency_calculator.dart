import 'dart:math' as math;

/// The two rotor arrangements this tool covers.
enum TorsionalSystem {
  /// One rotor on a shaft built in at the far end — a flywheel on a stub
  /// shaft off a rigid casing, say.
  singleRotor,

  /// Two rotors on the ends of a free shaft — the classic engine-and-load
  /// pairing, which twists about a node somewhere between them.
  twoRotor,
}

class TorsionalFrequencyResult {
  const TorsionalFrequencyResult({
    required this.stiffnessNmPerRad,
    required this.polarMomentMm4,
    required this.frequencyHz,
    required this.effectiveInertia,
    required this.nodeFromFirstRotorM,
  });

  /// Torsional stiffness of the shaft, N·m per radian.
  final double stiffnessNmPerRad;

  /// Polar second moment of area of the round shaft, mm⁴.
  final double polarMomentMm4;

  /// Fundamental torsional natural frequency, Hz.
  final double frequencyHz;

  /// The inertia the stiffness actually works against, kg·m² — J for a single
  /// rotor, and the reduced inertia J₁J₂/(J₁+J₂) for a two-rotor shaft.
  final double effectiveInertia;

  /// Distance from the first rotor to the torsional node, m. Null for a
  /// single-rotor system, whose node is the built-in end by definition.
  final double? nodeFromFirstRotorM;

  double get omegaRadPerS => 2 * math.pi * frequencyHz;

  /// The frequency as a shaft speed, rpm — the running speed at which a
  /// one-per-rev torque ripple would excite this mode.
  double get rpm => frequencyHz * 60;
}

/// Fundamental torsional natural frequency of a round shaft carrying one or
/// two rotors.
///
/// Both cases are ω = √(kt/J_eff) with kt = GJp/L; only the effective inertia
/// differs. The shaft's own inertia is neglected, which is the usual
/// assumption when the rotors dominate — a shaft whose inertia is comparable
/// to the rotors' needs a proper multi-station (Holzer) analysis instead.
abstract final class TorsionalFrequencyCalculator {
  /// Inputs are in the app's SI display units: [shearModulusGPa] in GPa,
  /// [diameterMm] in mm, [lengthM] in m, and the rotor inertias in kg·m².
  ///
  /// [secondInertiaKgM2] is required for [TorsionalSystem.twoRotor] and
  /// ignored for a single rotor.
  static TorsionalFrequencyResult calculate({
    required double shearModulusGPa,
    required double diameterMm,
    required double lengthM,
    required double firstInertiaKgM2,
    double? secondInertiaKgM2,
    required TorsionalSystem system,
  }) {
    if (shearModulusGPa <= 0) {
      throw const FormatException('Shear modulus G must be positive.');
    }
    if (diameterMm <= 0) {
      throw const FormatException('Shaft diameter must be positive.');
    }
    if (lengthM <= 0) {
      throw const FormatException('Shaft length L must be positive.');
    }
    if (firstInertiaKgM2 <= 0) {
      throw const FormatException('Rotor inertia must be positive.');
    }

    final g = shearModulusGPa * 1e9; // Pa
    final d = diameterMm * 1e-3; // m
    final jp = math.pi * math.pow(d, 4) / 32; // m⁴
    final kt = g * jp / lengthM; // N·m/rad

    final double effectiveInertia;
    final double? node;
    switch (system) {
      case TorsionalSystem.singleRotor:
        effectiveInertia = firstInertiaKgM2;
        node = null;
      case TorsionalSystem.twoRotor:
        final j2 = secondInertiaKgM2;
        if (j2 == null || j2 <= 0) {
          throw const FormatException('Second rotor inertia must be positive.');
        }
        // Two free rotors twist about a stationary node, so each sees only
        // its own share of the shaft. Folding that back into one degree of
        // freedom leaves the reduced inertia J₁J₂/(J₁+J₂).
        effectiveInertia =
            firstInertiaKgM2 * j2 / (firstInertiaKgM2 + j2);
        // The node sits where the two twist angles match, dividing the shaft
        // in inverse proportion to the inertias.
        node = lengthM * j2 / (firstInertiaKgM2 + j2);
    }

    final omega = math.sqrt(kt / effectiveInertia);

    return TorsionalFrequencyResult(
      stiffnessNmPerRad: kt,
      polarMomentMm4: jp * 1e12,
      frequencyHz: omega / (2 * math.pi),
      effectiveInertia: effectiveInertia,
      nodeFromFirstRotorM: node,
    );
  }
}
