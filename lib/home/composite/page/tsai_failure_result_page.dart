import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/tsai_failure_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

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

  /// Shown on screen and reproduced in the PDF report.
  static const _formulaSteps = [
    'Tsai-Hill: FI = σ1²/X² − σ1σ2/X² + σ2²/Y² + τ12²/S²',
    '(X=Xt/Y=Yt or Xc/Yc by sign of σ1/σ2)',
    '',
    'Tsai-Wu: FI = F1σ1+F2σ2+F11σ1²+F22σ2²+F66τ12²+2F12σ1σ2',
    'F1=1/Xt−1/Xc, F2=1/Yt−1/Yc, F11=1/(XtXc), F22=1/(YtYc), F66=1/S², F12=−0.5√(F11F22)',
  ];

  @override
  Widget build(BuildContext context) {
    final hillSafe = result.tsaiHillIndex < 1;
    final wuSafe = result.tsaiWuIndex < 1;
    final scheme = Theme.of(context).colorScheme;

    return ResultScaffold(
      toolName: 'Composite Failure Criteria',
      formulaSteps: _formulaSteps,
      results: [
        ResultSection(
          title: 'Failure Indices',
          values: [
            ResultValue(
              label: 'Tsai-Hill index (${hillSafe ? 'safe' : 'FAIL'})',
              valueSI: result.tsaiHillIndex,
            ),
            ResultValue(
              label: 'Tsai-Wu index (${wuSafe ? 'safe' : 'FAIL'})',
              valueSI: result.tsaiWuIndex,
            ),
            if (result.tsaiWuStrengthRatio != null)
              ResultValue(
                label: 'Tsai-Wu strength ratio, R',
                valueSI: result.tsaiWuStrengthRatio,
              ),
          ],
        ),
      ],
      children: [
        if (!hillSafe || !wuSafe) ...[
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
        const FormulaCard(steps: _formulaSteps),
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
    );
  }
}
