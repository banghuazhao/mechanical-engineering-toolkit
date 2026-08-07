import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/spring_design_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class SpringDesignResultPage extends StatelessWidget {
  const SpringDesignResultPage({
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

  @override
  Widget build(BuildContext context) {
    final precs = context.watch<NumberPrecisionHelper>();
    // Shared by the on-screen FormulaCard and the PDF report, so the two
    // cannot drift.
    final formulaSteps = [
      'C = D/d = ${precs.formatValue(result.springIndex)}',
      'Kw = (4C−1)/(4C−4) + 0.615/C = ${precs.formatValue(result.wahlFactor)}',
      'k = G·d⁴/(8·D³·Na)',
      'Solid height = (Na+2)·d',
      'f ≈ (d/2πD²Na)·√(G/2ρ)  — both-ends-fixed estimate',
      if (result.shearStressMPa != null) 'τ = Kw·8F·D/(π·d³)',
    ];

    return ResultScaffold(
      formulaSteps: formulaSteps,
      toolName: S.of(context).Helical_Compression_Spring,
      results: [
        ResultSection(
          title: S.of(context).Helical_Compression_Spring,
          values: [
            ResultValue(
              label: S.of(context).Spring_Index_C,
              valueSI: result.springIndex,
            ),
            ResultValue(
              label: S.of(context).Wahl_Factor_Kw,
              valueSI: result.wahlFactor,
            ),
            ResultValue(
              label: S.of(context).Spring_Rate_K,
              valueSI: result.rateNPerMm,
              category: UnitCategory.distributedLoadSmall,
            ),
            ResultValue(
              label: S.of(context).Solid_Height,
              valueSI: result.solidHeightMm,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: S.of(context).Natural_Frequency_Estimate,
              valueSI: result.naturalFrequencyHz,
              category: UnitCategory.frequency,
            ),
            if (result.deflectionMm != null)
              ResultValue(
                label: S.of(context).Deflection_Delta,
                valueSI: result.deflectionMm,
                category: UnitCategory.length,
              ),
            if (result.shearStressMPa != null)
              ResultValue(
                label: S.of(context).Shear_Stress_Tau,
                valueSI: result.shearStressMPa,
                category: UnitCategory.stress,
              ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: formulaSteps),
        ParameterSweepCard(
          variableLabel: S.of(context).Wire_Diameter_D,
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
    );
  }

}
