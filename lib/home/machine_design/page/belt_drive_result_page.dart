import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/belt_drive_calculator.dart';
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

class BeltDriveResultPage extends StatelessWidget {
  BeltDriveResultPage({
    super.key,
    required this.result,
    required this.d1,
    required this.d2,
    required this.c,
    required this.n1,
  });

  final BeltDriveResult result;
  final double d1;
  final double d2;
  final double c;
  final double n1;
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
            onPressed: () => shareResultImage(_exportKey, 'Belt / Chain Drive'),
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
                title: 'Belt / Chain Drive',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Speed ratio',
                    value: precs.formatValue(result.ratio),
                  ),
                  AppCopyableValue(
                    label: 'Output speed, n2',
                    valueSI: result.outputSpeedRpm,
                    category: UnitCategory.angularVelocity,
                  ),
                  AppCopyableValue(
                    label: 'Belt length, L',
                    valueSI: result.beltLength,
                    category: UnitCategory.length,
                  ),
                  AppCopyableValue(
                    label: 'Wrap angle, small pulley',
                    value: '${precs.formatValue(result.smallWrapAngleDeg)}°',
                  ),
                  AppCopyableValue(
                    label: 'Wrap angle, large pulley',
                    value: '${precs.formatValue(result.largeWrapAngleDeg)}°',
                  ),
                  if (result.drivingTorqueNm != null)
                    AppCopyableValue(
                      label: 'Driving torque, T1',
                      valueSI: result.drivingTorqueNm,
                      category: UnitCategory.torque,
                    ),
                  if (result.beltPullN != null)
                    AppCopyableValue(
                      label: 'Belt pull, Ft',
                      valueSI: result.beltPullN,
                      category: UnitCategory.force,
                    ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'ratio = d2/d1 = ${_fv(d2, UnitCategory.length, system, precs)} / ${_fv(d1, UnitCategory.length, system, precs)} = ${precs.formatValue(result.ratio)}\n'
                  'L = 2C + (π/2)(d1+d2) + (d2−d1)²/(4C)\n'
                  '= ${_fv(result.beltLength, UnitCategory.length, system, precs)}\n'
                  'Wrap: θ = π ∓ 2·asin((d2−d1)/(2C))'
                  '${result.drivingTorqueNm != null ? '\nT1 = P/ω1, Ft = T1/(d1/2) — required driving force, not a belt-capacity rating.' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: context.tokens.space4),
              ParameterSweepCard(
                variableLabel: 'Center distance, C',
                variableCategory: UnitCategory.length,
                baseValueSI: c,
                outputLabel: 'Belt length, L',
                outputCategory: UnitCategory.length,
                compute: (variedC) {
                  final r = BeltDriveCalculator.calculate(BeltDriveInput(
                    smallPulleyDiameter: d1,
                    largePulleyDiameter: d2,
                    centerDistance: variedC,
                    inputSpeedRpm: n1,
                  ));
                  return r.beltLength;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(UnitSystem system, NumberPrecisionHelper precs) =>
      shareResult('Belt / Chain Drive', [
        'ratio = ${precs.formatValue(result.ratio)}',
        'n2 = ${_fv(result.outputSpeedRpm, UnitCategory.angularVelocity, system, precs)}',
        'L = ${_fv(result.beltLength, UnitCategory.length, system, precs)}',
        'θ_small = ${precs.formatValue(result.smallWrapAngleDeg)}°, θ_large = ${precs.formatValue(result.largeWrapAngleDeg)}°',
        if (result.drivingTorqueNm != null)
          'T1 = ${_fv(result.drivingTorqueNm!, UnitCategory.torque, system, precs)}',
        if (result.beltPullN != null)
          'Ft = ${_fv(result.beltPullN!, UnitCategory.force, system, precs)}',
      ]);
}
