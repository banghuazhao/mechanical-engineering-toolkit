import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/belt_drive_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
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

    return ResultScaffold(
      toolName: S.of(context).Belt_Chain_Drive,
      shareLines: () => _shareLines(system, precs),
      children: [
        AppSectionCard(
          title: S.of(context).Belt_Chain_Drive,
          child: Column(children: [
            AppCopyableValue(
              label: S.of(context).Speed_Ratio,
              value: precs.formatValue(result.ratio),
            ),
            AppCopyableValue(
              label: S.of(context).Output_Speed_N2,
              valueSI: result.outputSpeedRpm,
              category: UnitCategory.angularVelocity,
            ),
            AppCopyableValue(
              label: S.of(context).Belt_Length_L,
              valueSI: result.beltLength,
              category: UnitCategory.length,
            ),
            AppCopyableValue(
              label: S.of(context).Wrap_Angle_Small_Pulley,
              value: '${precs.formatValue(result.smallWrapAngleDeg)}°',
            ),
            AppCopyableValue(
              label: S.of(context).Wrap_Angle_Large_Pulley,
              value: '${precs.formatValue(result.largeWrapAngleDeg)}°',
            ),
            if (result.drivingTorqueNm != null)
              AppCopyableValue(
                label: S.of(context).Driving_Torque_T1,
                valueSI: result.drivingTorqueNm,
                category: UnitCategory.torque,
              ),
            if (result.beltPullN != null)
              AppCopyableValue(
                label: S.of(context).Belt_Pull_Ft,
                valueSI: result.beltPullN,
                category: UnitCategory.force,
              ),
          ]),
        ),
        FormulaCard(steps: [
          'ratio = d2/d1 = ${precs.formatSI(d2, UnitCategory.length, system)} / ${precs.formatSI(d1, UnitCategory.length, system)} = ${precs.formatValue(result.ratio)}',
          'L = 2C + (π/2)(d1+d2) + (d2−d1)²/(4C)',
          '= ${precs.formatSI(result.beltLength, UnitCategory.length, system)}',
          'Wrap: θ = π ∓ 2·asin((d2−d1)/(2C))',
          if (result.drivingTorqueNm != null)
            'T1 = P/ω1, Ft = T1/(d1/2) — required driving force, not a belt-capacity rating.',
        ]),
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

  List<String> _shareLines(UnitSystem system, NumberPrecisionHelper precs) => [
        'ratio = ${precs.formatValue(result.ratio)}',
        'n2 = ${precs.formatSI(result.outputSpeedRpm, UnitCategory.angularVelocity, system)}',
        'L = ${precs.formatSI(result.beltLength, UnitCategory.length, system)}',
        'θ_small = ${precs.formatValue(result.smallWrapAngleDeg)}°, θ_large = ${precs.formatValue(result.largeWrapAngleDeg)}°',
        if (result.drivingTorqueNm != null)
          'T1 = ${precs.formatSI(result.drivingTorqueNm!, UnitCategory.torque, system)}',
        if (result.beltPullN != null)
          'Ft = ${precs.formatSI(result.beltPullN!, UnitCategory.force, system)}',
      ];
}
