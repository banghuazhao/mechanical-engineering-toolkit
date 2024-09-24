import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/area_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/force_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/stress_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/general_stress_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/area_row.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/force_row.dart';

class GeneralStressPage extends StatefulWidget {
  final String title;
  const GeneralStressPage({Key? key, required this.title}) : super(key: key);

  @override
  _LaminaEngineeringConstantsPageState createState() =>
      _LaminaEngineeringConstantsPageState();
}

class _LaminaEngineeringConstantsPageState extends State<GeneralStressPage> {
  Force force = Force();
  Area area = Area();
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
                            style: Theme.of(context).textTheme.bodyText2),
                        const SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: Math.tex(
                            r'''\sigma = \frac{F}{A}''',
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
    if (force.isValid() && area.isValid()) {
      Stress stress = Stress(force.value! / area.value!);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GeneralStressResultPage(
                    stress: stress,
                  )));
    }
  }
}
