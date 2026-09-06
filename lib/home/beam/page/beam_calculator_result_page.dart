import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/beam_solver.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/beam_calculator_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/xy_diagram_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BeamCalculatorResultPage extends StatelessWidget {
  const BeamCalculatorResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.input,
    required this.result,
    required this.supportCase,
  });

  final int toolId;
  final String title;
  final BeamInput input;
  final BeamResult result;
  final BeamSupportCase supportCase;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final tool = ToolLibrary.shared.item(toolId, context);
    final steps = _steps(context, system, precs);

    return ResultScaffold(
      toolName: title,
      formulaSteps: steps,
      leading: [ToolResultHeader(tool: tool)],
      results: [
        ResultSection(
          title: l10n.Support_Reactions,
          values: [
            for (final reaction in result.reactions) ...[
              ResultValue(
                label: l10n.Reaction_At_X(
                    _position(reaction.position, system, precs)),
                valueSI: reaction.force,
                category: UnitCategory.forceStructural,
              ),
              // A simple support carries no couple, and a row of zeroes in a
              // report is worse than no row at all.
              if (reaction.type == BeamSupportType.fixed)
                ResultValue(
                  label: l10n.Fixing_Moment_At_X(
                      _position(reaction.position, system, precs)),
                  valueSI: reaction.moment,
                  category: UnitCategory.momentStructural,
                ),
            ],
          ],
        ),
        ResultSection(
          title: title,
          values: [
            ResultValue(
              label: l10n.Maximum_Shear,
              valueSI: result.maximumShear.value,
              category: UnitCategory.forceStructural,
            ),
            ResultValue(
              label: '${l10n.Maximum_Shear} @ x',
              valueSI: result.maximumShear.position,
              category: UnitCategory.span,
            ),
            // Magnitude and its location are separate rows: a spreadsheet
            // cannot split "12 kN·m at x = 2 m" back into two numbers.
            ResultValue(
              label: l10n.Maximum_Sagging_Moment,
              valueSI: result.maximumSaggingMoment.value,
              category: UnitCategory.momentStructural,
            ),
            ResultValue(
              label: '${l10n.Maximum_Sagging_Moment} @ x',
              valueSI: result.maximumSaggingMoment.position,
              category: UnitCategory.span,
            ),
            // Kept even when zero: on a simple span its absence is the
            // answer, and a reader scanning for it should see that rather
            // than wonder whether the tool looked.
            ResultValue(
              label: l10n.Maximum_Hogging_Moment,
              valueSI: result.maximumHoggingMoment.value,
              category: UnitCategory.momentStructural,
            ),
            ResultValue(
              label: '${l10n.Maximum_Hogging_Moment} @ x',
              valueSI: result.maximumHoggingMoment.position,
              category: UnitCategory.span,
            ),
            ResultValue(
              label: l10n.Maximum_Downward_Deflection,
              valueSI: result.maximumDeflection.value,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: '${l10n.Maximum_Downward_Deflection} @ x',
              valueSI: result.maximumDeflection.position,
              category: UnitCategory.span,
            ),
            if (result.bendingStress != null)
              ResultValue(
                label: l10n.Bending_Stress_At_Mmax,
                valueSI: result.bendingStress,
                category: UnitCategory.stress,
              ),
          ],
        ),
      ],
      children: [
        CalculationCard(steps: steps),
        XYDiagramCard(
          title: l10n.Shear_Force_Diagram,
          xUnitLabel: unitLabel(UnitCategory.span, system),
          yUnitLabel: unitLabel(UnitCategory.forceStructural, system),
          points: [
            for (final point in result.shear)
              DiagramPoint(fromSI(point.x, UnitCategory.span, system),
                  fromSI(point.value, UnitCategory.forceStructural, system)),
          ],
        ),
        XYDiagramCard(
          title: l10n.Bending_Moment_Diagram,
          xUnitLabel: unitLabel(UnitCategory.span, system),
          yUnitLabel: unitLabel(UnitCategory.momentStructural, system),
          points: [
            for (final point in result.moment)
              DiagramPoint(fromSI(point.x, UnitCategory.span, system),
                  fromSI(point.value, UnitCategory.momentStructural, system)),
          ],
        ),
        XYDiagramCard(
          title: l10n.Elastic_Deflection,
          xUnitLabel: unitLabel(UnitCategory.span, system),
          yUnitLabel: unitLabel(UnitCategory.length, system),
          points: [
            for (final point in result.deflection)
              DiagramPoint(fromSI(point.x, UnitCategory.span, system),
                  fromSI(point.value, UnitCategory.length, system)),
          ],
        ),
        Text(
          '${result.isDeterminate ? l10n.Beam_Determinate_Note : l10n.Beam_Indeterminate_Note}\n\n'
          '${l10n.Beam_Model_Note}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  /// A position rendered for use inside a label, e.g. `2 m`.
  String _position(
          double valueSI, UnitSystem system, NumberPrecisionHelper precs) =>
      '${precs.formatValue(fromSI(valueSI, UnitCategory.span, system))} '
      '${unitLabel(UnitCategory.span, system)}';

  /// The worked calculation, in the reader's language and units.
  ///
  /// A stiffness solve has no substituted algebra to show — the answer comes
  /// out of a matrix, not out of a formula anyone would write by hand. What is
  /// worth setting down instead is the model it solved and the equilibrium
  /// check on the answer, which is what a reader would verify by hand anyway.
  List<String> _steps(BuildContext context, UnitSystem system,
      NumberPrecisionHelper precs) {
    final l10n = S.of(context);
    String value(double valueSI, UnitCategory category) =>
        '${precs.formatValue(fromSI(valueSI, category, system))} '
        '${unitLabel(category, system)}';

    final steps = <String>[
      '${l10n.Support_Arrangement}: ${supportCaseLabel(context, supportCase)}',
      '${l10n.Span_L} = ${value(input.span, UnitCategory.span)}',
      'EI = ${value(input.elasticModulus, UnitCategory.modulus)} × '
          '${value(input.secondMoment, UnitCategory.momentOfInertia)}',
      '',
      l10n.Beam_Loads,
    ];

    for (final load in input.loads) {
      switch (load) {
        case BeamPointLoad():
          steps.add('· ${value(load.magnitude, UnitCategory.forceStructural)} '
              '@ x = ${value(load.position, UnitCategory.span)}');
        case BeamDistributedLoad():
          final intensity = load.isUniform
              ? value(load.startIntensity,
                  UnitCategory.distributedLoadStructural)
              : '${value(load.startIntensity, UnitCategory.distributedLoadStructural)} → '
                  '${value(load.endIntensity, UnitCategory.distributedLoadStructural)}';
          steps.add('· $intensity, '
              'x = ${value(load.start, UnitCategory.span)} → '
              '${value(load.end, UnitCategory.span)}');
        case BeamAppliedMoment():
          steps.add('· ${value(load.magnitude, UnitCategory.momentStructural)} '
              '@ x = ${value(load.position, UnitCategory.span)}');
      }
    }

    steps
      ..add('')
      ..add(l10n.Support_Reactions);
    for (final reaction in result.reactions) {
      steps.add('· x = ${value(reaction.position, UnitCategory.span)}: '
          '${value(reaction.force, UnitCategory.forceStructural)}'
          '${reaction.type == BeamSupportType.fixed ? ', ${value(reaction.moment, UnitCategory.momentStructural)}' : ''}');
    }

    // The vertical equilibrium check: the reactions have to add up to the
    // load, whatever the matrix did. It is the one line of this report a
    // reader can verify without redoing the analysis.
    final totalReaction =
        result.reactions.fold<double>(0, (sum, r) => sum + r.force);
    steps
      ..add('ΣR = ${value(totalReaction, UnitCategory.forceStructural)} '
          '= ΣF')
      ..add('')
      ..add('Mmax = ${value(result.maximumMoment.value, UnitCategory.momentStructural)} '
          '@ x = ${value(result.maximumMoment.position, UnitCategory.span)}')
      ..add('vmax = ${value(result.maximumDeflection.value, UnitCategory.length)} '
          '@ x = ${value(result.maximumDeflection.position, UnitCategory.span)}');

    final stress = result.bendingStress;
    if (stress != null) {
      steps.add('σ = Mc/I = ${value(stress, UnitCategory.stress)}');
    }
    return steps;
  }
}
