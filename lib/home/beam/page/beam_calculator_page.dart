import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/simply_supported_beam_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/beam_calculator_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BeamCalculatorPage extends StatefulWidget {
  const BeamCalculatorPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<BeamCalculatorPage> createState() => _BeamCalculatorPageState();
}

class _BeamCalculatorPageState extends State<BeamCalculatorPage> {
  double? _span = 4;
  double? _pointLoad = 10;
  double? _pointPosition = 2;
  double? _udl = 0;
  double? _elasticModulus = 200;
  double? _secondMoment = 100000000;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _span = double.tryParse(inputs['Span (m)'] ?? '') ?? _span;
    _pointLoad = double.tryParse(inputs['Point load (kN)'] ?? '') ?? _pointLoad;
    _pointPosition =
        double.tryParse(inputs['Point position (m)'] ?? '') ?? _pointPosition;
    _udl = double.tryParse(inputs['UDL (kN/m)'] ?? '') ?? _udl;
    _elasticModulus = double.tryParse(inputs['Elastic modulus (GPa)'] ?? '') ??
        _elasticModulus;
    _secondMoment =
        double.tryParse(inputs['Second moment (mm4)'] ?? '') ?? _secondMoment;
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _calculate,
        icon: const Icon(Icons.analytics_rounded),
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
              title: S.of(context).Simply_Supported_Beam,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).Desc_Beam_Supports,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: S.of(context).Span_L,
                      category: UnitCategory.span,
                      initialSI: _span,
                      onChangedSI: (v) => _span = v,
                    ),
                    UnitField(
                      label: S.of(context).Point_Load_P,
                      category: UnitCategory.forceStructural,
                      initialSI: _pointLoad,
                      onChangedSI: (v) => _pointLoad = v,
                    ),
                    UnitField(
                      label: S.of(context).Point_Position_A,
                      category: UnitCategory.span,
                      initialSI: _pointPosition,
                      onChangedSI: (v) => _pointPosition = v,
                    ),
                    UnitField(
                      label: S.of(context).Full_Span_UDL_W,
                      category: UnitCategory.distributedLoadStructural,
                      initialSI: _udl,
                      onChangedSI: (v) => _udl = v,
                    ),
                    UnitField(
                      label: S.of(context).Elastic_Modulus_E,
                      category: UnitCategory.modulus,
                      initialSI: _elasticModulus,
                      onChangedSI: (v) => _elasticModulus = v,
                    ),
                    UnitField(
                      label: S.of(context).Second_Moment_I,
                      category: UnitCategory.momentOfInertia,
                      initialSI: _secondMoment,
                      onChangedSI: (v) => _secondMoment = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.elasticModulusSI != null) {
                        _elasticModulus = preset.elasticModulusSI;
                      }
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.tokens.space4),
            AppSectionCard(
              title: S.of(context).Description_and_Formulas,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).Desc_Beam_Analysis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: context.tokens.space4),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        r'''\begin{aligned}
R_A&=\frac{P(L-a)}{L}+\frac{wL}{2}\\
R_B&=\frac{Pa}{L}+\frac{wL}{2}\\
M(x)&=R_Ax-\frac{wx^2}{2}-P(x-a)H(x-a)\\
EI\frac{d^2v}{dx^2}&=M(x)
\end{aligned}''',
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
      final inputs = <String, String>{
        'Span (m)': '${_span ?? ''}',
        'Point load (kN)': '${_pointLoad ?? ''}',
        'Point position (m)': '${_pointPosition ?? ''}',
        'UDL (kN/m)': '${_udl ?? ''}',
        'Elastic modulus (GPa)': '${_elasticModulus ?? ''}',
        'Second moment (mm4)': '${_secondMoment ?? ''}',
      };
      final input = BeamAnalysisInput(
        span: _span ?? 0,
        pointLoad: _pointLoad ?? 0,
        pointPosition: _pointPosition ?? 0,
        distributedLoad: _udl ?? 0,
        elasticModulus: _elasticModulus ?? 0,
        secondMoment: _secondMoment ?? 0,
      );
      final result = SimplySupportedBeamCalculator.calculate(input);
      context.read<ToolHistory>().record(widget.toolId, inputs: inputs);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BeamCalculatorResultPage(
            toolId: widget.toolId,
            title: widget.title,
            input: input,
            result: result,
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
