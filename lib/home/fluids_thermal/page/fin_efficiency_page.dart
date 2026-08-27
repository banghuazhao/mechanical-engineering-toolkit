import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/heat_transfer_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/page/fin_efficiency_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class FinEfficiencyPage extends StatefulWidget {
  const FinEfficiencyPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<FinEfficiencyPage> createState() => _FinEfficiencyPageState();
}

class _FinEfficiencyPageState extends State<FinEfficiencyPage> {
  double? _length;
  double? _thickness;
  double? _width;
  double? _conductivity;
  double? _coefficient;
  double? _baseTemperature;
  double? _ambientTemperature;

  int _presetGeneration = 0;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _length = double.tryParse(inputs['L'] ?? '');
    _thickness = double.tryParse(inputs['t'] ?? '');
    _width = double.tryParse(inputs['w'] ?? '');
    _conductivity = double.tryParse(inputs['k'] ?? '');
    _coefficient = double.tryParse(inputs['h'] ?? '');
    _baseTemperature = double.tryParse(inputs['Tb'] ?? '');
    _ambientTemperature = double.tryParse(inputs['Tinf'] ?? '');
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
              title: l10n.Fin_Efficiency,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Fin_Efficiency,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  ThermalMaterialButton(
                    onSelected: (material) => setState(() {
                      _conductivity = material.conductivitySI;
                      _presetGeneration++;
                    }),
                  ),
                  SizedBox(height: context.tokens.space2),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: l10n.Fin_Length_L,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _length,
                      onChangedSI: (v) => _length = v,
                    ),
                    UnitField(
                      label: l10n.Fin_Thickness_t,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _thickness,
                      onChangedSI: (v) => _thickness = v,
                    ),
                    UnitField(
                      label: l10n.Fin_Width_w,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _width,
                      onChangedSI: (v) => _width = v,
                    ),
                    UnitField(
                      key: ValueKey('k$_presetGeneration'),
                      label: l10n.Conductivity_k,
                      category: UnitCategory.thermalConductivity,
                      signed: false,
                      initialSI: _conductivity,
                      onChangedSI: (v) => _conductivity = v,
                    ),
                    UnitField(
                      label: l10n.Film_Coefficient_h,
                      category: UnitCategory.heatTransferCoefficient,
                      signed: false,
                      initialSI: _coefficient,
                      onChangedSI: (v) => _coefficient = v,
                    ),
                    UnitField(
                      label: l10n.Base_Temperature,
                      category: UnitCategory.temperature,
                      initialSI: _baseTemperature,
                      onChangedSI: (v) => _baseTemperature = v,
                    ),
                    UnitField(
                      label: l10n.Ambient_Temperature,
                      category: UnitCategory.temperature,
                      initialSI: _ambientTemperature,
                      onChangedSI: (v) => _ambientTemperature = v,
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
      final length = _length;
      final thickness = _thickness;
      final width = _width;
      final conductivity = _conductivity;
      final coefficient = _coefficient;
      final base = _baseTemperature;
      final ambient = _ambientTemperature;
      if (length == null ||
          thickness == null ||
          width == null ||
          conductivity == null ||
          coefficient == null ||
          base == null ||
          ambient == null) {
        throw FormatException(S.of(context).Err_Enter_Fin_Inputs);
      }

      final result = FinCalculator.calculate(
        length: length,
        thickness: thickness,
        width: width,
        conductivity: conductivity,
        coefficient: coefficient,
        baseTemperature: base,
        ambientTemperature: ambient,
      );

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'L': '$length',
        't': '$thickness',
        'w': '$width',
        'k': '$conductivity',
        'h': '$coefficient',
        'Tb': '$base',
        'Tinf': '$ambient',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FinEfficiencyResultPage(
            result: result,
            length: length,
            thickness: thickness,
            width: width,
            conductivity: conductivity,
            coefficient: coefficient,
            baseTemperature: base,
            ambientTemperature: ambient,
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
