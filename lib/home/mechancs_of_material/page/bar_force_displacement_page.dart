import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:provider/provider.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/bar_force_displacement_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/displacement_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/bar_force_displacement_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/bar_force_displacement_row.dart';

class BarForceDisplacementRelationPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const BarForceDisplacementRelationPage(
      {Key? key,
      required this.title,
      required this.toolId,
      this.initialInputs})
      : super(key: key);

  @override
  _BarForceDisplacementRelationPageState createState() =>
      _BarForceDisplacementRelationPageState();
}

class _BarForceDisplacementRelationPageState
    extends State<BarForceDisplacementRelationPage> {
  BarTorsionFormulaModel barForceDisplacementModel = BarTorsionFormulaModel();
  bool validate = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      barForceDisplacementModel.p =
          double.tryParse(widget.initialInputs![S.current.Force] ?? "");
      barForceDisplacementModel.l =
          double.tryParse(widget.initialInputs!["L"] ?? "");
      barForceDisplacementModel.e =
          double.tryParse(widget.initialInputs!["E"] ?? "");
      barForceDisplacementModel.area =
          double.tryParse(widget.initialInputs![S.current.Area] ?? "");
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
                    BarForceDisplacementRow(
                        barForceDisplacementModel: barForceDisplacementModel,
                        validate: validate),
                    DescriptionItem(
                        content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image(
                                height: 180,
                                image: AssetImage(
                                    "images/bar_force_displacement.png"),
                                fit: BoxFit.fitHeight,
                              )),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text("""
The displacement (δ) of prismatic bars subjected to tensile or compressive centroidal loads is proportional to both the load (F) and the length (L) of the bar, and inversely proportional to the axial rigidity (EA) of the bar:""",
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: Math.tex(
                            r'''\delta = \frac{FL}{EA}''',
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
    if (barForceDisplacementModel.isValid()) {
      double p = barForceDisplacementModel.p!;
      double l = barForceDisplacementModel.l!;
      double e = barForceDisplacementModel.e!;
      double area = barForceDisplacementModel.area!;
      Displacement displacement = Displacement(p * l / (e * area));
      context.read<ToolHistory>().record(widget.toolId, inputs: {
        S.of(context).Force: p.toString(),
        "L": l.toString(),
        "E": e.toString(),
        S.of(context).Area: area.toString(),
      });
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BarForceDisplacementResultPage(
                    displacement: displacement,
                    F: p,
                    L: l,
                    E: e,
                    A: area,
                  )));
    }
  }
}
