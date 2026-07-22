import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class AngleOfTwistPage extends StatefulWidget {
  const AngleOfTwistPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<AngleOfTwistPage> createState() => _AngleOfTwistPageState();
}

class _AngleOfTwistPageState extends State<AngleOfTwistPage> {
  double? _t;
  double? _l;
  double? _g;
  double? _j;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _t = double.tryParse(inputs['T'] ?? '');
    _l = double.tryParse(inputs['L'] ?? '');
    _g = double.tryParse(inputs['G'] ?? '');
    _j = double.tryParse(inputs['J'] ?? '');
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
              title: 'Angle of Twist',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The angle of twist for a circular shaft under torque T.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''\phi = \frac{TL}{GJ}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Torque, T',
                      category: UnitCategory.momentSection,
                      initialSI: _t,
                      onChangedSI: (v) => _t = v,
                    ),
                    UnitField(
                      label: 'Length, L',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _l,
                      onChangedSI: (v) => _l = v,
                    ),
                    UnitField(
                      label: 'Shear modulus, G',
                      category: UnitCategory.modulus,
                      signed: false,
                      initialSI: _g,
                      onChangedSI: (v) => _g = v,
                    ),
                    UnitField(
                      label: 'Polar moment, J',
                      category: UnitCategory.momentOfInertia,
                      signed: false,
                      initialSI: _j,
                      onChangedSI: (v) => _j = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space3),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.shearModulusSI != null) {
                        _g = preset.shearModulusSI;
                      }
                    }),
                  ),
                  SizedBox(height: context.tokens.space2),
                  Text(
                    'Tip: for a solid circular shaft of diameter d, J = πd⁴/32; for a hollow shaft (do, di), J = π(do⁴ − di⁴)/32.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
      final t = _t;
      final l = _l;
      final g = _g;
      final j = _j;
      if (t == null || l == null || g == null || j == null) {
        throw const FormatException('Enter T, L, G, and J.');
      }
      if (g == 0 || j == 0) {
        throw const FormatException('G and J must be nonzero.');
      }

      // G is entered in GPa; the mm/N-based formula needs the numerically
      // equivalent MPa value (1 GPa = 1000 MPa).
      final phiRad = t * l / (g * 1000 * j);
      final phiDeg = phiRad * 180 / pi;

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'T': '$t',
        'L': '$l',
        'G': '$g',
        'J': '$j',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _AngleOfTwistResultPage(
            toolId: widget.toolId,
            phiRad: phiRad,
            phiDeg: phiDeg,
            t: t,
            l: l,
            g: g,
            j: j,
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

class _AngleOfTwistResultPage extends StatelessWidget {
  _AngleOfTwistResultPage({
    required this.toolId,
    required this.phiRad,
    required this.phiDeg,
    required this.t,
    required this.l,
    required this.g,
    required this.j,
  });

  final int toolId;
  final double phiRad;
  final double phiDeg;
  final double t;
  final double l;
  final double g;
  final double j;
  final _exportKey = GlobalKey();

  String _fv(double valueSI, UnitCategory category, UnitSystem system,
          NumberPrecisionHelper precs) =>
      '${precs.formatValue(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final tool = ToolLibrary.shared.item(toolId, context);

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
            onPressed: () => shareResultImage(_exportKey, 'Angle of Twist'),
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
              ToolResultHeader(tool: tool),
              AppSectionCard(
                title: 'Angle of Twist',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Angle, φ (radians)',
                    value: precs.formatValue(phiRad),
                  ),
                  AppCopyableValue(
                    label: 'Angle, φ (degrees)',
                    valueSI: phiDeg,
                    category: UnitCategory.angle,
                  ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'φ = T·L / (G·J)\n'
                  '= ${_fv(t, UnitCategory.momentSection, system, precs)} × ${_fv(l, UnitCategory.length, system, precs)} / (${_fv(g, UnitCategory.modulus, system, precs)} × ${_fv(j, UnitCategory.momentOfInertia, system, precs)})\n'
                  '= ${precs.formatValue(phiRad)} rad = ${precs.formatValue(phiDeg)}°',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: context.tokens.space4),
              ParameterSweepCard(
                variableLabel: 'Length, L',
                variableCategory: UnitCategory.length,
                baseValueSI: l,
                outputLabel: 'φ (rad)',
                outputCategory: null,
                compute: (variedL) => t * variedL / (g * 1000 * j),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(UnitSystem system, NumberPrecisionHelper precs) =>
      shareResult('Angle of Twist', [
        'φ = ${precs.formatValue(phiRad)} rad (${precs.formatValue(phiDeg)}°)',
        '',
        'Calculation:',
        'φ = T·L / (G·J)',
        '= ${_fv(t, UnitCategory.momentSection, system, precs)} × ${_fv(l, UnitCategory.length, system, precs)} / (${_fv(g, UnitCategory.modulus, system, precs)} × ${_fv(j, UnitCategory.momentOfInertia, system, precs)})',
        '= ${precs.formatValue(phiRad)} rad = ${precs.formatValue(phiDeg)}°',
      ]);
}
