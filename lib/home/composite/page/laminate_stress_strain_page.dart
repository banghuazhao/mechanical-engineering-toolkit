import 'package:composite_calculator/composite_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
  TransverselyIsotropicMaterial material = TransverselyIsotropicMaterial();
  LayupSequence layupSequence = LayupSequence();
  LayerThickness layerThickness = LayerThickness();
  MechanicalTensor mechanicalTensor = LaminateStress();
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
          setState(() => validate = true);
          _calculate();
        },
        label: Text(S.of(context).Calculate),
      ),
      body: SafeArea(
        child: StaggeredGridView.countBuilder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          crossAxisCount: 8,
          itemCount: 5,
          staggeredTileBuilder: (_) =>
              StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (context, index) => [
            LaminaContantsRow(
                material: material, validate: validate, isPlaneStress: true),
            LayupSequenceRow(layupSequence: layupSequence, validate: validate),
            LayerThicknessPage(
                layerThickness: layerThickness, validate: validate),
            LaminateStressStrainRow(
              mechanicalTensor: mechanicalTensor,
              validate: validate,
              callback: (v) => setState(() {
                mechanicalTensor = v == 'Stress Resultant'
                    ? LaminateStress()
                    : LaminateStrain();
              }),
            ),
            DescriptionItem(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apply Classical Laminate Theory (CLT) to compute mid-plane strains, curvatures, or stress resultants.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Math.tex(
                      r'''\begin{Bmatrix}N\\M\end{Bmatrix}=\begin{bmatrix}A&B\\B&D\end{bmatrix}\begin{Bmatrix}\varepsilon^0\\\kappa\end{Bmatrix}''',
                      mathStyle: MathStyle.display,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ][index],
        ),
      ),
    );
  }

  void _calculate() {
    if (!material.isValidInPlane() ||
        !layupSequence.isValid() ||
        !layerThickness.isValid() ||
        !mechanicalTensor.isValid()) return;

    final tensorType =
        mechanicalTensor is LaminateStress ? TensorType.stress : TensorType.strain;
    final s = mechanicalTensor is LaminateStress
        ? mechanicalTensor as LaminateStress
        : null;
    final e = mechanicalTensor is LaminateStrain
        ? mechanicalTensor as LaminateStrain
        : null;

    final input = LaminarStressStrainInput(
      E1: material.e1!,
      E2: material.e2!,
      G12: material.g12!,
      nu12: material.nu12!,
      layupSequence: layupSequence.rawValue ?? '',
      layerThickness: layerThickness.value!,
      tensorType: tensorType,
      N11: s?.N11 ?? 0,
      N22: s?.N22 ?? 0,
      N12: s?.N12 ?? 0,
      M11: s?.M11 ?? 0,
      M22: s?.M22 ?? 0,
      M12: s?.M12 ?? 0,
      epsilon11: e?.epsilon11 ?? 0,
      epsilon22: e?.epsilon22 ?? 0,
      epsilon12: e?.epsilon12 ?? 0,
      kappa11: e?.kappa11 ?? 0,
      kappa22: e?.kappa22 ?? 0,
      kappa12: e?.kappa12 ?? 0,
    );

    final output = LaminarStressStrainCalculator.calculate(input);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LaminateStressStrainResultPage(
          output: output,
          input: input,
          material: material,
        ),
      ),
    );
  }
}
