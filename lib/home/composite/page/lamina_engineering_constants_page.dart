import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/lamina_constants_row.dart';

import 'lamina_engineering_constants_result_page.dart';

class LaminaEngineeringConstantsPage extends StatefulWidget {
  final String title;
  const LaminaEngineeringConstantsPage({Key? key, required this.title})
      : super(key: key);

  @override
  _LaminaEngineeringConstantsPageState createState() =>
      _LaminaEngineeringConstantsPageState();
}

class _LaminaEngineeringConstantsPageState
    extends State<LaminaEngineeringConstantsPage> {
  TransverselyIsotropicMaterial transverselyIsotropicMaterial =
      TransverselyIsotropicMaterial();
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
                    LaminaContantsRow(
                        material: transverselyIsotropicMaterial,
                        validate: validate,
                        isPlaneStress: true),
                    DescriptionItem(
                        content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("""
Calculate the engineering of a lamina that is transversely isotropic for different layup angles.
The plane stress-strain relations on the material coordinate can be expressed by:""",
                            style: Theme.of(context).textTheme.bodyText2),
                        const SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: Math.tex(
                            r'''\begin{Bmatrix}
  \varepsilon_{11} \\
  \varepsilon_{22} \\
  \gamma_{12}
\end{Bmatrix} = \begin{bmatrix}
  \frac{1}{E_1} & -\frac{\nu_{12}}{E_1} & 0 \\
  -\frac{\nu_{12}}{E_1} & \frac{1}{E_2}  & 0 \\
  0 & 0 & \frac{1}{G_{12}}
\end{bmatrix} \begin{Bmatrix}
  \sigma_{11} \\
  \sigma_{22} \\
  \sigma_{12}
\end{Bmatrix}''',
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
    if (transverselyIsotropicMaterial.isValidInPlane()) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LaminaEngineeringConstantsResultPage(
                    transverselyIsotropicMaterial:
                        transverselyIsotropicMaterial,
                  )));
    }
  }
}
