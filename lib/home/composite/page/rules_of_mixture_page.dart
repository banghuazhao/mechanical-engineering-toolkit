import 'package:composite_calculator/composite_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/material_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/volume_fraction_model.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/analysis_type_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/description.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/isotropic_material_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/lamina_constants_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/thermal_constants_row.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/volume_fraction_row.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/ui/tool_help_button.dart';
import 'package:provider/provider.dart';

import 'rules_of_mixture_result_page.dart';

class RulesOfMixturePage extends StatefulWidget {
  final String title;
  final int toolId;
  final Map<String, String>? initialInputs;
  const RulesOfMixturePage(
      {Key? key, required this.title, required this.toolId, this.initialInputs})
      : super(key: key);

  @override
  _RulesOfMixturePageState createState() => _RulesOfMixturePageState();
}

class _RulesOfMixturePageState extends State<RulesOfMixturePage> {
  AnalysisType analysisType = AnalysisType.elastic;
  TransverselyIsotropicMaterial fiberMaterial = TransverselyIsotropicMaterial();
  IsotropicMaterial matrixMaterial = IsotropicMaterial();
  VolumeFraction fiberVolumeFraction = VolumeFraction();
  ThermalConstants fiberThermal = ThermalConstants();
  double? matrixAlpha;
  late TextEditingController _matrixAlphaController;
  bool validate = false;

  @override
  void initState() {
    super.initState();
    _matrixAlphaController = TextEditingController();
    if (widget.initialInputs != null) {
      final inputs = widget.initialInputs!;
      if (inputs.containsKey('Analysis Type')) {
        analysisType = AnalysisType.values.firstWhere(
            (e) => e.toString().split('.').last == inputs['Analysis Type'],
            orElse: () => AnalysisType.elastic);
      }
      fiberMaterial.e1 = double.tryParse(inputs['E1 (fiber)'] ?? '');
      fiberMaterial.e2 = double.tryParse(inputs['E2 (fiber)'] ?? '');
      fiberMaterial.g12 = double.tryParse(inputs['G12 (fiber)'] ?? '');
      fiberMaterial.nu12 = double.tryParse(inputs['ν12 (fiber)'] ?? '');
      fiberMaterial.nu23 = double.tryParse(inputs['ν23 (fiber)'] ?? '');
      matrixMaterial.e = double.tryParse(inputs['E (matrix)'] ?? '');
      matrixMaterial.nu = double.tryParse(inputs['ν (matrix)'] ?? '');
      fiberVolumeFraction.value =
          double.tryParse(inputs['Fiber Volume Fraction'] ?? '');
      if (isThermal) {
        fiberThermal.alpha11 = double.tryParse(inputs['α11 (fiber)'] ?? '');
        fiberThermal.alpha22 = double.tryParse(inputs['α22 (fiber)'] ?? '');
        matrixAlpha = double.tryParse(inputs['α (matrix)'] ?? '');
        _matrixAlphaController.text = matrixAlpha?.toString() ?? '';
      }
    }
  }

  @override
  void dispose() {
    _matrixAlphaController.dispose();
    super.dispose();
  }

  bool get isThermal => analysisType == AnalysisType.thermalElastic;

  @override
  Widget build(BuildContext context) {
    final items = [
      AnalysisTypeRow(
          value: analysisType,
          onChanged: (v) => setState(() => analysisType = v)),
      LaminaContantsRow(
          material: fiberMaterial,
          validate: validate,
          isPlaneStress: false,
          title: 'Fiber (Transversely Isotropic)'),
      if (isThermal)
        ThermalConstantsRow(
            thermalConstants: fiberThermal,
            validate: validate,
            showAlpha12: false),
      IsotropicMaterialRow(
          title: 'Matrix Material',
          material: matrixMaterial,
          validate: validate),
      if (isThermal) _matrixAlphaRow(),
      VolumeFractionRow(
          volumeFraction: fiberVolumeFraction, validate: validate),
      DescriptionItem(
        content: Text(
          'Calculate effective stiffness matrix and engineering constants for three micromechanics models:\n'
          '1. Voigt (uniform strain)\n'
          '2. Reuss (uniform stress)\n'
          '3. Hybrid (mixed boundary conditions)',
          style: Theme.of(context).textTheme.bodyMedium,
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

  Widget _matrixAlphaRow() {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              'MATRIX CTE',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primary,
                    letterSpacing: 0.8,
                  ),
            ),
          ),
          const Divider(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _matrixAlphaController,
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: true),
              decoration: InputDecoration(
                labelText: 'α (isotropic)',
                errorText: validate && isThermal && matrixAlpha == null
                    ? 'Required'
                    : null,
              ),
              onChanged: (v) =>
                  setState(() => matrixAlpha = double.tryParse(v)),
            ),
          ),
        ],
      ),
    );
  }

  void _calculate() {
    if (!fiberMaterial.isValid() ||
        !matrixMaterial.isValid() ||
        !fiberVolumeFraction.isValid()) return;
    if (isThermal) {
      if (!fiberThermal.isValid(requireAlpha12: false) || matrixAlpha == null)
        return;
    }

    final Map<String, String> inputs = {
      'Analysis Type': analysisType.toString().split('.').last,
      'E1 (fiber)': fiberMaterial.e1.toString(),
      'E2 (fiber)': fiberMaterial.e2.toString(),
      'G12 (fiber)': fiberMaterial.g12.toString(),
      'ν12 (fiber)': fiberMaterial.nu12.toString(),
      'ν23 (fiber)': fiberMaterial.nu23.toString(),
      'E (matrix)': matrixMaterial.e.toString(),
      'ν (matrix)': matrixMaterial.nu.toString(),
      'Fiber Volume Fraction': fiberVolumeFraction.value.toString(),
    };
    if (isThermal) {
      inputs['α11 (fiber)'] = fiberThermal.alpha11.toString();
      inputs['α22 (fiber)'] = fiberThermal.alpha22.toString();
      inputs['α (matrix)'] = matrixAlpha.toString();
    }
    context.read<ToolHistory>().record(widget.toolId, inputs: inputs);

    final input = UDFRCRulesOfMixtureInput(
      analysisType: analysisType,
      E1_fiber: fiberMaterial.e1!,
      E2_fiber: fiberMaterial.e2!,
      G12_fiber: fiberMaterial.g12!,
      nu12_fiber: fiberMaterial.nu12!,
      nu23_fiber: fiberMaterial.nu23!,
      alpha11_fiber: fiberThermal.alpha11 ?? 0,
      alpha22_fiber: fiberThermal.alpha22 ?? 0,
      E_matrix: matrixMaterial.e!,
      nu_matrix: matrixMaterial.nu!,
      alpha_matrix: matrixAlpha ?? 0,
      fiberVolumeFraction: fiberVolumeFraction.value!,
    );

    final output = UDFRCRulesOfMixtureCalculator.calculate(input);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RulesOfMixtureResultPage(
            toolId: widget.toolId,
            output: output,
            analysisType: analysisType),
      ),
    );
  }
}
