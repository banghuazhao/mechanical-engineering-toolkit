import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/heat_transfer_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class CompositeWallResultPage extends StatelessWidget {
  const CompositeWallResultPage({
    super.key,
    required this.result,
    required this.layers,
    required this.area,
  });

  final CompositeWallResult result;
  final List<WallLayer> layers;
  final double area;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final steps = _steps(l10n, system, precs);

    return ResultScaffold(
      toolName: l10n.Composite_Wall_Conduction,
      formulaSteps: steps,
      results: [
        ResultSection(
          title: l10n.Composite_Wall_Conduction,
          values: [
            ResultValue(
              label: l10n.Heat_Flow_Q,
              valueSI: result.heatFlow,
              category: UnitCategory.heatFlow,
            ),
            ResultValue(
              // Both q" (W/m²) and R (m²·K/W) are per-unit-area quantities
              // with no second unit pair in the app, so they are formatted
              // with their symbols rather than given a category.
              label: l10n.Heat_Flux,
              value: '${precs.formatValue(result.heatFlux)} W/m²',
            ),
            ResultValue(
              label: l10n.Total_Resistance_R,
              value: '${precs.formatValue(result.totalResistance)} m²·K/W',
            ),
            ResultValue(
              label: l10n.Overall_Coefficient_U,
              valueSI: result.overallCoefficient,
              category: UnitCategory.heatTransferCoefficient,
            ),
          ],
        ),
        ResultSection(
          title: l10n.Layer_Resistances,
          values: [
            if (result.insideFilmResistance > 0)
              ResultValue(
                label: '1/hi',
                value: '${precs.formatValue(result.insideFilmResistance)} '
                    'm²·K/W',
              ),
            for (var i = 0; i < result.layerResistances.length; i++)
              ResultValue(
                label: l10n.Layer_Number('${i + 1}'),
                value: '${precs.formatValue(result.layerResistances[i])} '
                    'm²·K/W',
              ),
            if (result.outsideFilmResistance > 0)
              ResultValue(
                label: '1/ho',
                value: '${precs.formatValue(result.outsideFilmResistance)} '
                    'm²·K/W',
              ),
          ],
        ),
        ResultSection(
          title: l10n.Wall_Temperatures,
          values: [
            for (final node in result.nodes)
              ResultValue(
                label: node.label,
                valueSI: node.temperature,
                category: UnitCategory.temperature,
              ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: steps),
        // Sweeping the thickness of the highest-resistance layer answers the
        // question the tool is usually opened for: how much more insulation
        // is worth adding.
        _insulationSweep(context, l10n),
      ],
    );
  }

  Widget _insulationSweep(BuildContext context, S l10n) {
    var thickest = 0;
    for (var i = 1; i < result.layerResistances.length; i++) {
      if (result.layerResistances[i] > result.layerResistances[thickest]) {
        thickest = i;
      }
    }
    final governing = layers[thickest];
    final deltaT = result.nodes.first.temperature - result.nodes.last.temperature;
    final fixedResistance =
        result.totalResistance - result.layerResistances[thickest];

    return ParameterSweepCard(
      variableLabel: '${l10n.Layer_Number('${thickest + 1}')} — '
          '${l10n.Thickness_t}',
      variableCategory: UnitCategory.length,
      baseValueSI: governing.thickness,
      outputLabel: l10n.Heat_Flow_Q,
      outputCategory: UnitCategory.heatFlow,
      minSI: governing.thickness * 0.1,
      maxSI: governing.thickness * 3,
      compute: (variedThickness) {
        final total =
            fixedResistance + (variedThickness / 1000) / governing.conductivity;
        return deltaT / total * area;
      },
    );
  }

  List<String> _steps(
    S l10n,
    UnitSystem system,
    NumberPrecisionHelper precs,
  ) {
    final steps = <String>['R = Σ t/k + 1/h (per m² of wall)'];
    if (result.insideFilmResistance > 0) {
      steps.add('1/hi = '
          '${precs.formatValue(result.insideFilmResistance)} m²·K/W');
    }
    for (var i = 0; i < layers.length; i++) {
      steps.add('${l10n.Layer_Number('${i + 1}')}: t/k = '
          '${precs.formatSI(layers[i].thickness, UnitCategory.length, system)} / '
          '${precs.formatSI(layers[i].conductivity, UnitCategory.thermalConductivity, system)}'
          ' = ${precs.formatValue(result.layerResistances[i])} m²·K/W');
    }
    if (result.outsideFilmResistance > 0) {
      steps.add('1/ho = '
          '${precs.formatValue(result.outsideFilmResistance)} m²·K/W');
    }
    steps.addAll([
      'R_total = ${precs.formatValue(result.totalResistance)} m²·K/W',
      'U = 1/R_total = '
          '${precs.formatSI(result.overallCoefficient, UnitCategory.heatTransferCoefficient, system)}',
      'q" = ΔT/R_total = ${precs.formatValue(result.heatFlux)} W/m²',
      'Q = q"·A = '
          '${precs.formatSI(result.heatFlow, UnitCategory.heatFlow, system)}',
    ]);
    return steps;
  }
}
