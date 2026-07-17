import 'package:composite_calculator/composite_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/engineering_constants_widget.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_list_matrix.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

import '../../tool_setting_page.dart';

class LaminaStressStrainResultPage extends StatelessWidget {
  final LaminaStressStrainOutput output;
  final AnalysisType analysisType;

  const LaminaStressStrainResultPage({
    Key? key,
    required this.output,
    required this.analysisType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isStress = output.tensorType == TensorType.stress;

    final resultConstants = isStress
        ? <String, double>{
            'σ11': output.sigma11,
            'σ22': output.sigma22,
            'σ12': output.sigma12,
          }
        : <String, double>{
            'ε11': output.epsilon11,
            'ε22': output.epsilon22,
            'γ12': output.gamma12,
          };

    final items = [
      EngineeringConstantsWidget(
        title: isStress ? 'Stress Result' : 'Strain Result',
        constants: resultConstants,
        categoryForKey: isStress ? (_) => UnitCategory.stress : null,
      ),
      ResultListMatrix(title: 'Stiffness Matrix Q̄', matrix: output.Q),
      ResultListMatrix(title: 'Compliance Matrix S̄', matrix: output.S),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ToolSettingPage())),
          ),
        ],
        title: Text(S.of(context).Result),
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
}
