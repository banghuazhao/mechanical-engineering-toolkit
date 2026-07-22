import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BarForceDisplacementResultPage extends StatelessWidget {
  BarForceDisplacementResultPage({
    super.key,
    required this.toolId,
    required this.delta,
    required this.f,
    required this.l,
    required this.e,
    required this.a,
  });

  final int toolId;
  final double delta;
  final double f;
  final double l;
  final double e;
  final double a;
  final _exportKey = GlobalKey();

  String _fmt(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_fmt(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
    final tool = ToolLibrary.shared.item(toolId, context);
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
            onPressed: () =>
                shareResultImage(_exportKey, 'Bar Force & Displacement'),
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
              ToolResultHeader(tool: tool),
              AppSectionCard(
                title: 'Bar Force & Displacement',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Displacement, δ',
                    valueSI: delta,
                    category: UnitCategory.length,
                  ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'δ = F·L / (E·A)\n'
                  '= ${_fv(f, UnitCategory.force, system)} × ${_fv(l, UnitCategory.length, system)} / (${_fv(e, UnitCategory.modulus, system)} × ${_fv(a, UnitCategory.area, system)})\n'
                  '= ${_fv(delta, UnitCategory.length, system)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: context.tokens.space4),
              ParameterSweepCard(
                variableLabel: 'Length, L',
                variableCategory: UnitCategory.length,
                baseValueSI: l,
                outputLabel: 'δ',
                outputCategory: UnitCategory.length,
                compute: (variedL) => f * variedL / (e * 1000 * a),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(UnitSystem system) => shareResult('Bar Force & Displacement', [
        'δ = ${_fv(delta, UnitCategory.length, system)}',
        '',
        'Calculation:',
        'δ = F·L / (E·A)',
        '= ${_fv(f, UnitCategory.force, system)} × ${_fv(l, UnitCategory.length, system)} / (${_fv(e, UnitCategory.modulus, system)} × ${_fv(a, UnitCategory.area, system)})',
        '= ${_fv(delta, UnitCategory.length, system)}',
      ]);
}
