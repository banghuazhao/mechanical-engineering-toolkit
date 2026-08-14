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

class FinEfficiencyResultPage extends StatelessWidget {
  const FinEfficiencyResultPage({
    super.key,
    required this.result,
    required this.length,
    required this.thickness,
    required this.width,
    required this.conductivity,
    required this.coefficient,
    required this.baseTemperature,
    required this.ambientTemperature,
  });

  final FinResult result;
  final double length;
  final double thickness;
  final double width;
  final double conductivity;
  final double coefficient;
  final double baseTemperature;
  final double ambientTemperature;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final steps = _steps(system, precs);

    return ResultScaffold(
      toolName: l10n.Fin_Efficiency,
      formulaSteps: steps,
      results: [
        ResultSection(
          title: l10n.Fin_Efficiency,
          values: [
            ResultValue(
              label: l10n.Fin_Efficiency_Eta,
              value: '${precs.formatValue(result.efficiency * 100)} %',
            ),
            ResultValue(
              label: l10n.Fin_Heat_Flow,
              valueSI: result.heatFlow,
              category: UnitCategory.heatFlow,
            ),
            ResultValue(
              label: l10n.Isothermal_Max_Heat_Flow,
              valueSI: result.maximumHeatFlow,
              category: UnitCategory.heatFlow,
            ),
            ResultValue(
              label: l10n.Fin_Effectiveness,
              valueSI: result.effectiveness,
            ),
            ResultValue(
              label: l10n.Tip_Temperature,
              valueSI: result.tipTemperature,
              category: UnitCategory.temperature,
            ),
          ],
        ),
        ResultSection(
          title: l10n.Section_Dimensions,
          values: [
            ResultValue(
              label: l10n.Corrected_Length_Lc,
              valueSI: result.correctedLength,
              category: UnitCategory.length,
            ),
            ResultValue(
              // m has units of 1/m, which has no pair in the app's unit table.
              label: l10n.Fin_Parameter_m,
              value: '${precs.formatValue(result.finParameter)} 1/m',
            ),
            ResultValue(
              label: l10n.Fin_Surface_Area,
              valueSI: result.surfaceArea,
              category: UnitCategory.area,
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: steps),
        ParameterSweepCard(
          variableLabel: l10n.Fin_Length_L,
          variableCategory: UnitCategory.length,
          baseValueSI: length,
          outputLabel: l10n.Fin_Heat_Flow,
          outputCategory: UnitCategory.heatFlow,
          // A longer fin always sheds more heat but at a falling rate; the
          // curve is where the point of diminishing returns shows up.
          compute: (variedLength) => FinCalculator.calculate(
            length: variedLength,
            thickness: thickness,
            width: width,
            conductivity: conductivity,
            coefficient: coefficient,
            baseTemperature: baseTemperature,
            ambientTemperature: ambientTemperature,
          ).heatFlow,
        ),
      ],
    );
  }

  List<String> _steps(UnitSystem system, NumberPrecisionHelper precs) {
    final mLc = result.finParameter * result.correctedLength / 1000;
    return [
      'Lc = L + t/2 = '
          '${precs.formatSI(result.correctedLength, UnitCategory.length, system)}',
      'm = √(2h/(k·t)) = ${precs.formatValue(result.finParameter)} 1/m',
      'm·Lc = ${precs.formatValue(mLc)}',
      'ηf = tanh(m·Lc)/(m·Lc) = '
          '${precs.formatValue(result.efficiency * 100)} %',
      'Q_max = h·A_f·(Tb − T∞) = '
          '${precs.formatSI(result.maximumHeatFlow, UnitCategory.heatFlow, system)}',
      'Q_fin = ηf·Q_max = '
          '${precs.formatSI(result.heatFlow, UnitCategory.heatFlow, system)}',
      'εf = Q_fin / (h·w·t·(Tb − T∞)) = '
          '${precs.formatValue(result.effectiveness)}',
    ];
  }
}
