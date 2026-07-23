import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/tsai_failure_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/tool_setting_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/share_helper.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class TsaiFailureResultPage extends StatelessWidget {
  TsaiFailureResultPage({
    super.key,
    required this.result,
    required this.s1,
    required this.s2,
    required this.t12,
    required this.xt,
    required this.xc,
    required this.yt,
    required this.yc,
    required this.s,
  });

  final TsaiFailureResult result;
  final double s1, s2, t12, xt, xc, yt, yc, s;
  final _exportKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final precs = context.watch<NumberPrecisionHelper>();
    final hillSafe = result.tsaiHillIndex < 1;
    final wuSafe = result.tsaiWuIndex < 1;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          IconButton(
            tooltip: 'Share results',
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _share(precs),
          ),
          IconButton(
            tooltip: 'Share as image',
            icon: const Icon(Icons.image_outlined),
            onPressed: () =>
                shareResultImage(_exportKey, 'Composite Failure Criteria'),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ToolSettingPage()),
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
                title: 'Failure Indices',
                child: Column(children: [
                  AppCopyableValue(
                    label: 'Tsai-Hill index (${hillSafe ? 'safe' : 'FAIL'})',
                    value: precs.formatValue(result.tsaiHillIndex),
                  ),
                  AppCopyableValue(
                    label: 'Tsai-Wu index (${wuSafe ? 'safe' : 'FAIL'})',
                    value: precs.formatValue(result.tsaiWuIndex),
                  ),
                  if (result.tsaiWuStrengthRatio != null)
                    AppCopyableValue(
                      label: 'Tsai-Wu strength ratio, R',
                      value: precs.formatValue(result.tsaiWuStrengthRatio),
                    ),
                ]),
              ),
              if (!hillSafe || !wuSafe) ...[
                SizedBox(height: context.tokens.space4),
                Card(
                  color: scheme.errorContainer,
                  child: Padding(
                    padding: EdgeInsets.all(context.tokens.space3),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: scheme.onErrorContainer),
                        SizedBox(width: context.tokens.space2),
                        Expanded(
                          child: Text(
                            'At least one criterion predicts failure at this stress state (index ≥ 1).',
                            style: TextStyle(color: scheme.onErrorContainer),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SizedBox(height: context.tokens.space4),
              AppSectionCard(
                title: 'Formula',
                child: Text(
                  'Tsai-Hill: FI = σ1²/X² − σ1σ2/X² + σ2²/Y² + τ12²/S²\n'
                  '(X=Xt/Y=Yt or Xc/Yc by sign of σ1/σ2)\n\n'
                  'Tsai-Wu: FI = F1σ1+F2σ2+F11σ1²+F22σ2²+F66τ12²+2F12σ1σ2\n'
                  'F1=1/Xt−1/Xc, F2=1/Yt−1/Yc, F11=1/(XtXc), F22=1/(YtYc), F66=1/S², F12=−0.5√(F11F22)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SizedBox(height: context.tokens.space4),
              ParameterSweepCard(
                variableLabel: 'τ12',
                variableCategory: UnitCategory.stress,
                baseValueSI: t12 == 0 ? 1 : t12,
                outputLabel: 'Tsai-Wu index',
                outputCategory: null,
                compute: (variedT12) {
                  final r = TsaiFailureCalculator.calculate(TsaiFailureInput(
                    sigma1: s1,
                    sigma2: s2,
                    tau12: variedT12,
                    xt: xt,
                    xc: xc,
                    yt: yt,
                    yc: yc,
                    s: s,
                  ));
                  return r.tsaiWuIndex;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _share(NumberPrecisionHelper precs) =>
      shareResult('Composite Failure Criteria', [
        'Tsai-Hill index = ${precs.formatValue(result.tsaiHillIndex)} (${result.tsaiHillIndex < 1 ? 'safe' : 'FAIL'})',
        'Tsai-Wu index = ${precs.formatValue(result.tsaiWuIndex)} (${result.tsaiWuIndex < 1 ? 'safe' : 'FAIL'})',
        if (result.tsaiWuStrengthRatio != null)
          'Tsai-Wu strength ratio R = ${precs.formatValue(result.tsaiWuStrengthRatio)}',
      ]);
}
