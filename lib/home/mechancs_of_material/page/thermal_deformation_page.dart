import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/multiple_row_result.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:provider/provider.dart';

import '../../tool_setting_page.dart';

class _ThermalModel {
  double? alpha, deltaT, length, youngsModulus;

  bool isValid() =>
      alpha != null && deltaT != null && length != null && youngsModulus != null;
}

class ThermalDeformationPage extends StatefulWidget {
  final String title;
  const ThermalDeformationPage({Key? key, required this.title})
      : super(key: key);

  @override
  _ThermalDeformationPageState createState() => _ThermalDeformationPageState();
}

class _ThermalDeformationPageState extends State<ThermalDeformationPage> {
  final _model = _ThermalModel();
  bool validate = false;

  Widget _inputCard(String cardTitle, List<_Field> fields) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              cardTitle.toUpperCase(),
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
                            errorText: validate && f.value == null
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _inputCard('Thermal Properties', [
        _Field('α  (coefficient of thermal expansion, 1/°C or 1/K)',
            () => _model.alpha, (v) => _model.alpha = v),
        _Field('ΔT  (temperature change, °C or K)',
            () => _model.deltaT, (v) => _model.deltaT = v),
        _Field('L  (original length, m)',
            () => _model.length, (v) => _model.length = v),
        _Field('E  (Young\'s modulus, Pa)',
            () => _model.youngsModulus, (v) => _model.youngsModulus = v),
      ]),
      DescriptionItem(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thermal deformation (free bar):',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Center(
              child: Math.tex(
                r'''\delta_T = \alpha \cdot \Delta T \cdot L''',
                mathStyle: MathStyle.display,
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thermal stress (fully constrained bar, δ = 0):',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Center(
              child: Math.tex(
                r'''\sigma_T = -E \cdot \alpha \cdot \Delta T''',
                mathStyle: MathStyle.display,
                textStyle: Theme.of(context).textTheme.titleMedium,
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
    final delta = _model.alpha! * _model.deltaT! * _model.length!;
    final sigma = -_model.youngsModulus! * _model.alpha! * _model.deltaT!;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ThermalResultPage(
          delta: delta,
          sigma: sigma,
          alpha: _model.alpha!,
          deltaT: _model.deltaT!,
          length: _model.length!,
          E: _model.youngsModulus!,
        ),
      ),
    );
  }
}

class _Field {
  final String label;
  final double? Function() getter;
  final void Function(double?) setter;
  double? get value => getter();
  _Field(this.label, this.getter, this.setter);
}

class _ThermalResultPage extends StatelessWidget {
  final double delta;
  final double sigma;
  final double alpha;
  final double deltaT;
  final double length;
  final double E;
  const _ThermalResultPage(
      {required this.delta,
      required this.sigma,
      required this.alpha,
      required this.deltaT,
      required this.length,
      required this.E});

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
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ToolSettingPage())),
          ),
        ],
        title: Text(S.of(context).Result),
      ),
      body: SafeArea(
        child: Consumer<NumberPrecisionHelper>(
          builder: (context, precs, _) {
            final items = [
              MultipleRowResult(
                title: 'Thermal Results',
                resultTitles: const [
                  'δ_T  (thermal deformation)',
                  'σ_T  (thermal stress, constrained)'
                ],
                resultValues: [delta, sigma],
              ),
              CalculationCard(steps: [
                'δ_T = α × ΔT × L',
                '= ${precs.formatValue(alpha)} × ${precs.formatValue(deltaT)} × ${precs.formatValue(length)}',
                '= ${precs.formatValue(delta)}',
                '',
                'σ_T = −E × α × ΔT',
                '= −${precs.formatValue(E)} × ${precs.formatValue(alpha)} × ${precs.formatValue(deltaT)}',
                '= ${precs.formatValue(sigma)}',
              ]),
            ];
            return StaggeredGridView.countBuilder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              crossAxisCount: 8,
              itemCount: items.length,
              staggeredTileBuilder: (_) =>
                  StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (_, i) => items[i],
            );
          },
        ),
      ),
    );
  }
}
