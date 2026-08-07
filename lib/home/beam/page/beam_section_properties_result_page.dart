import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/beam_section_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BeamSectionPropertiesResultPage extends StatelessWidget {
  const BeamSectionPropertiesResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.input,
    required this.result,
  });

  final int toolId;
  final String title;
  final BeamSectionInput input;
  final BeamSectionResult result;

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final tool = ToolLibrary.shared.item(toolId, context);
    final steps = _calculationSteps(system);

    return ResultScaffold(
      toolName: title,
      formulaSteps: steps,
      leading: [ToolResultHeader(tool: tool)],
      results: [
        ResultSection(
          title: title,
          values: [
            ResultValue(
              label: S.of(context).Area_A,
              valueSI: result.area,
              category: UnitCategory.area,
            ),
            ResultValue(
              label: S.of(context).Second_Moment_Ix,
              valueSI: result.ix,
              category: UnitCategory.momentOfInertia,
            ),
            ResultValue(
              label: S.of(context).Second_Moment_Iy,
              valueSI: result.iy,
              category: UnitCategory.momentOfInertia,
            ),
            ResultValue(
              label: S.of(context).Section_Modulus_Zx,
              valueSI: result.zx,
              category: UnitCategory.sectionModulus,
            ),
            ResultValue(
              label: S.of(context).Section_Modulus_Zy,
              valueSI: result.zy,
              category: UnitCategory.sectionModulus,
            ),
            ResultValue(
              label: S.of(context).Polar_Area_Moment_J,
              valueSI: result.polarMoment,
              category: UnitCategory.momentOfInertia,
            ),
          ],
        ),
      ],
      children: [
        CalculationCard(steps: steps),
        Text(
          S.of(context).Note_Polar_Moment,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  List<String> _calculationSteps(UnitSystem system) {
    final b = _fv(input.width, UnitCategory.length, system);
    final h = _fv(input.height, UnitCategory.length, system);
    final area = _fv(result.area, UnitCategory.area, system);
    final ix = _fv(result.ix, UnitCategory.momentOfInertia, system);
    final iy = _fv(result.iy, UnitCategory.momentOfInertia, system);
    final zx = _fv(result.zx, UnitCategory.sectionModulus, system);
    final zy = _fv(result.zy, UnitCategory.sectionModulus, system);
    final j = _fv(result.polarMoment, UnitCategory.momentOfInertia, system);
    final t = _fv(input.wallThickness, UnitCategory.length, system);
    final tf = _fv(input.flangeThickness, UnitCategory.length, system);
    final tw = _fv(input.webThickness, UnitCategory.length, system);
    final bi =
        _fv(input.width - 2 * input.wallThickness, UnitCategory.length, system);
    final hi = _fv(
        input.height - 2 * input.wallThickness, UnitCategory.length, system);
    final hw = _fv(
        input.height - 2 * input.flangeThickness, UnitCategory.length, system);
    final common = [
      'Zx = Ix / (h/2) = $ix / ($h/2) = $zx',
      'Zy = Iy / (b/2) = $iy / ($b/2) = $zy',
      'J = Ix + Iy = $ix + $iy = $j',
    ];
    return switch (input.type) {
      BeamSectionType.rectangle => [
          'Solid rectangle: b = $b, h = $h',
          'A = b·h = $b × $h = $area',
          'Ix = b·h³/12 = $b × $h³ / 12 = $ix',
          'Iy = h·b³/12 = $h × $b³ / 12 = $iy',
          ...common,
        ],
      BeamSectionType.hollowRectangle => [
          'Rectangular hollow section: b = $b, h = $h, t = $t',
          'bi = b − 2t = $bi; hi = h − 2t = $hi',
          'A = b·h − bi·hi = $area',
          'Ix = (b·h³ − bi·hi³)/12 = $ix',
          'Iy = (h·b³ − hi·bi³)/12 = $iy',
          ...common,
        ],
      BeamSectionType.circle => [
          'Solid circle: d = $b',
          'A = πd²/4 = π × $b² / 4 = $area',
          'Ix = Iy = πd⁴/64 = π × $b⁴ / 64 = $ix',
          ...common,
        ],
      BeamSectionType.hollowCircle => [
          'Circular hollow section: D = $b, t = $t',
          'd = D − 2t = $bi',
          'A = π(D² − d²)/4 = $area',
          'Ix = Iy = π(D⁴ − d⁴)/64 = $ix',
          ...common,
        ],
      BeamSectionType.iSection => [
          'Symmetric I-section: b = $b, h = $h, tf = $tf, tw = $tw',
          'hw = h − 2tf = $hw',
          'A = 2b·tf + tw·hw = $area',
          'Ix = 2[b·tf³/12 + b·tf((h−tf)/2)²] + tw·hw³/12 = $ix',
          'Iy = 2(tf·b³/12) + hw·tw³/12 = $iy',
          ...common,
        ],
    };
  }

  String _f(double value) => value.abs() >= 1e6
      ? value.toStringAsExponential(4)
      : value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_f(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';
}
