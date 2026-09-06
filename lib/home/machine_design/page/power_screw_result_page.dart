import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/power_screw_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/page/power_screw_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class PowerScrewResultPage extends StatelessWidget {
  const PowerScrewResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.input,
    required this.result,
  });

  final int toolId;
  final String title;
  final PowerScrewInput input;
  final PowerScrewResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final tool = ToolLibrary.shared.item(toolId, context);
    final yes = l10n.Answer_Yes;
    final no = l10n.Answer_No;

    String torque(double value) =>
        precs.formatSI(value, UnitCategory.torque, system);

    final steps = [
      '${l10n.Thread_Form}: ${threadFormLabel(context, input.form)}, '
          'sec α = ${precs.formatValue(input.form.secantFactor)}',
      'dm = d − p/2 = ${precs.formatSI(result.meanDiameter, UnitCategory.length, system)}',
      'l = n·p = ${precs.formatSI(result.lead, UnitCategory.length, system)}',
      'λ = atan(l / π·dm) = ${precs.formatSI(result.leadAngle, UnitCategory.angle, system)}',
      '',
      'TR = (F·dm/2)·(l + π·μ·dm·secα)/(π·dm − μ·l·secα) + F·μc·dc/2',
      '= ${torque(result.threadTorqueRaising)} + ${torque(result.collarTorque)}'
          ' = ${torque(result.torqueToRaise)}',
      'TL = (F·dm/2)·(π·μ·dm·secα − l)/(π·dm + μ·l·secα) + F·μc·dc/2',
      '= ${torque(result.threadTorqueLowering)} + ${torque(result.collarTorque)}'
          ' = ${torque(result.torqueToLower)}',
      '',
      'e = F·l / (2π·TR) = ${precs.formatValue(result.efficiency * 100)} %',
      // The self-locking test written out, because it is the one line a
      // reader is most likely to want to check by hand.
      'μ·secα ${result.isSelfLocking ? '>' : '≤'} tan λ '
          '→ ${result.isSelfLocking ? yes : no}',
    ];

    return ResultScaffold(
      toolName: title,
      formulaSteps: steps,
      leading: [ToolResultHeader(tool: tool)],
      results: [
        ResultSection(
          title: title,
          values: [
            ResultValue(
              label: l10n.Mean_Diameter_Dm,
              valueSI: result.meanDiameter,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Lead_L,
              valueSI: result.lead,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Lead_Angle_Lambda,
              valueSI: result.leadAngle,
              category: UnitCategory.angle,
            ),
            ResultValue(
              label: l10n.Torque_To_Raise,
              valueSI: result.torqueToRaise,
              category: UnitCategory.torque,
            ),
            ResultValue(
              label: l10n.Torque_To_Lower,
              valueSI: result.torqueToLower,
              category: UnitCategory.torque,
            ),
            ResultValue(
              label: l10n.Thread_Torque_Raise,
              valueSI: result.threadTorqueRaising,
              category: UnitCategory.torque,
            ),
            ResultValue(
              label: l10n.Thread_Torque_Lower,
              valueSI: result.threadTorqueLowering,
              category: UnitCategory.torque,
            ),
            ResultValue(
              label: l10n.Collar_Torque,
              valueSI: result.collarTorque,
              category: UnitCategory.torque,
            ),
            ResultValue(
              label: '${l10n.Screw_Efficiency} (%)',
              valueSI: result.efficiency * 100,
            ),
            // Yes or no rather than a number: these are the two questions the
            // tool exists to answer, and rounding them into a torque loses
            // the answer.
            ResultValue(
              label: l10n.Self_Locking_Thread,
              value: result.isSelfLocking ? yes : no,
            ),
            ResultValue(
              label: l10n.Holds_With_Collar,
              value: result.holdsWithCollar ? yes : no,
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(
          steps: steps,
          tex: r'''\begin{aligned}
T_R &= \frac{F d_m}{2}\left(\frac{l + \pi \mu d_m \sec\alpha}{\pi d_m - \mu l \sec\alpha}\right) + \frac{F \mu_c d_c}{2}\\
T_L &= \frac{F d_m}{2}\left(\frac{\pi \mu d_m \sec\alpha - l}{\pi d_m + \mu l \sec\alpha}\right) + \frac{F \mu_c d_c}{2}\\
e &= \frac{F l}{2\pi T_R}, \qquad \text{self-locking if } \mu\sec\alpha > \tan\lambda
\end{aligned}''',
        ),
        ParameterSweepCard(
          variableLabel: l10n.Thread_Friction_Mu,
          variableCategory: null,
          baseValueSI: input.threadFriction,
          outputLabel: '${l10n.Screw_Efficiency} (%)',
          outputCategory: null,
          // Friction is what the whole answer turns on and the input nobody
          // knows to better than a factor, so it is the one worth sweeping.
          minSI: 0.02,
          maxSI: 0.30,
          compute: (mu) => PowerScrewCalculator.calculate(PowerScrewInput(
                majorDiameter: input.majorDiameter,
                pitch: input.pitch,
                load: input.load,
                form: input.form,
                starts: input.starts,
                threadFriction: mu,
                collarFriction: input.collarFriction,
                collarDiameter: input.collarDiameter,
              )).efficiency *
              100,
        ),
        Text(
          l10n.Power_Screw_Note,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
