import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/beam_section_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/beam_section_properties_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
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
  final _width = TextEditingController();
  final _height = TextEditingController();
  final _wall = TextEditingController();
  final _flange = TextEditingController();
  final _web = TextEditingController();

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _type = BeamSectionType.values.firstWhere(
      (value) => value.name == inputs['Section type'],
      orElse: () => BeamSectionType.rectangle,
    );
    _width.text = inputs['Width / diameter (mm)'] ?? '';
    _height.text = inputs['Height (mm)'] ?? '';
    _wall.text = inputs['Wall thickness (mm)'] ?? '';
    _flange.text = inputs['Flange thickness (mm)'] ?? '';
    _web.text = inputs['Web thickness (mm)'] ?? '';
  }

  @override
  void dispose() {
    _width.dispose();
    _height.dispose();
    _wall.dispose();
    _flange.dispose();
    _web.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      _field(
                        _width,
                        isCircular ? 'Outside diameter' : 'Overall width',
                      ),
                      if (!isCircular) _field(_height, 'Overall height'),
                      if (isHollow) _field(_wall, 'Wall thickness'),
                      if (isISection) ...[
                        _field(_flange, 'Flange thickness'),
                        _field(_web, 'Web thickness'),
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
                    'Calculates centroidal geometric properties used in beam bending and stress calculations. Dimensions are entered in millimetres. The x-axis is horizontal through the centroid and the y-axis is vertical through the centroid.',
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

  Widget _field(TextEditingController controller, String label) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, suffixText: 'mm'),
      );

  void _calculate() {
    try {
      final width = double.tryParse(_width.text) ?? 0;
      final height = {
        BeamSectionType.circle,
        BeamSectionType.hollowCircle,
      }.contains(_type)
          ? width
          : double.tryParse(_height.text) ?? 0;
      final input = BeamSectionInput(
        type: _type,
        width: width,
        height: height,
        wallThickness: double.tryParse(_wall.text) ?? 0,
        flangeThickness: double.tryParse(_flange.text) ?? 0,
        webThickness: double.tryParse(_web.text) ?? 0,
      );
      final result = BeamSectionCalculator.calculate(input);
      final inputs = <String, String>{
        'Section type': _type.name,
        'Width / diameter (mm)': _width.text,
        if (_height.text.isNotEmpty) 'Height (mm)': _height.text,
        if (_wall.text.isNotEmpty) 'Wall thickness (mm)': _wall.text,
        if (_flange.text.isNotEmpty) 'Flange thickness (mm)': _flange.text,
        if (_web.text.isNotEmpty) 'Web thickness (mm)': _web.text,
      };
      context.read<ToolHistory>().record(widget.toolId, inputs: inputs);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BeamSectionPropertiesResultPage(
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
