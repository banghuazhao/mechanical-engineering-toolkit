import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
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
  final TextEditingController fx = TextEditingController();
  final TextEditingController fy = TextEditingController();
  void dispose() {
    fx.dispose();
    fy.dispose();
  }
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
        for (var f in _forces) f.dispose();
        _forces.clear();
        for (int i = 0; i < maxI; i++) {
          final entry = _ForceEntry();
          final fxKey = 'F${i + 1} Fx';
          final fyKey = 'F${i + 1} Fy';
          if (inputs.containsKey(fxKey)) entry.fx.text = inputs[fxKey]!;
          if (inputs.containsKey(fyKey)) entry.fy.text = inputs[fyKey]!;
          _forces.add(entry);
        }
      }
    }
  }

  @override
  void dispose() {
    for (final f in _forces) f.dispose();
    super.dispose();
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
                  Text('Forces', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Enter Fx and Fy components for each force (N)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(_forces.length, _buildForceRow),
                  TextButton.icon(
                    onPressed: () => setState(() => _forces.add(_ForceEntry())),
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('Add Force'),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Calculate', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildForceRow(int i) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 28, child: Text('F${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
            child: TextField(
              controller: _forces[i].fx,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(labelText: 'Fx', suffixText: 'N'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _forces[i].fy,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              decoration: const InputDecoration(labelText: 'Fy', suffixText: 'N'),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
            onPressed: _forces.length > 1 ? () {
              _forces[i].dispose();
              setState(() => _forces.removeAt(i));
            } : null,
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
      final fx = double.tryParse(f.fx.text) ?? 0;
      final fy = double.tryParse(f.fy.text) ?? 0;
      if (f.fx.text.isNotEmpty || f.fy.text.isNotEmpty) {
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
          title: widget.title,
          forces: _forces.map((f) => (
            fx: double.tryParse(f.fx.text) ?? 0,
            fy: double.tryParse(f.fy.text) ?? 0,
          )).toList(),
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
  final String title;
  final List<({double fx, double fy})> forces;
  final double sumFx, sumFy, R, theta;

  const _ResultPage({
    required this.title,
    required this.forces,
    required this.sumFx,
    required this.sumFy,
    required this.R,
    required this.theta,
  });

  String _fmt(double v) => v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');

  @override
  Widget build(BuildContext context) {
    final fxTerms = forces.map((f) => _fmt(f.fx)).join(' + ');
    final fyTerms = forces.map((f) => _fmt(f.fy)).join(' + ');

    final steps = [
      'ΣFx = $fxTerms = ${_fmt(sumFx)} N',
      'ΣFy = $fyTerms = ${_fmt(sumFy)} N',
      'R = √(ΣFx² + ΣFy²)',
      '  = √(${_fmt(sumFx)}² + ${_fmt(sumFy)}²)',
      '  = ${_fmt(R)} N',
      'θ = atan2(ΣFy, ΣFx)',
      '  = atan2(${_fmt(sumFy)}, ${_fmt(sumFx)})',
      '  = ${_fmt(theta)}°',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => shareResult(title, [
              'ΣFx = ${_fmt(sumFx)} N',
              'ΣFy = ${_fmt(sumFy)} N',
              'R = ${_fmt(R)} N',
              'θ = ${_fmt(theta)}°',
            ]),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [CalculationCard(steps: steps)],
      ),
    );
  }
}
