import 'package:composite_calculator/composite_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/engineering_constants_widget.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_list_matrix.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

import '../../tool_setting_page.dart';

class Laminate3DPropertiesResultPage extends StatelessWidget {
  final Laminate3DPropertiesOutput output;
  final AnalysisType analysisType;
  final _exportKey = GlobalKey();

  Laminate3DPropertiesResultPage({
    Key? key,
    required this.output,
    required this.analysisType,
  }) : super(key: key);

  static UnitCategory? _categoryForKey(String key) {
    if (key.startsWith('E') || key.startsWith('G')) return UnitCategory.modulus;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ec = output.engineeringConstants;
    final items = <Widget>[
      ResultListMatrix(
          title: 'Effective 3D Stiffness Matrix', matrix: output.stiffness),
      ResultListMatrix(
          title: 'Effective 3D Compliance Matrix', matrix: output.compliance),
      EngineeringConstantsWidget(
          title: 'Engineering Constants',
          constants: ec,
          categoryForKey: _categoryForKey),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.image_outlined),
            onPressed: () =>
                shareResultImage(_exportKey, 'Laminate 3D Properties'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ToolSettingPage())),
          ),
        ],
        title: Text(S.of(context).Result),
      ),
      bottomNavigationBar: const AppBannerAd(),
      body: RepaintBoundary(
        key: _exportKey,
        child: SafeArea(
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
      ),
    );
  }
}
