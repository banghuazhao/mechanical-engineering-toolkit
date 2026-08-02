import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/principal_stress_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class CombinedLoadingResultPage extends StatelessWidget {
  CombinedLoadingResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.sigma,
    required this.tau,
    this.yieldStrength,
  });

  final int toolId;
  final String title;
  final double sigma;
  final double tau;
  final double? yieldStrength;
  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final tool = ToolLibrary.shared.item(toolId, context);
    final principal = PrincipalStressCalculator.calculate(
      sigmaX: sigma,
      sigmaY: 0,
      tauXY: tau,
    );
    final vonMises = sqrt(sigma * sigma + 3 * tau * tau);
    final fos = yieldStrength == null ? null : yieldStrength! / vonMises;

    return ResultScaffold(
      toolName: title,
      shareLines: () => _shareLines(system, principal, vonMises, fos),
      children: [
        ToolResultHeader(tool: tool),
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
                value: formatFixed(fos),
              ),
          ]),
        ),
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
        CalculationCard(steps: [
          'σ = P/A + M·c/I = ${formatFixedSI(sigma, UnitCategory.stress, system)}',
          'τ = T·r/J = ${formatFixedSI(tau, UnitCategory.stress, system)}',
          "σ' = √(σ² + 3τ²) = ${formatFixedSI(vonMises, UnitCategory.stress, system)}",
          if (fos != null) 'n = Sy/σ\' = ${formatFixed(fos)}',
        ]),
      ],
    );
  }

  List<String> _shareLines(UnitSystem system, PrincipalStressResult principal,
          double vonMises, double? fos) =>
      [
        'σ = ${formatFixedSI(sigma, UnitCategory.stress, system)}',
        'τ = ${formatFixedSI(tau, UnitCategory.stress, system)}',
        "σ' = ${formatFixedSI(vonMises, UnitCategory.stress, system)}",
        if (fos != null) 'n = ${formatFixed(fos)}',
        'σ1 = ${formatFixedSI(principal.sigma1, UnitCategory.stress, system)}',
        'σ2 = ${formatFixedSI(principal.sigma2, UnitCategory.stress, system)}',
        'τmax = ${formatFixedSI(principal.tauMax, UnitCategory.stress, system)}',
      ];
}
