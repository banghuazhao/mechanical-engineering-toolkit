import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:linalg/linalg.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/layer_thickness.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/layup_sequence_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/lamina_constants_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/layer_thickness_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/layup_sequence_row.dart';

import 'laminate_3d_properties_result_page.dart';

class Laminate3DPropertiesPage extends StatefulWidget {
  final String title;
  const Laminate3DPropertiesPage({Key? key, required this.title})
      : super(key: key);

  @override
  _Laminate3DPropertiesPageState createState() =>
      _Laminate3DPropertiesPageState();
}

class _Laminate3DPropertiesPageState extends State<Laminate3DPropertiesPage> {
  TransverselyIsotropicMaterial transverselyIsotropicMaterial =
      TransverselyIsotropicMaterial();
  LayupSequence layupSequence = LayupSequence();
  LayerThickness layerThickness = LayerThickness();
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
                itemCount: 4,
                staggeredTileBuilder: (int index) => StaggeredTile.fit(
                    MediaQuery.of(context).size.width > 600 ? 4 : 8),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                itemBuilder: (BuildContext context, int index) {
                  return [
                    LaminaContantsRow(
                      material: transverselyIsotropicMaterial,
                      validate: validate,
                      isPlaneStress: false,
                    ),
                    LayupSequenceRow(
                        layupSequence: layupSequence, validate: validate),
                    LayerThicknessPage(
                        layerThickness: layerThickness, validate: validate),
                    DescriptionItem(
                        content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("""
Calculate the 3D properties of a laminate (Effective Solid Stiffness Matrix and Engineering Constants).
The constitutive relations of the Effective Solid Stiffness Matrix can be expressed by:""",
                            style: Theme.of(context).textTheme.bodyText2),
                        const SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: Math.tex(
                            r'''\begin{Bmatrix}
  \sigma_{11} \\
  \sigma_{22} \\
  \sigma_{33} \\
  \sigma_{23} \\
  \sigma_{13} \\
  \sigma_{12}
\end{Bmatrix} = 
\begin{bmatrix}
  C_{11} & C_{12} & C_{13} & C_{14} & C_{15} & C_{16} \\
  C_{12} & C_{22} & C_{23} & C_{24} & C_{25} & C_{26} \\
  C_{13} & C_{23} & C_{33} & C_{34} & C_{35} & C_{36} \\
  C_{14} & C_{24} & C_{34} & C_{44} & C_{45} & C_{46} \\
  C_{15} & C_{25} & C_{35} & C_{45} & C_{55} & C_{56} \\
  C_{16} & C_{26} & C_{36} & C_{46} & C_{56} & C_{66} 
\end{bmatrix} 
\begin{Bmatrix}
  \varepsilon_{11} \\
  \varepsilon_{22} \\
  \varepsilon_{33} \\
  \gamma_{23} \\
  \gamma_{13} \\
  \gamma_{12}
\end{Bmatrix}''',
                            mathStyle: MathStyle.script,
                            textStyle: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ))
                  ][index];
                })));
  }

  void _calculate() {
    if (!transverselyIsotropicMaterial.isValid() ||
        !layupSequence.isValid() ||
        !layerThickness.isValid()) {
      return;
    }

    double thickness = layerThickness.value!;
    int nPly = layupSequence.layups!.length;

    List<double> bzi = [];
    for (int i = 1; i <= nPly; i++) {
      double bz = (-(nPly + 1) * thickness) / 2 + i * thickness;
      bzi.add(bz);
    }

    Matrix C = Matrix.fill(6, 6);

    for (int i = 0; i < nPly; i++) {
      double layup = layupSequence.layups![i];
      double e1 = transverselyIsotropicMaterial.e1!;
      double e2 = transverselyIsotropicMaterial.e2!;
      double g12 = transverselyIsotropicMaterial.g12!;
      double nu12 = transverselyIsotropicMaterial.nu12!;
      double nu23 = transverselyIsotropicMaterial.nu23!;
      double e3 = e2;
      double g13 = g12;
      double g23 = e2 / (2 * (1 + nu23));
      double nu13 = nu12;
      double angleRadian = layup * pi / 180;
      double s = sin(angleRadian);
      double c = cos(angleRadian);
      Matrix Sp = Matrix([
        [1 / e1, -nu12 / e1, -nu13 / e1, 0, 0, 0],
        [-nu12 / e1, 1 / e2, -nu23 / e2, 0, 0, 0],
        [-nu13 / e1, -nu23 / e2, 1 / e3, 0, 0, 0],
        [0, 0, 0, 1 / g23, 0, 0],
        [0, 0, 0, 0, 1 / g13, 0],
        [0, 0, 0, 0, 0, 1 / g12]
      ]);

      Matrix Cp = Sp.inverse();

      Matrix Rsigma = Matrix([
        [c * c, s * s, 0, 0, 0, -2 * s * c],
        [s * s, c * c, 0, 0, 0, 2 * s * c],
        [0, 0, 1, 0, 0, 0],
        [0, 0, 0, c, s, 0],
        [0, 0, 0, -s, c, 0],
        [s * c, -s * c, 0, 0, 0, c * c - s * s]
      ]);
      C += Rsigma * Cp * Rsigma.transpose();
    }

    C = C * (1 / nPly);

    Matrix S = C.inverse();

    OrthotropicMaterial orthotropicMaterial = OrthotropicMaterial();
    orthotropicMaterial.e1 = 1 / S[0][0];
    orthotropicMaterial.e2 = 1 / S[1][1];
    orthotropicMaterial.e3 = 1 / S[2][2];
    orthotropicMaterial.g12 = 1 / S[5][5];
    orthotropicMaterial.g13 = 1 / S[4][4];
    orthotropicMaterial.g23 = 1 / S[3][3];
    orthotropicMaterial.nu12 = -1 / S[0][0] * S[0][1];
    orthotropicMaterial.nu13 = -1 / S[0][0] * S[0][2];
    orthotropicMaterial.nu23 = -1 / S[1][1] * S[1][2];

    print(C);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Laminate3DPropertiesResultPage(
                  C: C,
                  orthotropicMaterial: orthotropicMaterial,
                )));
  }
}
