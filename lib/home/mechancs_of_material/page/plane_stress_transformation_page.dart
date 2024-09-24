import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/angle_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/layup_angle_row.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/spherical_shell_stress_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/plane_stress_row.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';

class PlaneStressTransformationPage extends StatefulWidget {
  final String title;
  const PlaneStressTransformationPage({Key? key, required this.title})
      : super(key: key);

  @override
  _PlaneStressTransformationPageState createState() =>
      _PlaneStressTransformationPageState();
}

class _PlaneStressTransformationPageState
    extends State<PlaneStressTransformationPage> {
  PlaneStress planeStress = PlaneStress();
  LayupAngle layupAngle = LayupAngle();
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
                itemCount: 3,
                staggeredTileBuilder: (int index) => StaggeredTile.fit(
                    MediaQuery.of(context).size.width > 600 ? 4 : 8),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemBuilder: (BuildContext context, int index) {
                  return [
                    PlaneStressRow(
                        planeStress: planeStress, validate: validate),
                    LayupAngleRow(
                      layupAngle: layupAngle,
                      validate: validate,
                      title: S.of(context).Angle_of_Rotation,
                      placeHolder: "θ",
                    ),
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
                        Center(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image(
                                height: 150,
                                image: AssetImage(
                                    "images/icon_stress_element_inclined.png"),
                                fit: BoxFit.fitHeight,
                              )),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text("""
The transformation equations for plane stress are:
""", style: Theme.of(context).textTheme.bodyText2),
                        Center(
                          child: Math.tex(
                            r'''\begin{aligned}
                          \sigma_{x1} &= \frac{\sigma_x + \sigma_y}{2} + \frac{\sigma_x - \sigma_y}{2} cos2\theta + \tau_{xy}sin2\theta\\ 
                          \sigma_{y1} &= \frac{\sigma_x + \sigma_y}{2} - \frac{\sigma_x - \sigma_y}{2} cos2\theta - \tau_{xy}sin2\theta\\ 
                          \tau_{y1} &= - \frac{\sigma_x - \sigma_y}{2} sin2\theta - \tau_{xy}cos2\theta
                          \end{aligned}
                          ''',
                            mathStyle: MathStyle.display,
                            textStyle: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),
                      ],
                    ))
                  ][index];
                })));
  }

  void _calculate() {
    if (planeStress.isValid() && layupAngle.isValid()) {
      int precision = NumberPrecisionHelper().precision;

      double s11 = planeStress.sigma11!;
      double s22 = planeStress.sigma22!;
      double s12 = planeStress.sigma12!;
      double angle = layupAngle.value!;

      double angleRadian = angle * pi / 180;
      double s = sin(2 * angleRadian);
      double c = cos(2 * angleRadian);

      double sigma_x1 = (s11 + s22) / 2 + (s11 - s22) / 2 * c + s12 * s;
      double sigma_y1 = (s11 + s22) / 2 - (s11 - s22) / 2 * c - s12 * s;
      double sigma_xy = -(s11 - s22) / 2 * s + s12 * c;

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SphericalShellStressResultPage(
                      rowTitle: "Principal Stresses",
                      titles: [
                        "σ_x1",
                        "σ_y1",
                        "𝛕_x1y1"
                      ],
                      values: [
                        sigma_x1.toStringAsExponential(precision),
                        sigma_y1.toStringAsExponential(precision),
                        sigma_xy.toStringAsExponential(precision)
                      ])));
    }
  }
}
