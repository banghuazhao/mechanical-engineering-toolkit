import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
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
    return ResultScaffold(
      toolName: title,
      shareLines: () => _shareLines(system),
      children: [
        ToolResultHeader(tool: tool),
        AppSectionCard(
          title: title,
          child: Column(children: [
            AppCopyableValue(
              label: 'Factor of safety, n',
              value: formatFixed(safetyFactor),
            ),
            AppCopyableValue(
              label: 'Assessment',
              value: safetyFactor >= 1
                  ? 'Safe against fatigue failure (n ≥ 1)'
                  : 'Unsafe — predicted fatigue failure (n < 1)',
            ),
          ]),
        ),
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
        CalculationCard(steps: [
          '1/n = σa/Se + σm/Su',
          '= ${formatFixedSI(sigmaA, UnitCategory.stress, system)} / ${formatFixedSI(se, UnitCategory.stress, system)} + ${formatFixedSI(sigmaM, UnitCategory.stress, system)} / ${formatFixedSI(su, UnitCategory.stress, system)}',
          'n = ${formatFixed(safetyFactor)}',
        ]),
      ],
    );
  }

  List<String> _shareLines(UnitSystem system) => [
        'n = ${formatFixed(safetyFactor)}',
        'σa = ${formatFixedSI(sigmaA, UnitCategory.stress, system)}',
        'σm = ${formatFixedSI(sigmaM, UnitCategory.stress, system)}',
        'Su = ${formatFixedSI(su, UnitCategory.stress, system)}',
        'Se = ${formatFixedSI(se, UnitCategory.stress, system)}',
      ];
}
