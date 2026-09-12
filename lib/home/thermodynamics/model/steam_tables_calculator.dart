import 'dart:math' as math;

import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/iapws_if97.dart';

/// Which pair of properties a steam-table lookup starts from.
enum SteamLookup {
  /// Saturated liquid and vapour at a temperature — table A-4 in Çengel.
  saturatedByTemperature,

  /// Saturated liquid and vapour at a pressure — table A-5.
  saturatedByPressure,

  /// A single-phase state at pressure and temperature — tables A-6 and A-7.
  pressureTemperature,

  /// A wet mixture at pressure and quality.
  pressureQuality,

  /// Pressure and enthalpy — the throttle and the heat balance.
  pressureEnthalpy,

  /// Pressure and entropy — the isentropic turbine and pump.
  pressureEntropy,
}

/// What a single state is, in the words a steam table uses.
enum SteamPhase {
  compressedLiquid,
  wetMixture,
  superheatedVapour,
  supercriticalFluid,
}

/// Inputs in the app's SI display units: °C, kPa, kJ/kg, kJ/(kg·K).
class SteamTableInput {
  const SteamTableInput({
    required this.lookup,
    this.temperatureC,
    this.pressureKPa,
    this.quality,
    this.enthalpy,
    this.entropy,
  });

  final SteamLookup lookup;
  final double? temperatureC;
  final double? pressureKPa;

  /// Vapour mass fraction, 0–1.
  final double? quality;
  final double? enthalpy;
  final double? entropy;
}

/// Either a saturation row (liquid and vapour side by side) or a single
/// state, never both.
class SteamTableResult {
  const SteamTableResult._({this.saturation, this.point, this.phase});

  final SaturationProperties? saturation;
  final SteamPoint? point;
  final SteamPhase? phase;

  bool get isSaturationRow => saturation != null && point == null;
}

/// Why a lookup could not be made. [kind] is what the page turns into a
/// localized message; the calculator itself stays free of UI strings.
enum SteamInputProblem {
  missingInput,
  temperatureOutOfRange,
  pressureOutOfRange,
  aboveCriticalForSaturation,
  qualityOutOfRange,
  outsideFormulation,
}

class SteamInputException implements Exception {
  const SteamInputException(this.kind);
  final SteamInputProblem kind;

  @override
  String toString() => 'SteamInputException: $kind';
}

abstract final class SteamTablesCalculator {
  static SteamTableResult calculate(SteamTableInput input) {
    double need(double? value) =>
        value ?? (throw const SteamInputException(SteamInputProblem.missingInput));

    try {
      switch (input.lookup) {
        case SteamLookup.saturatedByTemperature:
          final t = need(input.temperatureC) + 273.15;
          if (t < If97.tMin - 1e-9 || t > If97.tc) {
            throw const SteamInputException(
                SteamInputProblem.temperatureOutOfRange);
          }
          return SteamTableResult._(
              saturation: If97.saturationAtTemperature(t));
        case SteamLookup.saturatedByPressure:
          final p = need(input.pressureKPa) / 1000;
          if (p > If97.pc) {
            throw const SteamInputException(
                SteamInputProblem.aboveCriticalForSaturation);
          }
          if (p < 611.213e-6) {
            throw const SteamInputException(
                SteamInputProblem.pressureOutOfRange);
          }
          return SteamTableResult._(saturation: If97.saturationAtPressure(p));
        case SteamLookup.pressureTemperature:
          final p = need(input.pressureKPa) / 1000;
          final t = need(input.temperatureC) + 273.15;
          final state = If97.state(p, t);
          return SteamTableResult._(
            point: SteamPoint.single(state),
            phase: phaseOf(state),
          );
        case SteamLookup.pressureQuality:
          final p = need(input.pressureKPa) / 1000;
          final x = need(input.quality);
          if (x < 0 || x > 1) {
            throw const SteamInputException(
                SteamInputProblem.qualityOutOfRange);
          }
          if (p > If97.pc) {
            throw const SteamInputException(
                SteamInputProblem.aboveCriticalForSaturation);
          }
          return SteamTableResult._(
            point: If97.stateFromPressureQuality(p, x),
            phase: SteamPhase.wetMixture,
          );
        case SteamLookup.pressureEnthalpy:
          return _fromPoint(If97.stateFromPressureEnthalpy(
              need(input.pressureKPa) / 1000, need(input.enthalpy)));
        case SteamLookup.pressureEntropy:
          return _fromPoint(If97.stateFromPressureEntropy(
              need(input.pressureKPa) / 1000, need(input.entropy)));
      }
    } on SteamRangeException {
      throw const SteamInputException(SteamInputProblem.outsideFormulation);
    }
  }

  static SteamTableResult _fromPoint(SteamPoint point) => SteamTableResult._(
        point: point,
        phase: point.isMixture ? SteamPhase.wetMixture : phaseOf(point.single!),
      );

  /// How a steam table would file a single-phase [state].
  ///
  /// Above both critical values it is supercritical fluid. Below the critical
  /// pressure it is liquid or vapour by which side of the saturation
  /// temperature it sits; above the critical pressure but below the critical
  /// temperature, tables list it with the compressed liquid.
  static SteamPhase phaseOf(SteamProperties state) {
    final p = state.pressure;
    final t = state.temperature;
    if (p >= If97.pc) {
      return t >= If97.tc
          ? SteamPhase.supercriticalFluid
          : SteamPhase.compressedLiquid;
    }
    return t < If97.saturationTemperature(p)
        ? SteamPhase.compressedLiquid
        : SteamPhase.superheatedVapour;
  }

  /// The saturation dome on a T–s diagram, (s kJ/(kg·K), T K), up the
  /// saturated-liquid line to the critical point and back down the vapour
  /// line. Computed once: it is the same dome behind every chart.
  static final List<({double s, double t})> saturationDome = () {
    const samples = 48;
    final liquid = <({double s, double t})>[];
    final vapour = <({double s, double t})>[];
    for (var k = 0; k <= samples; k++) {
      // Denser near the top, where the dome turns over.
      final fraction = 1 - math.pow(1 - k / samples, 2).toDouble();
      final t = If97.tMin + 0.01 + (If97.tc - If97.tMin - 0.01) * fraction;
      final sat = If97.saturationAtTemperature(math.min(t, If97.tc));
      liquid.add((s: sat.liquid.entropy, t: sat.temperature));
      vapour.add((s: sat.vapour.entropy, t: sat.temperature));
    }
    return [...liquid, ...vapour.reversed];
  }();
}
