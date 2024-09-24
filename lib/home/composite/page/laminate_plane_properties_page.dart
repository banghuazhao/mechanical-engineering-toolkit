import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:linalg/linalg.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/in_plane_properties_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/layer_thickness.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/layup_sequence_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/lamina_constants_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/layer_thickness_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/layup_sequence_row.dart';

import 'laminate_plane_properties_result_page.dart';

class LaminatePlanePropertiesPage extends StatefulWidget {
  final String title;
  const LaminatePlanePropertiesPage({Key? key, required this.title})
      : super(key: key);

  @override
  _LaminatePlanePropertiesPageState createState() =>
      _LaminatePlanePropertiesPageState();
}

class _LaminatePlanePropertiesPageState
    extends State<LaminatePlanePropertiesPage> {
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
                      isPlaneStress: true,
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
Calculate the plate properties of a laminate.
The constitutive relations on the material coordinate can be expressed by:""",
                            style: Theme.of(context).textTheme.bodyText2),
                        const SizedBox(
                          height: 12,
                        ),
                        Center(
                          child: Math.tex(
                            r'''\begin{Bmatrix}
  N_{11} \\
  N_{22} \\
  N_{12} \\
  M_{11} \\
  M_{22} \\
  M_{12}
\end{Bmatrix} = 
\begin{bmatrix}
  A_{11} & A_{12} & A_{16} & B_{11} & B_{12} & B_{16} \\
  A_{12} & A_{22} & A_{26} & B_{12} & B_{22} & B_{26} \\
  A_{16} & A_{26} & A_{66} & B_{16} & B_{26} & B_{66} \\
  B_{11} & B_{12} & B_{16} & D_{11} & D_{12} & D_{16} \\
  B_{12} & B_{22} & B_{26} & D_{12} & D_{22} & D_{26} \\
  B_{16} & B_{26} & B_{66} & D_{16} & D_{26} & D_{66} 
\end{bmatrix} 
\begin{Bmatrix}
  \epsilon_{11} \\
  \epsilon_{22} \\
  \epsilon_{12} \\
  \kappa_{11} \\
  \kappa_{22} \\
  \kappa_{12}
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
    if (!transverselyIsotropicMaterial.isValidInPlane() ||
        !layupSequence.isValid() ||
        !layerThickness.isValid()) {
      return;
    }
    Matrix A = Matrix.fill(3, 3);
    Matrix B = Matrix.fill(3, 3);
    Matrix D = Matrix.fill(3, 3);
    double thickness = layerThickness.value!;
    int nPly = layupSequence.layups!.length;

    List<double> bzi = [];
    for (int i = 1; i <= nPly; i++) {
      double bz = (-(nPly + 1) * thickness) / 2 + i * thickness;
      bzi.add(bz);
    }

    for (int i = 0; i < nPly; i++) {
      double layup = layupSequence.layups![i];
      double e1 = transverselyIsotropicMaterial.e1!;
      double e2 = transverselyIsotropicMaterial.e2!;
      double g12 = transverselyIsotropicMaterial.g12!;
      double nu12 = transverselyIsotropicMaterial.nu12!;

      double angleRadian = layup * pi / 180;
      double s = sin(angleRadian);
      double c = cos(angleRadian);

      Matrix Sep = Matrix([
        [1 / e1, -nu12 / e1, 0],
        [-nu12 / e1, 1 / e2, 0],
        [0, 0, 1 / g12]
      ]);

      Matrix Qep = Sep.inverse();

      Matrix Rsigmae = Matrix([
        [c * c, s * s, -2 * s * c],
        [s * s, c * c, 2 * s * c],
        [s * c, -s * c, c * c - s * s]
      ]);

      Matrix Qe = Rsigmae * Qep * Rsigmae.transpose();

      A += Qe * thickness;
      B += Qe * thickness * bzi[i];
      D += Qe * (thickness * bzi[i] * bzi[i] + pow(thickness, 3) / 12);
    }

    double h = nPly * thickness;

    Matrix Ses = A.inverse() * h;
    Matrix Sesf = D.inverse() * (pow(h, 3) / 12);

    InPlanePropertiesModel inPlanePropertiesModel = InPlanePropertiesModel();
    inPlanePropertiesModel.e1 = 1 / Ses[0][0];
    inPlanePropertiesModel.e2 = 1 / Ses[1][1];
    inPlanePropertiesModel.g12 = 1 / Ses[2][2];
    inPlanePropertiesModel.nu12 = -1 / Ses[0][0] * Ses[0][1];
    inPlanePropertiesModel.eta121 = -1 / Ses[2][2] * Ses[0][2];
    inPlanePropertiesModel.eta122 = -1 / Ses[2][2] * Ses[1][2];

    InPlanePropertiesModel flexuralPropertiesModel = InPlanePropertiesModel();
    flexuralPropertiesModel.e1 = 1 / Sesf[0][0];
    flexuralPropertiesModel.e2 = 1 / Sesf[1][1];
    flexuralPropertiesModel.g12 = 1 / Sesf[2][2];
    flexuralPropertiesModel.nu12 = -1 / Sesf[0][0] * Sesf[0][1];
    flexuralPropertiesModel.eta121 = -1 / Sesf[2][2] * Sesf[0][2];
    flexuralPropertiesModel.eta122 = -1 / Sesf[2][2] * Sesf[1][2];

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LaminatePlanePropertiesResultPage(
                  A: A,
                  B: B,
                  D: D,
                  inPlanePropertiesModel: inPlanePropertiesModel,
                  flexuralPropertiesModel: flexuralPropertiesModel,
                )));
  }
}
