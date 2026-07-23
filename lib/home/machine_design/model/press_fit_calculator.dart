class PressFitInput {
  const PressFitInput({
    required this.interfaceRadius,
    required this.hubOuterRadius,
    required this.diametralInterference,
    required this.modulusGPa,
    this.poissonsRatio = 0.3,
  });

  /// Nominal interface radius r, mm (shaft outer / hub inner, before fit).
  final double interfaceRadius;

  /// Hub outer radius r_o, mm.
  final double hubOuterRadius;

  /// Diametral interference (difference in diameters before assembly), mm.
  final double diametralInterference;

  /// Elastic modulus, GPa — same material assumed for shaft and hub.
  final double modulusGPa;

  /// Poisson's ratio (cancels out in the same-material case; kept for
  /// documentation/future two-material support).
  final double poissonsRatio;
}

class PressFitResult {
  const PressFitResult({
    required this.contactPressureMPa,
    required this.hubHoopStressMPa,
    required this.shaftStressMPa,
  });

  final double contactPressureMPa;
  final double hubHoopStressMPa;
  final double shaftStressMPa;
}

/// Solid-shaft/hub interference (shrink/press) fit, same material both
/// parts — the classic simplified Lamé result (Poisson's ratio cancels).
abstract final class PressFitCalculator {
  static PressFitResult calculate(PressFitInput input) {
    final r = input.interfaceRadius;
    final ro = input.hubOuterRadius;
    final deltaD = input.diametralInterference;
    final e = input.modulusGPa;

    if (r <= 0) {
      throw const FormatException('Interface radius must be positive.');
    }
    if (ro <= r) {
      throw const FormatException(
          'Hub outer radius must be greater than the interface radius.');
    }
    if (deltaD <= 0) {
      throw const FormatException('Interference must be positive.');
    }
    if (e <= 0) {
      throw const FormatException('Modulus must be positive.');
    }

    final deltaR = deltaD / 2;
    // E is entered in GPa; the mm-based formula needs the numerically
    // equivalent MPa value (1 GPa = 1000 MPa) to keep pressure in MPa.
    final eMPa = e * 1000;
    final ratio = (ro * ro + r * r) / (ro * ro - r * r);
    final p = eMPa * deltaR / (r * (ratio + 1));
    final hubHoop = p * ratio;
    final shaftStress = -p;

    return PressFitResult(
      contactPressureMPa: p,
      hubHoopStressMPa: hubHoop,
      shaftStressMPa: shaftStress,
    );
  }
}
