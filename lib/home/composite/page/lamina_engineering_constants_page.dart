import 'package:composite_calculator/composite_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/analysis_type_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/lamina_constants_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/thermal_constants_row.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:provider/provider.dart';

import 'lamina_engineering_constants_result_page.dart';

class LaminaEngineeringConstantsPage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const LaminaEngineeringConstantsPage(
      {Key? key, required this.title, required this.toolId, this.initialInputs})
      : super(key: key);

  @override
  _LaminaEngineeringConstantsPageState createState() =>
      _LaminaEngineeringConstantsPageState();
}

class _LaminaEngineeringConstantsPageState
    extends State<LaminaEngineeringConstantsPage> {
  AnalysisType analysisType = AnalysisType.elastic;
  TransverselyIsotropicMaterial material = TransverselyIsotropicMaterial();
  ThermalConstants thermalConstants = ThermalConstants();
  bool validate = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialInputs != null) {
      final inputs = widget.initialInputs!;
      if (inputs.containsKey('Analysis Type')) {
        analysisType = AnalysisType.values.firstWhere(
            (e) => e.toString().split('.').last == inputs['Analysis Type'],
            orElse: () => AnalysisType.elastic);
      }
      material.e1 = double.tryParse(inputs['E1'] ?? '');
      material.e2 = double.tryParse(inputs['E2'] ?? '');
      material.g12 = double.tryParse(inputs['G12'] ?? '');
      material.nu12 = double.tryParse(inputs['ν12'] ?? '');
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
              'Calculate engineering constants of a transversely isotropic lamina as a function of layup angle (shown as curves from −90° to 90°).',
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
          itemCount: items.length,
          staggeredTileBuilder: (_) => StaggeredTile.fit(
              MediaQuery.of(context).size.width > 600 ? 4 : 8),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (_, i) => items[i],
        ),
      ),
    );
  }

  void _calculate() {
    if (!material.isValidInPlane()) return;
    if (isThermal && !thermalConstants.isValid()) return;

    final Map<String, String> inputs = {
      'Analysis Type': analysisType.toString().split('.').last,
      'E1': material.e1.toString(),
      'E2': material.e2.toString(),
      'G12': material.g12.toString(),
      'ν12': material.nu12.toString(),
    };
    if (isThermal) {
      inputs['α11'] = thermalConstants.alpha11.toString();
      inputs['α22'] = thermalConstants.alpha22.toString();
      inputs['α12'] = thermalConstants.alpha12.toString();
    }
    context.read<ToolHistory>().record(widget.toolId, inputs: inputs);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LaminaEngineeringConstantsResultPage(
          toolId: widget.toolId,
          material: material,
          analysisType: analysisType,
          thermalConstants: thermalConstants,
        ),
      ),
    );
  }
}
