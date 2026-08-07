import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class GeneralStressResultPage extends StatelessWidget {
  GeneralStressResultPage({
    super.key,
    required this.toolId,
    required this.sigma,
    required this.f,
    required this.a,
  });

  final int toolId;
  final double sigma;
  final double f;
  final double a;
  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final tool = ToolLibrary.shared.item(toolId, context);
    final formulaSteps = [
      'σ = F / A',
      '= ${formatFixedSI(f, UnitCategory.force, system)} / ${formatFixedSI(a, UnitCategory.area, system)}',
      '= ${formatFixedSI(sigma, UnitCategory.stress, system)}',
    ];

    return ResultScaffold(
      toolName: 'General Stress',
      formulaSteps: formulaSteps,
      leading: [ToolResultHeader(tool: tool)],
      results: [
        ResultSection(
          title: 'General Stress',
          values: [
            ResultValue(
              label: 'Stress, σ',
              valueSI: sigma,
              category: UnitCategory.stress,
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: formulaSteps),
        ParameterSweepCard(
          variableLabel: 'Force, F',
          variableCategory: UnitCategory.force,
          baseValueSI: f,
          outputLabel: 'σ',
          outputCategory: UnitCategory.stress,
          compute: (variedF) => variedF / a,
        ),
      ],
    );
  }

}
