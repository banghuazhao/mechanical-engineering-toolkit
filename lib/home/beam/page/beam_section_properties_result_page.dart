import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/beam_section_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';

class BeamSectionPropertiesResultPage extends StatelessWidget {
  const BeamSectionPropertiesResultPage({
    super.key,
    required this.title,
    required this.input,
    required this.result,
  });

  final String title;
  final BeamSectionInput input;
  final BeamSectionResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            tooltip: 'Share results',
            icon: const Icon(Icons.share_rounded),
            onPressed: _share,
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
      body: AppContent(
        padding: EdgeInsets.zero,
        child: ListView(
          padding: EdgeInsets.all(context.tokens.space4),
          children: [
            AppSectionCard(
              title: title,
              child: Column(children: [
                AppCopyableValue(
                    label: 'Area, A', value: '${_f(result.area)} mm²'),
                AppCopyableValue(
                    label: 'Second moment, Ix', value: '${_f(result.ix)} mm⁴'),
                AppCopyableValue(
                    label: 'Second moment, Iy', value: '${_f(result.iy)} mm⁴'),
                AppCopyableValue(
                    label: 'Section modulus, Zx',
                    value: '${_f(result.zx)} mm³'),
                AppCopyableValue(
                    label: 'Section modulus, Zy',
                    value: '${_f(result.zy)} mm³'),
                AppCopyableValue(
                    label: 'Polar area moment, J',
                    value: '${_f(result.polarMoment)} mm⁴'),
              ]),
            ),
            SizedBox(height: context.tokens.space4),
            CalculationCard(steps: _calculationSteps()),
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
    );
  }

  List<String> _calculationSteps() {
    final b = input.width;
    final h = input.height;
    final common = [
      'Zx = Ix / (h/2) = ${_f(result.ix)} / (${_f(h)}/2) = ${_f(result.zx)} mm³',
      'Zy = Iy / (b/2) = ${_f(result.iy)} / (${_f(b)}/2) = ${_f(result.zy)} mm³',
      'J = Ix + Iy = ${_f(result.ix)} + ${_f(result.iy)} = ${_f(result.polarMoment)} mm⁴',
    ];
    return switch (input.type) {
      BeamSectionType.rectangle => [
          'Solid rectangle: b = ${_f(b)} mm, h = ${_f(h)} mm',
          'A = b·h = ${_f(b)} × ${_f(h)} = ${_f(result.area)} mm²',
          'Ix = b·h³/12 = ${_f(b)} × ${_f(h)}³ / 12 = ${_f(result.ix)} mm⁴',
          'Iy = h·b³/12 = ${_f(h)} × ${_f(b)}³ / 12 = ${_f(result.iy)} mm⁴',
          ...common,
        ],
      BeamSectionType.hollowRectangle => [
          'Rectangular hollow section: b = ${_f(b)}, h = ${_f(h)}, t = ${_f(input.wallThickness)} mm',
          'bi = b − 2t = ${_f(b - 2 * input.wallThickness)} mm; hi = h − 2t = ${_f(h - 2 * input.wallThickness)} mm',
          'A = b·h − bi·hi = ${_f(result.area)} mm²',
          'Ix = (b·h³ − bi·hi³)/12 = ${_f(result.ix)} mm⁴',
          'Iy = (h·b³ − hi·bi³)/12 = ${_f(result.iy)} mm⁴',
          ...common,
        ],
      BeamSectionType.circle => [
          'Solid circle: d = ${_f(b)} mm',
          'A = πd²/4 = π × ${_f(b)}² / 4 = ${_f(result.area)} mm²',
          'Ix = Iy = πd⁴/64 = π × ${_f(b)}⁴ / 64 = ${_f(result.ix)} mm⁴',
          ...common,
        ],
      BeamSectionType.hollowCircle => [
          'Circular hollow section: D = ${_f(b)} mm, t = ${_f(input.wallThickness)} mm',
          'd = D − 2t = ${_f(b - 2 * input.wallThickness)} mm',
          'A = π(D² − d²)/4 = ${_f(result.area)} mm²',
          'Ix = Iy = π(D⁴ − d⁴)/64 = ${_f(result.ix)} mm⁴',
          ...common,
        ],
      BeamSectionType.iSection => [
          'Symmetric I-section: b = ${_f(b)}, h = ${_f(h)}, tf = ${_f(input.flangeThickness)}, tw = ${_f(input.webThickness)} mm',
          'hw = h − 2tf = ${_f(h - 2 * input.flangeThickness)} mm',
          'A = 2b·tf + tw·hw = ${_f(result.area)} mm²',
          'Ix = 2[b·tf³/12 + b·tf((h−tf)/2)²] + tw·hw³/12 = ${_f(result.ix)} mm⁴',
          'Iy = 2(tf·b³/12) + hw·tw³/12 = ${_f(result.iy)} mm⁴',
          ...common,
        ],
    };
  }

  void _share() => shareResult(title, [
        'A = ${_f(result.area)} mm²',
        'Ix = ${_f(result.ix)} mm⁴',
        'Iy = ${_f(result.iy)} mm⁴',
        'Zx = ${_f(result.zx)} mm³',
        'Zy = ${_f(result.zy)} mm³',
        '',
        ..._calculationSteps(),
      ]);

  String _f(double value) => value.abs() >= 1e6
      ? value.toStringAsExponential(4)
      : value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
}
