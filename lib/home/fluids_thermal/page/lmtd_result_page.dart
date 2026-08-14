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

class LmtdResultPage extends StatelessWidget {
  const LmtdResultPage({
    super.key,
    required this.result,
    required this.arrangement,
    required this.overallCoefficient,
    required this.heatDuty,
  });

  final LmtdResult result;
  final FlowArrangement arrangement;
  final double overallCoefficient;
  final double heatDuty;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final steps = _steps(context, system, precs);

    return ResultScaffold(
      toolName: l10n.Heat_Exchanger_LMTD,
      formulaSteps: steps,
      results: [
        ResultSection(
          title: l10n.Heat_Exchanger_LMTD,
          values: [
            ResultValue(
              label: l10n.Log_Mean_Delta_T,
              valueSI: result.lmtd,
              category: UnitCategory.temperatureDelta,
            ),
            ResultValue(
              label: l10n.Required_Area_A,
              valueSI: result.area,
              category: UnitCategory.areaStructural,
            ),
            ResultValue(
              label: l10n.Flow_Arrangement,
              value: arrangement.label(context),
            ),
          ],
        ),
        ResultSection(
          title: l10n.Flow_Regime,
          values: [
            ResultValue(
              label: l10n.End_Approach_1,
              valueSI: result.deltaT1,
              category: UnitCategory.temperatureDelta,
            ),
            ResultValue(
              label: l10n.End_Approach_2,
              valueSI: result.deltaT2,
              category: UnitCategory.temperatureDelta,
            ),
            ResultValue(
              label: l10n.Hot_Stream_Range,
              valueSI: result.hotRange,
              category: UnitCategory.temperatureDelta,
            ),
            ResultValue(
              label: l10n.Cold_Stream_Range,
              valueSI: result.coldRange,
              category: UnitCategory.temperatureDelta,
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: steps),
        ParameterSweepCard(
          variableLabel: l10n.Overall_Coefficient_U,
          variableCategory: UnitCategory.heatTransferCoefficient,
          baseValueSI: overallCoefficient,
          outputLabel: l10n.Required_Area_A,
          outputCategory: UnitCategory.areaStructural,
          // U is the number carrying the most uncertainty in a first-pass
          // sizing, so the area's sensitivity to it is worth seeing.
          compute: (variedU) => heatDuty / (variedU * result.lmtd),
        ),
      ],
    );
  }

  List<String> _steps(
    BuildContext context,
    UnitSystem system,
    NumberPrecisionHelper precs,
  ) {
    String dt(double v) =>
        precs.formatSI(v, UnitCategory.temperatureDelta, system);
    return [
      '${arrangement.label(context)}:',
      'ΔT1 = ${dt(result.deltaT1)}',
      'ΔT2 = ${dt(result.deltaT2)}',
      'ΔT_lm = (ΔT1 − ΔT2)/ln(ΔT1/ΔT2) = ${dt(result.lmtd)}',
      'A = Q/(U·ΔT_lm) = '
          '${precs.formatSI(heatDuty, UnitCategory.heatFlow, system)} / '
          '(${precs.formatSI(overallCoefficient, UnitCategory.heatTransferCoefficient, system)}'
          ' × ${dt(result.lmtd)})',
      '= ${precs.formatSI(result.area, UnitCategory.areaStructural, system)}',
    ];
  }
}
