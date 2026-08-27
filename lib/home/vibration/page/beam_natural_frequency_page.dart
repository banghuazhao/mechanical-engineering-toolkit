import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/model/beam_natural_frequency_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/page/beam_natural_frequency_result_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/standard_section_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// The end condition's display name in the active locale. Kept here rather
/// than on the enum so the model stays free of hard-coded English.
String beamEndConditionLabel(BuildContext context, BeamEndCondition condition) {
  final l10n = S.of(context);
  return switch (condition) {
    BeamEndCondition.simplySupported => l10n.Beam_Simply_Supported,
    BeamEndCondition.cantilever => l10n.Beam_Cantilever,
    BeamEndCondition.fixedFixed => l10n.Beam_Fixed_Fixed,
    BeamEndCondition.fixedPinned => l10n.Beam_Fixed_Pinned,
    BeamEndCondition.freeFree => l10n.Beam_Free_Free,
  };
}

class BeamNaturalFrequencyPage extends StatefulWidget {
  const BeamNaturalFrequencyPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<BeamNaturalFrequencyPage> createState() =>
      _BeamNaturalFrequencyPageState();
}

class _BeamNaturalFrequencyPageState extends State<BeamNaturalFrequencyPage> {
  BeamEndCondition _endCondition = BeamEndCondition.simplySupported;
  double? _e;
  double? _i;
  double? _a;
  double? _length;
  double? _density;

  /// Bumped whenever a preset overwrites a field, to re-key the affected
  /// [UnitField]s so they pick the new value up.
  int _presetGeneration = 0;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _endCondition = BeamEndCondition.values.firstWhere(
      (c) => c.name == inputs['End Condition'],
      orElse: () => _endCondition,
    );
    _e = double.tryParse(inputs['E'] ?? '');
    _i = double.tryParse(inputs['I'] ?? '');
    _a = double.tryParse(inputs['A'] ?? '');
    _length = double.tryParse(inputs['L'] ?? '');
    _density = double.tryParse(inputs['rho'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final l10n = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ToolHelpButton(toolId: widget.toolId, toolTitle: widget.title),
        ],
      ),
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
              title: l10n.Beam_Natural_Frequency,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Beam_Natural_Frequency,
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
                        r'''f_n = \frac{(\beta_n L)^2}{2\pi L^2}\sqrt{\frac{EI}{\rho A}}''',
                        mathStyle: MathStyle.display,
                        textStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  DropdownButtonFormField<BeamEndCondition>(
                    initialValue: _endCondition,
                    // Option labels are kept short enough to fit one line
                    // in every locale; isExpanded bounds the row to the field
                    // so a long translation clips quietly rather than
                    // overflowing the card.
                    isExpanded: true,
                    decoration:
                        InputDecoration(labelText: l10n.End_Condition),
                    items: [
                      for (final condition in BeamEndCondition.values)
                        DropdownMenuItem(
                          value: condition,
                          child: Text(
                              beamEndConditionLabel(context, condition)),
                        ),
                    ],
                    onChanged: (c) => setState(() => _endCondition = c!),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      key: ValueKey('E$_presetGeneration'),
                      label: l10n.Elastic_Modulus_E,
                      category: UnitCategory.modulus,
                      signed: false,
                      initialSI: _e,
                      onChangedSI: (v) => _e = v,
                    ),
                    UnitField(
                      key: ValueKey('I$_presetGeneration'),
                      label: l10n.Second_Moment_I,
                      category: UnitCategory.momentOfInertia,
                      signed: false,
                      initialSI: _i,
                      onChangedSI: (v) => _i = v,
                    ),
                    UnitField(
                      key: ValueKey('A$_presetGeneration'),
                      label: l10n.Area_A,
                      category: UnitCategory.area,
                      signed: false,
                      initialSI: _a,
                      onChangedSI: (v) => _a = v,
                    ),
                    UnitField(
                      label: l10n.Beam_Length_L,
                      category: UnitCategory.span,
                      signed: false,
                      initialSI: _length,
                      onChangedSI: (v) => _length = v,
                    ),
                    UnitField(
                      key: ValueKey('rho$_presetGeneration'),
                      label: l10n.Density,
                      category: UnitCategory.density,
                      signed: false,
                      initialSI: _density,
                      onChangedSI: (v) => _density = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.elasticModulusSI != null) {
                        _e = preset.elasticModulusSI;
                      }
                      if (preset.densitySI != null) {
                        _density = preset.densitySI;
                      }
                      _presetGeneration++;
                    }),
                  ),
                  StandardSectionButton(
                    // The published A and Ix go straight across: both are
                    // needed here, and the table values already include the
                    // root fillets a dimensions-only calculation misses.
                    onSelected: (section) => setState(() {
                      _i = section.ix;
                      _a = section.area;
                      _presetGeneration++;
                    }),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Text(
                    l10n.Beam_Frequency_Footnote,
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
      final e = _e;
      final i = _i;
      final a = _a;
      final length = _length;
      final density = _density;
      if (e == null ||
          i == null ||
          a == null ||
          length == null ||
          density == null) {
        throw FormatException(l10n.Err_Enter_Beam_Frequency_Inputs);
      }
      if (e <= 0 || i <= 0 || a <= 0 || length <= 0 || density <= 0) {
        throw FormatException(l10n.Err_Values_Positive);
      }

      final result = BeamNaturalFrequencyCalculator.calculate(
        modulusGPa: e,
        momentOfInertiaMm4: i,
        areaMm2: a,
        lengthM: length,
        densityKgM3: density,
        endCondition: _endCondition,
      );

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'End Condition': _endCondition.name,
        'E': '$e',
        'I': '$i',
        'A': '$a',
        'L': '$length',
        'rho': '$density',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BeamNaturalFrequencyResultPage(
            result: result,
            endCondition: _endCondition,
            e: e,
            i: i,
            a: a,
            length: length,
            density: density,
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
