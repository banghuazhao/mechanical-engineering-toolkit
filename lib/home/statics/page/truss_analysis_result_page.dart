import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/statics/model/truss_solver.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

class TrussAnalysisResultPage extends StatelessWidget {
  const TrussAnalysisResultPage({
    super.key,
    required this.toolId,
    required this.title,
    required this.joints,
    required this.members,
    required this.solution,
  });

  final int toolId;
  final String title;
  final List<TrussJoint> joints;
  final List<TrussMember> members;
  final TrussSolution solution;

  @override
  Widget build(BuildContext context) {
    final tool = ToolLibrary.shared.item(toolId, context);
    final scheme = Theme.of(context).colorScheme;
    return ResultScaffold(
      toolName: title,
      results: [
        ResultSection(
          title: S.of(context).Member_Forces,
          values: [
            for (var i = 0; i < members.length; i++)
              ResultValue(
                label:
                    'M${i + 1}: J${members[i].jointA + 1}–J${members[i].jointB + 1}'
                    ' (${solution.memberForces[i] >= 0 ? 'tension' : 'compression'})',
                valueSI: solution.memberForces[i],
                category: UnitCategory.force,
              ),
          ],
        ),
        ResultSection(
          title: S.of(context).Support_Reactions,
          values: [
            for (final r in solution.reactions) ...[
              if (joints[r.jointIndex].support == TrussSupport.pin ||
                  joints[r.jointIndex].support == TrussSupport.rollerX)
                ResultValue(
                  label: 'J${r.jointIndex + 1} Rx',
                  valueSI: r.fx,
                  category: UnitCategory.force,
                ),
              if (joints[r.jointIndex].support == TrussSupport.pin ||
                  joints[r.jointIndex].support == TrussSupport.rollerY)
                ResultValue(
                  label: 'J${r.jointIndex + 1} Ry',
                  valueSI: r.fy,
                  category: UnitCategory.force,
                ),
            ],
          ],
        ),
      ],
      // The diagram is the anchor for the tables that follow it, so it leads
      // rather than trailing them as a child would.
      leading: [
        ToolResultHeader(tool: tool),
        AppSectionCard(
          title: S.of(context).Truss_Geometry,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 220,
                child: CustomPaint(
                  painter: _TrussDiagramPainter(
                    joints: joints,
                    members: members,
                    memberForces: solution.memberForces,
                    reactions: solution.reactions,
                    tensionColor: scheme.primary,
                    compressionColor: scheme.error,
                    reactionColor: scheme.tertiary,
                    textColor: scheme.onSurface,
                  ),
                ),
              ),
              SizedBox(height: context.tokens.space2),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: context.tokens.space3,
                children: [
                  _legendItem(context, scheme.primary, 'Tension'),
                  _legendItem(context, scheme.error, 'Compression'),
                  _legendItem(context, scheme.tertiary, 'Reaction'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendItem(BuildContext context, Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 14, height: 3, color: color),
          const SizedBox(width: 6),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}

class _TrussDiagramPainter extends CustomPainter {
  const _TrussDiagramPainter({
    required this.joints,
    required this.members,
    required this.memberForces,
    required this.reactions,
    required this.tensionColor,
    required this.compressionColor,
    required this.reactionColor,
    required this.textColor,
  });

  final List<TrussJoint> joints;
  final List<TrussMember> members;
  final List<double> memberForces;
  final List<TrussReaction> reactions;
  final Color tensionColor;
  final Color compressionColor;
  final Color reactionColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (joints.isEmpty) return;
    const padding = 30.0;
    final chart = Rect.fromLTWH(
        padding, padding, size.width - 2 * padding, size.height - 2 * padding);

    final minX = joints.map((j) => j.x).reduce((a, b) => a < b ? a : b);
    final maxX = joints.map((j) => j.x).reduce((a, b) => a > b ? a : b);
    final minY = joints.map((j) => j.y).reduce((a, b) => a < b ? a : b);
    final maxY = joints.map((j) => j.y).reduce((a, b) => a > b ? a : b);
    final spanX = (maxX - minX).abs() < 1e-9 ? 1.0 : maxX - minX;
    final spanY = (maxY - minY).abs() < 1e-9 ? 1.0 : maxY - minY;
    final scale = [chart.width / spanX, chart.height / spanY]
        .reduce((a, b) => a < b ? a : b);

    final centerData = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    Offset toCanvas(double x, double y) => Offset(
          chart.center.dx + (x - centerData.dx) * scale,
          chart.center.dy - (y - centerData.dy) * scale,
        );

    for (var mi = 0; mi < members.length; mi++) {
      final member = members[mi];
      final force = mi < memberForces.length ? memberForces[mi] : 0.0;
      final linePaint = Paint()
        ..color = force >= 0 ? tensionColor : compressionColor
        ..strokeWidth = 2;
      canvas.drawLine(
        toCanvas(joints[member.jointA].x, joints[member.jointA].y),
        toCanvas(joints[member.jointB].x, joints[member.jointB].y),
        linePaint,
      );
    }

    // Reaction arrows at supported joints, direction from force sign,
    // fixed on-screen length (not to force scale — reactions can span many
    // orders of magnitude relative to the geometry).
    const arrowLength = 24.0;
    final arrowPaint = Paint()
      ..color = reactionColor
      ..strokeWidth = 2;
    for (final r in reactions) {
      final joint = toCanvas(joints[r.jointIndex].x, joints[r.jointIndex].y);
      if ((joint.dx.isNaN) || (joint.dy.isNaN)) continue;
      if (r.fx.abs() > 1e-9) {
        _drawArrow(
            canvas, joint, r.fx > 0 ? 0 : 3.14159, arrowLength, arrowPaint);
      }
      if (r.fy.abs() > 1e-9) {
        // Screen y grows downward; a positive (upward) reaction points up.
        _drawArrow(canvas, joint, r.fy > 0 ? -1.5708 : 1.5708, arrowLength,
            arrowPaint);
      }
    }

    final dotPaint = Paint()..color = textColor;
    for (var i = 0; i < joints.length; i++) {
      final p = toCanvas(joints[i].x, joints[i].y);
      canvas.drawCircle(p, 4, dotPaint);
      final painter = TextPainter(
        text: TextSpan(
          text: 'J${i + 1}',
          style: TextStyle(
              color: textColor, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, p + const Offset(6, -14));
    }
  }

  void _drawArrow(
      Canvas canvas, Offset from, double angle, double length, Paint paint) {
    final dx = length *
        (angle == 0
            ? 1
            : angle == 3.14159
                ? -1
                : 0);
    final dy = angle == -1.5708
        ? -length
        : angle == 1.5708
            ? length
            : 0.0;
    final to = from + Offset(dx, dy);
    canvas.drawLine(from, to, paint);
    final dir = (to - from);
    final len = dir.distance == 0 ? 1 : dir.distance;
    final unit = Offset(dir.dx / len, dir.dy / len);
    final perp = Offset(-unit.dy, unit.dx);
    const headSize = 6.0;
    final head1 = to - unit * headSize + perp * (headSize * 0.6);
    final head2 = to - unit * headSize - perp * (headSize * 0.6);
    canvas.drawLine(to, head1, paint);
    canvas.drawLine(to, head2, paint);
  }

  @override
  bool shouldRepaint(covariant _TrussDiagramPainter oldDelegate) => true;
}
