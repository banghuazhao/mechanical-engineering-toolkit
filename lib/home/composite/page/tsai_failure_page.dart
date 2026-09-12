import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/tsai_failure_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/composite/page/tsai_failure_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class TsaiFailurePage extends StatefulWidget {
  const TsaiFailurePage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<TsaiFailurePage> createState() => _TsaiFailurePageState();
}

class _TsaiFailurePageState extends State<TsaiFailurePage> {
  double? _s1;
  double? _s2;
  double? _t12;
  double? _xt;
  double? _xc;
  double? _yt;
  double? _yc;
  double? _s;
  int _presetGeneration = 0;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _s1 = double.tryParse(inputs['σ1'] ?? '');
    _s2 = double.tryParse(inputs['σ2'] ?? '');
    _t12 = double.tryParse(inputs['τ12'] ?? '');
    _xt = double.tryParse(inputs['Xt'] ?? '');
    _xc = double.tryParse(inputs['Xc'] ?? '');
    _yt = double.tryParse(inputs['Yt'] ?? '');
    _yc = double.tryParse(inputs['Yc'] ?? '');
    _s = double.tryParse(inputs['S'] ?? '');
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
            ToolResultHeader(tool: tool),
            AppSectionCard(
              title: 'Composite Failure Criteria (Tsai-Hill / Tsai-Wu)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Checks a lamina stress state (in material axes 1-2) against its strengths using both criteria. A failure index below 1 is predicted safe. The Tsai-Wu interaction term uses the common default F12 = −0.5·√(F11·F22) — override by testing if you have biaxial data.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  Text('Lamina stresses (material axes)',
                      style: Theme.of(context).textTheme.labelMedium),
                  SizedBox(height: context.tokens.space2),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'σ1',
                      category: UnitCategory.stress,
                      initialSI: _s1,
                      onChangedSI: (v) => _s1 = v,
                    ),
                    UnitField(
                      label: 'σ2',
                      category: UnitCategory.stress,
                      initialSI: _s2,
                      onChangedSI: (v) => _s2 = v,
                    ),
                    UnitField(
                      label: 'τ12',
                      category: UnitCategory.stress,
                      initialSI: _t12,
                      onChangedSI: (v) => _t12 = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space4),
                  Text('Lamina strengths (positive values)',
                      style: Theme.of(context).textTheme.labelMedium),
                  SizedBox(height: context.tokens.space2),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      key: ValueKey('Xt$_presetGeneration'),
                      label: 'Xt (fiber tensile)',
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _xt,
                      onChangedSI: (v) => _xt = v,
                    ),
                    UnitField(
                      key: ValueKey('Xc$_presetGeneration'),
                      label: 'Xc (fiber compressive)',
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _xc,
                      onChangedSI: (v) => _xc = v,
                    ),
                    UnitField(
                      key: ValueKey('Yt$_presetGeneration'),
                      label: 'Yt (transverse tensile)',
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _yt,
                      onChangedSI: (v) => _yt = v,
                    ),
                    UnitField(
                      key: ValueKey('Yc$_presetGeneration'),
                      label: 'Yc (transverse compressive)',
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _yc,
                      onChangedSI: (v) => _yc = v,
                    ),
                    UnitField(
                      key: ValueKey('S$_presetGeneration'),
                      label: 'S (in-plane shear)',
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _s,
                      onChangedSI: (v) => _s = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  LaminaPresetButton(
                    onSelected: (lamina) => setState(() {
                      _xt = lamina.xt;
                      _xc = lamina.xc;
                      _yt = lamina.yt;
                      _yc = lamina.yc;
                      _s = lamina.s;
                      _presetGeneration++;
                    }),
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
      final s1 = _s1;
      final s2 = _s2;
      final t12 = _t12;
      final xt = _xt;
      final xc = _xc;
      final yt = _yt;
      final yc = _yc;
      final s = _s;
      if (s1 == null || s2 == null || t12 == null) {
        throw const FormatException('Enter σ1, σ2, and τ12.');
      }
      if (xt == null || xc == null || yt == null || yc == null || s == null) {
        throw const FormatException('Enter all five strengths.');
      }

      final result = TsaiFailureCalculator.calculate(TsaiFailureInput(
        sigma1: s1,
        sigma2: s2,
        tau12: t12,
        xt: xt,
        xc: xc,
        yt: yt,
        yc: yc,
        s: s,
      ));

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'σ1': '$s1',
        'σ2': '$s2',
        'τ12': '$t12',
        'Xt': '$xt',
        'Xc': '$xc',
        'Yt': '$yt',
        'Yc': '$yc',
        'S': '$s',
      });

      showToolResult(
        context,
        (context) => TsaiFailureResultPage(
          result: result,
          s1: s1,
          s2: s2,
          t12: t12,
          xt: xt,
          xc: xc,
          yt: yt,
          yc: yc,
          s: s,
        ),
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
