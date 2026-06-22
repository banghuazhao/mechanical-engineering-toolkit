import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/single_row_result.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:provider/provider.dart';

import '../../tool_setting_page.dart';

class _ShearModel {
  double? V, Q, I, t;
  bool isValid() => V != null && Q != null && I != null && t != null && I! != 0 && t! != 0;
}

class TransverseShearStressPage extends StatefulWidget {
  final String title;
  const TransverseShearStressPage({Key? key, required this.title})
      : super(key: key);

  @override
  _TransverseShearStressPageState createState() =>
      _TransverseShearStressPageState();
}

class _TransverseShearStressPageState
    extends State<TransverseShearStressPage> {
  final _model = _ShearModel();
  bool validate = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final fields = <_FieldDef>[
      _FieldDef('V  (transverse shear force, N)', (v) => _model.V = v, () => _model.V),
      _FieldDef('Q  (first moment of area, m³)', (v) => _model.Q = v, () => _model.Q),
      _FieldDef('I  (moment of inertia, m⁴)', (v) => _model.I = v, () => _model.I),
      _FieldDef('t  (width at point of interest, m)', (v) => _model.t = v, () => _model.t),
    ];

    final items = [
      Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                'INPUTS',
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
                          child: TextField(
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: const OutlineInputBorder(),
                              labelText: f.label,
                              errorText: validate && f.getter() == null
                                  ? S.of(context).Not_a_number
                                  : null,
                            ),
                            onChanged: (v) =>
                                setState(() => f.setter(double.tryParse(v))),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      DescriptionItem(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The transverse shear stress at any point in the cross-section:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Center(
              child: Math.tex(
                r'''\tau = \frac{VQ}{It}''',
                mathStyle: MathStyle.display,
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'where Q = ∫ydA is the first moment of the area above (or below) the point of interest about the neutral axis.',
              style: Theme.of(context).textTheme.bodyMedium,
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
          staggeredTileBuilder: (_) =>
              StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (_, i) => items[i],
        ),
      ),
    );
  }

  void _calculate() {
    if (!_model.isValid()) return;
    final tau = _model.V! * _model.Q! / (_model.I! * _model.t!);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ShearResultPage(
          tau: tau,
          V: _model.V!,
          Q: _model.Q!,
          I: _model.I!,
          t: _model.t!,
        ),
      ),
    );
  }
}

class _FieldDef {
  final String label;
  final void Function(double?) setter;
  final double? Function() getter;
  _FieldDef(this.label, this.setter, this.getter);
}

class _ShearResultPage extends StatelessWidget {
  final double tau, V, Q, I, t;
  const _ShearResultPage(
      {required this.tau,
      required this.V,
      required this.Q,
      required this.I,
      required this.t});

  @override
  Widget build(BuildContext context) {
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
              final precs = Provider.of<NumberPrecisionHelper>(context, listen: false);
              shareResult('Transverse Shear Stress', [
                'τ = ${precs.formatValue(tau)}',
                '',
                'Calculation:',
                'τ = V·Q / (I·t)',
                '= ${precs.formatValue(V)} × ${precs.formatValue(Q)} / (${precs.formatValue(I)} × ${precs.formatValue(t)})',
                '= ${precs.formatValue(tau)}',
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
          itemCount: 2,
          staggeredTileBuilder: (_) =>
              StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (_, i) {
            return [
              SingleRowResult(
                title: 'Transverse Shear Stress',
                resultTitle: 'τ = VQ/(It)',
                resultValue: tau,
              ),
              Consumer<NumberPrecisionHelper>(
                builder: (context, precs, _) => CalculationCard(steps: [
                  'τ = V·Q / (I·t)',
                  '= ${precs.formatValue(V)} × ${precs.formatValue(Q)} / (${precs.formatValue(I)} × ${precs.formatValue(t)})',
                  '= ${precs.formatValue(tau)}',
                ]),
              ),
            ][i];
          },
        ),
      ),
    );
  }
}
