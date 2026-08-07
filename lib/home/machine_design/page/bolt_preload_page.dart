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
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BoltPreloadPage extends StatefulWidget {
  const BoltPreloadPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<BoltPreloadPage> createState() => _BoltPreloadPageState();
}

class _BoltPreloadPageState extends State<BoltPreloadPage> {
  double? _f;
  double? _d;
  double _k = 0.2;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _f = double.tryParse(inputs['F'] ?? '');
    _d = double.tryParse(inputs['d'] ?? '');
    _k = double.tryParse(inputs['K'] ?? '') ?? 0.2;
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
              title: S.of(context).Bolt_Preload_Torque_Tension,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).Desc_Bolt_Preload,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''T = K \cdot F \cdot d''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: S.of(context).Target_Preload_F,
                      category: UnitCategory.force,
                      signed: false,
                      initialSI: _f,
                      onChangedSI: (v) => _f = v,
                    ),
                    UnitField(
                      label: S.of(context).Nominal_Diameter_D,
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _d,
                      onChangedSI: (v) => _d = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space3),
                  Text(
                    S.of(context).Nut_Factor_K,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space2),
                  TextFormField(
                    initialValue: _k.toString(),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'K'),
                    onChanged: (v) => _k = double.tryParse(v) ?? _k,
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
      final f = _f;
      final d = _d;
      if (f == null || d == null) {
        throw FormatException(S.of(context).Err_Enter_F_D);
      }
      if (f <= 0 || d <= 0) {
        throw FormatException(S.of(context).Err_F_D_Positive);
      }
      if (_k <= 0) {
        throw FormatException(S.of(context).Err_Nut_Factor_Positive);
      }

      // d is in mm; T = K*F*d needs d in meters to give torque in N·m.
      final torque = _k * f * (d / 1000);

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'F': '$f',
        'd': '$d',
        'K': '$_k',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _BoltPreloadResultPage(
            torque: torque,
            f: f,
            d: d,
            k: _k,
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

class _BoltPreloadResultPage extends StatelessWidget {
  const _BoltPreloadResultPage({
    required this.torque,
    required this.f,
    required this.d,
    required this.k,
  });

  final double torque;
  final double f;
  final double d;
  final double k;

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();

    final formulaSteps = _steps(system, precs);

    return ResultScaffold(
      toolName: S.of(context).Bolt_Preload_Torque_Tension,
      formulaSteps: formulaSteps,
      results: [
        ResultSection(
          title: S.of(context).Bolt_Preload_Torque_Tension,
          values: [
            ResultValue(
              label: S.of(context).Tightening_Torque_T,
              valueSI: torque,
              category: UnitCategory.torque,
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: formulaSteps),
        ParameterSweepCard(
          variableLabel: S.of(context).Diameter_D,
          variableCategory: UnitCategory.length,
          baseValueSI: d,
          outputLabel: 'T',
          outputCategory: UnitCategory.torque,
          compute: (variedD) => k * f * (variedD / 1000),
        ),
      ],
    );
  }

  List<String> _steps(UnitSystem system, NumberPrecisionHelper precs) => [
        'T = K\u00b7F\u00b7d',
        '= ${precs.formatValue(k)} \u00d7 ${precs.formatSI(f, UnitCategory.force, system)} \u00d7 ${precs.formatSI(d, UnitCategory.length, system)}',
        '= ${precs.formatSI(torque, UnitCategory.torque, system)}',
      ];
}
