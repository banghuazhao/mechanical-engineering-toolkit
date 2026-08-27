import 'package:composite_calculator/composite_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/angle_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/mechanical_tensor_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/analysis_type_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/delta_temperature_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/lamina_constants_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/layup_angle_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/plane_stress_strain_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/thermal_constants_row.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:provider/provider.dart';

import 'lamina_stress_strain_result_page.dart';

class LaminaStressStrainPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const LaminaStressStrainPage(
      {Key? key, required this.title, required this.toolId, this.initialInputs})
      : super(key: key);

  @override
  _LaminaStressStrainPageState createState() => _LaminaStressStrainPageState();
}

class _LaminaStressStrainPageState extends State<LaminaStressStrainPage> {
  AnalysisType analysisType = AnalysisType.elastic;
  TransverselyIsotropicMaterial material = TransverselyIsotropicMaterial();
  LayupAngle layupAngle = LayupAngle();
  MechanicalTensor mechanicalTensor = PlaneStress();
  ThermalConstants thermalConstants = ThermalConstants();
  double? deltaT;
  bool validate = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      final inputs = widget.initialInputs!;
      final s = S.current;
      if (inputs.containsKey('Analysis Type')) {
        analysisType = AnalysisType.values.firstWhere(
            (e) => e.toString().split('.').last == inputs['Analysis Type'],
            orElse: () => AnalysisType.elastic);
      }
      material.e1 = double.tryParse(inputs['E1'] ?? '');
      material.e2 = double.tryParse(inputs['E2'] ?? '');
      material.g12 = double.tryParse(inputs['G12'] ?? '');
      material.nu12 = double.tryParse(inputs['ν12'] ?? '');
      if (inputs.containsKey(s.Layup_Angle)) {
        layupAngle.value = double.tryParse(inputs[s.Layup_Angle]!);
      }
      if (inputs.containsKey('Input Type')) {
        final inputType = inputs['Input Type']!;
        if (inputType == s.Stress) {
          mechanicalTensor = PlaneStress();
          final t = mechanicalTensor as PlaneStress;
          t.sigma11 = double.tryParse(inputs['σ11'] ?? '');
          t.sigma22 = double.tryParse(inputs['σ22'] ?? '');
          t.sigma12 = double.tryParse(inputs['σ12'] ?? '');
        } else if (inputType == s.Strain) {
          mechanicalTensor = PlaneStrain();
          final t = mechanicalTensor as PlaneStrain;
          t.epsilon11 = double.tryParse(inputs['ε11'] ?? '');
          t.epsilon22 = double.tryParse(inputs['ε22'] ?? '');
          t.gamma12 = double.tryParse(inputs['γ12'] ?? '');
        }
      }
      if (isThermal) {
        thermalConstants.alpha11 = double.tryParse(inputs['α11'] ?? '');
        thermalConstants.alpha22 = double.tryParse(inputs['α22'] ?? '');
        thermalConstants.alpha12 = double.tryParse(inputs['α12'] ?? '');
        deltaT = double.tryParse(inputs['ΔT'] ?? '');
      }
    }
  }

  bool get isThermal => analysisType == AnalysisType.thermalElastic;

  int get _itemCount => isThermal ? 7 : 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title),
        actions: [
          ToolHelpButton(toolId: widget.toolId, toolTitle: widget.title),
        ],
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
          itemCount: _itemCount,
          staggeredTileBuilder: (_) => StaggeredTile.fit(
              MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (context, index) {
            final items = [
              AnalysisTypeRow(
                value: analysisType,
                onChanged: (v) => setState(() => analysisType = v),
              ),
              LaminaContantsRow(
                  material: material, validate: validate, isPlaneStress: true),
              LayupAngleRow(
                  layupAngle: layupAngle,
                  validate: validate,
                  title: S.of(context).Layup_Angle),
              PlaneStressStrainRow(
                mechanicalTensor: mechanicalTensor,
                validate: validate,
                callback: (v) => setState(() {
                  mechanicalTensor =
                      v == S.of(context).Stress ? PlaneStress() : PlaneStrain();
                }),
              ),
              if (isThermal) ...[
                ThermalConstantsRow(
                    thermalConstants: thermalConstants,
                    validate: validate,
                    showAlpha12: true),
                DeltaTemperatureRow(
                    value: deltaT,
                    validate: validate,
                    onChanged: (v) => setState(() => deltaT = v)),
              ],
              DescriptionItem(
                content: Column(
                  children: [
                    Text(
                      'Calculate stress or strain of a lamina at a given fiber orientation angle.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Math.tex(
                        r'''\begin{Bmatrix}\varepsilon_{11}\\\varepsilon_{22}\\\gamma_{12}\end{Bmatrix}=\begin{bmatrix}\frac{1}{E_1}&-\frac{\nu_{12}}{E_1}&0\\-\frac{\nu_{12}}{E_1}&\frac{1}{E_2}&0\\0&0&\frac{1}{G_{12}}\end{bmatrix}\begin{Bmatrix}\sigma_{11}\\\sigma_{22}\\\sigma_{12}\end{Bmatrix}''',
                        mathStyle: MathStyle.display,
                        textStyle: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ];
            return items[index];
          },
        ),
      ),
    );
  }

  void _calculate() {
    if (!material.isValidInPlane() ||
        !layupAngle.isValid() ||
        !mechanicalTensor.isValid()) {
      return;
    }
    if (isThermal && (!thermalConstants.isValid() || deltaT == null)) return;

    final Map<String, String> inputs = {
      'Analysis Type': analysisType.toString().split('.').last,
      'E1': material.e1.toString(),
      'E2': material.e2.toString(),
      'G12': material.g12.toString(),
      'ν12': material.nu12.toString(),
      S.of(context).Layup_Angle: layupAngle.value.toString(),
      'Input Type': mechanicalTensor is PlaneStress
          ? S.of(context).Stress
          : S.of(context).Strain,
    };
    if (mechanicalTensor is PlaneStress) {
      final t = mechanicalTensor as PlaneStress;
      inputs['σ11'] = t.sigma11.toString();
      inputs['σ22'] = t.sigma22.toString();
      inputs['σ12'] = t.sigma12.toString();
    } else if (mechanicalTensor is PlaneStrain) {
      final t = mechanicalTensor as PlaneStrain;
      inputs['ε11'] = t.epsilon11.toString();
      inputs['ε22'] = t.epsilon22.toString();
      inputs['γ12'] = t.gamma12.toString();
    }
    if (isThermal) {
      inputs['α11'] = thermalConstants.alpha11.toString();
      inputs['α22'] = thermalConstants.alpha22.toString();
      inputs['α12'] = thermalConstants.alpha12.toString();
      inputs['ΔT'] = deltaT.toString();
    }
    context.read<ToolHistory>().record(widget.toolId, inputs: inputs);

    final tensorType =
        mechanicalTensor is PlaneStress ? TensorType.stress : TensorType.strain;
    final input = LaminaStressStrainInput(
      analysisType: analysisType,
      E1: material.e1!,
      E2: material.e2!,
      G12: material.g12!,
      nu12: material.nu12!,
      layupAngle: layupAngle.value!,
      alpha11: thermalConstants.alpha11 ?? 0,
      alpha22: thermalConstants.alpha22 ?? 0,
      alpha12: thermalConstants.alpha12 ?? 0,
      deltaT: deltaT ?? 0,
      tensorType: tensorType,
      sigma11: mechanicalTensor is PlaneStress
          ? (mechanicalTensor as PlaneStress).sigma11 ?? 0
          : 0,
      sigma22: mechanicalTensor is PlaneStress
          ? (mechanicalTensor as PlaneStress).sigma22 ?? 0
          : 0,
      sigma12: mechanicalTensor is PlaneStress
          ? (mechanicalTensor as PlaneStress).sigma12 ?? 0
          : 0,
      epsilon11: mechanicalTensor is PlaneStrain
          ? (mechanicalTensor as PlaneStrain).epsilon11 ?? 0
          : 0,
      epsilon22: mechanicalTensor is PlaneStrain
          ? (mechanicalTensor as PlaneStrain).epsilon22 ?? 0
          : 0,
      gamma12: mechanicalTensor is PlaneStrain
          ? (mechanicalTensor as PlaneStrain).gamma12 ?? 0
          : 0,
    );

    final output = LaminaStressStrainCalculator.calculate(input);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LaminaStressStrainResultPage(
            toolId: widget.toolId,
            output: output,
            analysisType: analysisType),
      ),
    );
  }
}
