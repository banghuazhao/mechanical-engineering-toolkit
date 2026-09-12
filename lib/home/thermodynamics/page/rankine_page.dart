import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/rankine_cycle_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/page/rankine_result_page.dart';
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

const rankineTex =
    r'\eta = \frac{w_t - w_p}{q_{in}} = \frac{(h_3 - h_4) - (h_2 - h_1)}{h_3 - h_2}';

class RankinePage extends StatefulWidget {
  const RankinePage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<RankinePage> createState() => _RankinePageState();
}

class _RankinePageState extends State<RankinePage> {
  double? _boiler;
  double? _condenser;
  double? _inlet;
  double? _etaT = 100;
  double? _etaP = 100;
  double? _massFlow;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _boiler = double.tryParse(inputs['pb'] ?? '');
    _condenser = double.tryParse(inputs['pc'] ?? '');
    _inlet = double.tryParse(inputs['T3'] ?? '');
    _etaT = double.tryParse(inputs['etaT'] ?? '') ?? _etaT;
    _etaP = double.tryParse(inputs['etaP'] ?? '') ?? _etaP;
    _massFlow = double.tryParse(inputs['m'] ?? '');
  }

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
              title: l10n.Rankine_Cycle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Rankine_Cycle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        rankineTex,
                        mathStyle: MathStyle.display,
                        textStyle: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: l10n.Boiler_Pressure,
                      category: UnitCategory.pressure,
                      signed: false,
                      initialSI: _boiler,
                      onChangedSI: (v) => _boiler = v,
                    ),
                    UnitField(
                      label: l10n.Condenser_Pressure,
                      category: UnitCategory.pressure,
                      signed: false,
                      initialSI: _condenser,
                      onChangedSI: (v) => _condenser = v,
                    ),
                    UnitField(
                      label: l10n.Turbine_Inlet_Optional,
                      category: UnitCategory.temperature,
                      initialSI: _inlet,
                      onChangedSI: (v) => _inlet = v,
                    ),
                    UnitField(
                      label: l10n.Mass_Flow_Optional,
                      category: UnitCategory.massFlow,
                      signed: false,
                      initialSI: _massFlow,
                      onChangedSI: (v) => _massFlow = v,
                    ),
                    UnitField(
                      label: l10n.Turbine_Efficiency,
                      category: null,
                      signed: false,
                      initialSI: _etaT,
                      onChangedSI: (v) => _etaT = v,
                    ),
                    UnitField(
                      label: l10n.Pump_Efficiency,
                      category: null,
                      signed: false,
                      initialSI: _etaP,
                      onChangedSI: (v) => _etaP = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  Text(
                    l10n.Rankine_Hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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
    final boiler = _boiler, condenser = _condenser;
    if (boiler == null || condenser == null) {
      _fail(l10n.Err_Rankine_Inputs);
      return;
    }
    final input = RankineInput(
      boilerPressure: boiler,
      condenserPressure: condenser,
      turbineInletC: _inlet,
      turbineEfficiency: (_etaT ?? 100) / 100,
      pumpEfficiency: (_etaP ?? 100) / 100,
      massFlow: _massFlow,
    );
    final RankineResult result;
    try {
      result = RankineCalculator.calculate(input);
    } on RankineException catch (error) {
      final system = context.read<UnitSystemPreference>().system;
      final precs = context.read<NumberPrecisionHelper>();
      _fail(switch (error.kind) {
        RankineProblem.nonPositive => l10n.Err_Gas_Positive,
        RankineProblem.condenserNotBelowBoiler => l10n.Err_Rankine_Pressures,
        RankineProblem.pressureOutOfRange => l10n.Err_Rankine_Range,
        RankineProblem.efficiencyRange => l10n.Err_Efficiency_Range,
        RankineProblem.inletNotSuperheated => l10n.Err_Rankine_Superheat(
            precs.formatSI(
                error.limitK! - 273.15, UnitCategory.temperature, system)),
        RankineProblem.supercriticalNeedsTemperature =>
          l10n.Err_Rankine_Supercritical,
        RankineProblem.outsideFormulation => l10n.Err_Steam_Range,
      });
      return;
    }

    context.read<ToolHistory>().record(widget.toolId, inputs: {
      'pb': '$boiler',
      'pc': '$condenser',
      if (_inlet != null) 'T3': '$_inlet',
      'etaT': '${_etaT ?? 100}',
      'etaP': '${_etaP ?? 100}',
      if (_massFlow != null) 'm': '$_massFlow',
    });

    showToolResult(
      context,
      (context) => RankineResultPage(
        toolId: widget.toolId,
        title: widget.title,
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
