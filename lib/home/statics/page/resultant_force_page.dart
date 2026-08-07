import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class ResultantForcePage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const ResultantForcePage(
      {Key? key, required this.toolId, required this.title, this.initialInputs})
      : super(key: key);

  @override
  State<ResultantForcePage> createState() => _ResultantForcePageState();
}

class _ForceEntry {
  double? fx;
  double? fy;
}

class _ResultantForcePageState extends State<ResultantForcePage> {
  final List<_ForceEntry> _forces = [_ForceEntry(), _ForceEntry()];

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      final inputs = widget.initialInputs!;
      int maxI = 0;
      inputs.forEach((key, value) {
        if (key.startsWith('F')) {
          final match = RegExp(r'F(\d+)').firstMatch(key);
          if (match != null) {
            maxI = max(maxI, int.parse(match.group(1)!));
          }
        }
      });

      if (maxI > 0) {
        _forces.clear();
        for (int i = 0; i < maxI; i++) {
          final entry = _ForceEntry();
          final fxKey = 'F${i + 1} Fx';
          final fyKey = 'F${i + 1} Fy';
          if (inputs.containsKey(fxKey)) {
            entry.fx = double.tryParse(inputs[fxKey]!);
          }
          if (inputs.containsKey(fyKey)) {
            entry.fy = double.tryParse(inputs[fyKey]!);
          }
          _forces.add(entry);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.of(context).Forces,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).Enter_Fx_Fy_Components,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_forces.length, _buildForceRow),
                  TextButton.icon(
                    onPressed: () => setState(() => _forces.add(_ForceEntry())),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: Text(S.of(context).Add_Force),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _calculate,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                Text(S.of(context).Calculate, style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildForceRow(int i) {
    final entry = _forces[i];
    return Padding(
      key: ObjectKey(entry),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
              width: 28,
              child: Text('F${i + 1}',
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: UnitField(
              label: 'Fx',
              category: UnitCategory.force,
              initialSI: entry.fx,
              onChangedSI: (v) => entry.fx = v,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: UnitField(
              label: 'Fy',
              category: UnitCategory.force,
              initialSI: entry.fy,
              onChangedSI: (v) => entry.fy = v,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded,
                color: Colors.red),
            onPressed: _forces.length > 1
                ? () {
                    setState(() => _forces.removeAt(i));
                  }
                : null,
          ),
        ],
      ),
    );
  }

  void _calculate() {
    double sumFx = 0, sumFy = 0;
    bool hasValue = false;
    final Map<String, String> inputs = {};
    for (int i = 0; i < _forces.length; i++) {
      final f = _forces[i];
      final fx = f.fx ?? 0;
      final fy = f.fy ?? 0;
      if (f.fx != null || f.fy != null) {
        hasValue = true;
        inputs['F${i + 1} Fx'] = fx.toString();
        inputs['F${i + 1} Fy'] = fy.toString();
      }
      sumFx += fx;
      sumFy += fy;
    }
    if (!hasValue) return;

    context.read<ToolHistory>().record(widget.toolId, inputs: inputs);

    final R = sqrt(sumFx * sumFx + sumFy * sumFy);
    final theta = atan2(sumFy, sumFx) * 180 / pi;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ResultPage(
          toolId: widget.toolId,
          title: widget.title,
          forces: _forces
              .map((f) => (
                    fx: f.fx ?? 0,
                    fy: f.fy ?? 0,
                  ))
              .toList(),
          sumFx: sumFx,
          sumFy: sumFy,
          R: R,
          theta: theta,
        ),
      ),
    );
  }
}

class _ResultPage extends StatelessWidget {
  final int toolId;
  final String title;
  final List<({double fx, double fy})> forces;
  final double sumFx, sumFy, R, theta;

  const _ResultPage({
    required this.toolId,
    required this.title,
    required this.forces,
    required this.sumFx,
    required this.sumFy,
    required this.R,
    required this.theta,
  });

  String _fv(double valueSI, UnitSystem system) =>
      '${formatFixed4(fromSI(valueSI, UnitCategory.force, system))} ${unitLabel(UnitCategory.force, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final tool = ToolLibrary.shared.item(toolId, context);
    final fxTerms = forces
        .map((f) => formatFixed4(fromSI(f.fx, UnitCategory.force, system)))
        .join(' + ');
    final fyTerms = forces
        .map((f) => formatFixed4(fromSI(f.fy, UnitCategory.force, system)))
        .join(' + ');

    final steps = [
      '\u03a3Fx = $fxTerms = ${_fv(sumFx, system)}',
      '\u03a3Fy = $fyTerms = ${_fv(sumFy, system)}',
      'R = \u221a(\u03a3Fx\u00b2 + \u03a3Fy\u00b2)',
      '  = \u221a(${_fv(sumFx, system)}\u00b2 + ${_fv(sumFy, system)}\u00b2)',
      '  = ${_fv(R, system)}',
      '\u03b8 = atan2(\u03a3Fy, \u03a3Fx)',
      '  = atan2(${_fv(sumFy, system)}, ${_fv(sumFx, system)})',
      '  = ${formatFixed4(theta)}\u00b0',
    ];

    return ResultScaffold(
      title: title,
      toolName: title,
      formulaSteps: steps,
      leading: [ToolResultHeader(tool: tool)],
      results: [
        ResultSection(
          title: title,
          values: [
            ResultValue(
              label: '\u03a3Fx',
              valueSI: sumFx,
              category: UnitCategory.force,
            ),
            ResultValue(
              label: '\u03a3Fy',
              valueSI: sumFy,
              category: UnitCategory.force,
            ),
            ResultValue(
              label: 'R',
              valueSI: R,
              category: UnitCategory.force,
            ),
            ResultValue(
              label: '\u03b8',
              valueSI: theta,
              category: UnitCategory.angle,
            ),
          ],
        ),
      ],
      children: [
        CalculationCard(steps: steps),
      ],
    );
  }
}
