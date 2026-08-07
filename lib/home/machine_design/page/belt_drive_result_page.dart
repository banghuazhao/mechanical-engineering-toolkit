import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/belt_drive_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BeltDriveResultPage extends StatelessWidget {
  const BeltDriveResultPage({
    super.key,
    required this.result,
    required this.d1,
    required this.d2,
    required this.c,
    required this.n1,
  });

  final BeltDriveResult result;
  final double d1;
  final double d2;
  final double c;
  final double n1;

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();

    final formulaSteps = [
      'ratio = d2/d1 = ${precs.formatSI(d2, UnitCategory.length, system)} / ${precs.formatSI(d1, UnitCategory.length, system)} = ${precs.formatValue(result.ratio)}',
      'L = 2C + (π/2)(d1+d2) + (d2−d1)²/(4C)',
      '= ${precs.formatSI(result.beltLength, UnitCategory.length, system)}',
      'Wrap: θ = π ∓ 2·asin((d2−d1)/(2C))',
      if (result.drivingTorqueNm != null)
        'T1 = P/ω1, Ft = T1/(d1/2) — required driving force, not a belt-capacity rating.',
    ];

    return ResultScaffold(
      toolName: S.of(context).Belt_Chain_Drive,
      formulaSteps: formulaSteps,
      results: [
        ResultSection(
          title: S.of(context).Belt_Chain_Drive,
          values: [
            ResultValue(
              label: S.of(context).Speed_Ratio,
              valueSI: result.ratio,
            ),
            ResultValue(
              label: S.of(context).Output_Speed_N2,
              valueSI: result.outputSpeedRpm,
              category: UnitCategory.angularVelocity,
            ),
            ResultValue(
              label: S.of(context).Belt_Length_L,
              valueSI: result.beltLength,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: S.of(context).Wrap_Angle_Small_Pulley,
              valueSI: result.smallWrapAngleDeg,
              category: UnitCategory.angle,
            ),
            ResultValue(
              label: S.of(context).Wrap_Angle_Large_Pulley,
              valueSI: result.largeWrapAngleDeg,
              category: UnitCategory.angle,
            ),
            if (result.drivingTorqueNm != null)
              ResultValue(
                label: S.of(context).Driving_Torque_T1,
                valueSI: result.drivingTorqueNm,
                category: UnitCategory.torque,
              ),
            if (result.beltPullN != null)
              ResultValue(
                label: S.of(context).Belt_Pull_Ft,
                valueSI: result.beltPullN,
                category: UnitCategory.force,
              ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: formulaSteps),
        ParameterSweepCard(
          variableLabel: S.of(context).Center_Distance_C,
          variableCategory: UnitCategory.length,
          baseValueSI: c,
          outputLabel: S.of(context).Belt_Length_L,
          outputCategory: UnitCategory.length,
          compute: (variedC) {
            final r = BeltDriveCalculator.calculate(BeltDriveInput(
              smallPulleyDiameter: d1,
              largePulleyDiameter: d2,
              centerDistance: variedC,
              inputSpeedRpm: n1,
            ));
            return r.beltLength;
          },
        ),
      ],
    );
  }
}
