import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/stress_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/beam_flexure_formula_row_result.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';

class BeamFlexureFormulaResultPage extends StatefulWidget {
  final Stress stress;
  final double? y;

  const BeamFlexureFormulaResultPage(
      {Key? key, required this.stress, required this.y})
      : super(key: key);

  @override
  _BeamFlexureFormulaResultPageState createState() =>
      _BeamFlexureFormulaResultPageState();
}

class _BeamFlexureFormulaResultPageState
    extends State<BeamFlexureFormulaResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(S.of(context).Result),
        ),
        body: SafeArea(
          child: StaggeredGridView.countBuilder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              crossAxisCount: 8,
              itemCount: 1,
              staggeredTileBuilder: (int index) => StaggeredTile.fit(
                  MediaQuery.of(context).size.width > 600 ? 4 : 8),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              itemBuilder: (BuildContext context, int index) {
                double? value = null;
                if (widget.y != null) {
                  value = widget.stress.value! * widget.y!;
                }
                return [
                  BeamFlexureFormulaRowResult(
                      resultFormula: widget.stress.value!
                              .toStringAsExponential(
                                  NumberPrecisionHelper().precision)
                              .toString() +
                          "*y",
                      resultValue: value)
                ][index];
              }),
        ));
  }
}
