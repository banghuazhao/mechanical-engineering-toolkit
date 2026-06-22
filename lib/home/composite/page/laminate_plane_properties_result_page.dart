import 'package:composite_calculator/composite_calculator.dart';
import 'package:composite_calculator/models/in-plane-properties.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/engineering_constants_widget.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_list_matrix.dart';

import '../../tool_setting_page.dart';

class LaminatePlanePropertiesResultPage extends StatelessWidget {
  final LaminatePlatePropertiesOutput output;
  final AnalysisType analysisType;

  const LaminatePlanePropertiesResultPage({
    Key? key,
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

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      ResultListMatrix(title: 'A Matrix (In-plane)', matrix: output.A),
      ResultListMatrix(title: 'B Matrix (Coupling)', matrix: output.B),
      ResultListMatrix(title: 'D Matrix (Flexural)', matrix: output.D),
      EngineeringConstantsWidget(
          title: 'In-Plane Properties',
          constants: _propsMap(output.inPlaneProperties)),
      EngineeringConstantsWidget(
          title: 'Flexural Properties',
          constants: _propsMap(output.flexuralProperties)),
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
