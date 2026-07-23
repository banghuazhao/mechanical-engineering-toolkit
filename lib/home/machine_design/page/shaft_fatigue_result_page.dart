import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/shaft_fatigue_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class ShaftFatigueResultPage extends StatelessWidget {
  ShaftFatigueResultPage({
    super.key,
    required this.result,
    required this.ma,
    required this.mm,
    required this.ta,
    required this.tm,
    required this.kf,
    required this.kfs,
    required this.se,
    required this.sut,
    required this.n,
  });

  final ShaftFatigueResult result;
  final double ma, mm, ta, tm, kf, kfs, se, sut, n;
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
            onPressed: () =>
                shareResultImage(_exportKey, 'Shaft Fatigue Design'),
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
                title: 'Shaft Fatigue Design (DE-Goodman)',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Required diameter, d',
                    valueSI: result.diameterMm,
                    category: UnitCategory.length,
                  ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'd = { (16n/π)·[ √(4(KfMa)²+3(KfsTa)²)/Se + √(4(KfMm)²+3(KfsTm)²)/Sut ] }^(1/3)\n'
                  'n=${precs.formatValue(n)}, Kf=${precs.formatValue(kf)}, Kfs=${precs.formatValue(kfs)}\n'
                  '= ${precs.formatValue(result.diameterMm)} mm',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: context.tokens.space4),
              ParameterSweepCard(
                variableLabel: 'Target safety factor, n',
                variableCategory: null,
                baseValueSI: n,
                outputLabel: 'Diameter, d',
                outputCategory: UnitCategory.length,
                minSI: n * 0.3,
                maxSI: n * 2,
                compute: (variedN) {
                  final r = ShaftFatigueCalculator.calculate(ShaftFatigueInput(
                    alternatingMoment: ma,
                    meanMoment: mm,
                    alternatingTorque: ta,
                    meanTorque: tm,
                    kf: kf,
                    kfs: kfs,
                    enduranceLimit: se,
                    ultimateStrength: sut,
                    safetyFactor: variedN,
                  ));
                  return r.diameterMm;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(NumberPrecisionHelper precs) =>
      shareResult('Shaft Fatigue Design', [
        'd = ${precs.formatValue(result.diameterMm)} mm',
        '',
        'Calculation:',
        'n=${precs.formatValue(n)}, Kf=${precs.formatValue(kf)}, Kfs=${precs.formatValue(kfs)}, Se=${precs.formatValue(se)} MPa, Sut=${precs.formatValue(sut)} MPa',
        'd = ${precs.formatValue(result.diameterMm)} mm',
      ]);
}
