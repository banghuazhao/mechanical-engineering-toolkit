import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BoltPreloadPage extends StatefulWidget {
  const BoltPreloadPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<BoltPreloadPage> createState() => _BoltPreloadPageState();
}

class _BoltPreloadPageState extends State<BoltPreloadPage> {
  double? _f;
  double? _d;
  double _k = 0.2;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _f = double.tryParse(inputs['F'] ?? '');
    _d = double.tryParse(inputs['d'] ?? '');
    _k = double.tryParse(inputs['K'] ?? '') ?? 0.2;
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
              title: 'Bolt Preload / Torque-Tension',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimates the tightening torque needed to reach a target bolt preload, using the short-form torque-tension equation.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''T = K \cdot F \cdot d''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Target preload, F',
                      category: UnitCategory.force,
                      signed: false,
                      initialSI: _f,
                      onChangedSI: (v) => _f = v,
                    ),
                    UnitField(
                      label: 'Nominal diameter, d',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _d,
                      onChangedSI: (v) => _d = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space3),
                  Text(
                    'Nut factor, K (default 0.2 — typical for non-lubricated steel; use ~0.15 lubricated/plated, ~0.2-0.3 dry)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space2),
                  TextFormField(
                    initialValue: _k.toString(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'K'),
                    onChanged: (v) => _k = double.tryParse(v) ?? _k,
                  ),
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
      final f = _f;
      final d = _d;
      if (f == null || d == null) {
        throw const FormatException('Enter F and d.');
      }
      if (f <= 0 || d <= 0) {
        throw const FormatException('F and d must be positive.');
      }
      if (_k <= 0) {
        throw const FormatException('Nut factor K must be positive.');
      }

      // d is in mm; T = K*F*d needs d in meters to give torque in N·m.
      final torque = _k * f * (d / 1000);

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'F': '$f',
        'd': '$d',
        'K': '$_k',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _BoltPreloadResultPage(
            torque: torque,
            f: f,
            d: d,
            k: _k,
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

class _BoltPreloadResultPage extends StatelessWidget {
  _BoltPreloadResultPage({
    required this.torque,
    required this.f,
    required this.d,
    required this.k,
  });

  final double torque;
  final double f;
  final double d;
  final double k;
  final _exportKey = GlobalKey();

  String _fv(double valueSI, UnitCategory category, UnitSystem system,
          NumberPrecisionHelper precs) =>
      '${precs.formatValue(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            tooltip: 'Share results',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _share(system, precs),
          ),
          IconButton(
            tooltip: 'Share as image',
            icon: const Icon(Icons.image_outlined),
            onPressed: () =>
                shareResultImage(_exportKey, 'Bolt Preload / Torque-Tension'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ToolSettingPage()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBannerAd(),
      body: RepaintBoundary(
        key: _exportKey,
        child: AppContent(
          padding: EdgeInsets.zero,
          child: ListView(
            padding: EdgeInsets.all(context.tokens.space4),
            children: [
              AppSectionCard(
                title: 'Bolt Preload / Torque-Tension',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Tightening torque, T',
                    valueSI: torque,
                    category: UnitCategory.torque,
                  ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'T = K·F·d\n'
                  '= ${precs.formatValue(k)} × ${_fv(f, UnitCategory.force, system, precs)} × ${_fv(d, UnitCategory.length, system, precs)}\n'
                  '= ${_fv(torque, UnitCategory.torque, system, precs)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: context.tokens.space4),
              ParameterSweepCard(
                variableLabel: 'Diameter, d',
                variableCategory: UnitCategory.length,
                baseValueSI: d,
                outputLabel: 'T',
                outputCategory: UnitCategory.torque,
                compute: (variedD) => k * f * (variedD / 1000),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(UnitSystem system, NumberPrecisionHelper precs) =>
      shareResult('Bolt Preload / Torque-Tension', [
        'T = ${_fv(torque, UnitCategory.torque, system, precs)}',
        '',
        'Calculation:',
        'T = K·F·d',
        '= ${precs.formatValue(k)} × ${_fv(f, UnitCategory.force, system, precs)} × ${_fv(d, UnitCategory.length, system, precs)}',
        '= ${_fv(torque, UnitCategory.torque, system, precs)}',
      ]);
}
