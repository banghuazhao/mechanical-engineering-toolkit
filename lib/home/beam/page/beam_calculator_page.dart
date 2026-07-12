import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/simply_supported_beam_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/beam_calculator_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
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
  final _span = TextEditingController(text: '4');
  final _pointLoad = TextEditingController(text: '10');
  final _pointPosition = TextEditingController(text: '2');
  final _udl = TextEditingController(text: '0');
  final _elasticModulus = TextEditingController(text: '200');
  final _secondMoment = TextEditingController(text: '100000000');

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _span.text = inputs['Span (m)'] ?? _span.text;
    _pointLoad.text = inputs['Point load (kN)'] ?? _pointLoad.text;
    _pointPosition.text = inputs['Point position (m)'] ?? _pointPosition.text;
    _udl.text = inputs['UDL (kN/m)'] ?? _udl.text;
    _elasticModulus.text =
        inputs['Elastic modulus (GPa)'] ?? _elasticModulus.text;
    _secondMoment.text = inputs['Second moment (mm4)'] ?? _secondMoment.text;
  }

  @override
  void dispose() {
    _span.dispose();
    _pointLoad.dispose();
    _pointPosition.dispose();
    _udl.dispose();
    _elasticModulus.dispose();
    _secondMoment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            AppSectionCard(
              title: 'Simply supported beam',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pin support at the left, roller support at the right. Combine one downward point load with a full-span uniformly distributed load.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    _field(_span, 'Span, L', 'm'),
                    _field(_pointLoad, 'Point load, P', 'kN'),
                    _field(_pointPosition, 'Point position, a', 'm'),
                    _field(_udl, 'Full-span UDL, w', 'kN/m'),
                    _field(_elasticModulus, 'Elastic modulus, E', 'GPa'),
                    _field(_secondMoment, 'Second moment, I', 'mm⁴'),
                  ]),
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
                    'Uses static equilibrium and Euler–Bernoulli beam theory for a simply supported beam. A downward point load and a full-span uniformly distributed load may be used separately or together.',
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

  Widget _field(
    TextEditingController controller,
    String label,
    String unit,
  ) =>
      TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, suffixText: unit),
      );

  void _calculate() {
    try {
      final inputs = <String, String>{
        'Span (m)': _span.text,
        'Point load (kN)': _pointLoad.text,
        'Point position (m)': _pointPosition.text,
        'UDL (kN/m)': _udl.text,
        'Elastic modulus (GPa)': _elasticModulus.text,
        'Second moment (mm4)': _secondMoment.text,
      };
      final input = BeamAnalysisInput(
        span: double.tryParse(_span.text) ?? 0,
        pointLoad: double.tryParse(_pointLoad.text) ?? 0,
        pointPosition: double.tryParse(_pointPosition.text) ?? 0,
        distributedLoad: double.tryParse(_udl.text) ?? 0,
        elasticModulus: double.tryParse(_elasticModulus.text) ?? 0,
        secondMoment: double.tryParse(_secondMoment.text) ?? 0,
      );
      final result = SimplySupportedBeamCalculator.calculate(input);
      context.read<ToolHistory>().record(widget.toolId, inputs: inputs);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BeamCalculatorResultPage(
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
