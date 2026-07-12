import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/simply_supported_beam_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';

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
                    label: 'Left reaction, RA',
                    value: '${_f(result.leftReaction)} kN'),
                AppCopyableValue(
                    label: 'Right reaction, RB',
                    value: '${_f(result.rightReaction)} kN'),
                AppCopyableValue(
                  label: 'Maximum bending moment',
                  value:
                      '${_f(result.maximumMoment)} kN·m at x = ${_f(result.maximumMomentPosition)} m',
                ),
                AppCopyableValue(
                  label: 'Maximum downward deflection',
                  value:
                      '${_f(result.maximumDeflection)} mm at x = ${_f(result.maximumDeflectionPosition)} m',
                ),
              ]),
            ),
            SizedBox(height: context.tokens.space4),
            CalculationCard(steps: _reactionSteps()),
            SizedBox(height: context.tokens.space3),
            CalculationCard(steps: _responseSteps()),
            SizedBox(height: context.tokens.space4),
            _diagramCard(context, 'Shear-force diagram', 'kN', result.shear),
            SizedBox(height: context.tokens.space3),
            _diagramCard(
                context, 'Bending-moment diagram', 'kN·m', result.moment),
            SizedBox(height: context.tokens.space3),
            _diagramCard(context, 'Elastic deflection', 'mm downward',
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

  List<String> _reactionSteps() => [
        'Support reactions from static equilibrium',
        'RA = P(L−a)/L + wL/2',
        '= ${_f(input.pointLoad)}(${_f(input.span)}−${_f(input.pointPosition)})/${_f(input.span)} + ${_f(input.distributedLoad)}×${_f(input.span)}/2',
        '= ${_f(result.leftReaction)} kN',
        'RB = Pa/L + wL/2',
        '= ${_f(input.pointLoad)}×${_f(input.pointPosition)}/${_f(input.span)} + ${_f(input.distributedLoad)}×${_f(input.span)}/2',
        '= ${_f(result.rightReaction)} kN',
        'Check: RA + RB = ${_f(result.leftReaction + result.rightReaction)} kN = P + wL',
      ];

  List<String> _responseSteps() => [
        'Internal actions and elastic deflection',
        'V(x) = RA − wx − P·H(x−a)',
        'M(x) = RA·x − wx²/2 − P(x−a)·H(x−a)',
        'Mmax = ${_f(result.maximumMoment)} kN·m at x = ${_f(result.maximumMomentPosition)} m',
        'EI = (${_f(input.elasticModulus)} GPa)(${_f(input.secondMoment)} mm⁴)',
        'UDL: v(x) = wx(L³−2Lx²+x³)/(24EI)',
        'Point load, x≤a: v(x) = Pb·x(L²−b²−x²)/(6LEI)',
        'Point load, x≥a: v(x) = Pa(L−x)[L²−a²−(L−x)²]/(6LEI)',
        'vmax = ${_f(result.maximumDeflection)} mm downward at x = ${_f(result.maximumDeflectionPosition)} m',
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
              'Horizontal: position (m) • Vertical: $unit',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );

  void _share() => shareResult(title, [
        'RA = ${_f(result.leftReaction)} kN',
        'RB = ${_f(result.rightReaction)} kN',
        'Mmax = ${_f(result.maximumMoment)} kN·m at ${_f(result.maximumMomentPosition)} m',
        'Deflection max = ${_f(result.maximumDeflection)} mm at ${_f(result.maximumDeflectionPosition)} m',
        '',
        ..._reactionSteps(),
        '',
        ..._responseSteps(),
      ]);

  String _f(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');
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
