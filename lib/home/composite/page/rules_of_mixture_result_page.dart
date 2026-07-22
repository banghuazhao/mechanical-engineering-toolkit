import 'package:composite_calculator/composite_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/engineering_constants_widget.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/home/composite/widget/result_list_matrix.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

import '../../tool_setting_page.dart';

class RulesOfMixtureResultPage extends StatelessWidget {
  final int toolId;
  final UDFRCRulesOfMixtureOutput output;
  final AnalysisType analysisType;
  final _exportKey = GlobalKey();

  RulesOfMixtureResultPage({
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
    final models = [
      ('Voigt Rules of Mixture', output.voigtRulesOfMixture),
      ('Reuss Rules of Mixture', output.reussRulesOfMixture),
      ('Hybrid Rules of Mixture', output.hybirdRulesOfMixture),
    ];

    final items = <Widget>[
      ToolResultHeader(tool: tool),
    ];
    for (final (label, m) in models) {
      items.add(_sectionHeader(context, label));
      if (m.stiffness.isNotEmpty)
        items.add(ResultListMatrix(
            title: 'Effective Stiffness Matrix', matrix: m.stiffness));
      if (m.compliance.isNotEmpty)
        items.add(ResultListMatrix(
            title: 'Effective Compliance Matrix', matrix: m.compliance));
      if (m.engineeringConstants.isNotEmpty)
        items.add(EngineeringConstantsWidget(
            title: 'Engineering Constants',
            constants: m.engineeringConstants,
            categoryForKey: _categoryForKey));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.image_outlined),
            onPressed: () => shareResultImage(_exportKey, 'Rule of Mixtures'),
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

  Widget _sectionHeader(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
      child: Text(label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              )),
    );
  }
}
