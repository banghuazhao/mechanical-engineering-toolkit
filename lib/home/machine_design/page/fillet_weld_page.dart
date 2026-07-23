import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class FilletWeldPage extends StatefulWidget {
  const FilletWeldPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<FilletWeldPage> createState() => _FilletWeldPageState();
}

class _FilletWeldPageState extends State<FilletWeldPage> {
  double? _w;
  double? _l;
  double? _f;
  double? _allow;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _w = double.tryParse(inputs['w'] ?? '');
    _l = double.tryParse(inputs['L'] ?? '');
    _f = double.tryParse(inputs['F'] ?? '');
    _allow = double.tryParse(inputs['allow'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
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
            ToolResultHeader(tool: tool),
            AppSectionCard(
              title: 'Fillet Weld Strength',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shear stress on the weld throat for a fillet weld of leg size w and effective length L, treating the throat as the failure plane (the standard simplified approach).',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''\tau = \frac{F}{0.707\,w\,L}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Leg size, w',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _w,
                      onChangedSI: (v) => _w = v,
                    ),
                    UnitField(
                      label: 'Effective length, L',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _l,
                      onChangedSI: (v) => _l = v,
                    ),
                    UnitField(
                      label: 'Applied force, F',
                      category: UnitCategory.force,
                      signed: false,
                      initialSI: _f,
                      onChangedSI: (v) => _f = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space3),
                  UnitField(
                    label: 'Allowable shear stress (optional)',
                    category: UnitCategory.stress,
                    signed: false,
                    initialSI: _allow,
                    onChangedSI: (v) => _allow = v,
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
      final w = _w;
      final l = _l;
      final f = _f;
      if (w == null || l == null || f == null) {
        throw const FormatException('Enter w, L, and F.');
      }
      if (w <= 0 || l <= 0 || f <= 0) {
        throw const FormatException('w, L, and F must be positive.');
      }

      final throat = 0.707 * w;
      final area = throat * l;
      final tau = f / area;

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'w': '$w',
        'L': '$l',
        'F': '$f',
        'allow': _allow == null ? '' : '$_allow',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _FilletWeldResultPage(
            tau: tau,
            w: w,
            l: l,
            f: f,
            allow: _allow,
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

class _FilletWeldResultPage extends StatelessWidget {
  _FilletWeldResultPage({
    required this.tau,
    required this.w,
    required this.l,
    required this.f,
    this.allow,
  });

  final double tau;
  final double w;
  final double l;
  final double f;
  final double? allow;
  final _exportKey = GlobalKey();

  String _fv(double valueSI, UnitCategory category, UnitSystem system,
          NumberPrecisionHelper precs) =>
      '${precs.formatValue(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final hasAllow = allow != null && allow! > 0;
    final fos = hasAllow ? allow! / tau : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            tooltip: 'Share results',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _share(system, precs, fos),
          ),
          IconButton(
            tooltip: 'Share as image',
            icon: const Icon(Icons.image_outlined),
            onPressed: () =>
                shareResultImage(_exportKey, 'Fillet Weld Strength'),
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
                title: 'Fillet Weld Strength',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Shear stress, τ',
                    valueSI: tau,
                    category: UnitCategory.stress,
                  ),
                  if (fos != null)
                    AppCopyableValue(
                      label: 'Factor of safety',
                      value: precs.formatValue(fos),
                    ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'τ = F / (0.707·w·L)\n'
                  '= ${_fv(f, UnitCategory.force, system, precs)} / (0.707 × ${_fv(w, UnitCategory.length, system, precs)} × ${_fv(l, UnitCategory.length, system, precs)})\n'
                  '= ${_fv(tau, UnitCategory.stress, system, precs)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: context.tokens.space4),
              ParameterSweepCard(
                variableLabel: 'Leg size, w',
                variableCategory: UnitCategory.length,
                baseValueSI: w,
                outputLabel: 'τ',
                outputCategory: UnitCategory.stress,
                compute: (variedW) => f / (0.707 * variedW * l),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(UnitSystem system, NumberPrecisionHelper precs, double? fos) =>
      shareResult('Fillet Weld Strength', [
        'τ = ${_fv(tau, UnitCategory.stress, system, precs)}',
        if (fos != null) 'FoS = ${precs.formatValue(fos)}',
        '',
        'Calculation:',
        'τ = F / (0.707·w·L)',
        '= ${_fv(f, UnitCategory.force, system, precs)} / (0.707 × ${_fv(w, UnitCategory.length, system, precs)} × ${_fv(l, UnitCategory.length, system, precs)})',
        '= ${_fv(tau, UnitCategory.stress, system, precs)}',
      ]);
}
