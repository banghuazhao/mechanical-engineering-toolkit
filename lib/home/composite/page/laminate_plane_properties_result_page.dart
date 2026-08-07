import 'package:composite_calculator/composite_calculator.dart';
import 'package:composite_calculator/models/in-plane-properties.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/home/composite/composite_results.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/engineering_constants_widget.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_list_matrix.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

class LaminatePlanePropertiesResultPage extends StatelessWidget {
  final int toolId;
  final LaminatePlatePropertiesOutput output;
  final AnalysisType analysisType;

  LaminatePlanePropertiesResultPage({
    Key? key,
    required this.toolId,
    required this.output,
    required this.analysisType,
  }) : super(key: key);

  Map<String, double> _propsMap(InPlaneProperties p) {
    final m = <String, double>{
      'E₁': p.E1,
      'E₂': p.E2,
      'G₁₂': p.G12,
      'ν₁₂': p.nu12,
      'η₁₂,₁': p.eta121,
      'η₁₂,₂': p.eta122,
    };
    if (analysisType == AnalysisType.thermalElastic) {
      m['α₁₁'] = p.alpha11;
      m['α₂₂'] = p.alpha22;
      m['α₁₂'] = p.alpha12;
    }
    return m;
  }

  UnitCategory? _categoryForKey(String key) {
    if (key.startsWith('E') || key.startsWith('G')) return UnitCategory.modulus;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(toolId, context);
    final items = <Widget>[
      ToolResultHeader(tool: tool),
      ResultListMatrix(title: 'A Matrix (In-plane)', matrix: output.A),
      ResultListMatrix(title: 'B Matrix (Coupling)', matrix: output.B),
      ResultListMatrix(title: 'D Matrix (Flexural)', matrix: output.D),
      EngineeringConstantsWidget(
          title: 'In-Plane Properties',
          constants: _propsMap(output.inPlaneProperties),
          categoryForKey: _categoryForKey),
      EngineeringConstantsWidget(
          title: 'Flexural Properties',
          constants: _propsMap(output.flexuralProperties),
          categoryForKey: _categoryForKey),
    ];

    return ResultScaffold(
      toolName: 'Laminate Plane Properties',
      results: [
        matrixSection('A Matrix (In-plane)', output.A),
        matrixSection('B Matrix (Coupling)', output.B),
        matrixSection('D Matrix (Flexural)', output.D),
        constantsSection(
          'In-Plane Properties',
          _propsMap(output.inPlaneProperties),
          categoryForKey: _categoryForKey,
        ),
        constantsSection(
          'Flexural Properties',
          _propsMap(output.flexuralProperties),
          categoryForKey: _categoryForKey,
        ),
      ],
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
}
