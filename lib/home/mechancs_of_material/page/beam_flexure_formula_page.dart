import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/beam_flexure_formula_result.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BeamFlexureFormulaPage extends StatefulWidget {
  const BeamFlexureFormulaPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<BeamFlexureFormulaPage> createState() => _BeamFlexureFormulaPageState();
}

class _BeamFlexureFormulaPageState extends State<BeamFlexureFormulaPage> {
  double? _m;
  double? _y;
  double? _i;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _m = double.tryParse(inputs['M'] ?? '');
    _y = double.tryParse(inputs['y'] ?? '');
    _i = double.tryParse(inputs['I'] ?? '');
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
              title: 'Flexure Formula of Beam',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bending stress varies linearly with distance y from the neutral axis. Leave y blank to see the stress as a function of y.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''\sigma_x = -\frac{My}{I}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Moment, M',
                      category: UnitCategory.momentSection,
                      initialSI: _m,
                      onChangedSI: (v) => _m = v,
                    ),
                    UnitField(
                      label: 'Moment of inertia, I',
                      category: UnitCategory.momentOfInertia,
                      signed: false,
                      initialSI: _i,
                      onChangedSI: (v) => _i = v,
                    ),
                    UnitField(
                      label: 'Distance, y (optional)',
                      category: UnitCategory.length,
                      initialSI: _y,
                      onChangedSI: (v) => _y = v,
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
      final m = _m;
      final i = _i;
      if (m == null || i == null) {
        throw const FormatException('Enter M and I.');
      }
      if (i <= 0) {
        throw const FormatException('Moment of inertia must be positive.');
      }

      final coefficient = -m / i;

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'M': '$m',
        'y': _y == null ? '' : '$_y',
        'I': '$i',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BeamFlexureFormulaResultPage(
            toolId: widget.toolId,
            coefficient: coefficient,
            y: _y,
            m: m,
            i: i,
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
