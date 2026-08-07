import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/shaft_fatigue_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class ShaftFatigueResultPage extends StatelessWidget {
  const ShaftFatigueResultPage({
    super.key,
    required this.result,
    required this.ma,
    required this.mm,
    required this.ta,
    required this.tm,
    required this.kf,
    required this.kfs,
    required this.se,
    required this.sut,
    required this.n,
  });

  final ShaftFatigueResult result;
  final double ma, mm, ta, tm, kf, kfs, se, sut, n;

  @override
  Widget build(BuildContext context) {
    final precs = context.watch<NumberPrecisionHelper>();

    final formulaSteps = [
      'd = { (16n/π)·[ √(4(KfMa)²+3(KfsTa)²)/Se + √(4(KfMm)²+3(KfsTm)²)/Sut ] }^(1/3)',
      'n=${precs.formatValue(n)}, Kf=${precs.formatValue(kf)}, Kfs=${precs.formatValue(kfs)}',
      '= ${precs.formatValue(result.diameterMm)} mm',
    ];

    return ResultScaffold(
      toolName: 'Shaft Fatigue Design',
      formulaSteps: formulaSteps,
      results: [
        ResultSection(
          title: S.of(context).Shaft_Fatigue_Design,
          values: [
            ResultValue(
              label: S.of(context).Required_Diameter_D,
              valueSI: result.diameterMm,
              category: UnitCategory.length,
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: formulaSteps),
        ParameterSweepCard(
          variableLabel: S.of(context).Target_Safety_Factor_N,
          variableCategory: null,
          baseValueSI: n,
          outputLabel: S.of(context).Diameter_D,
          outputCategory: UnitCategory.length,
          minSI: n * 0.3,
          maxSI: n * 2,
          compute: (variedN) {
            final r = ShaftFatigueCalculator.calculate(ShaftFatigueInput(
              alternatingMoment: ma,
              meanMoment: mm,
              alternatingTorque: ta,
              meanTorque: tm,
              kf: kf,
              kfs: kfs,
              enduranceLimit: se,
              ultimateStrength: sut,
              safetyFactor: variedN,
            ));
            return r.diameterMm;
          },
        ),
      ],
    );
  }
}
