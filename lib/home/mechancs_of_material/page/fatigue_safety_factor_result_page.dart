import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class FatigueSafetyFactorResultPage extends StatelessWidget {
  FatigueSafetyFactorResultPage({
    super.key,
    required this.title,
    required this.sigmaA,
    required this.sigmaM,
    required this.su,
    required this.se,
    required this.safetyFactor,
  });

  final String title;
  final double sigmaA;
  final double sigmaM;
  final double su;
  final double se;
  final double safetyFactor;
  final _exportKey = GlobalKey();

  String _f(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_f(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            tooltip: 'Share results',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _share(system),
          ),
          IconButton(
            tooltip: 'Share as image',
            icon: const Icon(Icons.image_outlined),
            onPressed: () => shareResultImage(_exportKey, title),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ToolSettingPage()),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBannerAd(),
      body: RepaintBoundary(
        key: _exportKey,
        child: AppContent(
          padding: EdgeInsets.zero,
          child: ListView(
            padding: EdgeInsets.all(context.tokens.space4),
            children: [
              AppSectionCard(
                title: title,
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Factor of safety, n',
                    value: _f(safetyFactor),
                  ),
                  AppCopyableValue(
                    label: 'Assessment',
                    value: safetyFactor >= 1
                        ? 'Safe against fatigue failure (n ≥ 1)'
                        : 'Unsafe — predicted fatigue failure (n < 1)',
                  ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              if (safetyFactor < 1)
                Card(
                  color: scheme.errorContainer,
                  child: Padding(
                    padding: EdgeInsets.all(context.tokens.space3),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: scheme.onErrorContainer),
                        SizedBox(width: context.tokens.space2),
                        Expanded(
                          child: Text(
                            'This stress state falls outside the Goodman line — the part is predicted to fail by fatigue.',
                            style: TextStyle(color: scheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (safetyFactor < 1) SizedBox(height: context.tokens.space4),
              CalculationCard(steps: [
                '1/n = σa/Se + σm/Su',
                '= ${_fv(sigmaA, UnitCategory.stress, system)} / ${_fv(se, UnitCategory.stress, system)} + ${_fv(sigmaM, UnitCategory.stress, system)} / ${_fv(su, UnitCategory.stress, system)}',
                'n = ${_f(safetyFactor)}',
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _share(UnitSystem system) => shareResult(title, [
        'n = ${_f(safetyFactor)}',
        'σa = ${_fv(sigmaA, UnitCategory.stress, system)}',
        'σm = ${_fv(sigmaM, UnitCategory.stress, system)}',
        'Su = ${_fv(su, UnitCategory.stress, system)}',
        'Se = ${_fv(se, UnitCategory.stress, system)}',
      ]);
}
