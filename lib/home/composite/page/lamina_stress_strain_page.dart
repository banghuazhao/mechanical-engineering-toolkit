import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/angle_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/lamina_constants_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/layup_angle_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/plane_stress_strain_row.dart';
import 'package:vector_math/vector_math.dart' as VMath;

import 'lamina_stress_strain_result_page.dart';

class LaminaStressStrainPage extends StatefulWidget {
  final String title;
  const LaminaStressStrainPage({Key? key, required this.title})
      : super(key: key);

  @override
  _LaminaStressStrainPageState createState() => _LaminaStressStrainPageState();
}

class _LaminaStressStrainPageState extends State<LaminaStressStrainPage> {
  TransverselyIsotropicMaterial transverselyIsotropicMaterial =
      TransverselyIsotropicMaterial();
  LayupAngle layupAngle = LayupAngle();
  MechanicalTensor mechanicalTensor = PlaneStress();
  bool validate = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
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
              LayupAngleRow(
                layupAngle: layupAngle,
                validate: validate,
                title: S.of(context).Layup_Angle,
              ),
              PlaneStressStrainRow(
                mechanicalTensor: mechanicalTensor,
                validate: validate,
                callback: (value) {
                  setState(() {
                    if (value == S.of(context).Stress) {
                      mechanicalTensor = PlaneStress();
                    } else {
                      mechanicalTensor = PlaneStrain();
                    }
                  });
                },
              ),
              DescriptionItem(
                  content: Column(
                children: [
                  Text('''
Calculate the stress or strain of a lamina that is transversely isotropic.
The plane stress-strain relations on the material coordinate can be expressed by:''',
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
                  )),
                ],
              ))
            ][index];
          },
        ),
      ),
    );
  }

  void _calculate() {
    if (transverselyIsotropicMaterial.isValidInPlane() &&
        layupAngle.isValid() &&
        mechanicalTensor.isValid()) {
      double e1 = transverselyIsotropicMaterial.e1!;
      double e2 = transverselyIsotropicMaterial.e2!;
      double g12 = transverselyIsotropicMaterial.g12!;
      double nu12 = transverselyIsotropicMaterial.nu12!;
      double angleRadian = VMath.radians(layupAngle.value!);
      var S = VMath.Matrix3.fromList(
          [1 / e1, -nu12 / e1, 0, -nu12 / e1, 1 / e2, 0, 0, 0, 1 / g12]);
      var Q = VMath.Matrix3.fromList(
          [1 / e1, -nu12 / e1, 0, -nu12 / e1, 1 / e2, 0, 0, 0, 1 / g12]);
      Q.invert();
      double s = sin(angleRadian);
      double c = cos(angleRadian);
      var T_epsilon = VMath.Matrix3.fromList([
        c * c,
        s * s,
        s * c,
        s * s,
        c * c,
        -s * c,
        -2 * s * c,
        2 * s * c,
        c * c - s * s
      ]);
      var T_sigma = VMath.Matrix3.fromList([
        c * c,
        s * s,
        2 * s * c,
        s * s,
        c * c,
        -2 * s * c,
        -s * c,
        s * c,
        c * c - s * s
      ]);
      var Q_bar = T_epsilon.transposed() * Q * T_epsilon;
      var S_bar = T_sigma.transposed() * S * T_sigma;

      MechanicalTensor resultTensor;
      if (mechanicalTensor is PlaneStrain) {
        double epsilon11 = (mechanicalTensor as PlaneStrain).epsilon11!;
        double epsilon22 = (mechanicalTensor as PlaneStrain).epsilon22!;
        double gamma12 = (mechanicalTensor as PlaneStrain).gamma12!;
        var strainVector = VMath.Vector3.array([epsilon11, epsilon22, gamma12]);
        var stressVector = Q_bar * strainVector;
        resultTensor =
            PlaneStress.from(stressVector[0], stressVector[1], stressVector[2]);
        // print(stressVector);
      } else {
        double sigma11 = (mechanicalTensor as PlaneStress).sigma11!;
        double sigma22 = (mechanicalTensor as PlaneStress).sigma22!;
        double sigma12 = (mechanicalTensor as PlaneStress).sigma12!;
        var stressVector = VMath.Vector3.array([sigma11, sigma22, sigma12]);
        var strainVector = S_bar * stressVector;
        resultTensor =
            PlaneStrain.from(strainVector[0], strainVector[1], strainVector[2]);
        // print(strainVector);
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LaminaStressStrainResult(
                  resultTensor: resultTensor, Q_bar: Q_bar, S_bar: S_bar)));
    }
  }
}
