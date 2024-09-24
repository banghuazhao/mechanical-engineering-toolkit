import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/beam_flexure_formula_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/stress_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/beam_flexure_formula_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/beam_flexure_formula_row.dart';

class BeamFlexureFormulaPage extends StatefulWidget {
  final String title;
  const BeamFlexureFormulaPage({Key? key, required this.title})
      : super(key: key);

  @override
  _BeamFlexureFormulaPageState createState() => _BeamFlexureFormulaPageState();
}

class _BeamFlexureFormulaPageState extends State<BeamFlexureFormulaPage> {
  BeamFlexureFormulaModel beamFlexureFormulaModel = BeamFlexureFormulaModel();
  bool validate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(widget.title),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              validate = true;
            });
            _calculate();
          },
          label: Text(S.of(context).Calculate),
        ),
        body: SafeArea(
            child: StaggeredGridView.countBuilder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                crossAxisCount: 8,
                itemCount: 2,
                staggeredTileBuilder: (int index) => StaggeredTile.fit(
                    MediaQuery.of(context).size.width > 600 ? 4 : 8),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemBuilder: (BuildContext context, int index) {
                  return [
                    BeamFlexureFormulaRow(
                        beamFlexureFormulaModel: beamFlexureFormulaModel,
                        validate: validate),
                    DescriptionItem(
                        content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image(
                                height: 150,
                                image:
                                    AssetImage("images/icon_beam_bending.png"),
                                fit: BoxFit.fitHeight,
                              )),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text("""
The flexure formula of beam: The stresses on the cross section are directly proportional to the bending moment M and inversely proportional to the moment of inertia I of the cross section. Also, the stresses vary linearly with the distance y from the neutral axis:""",
                            style: Theme.of(context).textTheme.bodyText2),
                        const SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: Math.tex(
                            r'''\sigma_x = -\frac{My}{I}''',
                            mathStyle: MathStyle.display,
                            textStyle: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ],
                    ))
                  ][index];
                })));
  }

  void _calculate() {
    if (beamFlexureFormulaModel.isValid()) {
      double M = beamFlexureFormulaModel.M!;
      double? y = beamFlexureFormulaModel.y;
      double I = beamFlexureFormulaModel.I!;
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BeamFlexureFormulaResultPage(
                    stress: Stress(-M / I),
                    y: y,
                  )));
    }
  }
}
