import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class FailureCriteriaPage extends StatefulWidget {
  const FailureCriteriaPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<FailureCriteriaPage> createState() => _FailureCriteriaPageState();
}

class _FailureCriteriaPageState extends State<FailureCriteriaPage> {
  double? _sx;
  double? _sy;
  double? _txy;
  double? _yield;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _sx = double.tryParse(inputs['σ_x'] ?? '');
    _sy = double.tryParse(inputs['σ_y'] ?? '');
    _txy = double.tryParse(inputs['τ_xy'] ?? '');
    _yield = double.tryParse(inputs['S_y'] ?? '');
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
              title: 'Failure Criteria (von Mises / Tresca)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Math.tex(
                      r'''\sigma_{VM} = \sqrt{\sigma_1^2 - \sigma_1\sigma_2 + \sigma_2^2}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  SizedBox(height: context.tokens.space2),
                  Center(
                    child: Math.tex(
                      r'''\sigma_{eff,Tresca} = |\sigma_1 - \sigma_2|''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'σx',
                      category: UnitCategory.stress,
                      initialSI: _sx,
                      onChangedSI: (v) => _sx = v,
                    ),
                    UnitField(
                      label: 'σy',
                      category: UnitCategory.stress,
                      initialSI: _sy,
                      onChangedSI: (v) => _sy = v,
                    ),
                    UnitField(
                      label: 'τxy',
                      category: UnitCategory.stress,
                      initialSI: _txy,
                      onChangedSI: (v) => _txy = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space3),
                  Text(
                    'Yield strength (optional — enables factor of safety)',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  SizedBox(height: context.tokens.space2),
                  UnitField(
                    label: 'Yield strength, Sy',
                    category: UnitCategory.stress,
                    signed: false,
                    initialSI: _yield,
                    onChangedSI: (v) => _yield = v,
                  ),
                  SizedBox(height: context.tokens.space2),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.yieldStrengthSI != null) {
                        _yield = preset.yieldStrengthSI;
                      }
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
      final sx = _sx;
      final sy = _sy;
      final txy = _txy;
      if (sx == null || sy == null || txy == null) {
        throw const FormatException('Enter σx, σy, and τxy.');
      }

      final avg = (sx + sy) / 2;
      final r = sqrt(pow((sx - sy) / 2, 2) + txy * txy);
      final s1 = avg + r;
      final s2 = avg - r;
      final vonMises = sqrt(s1 * s1 - s1 * s2 + s2 * s2);
      final tresca = (s1 - s2).abs();
      final tauMax = tresca / 2;

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'σ_x': '$sx',
        'σ_y': '$sy',
        'τ_xy': '$txy',
        'S_y': _yield == null ? '' : '$_yield',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _FailureCriteriaResultPage(
            s1: s1,
            s2: s2,
            vonMises: vonMises,
            tresca: tresca,
            tauMax: tauMax,
            yieldStrength: _yield,
            sx: sx,
            sy: sy,
            txy: txy,
            avg: avg,
            r: r,
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

class _FailureCriteriaResultPage extends StatelessWidget {
  _FailureCriteriaResultPage({
    required this.s1,
    required this.s2,
    required this.vonMises,
    required this.tresca,
    required this.tauMax,
    required this.sx,
    required this.sy,
    required this.txy,
    required this.avg,
    required this.r,
    this.yieldStrength,
  });

  final double s1;
  final double s2;
  final double vonMises;
  final double tresca;
  final double tauMax;
  final double sx;
  final double sy;
  final double txy;
  final double avg;
  final double r;
  final double? yieldStrength;

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final hasSy = yieldStrength != null && yieldStrength! > 0;
    final fsVm = hasSy ? yieldStrength! / vonMises : null;
    final fsTresca = hasSy ? yieldStrength! / tresca : null;

    return ResultScaffold(
      toolName: 'Failure Criteria',
      shareLines: () => _shareLines(system, precs, hasSy, fsVm, fsTresca),
      children: [
        AppSectionCard(
          title: S.of(context).Stress_Results,
          child: Column(children: [
            AppCopyableValue(
                label: 'σ₁', valueSI: s1, category: UnitCategory.stress),
            AppCopyableValue(
                label: 'σ₂', valueSI: s2, category: UnitCategory.stress),
            AppCopyableValue(
                label: 'σ_VM (von Mises)',
                valueSI: vonMises,
                category: UnitCategory.stress),
            AppCopyableValue(
                label: 'τ_max', valueSI: tauMax, category: UnitCategory.stress),
            AppCopyableValue(
                label: 'σ_Tresca',
                valueSI: tresca,
                category: UnitCategory.stress),
          ]),
        ),
        if (hasSy) ...[
          AppSectionCard(
            title: S.of(context).Factor_of_Safety,
            child: Column(children: [
              AppCopyableValue(
                  label: 'FS (von Mises)', value: precs.formatValue(fsVm)),
              AppCopyableValue(
                  label: 'FS (Tresca)', value: precs.formatValue(fsTresca)),
            ]),
          ),
        ],
        AppSectionCard(
          title: S.of(context).Calculation,
          child: Text(
            'R = √(((σx−σy)/2)² + τ²) = ${precs.formatSI(r, UnitCategory.stress, system)}\n'
            'σ1 = (σx+σy)/2 + R = ${precs.formatSI(avg, UnitCategory.stress, system)} + ${precs.formatSI(r, UnitCategory.stress, system)} = ${precs.formatSI(s1, UnitCategory.stress, system)}\n'
            'σ2 = (σx+σy)/2 − R = ${precs.formatSI(avg, UnitCategory.stress, system)} − ${precs.formatSI(r, UnitCategory.stress, system)} = ${precs.formatSI(s2, UnitCategory.stress, system)}\n'
            'σ_VM = √(σ1²−σ1σ2+σ2²) = ${precs.formatSI(vonMises, UnitCategory.stress, system)}\n'
            'σ_Tresca = |σ1−σ2| = ${precs.formatSI(tresca, UnitCategory.stress, system)}, τ_max = ${precs.formatSI(tauMax, UnitCategory.stress, system)}'
            '${hasSy ? '\nFS_VM = Sy/σ_VM = ${precs.formatValue(fsVm)}\nFS_Tresca = Sy/σ_Tresca = ${precs.formatValue(fsTresca)}' : ''}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        ParameterSweepCard(
          variableLabel: 'τxy',
          variableCategory: UnitCategory.stress,
          baseValueSI: txy,
          outputLabel: 'σ_VM',
          outputCategory: UnitCategory.stress,
          compute: (variedTxy) {
            final rr = sqrt(pow((sx - sy) / 2, 2) + variedTxy * variedTxy);
            final ss1 = avg + rr;
            final ss2 = avg - rr;
            return sqrt(ss1 * ss1 - ss1 * ss2 + ss2 * ss2);
          },
        ),
      ],
    );
  }

  List<String> _shareLines(UnitSystem system, NumberPrecisionHelper precs,
      bool hasSy, double? fsVm, double? fsTresca) {
    return [
      'σ₁ = ${precs.formatSI(s1, UnitCategory.stress, system)}, σ₂ = ${precs.formatSI(s2, UnitCategory.stress, system)}',
      'σ_VM = ${precs.formatSI(vonMises, UnitCategory.stress, system)}',
      'σ_Tresca = ${precs.formatSI(tresca, UnitCategory.stress, system)}, τ_max = ${precs.formatSI(tauMax, UnitCategory.stress, system)}',
      if (hasSy) 'FS_VM = ${precs.formatValue(fsVm)}',
      if (hasSy) 'FS_Tresca = ${precs.formatValue(fsTresca)}',
      '',
      'Calculation:',
      'R = √(((σx−σy)/2)² + τ²) = ${precs.formatSI(r, UnitCategory.stress, system)}',
      'σ1 = ${precs.formatSI(avg, UnitCategory.stress, system)} + ${precs.formatSI(r, UnitCategory.stress, system)} = ${precs.formatSI(s1, UnitCategory.stress, system)}',
      'σ2 = ${precs.formatSI(avg, UnitCategory.stress, system)} − ${precs.formatSI(r, UnitCategory.stress, system)} = ${precs.formatSI(s2, UnitCategory.stress, system)}',
      'σ_VM = √(σ1²−σ1σ2+σ2²) = ${precs.formatSI(vonMises, UnitCategory.stress, system)}',
    ];
  }
}
