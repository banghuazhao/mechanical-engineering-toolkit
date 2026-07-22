import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/bolted_joint_result_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BoltedJointPage extends StatefulWidget {
  const BoltedJointPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<BoltedJointPage> createState() => _BoltedJointPageState();
}

class _BoltedJointPageState extends State<BoltedJointPage> {
  double? _p;
  double? _d;
  int _n = 1;
  double? _t;
  double? _e;
  bool _doubleShear = false;
  double? _allowShear;
  double? _allowBearing;
  final _nController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _p = double.tryParse(inputs['P'] ?? '');
    _d = double.tryParse(inputs['d'] ?? '');
    _n = int.tryParse(inputs['n'] ?? '') ?? 1;
    _nController.text = '$_n';
    _t = double.tryParse(inputs['t'] ?? '');
    _e = double.tryParse(inputs['e'] ?? '');
    _doubleShear = inputs['shear'] == 'double';
    _allowShear = double.tryParse(inputs['allowShear'] ?? '');
    _allowBearing = double.tryParse(inputs['allowBearing'] ?? '');
  }

  @override
  void dispose() {
    _nController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _calculate,
        icon: const Icon(Icons.analytics_rounded),
        label: Text(S.of(context).Calculate),
      ),
      body: AppContent(
        padding: EdgeInsets.zero,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            context.tokens.space4,
            context.tokens.space4,
            context.tokens.space4,
            100,
          ),
          children: [
            AppSectionCard(
              title: 'Bolted / Riveted Joint',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shear, bearing, and tear-out stress for a group of identical fasteners carrying a single applied load in one direction.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Single shear')),
                      ButtonSegment(value: true, label: Text('Double shear')),
                    ],
                    selected: {_doubleShear},
                    onSelectionChanged: (s) =>
                        setState(() => _doubleShear = s.first),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Applied load, P',
                      category: UnitCategory.force,
                      signed: false,
                      initialSI: _p,
                      onChangedSI: (v) => _p = v,
                    ),
                    UnitField(
                      label: 'Bolt diameter, d',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _d,
                      onChangedSI: (v) => _d = v,
                    ),
                    TextField(
                      controller: _nController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: 'Number of bolts, n'),
                      onChanged: (v) => _n = int.tryParse(v) ?? 1,
                    ),
                    UnitField(
                      label: 'Plate thickness, t',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _t,
                      onChangedSI: (v) => _t = v,
                    ),
                    UnitField(
                      label: 'Edge distance, e',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _e,
                      onChangedSI: (v) => _e = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space4),
                  Text(
                    'Allowable stresses (optional — enables a factor of safety)',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  SizedBox(height: context.tokens.space2),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Allowable shear stress',
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _allowShear,
                      onChangedSI: (v) => _allowShear = v,
                    ),
                    UnitField(
                      label: 'Allowable bearing stress',
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _allowBearing,
                      onChangedSI: (v) => _allowBearing = v,
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _calculate() {
    try {
      final p = _p;
      final d = _d;
      final t = _t;
      final e = _e;
      if (p == null || d == null || t == null || e == null) {
        throw const FormatException('Enter P, d, t, and e.');
      }
      if (p <= 0 || d <= 0 || t <= 0 || _n < 1) {
        throw const FormatException(
            'Load, diameter, and thickness must be positive, and there must be at least one bolt.');
      }
      if (e <= d / 2) {
        throw const FormatException(
            'Edge distance e must be greater than half the bolt diameter.');
      }

      final shearPlanes = _doubleShear ? 2 : 1;
      final shearArea = _n * shearPlanes * pi / 4 * d * d;
      final bearingArea = _n * d * t;
      final tearOutArea = _n * 2 * (e - d / 2) * t;

      final tauShear = p / shearArea;
      final sigmaBearing = p / bearingArea;
      final sigmaTearOut = p / tearOutArea;

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'P': '$p',
        'd': '$d',
        'n': '$_n',
        't': '$t',
        'e': '$e',
        'shear': _doubleShear ? 'double' : 'single',
        'allowShear': '${_allowShear ?? ''}',
        'allowBearing': '${_allowBearing ?? ''}',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BoltedJointResultPage(
            title: widget.title,
            tauShear: tauShear,
            sigmaBearing: sigmaBearing,
            sigmaTearOut: sigmaTearOut,
            allowShear: _allowShear,
            allowBearing: _allowBearing,
          ),
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
