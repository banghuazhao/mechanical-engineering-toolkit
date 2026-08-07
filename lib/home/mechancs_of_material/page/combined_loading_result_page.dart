import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/principal_stress_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
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

    final formulaSteps = [
      'σ = P/A + M·c/I = ${formatFixedSI(sigma, UnitCategory.stress, system)}',
      'τ = T·r/J = ${formatFixedSI(tau, UnitCategory.stress, system)}',
      "σ' = √(σ² + 3τ²) = ${formatFixedSI(vonMises, UnitCategory.stress, system)}",
      if (fos != null) 'n = Sy/σ\' = ${formatFixed(fos)}',
    ];

    return ResultScaffold(
      toolName: title,
      formulaSteps: formulaSteps,
      leading: [ToolResultHeader(tool: tool)],
      results: [
        ResultSection(
          title: title,
          values: [
            ResultValue(
              label: 'Normal stress, σ',
              valueSI: sigma,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: 'Shear stress, τ',
              valueSI: tau,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: 'von Mises stress, σ′',
              valueSI: vonMises,
              category: UnitCategory.stress,
            ),
            if (fos != null)
              ResultValue(
                label: 'Factor of safety, n',
                valueSI: fos,
              ),
          ],
        ),
        ResultSection(
          title: 'Principal Stresses at this Point',
          values: [
            ResultValue(
              label: 'σ1',
              valueSI: principal.sigma1,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: 'σ2',
              valueSI: principal.sigma2,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: 'τmax',
              valueSI: principal.tauMax,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: 'θp',
              valueSI: principal.thetaP,
              category: UnitCategory.angle,
            ),
          ],
        ),
      ],
      children: [
        CalculationCard(steps: formulaSteps),
      ],
    );
  }
}
