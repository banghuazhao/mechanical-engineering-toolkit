import 'package:composite_calculator/composite_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/layer_thickness.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/layup_sequence_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/analysis_type_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/lamina_constants_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/layer_thickness_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/layup_sequence_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/thermal_constants_row.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:provider/provider.dart';

import 'laminate_plane_properties_result_page.dart';

class LaminatePlanePropertiesPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const LaminatePlanePropertiesPage(
      {Key? key,
      required this.title,
      required this.toolId,
      this.initialInputs})
      : super(key: key);

  @override
  _LaminatePlanePropertiesPageState createState() =>
      _LaminatePlanePropertiesPageState();
}

class _LaminatePlanePropertiesPageState
    extends State<LaminatePlanePropertiesPage> {
  AnalysisType analysisType = AnalysisType.elastic;
  TransverselyIsotropicMaterial material = TransverselyIsotropicMaterial();
  LayupSequence layupSequence = LayupSequence();
  LayerThickness layerThickness = LayerThickness();
  ThermalConstants thermalConstants = ThermalConstants();
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
      if (inputs.containsKey(s.Layup_Sequence)) {
        layupSequence.rawValue = inputs[s.Layup_Sequence];
      }
      if (inputs.containsKey(s.Layer_Thickness)) {
        layerThickness.value = double.tryParse(inputs[s.Layer_Thickness]!);
      }
      if (isThermal) {
        thermalConstants.alpha11 = double.tryParse(inputs['α11'] ?? '');
        thermalConstants.alpha22 = double.tryParse(inputs['α22'] ?? '');
        thermalConstants.alpha12 = double.tryParse(inputs['α12'] ?? '');
      }
    }
  }

  bool get isThermal => analysisType == AnalysisType.thermalElastic;

  @override
  Widget build(BuildContext context) {
    final items = [
      AnalysisTypeRow(
          value: analysisType,
          onChanged: (v) => setState(() => analysisType = v)),
      LaminaContantsRow(
          material: material, validate: validate, isPlaneStress: true),
      LayupSequenceRow(layupSequence: layupSequence, validate: validate),
      LayerThicknessPage(layerThickness: layerThickness, validate: validate),
      if (isThermal)
        ThermalConstantsRow(
            thermalConstants: thermalConstants,
            validate: validate,
            showAlpha12: true),
      DescriptionItem(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compute effective in-plane and flexural engineering properties of a multi-ply laminate using Classical Laminate Theory.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Center(
              child: Math.tex(
                r'''\begin{bmatrix}A&B\\B&D\end{bmatrix}=\sum_k\int_{z_k}^{z_{k+1}}\bar{Q}^{(k)}\begin{bmatrix}1\\z\\z^2\end{bmatrix}dz''',
                mathStyle: MathStyle.display,
                textStyle: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    ];

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
          itemCount: items.length,
          staggeredTileBuilder: (_) =>
              StaggeredTile.fit(MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (_, i) => items[i],
        ),
      ),
    );
  }

  void _calculate() {
    if (!material.isValidInPlane() ||
        !layupSequence.isValid() ||
        !layerThickness.isValid()) return;
    if (isThermal && !thermalConstants.isValid()) return;

    final Map<String, String> inputs = {
      'Analysis Type': analysisType.toString().split('.').last,
      'E1': material.e1.toString(),
      'E2': material.e2.toString(),
      'G12': material.g12.toString(),
      'ν12': material.nu12.toString(),
      S.of(context).Layup_Sequence: layupSequence.rawValue.toString(),
      S.of(context).Layer_Thickness: layerThickness.value.toString(),
    };
    if (isThermal) {
      inputs['α11'] = thermalConstants.alpha11.toString();
      inputs['α22'] = thermalConstants.alpha22.toString();
      inputs['α12'] = thermalConstants.alpha12.toString();
    }
    context.read<ToolHistory>().record(widget.toolId, inputs: inputs);

    final input = LaminatePlatePropertiesInput(
      analysisType: analysisType,
      E1: material.e1!,
      E2: material.e2!,
      G12: material.g12!,
      nu12: material.nu12!,
      layupSequence: layupSequence.rawValue ?? '',
      layerThickness: layerThickness.value!,
      alpha11: thermalConstants.alpha11 ?? 0,
      alpha22: thermalConstants.alpha22 ?? 0,
      alpha12: thermalConstants.alpha12 ?? 0,
    );

    final output = LaminatePlatePropertiesCalculator.calculate(input);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LaminatePlanePropertiesResultPage(
            output: output, analysisType: analysisType),
      ),
    );
  }
}
