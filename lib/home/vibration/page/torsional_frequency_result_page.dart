import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/model/torsional_frequency_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/page/torsional_frequency_page.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class TorsionalFrequencyResultPage extends StatelessWidget {
  const TorsionalFrequencyResultPage({
    super.key,
    required this.result,
    required this.system,
    required this.g,
    required this.diameter,
    required this.length,
    required this.j1,
    required this.j2,
  });

  final TorsionalFrequencyResult result;
  final TorsionalSystem system;

  /// The inputs, in the app's SI display units, kept so the sweep can re-run
  /// the same calculation with one of them varied.
  final double g, diameter, length, j1;
  final double? j2;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final unitSystem = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final steps = _steps(context, unitSystem, precs);
    final node = result.nodeFromFirstRotorM;

    return ResultScaffold(
      toolName: l10n.Torsional_Natural_Frequency,
      formulaSteps: steps,
      results: [
        ResultSection(
          title: l10n.Torsional_Natural_Frequency,
          values: [
            ResultValue(
              label: l10n.Natural_Frequency_F,
              valueSI: result.frequencyHz,
              category: UnitCategory.frequency,
            ),
            ResultValue(
              label: l10n.Circular_Frequency_Omega,
              valueSI: result.omegaRadPerS,
              category: UnitCategory.angularFrequency,
            ),
            ResultValue(
              label: l10n.Equivalent_Shaft_Speed,
              valueSI: result.rpm,
              category: UnitCategory.angularVelocity,
            ),
          ],
        ),
        ResultSection(
          title: l10n.Shaft_And_Rotor,
          values: [
            ResultValue(
              label: l10n.Torsional_Stiffness_Kt,
              valueSI: result.stiffnessNmPerRad,
              category: UnitCategory.torque,
            ),
            ResultValue(
              label: l10n.Polar_Moment_Jp,
              valueSI: result.polarMomentMm4,
              category: UnitCategory.momentOfInertia,
            ),
            ResultValue(
              label: l10n.Effective_Inertia_J,
              valueSI: result.effectiveInertia,
              category: UnitCategory.massMomentOfInertia,
            ),
            if (node != null)
              ResultValue(
                label: l10n.Node_Position,
                valueSI: node,
                category: UnitCategory.span,
              ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: steps, tex: r'''\begin{aligned}k_t&=\frac{GJ_p}{L}\\\omega_n&=\sqrt{\frac{k_t}{J_\text{eff}}}\end{aligned}'''),
        ParameterSweepCard(
          variableLabel: l10n.Shaft_Diameter_D,
          variableCategory: UnitCategory.length,
          baseValueSI: diameter,
          outputLabel: l10n.Natural_Frequency_F,
          outputCategory: UnitCategory.frequency,
          // kt goes as d⁴, so the frequency goes as d²: a small change in
          // diameter moves the mode a long way.
          minSI: diameter * 0.5,
          maxSI: diameter * 1.5,
          compute: (variedDiameter) => TorsionalFrequencyCalculator.calculate(
            shearModulusGPa: g,
            diameterMm: variedDiameter,
            lengthM: length,
            firstInertiaKgM2: j1,
            secondInertiaKgM2: j2,
            system: system,
          ).frequencyHz,
        ),
      ],
    );
  }

  List<String> _steps(
    BuildContext context,
    UnitSystem unitSystem,
    NumberPrecisionHelper precs,
  ) {
    final l10n = S.of(context);
    final node = result.nodeFromFirstRotorM;
    return [
      'kt = G·Jp/L, ω = √(kt/Jeff) — '
          '${torsionalSystemLabel(context, system)}',
      '${l10n.Torsional_Stiffness_Kt} = '
          '${precs.formatValue(result.stiffnessNmPerRad)} N·m/rad',
      if (system == TorsionalSystem.twoRotor)
        '${l10n.Effective_Inertia_J} = J1·J2/(J1+J2) = '
            '${precs.formatSI(result.effectiveInertia, UnitCategory.massMomentOfInertia, unitSystem)}',
      'ω = ${precs.formatSI(result.omegaRadPerS, UnitCategory.angularFrequency, unitSystem)}, '
          'f = ${precs.formatSI(result.frequencyHz, UnitCategory.frequency, unitSystem)}',
      if (node != null)
        '${l10n.Node_Position} = L·J2/(J1+J2) = '
            '${precs.formatSI(node, UnitCategory.span, unitSystem)}',
    ];
  }
}
