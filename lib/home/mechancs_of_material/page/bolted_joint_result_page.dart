import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BoltedJointResultPage extends StatelessWidget {
  BoltedJointResultPage({
    super.key,
    required this.title,
    required this.tauShear,
    required this.sigmaBearing,
    required this.sigmaTearOut,
    this.allowShear,
    this.allowBearing,
  });

  final String title;
  final double tauShear;
  final double sigmaBearing;
  final double sigmaTearOut;
  final double? allowShear;
  final double? allowBearing;
  final _exportKey = GlobalKey();

  String _f(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitSystem system) =>
      '${_f(fromSI(valueSI, UnitCategory.stress, system))} ${unitLabel(UnitCategory.stress, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final governingStress =
        [tauShear, sigmaBearing, sigmaTearOut].reduce((a, b) => a > b ? a : b);
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
                    label: 'Shear stress, τ',
                    valueSI: tauShear,
                    category: UnitCategory.stress,
                  ),
                  AppCopyableValue(
                    label: 'Bearing stress, σb',
                    valueSI: sigmaBearing,
                    category: UnitCategory.stress,
                  ),
                  AppCopyableValue(
                    label: 'Tear-out stress, σt',
                    valueSI: sigmaTearOut,
                    category: UnitCategory.stress,
                  ),
                ]),
              ),
              if (allowShear != null || allowBearing != null) ...[
                SizedBox(height: context.tokens.space4),
                AppSectionCard(
                  title: 'Factor of Safety',
                  child: Column(children: [
                    if (allowShear != null)
                      AppCopyableValue(
                        label: 'Shear FoS',
                        value: _f(allowShear! / tauShear),
                      ),
                    if (allowBearing != null)
                      AppCopyableValue(
                        label: 'Bearing FoS',
                        value: _f(allowBearing! / sigmaBearing),
                      ),
                  ]),
                ),
              ],
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formulas',
                child: Text(
                  'τ = P / (n·planes·π/4·d²)\n'
                  'σb = P / (n·d·t)\n'
                  'σt = P / (n·2·(e−d/2)·t)\n\n'
                  'Governing stress: ${_fv(governingStress, system)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(UnitSystem system) => shareResult(title, [
        'τ = ${_fv(tauShear, system)}',
        'σb = ${_fv(sigmaBearing, system)}',
        'σt = ${_fv(sigmaTearOut, system)}',
      ]);
}
