import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/multiple_row_result.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

/// A generic result page for a list of single-value physical quantities
/// (e.g. stresses), reused by several "Mechanics of Material" tools:
/// spherical shell stress, cylindrical pressure vessel, plane-stress
/// transformation, and principal stress.
class SphericalShellStressResultPage extends StatefulWidget {
  final int toolId;
  final List<String> titles;
  final List<double?> values;
  final List<UnitCategory?>? valueUnits;
  final String rowTitle;
  final List<String>? calculationSteps;

  const SphericalShellStressResultPage({
    Key? key,
    required this.toolId,
    required this.titles,
    required this.values,
    this.valueUnits,
    this.rowTitle = "Result Stress",
    this.calculationSteps,
  }) : super(key: key);

  @override
  _SphericalShellStressResultPageState createState() =>
      _SphericalShellStressResultPageState();
}

class _SphericalShellStressResultPageState
    extends State<SphericalShellStressResultPage> {
  @override
  Widget build(BuildContext context) {
    context.watch<UnitSystemPreference>();
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final hasCalc =
        widget.calculationSteps != null && widget.calculationSteps!.isNotEmpty;

    return ResultScaffold(
      toolName: widget.rowTitle,
      formulaSteps: hasCalc ? widget.calculationSteps! : const [],
      results: [
        multipleRowSection(
          title: widget.rowTitle,
          resultTitles: widget.titles,
          resultValues: widget.values,
          resultUnits: widget.valueUnits,
        ),
      ],
      body: SafeArea(
        child: StaggeredGridView.countBuilder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            crossAxisCount: 8,
            itemCount: (hasCalc ? 2 : 1) + 1,
            staggeredTileBuilder: (int index) => StaggeredTile.fit(index == 0
                ? 8
                : (MediaQuery.of(context).size.width > 600 ? 4 : 8)),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemBuilder: (BuildContext context, int index) {
              return [
                ToolResultHeader(tool: tool),
                MultipleRowResult(
                    title: widget.rowTitle,
                    resultTitles: widget.titles,
                    resultValues: widget.values,
                    resultUnits: widget.valueUnits),
                if (hasCalc) CalculationCard(steps: widget.calculationSteps!),
              ][index];
            }),
      ),
    );
  }
}
