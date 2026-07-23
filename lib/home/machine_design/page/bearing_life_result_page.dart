import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/bearing_life_calculator.dart';
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

class BearingLifeResultPage extends StatelessWidget {
  BearingLifeResultPage({
    super.key,
    required this.result,
    required this.c,
    required this.p,
    required this.rpm,
    required this.type,
  });

  final BearingLifeResult result;
  final double c;
  final double p;
  final double rpm;
  final BearingType type;
  final _exportKey = GlobalKey();

  String _fv(double valueSI, UnitCategory category, UnitSystem system,
          NumberPrecisionHelper precs) =>
      '${precs.formatValue(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final exponent = type.exponent;

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
            onPressed: () => shareResultImage(_exportKey, 'Bearing L10 Life'),
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
                title: 'Bearing L10 Life',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'L10 (million revolutions)',
                    value: precs.formatValue(result.l10Million),
                  ),
                  AppCopyableValue(
                    label: 'L10 (hours)',
                    value: precs.formatValue(result.l10Hours),
                  ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'L10 = (C/P)^p, ${type.label}\n'
                  '= (${_fv(c, UnitCategory.forceStructural, system, precs)} / ${_fv(p, UnitCategory.forceStructural, system, precs)})^${precs.formatValue(exponent)}\n'
                  '= ${precs.formatValue(result.l10Million)} million rev\n'
                  'L10h = L10 × 1e6 / (60 × n) = ${precs.formatValue(result.l10Hours)} h',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: context.tokens.space4),
              ParameterSweepCard(
                variableLabel: 'Equivalent load, P',
                variableCategory: UnitCategory.forceStructural,
                baseValueSI: p,
                outputLabel: 'L10 (hours)',
                outputCategory: null,
                compute: (variedP) {
                  final l10 = math.pow(c / variedP, exponent).toDouble();
                  return l10 * 1e6 / (60 * rpm);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(UnitSystem system, NumberPrecisionHelper precs) =>
      shareResult('Bearing L10 Life', [
        'L10 = ${precs.formatValue(result.l10Million)} million rev',
        'L10h = ${precs.formatValue(result.l10Hours)} h',
        '',
        'Calculation:',
        'L10 = (C/P)^p, ${type.label}',
        '= (${_fv(c, UnitCategory.forceStructural, system, precs)} / ${_fv(p, UnitCategory.forceStructural, system, precs)})^${precs.formatValue(type.exponent)}',
        '= ${precs.formatValue(result.l10Million)} million rev',
      ]);
}
