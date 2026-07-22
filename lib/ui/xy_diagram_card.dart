import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_components.dart';
import 'app_theme.dart';

class DiagramPoint {
  const DiagramPoint(this.x, this.y);
  final double x;
  final double y;
}

/// A static x-vs-y line-diagram card (position on x, magnitude on y) built
/// on [AppSectionCard]. Used for beam shear/moment/deflection diagrams and
/// any future position-vs-quantity diagram.
///
/// For an interactive "vary one input, see the effect" chart, see
/// [ParameterSweepCard] instead — this widget has no touch/zoom.
class XYDiagramCard extends StatelessWidget {
  const XYDiagramCard({
    super.key,
    required this.title,
    required this.xUnitLabel,
    required this.yUnitLabel,
    required this.points,
  });

  final String title;
  final String xUnitLabel;
  final String yUnitLabel;
  final List<DiagramPoint> points;

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 180,
            child: CustomPaint(
              painter: _XYDiagramPainter(
                points: points,
                color: Theme.of(context).colorScheme.primary,
                axisColor: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          SizedBox(height: context.tokens.space2),
          Text(
            'Horizontal: position ($xUnitLabel) • Vertical: $yUnitLabel',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _XYDiagramPainter extends CustomPainter {
  const _XYDiagramPainter({
    required this.points,
    required this.color,
    required this.axisColor,
  });

  final List<DiagramPoint> points;
  final Color color;
  final Color axisColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    const padding = 12.0;
    final chart = Rect.fromLTWH(
        padding, padding, size.width - 2 * padding, size.height - 2 * padding);
    final maxX = points.last.x;
    final minY = points.map((p) => p.y).reduce(math.min);
    final maxY = points.map((p) => p.y).reduce(math.max);
    final rangeY = math.max(maxY - minY, math.max(maxY.abs(), 1) * 0.02);
    double dx(double x) => chart.left + (maxX == 0 ? 0 : x / maxX * chart.width);
    double dy(double y) => chart.bottom - (y - minY) / rangeY * chart.height;
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;
    final zeroY = dy(0).clamp(chart.top, chart.bottom).toDouble();
    canvas.drawLine(
        Offset(chart.left, zeroY), Offset(chart.right, zeroY), axisPaint);
    canvas.drawLine(chart.bottomLeft, chart.topLeft, axisPaint);
    final path = Path()..moveTo(dx(points.first.x), dy(points.first.y));
    for (final point in points.skip(1)) {
      path.lineTo(dx(point.x), dy(point.y));
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
  bool shouldRepaint(covariant _XYDiagramPainter oldDelegate) =>
      oldDelegate.points != points ||
      oldDelegate.color != color ||
      oldDelegate.axisColor != axisColor;
}
