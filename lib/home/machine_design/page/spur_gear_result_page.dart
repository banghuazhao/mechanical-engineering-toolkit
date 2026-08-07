import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/spur_gear_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

class SpurGearResultPage extends StatelessWidget {
  const SpurGearResultPage({
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

  @override
  Widget build(BuildContext context) {
    const formulaSteps = [
      'd1=m·N1, d2=m·N2, C=(d1+d2)/2, mG=N2/N1',
      'σ = Wt/(F·m·Y)  (Lewis bending, 20° full-depth)',
      'σc ≈ Cp·√[(Wt/(F·d1))·(mG+1)/mG]  — simplified estimate, not full AGMA',
    ];

    return ResultScaffold(
      toolName: S.of(context).Spur_Gear_Geometry,
      formulaSteps: formulaSteps,
      results: [
        ResultSection(
          title: S.of(context).Spur_Gear_Geometry,
          values: [
            ResultValue(
              label: S.of(context).Pinion_Pitch_Diameter_D1,
              valueSI: result.pinionPitchDiameter,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: S.of(context).Gear_Pitch_Diameter_D2,
              valueSI: result.gearPitchDiameter,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: S.of(context).Center_Distance,
              valueSI: result.centerDistance,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: S.of(context).Gear_Ratio,
              valueSI: result.gearRatio,
            ),
            ResultValue(
              label: S.of(context).Lewis_Form_Factor_Y,
              valueSI: result.lewisFormFactor,
            ),
            if (result.bendingStressMPa != null)
              ResultValue(
                label: S.of(context).Bending_Stress_Pinion,
                valueSI: result.bendingStressMPa,
                category: UnitCategory.stress,
              ),
            if (result.contactStressMPa != null)
              ResultValue(
                label: S.of(context).Contact_Stress_Est,
                valueSI: result.contactStressMPa,
                category: UnitCategory.stress,
              ),
          ],
        ),
      ],
      children: [
        const FormulaCard(steps: formulaSteps),
        if (result.bendingStressMPa != null)
          ParameterSweepCard(
            variableLabel: S.of(context).Face_Width_F,
            variableCategory: UnitCategory.length,
            baseValueSI: faceWidth,
            outputLabel: 'σ (bending)',
            outputCategory: UnitCategory.stress,
            compute: (variedF) =>
                wt! / (variedF * module * result.lewisFormFactor),
          ),
      ],
    );
  }
}
