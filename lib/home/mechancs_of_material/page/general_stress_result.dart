import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class GeneralStressResultPage extends StatelessWidget {
  GeneralStressResultPage({
    super.key,
    required this.sigma,
    required this.f,
    required this.a,
  });

  final double sigma;
  final double f;
  final double a;
  final _exportKey = GlobalKey();

  String _f(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_f(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            tooltip: 'Share results',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _share(system),
          ),
          IconButton(
            tooltip: 'Share as image',
            icon: const Icon(Icons.image_outlined),
            onPressed: () => shareResultImage(_exportKey, 'General Stress'),
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
                title: 'General Stress',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Stress, σ',
                    valueSI: sigma,
                    category: UnitCategory.stress,
                  ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'σ = F / A\n'
                  '= ${_fv(f, UnitCategory.force, system)} / ${_fv(a, UnitCategory.area, system)}\n'
                  '= ${_fv(sigma, UnitCategory.stress, system)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: context.tokens.space4),
              ParameterSweepCard(
                variableLabel: 'Force, F',
                variableCategory: UnitCategory.force,
                baseValueSI: f,
                outputLabel: 'σ',
                outputCategory: UnitCategory.stress,
                compute: (variedF) => variedF / a,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(UnitSystem system) => shareResult('General Stress', [
        'σ = ${_fv(sigma, UnitCategory.stress, system)}',
        '',
        'Calculation:',
        'σ = F / A',
        '= ${_fv(f, UnitCategory.force, system)} / ${_fv(a, UnitCategory.area, system)}',
        '= ${_fv(sigma, UnitCategory.stress, system)}',
      ]);
}
