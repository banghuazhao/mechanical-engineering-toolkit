import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:linalg/matrix.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/theory_of_elasticity/page/strees_strain_of_linear_elastic_material_result.dart';
import 'package:mechanical_engineering_toolkit/home/theory_of_elasticity/widget/linear_elastic_stress_strain_row.dart';
import 'package:mechanical_engineering_toolkit/home/theory_of_elasticity/widget/material_input_row.dart';
import 'package:provider/provider.dart';

class StressStrainLinearElasticPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const StressStrainLinearElasticPage(
      {Key? key,
      required this.title,
      required this.toolId,
      this.initialInputs})
      : super(key: key);

  @override
  _StressStrainLinearElasticPageState createState() =>
      _StressStrainLinearElasticPageState();
}

class _StressStrainLinearElasticPageState
    extends State<StressStrainLinearElasticPage> {
  MechanicalMaterial material = IsotropicMaterial();
  String dropValue = "Isotropic material";
  MechanicalTensor mechanicalTensor = LinearStress();
  bool validate = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      final inputs = widget.initialInputs!;
      final s = S.current;
      if (inputs.containsKey('Material Type')) {
        dropValue = inputs['Material Type']!;
        if (dropValue == s.Isotropic_material ||
            dropValue == "Isotropic material") {
          material = IsotropicMaterial();
          (material as IsotropicMaterial).e =
              double.tryParse(inputs['E'] ?? '');
          (material as IsotropicMaterial).nu =
              double.tryParse(inputs['ν'] ?? '');
        } else if (dropValue == s.Transversely_isotropic_material) {
          material = TransverselyIsotropicMaterial();
          final m = material as TransverselyIsotropicMaterial;
          m.e1 = double.tryParse(inputs['E1'] ?? '');
          m.e2 = double.tryParse(inputs['E2'] ?? '');
          m.g12 = double.tryParse(inputs['G12'] ?? '');
          m.nu12 = double.tryParse(inputs['ν12'] ?? '');
          m.nu23 = double.tryParse(inputs['ν23'] ?? '');
        } else if (dropValue == s.Orthotropic_material) {
          material = OrthotropicMaterial();
          final m = material as OrthotropicMaterial;
          m.e1 = double.tryParse(inputs['E1'] ?? '');
          m.e2 = double.tryParse(inputs['E2'] ?? '');
          m.e3 = double.tryParse(inputs['E3'] ?? '');
          m.g12 = double.tryParse(inputs['G12'] ?? '');
          m.g13 = double.tryParse(inputs['G13'] ?? '');
          m.g23 = double.tryParse(inputs['G23'] ?? '');
          m.nu12 = double.tryParse(inputs['ν12'] ?? '');
          m.nu13 = double.tryParse(inputs['ν13'] ?? '');
          m.nu23 = double.tryParse(inputs['ν23'] ?? '');
        } else if (dropValue == s.Monoclinic_material) {
          material = MonoclinicMaterial();
          final m = material as MonoclinicMaterial;
          m.e1 = double.tryParse(inputs['E1'] ?? '');
          m.e2 = double.tryParse(inputs['E2'] ?? '');
          m.e3 = double.tryParse(inputs['E3'] ?? '');
          m.g12 = double.tryParse(inputs['G12'] ?? '');
          m.g13 = double.tryParse(inputs['G13'] ?? '');
          m.g23 = double.tryParse(inputs['G23'] ?? '');
          m.nu12 = double.tryParse(inputs['ν12'] ?? '');
          m.nu13 = double.tryParse(inputs['ν13'] ?? '');
          m.nu23 = double.tryParse(inputs['ν23'] ?? '');
          m.eta1_12 = double.tryParse(inputs['η1,12'] ?? '');
          m.eta2_12 = double.tryParse(inputs['η2,12'] ?? '');
          m.eta3_12 = double.tryParse(inputs['η3,12'] ?? '');
          m.eta13_23 = double.tryParse(inputs['η13,23'] ?? '');
        } else if (dropValue == s.Anisotropic_material) {
          material = AnisotropicMaterial();
          final m = material as AnisotropicMaterial;
          m.c11 = double.tryParse(inputs['C11'] ?? '');
          m.c12 = double.tryParse(inputs['C12'] ?? '');
          m.c13 = double.tryParse(inputs['C13'] ?? '');
          m.c14 = double.tryParse(inputs['C14'] ?? '');
          m.c15 = double.tryParse(inputs['C15'] ?? '');
          m.c16 = double.tryParse(inputs['C16'] ?? '');
          m.c22 = double.tryParse(inputs['C22'] ?? '');
          m.c23 = double.tryParse(inputs['C23'] ?? '');
          m.c24 = double.tryParse(inputs['C24'] ?? '');
          m.c25 = double.tryParse(inputs['C25'] ?? '');
          m.c26 = double.tryParse(inputs['C26'] ?? '');
          m.c33 = double.tryParse(inputs['C33'] ?? '');
          m.c34 = double.tryParse(inputs['C34'] ?? '');
          m.c35 = double.tryParse(inputs['C35'] ?? '');
          m.c36 = double.tryParse(inputs['C36'] ?? '');
          m.c44 = double.tryParse(inputs['C44'] ?? '');
          m.c45 = double.tryParse(inputs['C45'] ?? '');
          m.c46 = double.tryParse(inputs['C46'] ?? '');
          m.c55 = double.tryParse(inputs['C55'] ?? '');
          m.c56 = double.tryParse(inputs['C56'] ?? '');
          m.c66 = double.tryParse(inputs['C66'] ?? '');
        }
      }

      if (inputs.containsKey('Input Type')) {
        final inputType = inputs['Input Type']!;
        if (inputType == s.Stress) {
          mechanicalTensor = LinearStress();
          final t = mechanicalTensor as LinearStress;
          t.s11 = double.tryParse(inputs['σ11'] ?? '');
          t.s22 = double.tryParse(inputs['σ22'] ?? '');
          t.s33 = double.tryParse(inputs['σ33'] ?? '');
          t.s23 = double.tryParse(inputs['σ23'] ?? '');
          t.s13 = double.tryParse(inputs['σ13'] ?? '');
          t.s12 = double.tryParse(inputs['σ12'] ?? '');
        } else if (inputType == s.Strain) {
          mechanicalTensor = LinearStrain();
          final t = mechanicalTensor as LinearStrain;
          t.epsilon11 = double.tryParse(inputs['ε11'] ?? '');
          t.epsilon22 = double.tryParse(inputs['ε22'] ?? '');
          t.epsilon33 = double.tryParse(inputs['ε33'] ?? '');
          t.epsilon23 = double.tryParse(inputs['ε23'] ?? '');
          t.epsilon13 = double.tryParse(inputs['ε13'] ?? '');
          t.epsilon12 = double.tryParse(inputs['ε12'] ?? '');
        }
      }
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
                    MaterialInputRow(
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
                          } else if (dropValue ==
                              S.of(context).Anisotropic_material) {
                            material = AnisotropicMaterial();
                          }
                        });
                      },
                    ),
                    LinearElasticStressStrainRow(
                      mechanicalTensor: mechanicalTensor,
                      validate: validate,
                      callback: (value) {
                        setState(() {
                          if (value == S.of(context).Stress) {
                            mechanicalTensor = LinearStress();
                          } else {
                            mechanicalTensor = LinearStrain();
                          }
                        });
                      },
                    ),
                    DescriptionItem(
                        content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("""
Calculate the stress or strain of linear elastic material:
""", style: Theme.of(context).textTheme.bodyMedium),
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
""", style: Theme.of(context).textTheme.bodyMedium);
    } else if (dropValue == S.of(context).Transversely_isotropic_material) {
      return Text("""
Where:
G23 = E2/(2*(1+ν23))
E_i = Young’s modulus in the i-direction
G_ij = Shear modulus in the i-j plane
ν_ij = Poisson’s ratio measuring contraction in the j-direction due to uniaxial loading in the i-direction
""", style: Theme.of(context).textTheme.bodyMedium);
    } else if (dropValue == S.of(context).Orthotropic_material) {
      return Text("""
Where:
E_i = Young’s modulus in the i-direction
G_ij = Shear modulus in the i-j plane
ν_ij = Poisson’s ratio measuring contraction in the j-direction due to uniaxial loading in the i-direction
""");
    } else if (dropValue == S.of(context).Monoclinic_material) {
      return Text("""
Where:
E_i = Young’s modulus in the i-direction
G_ij = Shear modulus in the i-j plane
ν_ij = Poisson’s ratio measuring contraction in the j-direction due to uniaxial loading in the i-direction
η_ij,k = Coefficient of mutual influence of the first kind which characterizes normal strain in the k-direction caused by shear in the i-j plane
η_k,ji = Coefficient of mutual influence of the first kind which characterizes shear the i-j plane caused by normal stress in the k direction
""");
    } else {
      return Text("""
Where:
C_ij = Components of stiffness in i row and j column
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
    } else if (dropValue == S.of(context).Anisotropic_material) {
      mathFormula = r'''\begin{Bmatrix}
        \sigma_{11} \\
  \sigma_{22} \\
  \sigma_{33} \\
  \sigma_{23} \\
  \sigma_{13} \\
  \sigma_{12}

\end{Bmatrix} = 
\begin{bmatrix}
  C_{11} &  C_{12} &  C_{13} &  C_{14} &  C_{15} & C_{16}\\
  C_{21} &  C_{22} &  C_{23} &  C_{24} &  C_{25} & C_{26}\\
  C_{31} &  C_{32} &  C_{33} &  C_{34} &  C_{35} & C_{36}\\
  C_{41} &  C_{42} &  C_{43} &  C_{44} &  C_{45} & C_{46} \\
  C_{51} &  C_{52} &  C_{53} &  C_{54} &  C_{55} & C_{56} \\
  C_{61} &  C_{62} &  C_{63} &  C_{64} &  C_{65} & C_{66}
\end{bmatrix} 
\begin{Bmatrix}
      \varepsilon_{11} \\
  \varepsilon_{22} \\
  \varepsilon_{33} \\
  2\varepsilon_{23} \\
  2\varepsilon_{13} \\
  2\varepsilon_{12}
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
    if (material.isValid() && mechanicalTensor.isValid()) {
      final Map<String, String> inputs = {
        'Material Type': dropValue,
        'Input Type': mechanicalTensor is LinearStress ? S.of(context).Stress : S.of(context).Strain,
      };
      if (material is IsotropicMaterial) {
        inputs['E'] = (material as IsotropicMaterial).e.toString();
        inputs['ν'] = (material as IsotropicMaterial).nu.toString();
      } else if (material is TransverselyIsotropicMaterial) {
        final m = material as TransverselyIsotropicMaterial;
        inputs['E1'] = m.e1.toString();
        inputs['E2'] = m.e2.toString();
        inputs['G12'] = m.g12.toString();
        inputs['ν12'] = m.nu12.toString();
        inputs['ν23'] = m.nu23.toString();
      } else if (material is OrthotropicMaterial) {
        final m = material as OrthotropicMaterial;
        inputs['E1'] = m.e1.toString();
        inputs['E2'] = m.e2.toString();
        inputs['E3'] = m.e3.toString();
        inputs['G12'] = m.g12.toString();
        inputs['G13'] = m.g13.toString();
        inputs['G23'] = m.g23.toString();
        inputs['ν12'] = m.nu12.toString();
        inputs['ν13'] = m.nu13.toString();
        inputs['ν23'] = m.nu23.toString();
      } else if (material is MonoclinicMaterial) {
        final m = material as MonoclinicMaterial;
        inputs['E1'] = m.e1.toString();
        inputs['E2'] = m.e2.toString();
        inputs['E3'] = m.e3.toString();
        inputs['G12'] = m.g12.toString();
        inputs['G13'] = m.g13.toString();
        inputs['G23'] = m.g23.toString();
        inputs['ν12'] = m.nu12.toString();
        inputs['ν13'] = m.nu13.toString();
        inputs['ν23'] = m.nu23.toString();
        inputs['η1,12'] = m.eta1_12.toString();
        inputs['η2,12'] = m.eta2_12.toString();
        inputs['η3,12'] = m.eta3_12.toString();
        inputs['η13,23'] = m.eta13_23.toString();
      } else if (material is AnisotropicMaterial) {
        final m = material as AnisotropicMaterial;
        inputs['C11'] = m.c11.toString(); inputs['C12'] = m.c12.toString(); inputs['C13'] = m.c13.toString();
        inputs['C14'] = m.c14.toString(); inputs['C15'] = m.c15.toString(); inputs['C16'] = m.c16.toString();
        inputs['C22'] = m.c22.toString(); inputs['C23'] = m.c23.toString(); inputs['C24'] = m.c24.toString();
        inputs['C25'] = m.c25.toString(); inputs['C26'] = m.c26.toString(); inputs['C33'] = m.c33.toString();
        inputs['C34'] = m.c34.toString(); inputs['C35'] = m.c35.toString(); inputs['C36'] = m.c36.toString();
        inputs['C44'] = m.c44.toString(); inputs['C45'] = m.c45.toString(); inputs['C46'] = m.c46.toString();
        inputs['C55'] = m.c55.toString(); inputs['C56'] = m.c56.toString(); inputs['C66'] = m.c66.toString();
      }

      if (mechanicalTensor is LinearStress) {
        final t = mechanicalTensor as LinearStress;
        inputs['σ11'] = t.s11.toString(); inputs['σ22'] = t.s22.toString(); inputs['σ33'] = t.s33.toString();
        inputs['σ23'] = t.s23.toString(); inputs['σ13'] = t.s13.toString(); inputs['σ12'] = t.s12.toString();
      } else if (mechanicalTensor is LinearStrain) {
        final t = mechanicalTensor as LinearStrain;
        inputs['ε11'] = t.epsilon11.toString(); inputs['ε22'] = t.epsilon22.toString(); inputs['ε33'] = t.epsilon33.toString();
        inputs['ε23'] = t.epsilon23.toString(); inputs['ε13'] = t.epsilon13.toString(); inputs['ε12'] = t.epsilon12.toString();
      }
      context.read<ToolHistory>().record(widget.toolId, inputs: inputs);

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
      } else if (dropValue == S.of(context).Anisotropic_material) {
        AnisotropicMaterial m = material as AnisotropicMaterial;
        double c11 = m.c11!;
        double c12 = m.c12!;
        double c13 = m.c13!;
        double c14 = m.c14!;
        double c15 = m.c15!;
        double c16 = m.c16!;
        double c22 = m.c22!;
        double c23 = m.c23!;
        double c24 = m.c24!;
        double c25 = m.c25!;
        double c26 = m.c26!;
        double c33 = m.c33!;
        double c34 = m.c34!;
        double c35 = m.c35!;
        double c36 = m.c36!;
        double c44 = m.c44!;
        double c45 = m.c45!;
        double c46 = m.c46!;
        double c55 = m.c55!;
        double c56 = m.c56!;
        double c66 = m.c66!;

        Matrix C = Matrix([
          [c11, c12, c13, c14, c15, c16],
          [c12, c22, c23, c24, c25, c26],
          [c13, c23, c33, c34, c35, c36],
          [c14, c24, c34, c44, c45, c46],
          [c15, c25, c35, c45, c55, c56],
          [c16, c26, c36, c46, c56, c66]
        ]);
        Matrix S_matrix = C.inverse();

        MechanicalTensor resultTensor;
        if (mechanicalTensor is LinearStress) {
          double s11 = (mechanicalTensor as LinearStress).s11!;
          double s22 = (mechanicalTensor as LinearStress).s22!;
          double s33 = (mechanicalTensor as LinearStress).s33!;
          double s23 = (mechanicalTensor as LinearStress).s23!;
          double s13 = (mechanicalTensor as LinearStress).s13!;
          double s12 = (mechanicalTensor as LinearStress).s12!;
          Matrix stressVector = Matrix([
            [s11],
            [s22],
            [s33],
            [s23],
            [s13],
            [s12],
          ]);
          Matrix strainVector = S_matrix * stressVector;
          resultTensor = LinearStrain.from(
              strainVector[0][0],
              strainVector[1][0],
              strainVector[2][0],
              strainVector[3][0] / 2,
              strainVector[4][0] / 2,
              strainVector[5][0] / 2);
        } else {
          double epsilon11 = (mechanicalTensor as LinearStrain).epsilon11!;
          double epsilon22 = (mechanicalTensor as LinearStrain).epsilon22!;
          double epsilon33 = (mechanicalTensor as LinearStrain).epsilon33!;
          double epsilon23 = (mechanicalTensor as LinearStrain).epsilon23!;
          double epsilon13 = (mechanicalTensor as LinearStrain).epsilon13!;
          double epsilon12 = (mechanicalTensor as LinearStrain).epsilon12!;
          Matrix strainVector = Matrix([
            [epsilon11],
            [epsilon22],
            [epsilon33],
            [2 * epsilon23],
            [2 * epsilon13],
            [2 * epsilon12]
          ]);
          Matrix stressVector = C * strainVector;
          resultTensor = LinearStress.from(
              stressVector[0][0],
              stressVector[1][0],
              stressVector[2][0],
              stressVector[3][0],
              stressVector[4][0],
              stressVector[5][0]);
        }

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => StressStrainLinearElasticResultPage(
                    mechanicalTensor: resultTensor, C: C, S: S_matrix)));
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

      MechanicalTensor resultTensor;
      if (mechanicalTensor is LinearStress) {
        double s11 = (mechanicalTensor as LinearStress).s11!;
        double s22 = (mechanicalTensor as LinearStress).s22!;
        double s33 = (mechanicalTensor as LinearStress).s33!;
        double s23 = (mechanicalTensor as LinearStress).s23!;
        double s13 = (mechanicalTensor as LinearStress).s13!;
        double s12 = (mechanicalTensor as LinearStress).s12!;
        Matrix stressVector = Matrix([
          [s11],
          [s22],
          [s33],
          [s23],
          [s13],
          [s12],
        ]);
        Matrix strainVector = S_matrix * stressVector;
        resultTensor = LinearStrain.from(
            strainVector[0][0],
            strainVector[1][0],
            strainVector[2][0],
            strainVector[3][0] / 2,
            strainVector[4][0] / 2,
            strainVector[5][0] / 2);
      } else {
        double epsilon11 = (mechanicalTensor as LinearStrain).epsilon11!;
        double epsilon22 = (mechanicalTensor as LinearStrain).epsilon22!;
        double epsilon33 = (mechanicalTensor as LinearStrain).epsilon33!;
        double epsilon23 = (mechanicalTensor as LinearStrain).epsilon23!;
        double epsilon13 = (mechanicalTensor as LinearStrain).epsilon13!;
        double epsilon12 = (mechanicalTensor as LinearStrain).epsilon12!;
        Matrix strainVector = Matrix([
          [epsilon11],
          [epsilon22],
          [epsilon33],
          [2 * epsilon23],
          [2 * epsilon13],
          [2 * epsilon12]
        ]);
        Matrix stressVector = C * strainVector;
        resultTensor = LinearStress.from(
            stressVector[0][0],
            stressVector[1][0],
            stressVector[2][0],
            stressVector[3][0],
            stressVector[4][0],
            stressVector[5][0]);
      }

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StressStrainLinearElasticResultPage(
                  mechanicalTensor: resultTensor, C: C, S: S_matrix)));
    }
  }
}
