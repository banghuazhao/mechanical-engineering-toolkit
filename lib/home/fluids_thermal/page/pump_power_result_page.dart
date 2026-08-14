import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/pipe_flow_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class PumpPowerResultPage extends StatelessWidget {
  const PumpPowerResultPage({
    super.key,
    required this.result,
    required this.flowRate,
    required this.pressureRise,
    required this.density,
    required this.efficiency,
  });

  final PumpPowerResult result;
  final double flowRate;
  final double pressureRise;
  final double density;
  final double efficiency;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final steps = _steps(system, precs);

    return ResultScaffold(
      toolName: l10n.Pump_Fan_Power,
      formulaSteps: steps,
      results: [
        ResultSection(
          title: l10n.Pump_Fan_Power,
          values: [
            ResultValue(
              label: l10n.Shaft_Power,
              valueSI: result.shaftPower,
              category: UnitCategory.power,
            ),
            ResultValue(
              label: l10n.Hydraulic_Power,
              valueSI: result.hydraulicPower,
              category: UnitCategory.power,
            ),
            ResultValue(
              label: l10n.Power_Lost,
              valueSI: result.lostPower,
              category: UnitCategory.power,
            ),
            ResultValue(
              label: l10n.Pump_Head,
              valueSI: result.head,
              category: UnitCategory.span,
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: steps),
        ParameterSweepCard(
          variableLabel: l10n.Flow_Rate_Q,
          variableCategory: UnitCategory.volumeFlow,
          baseValueSI: flowRate,
          outputLabel: l10n.Shaft_Power,
          outputCategory: UnitCategory.power,
          compute: (variedFlow) => PumpPowerCalculator.calculate(
            flowRate: variedFlow,
            pressureRise: pressureRise,
            density: density,
            efficiency: efficiency,
          ).shaftPower,
        ),
      ],
    );
  }

  List<String> _steps(UnitSystem system, NumberPrecisionHelper precs) => [
        'P_hyd = Δp·Q = '
            '${precs.formatSI(pressureRise, UnitCategory.pressure, system)} × '
            '${precs.formatSI(flowRate, UnitCategory.volumeFlow, system)}',
        '= ${precs.formatSI(result.hydraulicPower, UnitCategory.power, system)}',
        'P_shaft = P_hyd/η = ${precs.formatValue(efficiency)}% → '
            '${precs.formatSI(result.shaftPower, UnitCategory.power, system)}',
        'H = Δp/(ρ·g) = '
            '${precs.formatSI(result.head, UnitCategory.span, system)}',
      ];
}
