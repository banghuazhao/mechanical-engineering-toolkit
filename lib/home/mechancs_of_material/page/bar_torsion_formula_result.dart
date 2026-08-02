import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BarTorsionFormulaResultPage extends StatelessWidget {
  BarTorsionFormulaResultPage({
    super.key,
    required this.toolId,
    required this.tauMax,
    required this.t,
    required this.r,
    required this.ip,
  });

  final int toolId;
  final double tauMax;
  final double t;
  final double r;
  final double ip;

  String _fmt(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_fmt(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final tool = ToolLibrary.shared.item(toolId, context);
    return ResultScaffold(
      toolName: 'Torsion Formula',
      shareLines: () => _shareLines(system),
      children: [
        ToolResultHeader(tool: tool),
        AppSectionCard(
          title: 'Torsion Formula of Bar',
          child: Column(children: [
            AppCopyableValue(
              label: 'Maximum shear stress, τ_max',
              valueSI: tauMax,
              category: UnitCategory.stress,
            ),
          ]),
        ),
        AppSectionCard(
          title: 'Formula',
          child: Text(
            'τ = T·r / Ip\n'
            '= ${_fv(t, UnitCategory.momentSection, system)} × ${_fv(r, UnitCategory.length, system)} / ${_fv(ip, UnitCategory.momentOfInertia, system)}\n'
            '= ${_fv(tauMax, UnitCategory.stress, system)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        ParameterSweepCard(
          variableLabel: 'Radius, r',
          variableCategory: UnitCategory.length,
          baseValueSI: r,
          outputLabel: 'τ_max',
          outputCategory: UnitCategory.stress,
          compute: (variedR) => t * variedR / ip,
        ),
      ],
    );
  }

  List<String> _shareLines(UnitSystem system) => [
        'τ_max = ${_fv(tauMax, UnitCategory.stress, system)}',
        '',
        'Calculation:',
        'τ = T·r / Ip',
        '= ${_fv(t, UnitCategory.momentSection, system)} × ${_fv(r, UnitCategory.length, system)} / ${_fv(ip, UnitCategory.momentOfInertia, system)}',
        '= ${_fv(tauMax, UnitCategory.stress, system)}',
      ];
}
