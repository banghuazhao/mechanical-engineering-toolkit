import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:linalg/linalg.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/layer_thickness.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/layup_sequence_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/lamina_constants_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/laminate_stress_strain_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/layer_thickness_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/layup_sequence_row.dart';

import 'laminate_stress_strain_result_page.dart';

class LaminateStressStrainPage extends StatefulWidget {
  final String title;
  const LaminateStressStrainPage({Key? key, required this.title})
      : super(key: key);

  @override
  _LaminateStressStrainPageState createState() =>
      _LaminateStressStrainPageState();
}

class _LaminateStressStrainPageState extends State<LaminateStressStrainPage> {
  TransverselyIsotropicMaterial transverselyIsotropicMaterial =
      TransverselyIsotropicMaterial();
  LayupSequence layupSequence = LayupSequence();
  LayerThickness layerThickness = LayerThickness();
  MechanicalTensor mechanicalTensor = LaminateStress();
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
                itemCount: 5,
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
                    LaminateStressStrainRow(
                      mechanicalTensor: mechanicalTensor,
                      validate: validate,
                      callback: (value) {
                        setState(() {
                          if (value == "Stress Resultant") {
                            mechanicalTensor = LaminateStress();
                          } else {
                            mechanicalTensor = LaminateStrain();
                          }
                        });
                      },
                    ),
                    DescriptionItem(
                        content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("""
Calculate the stress or strain of a laminate.
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
        !layerThickness.isValid() ||
        !mechanicalTensor.isValid()) {
      return;
    }
    Matrix A = Matrix.fill(3, 3);
    Matrix B = Matrix.fill(3, 3);
    Matrix D = Matrix.fill(3, 3);
    double thickness = layerThickness.value!;
    int nPly = layupSequence.layups!.length;

    List<double> bzi = [];
    List<Matrix> Q = [];
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

      Q.add(Qe);

      A += Qe * thickness;
      B += Qe * thickness * bzi[i];
      D += Qe * (thickness * bzi[i] * bzi[i] + pow(thickness, 3) / 12);
    }

    Matrix ABD = Matrix([
      [A[0][0], A[0][1], A[0][2], B[0][0], B[0][1], B[0][2]],
      [A[1][0], A[1][1], A[1][2], B[1][0], B[1][1], B[1][2]],
      [A[2][0], A[2][1], A[2][2], B[2][0], B[2][1], B[2][2]],
      [B[0][0], B[0][1], B[0][2], D[0][0], D[0][1], D[0][2]],
      [B[1][0], B[1][1], B[1][2], D[1][0], D[1][1], D[1][2]],
      [B[2][0], B[2][1], B[2][2], D[2][0], D[2][1], D[2][2]]
    ]);

    Matrix ABD_inverese = ABD.inverse();

    MechanicalTensor resultTensor;
    if (mechanicalTensor is LaminateStress) {
      double N11 = (mechanicalTensor as LaminateStress).N11!;
      double N22 = (mechanicalTensor as LaminateStress).N22!;
      double N12 = (mechanicalTensor as LaminateStress).N12!;
      double M11 = (mechanicalTensor as LaminateStress).M11!;
      double M22 = (mechanicalTensor as LaminateStress).M22!;
      double M12 = (mechanicalTensor as LaminateStress).M12!;
      Matrix stressVector = Matrix([
        [N11],
        [N22],
        [N12],
        [M11],
        [M22],
        [M12],
      ]);
      Matrix strainVector = ABD_inverese * stressVector;
      resultTensor = LaminateStrain.from(
          strainVector[0][0],
          strainVector[1][0],
          strainVector[2][0],
          strainVector[3][0],
          strainVector[4][0],
          strainVector[5][0]);
    } else {
      double epsilon11 = (mechanicalTensor as LaminateStrain).epsilon11!;
      double epsilon22 = (mechanicalTensor as LaminateStrain).epsilon22!;
      double epsilon12 = (mechanicalTensor as LaminateStrain).epsilon12!;
      double kappa11 = (mechanicalTensor as LaminateStrain).kappa11!;
      double kappa22 = (mechanicalTensor as LaminateStrain).kappa22!;
      double kappa12 = (mechanicalTensor as LaminateStrain).kappa12!;
      Matrix strainVector = Matrix([
        [epsilon11],
        [epsilon22],
        [epsilon12],
        [kappa11],
        [kappa22],
        [kappa12]
      ]);
      Matrix stressVector = ABD * strainVector;
      resultTensor = LaminateStress.from(
          stressVector[0][0],
          stressVector[1][0],
          stressVector[2][0],
          stressVector[3][0],
          stressVector[4][0],
          stressVector[5][0]);
    }

    // print(A);
    // print(D);
    // print(mechanicalTensor);
    print(resultTensor);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LaminateStressStrainResultPage(
                  inputTensor: mechanicalTensor,
                  resultTensor: resultTensor,
                  thickness: thickness,
                  Q: Q,
                )));
  }
}
