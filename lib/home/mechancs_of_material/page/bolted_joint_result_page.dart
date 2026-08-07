import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';

class BoltedJointResultPage extends StatelessWidget {
  BoltedJointResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.tauShear,
    required this.sigmaBearing,
    required this.sigmaTearOut,
    this.allowShear,
    this.allowBearing,
  });

  final int toolId;
  final String title;
  final double tauShear;
  final double sigmaBearing;
  final double sigmaTearOut;
  final double? allowShear;
  final double? allowBearing;
  String _f(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitSystem system) =>
      '${_f(fromSI(valueSI, UnitCategory.stress, system))} ${unitLabel(UnitCategory.stress, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final tool = ToolLibrary.shared.item(toolId, context);
    final governingStress =
        [tauShear, sigmaBearing, sigmaTearOut].reduce((a, b) => a > b ? a : b);
    final formulaSteps = [
      'τ = P / (n·planes·π/4·d²)',
      'σb = P / (n·d·t)',
      'σt = P / (n·2·(e−d/2)·t)',
      '',
      'Governing stress: ${_fv(governingStress, system)}',
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
              label: 'Shear stress, τ',
              valueSI: tauShear,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: 'Bearing stress, σb',
              valueSI: sigmaBearing,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: 'Tear-out stress, σt',
              valueSI: sigmaTearOut,
              category: UnitCategory.stress,
            ),
          ],
        ),
        if (allowShear != null || allowBearing != null)
          ResultSection(
            title: S.of(context).Factor_of_Safety,
            values: [
              if (allowShear != null)
                ResultValue(
                  label: 'Shear FoS',
                  valueSI: allowShear! / tauShear,
                ),
              if (allowBearing != null)
                ResultValue(
                  label: 'Bearing FoS',
                  valueSI: allowBearing! / sigmaBearing,
                ),
            ],
          ),
      ],
      children: [
        FormulaCard(steps: formulaSteps),
      ],
    );
  }
}
