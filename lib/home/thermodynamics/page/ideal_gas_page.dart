import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/ideal_gas_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/ideal_gas_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// History key for the process, stored as the enum's name.
const gasProcessKey = 'gasProcess';

String gasProcessLabel(BuildContext context, GasProcess process) {
  final l10n = S.of(context);
  return switch (process) {
    GasProcess.isothermal => l10n.Process_Isothermal,
    GasProcess.isobaric => l10n.Process_Isobaric,
    GasProcess.isochoric => l10n.Process_Isochoric,
    GasProcess.isentropic => l10n.Process_Isentropic,
    GasProcess.polytropic => l10n.Process_Polytropic,
  };
}

String gasProcessTex(GasProcess process) => switch (process) {
      GasProcess.isothermal =>
        r'pv = \text{const}, \quad W = mRT_1\ln\frac{p_1}{p_2}, \quad Q = W',
      GasProcess.isobaric =>
        r'W = mR\,(T_2 - T_1), \quad Q = mc_p\,(T_2 - T_1)',
      GasProcess.isochoric => r'W = 0, \quad Q = mc_v\,(T_2 - T_1)',
      GasProcess.isentropic =>
        r'\frac{T_2}{T_1} = \left(\frac{p_2}{p_1}\right)^{(k-1)/k}, \quad W = mc_v\,(T_1 - T_2)',
      GasProcess.polytropic =>
        r'pv^n = \text{const}, \quad W = \frac{mR\,(T_2 - T_1)}{1 - n}',
    };

class IdealGasPage extends StatefulWidget {
  const IdealGasPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<IdealGasPage> createState() => _IdealGasPageState();
}

class _IdealGasPageState extends State<IdealGasPage> {
  // Air, the gas most coursework is about, so the page works unedited.
  double? _r = idealGases.first.gasConstant;
  double? _cp = idealGases.first.cp;
  double? _p1;
  double? _t1;
  double? _mass = 1;
  double? _p2;
  double? _t2;
  double? _n = 1.3;
  GasProcess _process = GasProcess.isentropic;
  FinalStateSpec _spec = FinalStateSpec.pressure;
  int _presetGeneration = 0;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    for (final process in GasProcess.values) {
      if (process.name == inputs[gasProcessKey]) _process = process;
    }
    _spec = inputs['given'] == 'T2'
        ? FinalStateSpec.temperature
        : FinalStateSpec.pressure;
    _r = double.tryParse(inputs['R'] ?? '') ?? _r;
    _cp = double.tryParse(inputs['cp'] ?? '') ?? _cp;
    _p1 = double.tryParse(inputs['p1'] ?? '');
    _t1 = double.tryParse(inputs['T1'] ?? '');
    _mass = double.tryParse(inputs['m'] ?? '') ?? _mass;
    _p2 = double.tryParse(inputs['p2'] ?? '');
    _t2 = double.tryParse(inputs['T2'] ?? '');
    _n = double.tryParse(inputs['n'] ?? '') ?? _n;
  }

  /// Which end-state field the process takes. Isothermal needs a pressure —
  /// its temperature cannot move — and isobaric a temperature, for the same
  /// reason; the rest can be driven by either.
  bool get _usesPressure => switch (_process) {
        GasProcess.isothermal => true,
        GasProcess.isobaric => false,
        _ => _spec == FinalStateSpec.pressure,
      };

  bool get _offersChoice =>
      _process != GasProcess.isothermal && _process != GasProcess.isobaric;

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
              title: l10n.Ideal_Gas_Process,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Ideal_Gas_Process,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        gasProcessTex(_process),
                        mathStyle: MathStyle.display,
                        textStyle: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  DropdownButtonFormField<GasProcess>(
                    initialValue: _process,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l10n.Process_Label),
                    items: [
                      for (final process in GasProcess.values)
                        DropdownMenuItem(
                          value: process,
                          child: Text(gasProcessLabel(context, process)),
                        ),
                    ],
                    onChanged: (value) => setState(() => _process = value!),
                  ),
                  if (_offersChoice) ...[
                    SizedBox(height: context.tokens.space3),
                    Text(l10n.Final_State_From, style: theme.textTheme.labelLarge),
                    SizedBox(height: context.tokens.space2),
                    SegmentedButton<FinalStateSpec>(
                      segments: [
                        ButtonSegment(
                          value: FinalStateSpec.pressure,
                          label: Text(l10n.Final_Pressure_P2),
                        ),
                        ButtonSegment(
                          value: FinalStateSpec.temperature,
                          label: Text(l10n.Final_Temperature_T2),
                        ),
                      ],
                      selected: {_spec},
                      onSelectionChanged: (s) => setState(() => _spec = s.first),
                    ),
                  ],
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      key: ValueKey('R$_presetGeneration'),
                      label: l10n.Gas_Constant_R,
                      category: UnitCategory.specificEntropy,
                      signed: false,
                      initialSI: _r,
                      onChangedSI: (v) => _r = v,
                    ),
                    UnitField(
                      key: ValueKey('cp$_presetGeneration'),
                      label: l10n.Specific_Heat_Cp,
                      category: UnitCategory.specificEntropy,
                      signed: false,
                      initialSI: _cp,
                      onChangedSI: (v) => _cp = v,
                    ),
                    UnitField(
                      label: l10n.Initial_Pressure_P1,
                      category: UnitCategory.pressure,
                      signed: false,
                      initialSI: _p1,
                      onChangedSI: (v) => _p1 = v,
                    ),
                    UnitField(
                      label: l10n.Initial_Temperature_T1,
                      category: UnitCategory.temperature,
                      initialSI: _t1,
                      onChangedSI: (v) => _t1 = v,
                    ),
                    UnitField(
                      label: l10n.Gas_Mass_M,
                      category: UnitCategory.mass,
                      signed: false,
                      initialSI: _mass,
                      onChangedSI: (v) => _mass = v,
                    ),
                    if (_usesPressure)
                      UnitField(
                        key: const ValueKey('p2'),
                        label: l10n.Final_Pressure_P2,
                        category: UnitCategory.pressure,
                        signed: false,
                        initialSI: _p2,
                        onChangedSI: (v) => _p2 = v,
                      )
                    else
                      UnitField(
                        key: const ValueKey('T2'),
                        label: l10n.Final_Temperature_T2,
                        category: UnitCategory.temperature,
                        initialSI: _t2,
                        onChangedSI: (v) => _t2 = v,
                      ),
                    if (_process == GasProcess.polytropic)
                      UnitField(
                        label: l10n.Polytropic_Exponent_N,
                        category: null,
                        signed: false,
                        initialSI: _n,
                        onChangedSI: (v) => _n = v,
                      ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  PresetPickerButton<IdealGas>(
                    buttonLabel: l10n.Pick_Gas,
                    sheetTitle: l10n.Gas_Presets,
                    searchHint: l10n.Search_Gases,
                    emptyLabel: l10n.No_Gases_Found,
                    icon: Icons.bubble_chart_outlined,
                    presets: idealGases,
                    nameOf: (gas) => gas.name,
                    subtitleOf: (context, gas) {
                      final system = context.read<UnitSystemPreference>().system;
                      final precs = context.read<NumberPrecisionHelper>();
                      return 'R = ${precs.formatSI(gas.gasConstant, UnitCategory.specificEntropy, system)}'
                          ' · cp = ${precs.formatSI(gas.cp, UnitCategory.specificEntropy, system)}'
                          ' · k = ${precs.formatValue(gas.k)}';
                    },
                    onSelected: (gas) => setState(() {
                      _r = gas.gasConstant;
                      _cp = gas.cp;
                      _presetGeneration++;
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
    final l10n = S.of(context);
    final r = _r, cp = _cp, p1 = _p1, t1 = _t1, mass = _mass;
    if (r == null || cp == null || p1 == null || t1 == null || mass == null) {
      _fail(l10n.Err_Gas_Inputs);
      return;
    }
    final input = IdealGasProcessInput(
      gasConstant: r,
      cp: cp,
      p1: p1,
      t1C: t1,
      mass: mass,
      process: _process,
      spec: _usesPressure ? FinalStateSpec.pressure : FinalStateSpec.temperature,
      p2: _p2,
      t2C: _t2,
      n: _n,
    );
    final IdealGasProcessResult result;
    try {
      result = IdealGasCalculator.calculate(input);
    } on IdealGasException catch (error) {
      _fail(switch (error.kind) {
        IdealGasProblem.missingInput => l10n.Err_Gas_Inputs,
        IdealGasProblem.nonPositive => l10n.Err_Gas_Positive,
        IdealGasProblem.belowAbsoluteZero => l10n.Err_Absolute_Zero,
        IdealGasProblem.cpNotAboveR => l10n.Err_Gas_Cp_R,
        IdealGasProblem.polytropicExponent => l10n.Err_Polytropic_N,
        IdealGasProblem.noChange => l10n.Err_Gas_No_Change,
      });
      return;
    }

    context.read<ToolHistory>().record(widget.toolId, inputs: {
      gasProcessKey: _process.name,
      'given': _usesPressure ? 'p2' : 'T2',
      'R': '$r',
      'cp': '$cp',
      'p1': '$p1',
      'T1': '$t1',
      'm': '$mass',
      if (_usesPressure && _p2 != null) 'p2': '$_p2',
      if (!_usesPressure && _t2 != null) 'T2': '$_t2',
      if (_process == GasProcess.polytropic && _n != null) 'n': '$_n',
    });

    showToolResult(
      context,
      (context) => IdealGasResultPage(
        toolId: widget.toolId,
        title: widget.title,
        process: _process,
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
