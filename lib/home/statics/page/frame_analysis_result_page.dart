import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/statics/model/frame_solver.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class FrameAnalysisResultPage extends StatelessWidget {
  const FrameAnalysisResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.joints,
    required this.members,
    required this.solution,
  });

  final int toolId;
  final String title;
  final List<FrameJoint> joints;
  final List<FrameMember> members;
  final FrameSolution solution;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final tool = ToolLibrary.shared.item(toolId, context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    String force(double v) => precs.formatSI(v, UnitCategory.force, system);
    final palette = _memberPalette(Theme.of(context).colorScheme);

    String path(FrameMember m) => m.joints.map((j) => 'J${j + 1}').join('–');

    final steps = [
      l10n.Frame_Count_Step(
        members.length,
        joints.length,
        solution.equations,
      ),
      l10n.Frame_Unknowns_Step(solution.unknowns),
      '',
      for (var b = 0; b < members.length; b++)
        '${l10n.Member_N(b + 1)} (${path(members[b])}): '
            'ΣFx = 0, ΣFy = 0, ΣM = 0',
      l10n.Frame_Pin_Step,
      '',
      for (final r in solution.reactions)
        'J${r.joint + 1}: Rx = ${force(r.fx)}, Ry = ${force(r.fy)}'
            '${r.support == FrameSupport.fixed ? ', M = ${precs.formatSI(r.moment, UnitCategory.torque, system)}' : ''}',
    ];

    final sections = <ResultSection>[
      ResultSection(
        title: l10n.Support_Reactions,
        values: [
          for (final r in solution.reactions) ...[
            if (r.support != FrameSupport.rollerY)
              ResultValue(
                label: 'J${r.joint + 1} Rx',
                valueSI: r.fx,
                category: UnitCategory.force,
              ),
            if (r.support != FrameSupport.rollerX)
              ResultValue(
                label: 'J${r.joint + 1} Ry',
                valueSI: r.fy,
                category: UnitCategory.force,
              ),
            if (r.support == FrameSupport.fixed)
              ResultValue(
                label: 'J${r.joint + 1} M',
                valueSI: r.moment,
                category: UnitCategory.torque,
              ),
          ],
        ],
      ),
      for (var b = 0; b < members.length; b++)
        ResultSection(
          title: '${l10n.Member_N(b + 1)} · ${path(members[b])}',
          values: [
            if (solution.axialForce(b, joints, members) case final axial?)
              ResultValue(
                label: axial >= 0
                    ? l10n.Axial_Force_Tension
                    : l10n.Axial_Force_Compression,
                valueSI: axial.abs(),
                category: UnitCategory.force,
              ),
            for (final pin in solution.memberForces[b]) ...[
              ResultValue(
                label: l10n.Pin_Force_At(pin.joint + 1),
                valueSI: pin.magnitude,
                category: UnitCategory.force,
              ),
              ResultValue(
                label: 'J${pin.joint + 1} Fx',
                valueSI: pin.fx,
                category: UnitCategory.force,
              ),
              ResultValue(
                label: 'J${pin.joint + 1} Fy',
                valueSI: pin.fy,
                category: UnitCategory.force,
              ),
              ResultValue(
                label: 'J${pin.joint + 1} θ',
                valueSI: pin.angleDegrees,
                category: UnitCategory.angle,
              ),
            ],
          ],
        ),
    ];

    return ResultScaffold(
      toolName: title,
      formulaSteps: steps,
      leading: [
        ToolResultHeader(tool: tool),
        AppSectionCard(
          title: l10n.Frame_Geometry,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 240,
                child: CustomPaint(
                  painter: _FramePainter(
                    joints: joints,
                    members: members,
                    solution: solution,
                    palette: palette,
                    reactionColor: Theme.of(context).colorScheme.tertiary,
                    loadColor: Theme.of(context).colorScheme.error,
                    textColor: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: context.tokens.space2),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: context.tokens.space3,
                runSpacing: context.tokens.space1,
                children: [
                  for (var b = 0; b < members.length; b++)
                    _Legend(
                      color: palette[b % palette.length],
                      label: l10n.Member_N(b + 1),
                    ),
                  _Legend(
                    color: Theme.of(context).colorScheme.error,
                    label: l10n.Applied_Load,
                  ),
                  _Legend(
                    color: Theme.of(context).colorScheme.tertiary,
                    label: l10n.Reaction,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
      results: sections,
      children: [
        FormulaCard(
          steps: steps,
          tex: r'''\begin{aligned}
&\text{each member: } \textstyle\sum F_x = \sum F_y = \sum M = 0\\
&\text{each pin: } \textstyle\sum F_x = \sum F_y = 0\\
&2\,n_{\text{attach}} + r = 3\,m + 2\,j
\end{aligned}''',
        ),
        Text(
          l10n.Frame_Note,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// Distinct, theme-derived colours so each member reads as its own body —
/// the point of a frame drawing, where two members crossing at a pin must
/// not look like one.
List<Color> _memberPalette(ColorScheme scheme) => [
      scheme.primary,
      scheme.secondary,
      const Color(0xFF7B5EA7),
      const Color(0xFF2E8B57),
      const Color(0xFFB8860B),
      const Color(0xFF1E6FA8),
    ];

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 14, height: 4, color: color),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}

class _FramePainter extends CustomPainter {
  const _FramePainter({
    required this.joints,
    required this.members,
    required this.solution,
    required this.palette,
    required this.reactionColor,
    required this.loadColor,
    required this.textColor,
  });

  final List<FrameJoint> joints;
  final List<FrameMember> members;
  final FrameSolution solution;
  final List<Color> palette;
  final Color reactionColor, loadColor, textColor;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 34.0;
    final chart =
        Rect.fromLTWH(pad, pad, size.width - 2 * pad, size.height - 2 * pad);
    final xs = joints.map((j) => j.x), ys = joints.map((j) => j.y);
    final minX = xs.reduce(math.min), maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min), maxY = ys.reduce(math.max);
    final spanX = maxX - minX, spanY = maxY - minY;
    final scale = math.min(
      spanX > 1e-12 ? chart.width / spanX : double.infinity,
      spanY > 1e-12 ? chart.height / spanY : double.infinity,
    );
    final s = scale.isFinite ? scale : 1.0;
    Offset at(FrameJoint j) => Offset(
          chart.center.dx + (j.x - (minX + maxX) / 2) * s,
          chart.center.dy - (j.y - (minY + maxY) / 2) * s,
        );

    for (var b = 0; b < members.length; b++) {
      final points = [for (final j in members[b].joints) at(joints[j])];
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = palette[b % palette.length]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeJoin = StrokeJoin.round
          ..strokeCap = StrokeCap.round,
      );
    }

    // Arrows at a fixed on-screen length: forces span orders of magnitude
    // that the geometry does not.
    const arrow = 26.0;
    void drawArrow(Offset tip, Offset direction, Color color,
        {bool pointingIn = true}) {
      final length = direction.distance;
      if (length == 0) return;
      final unit = direction / length;
      // A load points at its joint; a reaction is drawn leaving it.
      final from = pointingIn ? tip - unit * arrow : tip;
      final to = pointingIn ? tip : tip + unit * arrow;
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.2;
      canvas.drawLine(from, to, paint);
      final perp = Offset(-unit.dy, unit.dx);
      final head = Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(
            (to - unit * 8 + perp * 4.5).dx, (to - unit * 8 + perp * 4.5).dy)
        ..lineTo(
            (to - unit * 8 - perp * 4.5).dx, (to - unit * 8 - perp * 4.5).dy)
        ..close();
      canvas.drawPath(head, Paint()..color = color);
    }

    for (final joint in joints) {
      // Screen y runs downward.
      drawArrow(at(joint), Offset(joint.fx, -joint.fy), loadColor);
      if (joint.couple != 0) {
        final c = at(joint);
        canvas.drawArc(
          Rect.fromCircle(center: c, radius: 13),
          joint.couple > 0 ? -2.4 : -0.7,
          joint.couple > 0 ? -3.2 : 3.2,
          false,
          Paint()
            ..color = loadColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
    for (final r in solution.reactions) {
      final p = at(joints[r.joint]);
      if (r.fx.abs() > 1e-9) {
        drawArrow(p, Offset(r.fx.sign, 0), reactionColor, pointingIn: false);
      }
      if (r.fy.abs() > 1e-9) {
        drawArrow(p, Offset(0, -r.fy.sign), reactionColor, pointingIn: false);
      }
      _drawSupport(canvas, p, r.support);
    }

    for (var i = 0; i < joints.length; i++) {
      final p = at(joints[i]);
      canvas.drawCircle(p, 4.5, Paint()..color = textColor);
      canvas.drawCircle(p, 2.5, Paint()..color = const Color(0xFFFFFFFF));
      final label = TextPainter(
        text: TextSpan(
          text: 'J${i + 1}',
          style: TextStyle(
              color: textColor, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      label.paint(canvas, p + const Offset(7, -16));
    }
  }

  void _drawSupport(Canvas canvas, Offset p, FrameSupport support) {
    final paint = Paint()
      ..color = textColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    switch (support) {
      case FrameSupport.none:
        return;
      case FrameSupport.fixed:
        canvas.drawLine(
            p + const Offset(-10, 8), p + const Offset(10, 8), paint);
        for (var x = -10.0; x <= 10; x += 5) {
          canvas.drawLine(p + Offset(x, 8), p + Offset(x - 4, 13), paint);
        }
      case FrameSupport.pin:
      case FrameSupport.rollerX:
      case FrameSupport.rollerY:
        final tri = Path()
          ..moveTo(p.dx, p.dy + 4)
          ..lineTo(p.dx - 8, p.dy + 15)
          ..lineTo(p.dx + 8, p.dy + 15)
          ..close();
        canvas.drawPath(tri, paint);
        if (support != FrameSupport.pin) {
          canvas.drawCircle(p + const Offset(-4, 18), 2.5, paint);
          canvas.drawCircle(p + const Offset(4, 18), 2.5, paint);
        }
    }
  }

  @override
  bool shouldRepaint(covariant _FramePainter old) =>
      old.joints != joints ||
      old.members != members ||
      old.solution != solution;
}
