import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/combined_loading_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class CombinedLoadingPage extends StatefulWidget {
  const CombinedLoadingPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<CombinedLoadingPage> createState() => _CombinedLoadingPageState();
}

class _CombinedLoadingPageState extends State<CombinedLoadingPage> {
  double? _p;
  double? _a;
  double? _m;
  double? _i;
  double? _c;
  double? _t;
  double? _j;
  double? _r;
  double? _sy;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _p = double.tryParse(inputs['P'] ?? '');
    _a = double.tryParse(inputs['A'] ?? '');
    _m = double.tryParse(inputs['M'] ?? '');
    _i = double.tryParse(inputs['I'] ?? '');
    _c = double.tryParse(inputs['c'] ?? '');
    _t = double.tryParse(inputs['T'] ?? '');
    _j = double.tryParse(inputs['J'] ?? '');
    _r = double.tryParse(inputs['r'] ?? '');
    _sy = double.tryParse(inputs['Sy'] ?? '');
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
              title: 'Combined Loading at a Point',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Superimposes axial and bending normal stress with torsional shear stress at a single point on a cross-section (e.g. a loaded shaft), then reports the resulting principal stresses and von Mises stress.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  Text('Axial + bending → normal stress σ = P/A + M·c/I',
                      style: Theme.of(context).textTheme.labelMedium),
                  SizedBox(height: context.tokens.space2),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Axial force, P',
                      category: UnitCategory.force,
                      initialSI: _p,
                      onChangedSI: (v) => _p = v,
                    ),
                    UnitField(
                      label: 'Area, A',
                      category: UnitCategory.area,
                      signed: false,
                      initialSI: _a,
                      onChangedSI: (v) => _a = v,
                    ),
                    UnitField(
                      label: 'Bending moment, M',
                      category: UnitCategory.momentSection,
                      initialSI: _m,
                      onChangedSI: (v) => _m = v,
                    ),
                    UnitField(
                      label: 'Second moment, I',
                      category: UnitCategory.momentOfInertia,
                      signed: false,
                      initialSI: _i,
                      onChangedSI: (v) => _i = v,
                    ),
                    UnitField(
                      label: 'Distance to fiber, c',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _c,
                      onChangedSI: (v) => _c = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space4),
                  Text('Torsion → shear stress τ = T·r/J',
                      style: Theme.of(context).textTheme.labelMedium),
                  SizedBox(height: context.tokens.space2),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Torque, T',
                      category: UnitCategory.momentSection,
                      signed: false,
                      initialSI: _t,
                      onChangedSI: (v) => _t = v,
                    ),
                    UnitField(
                      label: 'Polar second moment, J',
                      category: UnitCategory.momentOfInertia,
                      signed: false,
                      initialSI: _j,
                      onChangedSI: (v) => _j = v,
                    ),
                    UnitField(
                      label: 'Radius, r',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _r,
                      onChangedSI: (v) => _r = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space4),
                  UnitField(
                    label: 'Yield strength, Sy (optional)',
                    category: UnitCategory.stress,
                    signed: false,
                    initialSI: _sy,
                    onChangedSI: (v) => _sy = v,
                  ),
                  SizedBox(height: context.tokens.space2),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.yieldStrengthSI != null) {
                        _sy = preset.yieldStrengthSI;
                      }
                    }),
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
      final p = _p ?? 0;
      final a = _a;
      final m = _m ?? 0;
      final i = _i;
      final c = _c ?? 0;
      final t = _t ?? 0;
      final j = _j;
      final r = _r ?? 0;

      if (a == null || a <= 0) {
        throw const FormatException('Enter a positive area, A.');
      }
      if (_m != null && _m != 0 && (i == null || i <= 0)) {
        throw const FormatException(
            'Enter a positive second moment, I, to include bending.');
      }
      if (_t != null && _t != 0 && (j == null || j <= 0)) {
        throw const FormatException(
            'Enter a positive polar second moment, J, to include torsion.');
      }

      final sigma = p / a + (i == null || i == 0 ? 0 : m * c / i);
      final tau = (j == null || j == 0) ? 0.0 : t * r / j;

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'P': '$p',
        'A': '$a',
        'M': '$m',
        'I': '${i ?? ''}',
        'c': '$c',
        'T': '$t',
        'J': '${j ?? ''}',
        'r': '$r',
        'Sy': '${_sy ?? ''}',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CombinedLoadingResultPage(
            toolId: widget.toolId,
            title: widget.title,
            sigma: sigma,
            tau: tau,
            yieldStrength: _sy,
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
