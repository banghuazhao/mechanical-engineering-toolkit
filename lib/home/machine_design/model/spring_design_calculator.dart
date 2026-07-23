import 'dart:math' as math;

class SpringDesignInput {
  const SpringDesignInput({
    required this.wireDiameter,
    required this.coilDiameter,
    required this.activeCoils,
    required this.shearModulusGPa,
    this.force,
    this.densityKgM3 = 7850,
  });

  /// Wire diameter d, mm.
  final double wireDiameter;

  /// Mean coil diameter D, mm.
  final double coilDiameter;

  /// Number of active coils Na.
  final double activeCoils;

  /// Shear modulus G, GPa.
  final double shearModulusGPa;

  /// Operating axial force, N — optional; enables deflection/stress output.
  final double? force;

  /// Material density, kg/m³ — used only for the natural-frequency
  /// estimate. Defaults to steel.
  final double densityKgM3;
}

class SpringDesignResult {
  const SpringDesignResult({
    required this.springIndex,
    required this.wahlFactor,
    required this.rateNPerMm,
    required this.solidHeightMm,
    required this.naturalFrequencyHz,
    this.deflectionMm,
    this.shearStressMPa,
  });

  final double springIndex;
  final double wahlFactor;

  /// Spring rate, N/mm.
  final double rateNPerMm;

  /// Solid height (squared-and-ground ends assumed), mm.
  final double solidHeightMm;

  /// Estimated fundamental natural (surge) frequency, Hz — both ends fixed.
  final double naturalFrequencyHz;

  /// Deflection at the operating force, mm — null if force wasn't supplied.
  final double? deflectionMm;

  /// Shear stress at the operating force (Wahl-corrected), MPa — null if
  /// force wasn't supplied.
  final double? shearStressMPa;
}

/// Basic helical compression spring design: index, Wahl factor, rate,
/// operating deflection/stress, solid height, and an estimated fundamental
/// natural frequency (both ends fixed — a simplified textbook estimate, not
/// a substitute for a real dynamic analysis).
abstract final class SpringDesignCalculator {
  static SpringDesignResult calculate(SpringDesignInput input) {
    final d = input.wireDiameter;
    final coilD = input.coilDiameter;
    final na = input.activeCoils;
    final g = input.shearModulusGPa;

    if (d <= 0 || coilD <= 0) {
      throw const FormatException('Wire and coil diameter must be positive.');
    }
    if (na <= 0) {
      throw const FormatException('Number of active coils must be positive.');
    }
    if (g <= 0) {
      throw const FormatException('Shear modulus must be positive.');
    }
    if (coilD <= d) {
      throw const FormatException(
          'Coil diameter must be greater than wire diameter.');
    }

    final c = coilD / d;
    final kw = (4 * c - 1) / (4 * c - 4) + 0.615 / c;
    // G is entered in GPa; the mm/N-based rate formula needs the
    // numerically equivalent MPa value (1 GPa = 1000 MPa).
    final gMPa = g * 1000;
    final rate = gMPa * math.pow(d, 4) / (8 * math.pow(coilD, 3) * na);
    final solidHeight = (na + 2) * d;

    // Natural frequency needs base-SI units (meters, Pa, kg/m^3).
    final dM = d / 1000;
    final coilDM = coilD / 1000;
    final gPa = g * 1e9;
    final freq = (dM / (2 * math.pi * coilDM * coilDM * na)) *
        math.sqrt(gPa / (2 * input.densityKgM3));

    double? deflection;
    double? shear;
    final f = input.force;
    if (f != null && f > 0) {
      deflection = f / rate;
      shear = kw * 8 * f * coilD / (math.pi * math.pow(d, 3));
    }

    return SpringDesignResult(
      springIndex: c,
      wahlFactor: kw,
      rateNPerMm: rate,
      solidHeightMm: solidHeight,
      naturalFrequencyHz: freq,
      deflectionMm: deflection,
      shearStressMPa: shear,
    );
  }
}
