import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/pipe_flow_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/page/reynolds_number_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/pipe_size_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class ReynoldsNumberPage extends StatefulWidget {
  const ReynoldsNumberPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<ReynoldsNumberPage> createState() => _ReynoldsNumberPageState();
}

class _ReynoldsNumberPageState extends State<ReynoldsNumberPage> {
  double? _diameter;
  double? _velocity;
  double? _flowRate;
  double? _density;
  double? _viscosity;

  /// Bumped whenever a preset overwrites a field, so the affected
  /// [UnitField]s rebuild with their new values rather than keeping the text
  /// the user last typed. Shared by the fluid and pipe pickers: they write to
  /// different fields, and rebuilding all of them costs nothing.
  int _presetGeneration = 0;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _diameter = double.tryParse(inputs['D'] ?? '');
    _velocity = double.tryParse(inputs['V'] ?? '');
    _flowRate = double.tryParse(inputs['Q'] ?? '');
    _density = double.tryParse(inputs['rho'] ?? '');
    _viscosity = double.tryParse(inputs['mu'] ?? '');
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
              title: l10n.Reynolds_Number,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Reynolds_Number,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  FluidPresetButton(
                    onSelected: (fluid) => setState(() {
                      _density = fluid.densitySI;
                      _viscosity = fluid.viscositySI;
                      _presetGeneration++;
                    }),
                  ),
                  PipeSizeButton(
                    // The bore, not the size in the pipe's name: NPS 2 pipe
                    // runs 52.5 mm inside at Sch 40 and 49.2 mm at Sch 80.
                    onSelected: (pipe) => setState(() {
                      _diameter = pipe.insideDiameter;
                      _presetGeneration++;
                    }),
                  ),
                  SizedBox(height: context.tokens.space2),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      key: ValueKey('D$_presetGeneration'),
                      label: l10n.Inside_Diameter_D,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _diameter,
                      onChangedSI: (v) => _diameter = v,
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
                      key: ValueKey('mu$_presetGeneration'),
                      label: l10n.Dynamic_Viscosity,
                      category: UnitCategory.dynamicViscosity,
                      signed: false,
                      initialSI: _viscosity,
                      onChangedSI: (v) => _viscosity = v,
                    ),
                    UnitField(
                      label: l10n.Flow_Velocity_V,
                      category: UnitCategory.velocity,
                      signed: false,
                      initialSI: _velocity,
                      onChangedSI: (v) => _velocity = v,
                    ),
                    UnitField(
                      label: l10n.Flow_Rate_Q,
                      category: UnitCategory.volumeFlow,
                      signed: false,
                      initialSI: _flowRate,
                      onChangedSI: (v) => _flowRate = v,
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
      final diameter = _diameter;
      final density = _density;
      final viscosity = _viscosity;
      // Velocity wins when both are filled: it is the more direct statement of
      // the flow, and recomputing the rate from it keeps the pair consistent.
      final velocity = _velocity;
      final flowRate = _flowRate;
      if (diameter == null ||
          density == null ||
          viscosity == null ||
          (velocity == null && flowRate == null)) {
        throw FormatException(S.of(context).Err_Enter_Reynolds_Inputs);
      }

      final result = ReynoldsCalculator.calculate(
        diameter: diameter,
        density: density,
        viscosity: viscosity,
        velocity: velocity,
        flowRate: velocity == null ? flowRate : null,
      );

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'D': '$diameter',
        if (velocity != null) 'V': '$velocity',
        if (velocity == null && flowRate != null) 'Q': '$flowRate',
        'rho': '$density',
        'mu': '$viscosity',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReynoldsNumberResultPage(
            result: result,
            diameter: diameter,
            density: density,
            viscosity: viscosity,
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
