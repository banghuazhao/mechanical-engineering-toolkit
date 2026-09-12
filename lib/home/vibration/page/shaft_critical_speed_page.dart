import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/model/shaft_critical_speed_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/page/shaft_critical_speed_result_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// The support arrangement's display name in the active locale.
String shaftSupportLabel(BuildContext context, ShaftSupport support) {
  final l10n = S.of(context);
  return switch (support) {
    ShaftSupport.simplySupported => l10n.Shaft_Between_Bearings,
    ShaftSupport.fixedFixed => l10n.Shaft_Both_Ends_Fixed,
    ShaftSupport.cantilever => l10n.Shaft_Overhung,
  };
}

class ShaftCriticalSpeedPage extends StatefulWidget {
  const ShaftCriticalSpeedPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<ShaftCriticalSpeedPage> createState() => _ShaftCriticalSpeedPageState();
}

class _ShaftCriticalSpeedPageState extends State<ShaftCriticalSpeedPage> {
  ShaftSupport _support = ShaftSupport.simplySupported;
  double? _e;
  double? _diameter;
  double? _span;
  double? _rotorMass;
  double? _rotorPosition;
  double? _density;
  bool _includeShaftMass = true;

  int _presetGeneration = 0;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _support = ShaftSupport.values.firstWhere(
      (s) => s.name == inputs['Support'],
      orElse: () => _support,
    );
    _e = double.tryParse(inputs['E'] ?? '');
    _diameter = double.tryParse(inputs['d'] ?? '');
    _span = double.tryParse(inputs['L'] ?? '');
    _rotorMass = double.tryParse(inputs['m'] ?? '');
    _rotorPosition = double.tryParse(inputs['a'] ?? '');
    _density = double.tryParse(inputs['rho'] ?? '');
    _includeShaftMass = inputs['ShaftMass'] != 'off';
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
      floatingActionButton: CalculateButton(onPressed: _calculate),
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
              title: l10n.Shaft_Critical_Speed,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Shaft_Critical_Speed,
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
                        r'''\begin{aligned}\omega_r&=\sqrt{\frac{k}{m}}\\\frac{1}{\omega_c^{2}}&=\frac{1}{\omega_r^{2}}+\frac{1}{\omega_s^{2}}\\N_c&=\frac{60\,\omega_c}{2\pi}\end{aligned}''',
                        mathStyle: MathStyle.display,
                        textStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  DropdownButtonFormField<ShaftSupport>(
                    initialValue: _support,
                    // Option labels are kept short enough to fit one line
                    // in every locale; isExpanded bounds the row to the field
                    // so a long translation clips quietly rather than
                    // overflowing the card.
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.Support),
                    items: [
                      for (final support in ShaftSupport.values)
                        DropdownMenuItem(
                          value: support,
                          child: Text(shaftSupportLabel(context, support)),
                        ),
                    ],
                    onChanged: (s) => setState(() => _support = s!),
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
                      label: l10n.Shaft_Diameter_D,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _diameter,
                      onChangedSI: (v) => _diameter = v,
                    ),
                    UnitField(
                      label: l10n.Span_L,
                      category: UnitCategory.span,
                      signed: false,
                      initialSI: _span,
                      onChangedSI: (v) => _span = v,
                    ),
                    UnitField(
                      label: l10n.Rotor_Mass_M,
                      category: UnitCategory.mass,
                      signed: false,
                      initialSI: _rotorMass,
                      onChangedSI: (v) => _rotorMass = v,
                    ),
                    UnitField(
                      label: l10n.Rotor_Position_A,
                      category: UnitCategory.span,
                      signed: false,
                      initialSI: _rotorPosition,
                      onChangedSI: (v) => _rotorPosition = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.Include_Shaft_Mass),
                    value: _includeShaftMass,
                    onChanged: (on) =>
                        setState(() => _includeShaftMass = on),
                  ),
                  if (_includeShaftMass) ...[
                    SizedBox(height: context.tokens.space2),
                    AdaptiveFieldGrid(children: [
                      UnitField(
                        key: ValueKey('rho$_presetGeneration'),
                        label: l10n.Density,
                        category: UnitCategory.density,
                        signed: false,
                        initialSI: _density,
                        onChangedSI: (v) => _density = v,
                      ),
                    ]),
                  ],
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
                  SizedBox(height: context.tokens.space3),
                  Text(
                    l10n.Critical_Speed_Footnote,
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
      final diameter = _diameter;
      final span = _span;
      final mass = _rotorMass;
      final position = _rotorPosition;
      // Only asked for, and only required, when the shaft's mass is in play.
      final density = _includeShaftMass ? _density : null;
      if (e == null ||
          diameter == null ||
          span == null ||
          mass == null ||
          position == null ||
          (_includeShaftMass && density == null)) {
        throw FormatException(l10n.Err_Enter_Critical_Speed_Inputs);
      }
      if (e <= 0 ||
          diameter <= 0 ||
          span <= 0 ||
          mass <= 0 ||
          (density != null && density <= 0)) {
        throw FormatException(l10n.Err_Values_Positive);
      }
      if (position <= 0 ||
          position > span ||
          (position == span && !_support.allowsRotorAtEnd)) {
        throw FormatException(l10n.Err_Rotor_Position_Range);
      }

      final result = ShaftCriticalSpeedCalculator.calculate(
        modulusGPa: e,
        diameterMm: diameter,
        spanM: span,
        rotorMassKg: mass,
        rotorPositionM: position,
        support: _support,
        densityKgM3: density,
      );

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'Support': _support.name,
        'E': '$e',
        'd': '$diameter',
        'L': '$span',
        'm': '$mass',
        'a': '$position',
        'ShaftMass': _includeShaftMass ? 'on' : 'off',
        if (density != null) 'rho': '$density',
      });

      showToolResult(
        context,
        (context) => ShaftCriticalSpeedResultPage(
          result: result,
          support: _support,
          e: e,
          diameter: diameter,
          span: span,
          rotorMass: mass,
          rotorPosition: position,
          density: density,
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
