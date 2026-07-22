import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/principal_stress_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class CombinedLoadingResultPage extends StatelessWidget {
  CombinedLoadingResultPage({
    super.key,
    required this.title,
    required this.sigma,
    required this.tau,
    this.yieldStrength,
  });

  final String title;
  final double sigma;
  final double tau;
  final double? yieldStrength;
  final _exportKey = GlobalKey();

  String _f(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_f(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final principal = PrincipalStressCalculator.calculate(
      sigmaX: sigma,
      sigmaY: 0,
      tauXY: tau,
    );
    final vonMises = sqrt(sigma * sigma + 3 * tau * tau);
    final fos = yieldStrength == null ? null : yieldStrength! / vonMises;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            tooltip: 'Share results',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _share(system, principal, vonMises, fos),
          ),
          IconButton(
            tooltip: 'Share as image',
            icon: const Icon(Icons.image_outlined),
            onPressed: () => shareResultImage(_exportKey, title),
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
                title: title,
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Normal stress, σ',
                    valueSI: sigma,
                    category: UnitCategory.stress,
                  ),
                  AppCopyableValue(
                    label: 'Shear stress, τ',
                    valueSI: tau,
                    category: UnitCategory.stress,
                  ),
                  AppCopyableValue(
                    label: 'von Mises stress, σ′',
                    valueSI: vonMises,
                    category: UnitCategory.stress,
                  ),
                  if (fos != null)
                    AppCopyableValue(
                      label: 'Factor of safety, n',
                      value: _f(fos),
                    ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Principal Stresses at this Point',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'σ1',
                    valueSI: principal.sigma1,
                    category: UnitCategory.stress,
                  ),
                  AppCopyableValue(
                    label: 'σ2',
                    valueSI: principal.sigma2,
                    category: UnitCategory.stress,
                  ),
                  AppCopyableValue(
                    label: 'τmax',
                    valueSI: principal.tauMax,
                    category: UnitCategory.stress,
                  ),
                  AppCopyableValue(
                    label: 'θp',
                    valueSI: principal.thetaP,
                    category: UnitCategory.angle,
                  ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              CalculationCard(steps: [
                'σ = P/A + M·c/I = ${_fv(sigma, UnitCategory.stress, system)}',
                'τ = T·r/J = ${_fv(tau, UnitCategory.stress, system)}',
                "σ' = √(σ² + 3τ²) = ${_fv(vonMises, UnitCategory.stress, system)}",
                if (fos != null) 'n = Sy/σ\' = ${_f(fos)}',
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _share(UnitSystem system, PrincipalStressResult principal,
          double vonMises, double? fos) =>
      shareResult(title, [
        'σ = ${_fv(sigma, UnitCategory.stress, system)}',
        'τ = ${_fv(tau, UnitCategory.stress, system)}',
        "σ' = ${_fv(vonMises, UnitCategory.stress, system)}",
        if (fos != null) 'n = ${_f(fos)}',
        'σ1 = ${_fv(principal.sigma1, UnitCategory.stress, system)}',
        'σ2 = ${_fv(principal.sigma2, UnitCategory.stress, system)}',
        'τmax = ${_fv(principal.tauMax, UnitCategory.stress, system)}',
      ]);
}
