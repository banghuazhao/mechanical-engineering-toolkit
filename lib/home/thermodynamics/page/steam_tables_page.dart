import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/steam_tables_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/steam_tables_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// The history key the lookup mode is stored under, as the enum's name so it
/// survives a translation change. [displayInputs] turns it back into words.
const steamLookupKey = 'steamLookup';

String steamLookupLabel(BuildContext context, SteamLookup lookup) {
  final l10n = S.of(context);
  return switch (lookup) {
    SteamLookup.saturatedByTemperature => l10n.Steam_Lookup_Sat_T,
    SteamLookup.saturatedByPressure => l10n.Steam_Lookup_Sat_P,
    SteamLookup.pressureTemperature => l10n.Steam_Lookup_PT,
    SteamLookup.pressureQuality => l10n.Steam_Lookup_PX,
    SteamLookup.pressureEnthalpy => l10n.Steam_Lookup_PH,
    SteamLookup.pressureEntropy => l10n.Steam_Lookup_PS,
  };
}

String steamProblemMessage(BuildContext context, SteamInputProblem problem) {
  final l10n = S.of(context);
  return switch (problem) {
    SteamInputProblem.missingInput => l10n.Err_Steam_Missing,
    SteamInputProblem.temperatureOutOfRange => l10n.Err_Steam_Temperature_Range,
    SteamInputProblem.pressureOutOfRange => l10n.Err_Steam_Pressure_Range,
    SteamInputProblem.aboveCriticalForSaturation =>
      l10n.Err_Steam_Above_Critical,
    SteamInputProblem.qualityOutOfRange => l10n.Err_Steam_Quality,
    SteamInputProblem.outsideFormulation => l10n.Err_Steam_Range,
  };
}

class SteamTablesPage extends StatefulWidget {
  const SteamTablesPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<SteamTablesPage> createState() => _SteamTablesPageState();
}

class _SteamTablesPageState extends State<SteamTablesPage> {
  SteamLookup _lookup = SteamLookup.pressureTemperature;
  double? _temperature;
  double? _pressure;
  double? _quality;
  double? _enthalpy;
  double? _entropy;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    for (final lookup in SteamLookup.values) {
      if (lookup.name == inputs[steamLookupKey]) _lookup = lookup;
    }
    _temperature = double.tryParse(inputs['T'] ?? '');
    _pressure = double.tryParse(inputs['p'] ?? '');
    _quality = double.tryParse(inputs['x'] ?? '');
    _enthalpy = double.tryParse(inputs['h'] ?? '');
    _entropy = double.tryParse(inputs['s'] ?? '');
  }

  bool get _needsTemperature =>
      _lookup == SteamLookup.saturatedByTemperature ||
      _lookup == SteamLookup.pressureTemperature;

  bool get _needsPressure => _lookup != SteamLookup.saturatedByTemperature;

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final l10n = S.of(context);
    final theme = Theme.of(context);
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
              title: l10n.Steam_Tables,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Steam_Tables,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        r'\frac{g(p,T)}{RT} = \gamma(\pi,\tau), \qquad '
                        r'y = y_f + x\,(y_g - y_f)',
                        mathStyle: MathStyle.display,
                        textStyle: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  DropdownButtonFormField<SteamLookup>(
                    initialValue: _lookup,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.Steam_Lookup),
                    items: [
                      for (final lookup in SteamLookup.values)
                        DropdownMenuItem(
                          value: lookup,
                          child: Text(steamLookupLabel(context, lookup)),
                        ),
                    ],
                    onChanged: (value) => setState(() => _lookup = value!),
                  ),
                  SizedBox(height: context.tokens.space3),
                  AdaptiveFieldGrid(children: [
                    if (_needsPressure)
                      UnitField(
                        key: const ValueKey('steam-p'),
                        label: l10n.Pressure_P,
                        category: UnitCategory.pressure,
                        signed: false,
                        initialSI: _pressure,
                        onChangedSI: (v) => _pressure = v,
                      ),
                    if (_needsTemperature)
                      UnitField(
                        key: const ValueKey('steam-T'),
                        label: l10n.Temperature_T,
                        category: UnitCategory.temperature,
                        initialSI: _temperature,
                        onChangedSI: (v) => _temperature = v,
                      ),
                    if (_lookup == SteamLookup.pressureQuality)
                      UnitField(
                        key: const ValueKey('steam-x'),
                        label: l10n.Quality_X,
                        category: null,
                        signed: false,
                        initialSI: _quality,
                        onChangedSI: (v) => _quality = v,
                      ),
                    if (_lookup == SteamLookup.pressureEnthalpy)
                      UnitField(
                        key: const ValueKey('steam-h'),
                        label: l10n.Specific_Enthalpy_H,
                        category: UnitCategory.specificEnergy,
                        initialSI: _enthalpy,
                        onChangedSI: (v) => _enthalpy = v,
                      ),
                    if (_lookup == SteamLookup.pressureEntropy)
                      UnitField(
                        key: const ValueKey('steam-s'),
                        label: l10n.Specific_Entropy_S,
                        category: UnitCategory.specificEntropy,
                        initialSI: _entropy,
                        onChangedSI: (v) => _entropy = v,
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
    final input = SteamTableInput(
      lookup: _lookup,
      temperatureC: _needsTemperature ? _temperature : null,
      pressureKPa: _needsPressure ? _pressure : null,
      quality: _lookup == SteamLookup.pressureQuality ? _quality : null,
      enthalpy: _lookup == SteamLookup.pressureEnthalpy ? _enthalpy : null,
      entropy: _lookup == SteamLookup.pressureEntropy ? _entropy : null,
    );
    final SteamTableResult result;
    try {
      result = SteamTablesCalculator.calculate(input);
    } on SteamInputException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(steamProblemMessage(context, error.kind))),
        );
      return;
    }

    context.read<ToolHistory>().record(widget.toolId, inputs: {
      steamLookupKey: _lookup.name,
      if (input.temperatureC != null) 'T': '${input.temperatureC}',
      if (input.pressureKPa != null) 'p': '${input.pressureKPa}',
      if (input.quality != null) 'x': '${input.quality}',
      if (input.enthalpy != null) 'h': '${input.enthalpy}',
      if (input.entropy != null) 's': '${input.entropy}',
    });

    showToolResult(
      context,
      (context) => SteamTablesResultPage(
        toolId: widget.toolId,
        title: widget.title,
        result: result,
      ),
    );
  }
}
