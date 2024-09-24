import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/spherical_shell_stress_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/plane_stress_row.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';

class PrincipalStressPage extends StatefulWidget {
  final String title;
  const PrincipalStressPage({Key? key, required this.title}) : super(key: key);

  @override
  _PrincipalStressPageState createState() => _PrincipalStressPageState();
}

class _PrincipalStressPageState extends State<PrincipalStressPage> {
  PlaneStress planeStress = PlaneStress();
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
                    PlaneStressRow(
                        planeStress: planeStress, validate: validate),
                    DescriptionItem(
                        content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image(
                                height: 150,
                                image: AssetImage(
                                    "images/icon_stress_element.png"),
                                fit: BoxFit.fitHeight,
                              )),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text("""
The principal stresses σ1 and σ2 (The maximum and minimum normal stresses) are:
""", style: Theme.of(context).textTheme.bodyText2),
                        Center(
                          child: Math.tex(
                            r'''
                          \sigma_{1,2} = \frac{\sigma_x + \sigma_y}{2} \pm \sqrt{(\frac{\sigma_x - \sigma_y}{2})^2 + \tau_{xy}^2}
                          ''',
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
    if (planeStress.isValid()) {
      int precision = NumberPrecisionHelper().precision;

      double s11 = planeStress.sigma11!;
      double s22 = planeStress.sigma22!;
      double s12 = planeStress.sigma12!;

      double sigma_1 =
          (s11 + s22) / 2 + sqrt((s11 - s22) / 2 * (s11 - s22) / 2 + s12 * s12);
      double sigma_2 =
          (s11 + s22) / 2 - sqrt((s11 - s22) / 2 * (s11 - s22) / 2 + s12 * s12);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SphericalShellStressResultPage(
                      rowTitle: "Principal Stresses",
                      titles: [
                        "σ_1",
                        "σ_2",
                      ],
                      values: [
                        sigma_1.toStringAsExponential(precision),
                        sigma_2.toStringAsExponential(precision)
                      ])));
    }
  }
}
