import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';

/// One conducting layer of a plane wall, in the app's SI display units.
class WallLayer {
  const WallLayer({required this.thickness, required this.conductivity});

  /// Layer thickness, mm.
  final double thickness;

  /// Thermal conductivity k, W/(m·K).
  final double conductivity;
}

/// A node in the resistance network, reported so the user can see where the
/// temperature actually falls — usually the point of running the calculation.
class WallNode {
  const WallNode({required this.label, required this.temperature});

  /// Where this temperature is: a surface, or the boundary between two layers.
  final String label;

  /// °C.
  final double temperature;
}

class CompositeWallResult {
  const CompositeWallResult({
    required this.totalResistance,
    required this.layerResistances,
    required this.insideFilmResistance,
    required this.outsideFilmResistance,
    required this.overallCoefficient,
    required this.heatFlux,
    required this.heatFlow,
    required this.nodes,
  });

  /// Total unit-area resistance, m²·K/W.
  final double totalResistance;

  /// Unit-area resistance of each conducting layer, m²·K/W, in input order.
  final List<double> layerResistances;

  /// 1/h on each side, m²·K/W. Zero when that film was not modelled.
  final double insideFilmResistance;
  final double outsideFilmResistance;

  /// U = 1/R_total, W/(m²·K).
  final double overallCoefficient;

  /// q" = ΔT/R_total, W/m².
  final double heatFlux;

  /// Q = q"·A, W.
  final double heatFlow;

  /// Temperatures through the wall, hot side first.
  final List<WallNode> nodes;
}

/// Steady one-dimensional conduction through a plane composite wall, with
/// optional convection films on either face.
///
/// Everything is computed per unit area first (m²·K/W), because that is the
/// form the resistances add in and the form U is defined on; the area only
/// enters at the last step to turn a flux into a heat flow.
abstract final class CompositeWallCalculator {
  /// [layers] hot side first. [area] m², [insideTemperature] and
  /// [outsideTemperature] °C, [insideCoefficient] and [outsideCoefficient]
  /// W/(m²·K) — pass null for a face with no convection film, where the given
  /// temperature is the surface temperature itself.
  ///
  /// [insideLabel] and [outsideLabel] name the two outermost nodes; callers
  /// pass localized text so the model stays free of hard-coded English.
  static CompositeWallResult calculate({
    required List<WallLayer> layers,
    required double area,
    required double insideTemperature,
    required double outsideTemperature,
    required String insideLabel,
    required String outsideLabel,
    required String surfaceLabel,
    required String interfaceLabel,
    double? insideCoefficient,
    double? outsideCoefficient,
  }) {
    if (layers.isEmpty) {
      throw const FormatException('Add at least one wall layer.');
    }
    if (area <= 0) {
      throw const FormatException('Area must be positive.');
    }
    for (final layer in layers) {
      if (layer.thickness <= 0) {
        throw const FormatException('Every layer needs a positive thickness.');
      }
      if (layer.conductivity <= 0) {
        throw const FormatException('Every layer needs a positive k.');
      }
    }
    if (insideCoefficient != null && insideCoefficient <= 0) {
      throw const FormatException('Inside film coefficient must be positive.');
    }
    if (outsideCoefficient != null && outsideCoefficient <= 0) {
      throw const FormatException('Outside film coefficient must be positive.');
    }

    // t is entered in mm but k is per metre, so the thickness converts here.
    final layerResistances = [
      for (final layer in layers) (layer.thickness / 1000) / layer.conductivity,
    ];
    final insideFilm =
        insideCoefficient == null ? 0.0 : 1 / insideCoefficient;
    final outsideFilm =
        outsideCoefficient == null ? 0.0 : 1 / outsideCoefficient;
    final totalResistance = insideFilm +
        layerResistances.fold<double>(0, (sum, r) => sum + r) +
        outsideFilm;

    final deltaT = insideTemperature - outsideTemperature;
    final heatFlux = deltaT / totalResistance;

    // Walk the network from the hot side, dropping q"·R across each element.
    final nodes = <WallNode>[
      WallNode(label: insideLabel, temperature: insideTemperature),
    ];
    var temperature = insideTemperature;
    if (insideCoefficient != null) {
      temperature -= heatFlux * insideFilm;
      nodes.add(WallNode(label: surfaceLabel, temperature: temperature));
    }
    for (var i = 0; i < layerResistances.length; i++) {
      temperature -= heatFlux * layerResistances[i];
      final isLast = i == layerResistances.length - 1;
      nodes.add(WallNode(
        label: isLast
            ? (outsideCoefficient == null ? outsideLabel : surfaceLabel)
            : '$interfaceLabel ${i + 1}-${i + 2}',
        temperature: temperature,
      ));
    }
    if (outsideCoefficient != null) {
      nodes.add(WallNode(
        label: outsideLabel,
        temperature: temperature - heatFlux * outsideFilm,
      ));
    }

    return CompositeWallResult(
      totalResistance: totalResistance,
      layerResistances: layerResistances,
      insideFilmResistance: insideFilm,
      outsideFilmResistance: outsideFilm,
      overallCoefficient: 1 / totalResistance,
      heatFlux: heatFlux,
      heatFlow: heatFlux * area,
      nodes: nodes,
    );
  }
}

class FinResult {
  const FinResult({
    required this.correctedLength,
    required this.finParameter,
    required this.efficiency,
    required this.heatFlow,
    required this.maximumHeatFlow,
    required this.effectiveness,
    required this.surfaceArea,
    required this.tipTemperature,
  });

  /// L_c = L + t/2, mm.
  final double correctedLength;

  /// m = √(2h/(k·t)), 1/m.
  final double finParameter;

  /// η_f = tanh(m·L_c)/(m·L_c), dimensionless.
  final double efficiency;

  /// Actual heat dissipated by the fin, W.
  final double heatFlow;

  /// Heat an isothermal (infinitely conductive) fin would dissipate, W.
  final double maximumHeatFlow;

  /// ε_f — fin heat flow over the bare-base heat flow it replaces.
  final double effectiveness;

  /// Exposed fin area 2·w·L_c, mm².
  final double surfaceArea;

  /// Temperature at the fin tip, °C.
  final double tipTemperature;
}

/// Straight rectangular fin of uniform cross-section, treated with the
/// adiabatic-tip solution and the corrected length L_c = L + t/2, which is the
/// standard way to account for tip convection without a second solution.
abstract final class FinCalculator {
  /// [length], [thickness], [width] mm; [conductivity] W/(m·K);
  /// [coefficient] W/(m²·K); [baseTemperature], [ambientTemperature] °C.
  static FinResult calculate({
    required double length,
    required double thickness,
    required double width,
    required double conductivity,
    required double coefficient,
    required double baseTemperature,
    required double ambientTemperature,
  }) {
    if (length <= 0) {
      throw const FormatException('Fin length must be positive.');
    }
    if (thickness <= 0) {
      throw const FormatException('Fin thickness must be positive.');
    }
    if (width <= 0) {
      throw const FormatException('Fin width must be positive.');
    }
    if (conductivity <= 0) {
      throw const FormatException('Thermal conductivity must be positive.');
    }
    if (coefficient <= 0) {
      throw const FormatException('Film coefficient must be positive.');
    }

    final lengthM = length / 1000;
    final thicknessM = thickness / 1000;
    final widthM = width / 1000;
    final correctedM = lengthM + thicknessM / 2;

    final m = math.sqrt(2 * coefficient / (conductivity * thicknessM));
    final mLc = m * correctedM;
    // tanh(x)/x -> 1 as x -> 0; the guard keeps a vanishingly short fin from
    // dividing by zero rather than reporting its correct 100% efficiency.
    final efficiency = mLc.abs() < 1e-12 ? 1.0 : _tanh(mLc) / mLc;

    final excessTemperature = baseTemperature - ambientTemperature;
    final surfaceAreaM2 = 2 * widthM * correctedM;
    final maximumHeatFlow = coefficient * surfaceAreaM2 * excessTemperature;
    final heatFlow = efficiency * maximumHeatFlow;
    // The base area the fin occupies, had it been left bare.
    final bareHeatFlow = coefficient * widthM * thicknessM * excessTemperature;

    return FinResult(
      correctedLength: correctedM * 1000,
      finParameter: m,
      efficiency: efficiency,
      heatFlow: heatFlow,
      maximumHeatFlow: maximumHeatFlow,
      effectiveness: bareHeatFlow == 0 ? double.nan : heatFlow / bareHeatFlow,
      surfaceArea: surfaceAreaM2 * 1e6,
      // Adiabatic-tip profile: θ(x)/θ_b = cosh(m(L-x))/cosh(mL), so the tip
      // excess temperature is θ_b/cosh(m·L_c).
      tipTemperature:
          ambientTemperature + excessTemperature / _cosh(mLc),
    );
  }
}

double _tanh(double x) {
  // Guard the overflow: sinh/cosh both blow up past ~710, but their ratio is
  // 1 to within a rounding error long before that.
  if (x.abs() > 20) return x.isNegative ? -1.0 : 1.0;
  final e2 = math.exp(2 * x);
  return (e2 - 1) / (e2 + 1);
}

double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;

/// How the two streams are routed past one another, which decides which
/// terminal temperatures pair up into the two end approaches.
enum FlowArrangement { counterFlow, parallelFlow }

extension FlowArrangementLabel on FlowArrangement {
  String label(BuildContext context) => switch (this) {
        FlowArrangement.counterFlow => S.of(context).Counter_Flow,
        FlowArrangement.parallelFlow => S.of(context).Parallel_Flow,
      };
}

class LmtdResult {
  const LmtdResult({
    required this.deltaT1,
    required this.deltaT2,
    required this.lmtd,
    required this.area,
    required this.hotRange,
    required this.coldRange,
  });

  /// Temperature approach at each end, °C.
  final double deltaT1;
  final double deltaT2;

  /// Log mean temperature difference, °C.
  final double lmtd;

  /// Required surface area A = Q/(U·ΔT_lm), m².
  final double area;

  /// Temperature change of each stream, °C.
  final double hotRange;
  final double coldRange;
}

/// Log mean temperature difference and the surface area a duty needs.
///
/// Only the four terminal temperatures matter here, so no stream flow rates
/// or specific heats are asked for; the duty [heatDuty] carries that
/// information already.
abstract final class LmtdCalculator {
  /// Temperatures in °C, [overallCoefficient] W/(m²·K), [heatDuty] W.
  static LmtdResult calculate({
    required double hotInlet,
    required double hotOutlet,
    required double coldInlet,
    required double coldOutlet,
    required FlowArrangement arrangement,
    required double overallCoefficient,
    required double heatDuty,
  }) {
    if (overallCoefficient <= 0) {
      throw const FormatException('Overall coefficient U must be positive.');
    }
    if (heatDuty <= 0) {
      throw const FormatException('Heat duty must be positive.');
    }
    if (hotOutlet > hotInlet) {
      throw const FormatException('The hot stream must leave cooler than it '
          'entered.');
    }
    if (coldOutlet < coldInlet) {
      throw const FormatException('The cold stream must leave warmer than it '
          'entered.');
    }

    final (deltaT1, deltaT2) = switch (arrangement) {
      FlowArrangement.counterFlow => (
          hotInlet - coldOutlet,
          hotOutlet - coldInlet,
        ),
      FlowArrangement.parallelFlow => (
          hotInlet - coldInlet,
          hotOutlet - coldOutlet,
        ),
    };

    if (deltaT1 <= 0 || deltaT2 <= 0) {
      throw const FormatException('These temperatures cross: the cold stream '
          'would have to end up hotter than the hot stream.');
    }

    // The log mean is indeterminate when the two approaches are equal; its
    // limit there is simply that common value.
    final lmtd = (deltaT1 - deltaT2).abs() < 1e-9
        ? deltaT1
        : (deltaT1 - deltaT2) / math.log(deltaT1 / deltaT2);

    return LmtdResult(
      deltaT1: deltaT1,
      deltaT2: deltaT2,
      lmtd: lmtd,
      area: heatDuty / (overallCoefficient * lmtd),
      hotRange: hotInlet - hotOutlet,
      coldRange: coldOutlet - coldInlet,
    );
  }
}
