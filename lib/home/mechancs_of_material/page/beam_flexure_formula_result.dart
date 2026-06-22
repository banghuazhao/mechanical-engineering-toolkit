import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/stress_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/beam_flexure_formula_row_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:provider/provider.dart';

class BeamFlexureFormulaResultPage extends StatefulWidget {
  final Stress stress;
  final double? y;
  final double M;
  final double I;

  const BeamFlexureFormulaResultPage(
      {Key? key,
      required this.stress,
      required this.y,
      required this.M,
      required this.I})
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
            icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () {
                final precs = Provider.of<NumberPrecisionHelper>(context, listen: false);
                final lines = widget.y != null
                    ? [
                        'σ = ${precs.formatValue(widget.stress.value! * widget.y!)}',
                        '',
                        'Calculation:',
                        'σ = M·y / I',
                        '= ${precs.formatValue(widget.M)} × ${precs.formatValue(widget.y)} / ${precs.formatValue(widget.I)}',
                        '= ${precs.formatValue(widget.stress.value! * widget.y!)}',
                      ]
                    : [
                        'σ(y) = ${precs.formatValue(widget.stress.value)} × y',
                        '',
                        'Calculation:',
                        'σ(y) = M·y / I = ${precs.formatValue(widget.M)} × y / ${precs.formatValue(widget.I)}',
                        '= ${precs.formatValue(widget.stress.value)} × y',
                      ];
                shareResult('Beam Flexure Formula', lines);
              },
            ),
          ],
          title: Text(S.of(context).Result),
        ),
        body: SafeArea(
          child: Consumer<NumberPrecisionHelper>(
            builder: (context, precs, _) {
              final double? sigmaAtY =
                  widget.y != null ? widget.stress.value! * widget.y! : null;

              final calcSteps = widget.y != null
                  ? [
                      'σ = M·y / I',
                      '= ${precs.formatValue(widget.M)} × ${precs.formatValue(widget.y)} / ${precs.formatValue(widget.I)}',
                      '= ${precs.formatValue(sigmaAtY)}',
                    ]
                  : [
                      'σ(y) = M·y / I',
                      '= ${precs.formatValue(widget.M)} × y / ${precs.formatValue(widget.I)}',
                      '= ${precs.formatValue(widget.stress.value)} × y',
                    ];

              return StaggeredGridView.countBuilder(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  crossAxisCount: 8,
                  itemCount: 2,
                  staggeredTileBuilder: (int index) => StaggeredTile.fit(
                      MediaQuery.of(context).size.width > 600 ? 4 : 8),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  itemBuilder: (BuildContext context, int index) {
                    return [
                      BeamFlexureFormulaRowResult(
                          resultFormula: precs.formatValue(widget.stress.value) + ' × y',
                          resultValue: sigmaAtY),
                      CalculationCard(steps: calcSteps),
                    ][index];
                  });
            },
          ),
        ));
  }
}
