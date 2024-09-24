import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/spherical_shell_stress_model.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/page/spherical_shell_stress_result.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/spherical_shell_stress_row.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';

class SphericalShellStressPage extends StatefulWidget {
  final String title;
  const SphericalShellStressPage({Key? key, required this.title})
      : super(key: key);

  @override
  _SphericalShellStressPageState createState() =>
      _SphericalShellStressPageState();
}

class _SphericalShellStressPageState extends State<SphericalShellStressPage> {
  SphericalShellStressModel sphericalShellStressModel =
      SphericalShellStressModel();
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
                    SphericalShellStressRow(
                        sphericalShellStressModel: sphericalShellStressModel,
                        validate: validate),
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
                                    "images/icon_spherical_shell_stress.png"),
                                fit: BoxFit.fitHeight,
                              )),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text("""
The wall of a pressurized thin-walled spherical vessel is in a state of biaxial stress with uniform tensile stresses.
The tensile stresses σ in the wall can be calculated as following.
Where p is the pressure, r is the radius of the spherical and t is the thickness of the thin wall.
""", style: Theme.of(context).textTheme.bodyText2),
                        Center(
                          child: Math.tex(
                            r'''\sigma = \frac{pr}{2t}''',
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
    if (sphericalShellStressModel.isValid()) {
      int precision = NumberPrecisionHelper().precision;

      double p = sphericalShellStressModel.p!;
      double r = sphericalShellStressModel.r!;
      double t = sphericalShellStressModel.t!;
      double stress = p * r / (2 * t);
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SphericalShellStressResultPage(
                  titles: ["σ"],
                  values: [stress.toStringAsExponential(precision)])));
    }
  }
}