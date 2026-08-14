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

class PipePressureDropResultPage extends StatelessWidget {
  const PipePressureDropResultPage({
    super.key,
    required this.input,
    required this.result,
  });

  final PipeFlowInput input;
  final PipeFlowResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final steps = _steps(context, system, precs);

    return ResultScaffold(
      toolName: l10n.Pipe_Pressure_Drop,
      formulaSteps: steps,
      results: [
        ResultSection(
          title: l10n.Pipe_Pressure_Drop,
          values: [
            ResultValue(
              label: l10n.Pressure_Drop,
              valueSI: result.pressureDrop,
              category: UnitCategory.pressure,
            ),
            ResultValue(
              label: l10n.Total_Head_Loss,
              valueSI: result.totalHeadLoss,
              category: UnitCategory.span,
            ),
            ResultValue(
              label: l10n.Friction_Head_Loss,
              valueSI: result.frictionHeadLoss,
              category: UnitCategory.span,
            ),
            ResultValue(
              label: l10n.Minor_Head_Loss,
              valueSI: result.minorHeadLoss,
              category: UnitCategory.span,
            ),
          ],
        ),
        ResultSection(
          title: l10n.Flow_Regime,
          values: [
            ResultValue(
              label: l10n.Flow_Velocity_V,
              valueSI: result.velocity,
              category: UnitCategory.velocity,
            ),
            ResultValue(
              label: l10n.Reynolds_Number_Re,
              valueSI: result.reynolds,
            ),
            ResultValue(
              label: l10n.Flow_Regime,
              value: result.regime.label(context),
            ),
            ResultValue(
              label: l10n.Friction_Factor_f,
              valueSI: result.frictionFactor,
            ),
            ResultValue(
              label: l10n.Relative_Roughness,
              value: result.relativeRoughness.toStringAsExponential(3),
            ),
            ResultValue(
              label: l10n.Velocity_Head,
              valueSI: result.velocityHead,
              category: UnitCategory.span,
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: steps),
        ParameterSweepCard(
          variableLabel: l10n.Inside_Diameter_D,
          variableCategory: UnitCategory.length,
          baseValueSI: input.diameter,
          outputLabel: l10n.Pressure_Drop,
          outputCategory: UnitCategory.pressure,
          // Bore is the lever worth sweeping: Δp goes roughly as 1/D⁵, so the
          // curve shows immediately how much a size up buys.
          compute: (variedDiameter) => PipeFlowCalculator.calculate(
            PipeFlowInput(
              diameter: variedDiameter,
              length: input.length,
              flowRate: input.flowRate,
              density: input.density,
              viscosity: input.viscosity,
              roughness: input.roughness,
              minorLossK: input.minorLossK,
            ),
          ).pressureDrop,
        ),
      ],
    );
  }

  List<String> _steps(
    BuildContext context,
    UnitSystem system,
    NumberPrecisionHelper precs,
  ) {
    String span(double v) => precs.formatSI(v, UnitCategory.span, system);
    return [
      'V = Q/A = '
          '${precs.formatSI(result.velocity, UnitCategory.velocity, system)}',
      'Re = ρVD/μ = ${precs.formatValue(result.reynolds)} '
          '(${result.regime.label(context)})',
      if (result.regime == FlowRegime.laminar)
        'f = 64/Re = ${precs.formatValue(result.frictionFactor)}'
      else
        'f from Colebrook, ε/D = '
            '${result.relativeRoughness.toStringAsExponential(3)}'
            ' → f = ${precs.formatValue(result.frictionFactor)}',
      'V²/2g = ${span(result.velocityHead)}',
      'h_f = f·(L/D)·V²/2g = ${span(result.frictionHeadLoss)}',
      'h_minor = ΣK·V²/2g = ${precs.formatValue(input.minorLossK)} × '
          '${span(result.velocityHead)} = ${span(result.minorHeadLoss)}',
      'h_total = ${span(result.totalHeadLoss)}',
      'Δp = ρ·g·h_total = '
          '${precs.formatSI(result.pressureDrop, UnitCategory.pressure, system)}',
    ];
  }
}
