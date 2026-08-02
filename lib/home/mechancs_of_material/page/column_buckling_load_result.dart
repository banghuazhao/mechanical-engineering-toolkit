import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class ColumnBucklingLoadResultPage extends StatelessWidget {
  ColumnBucklingLoadResultPage({
    super.key,
    required this.toolId,
    required this.pcr,
    required this.e,
    required this.i,
    required this.l,
    required this.c,
    required this.endCondition,
  });

  final int toolId;
  final double pcr;
  final double e;
  final double i;
  final double l;
  final double c;
  final String endCondition;

  String _fmt(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_fmt(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final tool = ToolLibrary.shared.item(toolId, context);
    final cStr = c == 1.0 ? 'π²' : '${precs.formatValue(c)} × π²';

    return ResultScaffold(
      toolName: 'Column Buckling Load',
      shareLines: () => _shareLines(system, cStr),
      children: [
        ToolResultHeader(tool: tool),
        AppSectionCard(
          title: 'Buckling Load of Column',
          child: Column(children: [
            AppCopyableValue(
              label: 'Buckling load, Pcr',
              valueSI: pcr,
              category: UnitCategory.force,
            ),
          ]),
        ),
        AppSectionCard(
          title: 'Formula',
          child: Text(
            'Pcr = C·π²·E·I / L²  ($endCondition)\n'
            '= $cStr × ${_fv(e, UnitCategory.modulus, system)} × ${_fv(i, UnitCategory.momentOfInertia, system)} / ${_fv(l, UnitCategory.length, system)}²\n'
            '= ${_fv(pcr, UnitCategory.force, system)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        ParameterSweepCard(
          variableLabel: 'Length, L',
          variableCategory: UnitCategory.length,
          baseValueSI: l,
          outputLabel: 'Pcr',
          outputCategory: UnitCategory.force,
          compute: (variedL) =>
              c * pi * pi * (e * 1000) * i / (variedL * variedL),
        ),
      ],
    );
  }

  List<String> _shareLines(UnitSystem system, String cStr) => [
        'Pcr = ${_fv(pcr, UnitCategory.force, system)}',
        '',
        'Calculation:',
        'Pcr = C·π²·E·I / L²  ($endCondition)',
        '= $cStr × ${_fv(e, UnitCategory.modulus, system)} × ${_fv(i, UnitCategory.momentOfInertia, system)} / ${_fv(l, UnitCategory.length, system)}²',
        '= ${_fv(pcr, UnitCategory.force, system)}',
      ];
}
