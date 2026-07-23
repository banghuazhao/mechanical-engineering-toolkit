import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/spring_design_calculator.dart';
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

class SpringDesignResultPage extends StatelessWidget {
  SpringDesignResultPage({
    super.key,
    required this.result,
    required this.d,
    required this.coilD,
    required this.na,
    required this.g,
  });

  final SpringDesignResult result;
  final double d;
  final double coilD;
  final double na;
  final double g;
  final _exportKey = GlobalKey();

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
            onPressed: () => _share(precs),
          ),
          IconButton(
            tooltip: 'Share as image',
            icon: const Icon(Icons.image_outlined),
            onPressed: () =>
                shareResultImage(_exportKey, 'Helical Compression Spring'),
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
                title: 'Helical Compression Spring',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Spring index, C',
                    value: precs.formatValue(result.springIndex),
                  ),
                  AppCopyableValue(
                    label: 'Wahl factor, Kw',
                    value: precs.formatValue(result.wahlFactor),
                  ),
                  AppCopyableValue(
                    label: 'Rate, k',
                    value:
                        '${precs.formatValue(fromSI(result.rateNPerMm, UnitCategory.distributedLoadSmall, system))} ${unitLabel(UnitCategory.distributedLoadSmall, system)}',
                  ),
                  AppCopyableValue(
                    label: 'Solid height',
                    valueSI: result.solidHeightMm,
                    category: UnitCategory.length,
                  ),
                  AppCopyableValue(
                    label: 'Natural frequency (estimate)',
                    valueSI: result.naturalFrequencyHz,
                    category: UnitCategory.frequency,
                  ),
                  if (result.deflectionMm != null)
                    AppCopyableValue(
                      label: 'Deflection, δ',
                      valueSI: result.deflectionMm,
                      category: UnitCategory.length,
                    ),
                  if (result.shearStressMPa != null)
                    AppCopyableValue(
                      label: 'Shear stress, τ',
                      valueSI: result.shearStressMPa,
                      category: UnitCategory.stress,
                    ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'C = D/d = ${precs.formatValue(result.springIndex)}\n'
                  'Kw = (4C−1)/(4C−4) + 0.615/C = ${precs.formatValue(result.wahlFactor)}\n'
                  'k = G·d⁴/(8·D³·Na)\n'
                  'Solid height = (Na+2)·d\n'
                  'f ≈ (d/2πD²Na)·√(G/2ρ)  — both-ends-fixed estimate'
                  '${result.shearStressMPa != null ? '\nτ = Kw·8F·D/(π·d³)' : ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: context.tokens.space4),
              ParameterSweepCard(
                variableLabel: 'Wire diameter, d',
                variableCategory: UnitCategory.length,
                baseValueSI: d,
                outputLabel: 'Rate, k (N/mm)',
                outputCategory: null,
                compute: (variedD) {
                  final r = SpringDesignCalculator.calculate(SpringDesignInput(
                    wireDiameter: variedD,
                    coilDiameter: coilD,
                    activeCoils: na,
                    shearModulusGPa: g,
                  ));
                  return r.rateNPerMm;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(NumberPrecisionHelper precs) => shareResult(
        'Helical Compression Spring',
        [
          'C = ${precs.formatValue(result.springIndex)}',
          'Kw = ${precs.formatValue(result.wahlFactor)}',
          'k = ${precs.formatValue(result.rateNPerMm)} N/mm',
          'Solid height = ${precs.formatValue(result.solidHeightMm)} mm',
          'f ≈ ${precs.formatValue(result.naturalFrequencyHz)} Hz',
          if (result.deflectionMm != null)
            'δ = ${precs.formatValue(result.deflectionMm)} mm',
          if (result.shearStressMPa != null)
            'τ = ${precs.formatValue(result.shearStressMPa)} MPa',
        ],
      );
}
