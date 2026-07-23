import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/beam_section_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/beam_section_properties_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BeamSectionPropertiesPage extends StatefulWidget {
  const BeamSectionPropertiesPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<BeamSectionPropertiesPage> createState() =>
      _BeamSectionPropertiesPageState();
}

class _BeamSectionPropertiesPageState extends State<BeamSectionPropertiesPage> {
  BeamSectionType _type = BeamSectionType.rectangle;
  double? _width;
  double? _height;
  double? _wall;
  double? _flange;
  double? _web;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _type = BeamSectionType.values.firstWhere(
      (value) => value.name == inputs['Section type'],
      orElse: () => BeamSectionType.rectangle,
    );
    _width = double.tryParse(inputs['Width / diameter (mm)'] ?? '');
    _height = double.tryParse(inputs['Height (mm)'] ?? '');
    _wall = double.tryParse(inputs['Wall thickness (mm)'] ?? '');
    _flange = double.tryParse(inputs['Flange thickness (mm)'] ?? '');
    _web = double.tryParse(inputs['Web thickness (mm)'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final isCircular = {
      BeamSectionType.circle,
      BeamSectionType.hollowCircle,
    }.contains(_type);
    final isHollow = {
      BeamSectionType.hollowRectangle,
      BeamSectionType.hollowCircle,
    }.contains(_type);
    final isISection = _type == BeamSectionType.iSection;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _calculate,
        icon: const Icon(Icons.calculate_rounded),
        label: Text(S.of(context).Calculate),
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
              title: 'Cross-section',
              child: Column(
                children: [
                  DropdownButtonFormField<BeamSectionType>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Shape'),
                    items: BeamSectionType.values
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(_label(type)),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _type = value!),
                  ),
                  SizedBox(height: context.tokens.space3),
                  AdaptiveFieldGrid(
                    children: [
                      UnitField(
                        label:
                            isCircular ? 'Outside diameter' : 'Overall width',
                        category: UnitCategory.length,
                        initialSI: _width,
                        onChangedSI: (v) => _width = v,
                      ),
                      if (!isCircular)
                        UnitField(
                          label: 'Overall height',
                          category: UnitCategory.length,
                          initialSI: _height,
                          onChangedSI: (v) => _height = v,
                        ),
                      if (isHollow)
                        UnitField(
                          label: 'Wall thickness',
                          category: UnitCategory.length,
                          initialSI: _wall,
                          onChangedSI: (v) => _wall = v,
                        ),
                      if (isISection) ...[
                        UnitField(
                          label: 'Flange thickness',
                          category: UnitCategory.length,
                          initialSI: _flange,
                          onChangedSI: (v) => _flange = v,
                        ),
                        UnitField(
                          label: 'Web thickness',
                          category: UnitCategory.length,
                          initialSI: _web,
                          onChangedSI: (v) => _web = v,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: context.tokens.space4),
            AppSectionCard(
              title: 'Description and formulas',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calculates centroidal geometric properties used in beam bending and stress calculations. The x-axis is horizontal through the centroid and the y-axis is vertical through the centroid.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: context.tokens.space4),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        _formula(_type),
                        mathStyle: MathStyle.display,
                        textStyle: Theme.of(context).textTheme.titleMedium,
                      ),
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
    try {
      final width = _width ?? 0;
      final height = {
        BeamSectionType.circle,
        BeamSectionType.hollowCircle,
      }.contains(_type)
          ? width
          : _height ?? 0;
      final input = BeamSectionInput(
        type: _type,
        width: width,
        height: height,
        wallThickness: _wall ?? 0,
        flangeThickness: _flange ?? 0,
        webThickness: _web ?? 0,
      );
      final result = BeamSectionCalculator.calculate(input);
      final inputs = <String, String>{
        'Section type': _type.name,
        'Width / diameter (mm)': '${_width ?? ''}',
        if (_height != null) 'Height (mm)': '$_height',
        if (_wall != null) 'Wall thickness (mm)': '$_wall',
        if (_flange != null) 'Flange thickness (mm)': '$_flange',
        if (_web != null) 'Web thickness (mm)': '$_web',
      };
      context.read<ToolHistory>().record(widget.toolId, inputs: inputs);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BeamSectionPropertiesResultPage(
            toolId: widget.toolId,
            title: widget.title,
            input: input,
            result: result,
          ),
        ),
      );
    } on FormatException catch (error) {
      _error(error.message);
    }
  }

  void _error(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  String _label(BeamSectionType type) => switch (type) {
        BeamSectionType.rectangle => 'Solid rectangle',
        BeamSectionType.hollowRectangle => 'Rectangular hollow section',
        BeamSectionType.circle => 'Solid circle',
        BeamSectionType.hollowCircle => 'Circular hollow section',
        BeamSectionType.iSection => 'Symmetric I-section',
      };

  String _formula(BeamSectionType type) => switch (type) {
        BeamSectionType.rectangle =>
          r'A=bh,\quad I_x=\frac{bh^3}{12},\quad I_y=\frac{hb^3}{12}',
        BeamSectionType.hollowRectangle =>
          r'A=bh-b_i h_i,\quad I_x=\frac{bh^3-b_i h_i^3}{12}',
        BeamSectionType.circle =>
          r'A=\frac{\pi d^2}{4},\quad I_x=I_y=\frac{\pi d^4}{64}',
        BeamSectionType.hollowCircle =>
          r'A=\frac{\pi(D^2-d^2)}{4},\quad I_x=I_y=\frac{\pi(D^4-d^4)}{64}',
        BeamSectionType.iSection =>
          r'A=2bt_f+t_w(h-2t_f),\quad I_x=\sum(I_c+Ad^2)',
      };
}
