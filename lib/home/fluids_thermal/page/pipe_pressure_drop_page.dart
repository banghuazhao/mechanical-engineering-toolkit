import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/pipe_flow_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/page/pipe_pressure_drop_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/pipe_size_picker.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class PipePressureDropPage extends StatefulWidget {
  const PipePressureDropPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<PipePressureDropPage> createState() => _PipePressureDropPageState();
}

class _PipePressureDropPageState extends State<PipePressureDropPage> {
  double? _diameter;
  double? _length;
  double? _flowRate;
  double? _density;
  double? _viscosity;

  /// Commercial steel, the usual default for a first pass.
  double? _roughness = 0.045;
  double? _minorLossK = 0;

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
    _length = double.tryParse(inputs['L'] ?? '');
    _flowRate = double.tryParse(inputs['Q'] ?? '');
    _density = double.tryParse(inputs['rho'] ?? '');
    _viscosity = double.tryParse(inputs['mu'] ?? '');
    _roughness = double.tryParse(inputs['eps'] ?? '') ?? _roughness;
    _minorLossK = double.tryParse(inputs['K'] ?? '') ?? _minorLossK;
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
              title: l10n.Pipe_Pressure_Drop,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Pipe_Pressure_Drop,
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
                      label: l10n.Pipe_Length_L,
                      category: UnitCategory.span,
                      signed: false,
                      initialSI: _length,
                      onChangedSI: (v) => _length = v,
                    ),
                    UnitField(
                      label: l10n.Flow_Rate_Q,
                      category: UnitCategory.volumeFlow,
                      signed: false,
                      initialSI: _flowRate,
                      onChangedSI: (v) => _flowRate = v,
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
                      label: l10n.Wall_Roughness,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _roughness,
                      onChangedSI: (v) => _roughness = v,
                    ),
                    UnitField(
                      label: l10n.Minor_Loss_K,
                      category: null,
                      signed: false,
                      initialSI: _minorLossK,
                      onChangedSI: (v) => _minorLossK = v,
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
      final length = _length;
      final flowRate = _flowRate;
      final density = _density;
      final viscosity = _viscosity;
      if (diameter == null ||
          length == null ||
          flowRate == null ||
          density == null ||
          viscosity == null) {
        throw FormatException(S.of(context).Err_Enter_Pipe_Inputs);
      }

      final input = PipeFlowInput(
        diameter: diameter,
        length: length,
        flowRate: flowRate,
        density: density,
        viscosity: viscosity,
        roughness: _roughness ?? 0,
        minorLossK: _minorLossK ?? 0,
      );
      final result = PipeFlowCalculator.calculate(input);

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'D': '$diameter',
        'L': '$length',
        'Q': '$flowRate',
        'rho': '$density',
        'mu': '$viscosity',
        'eps': '${_roughness ?? 0}',
        'K': '${_minorLossK ?? 0}',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PipePressureDropResultPage(input: input, result: result),
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
