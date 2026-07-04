import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
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

  final _spanCtrl = TextEditingController();
  final _pCtrl = TextEditingController();
  final _aCtrl = TextEditingController();
  final _wCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      final inputs = widget.initialInputs!;
      _spanCtrl.text = inputs['Span L'] ?? '';
      if (inputs.containsKey('Load Type')) {
        _loadType = _LoadType.values.firstWhere(
            (e) => e.toString().split('.').last == inputs['Load Type'],
            orElse: () => _LoadType.pointLoad);
      }
      _pCtrl.text = inputs['P (load)'] ?? '';
      _aCtrl.text = inputs['a (from A)'] ?? '';
      _wCtrl.text = inputs['w (intensity)'] ?? '';
    }
  }

  @override
  void dispose() {
    _spanCtrl.dispose();
    _pCtrl.dispose();
    _aCtrl.dispose();
    _wCtrl.dispose();
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
                  Text('Beam Configuration', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Simply supported beam — pin at A (left), roller at B (right)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _spanCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Span L', suffixText: 'm'),
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
                          child: TextField(
                            controller: _pCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'P (load)', suffixText: 'N'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _aCtrl,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: 'a (from A)', suffixText: 'm'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_loadType == _LoadType.udl || _loadType == _LoadType.both) ...[
                    Text('Uniform Distributed Load (full span)', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _wCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'w (intensity)', suffixText: 'N/m'),
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
    final L = double.tryParse(_spanCtrl.text);
    if (L == null || L <= 0) { _showError('Enter a valid span L > 0'); return; }

    final hasPoint = _loadType == _LoadType.pointLoad || _loadType == _LoadType.both;
    final hasUdl = _loadType == _LoadType.udl || _loadType == _LoadType.both;

    double? P, a, w;
    if (hasPoint) {
      P = double.tryParse(_pCtrl.text);
      a = double.tryParse(_aCtrl.text);
      if (P == null || a == null) { _showError('Enter P and a'); return; }
      if (a < 0 || a > L) { _showError('a must be between 0 and L'); return; }
    }
    if (hasUdl) {
      w = double.tryParse(_wCtrl.text);
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

    double Ra = 0, Rb = 0, maxM = 0;
    final steps = <String>[];

    if (hasPoint && !hasUdl) {
      final b = L - a!;
      Ra = P! * b / L;
      Rb = P * a / L;
      maxM = Ra * a;
      steps.addAll([
        'Point load P = ${_fmt(P)} N at a = ${_fmt(a)} m from A',
        'b = L − a = ${_fmt(L)} − ${_fmt(a)} = ${_fmt(b)} m',
        'Ra = P·b / L',
        '   = ${_fmt(P)} × ${_fmt(b)} / ${_fmt(L)}',
        '   = ${_fmt(Ra)} N',
        'Rb = P·a / L',
        '   = ${_fmt(P)} × ${_fmt(a)} / ${_fmt(L)}',
        '   = ${_fmt(Rb)} N',
        'M_max = Ra·a = ${_fmt(Ra)} × ${_fmt(a)} = ${_fmt(maxM)} N·m  (at x = ${_fmt(a)} m)',
      ]);
    } else if (!hasPoint && hasUdl) {
      Ra = w! * L / 2;
      Rb = Ra;
      maxM = w * L * L / 8;
      steps.addAll([
        'UDL w = ${_fmt(w)} N/m over L = ${_fmt(L)} m',
        'Ra = w·L / 2 = ${_fmt(w)} × ${_fmt(L)} / 2 = ${_fmt(Ra)} N',
        'Rb = w·L / 2 = ${_fmt(Rb)} N',
        'M_max = w·L² / 8',
        '      = ${_fmt(w)} × ${_fmt(L)}² / 8',
        '      = ${_fmt(maxM)} N·m  (at midspan)',
      ]);
    } else {
      final b = L - a!;
      final RaPt = P! * b / L;
      final RbPt = P * a / L;
      final RaUdl = w! * L / 2;
      Ra = RaPt + RaUdl;
      Rb = RbPt + RaUdl;
      maxM = Ra * a; // approximate
      steps.addAll([
        'Point load P = ${_fmt(P)} N at a = ${_fmt(a)} m, UDL w = ${_fmt(w)} N/m',
        'Ra (point) = P·b/L = ${_fmt(P)}×${_fmt(b)}/${_fmt(L)} = ${_fmt(RaPt)} N',
        'Ra (UDL)   = w·L/2 = ${_fmt(w)}×${_fmt(L)}/2 = ${_fmt(RaUdl)} N',
        'Ra = ${_fmt(RaPt)} + ${_fmt(RaUdl)} = ${_fmt(Ra)} N',
        'Rb (point) = P·a/L = ${_fmt(P)}×${_fmt(a)}/${_fmt(L)} = ${_fmt(RbPt)} N',
        'Rb = ${_fmt(RbPt)} + ${_fmt(RaUdl)} = ${_fmt(Rb)} N',
        'M_max ≈ Ra·a = ${_fmt(Ra)} × ${_fmt(a)} = ${_fmt(maxM)} N·m',
      ]);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ResultPage(
          title: widget.title,
          Ra: Ra, Rb: Rb, maxM: maxM,
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
  final double Ra, Rb, maxM;
  final List<String> steps;

  const _ResultPage({
    required this.title,
    required this.Ra,
    required this.Rb,
    required this.maxM,
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
              'Ra = ${_fmt(Ra)} N',
              'Rb = ${_fmt(Rb)} N',
              'M_max = ${_fmt(maxM)} N·m',
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
