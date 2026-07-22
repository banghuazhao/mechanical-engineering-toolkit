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

class BarTorsionFormulaResultPage extends StatelessWidget {
  BarTorsionFormulaResultPage({
    super.key,
    required this.toolId,
    required this.tauMax,
    required this.t,
    required this.r,
    required this.ip,
  });

  final int toolId;
  final double tauMax;
  final double t;
  final double r;
  final double ip;
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
            onPressed: () => shareResultImage(_exportKey, 'Torsion Formula'),
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
                title: 'Torsion Formula of Bar',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Maximum shear stress, τ_max',
                    valueSI: tauMax,
                    category: UnitCategory.stress,
                  ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'τ = T·r / Ip\n'
                  '= ${_fv(t, UnitCategory.momentSection, system)} × ${_fv(r, UnitCategory.length, system)} / ${_fv(ip, UnitCategory.momentOfInertia, system)}\n'
                  '= ${_fv(tauMax, UnitCategory.stress, system)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: context.tokens.space4),
              ParameterSweepCard(
                variableLabel: 'Radius, r',
                variableCategory: UnitCategory.length,
                baseValueSI: r,
                outputLabel: 'τ_max',
                outputCategory: UnitCategory.stress,
                compute: (variedR) => t * variedR / ip,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(UnitSystem system) => shareResult('Torsion Formula', [
        'τ_max = ${_fv(tauMax, UnitCategory.stress, system)}',
        '',
        'Calculation:',
        'τ = T·r / Ip',
        '= ${_fv(t, UnitCategory.momentSection, system)} × ${_fv(r, UnitCategory.length, system)} / ${_fv(ip, UnitCategory.momentOfInertia, system)}',
        '= ${_fv(tauMax, UnitCategory.stress, system)}',
      ]);
}
