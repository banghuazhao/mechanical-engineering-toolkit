import 'dart:math' as math;

/// Lewis form factor Y for 20° full-depth involute teeth, a standard
/// published table (e.g. Shigley's Mechanical Engineering Design). Linearly
/// interpolated between entries; clamped to the table's endpoints outside
/// its range.
const List<(int teeth, double y)> _lewisFormFactorTable = [
  (12, 0.245),
  (13, 0.261),
  (14, 0.277),
  (15, 0.290),
  (16, 0.296),
  (17, 0.303),
  (18, 0.309),
  (19, 0.314),
  (20, 0.322),
  (21, 0.328),
  (22, 0.331),
  (24, 0.337),
  (26, 0.346),
  (28, 0.353),
  (30, 0.359),
  (34, 0.371),
  (38, 0.384),
  (43, 0.397),
  (50, 0.409),
  (60, 0.422),
  (75, 0.435),
  (100, 0.447),
  (150, 0.460),
  (300, 0.472),
];

double lewisFormFactor(int teeth) {
  if (teeth <= _lewisFormFactorTable.first.$1) {
    return _lewisFormFactorTable.first.$2;
  }
  if (teeth >= _lewisFormFactorTable.last.$1) {
    return _lewisFormFactorTable.last.$2;
  }
  for (var i = 0; i < _lewisFormFactorTable.length - 1; i++) {
    final (n0, y0) = _lewisFormFactorTable[i];
    final (n1, y1) = _lewisFormFactorTable[i + 1];
    if (teeth >= n0 && teeth <= n1) {
      final t = (teeth - n0) / (n1 - n0);
      return y0 + t * (y1 - y0);
    }
  }
  return _lewisFormFactorTable.last.$2; // unreachable
}

class SpurGearInput {
  const SpurGearInput({
    required this.module,
    required this.pinionTeeth,
    required this.gearTeeth,
    required this.faceWidth,
    this.tangentialLoad,
    this.elasticCoefficient = 191,
  });

  /// Module, mm.
  final double module;
  final int pinionTeeth;
  final int gearTeeth;

  /// Face width, mm.
  final double faceWidth;

  /// Transmitted tangential load, N — optional; enables stress output.
  final double? tangentialLoad;

  /// AGMA elastic coefficient Cp, √MPa — default is a typical steel-on-steel
  /// value.
  final double elasticCoefficient;
}

class SpurGearResult {
  const SpurGearResult({
    required this.pinionPitchDiameter,
    required this.gearPitchDiameter,
    required this.centerDistance,
    required this.gearRatio,
    required this.lewisFormFactor,
    this.bendingStressMPa,
    this.contactStressMPa,
  });

  /// mm.
  final double pinionPitchDiameter;

  /// mm.
  final double gearPitchDiameter;

  /// mm.
  final double centerDistance;
  final double gearRatio;

  /// Lewis form factor used for the pinion (usually the critical member).
  final double lewisFormFactor;

  /// Lewis bending stress at the pinion root, MPa — null if no load given.
  final double? bendingStressMPa;

  /// Simplified (basic) Hertzian contact stress estimate, MPa — null if no
  /// load given. Not a full AGMA-compliant design stress: overload, dynamic,
  /// load-distribution, and geometry factors are omitted.
  final double? contactStressMPa;
}

/// Basic 20°-full-depth spur gear geometry, plus simplified Lewis bending
/// stress and an approximate Hertzian contact stress when a tangential load
/// is supplied. Not a substitute for a full AGMA design check.
abstract final class SpurGearCalculator {
  static SpurGearResult calculate(SpurGearInput input) {
    final m = input.module;
    final n1 = input.pinionTeeth;
    final n2 = input.gearTeeth;
    final f = input.faceWidth;

    if (m <= 0) {
      throw const FormatException('Module must be positive.');
    }
    if (n1 < 8 || n2 < 8) {
      throw const FormatException(
          'Tooth counts should be at least 8 to avoid undercutting.');
    }
    if (f <= 0) {
      throw const FormatException('Face width must be positive.');
    }

    final d1 = m * n1;
    final d2 = m * n2;
    final centerDistance = (d1 + d2) / 2;
    final ratio = n2 / n1;
    final y = lewisFormFactor(n1);

    double? bending;
    double? contact;
    final wt = input.tangentialLoad;
    if (wt != null && wt > 0) {
      bending = wt / (f * m * y);
      contact = input.elasticCoefficient *
          math.sqrt((wt / (f * d1)) * (ratio + 1) / ratio);
    }

    return SpurGearResult(
      pinionPitchDiameter: d1,
      gearPitchDiameter: d2,
      centerDistance: centerDistance,
      gearRatio: ratio,
      lewisFormFactor: y,
      bendingStressMPa: bending,
      contactStressMPa: contact,
    );
  }
}
