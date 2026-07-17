import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/multiple_row_result.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

import '../../tool_setting_page.dart';

class FailureCriteriaPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const FailureCriteriaPage(
      {Key? key, required this.title, required this.toolId, this.initialInputs})
      : super(key: key);

  @override
  _FailureCriteriaPageState createState() => _FailureCriteriaPageState();
}

class _FailureCriteriaPageState extends State<FailureCriteriaPage> {
  double? _sx, _sy, _txy, _yield;
  bool validate = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      _sx = double.tryParse(widget.initialInputs!["σ_x"] ?? "");
      _sy = double.tryParse(widget.initialInputs!["σ_y"] ?? "");
      _txy = double.tryParse(widget.initialInputs!["τ_xy"] ?? "");
      _yield = double.tryParse(widget.initialInputs!["S_y"] ?? "");
    }
  }

  bool get _inputsReady => _sx != null && _sy != null && _txy != null;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final stressFields = <_FieldSpec>[
      _FieldSpec('σ_x  (normal stress in x)', (v) => _sx = v, () => _sx, true),
      _FieldSpec('σ_y  (normal stress in y)', (v) => _sy = v, () => _sy, true),
      _FieldSpec('τ_xy  (shear stress)', (v) => _txy = v, () => _txy, true),
    ];

    final items = [
      _buildCard(context, 'PLANE STRESS STATE', stressFields, primary),
      Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                'MATERIAL (OPTIONAL)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: primary,
                      letterSpacing: 0.8,
                    ),
              ),
            ),
            const Divider(height: 14),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UnitField(
                    label:
                        'S_y  (tensile yield strength — for factor of safety)',
                    category: UnitCategory.stress,
                    initialSI: _yield,
                    signed: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
                    border: const OutlineInputBorder(),
                    onChangedSI: (v) => setState(() => _yield = v),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Leave blank to skip safety factor calculation',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      DescriptionItem(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Von Mises (Distortion Energy) Criterion:',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Center(
              child: Math.tex(
                r'''\sigma_{VM} = \sqrt{\sigma_1^2 - \sigma_1\sigma_2 + \sigma_2^2}''',
                mathStyle: MathStyle.display,
                textStyle: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 12),
            Text('Tresca (Maximum Shear Stress) Criterion:',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Center(
              child: Math.tex(
                r'''\tau_{max} = \frac{|\sigma_1 - \sigma_2|}{2}''',
                mathStyle: MathStyle.display,
                textStyle: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Math.tex(
                r'''\sigma_{eff,Tresca} = |\sigma_1 - \sigma_2|''',
                mathStyle: MathStyle.display,
                textStyle: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() => validate = true);
          _calculate();
        },
        label: Text(S.of(context).Calculate),
      ),
      body: SafeArea(
        child: StaggeredGridView.countBuilder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          crossAxisCount: 8,
          itemCount: items.length,
          staggeredTileBuilder: (_) => StaggeredTile.fit(
              MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (_, i) => items[i],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String cardTitle,
      List<_FieldSpec> fields, Color primary) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              cardTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primary,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
          const Divider(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: fields
                  .map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: UnitField(
                          label: f.label,
                          category: UnitCategory.stress,
                          initialSI: f.getter(),
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) =>
                              validate && f.required && value == null
                                  ? S.of(context).Not_a_number
                                  : null,
                          onChangedSI: (v) => setState(() => f.setter(v)),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _calculate() {
    if (!_inputsReady) return;
    final sx = _sx!, sy = _sy!, txy = _txy!;

    final avg = (sx + sy) / 2;
    final r = sqrt(pow((sx - sy) / 2, 2) + txy * txy);
    final s1 = avg + r;
    final s2 = avg - r;

    final vonMises = sqrt(s1 * s1 - s1 * s2 + s2 * s2);
    final tresca = (s1 - s2).abs();
    final tauMax = tresca / 2;

    context.read<ToolHistory>().record(widget.toolId, inputs: {
      "σ_x": sx.toString(),
      "σ_y": sy.toString(),
      "τ_xy": txy.toString(),
      "S_y": _yield?.toString() ?? "",
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FailureResultPage(
          s1: s1,
          s2: s2,
          vonMises: vonMises,
          tresca: tresca,
          tauMax: tauMax,
          yield_: _yield,
          sx: _sx!,
          sy: _sy!,
          txy: _txy!,
          avg: avg,
          R: r,
        ),
      ),
    );
  }
}

class _FieldSpec {
  final String label;
  final void Function(double?) setter;
  final double? Function() getter;
  final bool required;
  _FieldSpec(this.label, this.setter, this.getter, this.required);
}

class _FailureResultPage extends StatelessWidget {
  final double s1, s2, vonMises, tresca, tauMax;
  final double sx, sy, txy, avg, R;
  final double? yield_;

  const _FailureResultPage({
    required this.s1,
    required this.s2,
    required this.vonMises,
    required this.tresca,
    required this.tauMax,
    required this.sx,
    required this.sy,
    required this.txy,
    required this.avg,
    required this.R,
    this.yield_,
  });

  String _fv(BuildContext context, double? valueSI, UnitCategory category) {
    final precs = Provider.of<NumberPrecisionHelper>(context, listen: false);
    final system =
        Provider.of<UnitSystemPreference>(context, listen: false).system;
    final display = valueSI == null ? null : fromSI(valueSI, category, system);
    return '${precs.formatValue(display)} ${unitLabel(category, system)}';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<UnitSystemPreference>();
    final hasSy = yield_ != null && yield_! > 0;
    final fsSy = hasSy ? yield_! / vonMises : null;
    final fsTresca = hasSy ? yield_! / tresca : null;

    final titles = [
      'σ₁  (principal stress 1)',
      'σ₂  (principal stress 2)',
      'σ_VM  (Von Mises stress)',
      'τ_max  (maximum shear stress)',
      'σ_Tresca  (effective Tresca stress)',
      if (hasSy) 'FS_VM  (factor of safety — Von Mises)',
      if (hasSy) 'FS_Tresca  (factor of safety — Tresca)',
    ];
    final values = [
      s1,
      s2,
      vonMises,
      tauMax,
      tresca,
      if (hasSy) fsSy!,
      if (hasSy) fsTresca!,
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {
              final precs =
                  Provider.of<NumberPrecisionHelper>(context, listen: false);
              shareResult('Failure Criteria', [
                'σ₁ = ${_fv(context, s1, UnitCategory.stress)},  σ₂ = ${_fv(context, s2, UnitCategory.stress)}',
                'σ_VM = ${_fv(context, vonMises, UnitCategory.stress)}',
                'σ_Tresca = ${_fv(context, tresca, UnitCategory.stress)},  τ_max = ${_fv(context, tauMax, UnitCategory.stress)}',
                if (yield_ != null && yield_! > 0) ...[
                  'FS_VM = ${precs.formatValue(yield_! / vonMises)}',
                  'FS_Tresca = ${precs.formatValue(yield_! / tresca)}',
                ],
                '',
                'Calculation:',
                'R = √(((σₓ−σᵧ)/2)² + τ²) = ${_fv(context, R, UnitCategory.stress)}',
                'σ₁ = ${_fv(context, avg, UnitCategory.stress)} + ${_fv(context, R, UnitCategory.stress)} = ${_fv(context, s1, UnitCategory.stress)}',
                'σ₂ = ${_fv(context, avg, UnitCategory.stress)} − ${_fv(context, R, UnitCategory.stress)} = ${_fv(context, s2, UnitCategory.stress)}',
                'σ_VM = √(σ₁²−σ₁σ₂+σ₂²) = ${_fv(context, vonMises, UnitCategory.stress)}',
              ]);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ToolSettingPage())),
          ),
        ],
        title: Text(S.of(context).Result),
      ),
      body: SafeArea(
        child: StaggeredGridView.countBuilder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          crossAxisCount: 8,
          itemCount: hasSy ? 3 : 2,
          staggeredTileBuilder: (_) => StaggeredTile.fit(
              MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (_, i) {
            if (i == 0) {
              return MultipleRowResult(
                title: 'Stress Results',
                resultTitles: titles.sublist(0, 5),
                resultValues: values.sublist(0, 5),
                resultUnits: const [
                  UnitCategory.stress,
                  UnitCategory.stress,
                  UnitCategory.stress,
                  UnitCategory.stress,
                  UnitCategory.stress,
                ],
              );
            }
            if (hasSy && i == 1) {
              return MultipleRowResult(
                title: 'Factor of Safety',
                resultTitles: titles.sublist(5),
                resultValues: values.sublist(5),
              );
            }
            return Consumer<NumberPrecisionHelper>(
              builder: (context, precs, _) => CalculationCard(steps: [
                'Principal stresses:',
                'R = √(((σₓ−σᵧ)/2)² + τ²)',
                '  = √((( ${_fv(context, sx, UnitCategory.stress)} − ${_fv(context, sy, UnitCategory.stress)} )/2)² + ${_fv(context, txy, UnitCategory.stress)}²)',
                '  = ${_fv(context, R, UnitCategory.stress)}',
                'σ₁ = (σₓ+σᵧ)/2 + R = ${_fv(context, avg, UnitCategory.stress)} + ${_fv(context, R, UnitCategory.stress)} = ${_fv(context, s1, UnitCategory.stress)}',
                'σ₂ = (σₓ+σᵧ)/2 − R = ${_fv(context, avg, UnitCategory.stress)} − ${_fv(context, R, UnitCategory.stress)} = ${_fv(context, s2, UnitCategory.stress)}',
                '',
                'Von Mises: σ_VM = √(σ₁²−σ₁σ₂+σ₂²) = ${_fv(context, vonMises, UnitCategory.stress)}',
                'Tresca:  σ_eff = |σ₁−σ₂| = ${_fv(context, tresca, UnitCategory.stress)},  τ_max = ${_fv(context, tauMax, UnitCategory.stress)}',
                if (hasSy)
                  'FS_VM = Sᵧ / σ_VM = ${_fv(context, yield_, UnitCategory.stress)} / ${_fv(context, vonMises, UnitCategory.stress)} = ${precs.formatValue(yield_! / vonMises)}',
                if (hasSy)
                  'FS_Tresca = Sᵧ / σ_eff = ${_fv(context, yield_, UnitCategory.stress)} / ${_fv(context, tresca, UnitCategory.stress)} = ${precs.formatValue(yield_! / tresca)}',
              ]),
            );
          },
        ),
      ),
    );
  }
}
