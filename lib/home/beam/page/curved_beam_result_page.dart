import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/curved_beam_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/curved_beam_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/solve/solve_for_card.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/xy_diagram_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class CurvedBeamResultPage extends StatelessWidget {
  const CurvedBeamResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.input,
    required this.result,
  });

  final int toolId;
  final String title;
  final CurvedBeamInput input;
  final CurvedBeamResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final tool = ToolLibrary.shared.item(toolId, context);

    String len(double v) => precs.formatSI(v, UnitCategory.length, system);
    String stress(double v) => precs.formatSI(v, UnitCategory.stress, system);
    final r = result;

    final steps = [
      '${l10n.Section_Shape}: ${curvedSectionLabel(context, input.section)}',
      'A = ${precs.formatSI(r.area, UnitCategory.area, system)}',
      '∫dA/r = ${len(r.integralDaOverR)}',
      'rc = ${len(r.centroidRadius)}',
      'rn = A / ∫dA/r = ${len(r.neutralRadius)}',
      'e = rc − rn = ${len(r.eccentricity)}',
      if (input.loading == CurvedBeamLoading.hook)
        'M = F·rc = ${precs.formatSI(r.moment, UnitCategory.momentSection, system)}',
      '',
      'σi = N/A + M·(rn − ri)/(A·e·ri) = ${stress(r.inner.total)}',
      'σo = N/A + M·(rn − ro)/(A·e·ro) = ${stress(r.outer.total)}',
      '',
      'M·c/I: σi = ${stress(r.inner.straightBending)}, '
          'σo = ${stress(r.outer.straightBending)}',
      'Ki = ${precs.formatValue(r.inner.curvatureFactor)}, '
          'Ko = ${precs.formatValue(r.outer.curvatureFactor)}',
    ];

    const samples = 48;
    final points = [
      for (var i = 0; i <= samples; i++)
        () {
          final radius = r.innerRadius + r.depth * i / samples;
          return DiagramPoint(
            fromSI(radius - r.innerRadius, UnitCategory.length, system),
            fromSI(r.stressAt(radius), UnitCategory.stress, system),
          );
        }(),
    ];

    return ResultScaffold(
      toolName: title,
      formulaSteps: steps,
      leading: [
        ToolResultHeader(tool: tool),
        _SectionSketchCard(input: input, result: result),
      ],
      results: [
        ResultSection(
          title: l10n.Fibre_Stresses,
          values: [
            ResultValue(
              label: l10n.Inner_Fibre_Stress,
              valueSI: r.inner.total,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: l10n.Outer_Fibre_Stress,
              valueSI: r.outer.total,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: l10n.Straight_Beam_Inner,
              valueSI: r.normalForce / r.area + r.inner.straightBending,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: l10n.Straight_Beam_Outer,
              valueSI: r.normalForce / r.area + r.outer.straightBending,
              category: UnitCategory.stress,
            ),
            ResultValue(
              label: l10n.Curvature_Factor_Ki,
              valueSI: r.inner.curvatureFactor,
            ),
            ResultValue(
              label: l10n.Curvature_Factor_Ko,
              valueSI: r.outer.curvatureFactor,
            ),
          ],
        ),
        ResultSection(
          title: l10n.Section_Geometry,
          values: [
            ResultValue(
              label: l10n.Area_A,
              valueSI: r.area,
              category: UnitCategory.area,
            ),
            ResultValue(
              label: l10n.Centroid_Radius_Rc,
              valueSI: r.centroidRadius,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Neutral_Radius_Rn,
              valueSI: r.neutralRadius,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Eccentricity_E,
              valueSI: r.eccentricity,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Outer_Radius_Ro,
              valueSI: r.outerRadius,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Second_Moment_I,
              valueSI: r.secondMoment,
              category: UnitCategory.momentOfInertia,
            ),
            ResultValue(
              label: l10n.Curvature_Ratio_Rc_H,
              valueSI: r.curvatureRatio,
            ),
          ],
        ),
        ResultSection(
          title: l10n.Section_Loads,
          values: [
            ResultValue(
              label: l10n.Moment_Carried_M,
              valueSI: r.moment,
              category: UnitCategory.momentSection,
            ),
            ResultValue(
              label: l10n.Normal_Force_Carried_N,
              valueSI: r.normalForce,
              category: UnitCategory.force,
            ),
          ],
        ),
      ],
      children: [
        FormulaCard(
          steps: steps,
          tex: r'''\begin{aligned}
r_n &= \frac{A}{\int_A dA/r}, \qquad e = r_c - r_n\\
\sigma(r) &= \frac{N}{A} + \frac{M\,(r_n - r)}{A\,e\,r}\\
\sigma_i &= \frac{N}{A} + \frac{M c_i}{A e r_i}, \qquad
\sigma_o = \frac{N}{A} - \frac{M c_o}{A e r_o}
\end{aligned}''',
        ),
        XYDiagramCard(
          title: l10n.Stress_Through_Depth,
          xUnitLabel: unitLabel(UnitCategory.length, system),
          yUnitLabel: unitLabel(UnitCategory.stress, system),
          points: points,
        ),
        SolveForCard(toolId: toolId),
        Text(
          l10n.Curved_Beam_Note,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// The section drawn to scale, inner fibre on the left — the side the centre
/// of curvature is on — with the centroid and the neutral axis marked, so
/// the shift e that the whole theory turns on is something you can see.
class _SectionSketchCard extends StatelessWidget {
  const _SectionSketchCard({required this.input, required this.result});

  final CurvedBeamInput input;
  final CurvedBeamResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = S.of(context);
    return AppSectionCard(
      title: l10n.Section_To_Scale,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 170,
            child: CustomPaint(
              painter: _SectionPainter(
                input: input,
                result: result,
                fill: theme.colorScheme.primaryContainer,
                outline: theme.colorScheme.onSurface,
                centroid: theme.colorScheme.outline,
                neutral: theme.colorScheme.error,
              ),
            ),
          ),
          SizedBox(height: context.tokens.space2),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: context.tokens.space4,
            children: [
              _LegendSwatch(
                  color: theme.colorScheme.outline, label: l10n.Centroid_Rc),
              _LegendSwatch(
                  color: theme.colorScheme.error, label: l10n.Neutral_Axis_Rn),
              Text('← ${l10n.Toward_Centre_Of_Curvature}',
                  style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 16, height: 3, color: color),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}

class _SectionPainter extends CustomPainter {
  const _SectionPainter({
    required this.input,
    required this.result,
    required this.fill,
    required this.outline,
    required this.centroid,
    required this.neutral,
  });

  final CurvedBeamInput input;
  final CurvedBeamResult result;
  final Color fill, outline, centroid, neutral;

  /// The section's extent across the radial direction, for scaling.
  double get _span => switch (input.section) {
        CurvedSection.rectangle => input.width,
        CurvedSection.trapezoid => math.max(input.innerWidth, input.outerWidth),
        CurvedSection.circle || CurvedSection.tube => input.diameter,
        CurvedSection.tSection =>
          math.max(input.flangeWidth, input.webThickness),
        CurvedSection.iSection => math.max(input.webThickness,
            math.max(input.flangeWidth, input.outerFlangeWidth)),
      };

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 14.0;
    final depth = result.depth;
    final span = _span;
    if (depth <= 0 || span <= 0) return;
    final scale = math.min(
        (size.width - 2 * pad) / depth, (size.height - 2 * pad) / span);
    final left = (size.width - depth * scale) / 2;
    final midY = size.height / 2;
    // Radial position → x, across → y.
    double x(double fromInner) => left + fromInner * scale;
    Rect band(double from, double to, double width) => Rect.fromLTRB(
        x(from), midY - width * scale / 2, x(to), midY + width * scale / 2);

    final path = Path();
    switch (input.section) {
      case CurvedSection.rectangle:
        path.addRect(band(0, depth, input.width));
      case CurvedSection.trapezoid:
        path
          ..moveTo(x(0), midY - input.innerWidth * scale / 2)
          ..lineTo(x(depth), midY - input.outerWidth * scale / 2)
          ..lineTo(x(depth), midY + input.outerWidth * scale / 2)
          ..lineTo(x(0), midY + input.innerWidth * scale / 2)
          ..close();
      case CurvedSection.circle:
      case CurvedSection.tube:
        final c = Offset(x(depth / 2), midY);
        path.addOval(Rect.fromCircle(center: c, radius: depth * scale / 2));
        if (input.section == CurvedSection.tube && input.boreDiameter > 0) {
          path
            ..addOval(Rect.fromCircle(
                center: c, radius: input.boreDiameter * scale / 2))
            ..fillType = PathFillType.evenOdd;
        }
      case CurvedSection.tSection:
        final tf = input.flangeThickness;
        final flange = input.flangeInside
            ? band(0, tf, input.flangeWidth)
            : band(depth - tf, depth, input.flangeWidth);
        final web = input.flangeInside
            ? band(tf, depth, input.webThickness)
            : band(0, depth - tf, input.webThickness);
        path.addRect(flange);
        path.addRect(web);
      case CurvedSection.iSection:
        final t1 = input.flangeThickness, t2 = input.outerFlangeThickness;
        path
          ..addRect(band(0, t1, input.flangeWidth))
          ..addRect(band(t1, depth - t2, input.webThickness))
          ..addRect(band(depth - t2, depth, input.outerFlangeWidth));
    }

    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    void axis(double fromInner, Color color, {bool dashed = false}) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2;
      final px = x(fromInner);
      if (!dashed) {
        canvas.drawLine(
            Offset(px, pad / 2), Offset(px, size.height - pad / 2), paint);
        return;
      }
      for (var y = pad / 2; y < size.height - pad / 2; y += 9) {
        canvas.drawLine(Offset(px, y),
            Offset(px, math.min(y + 5, size.height - pad / 2)), paint);
      }
    }

    axis(result.centroidRadius - result.innerRadius, centroid, dashed: true);
    axis(result.neutralRadius - result.innerRadius, neutral);
  }

  @override
  bool shouldRepaint(covariant _SectionPainter old) =>
      old.input != input ||
      old.result != result ||
      old.fill != fill ||
      old.outline != outline;
}
