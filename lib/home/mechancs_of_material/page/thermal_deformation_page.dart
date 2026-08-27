import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/multiple_row_result.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class _ThermalModel {
  double? alpha, deltaT, length, youngsModulus;

  bool isValid() =>
      alpha != null &&
      deltaT != null &&
      length != null &&
      youngsModulus != null;
}

class ThermalDeformationPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const ThermalDeformationPage(
      {Key? key, required this.title, required this.toolId, this.initialInputs})
      : super(key: key);

  @override
  _ThermalDeformationPageState createState() => _ThermalDeformationPageState();
}

class _ThermalDeformationPageState extends State<ThermalDeformationPage> {
  final _model = _ThermalModel();
  bool validate = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      _model.alpha = double.tryParse(widget.initialInputs!["α"] ?? "");
      _model.deltaT = double.tryParse(widget.initialInputs!["ΔT"] ?? "");
      _model.length = double.tryParse(widget.initialInputs!["L"] ?? "");
      _model.youngsModulus = double.tryParse(widget.initialInputs!["E"] ?? "");
    }
  }

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
                        child: UnitField(
                          label: f.label,
                          category: f.category,
                          initialSI: f.value,
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          border: const OutlineInputBorder(),
                          errorText: (value) => validate && value == null
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

  @override
  Widget build(BuildContext context) {
    final items = [
      _inputCard('Thermal Properties', [
        _Field('α  (coefficient of thermal expansion, per °C — not converted)',
            () => _model.alpha, (v) => _model.alpha = v, null),
        _Field('ΔT  (temperature change)', () => _model.deltaT,
            (v) => _model.deltaT = v, UnitCategory.temperatureDelta),
        _Field('L  (original length)', () => _model.length,
            (v) => _model.length = v, UnitCategory.length),
        _Field('E  (Young\'s modulus)', () => _model.youngsModulus,
            (v) => _model.youngsModulus = v, UnitCategory.stress),
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
        actions: [
          ToolHelpButton(toolId: widget.toolId, toolTitle: widget.title),
        ],
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

  void _calculate() {
    if (!_model.isValid()) return;
    final delta = _model.alpha! * _model.deltaT! * _model.length!;
    final sigma = -_model.youngsModulus! * _model.alpha! * _model.deltaT!;
    context.read<ToolHistory>().record(widget.toolId, inputs: {
      "α": _model.alpha!.toString(),
      "ΔT": _model.deltaT!.toString(),
      "L": _model.length!.toString(),
      "E": _model.youngsModulus!.toString(),
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ThermalResultPage(
          toolId: widget.toolId,
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
  final UnitCategory? category;
  double? get value => getter();
  _Field(this.label, this.getter, this.setter, this.category);
}

class _ThermalResultPage extends StatelessWidget {
  final int toolId;
  final double delta;
  final double sigma;
  final double alpha;
  final double deltaT;
  final double length;
  final double E;
  _ThermalResultPage(
      {required this.toolId,
      required this.delta,
      required this.sigma,
      required this.alpha,
      required this.deltaT,
      required this.length,
      required this.E});

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
    return ResultScaffold(
      toolName: 'Thermal Deformation & Stress',
      formulaSteps: _calculationSteps(context),
      results: [
        multipleRowSection(
          title: S.of(context).Thermal_Results,
          resultTitles: const [
            'δ_T  (thermal deformation)',
            'σ_T  (thermal stress, constrained)',
          ],
          resultValues: [delta, sigma],
          resultUnits: const [UnitCategory.length, UnitCategory.stress],
        ),
      ],
      body: SafeArea(
        child: Consumer<NumberPrecisionHelper>(
          builder: (context, precs, _) {
            final tool = ToolLibrary.shared.item(toolId, context);
            final items = [
              ToolResultHeader(tool: tool),
              MultipleRowResult(
                title: S.of(context).Thermal_Results,
                resultTitles: const [
                  'δ_T  (thermal deformation)',
                  'σ_T  (thermal stress, constrained)'
                ],
                resultValues: [delta, sigma],
                resultUnits: const [UnitCategory.length, UnitCategory.stress],
              ),
              CalculationCard(steps: _calculationSteps(context)),
            ];
            return StaggeredGridView.countBuilder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              crossAxisCount: 8,
              itemCount: items.length,
              staggeredTileBuilder: (index) => StaggeredTile.fit(index == 0
                  ? 8
                  : (MediaQuery.of(context).size.width > 600 ? 4 : 8)),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (_, i) => items[i],
            );
          },
        ),
      ),
    );
  }

  List<String> _calculationSteps(BuildContext context) {
    final precs = Provider.of<NumberPrecisionHelper>(context, listen: false);
    return [
      'δ_T = α × ΔT × L',
      '= ${precs.formatValue(alpha)} × ${_fv(context, deltaT, UnitCategory.temperatureDelta)} × ${_fv(context, length, UnitCategory.length)}',
      '= ${_fv(context, delta, UnitCategory.length)}',
      '',
      'σ_T = −E × α × ΔT',
      '= −${_fv(context, E, UnitCategory.stress)} × ${precs.formatValue(alpha)} × ${_fv(context, deltaT, UnitCategory.temperatureDelta)}',
      '= ${_fv(context, sigma, UnitCategory.stress)}',
    ];
  }
}
