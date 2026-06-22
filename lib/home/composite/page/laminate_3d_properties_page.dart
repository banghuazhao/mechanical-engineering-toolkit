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
  AnalysisType analysisType = AnalysisType.elastic;
  TransverselyIsotropicMaterial material = TransverselyIsotropicMaterial();
  LayupSequence layupSequence = LayupSequence();
  LayerThickness layerThickness = LayerThickness();
  ThermalConstants thermalConstants = ThermalConstants();
  bool validate = false;

  bool get isThermal => analysisType == AnalysisType.thermalElastic;

  @override
  Widget build(BuildContext context) {
    final items = [
      AnalysisTypeRow(
          value: analysisType,
          onChanged: (v) => setState(() => analysisType = v)),
      LaminaContantsRow(
          material: material, validate: validate, isPlaneStress: false),
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
              'Compute the full 3D effective stiffness/compliance and engineering constants of a laminate using Voigt averaging of rotated ply stiffnesses.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Center(
              child: Math.tex(
                r'''\bar{C}=\frac{1}{N}\sum_{k=1}^{N}R_\sigma^{(k)}C^{(k)}\left(R_\sigma^{(k)}\right)^T''',
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
    if (!material.isValid() ||
        !layupSequence.isValid() ||
        !layerThickness.isValid()) return;
    if (isThermal && !thermalConstants.isValid()) return;

    final input = Laminate3DPropertiesInput(
      analysisType: analysisType,
      E1: material.e1!,
      E2: material.e2!,
      G12: material.g12!,
      nu12: material.nu12!,
      nu23: material.nu23!,
      layupSequence: layupSequence.rawValue ?? '',
      layerThickness: layerThickness.value!,
      alpha11: thermalConstants.alpha11 ?? 0,
      alpha22: thermalConstants.alpha22 ?? 0,
      alpha12: thermalConstants.alpha12 ?? 0,
    );

    final output = Laminate3DPropertiesCalculator.calculate(input);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Laminate3DPropertiesResultPage(
            output: output, analysisType: analysisType),
      ),
    );
  }
}
