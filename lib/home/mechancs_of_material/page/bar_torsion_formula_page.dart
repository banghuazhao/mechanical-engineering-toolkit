import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/bar_torsion_formula_result.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BarTorsionFormulaPage extends StatefulWidget {
  const BarTorsionFormulaPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<BarTorsionFormulaPage> createState() => _BarTorsionFormulaPageState();
}

class _BarTorsionFormulaPageState extends State<BarTorsionFormulaPage> {
  double? _t;
  double? _r;
  double? _ip;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _t = double.tryParse(inputs['T'] ?? '');
    _r = double.tryParse(inputs['r'] ?? '');
    _ip = double.tryParse(inputs['Ip'] ?? '');
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
              title: 'Torsion Formula of Bar',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The maximum shear stress on the outer surface of a circular bar under torsion T, at radius r, for a cross-section with polar moment of inertia Ip.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''\tau_{max} = \frac{Tr}{I_p}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Torque, T',
                      category: UnitCategory.momentSection,
                      initialSI: _t,
                      onChangedSI: (v) => _t = v,
                    ),
                    UnitField(
                      label: 'Radius, r',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _r,
                      onChangedSI: (v) => _r = v,
                    ),
                    UnitField(
                      label: 'Polar moment, Ip',
                      category: UnitCategory.momentOfInertia,
                      signed: false,
                      initialSI: _ip,
                      onChangedSI: (v) => _ip = v,
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
      final t = _t;
      final r = _r;
      final ip = _ip;
      if (t == null || r == null || ip == null) {
        throw const FormatException('Enter T, r, and Ip.');
      }
      if (r <= 0 || ip <= 0) {
        throw const FormatException(
            'Radius and polar moment must be positive.');
      }

      final tauMax = t * r / ip;

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'T': '$t',
        'r': '$r',
        'Ip': '$ip',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BarTorsionFormulaResultPage(
            tauMax: tauMax,
            t: t,
            r: r,
            ip: ip,
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
