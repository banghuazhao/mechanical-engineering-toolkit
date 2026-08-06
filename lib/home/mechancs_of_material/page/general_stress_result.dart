import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';

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
    return ResultScaffold(
      toolName: 'General Stress',
      shareLines: () => _shareLines(system),
      children: [
        ToolResultHeader(tool: tool),
        AppSectionCard(
          title: 'General Stress',
          child: Column(children: [
            AppCopyableValue(
              label: 'Stress, σ',
              valueSI: sigma,
              category: UnitCategory.stress,
            ),
          ]),
        ),
        AppSectionCard(
          title: S.of(context).Formula,
          child: Text(
            'σ = F / A\n'
            '= ${formatFixedSI(f, UnitCategory.force, system)} / ${formatFixedSI(a, UnitCategory.area, system)}\n'
            '= ${formatFixedSI(sigma, UnitCategory.stress, system)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
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

  List<String> _shareLines(UnitSystem system) => [
        'σ = ${formatFixedSI(sigma, UnitCategory.stress, system)}',
        '',
        'Calculation:',
        'σ = F / A',
        '= ${formatFixedSI(f, UnitCategory.force, system)} / ${formatFixedSI(a, UnitCategory.area, system)}',
        '= ${formatFixedSI(sigma, UnitCategory.stress, system)}',
      ];
}
