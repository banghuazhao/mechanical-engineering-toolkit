import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/simply_supported_beam_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/xy_diagram_card.dart';
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
  });

  final int toolId;
  final String title;
  final BeamAnalysisInput input;
  final BeamAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final tool = ToolLibrary.shared.item(toolId, context);
    final reactionSteps = _reactionSteps(system);
    final responseSteps = _responseSteps(system);

    return ResultScaffold(
      toolName: title,
      formulaSteps: [...reactionSteps, '', ...responseSteps],
      leading: [ToolResultHeader(tool: tool)],
      results: [
        ResultSection(
          title: title,
          values: [
            ResultValue(
              label: S.of(context).Left_Reaction_RA,
              valueSI: result.leftReaction,
              category: UnitCategory.forceStructural,
            ),
            ResultValue(
              label: S.of(context).Right_Reaction_RB,
              valueSI: result.rightReaction,
              category: UnitCategory.forceStructural,
            ),
            // Magnitude and its location are separate rows: a spreadsheet
            // cannot split "12 kN·m at x = 2 m" back into two numbers.
            ResultValue(
              label: S.of(context).Maximum_Bending_Moment,
              valueSI: result.maximumMoment,
              category: UnitCategory.momentStructural,
            ),
            ResultValue(
              label: '${S.of(context).Maximum_Bending_Moment} @ x',
              valueSI: result.maximumMomentPosition,
              category: UnitCategory.span,
            ),
            ResultValue(
              label: S.of(context).Maximum_Downward_Deflection,
              valueSI: result.maximumDeflection,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: '${S.of(context).Maximum_Downward_Deflection} @ x',
              valueSI: result.maximumDeflectionPosition,
              category: UnitCategory.span,
            ),
          ],
        ),
      ],
      children: [
        CalculationCard(steps: reactionSteps),
        CalculationCard(steps: responseSteps),
        XYDiagramCard(
          title: S.of(context).Shear_Force_Diagram,
          xUnitLabel: unitLabel(UnitCategory.span, system),
          yUnitLabel: unitLabel(UnitCategory.forceStructural, system),
          points: result.shear.map((p) => DiagramPoint(p.x, p.value)).toList(),
        ),
        XYDiagramCard(
          title: S.of(context).Bending_Moment_Diagram,
          xUnitLabel: unitLabel(UnitCategory.span, system),
          yUnitLabel: unitLabel(UnitCategory.momentStructural, system),
          points: result.moment.map((p) => DiagramPoint(p.x, p.value)).toList(),
        ),
        XYDiagramCard(
          title: S.of(context).Elastic_Deflection,
          xUnitLabel: unitLabel(UnitCategory.span, system),
          yUnitLabel: '${unitLabel(UnitCategory.length, system)} downward',
          points:
              result.deflection.map((p) => DiagramPoint(p.x, p.value)).toList(),
        ),
        Text(
          'Linear-elastic Euler\u2013Bernoulli analysis. Self-weight and shear deformation are excluded unless entered as part of the UDL. Diagram extrema are evaluated at 200 intervals.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  List<String> _reactionSteps(UnitSystem system) => [
        'Support reactions from static equilibrium',
        'RA = P(L−a)/L + wL/2',
        '= ${_fv(input.pointLoad, UnitCategory.forceStructural, system)}(${_fv(input.span, UnitCategory.span, system)}−${_fv(input.pointPosition, UnitCategory.span, system)})/${_fv(input.span, UnitCategory.span, system)} + ${_fv(input.distributedLoad, UnitCategory.distributedLoadStructural, system)}×${_fv(input.span, UnitCategory.span, system)}/2',
        '= ${_fv(result.leftReaction, UnitCategory.forceStructural, system)}',
        'RB = Pa/L + wL/2',
        '= ${_fv(input.pointLoad, UnitCategory.forceStructural, system)}×${_fv(input.pointPosition, UnitCategory.span, system)}/${_fv(input.span, UnitCategory.span, system)} + ${_fv(input.distributedLoad, UnitCategory.distributedLoadStructural, system)}×${_fv(input.span, UnitCategory.span, system)}/2',
        '= ${_fv(result.rightReaction, UnitCategory.forceStructural, system)}',
        'Check: RA + RB = ${_fv(result.leftReaction + result.rightReaction, UnitCategory.forceStructural, system)} = P + wL',
      ];

  List<String> _responseSteps(UnitSystem system) => [
        'Internal actions and elastic deflection',
        'V(x) = RA − wx − P·H(x−a)',
        'M(x) = RA·x − wx²/2 − P(x−a)·H(x−a)',
        'Mmax = ${_fv(result.maximumMoment, UnitCategory.momentStructural, system)} at x = ${_fv(result.maximumMomentPosition, UnitCategory.span, system)}',
        'EI = (${_fv(input.elasticModulus, UnitCategory.modulus, system)})(${_fv(input.secondMoment, UnitCategory.momentOfInertia, system)})',
        'UDL: v(x) = wx(L³−2Lx²+x³)/(24EI)',
        'Point load, x≤a: v(x) = Pb·x(L²−b²−x²)/(6LEI)',
        'Point load, x≥a: v(x) = Pa(L−x)[L²−a²−(L−x)²]/(6LEI)',
        'vmax = ${_fv(result.maximumDeflection, UnitCategory.length, system)} downward at x = ${_fv(result.maximumDeflectionPosition, UnitCategory.span, system)}',
      ];

  String _f(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_f(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';
}
