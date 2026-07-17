import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/simply_supported_beam_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class BeamCalculatorResultPage extends StatelessWidget {
  const BeamCalculatorResultPage({
    super.key,
    required this.title,
    required this.input,
    required this.result,
  });

  final String title;
  final BeamAnalysisInput input;
  final BeamAnalysisResult result;

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
                    label: 'Left reaction, RA',
                    value: _fv(result.leftReaction, UnitCategory.forceStructural, system)),
                AppCopyableValue(
                    label: 'Right reaction, RB',
                    value: _fv(result.rightReaction, UnitCategory.forceStructural, system)),
                AppCopyableValue(
                  label: 'Maximum bending moment',
                  value:
                      '${_fv(result.maximumMoment, UnitCategory.momentStructural, system)} at x = ${_fv(result.maximumMomentPosition, UnitCategory.span, system)}',
                ),
                AppCopyableValue(
                  label: 'Maximum downward deflection',
                  value:
                      '${_fv(result.maximumDeflection, UnitCategory.length, system)} at x = ${_fv(result.maximumDeflectionPosition, UnitCategory.span, system)}',
                ),
              ]),
            ),
            SizedBox(height: context.tokens.space4),
            CalculationCard(steps: _reactionSteps(system)),
            SizedBox(height: context.tokens.space3),
            CalculationCard(steps: _responseSteps(system)),
            SizedBox(height: context.tokens.space4),
            _diagramCard(context, 'Shear-force diagram',
                unitLabel(UnitCategory.forceStructural, system), result.shear),
            SizedBox(height: context.tokens.space3),
            _diagramCard(context, 'Bending-moment diagram',
                unitLabel(UnitCategory.momentStructural, system), result.moment),
            SizedBox(height: context.tokens.space3),
            _diagramCard(
                context,
                'Elastic deflection',
                '${unitLabel(UnitCategory.length, system)} downward',
                result.deflection),
            SizedBox(height: context.tokens.space3),
            Text(
              'Linear-elastic Euler–Bernoulli analysis. Self-weight and shear deformation are excluded unless entered as part of the UDL. Diagram extrema are evaluated at 200 intervals.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _reactionSteps(UnitSystem system) => [
        'Support reactions from static equilibrium',
        'RA = P(L−a)/L + wL/2',
        '= ${_fv(input.pointLoad, UnitCategory.forceStructural, system)}(${_fv(input.span, UnitCategory.span, system)}−${_fv(input.pointPosition, UnitCategory.span, system)})/${_fv(input.span, UnitCategory.span, system)} + ${_fv(input.distributedLoad, UnitCategory.distributedLoadStructural, system)}×${_fv(input.span, UnitCategory.span, system)}/2',
        '= ${_fv(result.leftReaction, UnitCategory.forceStructural, system)}',
        'RB = Pa/L + wL/2',
        '= ${_fv(input.pointLoad, UnitCategory.forceStructural, system)}×${_fv(input.pointPosition, UnitCategory.span, system)}/${_fv(input.span, UnitCategory.span, system)} + ${_fv(input.distributedLoad, UnitCategory.distributedLoadStructural, system)}×${_fv(input.span, UnitCategory.span, system)}/2',
        '= ${_fv(result.rightReaction, UnitCategory.forceStructural, system)}',
        'Check: RA + RB = ${_fv(result.leftReaction + result.rightReaction, UnitCategory.forceStructural, system)} = P + wL',
      ];

  List<String> _responseSteps(UnitSystem system) => [
        'Internal actions and elastic deflection',
        'V(x) = RA − wx − P·H(x−a)',
        'M(x) = RA·x − wx²/2 − P(x−a)·H(x−a)',
        'Mmax = ${_fv(result.maximumMoment, UnitCategory.momentStructural, system)} at x = ${_fv(result.maximumMomentPosition, UnitCategory.span, system)}',
        'EI = (${_fv(input.elasticModulus, UnitCategory.modulus, system)})(${_fv(input.secondMoment, UnitCategory.momentOfInertia, system)})',
        'UDL: v(x) = wx(L³−2Lx²+x³)/(24EI)',
        'Point load, x≤a: v(x) = Pb·x(L²−b²−x²)/(6LEI)',
        'Point load, x≥a: v(x) = Pa(L−x)[L²−a²−(L−x)²]/(6LEI)',
        'vmax = ${_fv(result.maximumDeflection, UnitCategory.length, system)} downward at x = ${_fv(result.maximumDeflectionPosition, UnitCategory.span, system)}',
      ];

  Widget _diagramCard(
    BuildContext context,
    String title,
    String unit,
    List<BeamDiagramPoint> points,
  ) =>
      AppSectionCard(
        title: title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 180,
              child: CustomPaint(
                painter: _BeamDiagramPainter(
                  points: points,
                  color: Theme.of(context).colorScheme.primary,
                  axisColor: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
            SizedBox(height: context.tokens.space2),
            Text(
              'Horizontal: position (${unitLabel(UnitCategory.span, context.watch<UnitSystemPreference>().system)}) • Vertical: $unit',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );

  void _share(UnitSystem system) => shareResult(title, [
        'RA = ${_fv(result.leftReaction, UnitCategory.forceStructural, system)}',
        'RB = ${_fv(result.rightReaction, UnitCategory.forceStructural, system)}',
        'Mmax = ${_fv(result.maximumMoment, UnitCategory.momentStructural, system)} at ${_fv(result.maximumMomentPosition, UnitCategory.span, system)}',
        'Deflection max = ${_fv(result.maximumDeflection, UnitCategory.length, system)} at ${_fv(result.maximumDeflectionPosition, UnitCategory.span, system)}',
        '',
        ..._reactionSteps(system),
        '',
        ..._responseSteps(system),
      ]);

  String _f(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_f(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';
}

class _BeamDiagramPainter extends CustomPainter {
  const _BeamDiagramPainter(
      {required this.points, required this.color, required this.axisColor});
  final List<BeamDiagramPoint> points;
  final Color color;
  final Color axisColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    const padding = 12.0;
    final chart = Rect.fromLTWH(
        padding, padding, size.width - 2 * padding, size.height - 2 * padding);
    final maxX = points.last.x;
    final minY = points.map((point) => point.value).reduce(min);
    final maxY = points.map((point) => point.value).reduce(max);
    final rangeY = max(maxY - minY, max(maxY.abs(), 1) * 0.02);
    double dx(double x) => chart.left + x / maxX * chart.width;
    double dy(double y) => chart.bottom - (y - minY) / rangeY * chart.height;
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    final zeroY = dy(0).clamp(chart.top, chart.bottom).toDouble();
    canvas.drawLine(
        Offset(chart.left, zeroY), Offset(chart.right, zeroY), axisPaint);
    canvas.drawLine(chart.bottomLeft, chart.topLeft, axisPaint);
    final path = Path()..moveTo(dx(points.first.x), dy(points.first.value));
    for (final point in points.skip(1)) {
      path.lineTo(dx(point.x), dy(point.value));
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(covariant _BeamDiagramPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.axisColor != axisColor;
}
