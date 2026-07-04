import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:provider/provider.dart';

enum _ShapeType { rectangle, circle, triangle, semicircle }

class _Shape {
  _ShapeType type = _ShapeType.rectangle;
  bool subtract = false;
  final TextEditingController dim1 = TextEditingController(); // width or radius
  final TextEditingController dim2 = TextEditingController(); // height
  final TextEditingController xRef = TextEditingController();
  final TextEditingController yRef = TextEditingController();
  void dispose() { dim1.dispose(); dim2.dispose(); xRef.dispose(); yRef.dispose(); }
}

class CentroidPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const CentroidPage(
      {Key? key,
      required this.title,
      required this.toolId,
      this.initialInputs})
      : super(key: key);

  @override
  State<CentroidPage> createState() => _CentroidPageState();
}

class _CentroidPageState extends State<CentroidPage> {
  final List<_Shape> _shapes = [_Shape(), _Shape()];

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      final inputs = widget.initialInputs!;
      int maxI = 0;
      inputs.forEach((key, value) {
        if (key.startsWith('Shape ')) {
          final match = RegExp(r'Shape (\d+)').firstMatch(key);
          if (match != null) {
            maxI = max(maxI, int.parse(match.group(1)!));
          }
        }
      });

      if (maxI > 0) {
        for (var s in _shapes) s.dispose();
        _shapes.clear();
        for (int i = 0; i < maxI; i++) {
          final s = _Shape();
          final prefix = 'Shape ${i + 1}';
          if (inputs.containsKey('$prefix Type')) {
            final typeStr = inputs['$prefix Type']!;
            s.type = _ShapeType.values.firstWhere(
                (t) => _shapeLabel(t) == typeStr,
                orElse: () => _ShapeType.rectangle);
          }
          s.dim1.text = inputs['$prefix Dim1'] ?? '';
          s.dim2.text = inputs['$prefix Dim2'] ?? '';
          s.xRef.text = inputs['$prefix xRef'] ?? '';
          s.yRef.text = inputs['$prefix yRef'] ?? '';
          s.subtract = inputs['$prefix Subtract'] == 'true';
          _shapes.add(s);
        }
      }
    }
  }

  @override
  void dispose() {
    for (final s in _shapes) s.dispose();
    super.dispose();
  }

  String _shapeLabel(_ShapeType t) {
    switch (t) {
      case _ShapeType.rectangle: return 'Rectangle';
      case _ShapeType.circle: return 'Circle';
      case _ShapeType.triangle: return 'Right Triangle';
      case _ShapeType.semicircle: return 'Semicircle (up)';
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
              padding: const EdgeInsets.all(12),
              child: Text(
                'Rectangles/Triangles: enter bottom-left corner (x, y).\n'
                'Circles/Semicircles: enter center (x, y). Mark shapes as "subtract" for holes.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(_shapes.length, _buildShapeCard),
          TextButton.icon(
            onPressed: () => setState(() => _shapes.add(_Shape())),
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Add Shape'),
          ),
          const SizedBox(height: 8),
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

  Widget _buildShapeCard(int i) {
    final s = _shapes[i];
    final showDim2 = s.type == _ShapeType.rectangle || s.type == _ShapeType.triangle;
    final dim1Label = (s.type == _ShapeType.circle || s.type == _ShapeType.semicircle) ? 'Radius r' : 'Width b';
    final xLabel = (s.type == _ShapeType.circle || s.type == _ShapeType.semicircle) ? 'x center' : 'x (bottom-left)';
    final yLabel = (s.type == _ShapeType.circle || s.type == _ShapeType.semicircle) ? 'y center' : 'y (bottom-left)';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Shape ${i + 1}', style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                const Text('Subtract'),
                Switch(
                  value: s.subtract,
                  onChanged: (v) => setState(() => s.subtract = v),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
                  onPressed: _shapes.length > 1 ? () {
                    s.dispose();
                    setState(() => _shapes.removeAt(i));
                  } : null,
                ),
              ],
            ),
            DropdownButtonFormField<_ShapeType>(
              value: s.type,
              decoration: const InputDecoration(labelText: 'Shape type'),
              items: _ShapeType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(_shapeLabel(t))))
                  .toList(),
              onChanged: (v) => setState(() => s.type = v!),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: s.dim1,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: dim1Label, suffixText: 'm'),
                  ),
                ),
                if (showDim2) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: s.dim2,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Height h', suffixText: 'm'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: s.xRef,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(labelText: xLabel, suffixText: 'm'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: s.yRef,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(labelText: yLabel, suffixText: 'm'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _calculate() {
    double totalA = 0, sumAx = 0, sumAy = 0;
    final steps = <String>[];
    final Map<String, String> inputs = {};

    for (int i = 0; i < _shapes.length; i++) {
      final s = _shapes[i];
      final d1 = double.tryParse(s.dim1.text);
      if (d1 == null || d1 <= 0) { _showError('Enter dimension for shape ${i + 1}'); return; }
      final xRef = double.tryParse(s.xRef.text) ?? 0;
      final yRef = double.tryParse(s.yRef.text) ?? 0;

      final prefix = 'Shape ${i + 1}';
      inputs['$prefix Type'] = _shapeLabel(s.type);
      inputs['$prefix Dim1'] = d1.toString();
      inputs['$prefix xRef'] = xRef.toString();
      inputs['$prefix yRef'] = yRef.toString();
      if (s.type == _ShapeType.rectangle || s.type == _ShapeType.triangle) {
        inputs['$prefix Dim2'] = s.dim2.text;
      }
      inputs['$prefix Subtract'] = s.subtract.toString();

      double A, cx, cy;
      switch (s.type) {
        case _ShapeType.rectangle:
          final h = double.tryParse(s.dim2.text);
          if (h == null || h <= 0) { _showError('Enter height for shape ${i + 1}'); return; }
          A = d1 * h;
          cx = xRef + d1 / 2;
          cy = yRef + h / 2;
          break;
        case _ShapeType.circle:
          A = pi * d1 * d1;
          cx = xRef;
          cy = yRef;
          break;
        case _ShapeType.triangle:
          final h = double.tryParse(s.dim2.text);
          if (h == null || h <= 0) { _showError('Enter height for shape ${i + 1}'); return; }
          A = 0.5 * d1 * h;
          cx = xRef + d1 / 3;
          cy = yRef + h / 3;
          break;
        case _ShapeType.semicircle:
          A = 0.5 * pi * d1 * d1;
          cx = xRef;
          cy = yRef + 4 * d1 / (3 * pi);
          break;
      }

      final sign = s.subtract ? -1.0 : 1.0;
      totalA += sign * A;
      sumAx += sign * A * cx;
      sumAy += sign * A * cy;

      final tag = s.subtract ? '(subtract)' : '';
      steps.add('Shape ${i + 1} $tag  A=${_fmt(A)} m²  cx=${_fmt(cx)}  cy=${_fmt(cy)}');
    }

    if (totalA == 0) { _showError('Total area is zero'); return; }
    context.read<ToolHistory>().record(widget.toolId, inputs: inputs);
    final xBar = sumAx / totalA;
    final yBar = sumAy / totalA;

    steps.addAll([
      'Total A = ${_fmt(totalA)} m²',
      'x̄ = ΣAᵢxᵢ / A = ${_fmt(sumAx)} / ${_fmt(totalA)} = ${_fmt(xBar)} m',
      'ȳ = ΣAᵢyᵢ / A = ${_fmt(sumAy)} / ${_fmt(totalA)} = ${_fmt(yBar)} m',
    ]);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ResultPage(
          title: widget.title,
          totalA: totalA, xBar: xBar, yBar: yBar,
          steps: steps,
        ),
      ),
    );
  }

  void _showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  String _fmt(double v) =>
      v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
}

class _ResultPage extends StatelessWidget {
  final String title;
  final double totalA, xBar, yBar;
  final List<String> steps;

  const _ResultPage({
    required this.title,
    required this.totalA,
    required this.xBar,
    required this.yBar,
    required this.steps,
  });

  String _fmt(double v) =>
      v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => shareResult(title, [
              'Total Area = ${_fmt(totalA)} m²',
              'Centroid x̄ = ${_fmt(xBar)} m',
              'Centroid ȳ = ${_fmt(yBar)} m',
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
