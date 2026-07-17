import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/statics/model/truss_solver.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class TrussAnalysisResultPage extends StatelessWidget {
  const TrussAnalysisResultPage({
    super.key,
    required this.title,
    required this.joints,
    required this.members,
    required this.solution,
  });

  final String title;
  final List<TrussJoint> joints;
  final List<TrussMember> members;
  final TrussSolution solution;

  String _f(double value) =>
      value.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

  String _fv(double valueSI, UnitCategory category, UnitSystem system) =>
      '${_f(fromSI(valueSI, category, system))} ${unitLabel(category, system)}';

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
        ],
      ),
      body: AppContent(
        padding: EdgeInsets.zero,
        child: ListView(
          padding: EdgeInsets.all(context.tokens.space4),
          children: [
            AppSectionCard(
              title: 'Truss Geometry',
              child: SizedBox(
                height: 220,
                child: CustomPaint(
                  painter: _TrussDiagramPainter(
                    joints: joints,
                    members: members,
                    color: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SizedBox(height: context.tokens.space4),
            AppSectionCard(
              title: 'Member Forces (+ tension, − compression)',
              child: Column(
                children: List.generate(members.length, (i) {
                  final force = solution.memberForces[i];
                  final member = members[i];
                  final tag = force >= 0 ? 'tension' : 'compression';
                  return AppCopyableValue(
                    label: 'M${i + 1}: J${member.jointA + 1}–J${member.jointB + 1} ($tag)',
                    valueSI: force,
                    category: UnitCategory.force,
                  );
                }),
              ),
            ),
            SizedBox(height: context.tokens.space4),
            AppSectionCard(
              title: 'Support Reactions',
              child: Column(
                children: solution.reactions.expand((r) {
                  final joint = joints[r.jointIndex];
                  final widgets = <Widget>[];
                  if (joint.support == TrussSupport.pin ||
                      joint.support == TrussSupport.rollerX) {
                    widgets.add(AppCopyableValue(
                      label: 'J${r.jointIndex + 1} Rx',
                      valueSI: r.fx,
                      category: UnitCategory.force,
                    ));
                  }
                  if (joint.support == TrussSupport.pin ||
                      joint.support == TrussSupport.rollerY) {
                    widgets.add(AppCopyableValue(
                      label: 'J${r.jointIndex + 1} Ry',
                      valueSI: r.fy,
                      category: UnitCategory.force,
                    ));
                  }
                  return widgets;
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _share(UnitSystem system) => shareResult(title, [
        for (var i = 0; i < members.length; i++)
          'M${i + 1}: J${members[i].jointA + 1}–J${members[i].jointB + 1} = ${_fv(solution.memberForces[i], UnitCategory.force, system)}',
        '',
        for (final r in solution.reactions)
          'J${r.jointIndex + 1} reaction: Rx = ${_fv(r.fx, UnitCategory.force, system)}, Ry = ${_fv(r.fy, UnitCategory.force, system)}',
      ]);
}

class _TrussDiagramPainter extends CustomPainter {
  const _TrussDiagramPainter({
    required this.joints,
    required this.members,
    required this.color,
    required this.textColor,
  });

  final List<TrussJoint> joints;
  final List<TrussMember> members;
  final Color color;
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

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2;
    for (final member in members) {
      canvas.drawLine(
        toCanvas(joints[member.jointA].x, joints[member.jointA].y),
        toCanvas(joints[member.jointB].x, joints[member.jointB].y),
        linePaint,
      );
    }

    final dotPaint = Paint()..color = color;
    for (var i = 0; i < joints.length; i++) {
      final p = toCanvas(joints[i].x, joints[i].y);
      canvas.drawCircle(p, 4, dotPaint);
      final painter = TextPainter(
        text: TextSpan(
          text: 'J${i + 1}',
          style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      painter.paint(canvas, p + const Offset(6, -14));
    }
  }

  @override
  bool shouldRepaint(covariant _TrussDiagramPainter oldDelegate) => true;
}
