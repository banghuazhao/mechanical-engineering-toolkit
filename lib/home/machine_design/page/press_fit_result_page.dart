import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/press_fit_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class PressFitResultPage extends StatelessWidget {
  PressFitResultPage({
    super.key,
    required this.result,
    required this.r,
    required this.ro,
    required this.delta,
    required this.e,
  });

  final PressFitResult result;
  final double r;
  final double ro;
  final double delta;
  final double e;
  final _exportKey = GlobalKey();

  String _fv(double valueSI, UnitCategory category, UnitSystem system,
          NumberPrecisionHelper precs) =>
      '${precs.formatValue(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            tooltip: 'Share results',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _share(system, precs),
          ),
          IconButton(
            tooltip: 'Share as image',
            icon: const Icon(Icons.image_outlined),
            onPressed: () =>
                shareResultImage(_exportKey, 'Press / Shrink-Fit Interference'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ToolSettingPage()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBannerAd(),
      body: RepaintBoundary(
        key: _exportKey,
        child: AppContent(
          padding: EdgeInsets.zero,
          child: ListView(
            padding: EdgeInsets.all(context.tokens.space4),
            children: [
              AppSectionCard(
                title: 'Press / Shrink-Fit Interference',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Contact pressure, p',
                    valueSI: result.contactPressureMPa,
                    category: UnitCategory.stress,
                  ),
                  AppCopyableValue(
                    label: 'Hub bore hoop stress, σt',
                    valueSI: result.hubHoopStressMPa,
                    category: UnitCategory.stress,
                  ),
                  AppCopyableValue(
                    label: 'Shaft surface stress, σs',
                    valueSI: result.shaftStressMPa,
                    category: UnitCategory.stress,
                  ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'p = E·(δ/2) / ( r·[ (ro²+r²)/(ro²−r²) + 1 ] )\n'
                  '= ${_fv(result.contactPressureMPa, UnitCategory.stress, system, precs)}\n'
                  'σt,hub = p·(ro²+r²)/(ro²−r²) = ${_fv(result.hubHoopStressMPa, UnitCategory.stress, system, precs)}\n'
                  'σshaft = −p = ${_fv(result.shaftStressMPa, UnitCategory.stress, system, precs)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: context.tokens.space4),
              ParameterSweepCard(
                variableLabel: 'Diametral interference, δ',
                variableCategory: UnitCategory.length,
                baseValueSI: delta,
                outputLabel: 'Contact pressure, p',
                outputCategory: UnitCategory.stress,
                compute: (variedDelta) {
                  final r2 = PressFitCalculator.calculate(PressFitInput(
                    interfaceRadius: r,
                    hubOuterRadius: ro,
                    diametralInterference: variedDelta,
                    modulusGPa: e,
                  ));
                  return r2.contactPressureMPa;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(UnitSystem system, NumberPrecisionHelper precs) =>
      shareResult('Press / Shrink-Fit Interference', [
        'p = ${_fv(result.contactPressureMPa, UnitCategory.stress, system, precs)}',
        'σt,hub = ${_fv(result.hubHoopStressMPa, UnitCategory.stress, system, precs)}',
        'σshaft = ${_fv(result.shaftStressMPa, UnitCategory.stress, system, precs)}',
      ]);
}
