import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/spring_design_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
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
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();

    return ResultScaffold(
      toolName: S.of(context).Helical_Compression_Spring,
      shareLines: () => _shareLines(precs),
      children: [
        AppSectionCard(
          title: S.of(context).Helical_Compression_Spring,
          child: Column(children: [
            AppCopyableValue(
              label: S.of(context).Spring_Index_C,
              value: precs.formatValue(result.springIndex),
            ),
            AppCopyableValue(
              label: S.of(context).Wahl_Factor_Kw,
              value: precs.formatValue(result.wahlFactor),
            ),
            AppCopyableValue(
              label: S.of(context).Spring_Rate_K,
              value: precs.formatSI(
                  result.rateNPerMm, UnitCategory.distributedLoadSmall, system),
            ),
            AppCopyableValue(
              label: S.of(context).Solid_Height,
              valueSI: result.solidHeightMm,
              category: UnitCategory.length,
            ),
            AppCopyableValue(
              label: S.of(context).Natural_Frequency_Estimate,
              valueSI: result.naturalFrequencyHz,
              category: UnitCategory.frequency,
            ),
            if (result.deflectionMm != null)
              AppCopyableValue(
                label: S.of(context).Deflection_Delta,
                valueSI: result.deflectionMm,
                category: UnitCategory.length,
              ),
            if (result.shearStressMPa != null)
              AppCopyableValue(
                label: S.of(context).Shear_Stress_Tau,
                valueSI: result.shearStressMPa,
                category: UnitCategory.stress,
              ),
          ]),
        ),
        FormulaCard(steps: [
          'C = D/d = ${precs.formatValue(result.springIndex)}',
          'Kw = (4C−1)/(4C−4) + 0.615/C = ${precs.formatValue(result.wahlFactor)}',
          'k = G·d⁴/(8·D³·Na)',
          'Solid height = (Na+2)·d',
          'f ≈ (d/2πD²Na)·√(G/2ρ)  — both-ends-fixed estimate',
          if (result.shearStressMPa != null) 'τ = Kw·8F·D/(π·d³)',
        ]),
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

  List<String> _shareLines(NumberPrecisionHelper precs) => [
        'C = ${precs.formatValue(result.springIndex)}',
        'Kw = ${precs.formatValue(result.wahlFactor)}',
        'k = ${precs.formatValue(result.rateNPerMm)} N/mm',
        'Solid height = ${precs.formatValue(result.solidHeightMm)} mm',
        'f ≈ ${precs.formatValue(result.naturalFrequencyHz)} Hz',
        if (result.deflectionMm != null)
          'δ = ${precs.formatValue(result.deflectionMm)} mm',
        if (result.shearStressMPa != null)
          'τ = ${precs.formatValue(result.shearStressMPa)} MPa',
      ];
}
