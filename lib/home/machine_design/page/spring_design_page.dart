import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/spring_design_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/page/spring_design_result_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class SpringDesignPage extends StatefulWidget {
  const SpringDesignPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<SpringDesignPage> createState() => _SpringDesignPageState();
}

class _SpringDesignPageState extends State<SpringDesignPage> {
  double? _d;
  double? _coilD;
  double? _na;
  double? _g;
  double? _f;
  double? _density;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _d = double.tryParse(inputs['d'] ?? '');
    _coilD = double.tryParse(inputs['D'] ?? '');
    _na = double.tryParse(inputs['Na'] ?? '');
    _g = double.tryParse(inputs['G'] ?? '');
    _f = double.tryParse(inputs['F'] ?? '');
    _density = double.tryParse(inputs['rho'] ?? '');
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
              title: 'Helical Compression Spring',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spring index, Wahl stress-correction factor, rate, and an estimated fundamental natural frequency (both ends fixed) for a round-wire helical compression spring.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''k = \frac{Gd^4}{8D^3N_a}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Wire diameter, d',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _d,
                      onChangedSI: (v) => _d = v,
                    ),
                    UnitField(
                      label: 'Mean coil diameter, D',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _coilD,
                      onChangedSI: (v) => _coilD = v,
                    ),
                    TextFormField(
                      initialValue: _na?.toString(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Active coils, Na'),
                      onChanged: (v) => _na = double.tryParse(v),
                    ),
                    UnitField(
                      label: 'Shear modulus, G',
                      category: UnitCategory.modulus,
                      signed: false,
                      initialSI: _g,
                      onChangedSI: (v) => _g = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.shearModulusSI != null) {
                        _g = preset.shearModulusSI;
                      }
                      if (preset.densitySI != null) {
                        _density = preset.densitySI;
                      }
                    }),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Text(
                    'Optional — for operating deflection/stress and frequency',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  SizedBox(height: context.tokens.space2),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Operating force, F',
                      category: UnitCategory.force,
                      signed: false,
                      initialSI: _f,
                      onChangedSI: (v) => _f = v,
                    ),
                    UnitField(
                      label: 'Material density (default steel)',
                      category: UnitCategory.density,
                      signed: false,
                      initialSI: _density,
                      onChangedSI: (v) => _density = v,
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
      final d = _d;
      final coilD = _coilD;
      final na = _na;
      final g = _g;
      if (d == null || coilD == null || na == null || g == null) {
        throw const FormatException('Enter d, D, Na, and G.');
      }

      final result = SpringDesignCalculator.calculate(SpringDesignInput(
        wireDiameter: d,
        coilDiameter: coilD,
        activeCoils: na,
        shearModulusGPa: g,
        force: _f,
        densityKgM3: _density ?? 7850,
      ));

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'd': '$d',
        'D': '$coilD',
        'Na': '$na',
        'G': '$g',
        'F': _f == null ? '' : '$_f',
        'rho': _density == null ? '' : '$_density',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpringDesignResultPage(
            result: result,
            d: d,
            coilD: coilD,
            na: na,
            g: g,
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
