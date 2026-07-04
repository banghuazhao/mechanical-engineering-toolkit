import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/area_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/force_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/stress_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/general_stress_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/area_row.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/force_row.dart';
import 'package:provider/provider.dart';

class GeneralStressPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const GeneralStressPage({Key? key, required this.title, required this.toolId, this.initialInputs}) : super(key: key);

  @override
  _LaminaEngineeringConstantsPageState createState() =>
      _LaminaEngineeringConstantsPageState();
}

class _LaminaEngineeringConstantsPageState extends State<GeneralStressPage> {
  Force force = Force();
  Area area = Area();
  bool validate = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      force.value = double.tryParse(widget.initialInputs![S.current.Force] ?? '');
      area.value = double.tryParse(widget.initialInputs![S.current.Area] ?? '');
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
                itemCount: 3,
                staggeredTileBuilder: (int index) => StaggeredTile.fit(
                    MediaQuery.of(context).size.width > 600 ? 4 : 8),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemBuilder: (BuildContext context, int index) {
                  return [
                    ForceRow(force: force, validate: validate),
                    AreaRow(area: area, validate: validate),
                    DescriptionItem(
                        content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image(
                                height: 150,
                                image: AssetImage("images/icon_bar_force.png"),
                                fit: BoxFit.fitHeight,
                              )),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text("""
Calculate the stress by force (F) and area (A):""",
                            style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: Math.tex(
                            r'''\sigma = \frac{F}{A}''',
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
    if (force.isValid() && area.isValid()) {
      context.read<ToolHistory>().record(widget.toolId, inputs: {
        S.of(context).Force: force.value!.toString(),
        S.of(context).Area: area.value!.toString(),
      });
      Stress stress = Stress(force.value! / area.value!);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GeneralStressResultPage(
                    stress: stress,
                    F: force.value!,
                    A: area.value!,
                  )));
    }
  }
}
