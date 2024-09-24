import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/bar_torsion_formula_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/strain_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/bar_torsion_formula_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/bar_torsion_formula_row.dart';

class BarTorsionFormulaPage extends StatefulWidget {
  final String title;
  const BarTorsionFormulaPage({Key? key, required this.title})
      : super(key: key);

  @override
  _BarTorsionFormulaPageState createState() => _BarTorsionFormulaPageState();
}

class _BarTorsionFormulaPageState extends State<BarTorsionFormulaPage> {
  BarTorsionFormulaModel barTorsionFormulaModel = BarTorsionFormulaModel();
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
                    BarTorsionFormulaRow(
                        barTorsionFormulaModel: barTorsionFormulaModel,
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
                                    AssetImage("images/icon_bar_torsion.png"),
                                fit: BoxFit.fitHeight,
                              )),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text("""
The torsion formula of bar: The maximum shear stress which occurs on the outer surface of a bar is proportional to torsional moment T, bar radius r and inversely proportional to the polar moment of inertia of the cross section Ip.""",
                            style: Theme.of(context).textTheme.bodyText2),
                        const SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: Math.tex(
                            r'''\tau_{max} = \frac{Tr}{I_p}''',
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
    if (barTorsionFormulaModel.isValid()) {
      double T = barTorsionFormulaModel.T!;
      double r = barTorsionFormulaModel.r!;
      double Ip = barTorsionFormulaModel.Ip!;
      Strain strain = Strain(T * r / Ip);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BarTorsionFormulaResultPage(
                    strain: strain,
                  )));
    }
  }
}
