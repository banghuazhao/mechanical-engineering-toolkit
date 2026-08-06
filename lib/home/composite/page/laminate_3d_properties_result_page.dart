import 'package:composite_calculator/composite_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/engineering_constants_widget.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_list_matrix.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';

class Laminate3DPropertiesResultPage extends StatelessWidget {
  final int toolId;
  final Laminate3DPropertiesOutput output;
  final AnalysisType analysisType;

  Laminate3DPropertiesResultPage({
    Key? key,
    required this.toolId,
    required this.output,
    required this.analysisType,
  }) : super(key: key);

  static UnitCategory? _categoryForKey(String key) {
    if (key.startsWith('E') || key.startsWith('G')) return UnitCategory.modulus;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(toolId, context);
    final ec = output.engineeringConstants;
    final items = <Widget>[
      ToolResultHeader(tool: tool),
      ResultListMatrix(
          title: 'Effective 3D Stiffness Matrix', matrix: output.stiffness),
      ResultListMatrix(
          title: 'Effective 3D Compliance Matrix', matrix: output.compliance),
      EngineeringConstantsWidget(
          title: S.of(context).Engineering_Constants,
          constants: ec,
          categoryForKey: _categoryForKey),
    ];

    return ResultScaffold(
      toolName: 'Laminate 3D Properties',
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
