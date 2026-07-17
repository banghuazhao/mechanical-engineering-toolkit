import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/principal_stress_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/mohrs_circle_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/plane_stress_row.dart';
import 'package:provider/provider.dart';

class MohrsCirclePage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const MohrsCirclePage(
      {Key? key,
      required this.title,
      required this.toolId,
      this.initialInputs})
      : super(key: key);

  @override
  _MohrsCirclePageState createState() => _MohrsCirclePageState();
}

class _MohrsCirclePageState extends State<MohrsCirclePage> {
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
                        Text("""
Mohr's circle is a graphical representation of the plane-stress transformation equations. Given σx, σy and τxy at a point, it plots the state of stress on every possible plane through that point, and reads off the principal stresses σ1, σ2, the maximum in-plane shear stress τmax, and the orientation of each.
""", style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ))
                  ][index];
                })));
  }

  void _calculate() {
    if (planeStress.isValid()) {
      final s11 = planeStress.sigma11!;
      final s22 = planeStress.sigma22!;
      final s12 = planeStress.sigma12!;

      final result = PrincipalStressCalculator.calculate(
        sigmaX: s11,
        sigmaY: s22,
        tauXY: s12,
      );

      context.read<ToolHistory>().record(widget.toolId, inputs: {
        "σ_x": s11.toString(),
        "σ_y": s22.toString(),
        "τ_xy": s12.toString(),
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MohrsCircleResultPage(
            title: widget.title,
            sigmaX: s11,
            sigmaY: s22,
            tauXY: s12,
            result: result,
          ),
        ),
      );
    }
  }
}
