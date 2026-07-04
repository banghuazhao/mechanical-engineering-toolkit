import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:provider/provider.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/beam_deflection_slope_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/cantilever_beam_deflections_slopes_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/simple_beam_deflections_slopes_row.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';

class SimpleBeamDeflectionsSlopesPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const SimpleBeamDeflectionsSlopesPage(
      {Key? key,
      required this.title,
      required this.toolId,
      this.initialInputs})
      : super(key: key);

  @override
  _SimpleBeamDeflectionsSlopesPageState createState() =>
      _SimpleBeamDeflectionsSlopesPageState();
}

class _SimpleBeamDeflectionsSlopesPageState
    extends State<SimpleBeamDeflectionsSlopesPage> {
  BeamDeflectionSlope beamDeflectionSlope = BeamDeflectionSlopeModel();
  String dropValue = "Point force at middle";
  bool validate = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      dropValue = widget.initialInputs!["Type"] ?? "Point force at middle";
      beamDeflectionSlope.E = double.tryParse(widget.initialInputs!["E"] ?? "");
      beamDeflectionSlope.I = double.tryParse(widget.initialInputs!["I"] ?? "");
      beamDeflectionSlope.L = double.tryParse(widget.initialInputs!["L"] ?? "");
      beamDeflectionSlope.f = double.tryParse(widget.initialInputs!["f"] ?? "");
    }
  }

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
                    SimpleBeamDeflectionsSlopesRow(
                      beamDeflectionSlope: beamDeflectionSlope,
                      validate: validate,
                      callback: (String dropValueNew) {
                        setState(() {
                          beamDeflectionSlope = BeamDeflectionSlopeModel();
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
                                    "images/simple_beam/icon_simple_beam.png"),
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
δ_C: -v(L/2) = Deflection at midpoint C of the beam (positive downward)
δ_max: -v_max = Maximum deflection (positive downward)
θ_A: v'(0) = Angle of rotation at start A of the beam (positive clockwise)
θ_B: v'(L) = Angle of rotation at end B of the beam (positive counterclockwise)
""", style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ))
                  ][index];
                })));
  }

  Center buildMathFormula(BuildContext context) {
    String mathFormula = r'''\begin{aligned}
        v &= -\frac{Px}{48EI}(3L^2-4x^2) \\ (&0 \leq x \leq \frac{L}{2})\\ 
        v' &= -\frac{P}{16EI}(L^2-4x^2) \\ (&0 \leq x \leq \frac{L}{2})\\ 
        \delta_C &= \delta_{max} = \frac{PL^3}{48EI} \\ 
        \theta_A &= \theta_B = \frac{PL^2}{16EI}
        \end{aligned}
        ''';

    if (dropValue == "Point force at middle") {
      mathFormula = r'''\begin{aligned}
        v &= -\frac{Px}{48EI}(3L^2-4x^2) \\ (&0 \leq x \leq \frac{L}{2})\\ 
        v' &= -\frac{P}{16EI}(L^2-4x^2) \\ (&0 \leq x \leq \frac{L}{2})\\ 
        \delta_C &= \delta_{max} = \frac{PL^3}{48EI} \\ 
        \theta_A &= \theta_B =  \frac{PL^2}{16EI}
        \end{aligned}
        ''';
    } else if (dropValue == "Distributed force evenly") {
      mathFormula = r'''\begin{aligned}
        v &= -\frac{qx}{24EI}(L^3-2Lx^2+x^3) \\ 
        v' &= -\frac{q}{24EI}(L^3-6Lx^2+4x^3) \\ 
        \delta_C &= \delta_{max} = \frac{5qL^4}{384EI} \\ 
        \theta_A &= \theta_B = \frac{qL^3}{24EI}
        \end{aligned}
        ''';
    } else if (dropValue == "Moment at middle") {
      mathFormula = r'''\begin{aligned}
        v &= -\frac{Mx}{24LEI}(L^2-4x^2) \\ (&0 \leq x \leq \frac{L}{2})\\ 
        v' &= -\frac{M}{24LEI}(L^2-12x^2) \\ (&0 \leq x \leq \frac{L}{2})\\ 
        \delta_C &= 0 \\ 
        \theta_A &= \frac{ML}{24EI} \\ 
        \theta_B &= -\frac{ML}{24EI}
        \end{aligned}
        ''';
    }

    return Center(
      child: Math.tex(
        mathFormula,
        mathStyle: MathStyle.display,
        textStyle: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  void _calculate() {
    if (beamDeflectionSlope.isValid()) {
      final precs = NumberPrecisionHelper();

      double E = beamDeflectionSlope.E!;
      double I = beamDeflectionSlope.I!;
      double L = beamDeflectionSlope.L!;
      double f = beamDeflectionSlope.f!;
      // double a = 0;
      // if (beamDeflectionSlope is BeamDeflectionSlopeABModel) {
      //   a = (beamDeflectionSlope as BeamDeflectionSlopeABModel).a!;
      // }

      List<String> deflectionTitles = [];
      List<String> deflectionValues = [];

      List<String> slopeTitles = [];
      List<String> slopeValues = [];

      if (dropValue == "Point force at middle") {
        deflectionTitles = ["v", "δ_C", "δ_max"];
        slopeTitles = ["v'", "θ_A", "θ_B"];
        double first = -f / (48 * E * I);
        deflectionValues = [
          (first * 3 * L * L).formatted(precs) +
              "x" +
              " + " +
              (-first * 4).formatted(precs) +
              "x^3",
          (f * L * L * L / (48 * E * I)).formatted(precs),
          (f * L * L * L / (48 * E * I)).formatted(precs)
        ];
        double second = -f / (16 * E * I);
        slopeValues = [
          (second * L * L).formatted(precs) +
              " + " +
              (-second * 4).formatted(precs) +
              "x^2",
          (f * L * L / (16 * E * I)).formatted(precs),
          (f * L * L / (16 * E * I)).formatted(precs)
        ];
      } else if (dropValue == "Distributed force evenly") {
        deflectionTitles = ["v", "δ_C", "δ_max"];
        slopeTitles = ["v'", "θ_A", "θ_B"];
        double first = -f / (24 * E * I);
        deflectionValues = [
          (first * L * L * L).formatted(precs) +
              "x" +
              " + " +
              (-first * 2 * L).formatted(precs) +
              "x^3" +
              " + " +
              (first).formatted(precs) +
              "x^4",
          (5 * f * L * L * L * L / (384 * E * I))
              .formatted(precs),
          (5 * f * L * L * L * L / (384 * E * I))
              .formatted(precs)
        ];
        double second = -f / (24 * E * I);
        slopeValues = [
          (second * L * L * L).formatted(precs) +
              " + " +
              (-second * 6 * L).formatted(precs) +
              "x^2" +
              " + " +
              (second * 4).formatted(precs) +
              "x^3",
          (f * L * L * L / (24 * E * I)).formatted(precs),
          (f * L * L * L / (24 * E * I)).formatted(precs)
        ];
      } else if (dropValue == "Moment at middle") {
        deflectionTitles = ["v", "δ_C"];
        slopeTitles = ["v'", "θ_A", "θ_B"];
        double first = -f / (24 * L * E * I);
        deflectionValues = [
          (first * L * L).formatted(precs) +
              " + " +
              (-first * 4).formatted(precs) +
              "x^2",
          "0"
        ];
        slopeValues = [
          (first * L * L).formatted(precs) +
              " + " +
              (-first * 12).formatted(precs) +
              "x^2",
          (first * L * L).formatted(precs),
          (-first * L * L).formatted(precs),
        ];
      }

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        "E": E.toString(),
        "I": I.toString(),
        "L": L.toString(),
        "f": f.toString(),
        "Type": dropValue,
      });

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
