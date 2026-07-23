import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/shaft_fatigue_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/page/shaft_fatigue_result_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class ShaftFatiguePage extends StatefulWidget {
  const ShaftFatiguePage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<ShaftFatiguePage> createState() => _ShaftFatiguePageState();
}

class _ShaftFatiguePageState extends State<ShaftFatiguePage> {
  double? _ma;
  double? _mm;
  double? _ta;
  double? _tm;
  double _kf = 1.6;
  double _kfs = 1.3;
  double? _se;
  double? _sut;
  double _n = 2;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _ma = double.tryParse(inputs['Ma'] ?? '');
    _mm = double.tryParse(inputs['Mm'] ?? '');
    _ta = double.tryParse(inputs['Ta'] ?? '');
    _tm = double.tryParse(inputs['Tm'] ?? '');
    _kf = double.tryParse(inputs['Kf'] ?? '') ?? 1.6;
    _kfs = double.tryParse(inputs['Kfs'] ?? '') ?? 1.3;
    _se = double.tryParse(inputs['Se'] ?? '');
    _sut = double.tryParse(inputs['Sut'] ?? '');
    _n = double.tryParse(inputs['n'] ?? '') ?? 2;
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
              title: 'Shaft Fatigue Design (DE-Goodman)',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Minimum shaft diameter for combined fluctuating bending and torsion, using the distortion-energy/modified-Goodman criterion (Shigley). Leave mean moment/torque at 0 for a fully-reversed-bending, steady-torque shaft — the common case.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Center(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Math.tex(
                        r'''d=\left\{\frac{16n}{\pi}\left[\frac{\sqrt{4(K_fM_a)^2+3(K_{fs}T_a)^2}}{S_e}+\frac{\sqrt{4(K_fM_m)^2+3(K_{fs}T_m)^2}}{S_{ut}}\right]\right\}^{1/3}''',
                        mathStyle: MathStyle.display,
                        textStyle: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Alternating moment, Ma',
                      category: UnitCategory.momentSection,
                      signed: false,
                      initialSI: _ma,
                      onChangedSI: (v) => _ma = v,
                    ),
                    UnitField(
                      label: 'Mean moment, Mm',
                      category: UnitCategory.momentSection,
                      signed: false,
                      initialSI: _mm,
                      onChangedSI: (v) => _mm = v,
                    ),
                    UnitField(
                      label: 'Alternating torque, Ta',
                      category: UnitCategory.momentSection,
                      signed: false,
                      initialSI: _ta,
                      onChangedSI: (v) => _ta = v,
                    ),
                    UnitField(
                      label: 'Mean torque, Tm',
                      category: UnitCategory.momentSection,
                      signed: false,
                      initialSI: _tm,
                      onChangedSI: (v) => _tm = v,
                    ),
                    UnitField(
                      label: 'Endurance limit, Se',
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _se,
                      onChangedSI: (v) => _se = v,
                    ),
                    UnitField(
                      label: 'Ultimate strength, Sut',
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _sut,
                      onChangedSI: (v) => _sut = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.ultimateStrengthSI != null) {
                        _sut = preset.ultimateStrengthSI;
                      }
                    }),
                  ),
                  SizedBox(height: context.tokens.space3),
                  Text(
                    'Stress-concentration factors (defaults: profiled keyway) and target safety factor',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  SizedBox(height: context.tokens.space2),
                  AdaptiveFieldGrid(children: [
                    TextFormField(
                      initialValue: _kf.toString(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Kf (bending)'),
                      onChanged: (v) => _kf = double.tryParse(v) ?? _kf,
                    ),
                    TextFormField(
                      initialValue: _kfs.toString(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          const InputDecoration(labelText: 'Kfs (torsion)'),
                      onChanged: (v) => _kfs = double.tryParse(v) ?? _kfs,
                    ),
                    TextFormField(
                      initialValue: _n.toString(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                          labelText: 'Target factor of safety, n'),
                      onChanged: (v) => _n = double.tryParse(v) ?? _n,
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
      final se = _se;
      final sut = _sut;
      if (se == null || sut == null) {
        throw const FormatException('Enter Se and Sut.');
      }

      final result = ShaftFatigueCalculator.calculate(ShaftFatigueInput(
        alternatingMoment: _ma ?? 0,
        meanMoment: _mm ?? 0,
        alternatingTorque: _ta ?? 0,
        meanTorque: _tm ?? 0,
        kf: _kf,
        kfs: _kfs,
        enduranceLimit: se,
        ultimateStrength: sut,
        safetyFactor: _n,
      ));

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'Ma': '${_ma ?? 0}',
        'Mm': '${_mm ?? 0}',
        'Ta': '${_ta ?? 0}',
        'Tm': '${_tm ?? 0}',
        'Kf': '$_kf',
        'Kfs': '$_kfs',
        'Se': '$se',
        'Sut': '$sut',
        'n': '$_n',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ShaftFatigueResultPage(
            result: result,
            ma: _ma ?? 0,
            mm: _mm ?? 0,
            ta: _ta ?? 0,
            tm: _tm ?? 0,
            kf: _kf,
            kfs: _kfs,
            se: se,
            sut: sut,
            n: _n,
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
