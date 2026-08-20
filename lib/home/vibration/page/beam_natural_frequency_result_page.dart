import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/model/beam_natural_frequency_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/page/beam_natural_frequency_page.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BeamNaturalFrequencyResultPage extends StatelessWidget {
  const BeamNaturalFrequencyResultPage({
    super.key,
    required this.result,
    required this.endCondition,
    required this.e,
    required this.i,
    required this.a,
    required this.length,
    required this.density,
  });

  final BeamNaturalFrequencyResult result;
  final BeamEndCondition endCondition;

  /// The inputs, in the app's SI display units, kept so the sweep can re-run
  /// the same calculation with one of them varied.
  final double e, i, a, length, density;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final fundamental = result.fundamental;
    final steps = _steps(context, system, precs);

    return ResultScaffold(
      toolName: l10n.Beam_Natural_Frequency,
      formulaSteps: steps,
      results: [
        ResultSection(
          title: l10n.Vibration_Modes,
          values: [
            for (final mode in result.modes)
              ResultValue(
                label: l10n.Mode_Number(mode.order),
                valueSI: mode.frequencyHz,
                category: UnitCategory.frequency,
              ),
          ],
        ),
        ResultSection(
          title: l10n.Mode_Number(fundamental.order),
          values: [
            ResultValue(
              label: l10n.Natural_Frequency_F,
              valueSI: fundamental.frequencyHz,
              category: UnitCategory.frequency,
            ),
            ResultValue(
              label: l10n.Circular_Frequency_Omega,
              valueSI: fundamental.omegaRadPerS,
              category: UnitCategory.angularFrequency,
            ),
            ResultValue(
              label: l10n.Equivalent_Shaft_Speed,
              valueSI: fundamental.rpm,
              category: UnitCategory.angularVelocity,
            ),
            ResultValue(
              label: l10n.Beam_Mode_Constant,
              valueSI: fundamental.betaL,
            ),
          ],
        ),
        ResultSection(
          title: l10n.Beam_Properties,
          values: [
            ResultValue(
              label: l10n.Mass_Per_Length,
              valueSI: result.massPerLength,
              category: UnitCategory.linearDensity,
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: steps, tex: r'''f_n = \frac{(\beta_n L)^2}{2\pi L^2}\sqrt{\frac{EI}{\rho A}}'''),
        ParameterSweepCard(
          variableLabel: l10n.Beam_Length_L,
          variableCategory: UnitCategory.span,
          baseValueSI: length,
          outputLabel: l10n.Natural_Frequency_F,
          outputCategory: UnitCategory.frequency,
          // A beam's fundamental goes as 1/L², so the interesting shape is
          // to either side of the length actually entered.
          minSI: length * 0.5,
          maxSI: length * 1.5,
          compute: (variedLength) =>
              BeamNaturalFrequencyCalculator.calculate(
                modulusGPa: e,
                momentOfInertiaMm4: i,
                areaMm2: a,
                lengthM: variedLength,
                densityKgM3: density,
                endCondition: endCondition,
              ).fundamental.frequencyHz,
        ),
      ],
    );
  }

  List<String> _steps(
    BuildContext context,
    UnitSystem system,
    NumberPrecisionHelper precs,
  ) {
    final l10n = S.of(context);
    return [
      'fn = (βL)ₙ²/(2π)·√(EI/(ρA·L⁴)) — '
          '${beamEndConditionLabel(context, endCondition)}',
      '${l10n.Flexural_Rigidity_EI} = '
          '${precs.formatValue(result.flexuralRigidity)} N·m²',
      '${l10n.Mass_Per_Length} = '
          '${precs.formatSI(result.massPerLength, UnitCategory.linearDensity, system)}',
      for (final mode in result.modes)
        '${l10n.Mode_Number(mode.order)}: βL = ${formatFixed4(mode.betaL)} → '
            'f = ${precs.formatSI(mode.frequencyHz, UnitCategory.frequency, system)}',
    ];
  }
}
