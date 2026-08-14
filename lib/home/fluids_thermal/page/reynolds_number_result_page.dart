import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/pipe_flow_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class ReynoldsNumberResultPage extends StatelessWidget {
  const ReynoldsNumberResultPage({
    super.key,
    required this.result,
    required this.diameter,
    required this.density,
    required this.viscosity,
  });

  final ReynoldsResult result;
  final double diameter;
  final double density;
  final double viscosity;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final steps = _steps(context, system, precs);

    return ResultScaffold(
      toolName: l10n.Reynolds_Number,
      formulaSteps: steps,
      results: [
        ResultSection(
          title: l10n.Reynolds_Number,
          values: [
            ResultValue(
              label: l10n.Reynolds_Number_Re,
              valueSI: result.reynolds,
            ),
            ResultValue(
              label: l10n.Flow_Regime,
              value: result.regime.label(context),
            ),
            ResultValue(
              label: l10n.Flow_Velocity_V,
              valueSI: result.velocity,
              category: UnitCategory.velocity,
            ),
            ResultValue(
              label: l10n.Flow_Rate_Q,
              valueSI: result.flowRate,
              category: UnitCategory.volumeFlow,
            ),
            ResultValue(
              label: l10n.Flow_Area,
              valueSI: result.area,
              category: UnitCategory.area,
            ),
            ResultValue(
              // ν is m²/s in both systems here — there is no second unit pair
              // for it, so it is formatted rather than given a category.
              label: l10n.Kinematic_Viscosity,
              value: '${result.kinematicViscosity.toStringAsExponential(3)} '
                  'm²/s',
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: steps),
        ParameterSweepCard(
          variableLabel: l10n.Flow_Velocity_V,
          variableCategory: UnitCategory.velocity,
          baseValueSI: result.velocity,
          outputLabel: l10n.Reynolds_Number_Re,
          outputCategory: null,
          compute: (variedVelocity) => reynoldsNumber(
            velocity: variedVelocity,
            diameter: diameter / 1000,
            density: density,
            viscosity: viscosity,
          ),
        ),
      ],
    );
  }

  List<String> _steps(
    BuildContext context,
    UnitSystem system,
    NumberPrecisionHelper precs,
  ) =>
      [
        'Re = ρ·V·D / μ',
        '= ${precs.formatSI(density, UnitCategory.density, system)} × '
            '${precs.formatSI(result.velocity, UnitCategory.velocity, system)} × '
            '${precs.formatSI(diameter, UnitCategory.length, system)} / '
            '${precs.formatSmallSI(viscosity, UnitCategory.dynamicViscosity, system)}',
        '= ${precs.formatValue(result.reynolds)} '
            '(${result.regime.label(context)})',
        'ν = μ/ρ = ${result.kinematicViscosity.toStringAsExponential(3)} m²/s',
      ];
}
