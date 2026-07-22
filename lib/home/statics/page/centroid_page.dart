import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

enum _ShapeType { rectangle, circle, triangle, semicircle }

class _Shape {
  _ShapeType type = _ShapeType.rectangle;
  bool subtract = false;
  double? dim1; // width or radius
  double? dim2; // height
  double? xRef;
  double? yRef;
}

class CentroidPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const CentroidPage(
      {Key? key, required this.title, required this.toolId, this.initialInputs})
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
          s.dim1 = double.tryParse(inputs['$prefix Dim1'] ?? '');
          s.dim2 = double.tryParse(inputs['$prefix Dim2'] ?? '');
          s.xRef = double.tryParse(inputs['$prefix xRef'] ?? '');
          s.yRef = double.tryParse(inputs['$prefix yRef'] ?? '');
          s.subtract = inputs['$prefix Subtract'] == 'true';
          _shapes.add(s);
        }
      }
    }
  }

  String _shapeLabel(_ShapeType t) {
    switch (t) {
      case _ShapeType.rectangle:
        return 'Rectangle';
      case _ShapeType.circle:
        return 'Circle';
      case _ShapeType.triangle:
        return 'Right Triangle';
      case _ShapeType.semicircle:
        return 'Semicircle (up)';
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
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Calculate', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildShapeCard(int i) {
    final s = _shapes[i];
    final showDim2 =
        s.type == _ShapeType.rectangle || s.type == _ShapeType.triangle;
    final dim1Label =
        (s.type == _ShapeType.circle || s.type == _ShapeType.semicircle)
            ? 'Radius r'
            : 'Width b';
    final xLabel =
        (s.type == _ShapeType.circle || s.type == _ShapeType.semicircle)
            ? 'x center'
            : 'x (bottom-left)';
    final yLabel =
        (s.type == _ShapeType.circle || s.type == _ShapeType.semicircle)
            ? 'y center'
            : 'y (bottom-left)';

    return Card(
      key: ObjectKey(s),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Shape ${i + 1}',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                const Text('Subtract'),
                Switch(
                  value: s.subtract,
                  onChanged: (v) => setState(() => s.subtract = v),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded,
                      color: Colors.red),
                  onPressed: _shapes.length > 1
                      ? () {
                          setState(() => _shapes.removeAt(i));
                        }
                      : null,
                ),
              ],
            ),
            DropdownButtonFormField<_ShapeType>(
              initialValue: s.type,
              decoration: const InputDecoration(labelText: 'Shape type'),
              items: _ShapeType.values
                  .map((t) =>
                      DropdownMenuItem(value: t, child: Text(_shapeLabel(t))))
                  .toList(),
              onChanged: (v) => setState(() => s.type = v!),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: UnitField(
                    label: dim1Label,
                    category: UnitCategory.span,
                    initialSI: s.dim1,
                    onChangedSI: (v) => s.dim1 = v,
                  ),
                ),
                if (showDim2) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: UnitField(
                      label: 'Height h',
                      category: UnitCategory.span,
                      initialSI: s.dim2,
                      onChangedSI: (v) => s.dim2 = v,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: UnitField(
                    label: xLabel,
                    category: UnitCategory.span,
                    initialSI: s.xRef,
                    onChangedSI: (v) => s.xRef = v,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: UnitField(
                    label: yLabel,
                    category: UnitCategory.span,
                    initialSI: s.yRef,
                    onChangedSI: (v) => s.yRef = v,
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
    final Map<String, String> inputs = {};
    final shapeCalcs =
        <({_ShapeType type, bool subtract, double a, double cx, double cy})>[];

    for (int i = 0; i < _shapes.length; i++) {
      final s = _shapes[i];
      final d1 = s.dim1;
      if (d1 == null || d1 <= 0) {
        _showError('Enter dimension for shape ${i + 1}');
        return;
      }
      final xRef = s.xRef ?? 0;
      final yRef = s.yRef ?? 0;

      final prefix = 'Shape ${i + 1}';
      inputs['$prefix Type'] = _shapeLabel(s.type);
      inputs['$prefix Dim1'] = d1.toString();
      inputs['$prefix xRef'] = xRef.toString();
      inputs['$prefix yRef'] = yRef.toString();
      if (s.type == _ShapeType.rectangle || s.type == _ShapeType.triangle) {
        inputs['$prefix Dim2'] = '${s.dim2 ?? ''}';
      }
      inputs['$prefix Subtract'] = s.subtract.toString();

      double A, cx, cy;
      switch (s.type) {
        case _ShapeType.rectangle:
          final h = s.dim2;
          if (h == null || h <= 0) {
            _showError('Enter height for shape ${i + 1}');
            return;
          }
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
          final h = s.dim2;
          if (h == null || h <= 0) {
            _showError('Enter height for shape ${i + 1}');
            return;
          }
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
      shapeCalcs
          .add((type: s.type, subtract: s.subtract, a: A, cx: cx, cy: cy));
    }

    if (totalA == 0) {
      _showError('Total area is zero');
      return;
    }
    context.read<ToolHistory>().record(widget.toolId, inputs: inputs);
    final xBar = sumAx / totalA;
    final yBar = sumAy / totalA;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ResultPage(
          title: widget.title,
          totalA: totalA,
          xBar: xBar,
          yBar: yBar,
          sumAx: sumAx,
          sumAy: sumAy,
          shapeCalcs: shapeCalcs,
        ),
      ),
    );
  }

  void _showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

class _ResultPage extends StatelessWidget {
  final String title;
  final double totalA, xBar, yBar, sumAx, sumAy;
  final List<({_ShapeType type, bool subtract, double a, double cx, double cy})>
      shapeCalcs;

  _ResultPage({
    required this.title,
    required this.totalA,
    required this.xBar,
    required this.yBar,
    required this.sumAx,
    required this.sumAy,
    required this.shapeCalcs,
  });

  final _exportKey = GlobalKey();

  String _fmt(double v) => v
      .toStringAsFixed(4)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');

  String _fvArea(double valueSI, UnitSystem system) =>
      '${_fmt(fromSI(valueSI, UnitCategory.areaStructural, system))} ${unitLabel(UnitCategory.areaStructural, system)}';

  String _fvSpan(double valueSI, UnitSystem system) =>
      '${_fmt(fromSI(valueSI, UnitCategory.span, system))} ${unitLabel(UnitCategory.span, system)}';

  // First moment of area (area x length): m^3 <-> ft^3. Used only to keep the
  // illustrative "sumAx / totalA = xBar" step arithmetic dimensionally
  // consistent; not a general-purpose unit category.
  String _fvAreaMoment(double valueSI, UnitSystem system) {
    if (system == UnitSystem.si) return '${_fmt(valueSI)} m³';
    return '${_fmt(valueSI / 0.028316846592)} ft³';
  }

  List<String> _steps(UnitSystem system) {
    final steps = <String>[];
    for (var i = 0; i < shapeCalcs.length; i++) {
      final s = shapeCalcs[i];
      final tag = s.subtract ? '(subtract)' : '';
      steps.add(
          'Shape ${i + 1} $tag  A=${_fvArea(s.a, system)}  cx=${_fvSpan(s.cx, system)}  cy=${_fvSpan(s.cy, system)}');
    }
    steps.addAll([
      'Total A = ${_fvArea(totalA, system)}',
      'x̄ = ΣAᵢxᵢ / A = ${_fvAreaMoment(sumAx, system)} / ${_fvArea(totalA, system)} = ${_fvSpan(xBar, system)}',
      'ȳ = ΣAᵢyᵢ / A = ${_fvAreaMoment(sumAy, system)} / ${_fvArea(totalA, system)} = ${_fvSpan(yBar, system)}',
    ]);
    return steps;
  }

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => shareResult(title, [
              'Total Area = ${_fvArea(totalA, system)}',
              'Centroid x̄ = ${_fvSpan(xBar, system)}',
              'Centroid ȳ = ${_fvSpan(yBar, system)}',
            ]),
          ),
          IconButton(
            icon: const Icon(Icons.image_outlined),
            onPressed: () => shareResultImage(_exportKey, title),
          ),
        ],
      ),
      bottomNavigationBar: const AppBannerAd(),
      body: RepaintBoundary(
        key: _exportKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [CalculationCard(steps: _steps(system))],
        ),
      ),
    );
  }
}
