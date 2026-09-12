import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/shaft_fatigue_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/page/shaft_fatigue_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
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
              title: S.of(context).Shaft_Fatigue_Design,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).Desc_Shaft_Fatigue,
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
                      label: S.of(context).Alternating_Moment_Ma,
                      category: UnitCategory.momentSection,
                      signed: false,
                      initialSI: _ma,
                      onChangedSI: (v) => _ma = v,
                    ),
                    UnitField(
                      label: S.of(context).Mean_Moment_Mm,
                      category: UnitCategory.momentSection,
                      signed: false,
                      initialSI: _mm,
                      onChangedSI: (v) => _mm = v,
                    ),
                    UnitField(
                      label: S.of(context).Alternating_Torque_Ta,
                      category: UnitCategory.momentSection,
                      signed: false,
                      initialSI: _ta,
                      onChangedSI: (v) => _ta = v,
                    ),
                    UnitField(
                      label: S.of(context).Mean_Torque_Tm,
                      category: UnitCategory.momentSection,
                      signed: false,
                      initialSI: _tm,
                      onChangedSI: (v) => _tm = v,
                    ),
                    UnitField(
                      label: S.of(context).Endurance_Limit_Se,
                      category: UnitCategory.stress,
                      signed: false,
                      initialSI: _se,
                      onChangedSI: (v) => _se = v,
                    ),
                    UnitField(
                      label: S.of(context).Ultimate_Strength_Sut,
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
                    S.of(context).Stress_Concentration_Defaults,
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
                          InputDecoration(labelText: S.of(context).Kf_Bending),
                      onChanged: (v) => _kf = double.tryParse(v) ?? _kf,
                    ),
                    TextFormField(
                      initialValue: _kfs.toString(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                          InputDecoration(labelText: S.of(context).Kfs_Torsion),
                      onChanged: (v) => _kfs = double.tryParse(v) ?? _kfs,
                    ),
                    TextFormField(
                      initialValue: _n.toString(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                          labelText: S.of(context).Target_Factor_of_Safety_N),
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
        throw FormatException(S.of(context).Err_Enter_Se_Sut);
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

      showToolResult(
        context,
        (context) => ShaftFatigueResultPage(
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
      );
    } on FormatException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }
}
