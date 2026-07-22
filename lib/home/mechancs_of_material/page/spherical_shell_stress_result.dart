import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/multiple_row_result.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
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
  final _exportKey = GlobalKey();

  String _fv(BuildContext context, double? valueSI, UnitCategory? category) {
    final precs = Provider.of<NumberPrecisionHelper>(context, listen: false);
    if (category == null) {
      return precs.formatValue(valueSI);
    }
    final system =
        Provider.of<UnitSystemPreference>(context, listen: false).system;
    final display = valueSI == null ? null : fromSI(valueSI, category, system);
    return '${precs.formatValue(display)} ${unitLabel(category, system)}';
  }

  @override
  Widget build(BuildContext context) {
    context.watch<UnitSystemPreference>();
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    final hasCalc =
        widget.calculationSteps != null && widget.calculationSteps!.isNotEmpty;

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () {
                final lines = [
                  for (var i = 0; i < widget.titles.length; i++)
                    '${widget.titles[i]} = ${_fv(context, widget.values[i], widget.valueUnits?[i])}',
                  if (hasCalc) '',
                  if (hasCalc) 'Calculation:',
                  if (hasCalc) ...widget.calculationSteps!,
                ];
                shareResult(widget.rowTitle, lines);
              },
            ),
            IconButton(
              icon: const Icon(Icons.image_outlined),
              onPressed: () => shareResultImage(_exportKey, widget.rowTitle),
            ),
          ],
          title: Text(S.of(context).Result),
        ),
        bottomNavigationBar: const AppBannerAd(),
        body: RepaintBoundary(
          key: _exportKey,
          child: SafeArea(
            child: StaggeredGridView.countBuilder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                crossAxisCount: 8,
                itemCount: (hasCalc ? 2 : 1) + 1,
                staggeredTileBuilder: (int index) => StaggeredTile.fit(
                    index == 0
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
                    if (hasCalc)
                      CalculationCard(steps: widget.calculationSteps!),
                  ][index];
                }),
          ),
        ));
  }
}
