import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/general_stress_result.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class GeneralStressPage extends StatefulWidget {
  const GeneralStressPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<GeneralStressPage> createState() => _GeneralStressPageState();
}

class _GeneralStressPageState extends State<GeneralStressPage> {
  double? _f;
  double? _a;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _f = double.tryParse(inputs['F'] ?? '');
    _a = double.tryParse(inputs['A'] ?? '');
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
              title: 'General Stress',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Normal stress from an axial force acting over a cross-sectional area.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''\sigma = \frac{F}{A}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Force, F',
                      category: UnitCategory.force,
                      signed: false,
                      initialSI: _f,
                      onChangedSI: (v) => _f = v,
                    ),
                    UnitField(
                      label: 'Area, A',
                      category: UnitCategory.area,
                      signed: false,
                      initialSI: _a,
                      onChangedSI: (v) => _a = v,
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
      final f = _f;
      final a = _a;
      if (f == null || a == null) {
        throw const FormatException('Enter F and A.');
      }
      if (a <= 0) {
        throw const FormatException('Area must be positive.');
      }

      final sigma = f / a;

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'F': '$f',
        'A': '$a',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GeneralStressResultPage(
            sigma: sigma,
            f: f,
            a: a,
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
