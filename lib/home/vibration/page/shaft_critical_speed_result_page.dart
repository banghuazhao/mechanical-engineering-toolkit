import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/model/shaft_critical_speed_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/page/shaft_critical_speed_page.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class ShaftCriticalSpeedResultPage extends StatelessWidget {
  const ShaftCriticalSpeedResultPage({
    super.key,
    required this.result,
    required this.support,
    required this.e,
    required this.diameter,
    required this.span,
    required this.rotorMass,
    required this.rotorPosition,
    required this.density,
  });

  final ShaftCriticalSpeedResult result;
  final ShaftSupport support;

  /// The inputs, in the app's SI display units, kept so the sweep can re-run
  /// the same calculation with one of them varied.
  final double e, diameter, span, rotorMass, rotorPosition;
  final double? density;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final steps = _steps(context, system, precs);
    final shaftFrequency = result.shaftFrequencyHz;

    return ResultScaffold(
      toolName: l10n.Shaft_Critical_Speed,
      formulaSteps: steps,
      results: [
        ResultSection(
          title: l10n.Shaft_Critical_Speed,
          values: [
            ResultValue(
              label: l10n.Critical_Speed_Nc,
              valueSI: result.criticalSpeedRpm,
              category: UnitCategory.angularVelocity,
            ),
            ResultValue(
              label: l10n.Natural_Frequency_F,
              valueSI: result.criticalFrequencyHz,
              category: UnitCategory.frequency,
            ),
          ],
        ),
        // Only worth a card once there are two terms to superpose: with the
        // shaft's mass left out, the rotor term *is* the answer above.
        if (shaftFrequency != null)
          ResultSection(
            title: l10n.Contributing_Frequencies,
            values: [
              ResultValue(
                label: l10n.Rotor_Alone_Frequency,
                valueSI: result.rotorFrequencyHz,
                category: UnitCategory.frequency,
              ),
              ResultValue(
                label: l10n.Shaft_Alone_Frequency,
                valueSI: shaftFrequency,
                category: UnitCategory.frequency,
              ),
            ],
          ),
        ResultSection(
          title: l10n.Shaft_And_Rotor,
          values: [
            ResultValue(
              label: l10n.Shaft_Stiffness_K,
              // Reported per millimetre, the scale a shaft stiffness is
              // usually quoted at — k itself comes back in N/m.
              valueSI: result.stiffnessNPerM / 1000,
              category: UnitCategory.distributedLoadSmall,
            ),
            ResultValue(
              label: l10n.Static_Deflection_Delta,
              valueSI: result.staticDeflectionMm,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Second_Moment_I,
              valueSI: result.momentOfInertiaMm4,
              category: UnitCategory.momentOfInertia,
            ),
            if (density != null)
              ResultValue(
                label: l10n.Shaft_Mass,
                valueSI: result.shaftMassKg,
                category: UnitCategory.mass,
              ),
          ],
        ),
      ],
      children: [
        FormulaCard(steps: steps, tex: r'''\begin{aligned}\omega_r&=\sqrt{\frac{k}{m}}\\\frac{1}{\omega_c^{2}}&=\frac{1}{\omega_r^{2}}+\frac{1}{\omega_s^{2}}\\N_c&=\frac{60\,\omega_c}{2\pi}\end{aligned}'''),
        ParameterSweepCard(
          variableLabel: l10n.Shaft_Diameter_D,
          variableCategory: UnitCategory.length,
          baseValueSI: diameter,
          outputLabel: l10n.Critical_Speed_Nc,
          outputCategory: UnitCategory.angularVelocity,
          // Diameter is the lever a designer actually has here: stiffness
          // goes as d⁴ while the shaft's own mass only goes as d².
          minSI: diameter * 0.5,
          maxSI: diameter * 1.5,
          compute: (variedDiameter) =>
              ShaftCriticalSpeedCalculator.calculate(
                modulusGPa: e,
                diameterMm: variedDiameter,
                spanM: span,
                rotorMassKg: rotorMass,
                rotorPositionM: rotorPosition,
                support: support,
                densityKgM3: density,
              ).criticalSpeedRpm,
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
    final shaftFrequency = result.shaftFrequencyHz;
    return [
      'ωrotor = √(k/m) — ${shaftSupportLabel(context, support)}',
      '${l10n.Shaft_Stiffness_K} = '
          '${precs.formatValue(result.stiffnessNPerM)} N/m',
      '${l10n.Rotor_Alone_Frequency} = '
          '${precs.formatSI(result.rotorFrequencyHz, UnitCategory.frequency, system)}',
      if (shaftFrequency != null) ...[
        '${l10n.Shaft_Alone_Frequency} = '
            '${precs.formatSI(shaftFrequency, UnitCategory.frequency, system)}',
        '1/ωc² = 1/ωrotor² + 1/ωshaft²',
      ],
      'Nc = 60·fc = '
          '${precs.formatSI(result.criticalSpeedRpm, UnitCategory.angularVelocity, system)}',
    ];
  }
}
