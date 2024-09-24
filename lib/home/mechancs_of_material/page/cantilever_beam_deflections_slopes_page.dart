import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/beam_deflection_slope_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/cantilever_beam_deflections_slopes_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/cantilever_beam_deflections_slopes_row.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';

class CantileverBeamDeflectionsSlopesPage extends StatefulWidget {
  final String title;
  const CantileverBeamDeflectionsSlopesPage({Key? key, required this.title})
      : super(key: key);

  @override
  _CantileverBeamDeflectionsSlopesPageState createState() =>
      _CantileverBeamDeflectionsSlopesPageState();
}

class _CantileverBeamDeflectionsSlopesPageState
    extends State<CantileverBeamDeflectionsSlopesPage> {
  BeamDeflectionSlope beamDeflectionSlope = BeamDeflectionSlopeModel();
  String dropValue = "Point force at end";
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
                    CantileverBeamDeflectionsSlopesRow(
                      beamDeflectionSlope: beamDeflectionSlope,
                      validate: validate,
                      callback: (String dropValueNew) {
                        setState(() {
                          if (dropValueNew == "Point force at end" ||
                              dropValueNew == "Distributed force evenly" ||
                              dropValueNew == "Moment at end") {
                            beamDeflectionSlope = BeamDeflectionSlopeModel();
                          } else {
                            beamDeflectionSlope = BeamDeflectionSlopeABModel();
                          }
                          dropValue = dropValueNew;
                        });
                      },
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
                                    "images/cantilever_beam/icon_cantilever_beam.png"),
                                fit: BoxFit.fitHeight,
                              )),
                        ),
                        buildMathFormula(context),
                        SizedBox(
                          height: 8,
                        ),
                        Text("""
E: Young's modulus
I: Moment of inertia
L: Length of the beam
v: Deflection in the y direction (positive upward)
v': = dv/dx = Slope of the deflection curve
δ_B: -v(L) = Deflection at end B of the beam (positive downward)
θ_B: -v'(L) = Angle of rotation at end B of the beam (positive clockwise)
""", style: Theme.of(context).textTheme.bodyText2),
                      ],
                    ))
                  ][index];
                })));
  }

  Center buildMathFormula(BuildContext context) {
    String mathFormula = r'''\begin{aligned}
        v &= -\frac{Px^2}{6EI}(3L-x) \\ 
        v' &= -\frac{Px}{2EI}(2L-x) \\ 
        \delta_B &= \frac{PL^3}{3EI} \\ 
        \theta_B &= \frac{PL^2}{2EI}
        \end{aligned}
        ''';

    if (dropValue == "Point force at end") {
      mathFormula = r'''\begin{aligned}
        v &= -\frac{Px^2}{6EI}(3L-x) \\ 
        v' &= -\frac{Px}{2EI}(2L-x) \\ 
        \delta_B &= \frac{PL^3}{3EI} \\ 
        \theta_B &= \frac{PL^2}{2EI}
        \end{aligned}
        ''';
    } else if (dropValue == "Point force") {
      mathFormula = r'''\begin{aligned}
        v &= -\frac{Px^2}{6EI}(3a-x) \quad (0 \leq x \leq a)\\ 
        v &= -\frac{Pa^2}{6EI}(3x-a) \quad (a \leq x \leq L)\\ 
        v' &= -\frac{Px}{2EI}(2a-x) \quad (0 \leq x \leq a)\\ 
        v' &= -\frac{Pa^2}{2EI} \quad (a \leq x \leq L)\\ 
        \delta_B &= \frac{Pa^2}{3EI}(3L - a) \\ 
        \theta_B &= \frac{Pa^2}{2EI}
        \end{aligned}
        ''';
    } else if (dropValue == "Distributed force evenly") {
      mathFormula = r'''\begin{aligned}
        v &= -\frac{qx^2}{24EI}(6L^2-4Lx+x^2) \\ 
        v' &= -\frac{qx}{6EI}(3L^2-3Lx+x^2) \\ 
        \delta_B &= \frac{qL^4}{8EI} \\ 
        \theta_B &= \frac{qL^3}{6EI}
        \end{aligned}
        ''';
    } else if (dropValue == "Distributed force") {
      mathFormula = r'''\begin{aligned}
        v &= -\frac{qx^2}{24EI}(6a^2-4ax+x^2) \\ &(0 \leq x \leq a)\\ 
        v &= -\frac{qa^3}{24EI}(4x-a) \quad (a \leq x \leq L)\\ 
        v' &= -\frac{qx}{6EI}(3a^2-3ax+x^2) \\ &(0 \leq x \leq a)\\ 
        v' &= -\frac{qa^3}{6EI} \quad (a \leq x \leq L)\\ 
        \delta_B &= \frac{qa^3}{24EI}(4L - a) \\ 
        \theta_B &= \frac{qa^3}{6EI}
        \end{aligned}
        ''';
    } else if (dropValue == "Moment at end") {
      mathFormula = r'''\begin{aligned}
        v &= -\frac{Mx^2}{2EI} \\ 
        v' &= -\frac{Mx}{EI} \\ 
        \delta_B &= \frac{ML^2}{2EI} \\ 
        \theta_B &= \frac{ML}{EI}
        \end{aligned}
        ''';
    } else if (dropValue == "Moment") {
      mathFormula = r'''\begin{aligned}
        v &= -\frac{Mx^2}{2EI} \quad (0 \leq x \leq a)\\ 
        v &= -\frac{Ma}{2EI}(2x-a) \quad (a \leq x \leq L)\\ 
        v' &= -\frac{Mx}{EI} \quad (0 \leq x \leq a)\\ 
        v' &= -\frac{Ma}{EI} \quad (a \leq x \leq L)\\ 
        \delta_B &= \frac{Ma}{2EI}(2L-a) \\ 
        \theta_B &= \frac{Ma}{EI}
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
    if (beamDeflectionSlope.isValid()) {
      int precision = NumberPrecisionHelper().precision;

      double E = beamDeflectionSlope.E!;
      double I = beamDeflectionSlope.I!;
      double L = beamDeflectionSlope.L!;
      double f = beamDeflectionSlope.f!;
      double a = 0;
      if (beamDeflectionSlope is BeamDeflectionSlopeABModel) {
        a = (beamDeflectionSlope as BeamDeflectionSlopeABModel).a!;
      }

      List<String> deflectionTitles = [];
      List<String> deflectionValues = [];

      List<String> slopeTitles = [];
      List<String> slopeValues = [];

      if (dropValue == "Point force at end") {
        deflectionTitles = ["v", "δ_B"];
        slopeTitles = ["v'", "θ_B"];
        double first = -f / (6 * E * I);
        deflectionValues = [
          (first * 3 * L).toStringAsExponential(precision) +
              "x^2" +
              " + " +
              (-first).toStringAsExponential(precision) +
              "x^3",
          (f * L * L * L / (3 * E * I)).toStringAsExponential(precision)
        ];
        double second = -f / (2 * E * I);
        slopeValues = [
          (second * 2 * L).toStringAsExponential(precision) +
              "x" +
              " + " +
              (-second).toStringAsExponential(precision) +
              "x^2",
          (f * L * L / (2 * E * I)).toStringAsExponential(precision)
        ];
      } else if (dropValue == "Point force") {
        deflectionTitles = ["v (0<=x<=a)", "v (a<=x<=L)", "δ_B"];
        slopeTitles = ["v' (0<=x<=a)", "v' (a<=x<=L)", "θ_B"];
        double first = -f / (6 * E * I);
        deflectionValues = [
          (first * 3 * a).toStringAsExponential(precision) +
              "x^2" +
              " + " +
              (-first).toStringAsExponential(precision) +
              "x^3",
          (first * 3 * a * a).toStringAsExponential(precision) +
              "x" +
              " + " +
              (-first * a * a * a).toStringAsExponential(precision),
          (f * a * a / (6 * E * I) * (3 * L - a))
              .toStringAsExponential(precision)
        ];
        double second = -f / (2 * E * I);
        slopeValues = [
          (second * 2 * a).toStringAsExponential(precision) +
              "x" +
              " + " +
              (second).toStringAsExponential(precision) +
              "x^2",
          (second * a * a).toStringAsExponential(precision),
          (f * a * a / (2 * E * I)).toStringAsExponential(precision)
        ];
      } else if (dropValue == "Distributed force evenly") {
        deflectionTitles = ["v", "δ_B"];
        slopeTitles = ["v'", "θ_B"];
        double first = -f / (24 * E * I);
        deflectionValues = [
          (first * 6 * L * L).toStringAsExponential(precision) +
              "x^2" +
              " + " +
              (-first * 4 * L).toStringAsExponential(precision) +
              "x^3" +
              " + " +
              (first).toStringAsExponential(precision) +
              "x^4",
          (f * L * L * L * L / (8 * E * I)).toStringAsExponential(precision)
        ];
        double second = -f / (6 * E * I);
        slopeValues = [
          (second * 3 * L * L).toStringAsExponential(precision) +
              "x" +
              " + " +
              (-second * 3 * L).toStringAsExponential(precision) +
              "x^2" +
              " + " +
              (second).toStringAsExponential(precision) +
              "x^3",
          (f * L * L * L / (6 * E * I)).toStringAsExponential(precision)
        ];
      } else if (dropValue == "Distributed force") {
        deflectionTitles = ["v (0<=x<=a)", "v (a<=x<=L)", "δ_B"];
        slopeTitles = ["v' (0<=x<=a)", "v' (a<=x<=L)", "θ_B"];
        double first = -f / (24 * E * I);
        deflectionValues = [
          (first * 6 * a * a).toStringAsExponential(precision) +
              "x^2" +
              " + " +
              (-first * 4 * a).toStringAsExponential(precision) +
              "x^3" +
              " + " +
              (first).toStringAsExponential(precision) +
              "x^4",
          (first * 4 * a * a * a).toStringAsExponential(precision) +
              "x" +
              " + " +
              (-first * a * a * a * a).toStringAsExponential(precision),
          (-first * a * a * a * (4 * L - a)).toStringAsExponential(precision)
        ];
        double second = -f / (6 * E * I);
        slopeValues = [
          (second * 3 * a * a).toStringAsExponential(precision) +
              "x" +
              " + " +
              (-second * 3 * a).toStringAsExponential(precision) +
              "x^2" +
              " + " +
              (second).toStringAsExponential(precision) +
              "x^3",
          (second * a * a * a).toStringAsExponential(precision),
          (f * a * a * a / (6 * E * I)).toStringAsExponential(precision)
        ];
      } else if (dropValue == "Moment at end") {
        deflectionTitles = ["v", "δ_B"];
        slopeTitles = ["v'", "θ_B"];
        double first = -f / (2 * E * I);
        deflectionValues = [
          (first).toStringAsExponential(precision) + "x^2",
          (-first * L * L).toStringAsExponential(precision)
        ];
        double second = -f / (E * I);
        slopeValues = [
          (second).toStringAsExponential(precision) + "x",
          (-second * L).toStringAsExponential(precision)
        ];
      } else if (dropValue == "Moment") {
        deflectionTitles = ["v (0<=x<=a)", "v (a<=x<=L)", "δ_B"];
        slopeTitles = ["v' (0<=x<=a)", "v' (a<=x<=L)", "θ_B"];
        double first = -f / (2 * E * I);
        deflectionValues = [
          (first).toStringAsExponential(precision) + "x^2",
          (first * 2 * a).toStringAsExponential(precision) +
              "x" +
              " + " +
              (-first * a * a).toStringAsExponential(precision),
          (-first * a * (2 * L - a)).toStringAsExponential(precision)
        ];
        double second = -f / (E * I);
        slopeValues = [
          (second).toStringAsExponential(precision) + "x",
          (second * a).toStringAsExponential(precision),
          (-second * a).toStringAsExponential(precision)
        ];
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CantileverBeamDeflectionsSlopesResultPage(
                    deflectionTitles: deflectionTitles,
                    deflectionValues: deflectionValues,
                    slopesTitles: slopeTitles,
                    slopesValues: slopeValues,
                  )));
    }
  }
}
