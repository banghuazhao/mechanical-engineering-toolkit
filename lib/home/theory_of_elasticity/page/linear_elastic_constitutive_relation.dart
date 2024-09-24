import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:linalg/matrix.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/theory_of_elasticity/page/linear_elastic_consitutive_relation_result.dart';
import 'package:mechanical_engineering_toolkit/home/theory_of_elasticity/widget/engineering_constants_input_row.dart';

class LinearElasticConstitutiveRelationPage extends StatefulWidget {
  final String title;
  const LinearElasticConstitutiveRelationPage({Key? key, required this.title})
      : super(key: key);

  @override
  _LinearElasticConstitutiveRelationPageState createState() =>
      _LinearElasticConstitutiveRelationPageState();
}

class _LinearElasticConstitutiveRelationPageState
    extends State<LinearElasticConstitutiveRelationPage> {
  MechanicalMaterial material = IsotropicMaterial();
  String dropValue = "Isotropic material";
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
                    EngineeringConstantsInputRow(
                      material: material,
                      validate: validate,
                      callback: (String dropValueNew) {
                        setState(() {
                          dropValue = dropValueNew;
                          if (dropValue == S.of(context).Isotropic_material) {
                            material = IsotropicMaterial();
                          } else if (dropValue ==
                              S.of(context).Transversely_isotropic_material) {
                            material = TransverselyIsotropicMaterial();
                          } else if (dropValue ==
                              S.of(context).Orthotropic_material) {
                            material = OrthotropicMaterial();
                          } else if (dropValue ==
                              S.of(context).Monoclinic_material) {
                            material = MonoclinicMaterial();
                          }
                        });
                      },
                    ),
                    DescriptionItem(
                        content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("""
Calculate the constitutive relation of linear elastic material by engineering constants:
""", style: Theme.of(context).textTheme.bodyText2),
                        buildMathFormula(context),
                        SizedBox(
                          height: 8,
                        ),
                        buildExtraText(context),
                      ],
                    ))
                  ][index];
                })));
  }

  Text buildExtraText(BuildContext context) {
    if (dropValue == "Isotropic material" ||
        dropValue == S.of(context).Isotropic_material) {
      return Text("""
Where:
G = E/(2*(1+ν))
E = Young’s modulus
ν = Poisson’s ratio
""", style: Theme.of(context).textTheme.bodyText2);
    } else if (dropValue == S.of(context).Transversely_isotropic_material) {
      return Text("""
Where:
G23 = E2/(2*(1+ν23))
E_i = Young’s modulus in the i-direction
G_ij = Shear modulus in the i-j plane
ν_ij = Poisson’s ratio measuring contraction in the j-direction due to uniaxial loading in the i-direction
""", style: Theme.of(context).textTheme.bodyText2);
    } else if (dropValue == S.of(context).Orthotropic_material) {
      return Text("""
Where:
E_i = Young’s modulus in the i-direction
G_ij = Shear modulus in the i-j plane
ν_ij = Poisson’s ratio measuring contraction in the j-direction due to uniaxial loading in the i-direction
""");
    } else {
      return Text("""
Where:
E_i = Young’s modulus in the i-direction
G_ij = Shear modulus in the i-j plane
ν_ij = Poisson’s ratio measuring contraction in the j-direction due to uniaxial loading in the i-direction
η_ij,k = Coefficient of mutual influence of the first kind which characterizes normal strain in the k-direction caused by shear in the i-j plane
η_k,ji = Coefficient of mutual influence of the first kind which characterizes shear the i-j plane caused by normal stress in the k direction
""");
    }
  }

  Center buildMathFormula(BuildContext context) {
    String mathFormula = r'''\begin{Bmatrix}
      \varepsilon_{11} \\
  \varepsilon_{22} \\
  \varepsilon_{33} \\
  2\varepsilon_{23} \\
  2\varepsilon_{13} \\
  2\varepsilon_{12}
\end{Bmatrix} = 
\begin{bmatrix}
  \frac{1}{E} & -\frac{\nu}{E} & -\frac{\nu}{E} & 0 & 0 & 0\\
  -\frac{\nu}{E} & \frac{1}{E} & -\frac{\nu}{E} & 0 & 0 & 0\\
  -\frac{\nu}{E} & -\frac{\nu}{E} & \frac{1}{E} & 0 & 0 & 0\\
  0 & 0 & 0 & \frac{1}{G} &0 & 0 \\
  0 & 0 & 0 & 0 & \frac{1}{G}  & 0 \\
  0 & 0 & 0 & 0 & 0 & \frac{1}{G} 
\end{bmatrix} 
\begin{Bmatrix}
  \sigma_{11} \\
  \sigma_{22} \\
  \sigma_{33} \\
  \sigma_{23} \\
  \sigma_{13} \\
  \sigma_{12}
\end{Bmatrix}
''';

    if (dropValue == "Isotropic material" ||
        dropValue == S.of(context).Isotropic_material) {
      mathFormula = r'''\begin{Bmatrix}
      \varepsilon_{11} \\
  \varepsilon_{22} \\
  \varepsilon_{33} \\
 2\varepsilon_{23} \\
  2\varepsilon_{13} \\
  2\varepsilon_{12}
\end{Bmatrix} = 
\begin{bmatrix}
  \frac{1}{E} & -\frac{\nu}{E} & -\frac{\nu}{E} & 0 & 0 & 0\\
  -\frac{\nu}{E} & \frac{1}{E} & -\frac{\nu}{E} & 0 & 0 & 0\\
  -\frac{\nu}{E} & -\frac{\nu}{E} & \frac{1}{E} & 0 & 0 & 0\\
  0 & 0 & 0 & \frac{1}{G} &0 & 0 \\
  0 & 0 & 0 & 0 & \frac{1}{G}  & 0 \\
  0 & 0 & 0 & 0 & 0 & \frac{1}{G} 
\end{bmatrix} 
\begin{Bmatrix}
  \sigma_{11} \\
  \sigma_{22} \\
  \sigma_{33} \\
  \sigma_{23} \\
  \sigma_{13} \\
  \sigma_{12}
\end{Bmatrix}
''';
    } else if (dropValue == S.of(context).Transversely_isotropic_material) {
      mathFormula = r'''\begin{Bmatrix}
      \varepsilon_{11} \\
  \varepsilon_{22} \\
  \varepsilon_{33} \\
  2\varepsilon_{23} \\
  2\varepsilon_{13} \\
  2\varepsilon_{12}
\end{Bmatrix} = 
\begin{bmatrix}
  \frac{1}{E_1} & -\frac{\nu_{12}}{E_1} & -\frac{\nu_{12}}{E_1} & 0 & 0 & 0\\
  -\frac{\nu_{12}}{E_1} & \frac{1}{E_2} & -\frac{\nu_{23}}{E_2} & 0 & 0 & 0\\
  -\frac{\nu_{12}}{E_1} & -\frac{\nu_{23}}{E_2} & \frac{1}{E_2} & 0 & 0 & 0\\
  0 & 0 & 0 & \frac{1}{G_{23}} &0 & 0 \\
  0 & 0 & 0 & 0 & \frac{1}{G_{13}}  & 0 \\
  0 & 0 & 0 & 0 & 0 & \frac{1}{G_{12}} 
\end{bmatrix} 
\begin{Bmatrix}
  \sigma_{11} \\
  \sigma_{22} \\
  \sigma_{33} \\
  \sigma_{23} \\
  \sigma_{13} \\
  \sigma_{12}
\end{Bmatrix}
''';
    } else if (dropValue == S.of(context).Orthotropic_material) {
      mathFormula = r'''\begin{Bmatrix}
      \varepsilon_{11} \\
  \varepsilon_{22} \\
  \varepsilon_{33} \\
  2\varepsilon_{23} \\
  2\varepsilon_{13} \\
  2\varepsilon_{12}
\end{Bmatrix} = 
\begin{bmatrix}
  \frac{1}{E_1} & -\frac{\nu_{12}}{E_1} & -\frac{\nu_{13}}{E_1} & 0 & 0 & 0\\
  -\frac{\nu_{12}}{E_1} & \frac{1}{E_2} & -\frac{\nu_{23}}{E_2} & 0 & 0 & 0\\
  -\frac{\nu_{13}}{E_1} & -\frac{\nu_{23}}{E_2} & \frac{1}{E_3} & 0 & 0 & 0\\
  0 & 0 & 0 & \frac{1}{G_{23}} &0 & 0 \\
  0 & 0 & 0 & 0 & \frac{1}{G_{13}}  & 0 \\
  0 & 0 & 0 & 0 & 0 & \frac{1}{G_{12}} 
\end{bmatrix} 
\begin{Bmatrix}
  \sigma_{11} \\
  \sigma_{22} \\
  \sigma_{33} \\
  \sigma_{23} \\
  \sigma_{13} \\
  \sigma_{12}
\end{Bmatrix}
''';
    } else if (dropValue == S.of(context).Monoclinic_material) {
      mathFormula = r'''\begin{Bmatrix}
      \varepsilon_{11} \\
  \varepsilon_{22} \\
  \varepsilon_{33} \\
  2\varepsilon_{23} \\
  2\varepsilon_{13} \\
  2\varepsilon_{12}
\end{Bmatrix} = 
\begin{bmatrix}
  \frac{1}{E_1} & -\frac{\nu_{12}}{E_1} & -\frac{\nu_{13}}{E_1} & 0 & 0 & \frac{\eta_{1,12}}{E_1}\\
  -\frac{\nu_{12}}{E_1} & \frac{1}{E_2} & -\frac{\nu_{23}}{E_2} & 0 & 0 & \frac{\eta_{2,12}}{E_2}\\
  -\frac{\nu_{13}}{E_1} & -\frac{\nu_{23}}{E_2} & \frac{1}{E_3} & 0 & 0 & \frac{\eta_{3,12}}{E_3}\\
  0 & 0 & 0 & \frac{1}{G_{23}} & \frac{\eta_{13,23}}{G_{13}} & 0 \\
  0 & 0 & 0 & \frac{\eta_{13,23}}{G_{13}} & \frac{1}{G_{13}}  & 0 \\
  \frac{\eta_{1,12}}{E_1} & \frac{\eta_{2,12}}{E_2} & \frac{\eta_{3,12}}{E_3} & 0 & 0 & \frac{1}{G_{12}} 
\end{bmatrix} 
\begin{Bmatrix}
  \sigma_{11} \\
  \sigma_{22} \\
  \sigma_{33} \\
  \sigma_{23} \\
  \sigma_{13} \\
  \sigma_{12}
\end{Bmatrix}
''';
    }

    double fontSize = 13;
    if (dropValue == S.of(context).Orthotropic_material ||
        dropValue == S.of(context).Transversely_isotropic_material) {
      fontSize = 12.5;
    } else if (dropValue == S.of(context).Monoclinic_material) {
      fontSize = 12;
    }
    return Center(
      child: Math.tex(
        mathFormula,
        mathStyle: MathStyle.script,
        textStyle: TextStyle(fontSize: fontSize),
      ),
    );
  }

  void _calculate() {
    print(dropValue);
    if (material.isValid()) {
      double s11 = 0;
      double s12 = 0;
      double s13 = 0;
      double s16 = 0;

      double s22 = 0;
      double s23 = 0;
      double s26 = 0;

      double s33 = 0;
      double s36 = 0;

      double s44 = 0;
      double s45 = 0;

      double s55 = 0;

      double s66 = 0;

      if (dropValue == "Isotropic material" ||
          dropValue == S.of(context).Isotropic_material) {
        IsotropicMaterial m = material as IsotropicMaterial;
        double e = m.e!;
        double nu = m.nu!;
        double g = e / (2 * (1 + nu));
        s11 = 1 / e;
        s12 = -nu / e;
        s13 = -nu / e;
        s22 = 1 / e;
        s23 = -nu / e;
        s33 = 1 / e;
        s44 = 1 / g;
        s55 = 1 / g;
        s66 = 1 / g;
      } else if (dropValue == S.of(context).Transversely_isotropic_material) {
        TransverselyIsotropicMaterial m =
            material as TransverselyIsotropicMaterial;
        double e1 = m.e1!;
        double e2 = m.e2!;
        double e3 = e2;
        double g12 = m.g12!;
        double g13 = g12;
        double nu12 = m.nu12!;
        double nu13 = nu12;
        double nu23 = m.nu23!;
        double g23 = e2 / (2 * (1 + nu23));
        s11 = 1 / e1;
        s12 = -nu12 / e1;
        s13 = -nu13 / e1;
        s22 = 1 / e2;
        s23 = -nu23 / e2;
        s33 = 1 / e3;
        s44 = 1 / g23;
        s55 = 1 / g13;
        s66 = 1 / g12;
      } else if (dropValue == S.of(context).Orthotropic_material) {
        OrthotropicMaterial m = material as OrthotropicMaterial;
        double e1 = m.e1!;
        double e2 = m.e2!;
        double e3 = m.e3!;
        double g12 = m.g12!;
        double g13 = m.g13!;
        double g23 = m.g23!;
        double nu12 = m.nu12!;
        double nu13 = m.nu13!;
        double nu23 = m.nu23!;
        s11 = 1 / e1;
        s12 = -nu12 / e1;
        s13 = -nu13 / e1;
        s22 = 1 / e2;
        s23 = -nu23 / e2;
        s33 = 1 / e3;
        s44 = 1 / g23;
        s55 = 1 / g13;
        s66 = 1 / g12;
      } else if (dropValue == S.of(context).Monoclinic_material) {
        MonoclinicMaterial m = material as MonoclinicMaterial;
        double e1 = m.e1!;
        double e2 = m.e2!;
        double e3 = m.e3!;
        double g12 = m.g12!;
        double g13 = m.g13!;
        double g23 = m.g23!;
        double nu12 = m.nu12!;
        double nu13 = m.nu13!;
        double nu23 = m.nu23!;
        double eta1_12 = m.eta1_12!;
        double eta2_12 = m.eta2_12!;
        double eta3_12 = m.eta3_12!;
        double eta13_23 = m.eta13_23!;
        s11 = 1 / e1;
        s12 = -nu12 / e1;
        s13 = -nu13 / e1;
        s22 = 1 / e2;
        s23 = -nu23 / e2;
        s33 = 1 / e3;
        s44 = 1 / g23;
        s55 = 1 / g13;
        s66 = 1 / g12;

        s16 = eta1_12 / e1;
        s26 = eta2_12 / e2;
        s36 = eta3_12 / e3;
        s45 = eta13_23 / g13;
      }

      Matrix S_matrix = Matrix([
        [s11, s12, s13, 0, 0, s16],
        [s12, s22, s23, 0, 0, s26],
        [s13, s23, s33, 0, 0, s36],
        [0, 0, 0, s44, s45, 0],
        [0, 0, 0, s45, s55, 0],
        [s16, s26, s36, 0, 0, s66]
      ]);

      Matrix C = S_matrix.inverse();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LinearElasticConstitutiveResultPage(C: C, S: S_matrix)));
    }
  }
}
