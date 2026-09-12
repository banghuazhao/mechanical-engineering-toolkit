import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/air_standard_cycle_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/air_cycle_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// History key for the cycle, stored as the enum's name.
const airCycleKey = 'airCycle';

String airCycleLabel(BuildContext context, AirCycle cycle) {
  final l10n = S.of(context);
  return switch (cycle) {
    AirCycle.otto => l10n.Cycle_Otto,
    AirCycle.diesel => l10n.Cycle_Diesel,
    AirCycle.brayton => l10n.Cycle_Brayton,
  };
}

String airCycleTex(AirCycle cycle) => switch (cycle) {
      AirCycle.otto => r'\eta = 1 - \frac{1}{r^{\,k-1}}',
      AirCycle.diesel =>
        r'\eta = 1 - \frac{1}{r^{\,k-1}}\,\frac{r_c^{\,k} - 1}{k\,(r_c - 1)}',
      AirCycle.brayton => r'\eta = 1 - \frac{1}{r_p^{\,(k-1)/k}}',
    };

class AirCyclePage extends StatefulWidget {
  const AirCyclePage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<AirCyclePage> createState() => _AirCyclePageState();
}

class _AirCyclePageState extends State<AirCyclePage> {
  AirCycle _cycle = AirCycle.otto;
  OttoHeatSpec _heatSpec = OttoHeatSpec.heatAdded;
  double? _t1;
  double? _p1;
  // Cold-air-standard defaults: air at room temperature.
  double? _cp = 1.005;
  double? _k = 1.4;
  double? _ratio;
  double? _cutoff;
  double? _heat;
  double? _peak;
  double? _pressureRatio;
  double? _etaC = 100;
  double? _etaT = 100;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    for (final cycle in AirCycle.values) {
      if (cycle.name == inputs[airCycleKey]) _cycle = cycle;
    }
    if (inputs['given'] == 'T3') _heatSpec = OttoHeatSpec.peakTemperature;
    _t1 = double.tryParse(inputs['T1'] ?? '');
    _p1 = double.tryParse(inputs['p1'] ?? '');
    _cp = double.tryParse(inputs['cp'] ?? '') ?? _cp;
    _k = double.tryParse(inputs['k'] ?? '') ?? _k;
    _ratio = double.tryParse(inputs['r'] ?? '');
    _cutoff = double.tryParse(inputs['rc'] ?? '');
    _heat = double.tryParse(inputs['qin'] ?? '');
    _peak = double.tryParse(inputs['T3'] ?? '');
    _pressureRatio = double.tryParse(inputs['rp'] ?? '');
    _etaC = double.tryParse(inputs['etaC'] ?? '') ?? _etaC;
    _etaT = double.tryParse(inputs['etaT'] ?? '') ?? _etaT;
  }

  bool get _usesPeak =>
      _cycle == AirCycle.brayton ||
      (_cycle == AirCycle.otto && _heatSpec == OttoHeatSpec.peakTemperature);

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
              title: l10n.Air_Standard_Cycles,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Air_Standard_Cycles,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        airCycleTex(_cycle),
                        mathStyle: MathStyle.display,
                        textStyle: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  SegmentedButton<AirCycle>(
                    segments: [
                      for (final cycle in AirCycle.values)
                        ButtonSegment(
                          value: cycle,
                          label: Text(airCycleLabel(context, cycle)),
                        ),
                    ],
                    selected: {_cycle},
                    onSelectionChanged: (s) => setState(() => _cycle = s.first),
                  ),
                  if (_cycle == AirCycle.otto) ...[
                    SizedBox(height: context.tokens.space3),
                    Text(l10n.Heat_Input_Spec, style: theme.textTheme.labelLarge),
                    SizedBox(height: context.tokens.space2),
                    SegmentedButton<OttoHeatSpec>(
                      segments: [
                        ButtonSegment(
                          value: OttoHeatSpec.heatAdded,
                          label: Text(l10n.Heat_Spec_Heat),
                        ),
                        ButtonSegment(
                          value: OttoHeatSpec.peakTemperature,
                          label: Text(l10n.Heat_Spec_Peak),
                        ),
                      ],
                      selected: {_heatSpec},
                      onSelectionChanged: (s) =>
                          setState(() => _heatSpec = s.first),
                    ),
                  ],
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: l10n.Inlet_Temperature_T1,
                      category: UnitCategory.temperature,
                      initialSI: _t1,
                      onChangedSI: (v) => _t1 = v,
                    ),
                    UnitField(
                      label: l10n.Inlet_Pressure_P1,
                      category: UnitCategory.pressure,
                      signed: false,
                      initialSI: _p1,
                      onChangedSI: (v) => _p1 = v,
                    ),
                    if (_cycle == AirCycle.brayton)
                      UnitField(
                        key: const ValueKey('rp'),
                        label: l10n.Pressure_Ratio_Rp,
                        category: null,
                        signed: false,
                        initialSI: _pressureRatio,
                        onChangedSI: (v) => _pressureRatio = v,
                      )
                    else
                      UnitField(
                        key: const ValueKey('r'),
                        label: l10n.Compression_Ratio_R,
                        category: null,
                        signed: false,
                        initialSI: _ratio,
                        onChangedSI: (v) => _ratio = v,
                      ),
                    if (_cycle == AirCycle.diesel)
                      UnitField(
                        key: const ValueKey('rc'),
                        label: l10n.Cutoff_Ratio_Rc,
                        category: null,
                        signed: false,
                        initialSI: _cutoff,
                        onChangedSI: (v) => _cutoff = v,
                      ),
                    if (_cycle == AirCycle.otto && !_usesPeak)
                      UnitField(
                        key: const ValueKey('qin'),
                        label: l10n.Heat_Added_Qin,
                        category: UnitCategory.specificEnergy,
                        signed: false,
                        initialSI: _heat,
                        onChangedSI: (v) => _heat = v,
                      ),
                    if (_usesPeak)
                      UnitField(
                        key: const ValueKey('T3'),
                        label: _cycle == AirCycle.brayton
                            ? l10n.Turbine_Inlet_T3
                            : l10n.Peak_Temperature_T3,
                        category: UnitCategory.temperature,
                        initialSI: _peak,
                        onChangedSI: (v) => _peak = v,
                      ),
                    if (_cycle == AirCycle.brayton) ...[
                      UnitField(
                        key: const ValueKey('etaC'),
                        label: l10n.Compressor_Efficiency,
                        category: null,
                        signed: false,
                        initialSI: _etaC,
                        onChangedSI: (v) => _etaC = v,
                      ),
                      UnitField(
                        key: const ValueKey('etaT'),
                        label: l10n.Turbine_Efficiency,
                        category: null,
                        signed: false,
                        initialSI: _etaT,
                        onChangedSI: (v) => _etaT = v,
                      ),
                    ],
                    UnitField(
                      key: const ValueKey('cp'),
                      label: l10n.Specific_Heat_Cp,
                      category: UnitCategory.specificEntropy,
                      signed: false,
                      initialSI: _cp,
                      onChangedSI: (v) => _cp = v,
                    ),
                    UnitField(
                      key: const ValueKey('k'),
                      label: l10n.Specific_Heat_Ratio_K,
                      category: null,
                      signed: false,
                      initialSI: _k,
                      onChangedSI: (v) => _k = v,
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
    final l10n = S.of(context);
    final t1 = _t1, p1 = _p1, cp = _cp, k = _k;
    if (t1 == null || p1 == null || cp == null || k == null) {
      _fail(l10n.Err_Cycle_Inputs);
      return;
    }
    final input = AirCycleInput(
      cycle: _cycle,
      t1C: t1,
      p1: p1,
      cp: cp,
      k: k,
      compressionRatio: _ratio,
      cutoffRatio: _cutoff,
      ottoHeatSpec: _heatSpec,
      heatAdded: _heat,
      peakTemperatureC: _peak,
      pressureRatio: _pressureRatio,
      compressorEfficiency: (_etaC ?? 100) / 100,
      turbineEfficiency: (_etaT ?? 100) / 100,
    );
    final AirCycleResult result;
    try {
      result = AirCycleCalculator.calculate(input);
    } on AirCycleException catch (error) {
      final system = context.read<UnitSystemPreference>().system;
      final precs = context.read<NumberPrecisionHelper>();
      _fail(switch (error.kind) {
        AirCycleProblem.missingInput => l10n.Err_Cycle_Inputs,
        AirCycleProblem.nonPositive => l10n.Err_Cycle_Positive,
        AirCycleProblem.belowAbsoluteZero => l10n.Err_Absolute_Zero,
        AirCycleProblem.kNotAboveOne => l10n.Err_Cycle_K,
        AirCycleProblem.ratioNotAboveOne => l10n.Err_Cycle_Ratio,
        AirCycleProblem.cutoffNotBelowCompression => l10n.Err_Cycle_Cutoff,
        AirCycleProblem.efficiencyRange => l10n.Err_Efficiency_Range,
        AirCycleProblem.peakBelowCompression => l10n.Err_Cycle_Peak(
            precs.formatSI(
                error.limitK! - 273.15, UnitCategory.temperature, system)),
      });
      return;
    }

    context.read<ToolHistory>().record(widget.toolId, inputs: {
      airCycleKey: _cycle.name,
      'T1': '$t1',
      'p1': '$p1',
      'cp': '$cp',
      'k': '$k',
      if (_cycle == AirCycle.otto)
        'given': _heatSpec == OttoHeatSpec.heatAdded ? 'qin' : 'T3',
      if (_cycle != AirCycle.brayton && _ratio != null) 'r': '$_ratio',
      if (_cycle == AirCycle.diesel && _cutoff != null) 'rc': '$_cutoff',
      if (_cycle == AirCycle.otto && !_usesPeak && _heat != null)
        'qin': '$_heat',
      if (_usesPeak && _peak != null) 'T3': '$_peak',
      if (_cycle == AirCycle.brayton) ...{
        if (_pressureRatio != null) 'rp': '$_pressureRatio',
        'etaC': '${_etaC ?? 100}',
        'etaT': '${_etaT ?? 100}',
      },
    });

    showToolResult(
      context,
      (context) => AirCycleResultPage(
        toolId: widget.toolId,
        title: widget.title,
        input: input,
        result: result,
      ),
    );
  }

  void _fail(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
