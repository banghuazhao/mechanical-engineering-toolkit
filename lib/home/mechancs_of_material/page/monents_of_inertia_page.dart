import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/cross_section_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/monents_of_inertia_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/monents_of_inertia_row.dart';

class MonentsOfInertiaPage extends StatefulWidget {
  final String title;
  const MonentsOfInertiaPage({Key? key, required this.title}) : super(key: key);

  @override
  _MonentsOfInertiaPageState createState() => _MonentsOfInertiaPageState();
}

class _MonentsOfInertiaPageState extends State<MonentsOfInertiaPage> {
  CrossSectionModel crossSectionModel = CrossSectionBHModel();
  String dropValue = "Rectangle (Origin of axes at centroid)";
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
                    MonentsOfInertiaRow(
                      crossSectionModel: crossSectionModel,
                      validate: validate,
                      callback: (String dropValueNew) {
                        setState(() {
                          if (dropValueNew == "Circle (Origin at center)" ||
                              dropValueNew ==
                                  "Semicircle (Origin at centroid)") {
                            crossSectionModel = CrossSectionRModel();
                          } else {
                            crossSectionModel = CrossSectionBHModel();
                          }
                          dropValue = dropValueNew;
                        });
                      },
                    ),
                    DescriptionItem(
                        content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("""
Ix: Moments of inertia with respect to the x axis
Iy: Moments of inertia with respect to the y axis
Ixy: Product of inertia with respect to the x and y axe
Ip = Ix + Iy = Polar moment of inertia with respect to the origin of the x and y axes
""", style: Theme.of(context).textTheme.bodyText2),
                        buildMathFormula(context),
                      ],
                    ))
                  ][index];
                })));
  }

  Center buildMathFormula(BuildContext context) {
    String mathFormula = r'''\begin{aligned}
        I_x &= \frac{bh^3}{12} \\ 
        I_y &= \frac{hb^3}{12} \\ 
        I_{xy} &= 0 \\ 
        I_p &= \frac{bh}{12} (h^2 + b^2)
        \end{aligned}
        ''';
    if (dropValue == "Rectangle (Origin of axes at centroid)") {
      mathFormula = r'''\begin{aligned}
        I_x &= \frac{bh^3}{12} \\ 
        I_y &= \frac{hb^3}{12} \\ 
        I_{xy} &= 0 \\ 
        I_p &= \frac{bh}{12} (h^2 + b^2)
        \end{aligned}
        ''';
    } else if (dropValue == "Rectangle (Origin at corner)") {
      mathFormula = r'''\begin{aligned}
        I_x &= \frac{bh^3}{3} \\
         I_y &= \frac{hb^3}{3} \\ 
        I_{xy} &= \frac{b^2h^2}{4} \\
         I_p &= \frac{bh}{3} (h^2 + b^2)
        \end{aligned}
        ''';
    } else if (dropValue == "Isosceles triangle (Origin at centroid)") {
      mathFormula = r'''\begin{aligned}
        I_x &= \frac{bh^3}{36} \\
         I_y &= \frac{hb^3}{48} \\ 
        I_{xy} &= 0 \\
         I_p &= \frac{bh}{144} (4h^2 + 3b^2)
        \end{aligned}
        ''';
    } else if (dropValue == "Right triangle (Origin at centroid)") {
      mathFormula = r'''\begin{aligned}
        I_x &= \frac{bh^3}{36} \\
         I_y &= \frac{hb^3}{36} \\ 
        I_{xy} &= -\frac{b^2h^2}{72} \\
         I_p &= \frac{bh}{36} (h^2 + b^2)
        \end{aligned}
        ''';
    } else if (dropValue == "Circle (Origin at center)") {
      mathFormula = r'''\begin{aligned}
        I_x &= \frac{\pi r^4}{4} \\ 
        I_y &= \frac{\pi r^4}{4} \\ 
        I_{xy} &= 0 \\ 
        I_p &= \frac{\pi r^4}{2}
        \end{aligned}
        ''';
    } else if (dropValue == "Semicircle (Origin at centroid)") {
      mathFormula = r'''\begin{aligned}
        I_x &= \frac{(9\pi^2 - 64) r^4}{72\pi} \\ 
        I_y &= \frac{\pi r^4}{8} \\ 
        I_{xy} &= 0 \\ 
        I_p &= I_x + I_y
        \end{aligned}
        ''';
    }

    return Center(
      child: Math.tex(
        mathFormula,
        mathStyle: MathStyle.display,
        textStyle: Theme.of(context).textTheme.subtitle1,
      ),
    );
  }

  void _calculate() {
    if (crossSectionModel.isValid()) {
      double Ix = 0;
      double Iy = 0;
      double Ixy = 0;
      double Ip = 0;

      if (dropValue == "Circle (Origin at center)" ||
          dropValue == "Semicircle (Origin at centroid)") {
        double r = (crossSectionModel as CrossSectionRModel).r!;

        if (dropValue == "Circle (Origin at center)") {
          Ix = pi * r * r * r * r / 4;
          Iy = pi * r * r * r * r / 4;
          Ixy = 0;
          Ip = Ix + Iy;
        } else if (dropValue == "Semicircle (Origin at centroid)") {
          Ix = (9 * pi * pi - 64) * r * r * r * r / 4;
          Iy = pi * r * r * r * r / 8;
          Ixy = 0;
          Ip = Ix + Iy;
        }
      } else {
        double b = (crossSectionModel as CrossSectionBHModel).b!;
        double h = (crossSectionModel as CrossSectionBHModel).h!;

        if (dropValue == "Rectangle (Origin of axes at centroid)") {
          Ix = b * h * h * h / 12;
          Iy = h * b * b * b / 12;
          Ixy = 0;
          Ip = Ix + Iy;
        } else if (dropValue == "Rectangle (Origin at corner)") {
          Ix = b * h * h * h / 3;
          Iy = h * b * b * b / 3;
          Ixy = b * b * h * h / 4;
          Ip = Ix + Iy;
        } else if (dropValue == "Isosceles triangle (Origin at centroid)") {
          Ix = b * h * h * h / 36;
          Iy = h * b * b * b / 48;
          Ixy = 0;
          Ip = Ix + Iy;
        } else if (dropValue == "Right triangle (Origin at centroid)") {
          Ix = b * h * h * h / 36;
          Iy = h * b * b * b / 36;
          Ixy = -b * b * h * h / 72;
          Ip = Ix + Iy;
        }
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MomentsOfInertiaResultPage(
                    Ix: Ix,
                    Iy: Iy,
                    Ixy: Ixy,
                    Ip: Ip,
                  )));
    }
  }
}
