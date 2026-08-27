import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class FilletWeldPage extends StatefulWidget {
  const FilletWeldPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<FilletWeldPage> createState() => _FilletWeldPageState();
}

class _FilletWeldPageState extends State<FilletWeldPage> {
  double? _w;
  double? _l;
  double? _f;
  double? _allow;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _w = double.tryParse(inputs['w'] ?? '');
    _l = double.tryParse(inputs['L'] ?? '');
    _f = double.tryParse(inputs['F'] ?? '');
    _allow = double.tryParse(inputs['allow'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
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
              title: S.of(context).Fillet_Weld_Strength,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).Desc_Fillet_Weld,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''\tau = \frac{F}{0.707\,w\,L}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: S.of(context).Leg_Size_W,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _w,
                      onChangedSI: (v) => _w = v,
                    ),
                    UnitField(
                      label: S.of(context).Effective_Length_L,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _l,
                      onChangedSI: (v) => _l = v,
                    ),
                    UnitField(
                      label: S.of(context).Applied_Force_F,
                      category: UnitCategory.force,
                      signed: false,
                      initialSI: _f,
                      onChangedSI: (v) => _f = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space3),
                  UnitField(
                    label: S.of(context).Allowable_Shear_Stress_Optional,
                    category: UnitCategory.stress,
                    signed: false,
                    initialSI: _allow,
                    onChangedSI: (v) => _allow = v,
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
      final w = _w;
      final l = _l;
      final f = _f;
      if (w == null || l == null || f == null) {
        throw FormatException(S.of(context).Err_Enter_W_L_F);
      }
      if (w <= 0 || l <= 0 || f <= 0) {
        throw FormatException(S.of(context).Err_W_L_F_Positive);
      }

      final throat = 0.707 * w;
      final area = throat * l;
      final tau = f / area;

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'w': '$w',
        'L': '$l',
        'F': '$f',
        'allow': _allow == null ? '' : '$_allow',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _FilletWeldResultPage(
            tau: tau,
            w: w,
            l: l,
            f: f,
            allow: _allow,
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

class _FilletWeldResultPage extends StatelessWidget {
  const _FilletWeldResultPage({
    required this.tau,
    required this.w,
    required this.l,
    required this.f,
    this.allow,
  });

  final double tau;
  final double w;
  final double l;
  final double f;
  final double? allow;

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final hasAllow = allow != null && allow! > 0;
    final fos = hasAllow ? allow! / tau : null;

    final formulaSteps = _steps(system, precs);

    return ResultScaffold(
      toolName: S.of(context).Fillet_Weld_Strength,
      formulaSteps: formulaSteps,
      results: [
        ResultSection(
          title: S.of(context).Fillet_Weld_Strength,
          values: [
            ResultValue(
              label: 'Shear stress, \u03c4',
              valueSI: tau,
              category: UnitCategory.stress,
            ),
            if (fos != null)
              ResultValue(
                label: S.of(context).Factor_of_Safety,
                valueSI: fos,
              ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: formulaSteps),
        ParameterSweepCard(
          variableLabel: S.of(context).Leg_Size_W,
          variableCategory: UnitCategory.length,
          baseValueSI: w,
          outputLabel: '\u03c4',
          outputCategory: UnitCategory.stress,
          compute: (variedW) => f / (0.707 * variedW * l),
        ),
      ],
    );
  }

  List<String> _steps(UnitSystem system, NumberPrecisionHelper precs) => [
        '\u03c4 = F / (0.707\u00b7w\u00b7L)',
        '= ${precs.formatSI(f, UnitCategory.force, system)} / (0.707 \u00d7 ${precs.formatSI(w, UnitCategory.length, system)} \u00d7 ${precs.formatSI(l, UnitCategory.length, system)})',
        '= ${precs.formatSI(tau, UnitCategory.stress, system)}',
      ];
}
