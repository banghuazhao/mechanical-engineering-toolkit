import 'dart:math' as math;

class BeltDriveInput {
  const BeltDriveInput({
    required this.smallPulleyDiameter,
    required this.largePulleyDiameter,
    required this.centerDistance,
    required this.inputSpeedRpm,
    this.powerW,
  });

  /// Small pulley pitch diameter, mm.
  final double smallPulleyDiameter;

  /// Large pulley pitch diameter, mm.
  final double largePulleyDiameter;

  /// Center distance, mm.
  final double centerDistance;

  /// Driving (small) pulley rotational speed, rpm.
  final double inputSpeedRpm;

  /// Transmitted power, W (optional — enables torque/belt-pull output).
  final double? powerW;
}

class BeltDriveResult {
  const BeltDriveResult({
    required this.ratio,
    required this.outputSpeedRpm,
    required this.beltLength,
    required this.smallWrapAngleDeg,
    required this.largeWrapAngleDeg,
    this.drivingTorqueNm,
    this.beltPullN,
  });

  final double ratio;
  final double outputSpeedRpm;

  /// Approximate open-belt length, mm.
  final double beltLength;
  final double smallWrapAngleDeg;
  final double largeWrapAngleDeg;

  /// Torque required at the small (driving) pulley, N·m — null if power
  /// wasn't supplied.
  final double? drivingTorqueNm;

  /// Tangential belt pull at the small pulley, N — null if power wasn't
  /// supplied. This is the force the drive must deliver, not a belt
  /// capacity/selection rating.
  final double? beltPullN;
}

/// Basic open-belt (or roller-chain, using pitch diameters) drive geometry:
/// speed ratio, approximate belt length, and pulley wrap angles.
abstract final class BeltDriveCalculator {
  static BeltDriveResult calculate(BeltDriveInput input) {
    final d1 = input.smallPulleyDiameter;
    final d2 = input.largePulleyDiameter;
    final c = input.centerDistance;
    final n1 = input.inputSpeedRpm;

    if (d1 <= 0 || d2 <= 0) {
      throw const FormatException('Pulley diameters must be positive.');
    }
    if (c <= 0) {
      throw const FormatException('Center distance must be positive.');
    }
    if (n1 <= 0) {
      throw const FormatException('Input speed must be positive.');
    }
    final sinArg = (d2 - d1) / (2 * c);
    if (sinArg.abs() > 1) {
      throw const FormatException(
          'Center distance is too small for these pulley diameters.');
    }

    final ratio = d2 / d1;
    final n2 = n1 / ratio;
    final length =
        2 * c + (math.pi / 2) * (d1 + d2) + math.pow(d2 - d1, 2) / (4 * c);
    final halfAngle = math.asin(sinArg);
    final smallWrapRad = math.pi - 2 * halfAngle;
    final largeWrapRad = math.pi + 2 * halfAngle;

    double? torque;
    double? pull;
    if (input.powerW != null && input.powerW! > 0) {
      final omega1 = 2 * math.pi * n1 / 60;
      torque = input.powerW! / omega1;
      pull = torque / (d1 / 2 / 1000); // d1 mm -> m for a torque in N·m
    }

    return BeltDriveResult(
      ratio: ratio,
      outputSpeedRpm: n2,
      beltLength: length,
      smallWrapAngleDeg: smallWrapRad * 180 / math.pi,
      largeWrapAngleDeg: largeWrapRad * 180 / math.pi,
      drivingTorqueNm: torque,
      beltPullN: pull,
    );
  }
}
