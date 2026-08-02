import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class TransverseShearStressPage extends StatefulWidget {
  const TransverseShearStressPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<TransverseShearStressPage> createState() =>
      _TransverseShearStressPageState();
}

class _TransverseShearStressPageState extends State<TransverseShearStressPage> {
  double? _v;
  double? _q;
  double? _i;
  double? _t;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _v = double.tryParse(inputs['V'] ?? '');
    _q = double.tryParse(inputs['Q'] ?? '');
    _i = double.tryParse(inputs['I'] ?? '');
    _t = double.tryParse(inputs['t'] ?? '');
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
              title: 'Transverse Shear Stress',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The shear stress at any point in a beam cross-section, where Q is the first moment of the area above (or below) the point about the neutral axis.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''\tau = \frac{VQ}{It}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Shear force, V',
                      category: UnitCategory.force,
                      initialSI: _v,
                      onChangedSI: (v) => _v = v,
                    ),
                    UnitField(
                      label: 'First moment, Q',
                      category: UnitCategory.sectionModulus,
                      signed: false,
                      initialSI: _q,
                      onChangedSI: (v) => _q = v,
                    ),
                    UnitField(
                      label: 'Moment of inertia, I',
                      category: UnitCategory.momentOfInertia,
                      signed: false,
                      initialSI: _i,
                      onChangedSI: (v) => _i = v,
                    ),
                    UnitField(
                      label: 'Width, t',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _t,
                      onChangedSI: (v) => _t = v,
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
      final v = _v;
      final q = _q;
      final i = _i;
      final t = _t;
      if (v == null || q == null || i == null || t == null) {
        throw const FormatException('Enter V, Q, I, and t.');
      }
      if (i == 0 || t == 0) {
        throw const FormatException('I and t must be nonzero.');
      }

      final tau = v * q / (i * t);

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'V': '$v',
        'Q': '$q',
        'I': '$i',
        't': '$t',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _TransverseShearStressResultPage(
            toolId: widget.toolId,
            tau: tau,
            v: v,
            q: q,
            i: i,
            t: t,
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

class _TransverseShearStressResultPage extends StatelessWidget {
  _TransverseShearStressResultPage({
    required this.toolId,
    required this.tau,
    required this.v,
    required this.q,
    required this.i,
    required this.t,
  });

  final int toolId;
  final double tau;
  final double v;
  final double q;
  final double i;
  final double t;

  String _fmt(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_fmt(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final tool = ToolLibrary.shared.item(toolId, context);
    return ResultScaffold(
      toolName: 'Transverse Shear Stress',
      shareLines: () => _shareLines(system),
      children: [
        ToolResultHeader(tool: tool),
        AppSectionCard(
          title: 'Transverse Shear Stress',
          child: Column(children: [
            AppCopyableValue(
              label: 'Shear stress, τ',
              valueSI: tau,
              category: UnitCategory.stress,
            ),
          ]),
        ),
        AppSectionCard(
          title: 'Formula',
          child: Text(
            'τ = V·Q / (I·t)\n'
            '= ${_fv(v, UnitCategory.force, system)} × ${_fv(q, UnitCategory.sectionModulus, system)} / (${_fv(i, UnitCategory.momentOfInertia, system)} × ${_fv(t, UnitCategory.length, system)})\n'
            '= ${_fv(tau, UnitCategory.stress, system)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        ParameterSweepCard(
          variableLabel: 'Width, t',
          variableCategory: UnitCategory.length,
          baseValueSI: t,
          outputLabel: 'τ',
          outputCategory: UnitCategory.stress,
          compute: (variedT) => v * q / (i * variedT),
        ),
      ],
    );
  }

  List<String> _shareLines(UnitSystem system) => [
        'τ = ${_fv(tau, UnitCategory.stress, system)}',
        '',
        'Calculation:',
        'τ = V·Q / (I·t)',
        '= ${_fv(v, UnitCategory.force, system)} × ${_fv(q, UnitCategory.sectionModulus, system)} / (${_fv(i, UnitCategory.momentOfInertia, system)} × ${_fv(t, UnitCategory.length, system)})',
        '= ${_fv(tau, UnitCategory.stress, system)}',
      ];
}
