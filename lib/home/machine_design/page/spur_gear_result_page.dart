import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/spur_gear_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class SpurGearResultPage extends StatelessWidget {
  SpurGearResultPage({
    super.key,
    required this.result,
    required this.module,
    required this.faceWidth,
    this.wt,
  });

  final SpurGearResult result;
  final double module;
  final double faceWidth;
  final double? wt;
  final _exportKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final precs = context.watch<NumberPrecisionHelper>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            tooltip: 'Share results',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _share(precs),
          ),
          IconButton(
            tooltip: 'Share as image',
            icon: const Icon(Icons.image_outlined),
            onPressed: () => shareResultImage(_exportKey, 'Spur Gear Geometry'),
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
                title: 'Spur Gear Geometry',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Pinion pitch diameter, d1',
                    valueSI: result.pinionPitchDiameter,
                    category: UnitCategory.length,
                  ),
                  AppCopyableValue(
                    label: 'Gear pitch diameter, d2',
                    valueSI: result.gearPitchDiameter,
                    category: UnitCategory.length,
                  ),
                  AppCopyableValue(
                    label: 'Center distance',
                    valueSI: result.centerDistance,
                    category: UnitCategory.length,
                  ),
                  AppCopyableValue(
                    label: 'Gear ratio',
                    value: precs.formatValue(result.gearRatio),
                  ),
                  AppCopyableValue(
                    label: 'Lewis form factor, Y (pinion)',
                    value: precs.formatValue(result.lewisFormFactor),
                  ),
                  if (result.bendingStressMPa != null)
                    AppCopyableValue(
                      label: 'Bending stress, σ (pinion)',
                      valueSI: result.bendingStressMPa,
                      category: UnitCategory.stress,
                    ),
                  if (result.contactStressMPa != null)
                    AppCopyableValue(
                      label: 'Contact stress, σc (est.)',
                      valueSI: result.contactStressMPa,
                      category: UnitCategory.stress,
                    ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'd1=m·N1, d2=m·N2, C=(d1+d2)/2, mG=N2/N1\n'
                  'σ = Wt/(F·m·Y)  (Lewis bending, 20° full-depth)\n'
                  'σc ≈ Cp·√[(Wt/(F·d1))·(mG+1)/mG]  — simplified estimate, not full AGMA',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (result.bendingStressMPa != null) ...[
                SizedBox(height: context.tokens.space4),
                ParameterSweepCard(
                  variableLabel: 'Face width, F',
                  variableCategory: UnitCategory.length,
                  baseValueSI: faceWidth,
                  outputLabel: 'σ (bending)',
                  outputCategory: UnitCategory.stress,
                  compute: (variedF) =>
                      wt! / (variedF * module * result.lewisFormFactor),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _share(NumberPrecisionHelper precs) => shareResult(
        'Spur Gear Geometry',
        [
          'd1 = ${precs.formatValue(result.pinionPitchDiameter)} mm',
          'd2 = ${precs.formatValue(result.gearPitchDiameter)} mm',
          'C = ${precs.formatValue(result.centerDistance)} mm',
          'Ratio = ${precs.formatValue(result.gearRatio)}',
          'Y = ${precs.formatValue(result.lewisFormFactor)}',
          if (result.bendingStressMPa != null)
            'σ = ${precs.formatValue(result.bendingStressMPa)} MPa',
          if (result.contactStressMPa != null)
            'σc ≈ ${precs.formatValue(result.contactStressMPa)} MPa',
        ],
      );
}
