import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/model/torsional_frequency_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/page/torsional_frequency_result_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// The rotor arrangement's display name in the active locale.
String torsionalSystemLabel(BuildContext context, TorsionalSystem system) {
  final l10n = S.of(context);
  return switch (system) {
    TorsionalSystem.singleRotor => l10n.Torsional_Single_Rotor,
    TorsionalSystem.twoRotor => l10n.Torsional_Two_Rotor,
  };
}

class TorsionalFrequencyPage extends StatefulWidget {
  const TorsionalFrequencyPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<TorsionalFrequencyPage> createState() => _TorsionalFrequencyPageState();
}

class _TorsionalFrequencyPageState extends State<TorsionalFrequencyPage> {
  TorsionalSystem _system = TorsionalSystem.singleRotor;
  double? _g;
  double? _diameter;
  double? _length;
  double? _j1;
  double? _j2;

  int _presetGeneration = 0;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _system = TorsionalSystem.values.firstWhere(
      (s) => s.name == inputs['System'],
      orElse: () => _system,
    );
    _g = double.tryParse(inputs['G'] ?? '');
    _diameter = double.tryParse(inputs['d'] ?? '');
    _length = double.tryParse(inputs['L'] ?? '');
    _j1 = double.tryParse(inputs['J1'] ?? '');
    _j2 = double.tryParse(inputs['J2'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final l10n = S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _calculate,
        icon: const Icon(Icons.analytics_rounded),
        label: Text(l10n.Calculate),
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
              title: l10n.Torsional_Natural_Frequency,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Torsional_Natural_Frequency,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    // Wider than a phone once it is a fraction under a root,
                    // so it scrolls rather than overflowing the card.
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        r'''\begin{aligned}k_t&=\frac{GJ_p}{L}\\\omega_n&=\sqrt{\frac{k_t}{J_\text{eff}}}\end{aligned}''',
                        mathStyle: MathStyle.display,
                        textStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  SegmentedButton<TorsionalSystem>(
                    segments: [
                      for (final system in TorsionalSystem.values)
                        ButtonSegment(
                          value: system,
                          label: Text(torsionalSystemLabel(context, system)),
                        ),
                    ],
                    selected: {_system},
                    onSelectionChanged: (s) =>
                        setState(() => _system = s.first),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      key: ValueKey('G$_presetGeneration'),
                      label: l10n.Shear_Modulus_G,
                      category: UnitCategory.modulus,
                      signed: false,
                      initialSI: _g,
                      onChangedSI: (v) => _g = v,
                    ),
                    UnitField(
                      label: l10n.Shaft_Diameter_D,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _diameter,
                      onChangedSI: (v) => _diameter = v,
                    ),
                    UnitField(
                      label: l10n.Shaft_Length_L,
                      category: UnitCategory.span,
                      signed: false,
                      initialSI: _length,
                      onChangedSI: (v) => _length = v,
                    ),
                    UnitField(
                      label: l10n.Rotor_Inertia_J1,
                      category: UnitCategory.massMomentOfInertia,
                      signed: false,
                      initialSI: _j1,
                      onChangedSI: (v) => _j1 = v,
                    ),
                    if (_system == TorsionalSystem.twoRotor)
                      UnitField(
                        label: l10n.Rotor_Inertia_J2,
                        category: UnitCategory.massMomentOfInertia,
                        signed: false,
                        initialSI: _j2,
                        onChangedSI: (v) => _j2 = v,
                      ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.shearModulusSI != null) {
                        _g = preset.shearModulusSI;
                        _presetGeneration++;
                      }
                    }),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Text(
                    l10n.Torsional_Footnote,
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
    final l10n = S.of(context);
    try {
      final g = _g;
      final diameter = _diameter;
      final length = _length;
      final j1 = _j1;
      final j2 = _system == TorsionalSystem.twoRotor ? _j2 : null;
      if (g == null || diameter == null || length == null || j1 == null) {
        throw FormatException(l10n.Err_Enter_Torsional_Inputs);
      }
      if (_system == TorsionalSystem.twoRotor && j2 == null) {
        throw FormatException(l10n.Err_Second_Rotor_Inertia);
      }
      if (g <= 0 ||
          diameter <= 0 ||
          length <= 0 ||
          j1 <= 0 ||
          (j2 != null && j2 <= 0)) {
        throw FormatException(l10n.Err_Values_Positive);
      }

      final result = TorsionalFrequencyCalculator.calculate(
        shearModulusGPa: g,
        diameterMm: diameter,
        lengthM: length,
        firstInertiaKgM2: j1,
        secondInertiaKgM2: j2,
        system: _system,
      );

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'System': _system.name,
        'G': '$g',
        'd': '$diameter',
        'L': '$length',
        'J1': '$j1',
        if (j2 != null) 'J2': '$j2',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TorsionalFrequencyResultPage(
            result: result,
            system: _system,
            g: g,
            diameter: diameter,
            length: length,
            j1: j1,
            j2: j2,
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
