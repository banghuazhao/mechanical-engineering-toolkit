import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/spur_gear_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/page/spur_gear_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class SpurGearPage extends StatefulWidget {
  const SpurGearPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<SpurGearPage> createState() => _SpurGearPageState();
}

class _SpurGearPageState extends State<SpurGearPage> {
  double? _module;
  int? _n1;
  int? _n2;
  double? _faceWidth;
  double? _wt;
  double _cp = 191;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _module = double.tryParse(inputs['m'] ?? '');
    _n1 = int.tryParse(inputs['N1'] ?? '');
    _n2 = int.tryParse(inputs['N2'] ?? '');
    _faceWidth = double.tryParse(inputs['F'] ?? '');
    _wt = double.tryParse(inputs['Wt'] ?? '');
    _cp = double.tryParse(inputs['Cp'] ?? '') ?? 191;
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
              title: 'Spur Gear Geometry',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '20° full-depth involute spur gear pair: pitch diameters, center distance, and basic (Lewis) bending stress with a simplified contact-stress estimate. Not a full AGMA design check.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''\sigma = \frac{W_t}{F \cdot m \cdot Y}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Module, m',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _module,
                      onChangedSI: (v) => _module = v,
                    ),
                    TextFormField(
                      initialValue: _n1?.toString(),
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Pinion teeth, N1'),
                      onChanged: (v) => _n1 = int.tryParse(v),
                    ),
                    TextFormField(
                      initialValue: _n2?.toString(),
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Gear teeth, N2'),
                      onChanged: (v) => _n2 = int.tryParse(v),
                    ),
                    UnitField(
                      label: 'Face width, F',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _faceWidth,
                      onChangedSI: (v) => _faceWidth = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space3),
                  Text(
                    'Optional — for bending/contact stress',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  SizedBox(height: context.tokens.space2),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Tangential load, Wt',
                      category: UnitCategory.force,
                      signed: false,
                      initialSI: _wt,
                      onChangedSI: (v) => _wt = v,
                    ),
                    TextFormField(
                      initialValue: _cp.toString(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Elastic coeff., Cp (√MPa)'),
                      onChanged: (v) => _cp = double.tryParse(v) ?? _cp,
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
      final m = _module;
      final n1 = _n1;
      final n2 = _n2;
      final f = _faceWidth;
      if (m == null || n1 == null || n2 == null || f == null) {
        throw const FormatException('Enter module, N1, N2, and face width.');
      }

      final result = SpurGearCalculator.calculate(SpurGearInput(
        module: m,
        pinionTeeth: n1,
        gearTeeth: n2,
        faceWidth: f,
        tangentialLoad: _wt,
        elasticCoefficient: _cp,
      ));

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'm': '$m',
        'N1': '$n1',
        'N2': '$n2',
        'F': '$f',
        'Wt': _wt == null ? '' : '$_wt',
        'Cp': '$_cp',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpurGearResultPage(
            result: result,
            module: m,
            faceWidth: f,
            wt: _wt,
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
