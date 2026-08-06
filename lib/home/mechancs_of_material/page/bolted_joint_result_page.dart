import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
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
    return ResultScaffold(
      toolName: title,
      shareLines: () => _shareLines(system),
      children: [
        ToolResultHeader(tool: tool),
        AppSectionCard(
          title: title,
          child: Column(children: [
            AppCopyableValue(
              label: 'Shear stress, τ',
              valueSI: tauShear,
              category: UnitCategory.stress,
            ),
            AppCopyableValue(
              label: 'Bearing stress, σb',
              valueSI: sigmaBearing,
              category: UnitCategory.stress,
            ),
            AppCopyableValue(
              label: 'Tear-out stress, σt',
              valueSI: sigmaTearOut,
              category: UnitCategory.stress,
            ),
          ]),
        ),
        if (allowShear != null || allowBearing != null) ...[
          AppSectionCard(
            title: S.of(context).Factor_of_Safety,
            child: Column(children: [
              if (allowShear != null)
                AppCopyableValue(
                  label: 'Shear FoS',
                  value: _f(allowShear! / tauShear),
                ),
              if (allowBearing != null)
                AppCopyableValue(
                  label: 'Bearing FoS',
                  value: _f(allowBearing! / sigmaBearing),
                ),
            ]),
          ),
        ],
        AppSectionCard(
          title: S.of(context).Formulas,
          child: Text(
            'τ = P / (n·planes·π/4·d²)\n'
            'σb = P / (n·d·t)\n'
            'σt = P / (n·2·(e−d/2)·t)\n\n'
            'Governing stress: ${_fv(governingStress, system)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  List<String> _shareLines(UnitSystem system) => [
        'τ = ${_fv(tauShear, system)}',
        'σb = ${_fv(sigmaBearing, system)}',
        'σt = ${_fv(sigmaTearOut, system)}',
      ];
}
