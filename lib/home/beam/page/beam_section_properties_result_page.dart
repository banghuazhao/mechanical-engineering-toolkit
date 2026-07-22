import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/beam_section_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BeamSectionPropertiesResultPage extends StatelessWidget {
  BeamSectionPropertiesResultPage({
    super.key,
    required this.title,
    required this.input,
    required this.result,
  });

  final String title;
  final BeamSectionInput input;
  final BeamSectionResult result;
  final _exportKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final system = context.watch<UnitSystemPreference>().system;
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
              MaterialPageRoute(
                builder: (context) => const ToolSettingPage(),
              ),
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
                      label: 'Area, A',
                      value: _fv(result.area, UnitCategory.area, system)),
                  AppCopyableValue(
                      label: 'Second moment, Ix',
                      value:
                          _fv(result.ix, UnitCategory.momentOfInertia, system)),
                  AppCopyableValue(
                      label: 'Second moment, Iy',
                      value:
                          _fv(result.iy, UnitCategory.momentOfInertia, system)),
                  AppCopyableValue(
                      label: 'Section modulus, Zx',
                      value:
                          _fv(result.zx, UnitCategory.sectionModulus, system)),
                  AppCopyableValue(
                      label: 'Section modulus, Zy',
                      value:
                          _fv(result.zy, UnitCategory.sectionModulus, system)),
                  AppCopyableValue(
                      label: 'Polar area moment, J',
                      value: _fv(result.polarMoment,
                          UnitCategory.momentOfInertia, system)),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              CalculationCard(steps: _calculationSteps(system)),
              SizedBox(height: context.tokens.space3),
              Text(
                'J = Ix + Iy is the polar area moment. It is not the Saint-Venant torsion constant for non-circular sections.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _calculationSteps(UnitSystem system) {
    final b = _fv(input.width, UnitCategory.length, system);
    final h = _fv(input.height, UnitCategory.length, system);
    final area = _fv(result.area, UnitCategory.area, system);
    final ix = _fv(result.ix, UnitCategory.momentOfInertia, system);
    final iy = _fv(result.iy, UnitCategory.momentOfInertia, system);
    final zx = _fv(result.zx, UnitCategory.sectionModulus, system);
    final zy = _fv(result.zy, UnitCategory.sectionModulus, system);
    final j = _fv(result.polarMoment, UnitCategory.momentOfInertia, system);
    final t = _fv(input.wallThickness, UnitCategory.length, system);
    final tf = _fv(input.flangeThickness, UnitCategory.length, system);
    final tw = _fv(input.webThickness, UnitCategory.length, system);
    final bi =
        _fv(input.width - 2 * input.wallThickness, UnitCategory.length, system);
    final hi = _fv(
        input.height - 2 * input.wallThickness, UnitCategory.length, system);
    final hw = _fv(
        input.height - 2 * input.flangeThickness, UnitCategory.length, system);
    final common = [
      'Zx = Ix / (h/2) = $ix / ($h/2) = $zx',
      'Zy = Iy / (b/2) = $iy / ($b/2) = $zy',
      'J = Ix + Iy = $ix + $iy = $j',
    ];
    return switch (input.type) {
      BeamSectionType.rectangle => [
          'Solid rectangle: b = $b, h = $h',
          'A = b·h = $b × $h = $area',
          'Ix = b·h³/12 = $b × $h³ / 12 = $ix',
          'Iy = h·b³/12 = $h × $b³ / 12 = $iy',
          ...common,
        ],
      BeamSectionType.hollowRectangle => [
          'Rectangular hollow section: b = $b, h = $h, t = $t',
          'bi = b − 2t = $bi; hi = h − 2t = $hi',
          'A = b·h − bi·hi = $area',
          'Ix = (b·h³ − bi·hi³)/12 = $ix',
          'Iy = (h·b³ − hi·bi³)/12 = $iy',
          ...common,
        ],
      BeamSectionType.circle => [
          'Solid circle: d = $b',
          'A = πd²/4 = π × $b² / 4 = $area',
          'Ix = Iy = πd⁴/64 = π × $b⁴ / 64 = $ix',
          ...common,
        ],
      BeamSectionType.hollowCircle => [
          'Circular hollow section: D = $b, t = $t',
          'd = D − 2t = $bi',
          'A = π(D² − d²)/4 = $area',
          'Ix = Iy = π(D⁴ − d⁴)/64 = $ix',
          ...common,
        ],
      BeamSectionType.iSection => [
          'Symmetric I-section: b = $b, h = $h, tf = $tf, tw = $tw',
          'hw = h − 2tf = $hw',
          'A = 2b·tf + tw·hw = $area',
          'Ix = 2[b·tf³/12 + b·tf((h−tf)/2)²] + tw·hw³/12 = $ix',
          'Iy = 2(tf·b³/12) + hw·tw³/12 = $iy',
          ...common,
        ],
    };
  }

  void _share(UnitSystem system) => shareResult(title, [
        'A = ${_fv(result.area, UnitCategory.area, system)}',
        'Ix = ${_fv(result.ix, UnitCategory.momentOfInertia, system)}',
        'Iy = ${_fv(result.iy, UnitCategory.momentOfInertia, system)}',
        'Zx = ${_fv(result.zx, UnitCategory.sectionModulus, system)}',
        'Zy = ${_fv(result.zy, UnitCategory.sectionModulus, system)}',
        '',
        ..._calculationSteps(system),
      ]);

  String _f(double value) => value.abs() >= 1e6
      ? value.toStringAsExponential(4)
      : value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_f(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';
}
