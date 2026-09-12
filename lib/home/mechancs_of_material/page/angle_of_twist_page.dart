import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class AngleOfTwistPage extends StatefulWidget {
  const AngleOfTwistPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<AngleOfTwistPage> createState() => _AngleOfTwistPageState();
}

class _AngleOfTwistPageState extends State<AngleOfTwistPage> {
  double? _t;
  double? _l;
  double? _g;
  double? _j;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _t = double.tryParse(inputs['T'] ?? '');
    _l = double.tryParse(inputs['L'] ?? '');
    _g = double.tryParse(inputs['G'] ?? '');
    _j = double.tryParse(inputs['J'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          ToolHelpButton(toolId: widget.toolId, toolTitle: widget.title),
        ],
      ),
      floatingActionButton: CalculateButton(onPressed: _calculate),
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
              title: 'Angle of Twist',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The angle of twist for a circular shaft under torque T.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: Math.tex(
                      r'''\phi = \frac{TL}{GJ}''',
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
                      label: 'Length, L',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _l,
                      onChangedSI: (v) => _l = v,
                    ),
                    UnitField(
                      label: 'Shear modulus, G',
                      category: UnitCategory.modulus,
                      signed: false,
                      initialSI: _g,
                      onChangedSI: (v) => _g = v,
                    ),
                    UnitField(
                      label: 'Polar moment, J',
                      category: UnitCategory.momentOfInertia,
                      signed: false,
                      initialSI: _j,
                      onChangedSI: (v) => _j = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space3),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.shearModulusSI != null) {
                        _g = preset.shearModulusSI;
                      }
                    }),
                  ),
                  SizedBox(height: context.tokens.space2),
                  Text(
                    'Tip: for a solid circular shaft of diameter d, J = πd⁴/32; for a hollow shaft (do, di), J = π(do⁴ − di⁴)/32.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      final t = _t;
      final l = _l;
      final g = _g;
      final j = _j;
      if (t == null || l == null || g == null || j == null) {
        throw const FormatException('Enter T, L, G, and J.');
      }
      if (g == 0 || j == 0) {
        throw const FormatException('G and J must be nonzero.');
      }

      // G is entered in GPa; the mm/N-based formula needs the numerically
      // equivalent MPa value (1 GPa = 1000 MPa).
      final phiRad = t * l / (g * 1000 * j);
      final phiDeg = phiRad * 180 / pi;

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'T': '$t',
        'L': '$l',
        'G': '$g',
        'J': '$j',
      });

      showToolResult(
        context,
        (context) => _AngleOfTwistResultPage(
          toolId: widget.toolId,
          phiRad: phiRad,
          phiDeg: phiDeg,
          t: t,
          l: l,
          g: g,
          j: j,
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}

class _AngleOfTwistResultPage extends StatelessWidget {
  _AngleOfTwistResultPage({
    required this.toolId,
    required this.phiRad,
    required this.phiDeg,
    required this.t,
    required this.l,
    required this.g,
    required this.j,
  });

  final int toolId;
  final double phiRad;
  final double phiDeg;
  final double t;
  final double l;
  final double g;
  final double j;

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final tool = ToolLibrary.shared.item(toolId, context);

    final formulaSteps = [
      'φ = T·L / (G·J)',
      '= ${precs.formatSI(t, UnitCategory.momentSection, system)} × ${precs.formatSI(l, UnitCategory.length, system)} / (${precs.formatSI(g, UnitCategory.modulus, system)} × ${precs.formatSI(j, UnitCategory.momentOfInertia, system)})',
      '= ${precs.formatValue(phiRad)} rad = ${precs.formatValue(phiDeg)}°',
    ];

    return ResultScaffold(
      toolName: 'Angle of Twist',
      formulaSteps: formulaSteps,
      leading: [ToolResultHeader(tool: tool)],
      results: [
        ResultSection(
          title: 'Angle of Twist',
          values: [
            ResultValue(
              label: 'Angle, φ (radians)',
              valueSI: phiRad,
            ),
            ResultValue(
              label: 'Angle, φ (degrees)',
              valueSI: phiDeg,
              category: UnitCategory.angle,
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: formulaSteps),
        ParameterSweepCard(
          variableLabel: 'Length, L',
          variableCategory: UnitCategory.length,
          baseValueSI: l,
          outputLabel: 'φ (rad)',
          outputCategory: null,
          compute: (variedL) => t * variedL / (g * 1000 * j),
        ),
      ],
    );
  }

}
