import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:linalg/matrix.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_6by6_matrix.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';

class LinearElasticConstitutiveResultPage extends StatefulWidget {
  final int toolId;
  final Matrix C;
  final Matrix S;

  const LinearElasticConstitutiveResultPage(
      {Key? key, required this.toolId, required this.C, required this.S})
      : super(key: key);

  @override
  _LinearElasticConstitutiveResultPageState createState() =>
      _LinearElasticConstitutiveResultPageState();
}

class _LinearElasticConstitutiveResultPageState
    extends State<LinearElasticConstitutiveResultPage> {
  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(widget.toolId, context);
    return ResultScaffold(
      toolName: 'Constitutive Relation',
      body: SafeArea(
        child: StaggeredGridView.countBuilder(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            crossAxisCount: 8,
            itemCount: 3,
            staggeredTileBuilder: (int index) => StaggeredTile.fit(index == 0
                ? 8
                : (MediaQuery.of(context).size.width > 600 ? 4 : 8)),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            itemBuilder: (BuildContext context, int index) {
              return [
                ToolResultHeader(tool: tool),
                Result6By6Matrix(
                  matrix: widget.C,
                  title: S.of(context).Stiffness_Matrix_C,
                ),
                Result6By6Matrix(
                  matrix: widget.S,
                  title: S.of(context).Compliance_Matrix_S,
                ),
              ][index];
            }),
      ),
    );
  }
}
