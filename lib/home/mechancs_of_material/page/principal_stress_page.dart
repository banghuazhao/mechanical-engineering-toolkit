import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:provider/provider.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/spherical_shell_stress_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/plane_stress_row.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';

class PrincipalStressPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const PrincipalStressPage(
      {Key? key,
      required this.title,
      required this.toolId,
      this.initialInputs})
      : super(key: key);

  @override
  _PrincipalStressPageState createState() => _PrincipalStressPageState();
}

class _PrincipalStressPageState extends State<PrincipalStressPage> {
  PlaneStress planeStress = PlaneStress();
  bool validate = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      planeStress.sigma11 = double.tryParse(widget.initialInputs!["σ_x"] ?? "");
      planeStress.sigma22 = double.tryParse(widget.initialInputs!["σ_y"] ?? "");
      planeStress.sigma12 = double.tryParse(widget.initialInputs!["τ_xy"] ?? "");
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
""", style: Theme.of(context).textTheme.bodyMedium),
                        Center(
                          child: Math.tex(
                            r'''
                          \sigma_{1,2} = \frac{\sigma_x + \sigma_y}{2} \pm \sqrt{(\frac{\sigma_x - \sigma_y}{2})^2 + \tau_{xy}^2}
                          ''',
                            mathStyle: MathStyle.display,
                            textStyle: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ))
                  ][index];
                })));
  }

  void _calculate() {
    if (planeStress.isValid()) {
      final precs = NumberPrecisionHelper();

      double s11 = planeStress.sigma11!;
      double s22 = planeStress.sigma22!;
      double s12 = planeStress.sigma12!;

      double sigma_1 =
          (s11 + s22) / 2 + sqrt((s11 - s22) / 2 * (s11 - s22) / 2 + s12 * s12);
      double sigma_2 =
          (s11 + s22) / 2 - sqrt((s11 - s22) / 2 * (s11 - s22) / 2 + s12 * s12);

      final avg = (s11 + s22) / 2;
      final R = sqrt((s11 - s22) / 2 * (s11 - s22) / 2 + s12 * s12);
      context.read<ToolHistory>().record(widget.toolId, inputs: {
        "σ_x": s11.toString(),
        "σ_y": s22.toString(),
        "τ_xy": s12.toString(),
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SphericalShellStressResultPage(
                    rowTitle: "Principal Stresses",
                    titles: ["σ₁", "σ₂"],
                    values: [sigma_1.formatted(precs), sigma_2.formatted(precs)],
                    calculationSteps: [
                      'σ₁,₂ = (σₓ + σᵧ)/2 ± √((σₓ−σᵧ)²/4 + τ²)',
                      '= (${precs.formatValue(s11)} + ${precs.formatValue(s22)}) / 2 ± √(((${precs.formatValue(s11)}−${precs.formatValue(s22)})/2)² + ${precs.formatValue(s12)}²)',
                      '= ${precs.formatValue(avg)} ± ${precs.formatValue(R)}',
                      'σ₁ = ${precs.formatValue(sigma_1)},  σ₂ = ${precs.formatValue(sigma_2)}',
                    ],
                  )));
    }
  }
}
