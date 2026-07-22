import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/principal_stress_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/widget/calculation_card.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class MohrsCircleResultPage extends StatelessWidget {
  MohrsCircleResultPage({
    super.key,
    required this.title,
    required this.sigmaX,
    required this.sigmaY,
    required this.tauXY,
    required this.result,
  });

  final String title;
  final double sigmaX;
  final double sigmaY;
  final double tauXY;
  final PrincipalStressResult result;
  final _exportKey = GlobalKey();

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
                    label: 'Maximum principal stress, σ1',
                    valueSI: result.sigma1,
                    category: UnitCategory.stress,
                  ),
                  AppCopyableValue(
                    label: 'Minimum principal stress, σ2',
                    valueSI: result.sigma2,
                    category: UnitCategory.stress,
                  ),
                  AppCopyableValue(
                    label: 'Maximum in-plane shear, τmax',
                    valueSI: result.tauMax,
                    category: UnitCategory.stress,
                  ),
                  AppCopyableValue(
                    label: 'Principal-plane angle, θp',
                    valueSI: result.thetaP,
                    category: UnitCategory.angle,
                  ),
                  AppCopyableValue(
                    label: 'Max-shear-plane angle, θs',
                    valueSI: result.thetaS,
                    category: UnitCategory.angle,
                  ),
                ]),
              ),
              SizedBox(height: context.tokens.space4),
              _circleCard(context, system),
              SizedBox(height: context.tokens.space4),
              CalculationCard(steps: _steps(system)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleCard(BuildContext context, UnitSystem system) => AppSectionCard(
        title: "Mohr's Circle",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 260,
              child: CustomPaint(
                painter: _MohrsCirclePainter(
                  sigmaX: fromSI(sigmaX, UnitCategory.stress, system),
                  sigmaY: fromSI(sigmaY, UnitCategory.stress, system),
                  tauXY: fromSI(tauXY, UnitCategory.stress, system),
                  color: Theme.of(context).colorScheme.primary,
                  axisColor: Theme.of(context).colorScheme.outline,
                  textColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            SizedBox(height: context.tokens.space2),
            Text(
              'Horizontal: σ (${unitLabel(UnitCategory.stress, system)}) • Vertical: τ (${unitLabel(UnitCategory.stress, system)})',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );

  List<String> _steps(UnitSystem system) => [
        'σavg = (σx + σy)/2 = (${_fv(sigmaX, UnitCategory.stress, system)} + ${_fv(sigmaY, UnitCategory.stress, system)}) / 2 = ${_fv(result.sigmaAvg, UnitCategory.stress, system)}',
        'R = √(((σx−σy)/2)² + τxy²) = ${_fv(result.tauMax, UnitCategory.stress, system)}',
        'σ1,2 = σavg ± R = ${_fv(result.sigma1, UnitCategory.stress, system)}, ${_fv(result.sigma2, UnitCategory.stress, system)}',
        'θp = ½·atan2(2τxy, σx−σy) = ${_fv(result.thetaP, UnitCategory.angle, system)}',
        'θs = θp − 45° = ${_fv(result.thetaS, UnitCategory.angle, system)}',
      ];

  void _share(UnitSystem system) => shareResult(title, [
        'σ1 = ${_fv(result.sigma1, UnitCategory.stress, system)}',
        'σ2 = ${_fv(result.sigma2, UnitCategory.stress, system)}',
        'τmax = ${_fv(result.tauMax, UnitCategory.stress, system)}',
        'θp = ${_fv(result.thetaP, UnitCategory.angle, system)}',
        'θs = ${_fv(result.thetaS, UnitCategory.angle, system)}',
        '',
        ..._steps(system),
      ]);
}

class _MohrsCirclePainter extends CustomPainter {
  const _MohrsCirclePainter({
    required this.sigmaX,
    required this.sigmaY,
    required this.tauXY,
    required this.color,
    required this.axisColor,
    required this.textColor,
  });

  final double sigmaX;
  final double sigmaY;
  final double tauXY;
  final Color color;
  final Color axisColor;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final sigmaAvg = (sigmaX + sigmaY) / 2;
    final r = sqrt(pow((sigmaX - sigmaY) / 2, 2) + pow(tauXY, 2));
    final radius = r == 0 ? 1.0 : r;

    const padding = 40.0;
    final chart = Rect.fromLTWH(
        padding, padding, size.width - 2 * padding, size.height - 2 * padding);

    // Uniform scale in both directions so the circle isn't drawn as an ellipse.
    final scale = min(chart.width, chart.height) / (2 * radius * 1.25);
    final centerOffset = Offset(
      chart.center.dx,
      chart.center.dy,
    );

    Offset toCanvas(double sigma, double tau) => Offset(
          centerOffset.dx + (sigma - sigmaAvg) * scale,
          centerOffset.dy - tau * scale,
        );

    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = 1;

    // sigma axis (tau = 0)
    canvas.drawLine(Offset(chart.left, centerOffset.dy),
        Offset(chart.right, centerOffset.dy), axisPaint);
    // tau axis (sigma = 0), only if within view
    final zeroSigmaX = toCanvas(0, 0).dx;
    if (zeroSigmaX >= chart.left && zeroSigmaX <= chart.right) {
      canvas.drawLine(Offset(zeroSigmaX, chart.top),
          Offset(zeroSigmaX, chart.bottom), axisPaint);
    }

    // Circle
    canvas.drawCircle(
      centerOffset,
      radius * scale,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Diameter X-Y
    final pointX = toCanvas(sigmaX, tauXY);
    final pointY = toCanvas(sigmaY, -tauXY);
    canvas.drawLine(
      pointX,
      pointY,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..strokeWidth = 1.5,
    );

    final dotPaint = Paint()..color = color;
    for (final p in [pointX, pointY]) {
      canvas.drawCircle(p, 3.5, dotPaint);
    }
    canvas.drawCircle(centerOffset, 2.5, Paint()..color = axisColor);

    _label(canvas, pointX, 'X', textColor);
    _label(canvas, pointY, 'Y', textColor);
    _label(canvas, toCanvas(sigmaAvg + radius, 0), 'σ1', textColor);
    _label(canvas, toCanvas(sigmaAvg - radius, 0), 'σ2', textColor);
  }

  void _label(Canvas canvas, Offset point, String text, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, point + const Offset(6, -14));
  }

  @override
  bool shouldRepaint(covariant _MohrsCirclePainter oldDelegate) =>
      oldDelegate.sigmaX != sigmaX ||
      oldDelegate.sigmaY != sigmaY ||
      oldDelegate.tauXY != tauXY ||
      oldDelegate.color != color;
}
