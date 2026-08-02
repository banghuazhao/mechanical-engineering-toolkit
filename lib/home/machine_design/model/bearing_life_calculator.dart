import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'dart:math' as math;

enum BearingType { ball, roller }

extension BearingTypeExponent on BearingType {
  /// Life exponent p in L10 = (C/P)^p.
  double get exponent => this == BearingType.ball ? 3.0 : 10.0 / 3.0;

  /// Display name in the active locale. Takes a context rather than
  /// returning a literal so the model stays free of hard-coded English.
  String label(BuildContext context) => this == BearingType.ball
      ? S.of(context).Ball_Bearing
      : S.of(context).Roller_Bearing;
}

class BearingLifeResult {
  const BearingLifeResult({required this.l10Million, required this.l10Hours});

  /// Rating life, in millions of revolutions.
  final double l10Million;

  /// Rating life, in hours, at the given speed.
  final double l10Hours;
}

/// Basic L10 bearing life: L10 = (C/P)^p, converted to hours at a given
/// rotational speed. C and P must be expressed in the same force unit.
abstract final class BearingLifeCalculator {
  static BearingLifeResult calculate({
    required double dynamicLoadRating,
    required double equivalentLoad,
    required BearingType type,
    required double speedRpm,
  }) {
    if (dynamicLoadRating <= 0) {
      throw const FormatException('Dynamic load rating C must be positive.');
    }
    if (equivalentLoad <= 0) {
      throw const FormatException('Equivalent load P must be positive.');
    }
    if (speedRpm <= 0) {
      throw const FormatException('Speed must be positive.');
    }

    final l10Million =
        math.pow(dynamicLoadRating / equivalentLoad, type.exponent).toDouble();
    final l10Hours = l10Million * 1e6 / (60 * speedRpm);
    return BearingLifeResult(l10Million: l10Million, l10Hours: l10Hours);
  }
}
