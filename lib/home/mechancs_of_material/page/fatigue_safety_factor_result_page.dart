import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/goodman_diagram_card.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class FatigueSafetyFactorResultPage extends StatelessWidget {
  FatigueSafetyFactorResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.sigmaA,
    required this.sigmaM,
    required this.su,
    required this.se,
    required this.safetyFactor,
  });

  final int toolId;
  final String title;
  final double sigmaA;
  final double sigmaM;
  final double su;
  final double se;
  final double safetyFactor;
  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final tool = ToolLibrary.shared.item(toolId, context);
    final scheme = Theme.of(context).colorScheme;
    final formulaSteps = [
      '1/n = σa/Se + σm/Su',
      '= ${formatFixedSI(sigmaA, UnitCategory.stress, system)} / ${formatFixedSI(se, UnitCategory.stress, system)} + ${formatFixedSI(sigmaM, UnitCategory.stress, system)} / ${formatFixedSI(su, UnitCategory.stress, system)}',
      'n = ${formatFixed(safetyFactor)}',
    ];

    return ResultScaffold(
      toolName: title,
      formulaSteps: formulaSteps,
      leading: [ToolResultHeader(tool: tool)],
      results: [
        ResultSection(
          title: title,
          values: [
            ResultValue(
              label: 'Factor of safety, n',
              valueSI: safetyFactor,
            ),
            ResultValue(
              label: 'Assessment',
              value: safetyFactor >= 1
                  ? 'Safe against fatigue failure (n ≥ 1)'
                  : 'Unsafe — predicted fatigue failure (n < 1)',
            ),
            ResultValue(
              label: 'Alternating stress, σa',
              valueSI: sigmaA,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: 'Mean stress, σm',
              valueSI: sigmaM,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: 'Ultimate strength, Su',
              valueSI: su,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: 'Endurance limit, Se',
              valueSI: se,
              category: UnitCategory.stress,
            ),
          ],
        ),
      ],
      children: [
        if (safetyFactor < 1)
          Card(
            color: scheme.errorContainer,
            child: Padding(
              padding: EdgeInsets.all(context.tokens.space3),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: scheme.onErrorContainer),
                  SizedBox(width: context.tokens.space2),
                  Expanded(
                    child: Text(
                      'This stress state falls outside the Goodman line — the part is predicted to fail by fatigue.',
                      style: TextStyle(color: scheme.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
        CalculationCard(steps: formulaSteps),
        GoodmanDiagramCard(
          alternatingStress: sigmaA,
          meanStress: sigmaM,
          enduranceLimit: se,
          ultimateStrength: su,
          safetyFactor: safetyFactor,
        ),
      ],
    );
  }
}
