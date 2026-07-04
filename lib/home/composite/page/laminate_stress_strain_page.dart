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
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:provider/provider.dart';

import 'laminate_stress_strain_result_page.dart';

class LaminateStressStrainPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const LaminateStressStrainPage(
      {Key? key,
      required this.title,
      required this.toolId,
      this.initialInputs})
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
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      final inputs = widget.initialInputs!;
      final s = S.current;
      material.e1 = double.tryParse(inputs['E1'] ?? '');
      material.e2 = double.tryParse(inputs['E2'] ?? '');
      material.g12 = double.tryParse(inputs['G12'] ?? '');
      material.nu12 = double.tryParse(inputs['ν12'] ?? '');
      if (inputs.containsKey(s.Layup_Sequence)) {
        layupSequence.rawValue = inputs[s.Layup_Sequence];
      }
      if (inputs.containsKey(s.Layer_Thickness)) {
        layerThickness.value = double.tryParse(inputs[s.Layer_Thickness]!);
      }
      if (inputs.containsKey('Input Type')) {
        final inputType = inputs['Input Type']!;
        if (inputType == 'Stress Resultant') {
          mechanicalTensor = LaminateStress();
          final t = mechanicalTensor as LaminateStress;
          t.N11 = double.tryParse(inputs['N11'] ?? '');
          t.N22 = double.tryParse(inputs['N22'] ?? '');
          t.N12 = double.tryParse(inputs['N12'] ?? '');
          t.M11 = double.tryParse(inputs['M11'] ?? '');
          t.M22 = double.tryParse(inputs['M22'] ?? '');
          t.M12 = double.tryParse(inputs['M12'] ?? '');
        } else if (inputType == 'Mid-plane Strain') {
          mechanicalTensor = LaminateStrain();
          final t = mechanicalTensor as LaminateStrain;
          t.epsilon11 = double.tryParse(inputs['ε011'] ?? '');
          t.epsilon22 = double.tryParse(inputs['ε022'] ?? '');
          t.epsilon12 = double.tryParse(inputs['γ012'] ?? '');
          t.kappa11 = double.tryParse(inputs['κ11'] ?? '');
          t.kappa22 = double.tryParse(inputs['κ22'] ?? '');
          t.kappa12 = double.tryParse(inputs['κ12'] ?? '');
        }
      }
    }
  }

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

    final Map<String, String> inputs = {
      'E1': material.e1.toString(),
      'E2': material.e2.toString(),
      'G12': material.g12.toString(),
      'ν12': material.nu12.toString(),
      S.of(context).Layup_Sequence: layupSequence.rawValue.toString(),
      S.of(context).Layer_Thickness: layerThickness.value.toString(),
      'Input Type': mechanicalTensor is LaminateStress ? 'Stress Resultant' : 'Mid-plane Strain',
    };
    if (mechanicalTensor is LaminateStress) {
      final t = mechanicalTensor as LaminateStress;
      inputs['N11'] = t.N11.toString(); inputs['N22'] = t.N22.toString(); inputs['N12'] = t.N12.toString();
      inputs['M11'] = t.M11.toString(); inputs['M22'] = t.M22.toString(); inputs['M12'] = t.M12.toString();
    } else if (mechanicalTensor is LaminateStrain) {
      final t = mechanicalTensor as LaminateStrain;
      inputs['ε011'] = t.epsilon11.toString(); inputs['ε022'] = t.epsilon22.toString(); inputs['γ012'] = t.epsilon12.toString();
      inputs['κ11'] = t.kappa11.toString(); inputs['κ22'] = t.kappa22.toString(); inputs['κ12'] = t.kappa12.toString();
    }
    context.read<ToolHistory>().record(widget.toolId, inputs: inputs);

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
