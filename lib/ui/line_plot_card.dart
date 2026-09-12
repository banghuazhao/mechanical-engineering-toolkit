import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'app_components.dart';
import 'app_theme.dart';

/// Which colour role a plotted line takes, resolved against the theme at paint
/// time so every chart reads correctly in light and dark mode.
enum PlotTone {
  /// The thing the chart is about: the cycle, the operating line.
  primary,

  /// A second curve worth telling apart from the first.
  secondary,

  /// Reference geometry: the saturation dome, a failure envelope.
  muted,

  /// A limit being crossed.
  danger,
}

/// One polyline on a [LinePlotCard], in the units its axes are labelled in.
class PlotSeries {
  const PlotSeries({
    required this.points,
    this.tone = PlotTone.primary,
    this.dashed = false,
    this.width = 2,
    this.label,
  });

  final List<Offset> points;
  final PlotTone tone;
  final bool dashed;
  final double width;

  /// Shown in the legend under the chart. Series without one stay out of it.
  final String? label;
}

/// A labelled point — a state in a cycle, an operating point on a diagram.
class PlotMarker {
  const PlotMarker(this.point, this.label, {this.tone = PlotTone.primary});

  final Offset point;
  final String label;
  final PlotTone tone;
}

/// A static engineering chart: several lines, labelled points, and axes with
/// real tick values.
///
/// For a single position-versus-quantity curve [XYDiagramCard] is lighter;
/// for "vary one input and watch the output" use [ParameterSweepCard]. This
/// is for the diagrams a textbook draws with more than one line on them — a
/// Goodman diagram, a T–s diagram with its saturation dome, a P–v cycle.
class LinePlotCard extends StatelessWidget {
  const LinePlotCard({
    super.key,
    required this.title,
    required this.xAxisLabel,
    required this.yAxisLabel,
    required this.series,
    this.markers = const [],
    this.caption,
    this.height = 240,
    this.xMin,
    this.xMax,
    this.yMin,
    this.yMax,
    this.logX = false,
  });

  final String title;
  final String xAxisLabel;
  final String yAxisLabel;
  final List<PlotSeries> series;
  final List<PlotMarker> markers;
  final String? caption;
  final double height;

  /// Axis limits. Any left null is fitted to the data, with a little margin.
  final double? xMin, xMax, yMin, yMax;

  /// Logarithmic x axis — for a P–v diagram, whose specific volume spans
  /// two or three decades between the top and bottom of a cycle.
  final bool logX;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    Color toneColor(PlotTone tone) => switch (tone) {
          PlotTone.primary => scheme.primary,
          PlotTone.secondary => scheme.tertiary,
          PlotTone.muted => scheme.outline,
          PlotTone.danger => scheme.error,
        };
    final legend = [
      for (final s in series)
        if (s.label != null) s,
    ];
    return AppSectionCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: height,
            child: CustomPaint(
              painter: _LinePlotPainter(
                plot: this,
                toneColor: toneColor,
                axisColor: scheme.outline,
                gridColor: scheme.outlineVariant.withValues(alpha: 0.6),
                background: theme.cardTheme.color ?? scheme.surfaceContainerLow,
                labelStyle: theme.textTheme.labelSmall!.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                markerLabelStyle: theme.textTheme.labelMedium!.copyWith(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (legend.isNotEmpty) ...[
            SizedBox(height: context.tokens.space2),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: context.tokens.space4,
              runSpacing: context.tokens.space1,
              children: [
                for (final s in legend)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomPaint(
                        size: const Size(22, 10),
                        painter: _LegendSwatchPainter(
                          color: toneColor(s.tone),
                          dashed: s.dashed,
                          width: s.width,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(s.label!, style: theme.textTheme.bodySmall),
                    ],
                  ),
              ],
            ),
          ],
          if (caption != null) ...[
            SizedBox(height: context.tokens.space2),
            Text(
              caption!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A tick spacing of 1, 2 or 5 times a power of ten giving roughly [target]
/// intervals across [range] — the steps a hand-drawn chart would use.
double niceTickStep(double range, {int target = 5}) {
  if (range <= 0 || !range.isFinite) return 1;
  final raw = range / target;
  final magnitude = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
  final residual = raw / magnitude;
  final nice = residual < 1.5
      ? 1
      : residual < 3
          ? 2
          : residual < 7
              ? 5
              : 10;
  return nice * magnitude;
}

/// A tick label without the float noise of `0.30000000000000004`.
String formatTick(double value, double step) {
  if (value.abs() < step * 1e-9) return '0';
  final magnitude = value.abs();
  if (magnitude >= 1e5 || magnitude < 1e-3) {
    return value.toStringAsExponential(0).replaceAll('e+', 'e');
  }
  final decimals = step >= 1 ? 0 : (-(math.log(step) / math.ln10).floor());
  return value.toStringAsFixed(decimals.clamp(0, 6));
}

class _LinePlotPainter extends CustomPainter {
  _LinePlotPainter({
    required this.plot,
    required this.toneColor,
    required this.axisColor,
    required this.gridColor,
    required this.background,
    required this.labelStyle,
    required this.markerLabelStyle,
  });

  final LinePlotCard plot;
  final Color Function(PlotTone) toneColor;
  final Color axisColor;
  final Color gridColor;
  final Color background;
  final TextStyle labelStyle;
  final TextStyle markerLabelStyle;

  double _tx(double x) => plot.logX ? math.log(x) / math.ln10 : x;

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      for (final s in plot.series) ...s.points,
      for (final m in plot.markers) m.point,
    ].where((p) => p.dx.isFinite && p.dy.isFinite && (!plot.logX || p.dx > 0));
    if (points.isEmpty) return;

    var x0 = plot.xMin ?? points.map((p) => p.dx).reduce(math.min);
    var x1 = plot.xMax ?? points.map((p) => p.dx).reduce(math.max);
    var y0 = plot.yMin ?? points.map((p) => p.dy).reduce(math.min);
    var y1 = plot.yMax ?? points.map((p) => p.dy).reduce(math.max);
    var tx0 = _tx(x0), tx1 = _tx(x1);
    if (tx1 - tx0 < 1e-12) {
      tx0 -= 0.5;
      tx1 += 0.5;
    }
    if (y1 - y0 < 1e-12) {
      y0 -= 1;
      y1 += 1;
    }
    // Breathing room on any side the caller did not pin.
    final xPad = (tx1 - tx0) * 0.04, yPad = (y1 - y0) * 0.06;
    if (plot.xMin == null) tx0 -= xPad;
    if (plot.xMax == null) tx1 += xPad;
    if (plot.yMin == null) y0 -= yPad;
    if (plot.yMax == null) y1 += yPad;

    final yStep = niceTickStep(y1 - y0);
    final yTicks = <double>[
      for (var v = (y0 / yStep).ceil() * yStep; v <= y1 + 1e-9; v += yStep) v,
    ];
    final xTicks = <double>[];
    double xStep;
    if (plot.logX) {
      xStep = 1;
      // Decades alone leave a chart spanning one or two of them with a
      // single labelled tick; add the 2 and 5 between them in that case.
      final mantissas = tx1 - tx0 < 2.5 ? const [1, 2, 5] : const [1];
      for (var e = tx0.floor(); e <= tx1.ceil(); e++) {
        for (final m in mantissas) {
          final t = e + math.log(m) / math.ln10;
          if (t >= tx0 && t <= tx1) xTicks.add(t);
        }
      }
    } else {
      xStep = niceTickStep(tx1 - tx0);
      for (var v = (tx0 / xStep).ceil() * xStep; v <= tx1 + 1e-9; v += xStep) {
        xTicks.add(v);
      }
    }
    String xTickLabel(double t) => plot.logX
        ? formatTick(math.pow(10, t).toDouble(), math.pow(10, t).toDouble())
        : formatTick(t, xStep);

    TextPainter layout(String text, TextStyle style) => TextPainter(
          text: TextSpan(text: text, style: style),
          textDirection: TextDirection.ltr,
        )..layout();

    final yLabels = [for (final t in yTicks) layout(formatTick(t, yStep), labelStyle)];
    final leftGutter = yLabels.fold<double>(0, (w, tp) => math.max(w, tp.width)) + 8;
    final yTitle = layout(plot.yAxisLabel, labelStyle);
    final xTitle = layout(plot.xAxisLabel, labelStyle);
    final chart = Rect.fromLTRB(
      leftGutter,
      yTitle.height + 6,
      size.width - 10,
      size.height - labelStyle.fontSize! * 1.3 - xTitle.height - 10,
    );
    if (chart.width <= 10 || chart.height <= 10) return;

    double dx(double x) =>
        chart.left + (_tx(x) - tx0) / (tx1 - tx0) * chart.width;
    double dxT(double t) => chart.left + (t - tx0) / (tx1 - tx0) * chart.width;
    double dy(double y) => chart.bottom - (y - y0) / (y1 - y0) * chart.height;

    final grid = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var k = 0; k < yTicks.length; k++) {
      final y = dy(yTicks[k]);
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
      yLabels[k].paint(
        canvas,
        Offset(chart.left - 6 - yLabels[k].width, y - yLabels[k].height / 2),
      );
    }
    var lastLabelRight = double.negativeInfinity;
    for (final t in xTicks) {
      final x = dxT(t);
      canvas.drawLine(Offset(x, chart.top), Offset(x, chart.bottom), grid);
      final tp = layout(xTickLabel(t), labelStyle);
      final left = x - tp.width / 2;
      // Skip a label that would overprint its neighbour on a narrow chart.
      if (left > lastLabelRight + 4) {
        tp.paint(canvas, Offset(left, chart.bottom + 4));
        lastLabelRight = left + tp.width;
      }
    }
    final axis = Paint()
      ..color = axisColor
      ..strokeWidth = 1.2;
    canvas.drawLine(chart.bottomLeft, chart.bottomRight, axis);
    canvas.drawLine(chart.bottomLeft, chart.topLeft, axis);
    yTitle.paint(canvas, Offset(chart.left - leftGutter + 2, 0));
    xTitle.paint(
      canvas,
      Offset(chart.right - xTitle.width, size.height - xTitle.height),
    );

    canvas.save();
    canvas.clipRect(chart.inflate(1));
    for (final s in plot.series) {
      final visible = s.points
          .where((p) => p.dx.isFinite && p.dy.isFinite && (!plot.logX || p.dx > 0))
          .toList();
      if (visible.length < 2) continue;
      final path = Path()..moveTo(dx(visible.first.dx), dy(visible.first.dy));
      for (final p in visible.skip(1)) {
        path.lineTo(dx(p.dx), dy(p.dy));
      }
      final paint = Paint()
        ..color = toneColor(s.tone)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.width
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(s.dashed ? _dash(path) : path, paint);
    }
    canvas.restore();

    for (final m in plot.markers) {
      if (!m.point.dx.isFinite || !m.point.dy.isFinite) continue;
      if (plot.logX && m.point.dx <= 0) continue;
      final c = Offset(dx(m.point.dx), dy(m.point.dy));
      canvas.drawCircle(c, 5.5, Paint()..color = background);
      canvas.drawCircle(c, 4, Paint()..color = toneColor(m.tone));
      final tp = layout(m.label, markerLabelStyle);
      // Up and to the right of the point unless that runs off the chart.
      var offset = Offset(c.dx + 6, c.dy - tp.height - 2);
      if (offset.dx + tp.width > chart.right) offset = Offset(c.dx - 6 - tp.width, offset.dy);
      if (offset.dy < chart.top) offset = Offset(offset.dx, c.dy + 4);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          (offset & tp.size).inflate(2),
          const Radius.circular(3),
        ),
        Paint()..color = background.withValues(alpha: 0.85),
      );
      tp.paint(canvas, offset);
    }
  }

  Path _dash(Path source) {
    final dashed = Path();
    for (final ui.PathMetric metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + 7, metric.length);
        dashed.addPath(metric.extractPath(distance, next), Offset.zero);
        distance = next + 5;
      }
    }
    return dashed;
  }

  @override
  bool shouldRepaint(covariant _LinePlotPainter old) =>
      old.plot != plot ||
      old.axisColor != axisColor ||
      old.labelStyle != labelStyle;
}

class _LegendSwatchPainter extends CustomPainter {
  const _LegendSwatchPainter({
    required this.color,
    required this.dashed,
    required this.width,
  });

  final Color color;
  final bool dashed;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }
    for (var x = 0.0; x < size.width; x += 9) {
      canvas.drawLine(
          Offset(x, y), Offset(math.min(x + 5, size.width), y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LegendSwatchPainter old) =>
      old.color != color || old.dashed != dashed || old.width != width;
}
