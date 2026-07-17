import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

enum _LoadType { pointLoad, udl, both }

class BeamReactionsPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const BeamReactionsPage(
      {Key? key, required this.title, required this.toolId, this.initialInputs})
      : super(key: key);

  @override
  State<BeamReactionsPage> createState() => _BeamReactionsPageState();
}

class _BeamReactionsPageState extends State<BeamReactionsPage> {
  _LoadType _loadType = _LoadType.pointLoad;

  double? _span;
  double? _p;
  double? _a;
  double? _w;

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      final inputs = widget.initialInputs!;
      _span = double.tryParse(inputs['Span L'] ?? '');
      if (inputs.containsKey('Load Type')) {
        _loadType = _LoadType.values.firstWhere(
            (e) => e.toString().split('.').last == inputs['Load Type'],
            orElse: () => _LoadType.pointLoad);
      }
      _p = double.tryParse(inputs['P (load)'] ?? '');
      _a = double.tryParse(inputs['a (from A)'] ?? '');
      _w = double.tryParse(inputs['w (intensity)'] ?? '');
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
                  Text('Beam Configuration', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Simply supported beam — pin at A (left), roller at B (right)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  UnitField(
                    label: 'Span L',
                    category: UnitCategory.span,
                    initialSI: _span,
                    onChangedSI: (v) => _span = v,
                  ),
                  const SizedBox(height: 16),
                  Text('Load Type', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<_LoadType>(
                    segments: const [
                      ButtonSegment(value: _LoadType.pointLoad, label: Text('Point Load')),
                      ButtonSegment(value: _LoadType.udl, label: Text('UDL')),
                      ButtonSegment(value: _LoadType.both, label: Text('Both')),
                    ],
                    selected: {_loadType},
                    onSelectionChanged: (s) => setState(() => _loadType = s.first),
                  ),
                  const SizedBox(height: 16),
                  if (_loadType == _LoadType.pointLoad || _loadType == _LoadType.both) ...[
                    Text('Point Load', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: UnitField(
                            label: 'P (load)',
                            category: UnitCategory.force,
                            initialSI: _p,
                            onChangedSI: (v) => _p = v,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: UnitField(
                            label: 'a (from A)',
                            category: UnitCategory.span,
                            initialSI: _a,
                            onChangedSI: (v) => _a = v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_loadType == _LoadType.udl || _loadType == _LoadType.both) ...[
                    Text('Uniform Distributed Load (full span)', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    UnitField(
                      label: 'w (intensity)',
                      category: UnitCategory.distributedLoad,
                      initialSI: _w,
                      onChangedSI: (v) => _w = v,
                    ),
                  ],
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

  void _calculate() {
    final L = _span;
    if (L == null || L <= 0) { _showError('Enter a valid span L > 0'); return; }

    final hasPoint = _loadType == _LoadType.pointLoad || _loadType == _LoadType.both;
    final hasUdl = _loadType == _LoadType.udl || _loadType == _LoadType.both;

    double? P, a, w;
    if (hasPoint) {
      P = _p;
      a = _a;
      if (P == null || a == null) { _showError('Enter P and a'); return; }
      if (a < 0 || a > L) { _showError('a must be between 0 and L'); return; }
    }
    if (hasUdl) {
      w = _w;
      if (w == null) { _showError('Enter w'); return; }
    }

    final Map<String, String> inputs = {
      'Span L': L.toString(),
      'Load Type': _loadType.toString().split('.').last,
    };
    if (hasPoint) {
      inputs['P (load)'] = P.toString();
      inputs['a (from A)'] = a.toString();
    }
    if (hasUdl) {
      inputs['w (intensity)'] = w.toString();
    }
    context.read<ToolHistory>().record(widget.toolId, inputs: inputs);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ResultPage(
          title: widget.title,
          loadType: _loadType,
          L: L, P: P, a: a, w: w,
        ),
      ),
    );
  }

  void _showError(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

class _ResultPage extends StatelessWidget {
  final String title;
  final _LoadType loadType;
  final double L;
  final double? P, a, w;

  const _ResultPage({
    required this.title,
    required this.loadType,
    required this.L,
    required this.P,
    required this.a,
    required this.w,
  });

  String _fmt(double v) =>
      v.toStringAsFixed(4).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_fmt(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  ({double Ra, double Rb, double maxM, List<String> steps}) _solve(
      UnitSystem system) {
    final hasPoint =
        loadType == _LoadType.pointLoad || loadType == _LoadType.both;
    final hasUdl = loadType == _LoadType.udl || loadType == _LoadType.both;
    final l = _fv(L, UnitCategory.span, system);

    double Ra = 0, Rb = 0, maxM = 0;
    final steps = <String>[];

    if (hasPoint && !hasUdl) {
      final b = L - a!;
      Ra = P! * b / L;
      Rb = P! * a! / L;
      maxM = Ra * a!;
      steps.addAll([
        'Point load P = ${_fv(P!, UnitCategory.force, system)} at a = ${_fv(a!, UnitCategory.span, system)} from A',
        'b = L − a = $l − ${_fv(a!, UnitCategory.span, system)} = ${_fv(b, UnitCategory.span, system)}',
        'Ra = P·b / L',
        '   = ${_fv(P!, UnitCategory.force, system)} × ${_fv(b, UnitCategory.span, system)} / $l',
        '   = ${_fv(Ra, UnitCategory.force, system)}',
        'Rb = P·a / L',
        '   = ${_fv(P!, UnitCategory.force, system)} × ${_fv(a!, UnitCategory.span, system)} / $l',
        '   = ${_fv(Rb, UnitCategory.force, system)}',
        'M_max = Ra·a = ${_fv(Ra, UnitCategory.force, system)} × ${_fv(a!, UnitCategory.span, system)} = ${_fv(maxM, UnitCategory.torque, system)}  (at x = ${_fv(a!, UnitCategory.span, system)})',
      ]);
    } else if (!hasPoint && hasUdl) {
      Ra = w! * L / 2;
      Rb = Ra;
      maxM = w! * L * L / 8;
      steps.addAll([
        'UDL w = ${_fv(w!, UnitCategory.distributedLoad, system)} over L = $l',
        'Ra = w·L / 2 = ${_fv(w!, UnitCategory.distributedLoad, system)} × $l / 2 = ${_fv(Ra, UnitCategory.force, system)}',
        'Rb = w·L / 2 = ${_fv(Rb, UnitCategory.force, system)}',
        'M_max = w·L² / 8',
        '      = ${_fv(w!, UnitCategory.distributedLoad, system)} × $l² / 8',
        '      = ${_fv(maxM, UnitCategory.torque, system)}  (at midspan)',
      ]);
    } else {
      final b = L - a!;
      final RaPt = P! * b / L;
      final RbPt = P! * a! / L;
      final RaUdl = w! * L / 2;
      Ra = RaPt + RaUdl;
      Rb = RbPt + RaUdl;
      maxM = Ra * a!; // approximate
      steps.addAll([
        'Point load P = ${_fv(P!, UnitCategory.force, system)} at a = ${_fv(a!, UnitCategory.span, system)}, UDL w = ${_fv(w!, UnitCategory.distributedLoad, system)}',
        'Ra (point) = P·b/L = ${_fv(P!, UnitCategory.force, system)}×${_fv(b, UnitCategory.span, system)}/$l = ${_fv(RaPt, UnitCategory.force, system)}',
        'Ra (UDL)   = w·L/2 = ${_fv(w!, UnitCategory.distributedLoad, system)}×$l/2 = ${_fv(RaUdl, UnitCategory.force, system)}',
        'Ra = ${_fv(RaPt, UnitCategory.force, system)} + ${_fv(RaUdl, UnitCategory.force, system)} = ${_fv(Ra, UnitCategory.force, system)}',
        'Rb (point) = P·a/L = ${_fv(P!, UnitCategory.force, system)}×${_fv(a!, UnitCategory.span, system)}/$l = ${_fv(RbPt, UnitCategory.force, system)}',
        'Rb = ${_fv(RbPt, UnitCategory.force, system)} + ${_fv(RaUdl, UnitCategory.force, system)} = ${_fv(Rb, UnitCategory.force, system)}',
        'M_max ≈ Ra·a = ${_fv(Ra, UnitCategory.force, system)} × ${_fv(a!, UnitCategory.span, system)} = ${_fv(maxM, UnitCategory.torque, system)}',
      ]);
    }
    return (Ra: Ra, Rb: Rb, maxM: maxM, steps: steps);
  }

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final solved = _solve(system);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => shareResult(title, [
              'Ra = ${_fv(solved.Ra, UnitCategory.force, system)}',
              'Rb = ${_fv(solved.Rb, UnitCategory.force, system)}',
              'M_max = ${_fv(solved.maxM, UnitCategory.torque, system)}',
            ]),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [CalculationCard(steps: solved.steps)],
      ),
    );
  }
}
