import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/pipe_flow_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/page/pump_power_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class PumpPowerPage extends StatefulWidget {
  const PumpPowerPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<PumpPowerPage> createState() => _PumpPowerPageState();
}

class _PumpPowerPageState extends State<PumpPowerPage> {
  double? _flowRate;
  double? _pressureRise;
  double? _density;

  /// A reasonable starting point for a mid-size centrifugal pump.
  double? _efficiency = 70;

  int _presetGeneration = 0;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _flowRate = double.tryParse(inputs['Q'] ?? '');
    _pressureRise = double.tryParse(inputs['dp'] ?? '');
    _density = double.tryParse(inputs['rho'] ?? '');
    _efficiency = double.tryParse(inputs['eta'] ?? '') ?? _efficiency;
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
              title: l10n.Pump_Fan_Power,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Pump_Fan_Power,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  FluidPresetButton(
                    onSelected: (fluid) => setState(() {
                      _density = fluid.densitySI;
                      _presetGeneration++;
                    }),
                  ),
                  SizedBox(height: context.tokens.space2),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: l10n.Flow_Rate_Q,
                      category: UnitCategory.volumeFlow,
                      signed: false,
                      initialSI: _flowRate,
                      onChangedSI: (v) => _flowRate = v,
                    ),
                    UnitField(
                      label: l10n.Pressure_Rise,
                      category: UnitCategory.pressure,
                      signed: false,
                      initialSI: _pressureRise,
                      onChangedSI: (v) => _pressureRise = v,
                    ),
                    UnitField(
                      key: ValueKey('rho$_presetGeneration'),
                      label: l10n.Density,
                      category: UnitCategory.density,
                      signed: false,
                      initialSI: _density,
                      onChangedSI: (v) => _density = v,
                    ),
                    UnitField(
                      label: l10n.Efficiency_Eta,
                      category: null,
                      signed: false,
                      initialSI: _efficiency,
                      onChangedSI: (v) => _efficiency = v,
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
      final flowRate = _flowRate;
      final pressureRise = _pressureRise;
      final density = _density;
      final efficiency = _efficiency;
      if (flowRate == null ||
          pressureRise == null ||
          density == null ||
          efficiency == null) {
        throw FormatException(S.of(context).Err_Enter_Pump_Inputs);
      }

      final result = PumpPowerCalculator.calculate(
        flowRate: flowRate,
        pressureRise: pressureRise,
        density: density,
        efficiency: efficiency,
      );

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'Q': '$flowRate',
        'dp': '$pressureRise',
        'rho': '$density',
        'eta': '$efficiency',
      });

      showToolResult(
        context,
        (context) => PumpPowerResultPage(
          result: result,
          flowRate: flowRate,
          pressureRise: pressureRise,
          density: density,
          efficiency: efficiency,
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
