import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/bearing_life_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BearingLifeResultPage extends StatelessWidget {
  const BearingLifeResultPage({
    super.key,
    required this.result,
    required this.c,
    required this.p,
    required this.rpm,
    required this.type,
  });

  final BearingLifeResult result;
  final double c;
  final double p;
  final double rpm;
  final BearingType type;

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final exponent = type.exponent;
    final formulaSteps = _steps(context, system, precs);

    return ResultScaffold(
      toolName: S.of(context).Bearing_L10_Life,
      formulaSteps: formulaSteps,
      results: [
        ResultSection(
          title: S.of(context).Bearing_L10_Life,
          values: [
            ResultValue(
              label: S.of(context).L10_Million_Revolutions,
              valueSI: result.l10Million,
            ),
            ResultValue(
              label: S.of(context).L10_Hours,
              valueSI: result.l10Hours,
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: formulaSteps),
        ParameterSweepCard(
          variableLabel: S.of(context).Equivalent_Load_P,
          variableCategory: UnitCategory.forceStructural,
          baseValueSI: p,
          outputLabel: S.of(context).L10_Hours,
          outputCategory: null,
          compute: (variedP) {
            final l10 = math.pow(c / variedP, exponent).toDouble();
            return l10 * 1e6 / (60 * rpm);
          },
        ),
      ],
    );
  }

  List<String> _steps(BuildContext context, UnitSystem system,
          NumberPrecisionHelper precs) =>
      [
        'L10 = (C/P)^p, ${type.label(context)}',
        '= (${precs.formatSI(c, UnitCategory.forceStructural, system)} / ${precs.formatSI(p, UnitCategory.forceStructural, system)})^${precs.formatValue(type.exponent)}',
        '= ${precs.formatValue(result.l10Million)} million rev',
        'L10h = L10 × 1e6 / (60 × n) = ${precs.formatValue(result.l10Hours)} h',
      ];
}
