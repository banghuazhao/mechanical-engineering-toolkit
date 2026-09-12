import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_commands.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:provider/provider.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/angle_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/layup_angle_row.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/spherical_shell_stress_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/plane_stress_row.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_workspace.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

class PlaneStressTransformationPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const PlaneStressTransformationPage(
      {Key? key, required this.title, required this.toolId, this.initialInputs})
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
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      planeStress.sigma11 = double.tryParse(widget.initialInputs!["σ_x"] ?? "");
      planeStress.sigma22 = double.tryParse(widget.initialInputs!["σ_y"] ?? "");
      planeStress.sigma12 =
          double.tryParse(widget.initialInputs!["τ_xy"] ?? "");
      layupAngle.value = double.tryParse(widget.initialInputs!["θ"] ?? "");
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
          actions: [
            ToolHelpButton(toolId: widget.toolId, toolTitle: widget.title),
          ],
        ),
        floatingActionButton: CalculateButton(onPressed: () {
        setState(() {
          validate = true;
        });
            _calculate();
          }),
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
""", style: Theme.of(context).textTheme.bodyMedium),
                        Center(
                          child: Math.tex(
                            r'''\begin{aligned}
                          \sigma_{x1} &= \frac{\sigma_x + \sigma_y}{2} + \frac{\sigma_x - \sigma_y}{2} cos2\theta + \tau_{xy}sin2\theta\\ 
                          \sigma_{y1} &= \frac{\sigma_x + \sigma_y}{2} - \frac{\sigma_x - \sigma_y}{2} cos2\theta - \tau_{xy}sin2\theta\\ 
                          \tau_{y1} &= - \frac{\sigma_x - \sigma_y}{2} sin2\theta - \tau_{xy}cos2\theta
                          \end{aligned}
                          ''',
                            mathStyle: MathStyle.display,
                            textStyle: Theme.of(context).textTheme.titleSmall,
                          ),
                        ),
                      ],
                    ))
                  ][index];
                })));
  }

  void _calculate() {
    if (planeStress.isValid() && layupAngle.isValid()) {
      final precs = NumberPrecisionHelper();

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

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        "σ_x": s11.toString(),
        "σ_y": s22.toString(),
        "τ_xy": s12.toString(),
        "θ": angle.toString(),
      });

      showToolResult(
        context,
        (context) => SphericalShellStressResultPage(
          toolId: widget.toolId,
          rowTitle: "Transformed Stresses",
          titles: const ["σ_x'", "σ_y'", "τ_x'y'"],
          values: [sigma_x1, sigma_y1, sigma_xy],
          valueUnits: const [
            UnitCategory.stress,
            UnitCategory.stress,
            UnitCategory.stress,
          ],
          calculationSteps: [
            'θ = ${precs.formatValue(angle)}°,  2θ = ${precs.formatValue(2 * angle)}°',
            'sin2θ = ${precs.formatValue(s)},  cos2θ = ${precs.formatValue(c)}',
            'σₓ\' = (σₓ+σᵧ)/2 + (σₓ−σᵧ)/2·cos2θ + τ·sin2θ = ${precs.formatValue(sigma_x1)}',
            'σᵧ\' = (σₓ+σᵧ)/2 − (σₓ−σᵧ)/2·cos2θ − τ·sin2θ = ${precs.formatValue(sigma_y1)}',
            'τₓ\'ᵧ\' = −(σₓ−σᵧ)/2·sin2θ + τ·cos2θ = ${precs.formatValue(sigma_xy)}',
          ],
        ),
      );
    }
  }
}
