import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/press_fit_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/page/press_fit_result_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/material_preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/unit_field.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class PressFitPage extends StatefulWidget {
  const PressFitPage({
    super.key,
    required this.title,
    required this.toolId,
    this.initialInputs,
  });

  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;

  @override
  State<PressFitPage> createState() => _PressFitPageState();
}

class _PressFitPageState extends State<PressFitPage> {
  double? _r;
  double? _ro;
  double? _delta;
  double? _e;
  double _nu = 0.3;

  @override
  void initState() {
    super.initState();
    final inputs = widget.initialInputs;
    if (inputs == null) return;
    _r = double.tryParse(inputs['r'] ?? '');
    _ro = double.tryParse(inputs['ro'] ?? '');
    _delta = double.tryParse(inputs['delta'] ?? '');
    _e = double.tryParse(inputs['E'] ?? '');
    _nu = double.tryParse(inputs['nu'] ?? '') ?? 0.3;
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
              title: 'Press / Shrink-Fit Interference',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact pressure and hoop stress for a solid shaft pressed into a hub, same material assumed for both parts (a standard simplified case — Poisson\'s ratio cancels out).',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  SizedBox(height: context.tokens.space4),
                  AdaptiveFieldGrid(children: [
                    UnitField(
                      label: 'Interface radius, r',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _r,
                      onChangedSI: (v) => _r = v,
                    ),
                    UnitField(
                      label: 'Hub outer radius, ro',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _ro,
                      onChangedSI: (v) => _ro = v,
                    ),
                    UnitField(
                      label: 'Diametral interference, δ',
                      category: UnitCategory.length,
                      signed: false,
                      initialSI: _delta,
                      onChangedSI: (v) => _delta = v,
                    ),
                    UnitField(
                      label: 'Modulus, E',
                      category: UnitCategory.modulus,
                      signed: false,
                      initialSI: _e,
                      onChangedSI: (v) => _e = v,
                    ),
                  ]),
                  SizedBox(height: context.tokens.space2),
                  MaterialPresetButton(
                    onSelected: (preset) => setState(() {
                      if (preset.elasticModulusSI != null) {
                        _e = preset.elasticModulusSI;
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
      final r = _r;
      final ro = _ro;
      final delta = _delta;
      final e = _e;
      if (r == null || ro == null || delta == null || e == null) {
        throw const FormatException('Enter r, ro, δ, and E.');
      }

      final result = PressFitCalculator.calculate(PressFitInput(
        interfaceRadius: r,
        hubOuterRadius: ro,
        diametralInterference: delta,
        modulusGPa: e,
        poissonsRatio: _nu,
      ));

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        'r': '$r',
        'ro': '$ro',
        'delta': '$delta',
        'E': '$e',
        'nu': '$_nu',
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PressFitResultPage(
            result: result,
            r: r,
            ro: ro,
            delta: delta,
            e: e,
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
