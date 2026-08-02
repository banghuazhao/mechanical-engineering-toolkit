import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// Result of the flexure formula σ = -M·y/I. [y] is optional — when omitted
/// the result is shown as a coefficient times y rather than a single value.
class BeamFlexureFormulaResultPage extends StatelessWidget {
  BeamFlexureFormulaResultPage({
    super.key,
    required this.toolId,
    required this.coefficient,
    required this.y,
    required this.m,
    required this.i,
  });

  final int toolId;

  /// -M/I, so that stress at a given y is coefficient * y.
  final double coefficient;
  final double? y;
  final double m;
  final double i;

  String _fmt(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_fmt(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final tool = ToolLibrary.shared.item(toolId, context);
    final sigmaAtY = y != null ? coefficient * y! : null;

    return ResultScaffold(
      toolName: 'Beam Flexure Formula',
      shareLines: () => _shareLines(system, precs),
      children: [
        ToolResultHeader(tool: tool),
        AppSectionCard(
          title: 'Flexure Formula of Beam',
          child: Column(children: [
            if (sigmaAtY != null)
              AppCopyableValue(
                label: 'Stress, σ',
                valueSI: sigmaAtY,
                category: UnitCategory.stress,
              )
            else
              AppCopyableValue(
                label: 'Stress, σ(y)',
                value: '${precs.formatValue(coefficient)} × y',
              ),
          ]),
        ),
        AppSectionCard(
          title: 'Formula',
          child: Text(
            sigmaAtY != null
                ? 'σ = M·y / I\n'
                    '= ${_fv(m, UnitCategory.momentSection, system)} × ${_fv(y!, UnitCategory.length, system)} / ${_fv(i, UnitCategory.momentOfInertia, system)}\n'
                    '= ${_fv(sigmaAtY, UnitCategory.stress, system)}'
                : 'σ(y) = M·y / I\n'
                    '= ${_fv(m, UnitCategory.momentSection, system)} × y / ${_fv(i, UnitCategory.momentOfInertia, system)}\n'
                    '= ${precs.formatValue(coefficient)} × y',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        if (sigmaAtY != null) ...[
          ParameterSweepCard(
            variableLabel: 'Distance, y',
            variableCategory: UnitCategory.length,
            baseValueSI: y!,
            outputLabel: 'σ',
            outputCategory: UnitCategory.stress,
            compute: (variedY) => coefficient * variedY,
          ),
        ],
      ],
    );
  }

  List<String> _shareLines(UnitSystem system, NumberPrecisionHelper precs) {
    final sigmaAtY = y != null ? coefficient * y! : null;
    return sigmaAtY != null
        ? [
            'σ = ${_fv(sigmaAtY, UnitCategory.stress, system)}',
            '',
            'Calculation:',
            'σ = M·y / I',
            '= ${_fv(m, UnitCategory.momentSection, system)} × ${_fv(y!, UnitCategory.length, system)} / ${_fv(i, UnitCategory.momentOfInertia, system)}',
            '= ${_fv(sigmaAtY, UnitCategory.stress, system)}',
          ]
        : [
            'σ(y) = ${precs.formatValue(coefficient)} × y',
            '',
            'Calculation:',
            'σ(y) = M·y / I = ${_fv(m, UnitCategory.momentSection, system)} × y / ${_fv(i, UnitCategory.momentOfInertia, system)}',
            '= ${precs.formatValue(coefficient)} × y',
          ];
  }
}
