import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/heat_transfer_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/page/composite_wall_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// One editable row of the layer stack. Mutable and identity-keyed so a row
/// keeps its text fields when its neighbours are added or removed.
class _LayerEntry {
  _LayerEntry({this.thickness, this.conductivity});

  double? thickness;
  double? conductivity;

  /// Bumped when a material preset overwrites [conductivity], so that field
  /// rebuilds with the new number instead of the typed text.
  int generation = 0;
}

class CompositeWallPage extends StatefulWidget {
  const CompositeWallPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<CompositeWallPage> createState() => _CompositeWallPageState();
}

class _CompositeWallPageState extends State<CompositeWallPage> {
  final List<_LayerEntry> _layers = [];
  double? _area = 1;
  double? _insideTemperature;
  double? _outsideTemperature;
  double? _insideCoefficient;
  double? _outsideCoefficient;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs != null) {
      _area = double.tryParse(inputs['A'] ?? '') ?? _area;
      _insideTemperature = double.tryParse(inputs['Ti'] ?? '');
      _outsideTemperature = double.tryParse(inputs['To'] ?? '');
      _insideCoefficient = double.tryParse(inputs['hi'] ?? '');
      _outsideCoefficient = double.tryParse(inputs['ho'] ?? '');
      for (var i = 0;; i++) {
        final thickness = double.tryParse(inputs['t$i'] ?? '');
        final conductivity = double.tryParse(inputs['k$i'] ?? '');
        if (thickness == null && conductivity == null) break;
        _layers.add(
          _LayerEntry(thickness: thickness, conductivity: conductivity),
        );
      }
    }
    // A single empty layer is the smallest wall worth showing a form for.
    if (_layers.isEmpty) _layers.add(_LayerEntry());
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final l10n = S.of(context);
    final theme = Theme.of(context);
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
              title: l10n.Composite_Wall_Conduction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.Desc_Composite_Wall,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: l10n.Wall_Area_A,
                      category: UnitCategory.areaStructural,
                      signed: false,
                      initialSI: _area,
                      onChangedSI: (v) => _area = v,
                    ),
                    UnitField(
                      label: l10n.Inside_Temperature,
                      category: UnitCategory.temperature,
                      initialSI: _insideTemperature,
                      onChangedSI: (v) => _insideTemperature = v,
                    ),
                    UnitField(
                      label: l10n.Outside_Temperature,
                      category: UnitCategory.temperature,
                      initialSI: _outsideTemperature,
                      onChangedSI: (v) => _outsideTemperature = v,
                    ),
                    UnitField(
                      label: l10n.Inside_Film_Coefficient,
                      category: UnitCategory.heatTransferCoefficient,
                      signed: false,
                      initialSI: _insideCoefficient,
                      onChangedSI: (v) => _insideCoefficient = v,
                    ),
                    UnitField(
                      label: l10n.Outside_Film_Coefficient,
                      category: UnitCategory.heatTransferCoefficient,
                      signed: false,
                      initialSI: _outsideCoefficient,
                      onChangedSI: (v) => _outsideCoefficient = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space3),
                  Text(
                    l10n.Film_Optional_Note,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.tokens.space4),
            AppSectionCard(
              title: l10n.Wall_Layers,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < _layers.length; i++) _layerRow(i),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () =>
                          setState(() => _layers.add(_LayerEntry())),
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          size: 18),
                      label: Text(l10n.Add_Layer),
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

  Widget _layerRow(int index) {
    final layer = _layers[index];
    final l10n = S.of(context);
    return Padding(
      key: ObjectKey(layer),
      padding: EdgeInsets.only(bottom: context.tokens.space3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.Layer_Number('${index + 1}'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              IconButton(
                tooltip: l10n.Remove_Layer,
                icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                // Never let the stack empty out: a wall with no layers has
                // nothing to calculate.
                onPressed: _layers.length > 1
                    ? () => setState(() => _layers.removeAt(index))
                    : null,
              ),
            ],
          ),
          AdaptiveFieldGrid(children: [
            UnitField(
              label: l10n.Thickness_t,
              category: UnitCategory.length,
              signed: false,
              initialSI: layer.thickness,
              onChangedSI: (v) => layer.thickness = v,
            ),
            UnitField(
              key: ValueKey('k${identityHashCode(layer)}-${layer.generation}'),
              label: l10n.Conductivity_k,
              category: UnitCategory.thermalConductivity,
              signed: false,
              initialSI: layer.conductivity,
              onChangedSI: (v) => layer.conductivity = v,
            ),
          ]),
          ThermalMaterialButton(
            onSelected: (material) => setState(() {
              layer.conductivity = material.conductivitySI;
              layer.generation++;
            }),
          ),
        ],
      ),
    );
  }

  void _calculate() {
    try {
      final l10n = S.of(context);
      final area = _area;
      final inside = _insideTemperature;
      final outside = _outsideTemperature;
      if (area == null || inside == null || outside == null) {
        throw FormatException(l10n.Err_Enter_Wall_Inputs);
      }
      final layers = <WallLayer>[];
      for (final layer in _layers) {
        final thickness = layer.thickness;
        final conductivity = layer.conductivity;
        if (thickness == null || conductivity == null) {
          throw FormatException(l10n.Err_Enter_Layer_Values);
        }
        layers.add(
          WallLayer(thickness: thickness, conductivity: conductivity),
        );
      }

      final result = CompositeWallCalculator.calculate(
        layers: layers,
        area: area,
        insideTemperature: inside,
        outsideTemperature: outside,
        insideLabel: l10n.Inside_Air,
        outsideLabel: l10n.Outside_Air,
        surfaceLabel: l10n.Wall_Surface,
        interfaceLabel: l10n.Wall_Interface,
        insideCoefficient: _insideCoefficient,
        outsideCoefficient: _outsideCoefficient,
      );

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'A': '$area',
        'Ti': '$inside',
        'To': '$outside',
        if (_insideCoefficient != null) 'hi': '$_insideCoefficient',
        if (_outsideCoefficient != null) 'ho': '$_outsideCoefficient',
        for (var i = 0; i < layers.length; i++) ...{
          't$i': '${layers[i].thickness}',
          'k$i': '${layers[i].conductivity}',
        },
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompositeWallResultPage(
            result: result,
            layers: layers,
            area: area,
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
