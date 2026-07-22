import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/bar_force_displacement_result.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BarForceDisplacementRelationPage extends StatefulWidget {
  const BarForceDisplacementRelationPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<BarForceDisplacementRelationPage> createState() =>
      _BarForceDisplacementRelationPageState();
}

class _BarForceDisplacementRelationPageState
    extends State<BarForceDisplacementRelationPage> {
  double? _p;
  double? _l;
  double? _e;
  double? _area;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _p = double.tryParse(inputs['F'] ?? '');
    _l = double.tryParse(inputs['L'] ?? '');
    _e = double.tryParse(inputs['E'] ?? '');
    _area = double.tryParse(inputs['A'] ?? '');
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
              title: 'Force-Displacement of Bar',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The displacement (δ) of a prismatic bar under a centroidal axial load is proportional to the load and length, and inversely proportional to the axial rigidity (EA).',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''\delta = \frac{FL}{EA}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Force, F',
                      category: UnitCategory.force,
                      initialSI: _p,
                      onChangedSI: (v) => _p = v,
                    ),
                    UnitField(
                      label: 'Length, L',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _l,
                      onChangedSI: (v) => _l = v,
                    ),
                    UnitField(
                      label: 'Modulus, E',
                      category: UnitCategory.modulus,
                      signed: false,
                      initialSI: _e,
                      onChangedSI: (v) => _e = v,
                    ),
                    UnitField(
                      label: 'Area, A',
                      category: UnitCategory.area,
                      signed: false,
                      initialSI: _area,
                      onChangedSI: (v) => _area = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space3),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.elasticModulusSI != null) {
                        _e = preset.elasticModulusSI;
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
      final p = _p;
      final l = _l;
      final e = _e;
      final area = _area;
      if (p == null || l == null || e == null || area == null) {
        throw const FormatException('Enter F, L, E, and A.');
      }
      if (l <= 0 || e <= 0 || area <= 0) {
        throw const FormatException(
            'Length, modulus, and area must be positive.');
      }

      // E is entered in GPa; the mm/N-based formula needs the numerically
      // equivalent MPa value (1 GPa = 1000 MPa) to keep delta in mm.
      final delta = p * l / (e * 1000 * area);

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'F': '$p',
        'L': '$l',
        'E': '$e',
        'A': '$area',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BarForceDisplacementResultPage(
            toolId: widget.toolId,
            delta: delta,
            f: p,
            l: l,
            e: e,
            a: area,
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
