import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/tolerance/model/tolerance_stackup_calculator.dart';
import 'package:mechanical_engineering_toolkit/ui/app_components.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';

class ToleranceStackupResultPage extends StatelessWidget {
  const ToleranceStackupResultPage({
    super.key,
    required this.result,
    required this.contributors,
  });

  final StackupResult result;
  final List<StackupContributor> contributors;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final system = context.watch<UnitSystemPreference>().system;
    final precs = context.watch<NumberPrecisionHelper>();
    final steps = _steps(context, system, precs);

    return ResultScaffold(
      toolName: l10n.Tolerance_Stackup,
      formulaSteps: steps,
      results: [
        ResultSection(
          title: l10n.Stackup_Worst_Case,
          values: [
            ResultValue(
              label: l10n.Stackup_Outcome,
              value: result.worstCaseOutcome.label(context),
            ),
            ResultValue(
              label: l10n.Stackup_Minimum,
              valueSI: result.worstCaseMin,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Stackup_Maximum,
              valueSI: result.worstCaseMax,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Nominal_Gap,
              valueSI: result.nominalGap,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Stackup_Spread,
              valueSI: result.worstCaseSpread,
              category: UnitCategory.length,
            ),
          ],
        ),
        ResultSection(
          title: l10n.Stackup_RSS,
          values: [
            ResultValue(
              label: l10n.Stackup_Minimum,
              valueSI: result.rssMin,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Stackup_Maximum,
              valueSI: result.rssMax,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Stackup_Mean,
              valueSI: result.rssMean,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Stackup_Spread,
              valueSI: result.rssSpread,
              category: UnitCategory.length,
            ),
            ResultValue(
              label: l10n.Stackup_RSS_Saving,
              value: '${(result.rssSaving * 100).toStringAsFixed(0)}%',
            ),
          ],
        ),
        ResultSection(
          title: l10n.Stackup_Contributions,
          // Declared so the shares reach the share text, the CSV, the PDF and
          // a saved project, but drawn by [_ContributionsCard] rather than as
          // a second card of the same percentages under the same heading.
          exportOnly: true,
          values: [
            ResultValue(
              label: l10n.Stackup_Dominant,
              value: _nameOf(context, result.dominant),
            ),
            for (final share in result.shares)
              ResultValue(
                label: _nameOf(context, share),
                value: '${(share.rssShare * 100).toStringAsFixed(0)}%',
              ),
          ],
        ),
      ],
      children: [
        _ContributionsCard(result: result),
        FormulaCard(steps: steps),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.tokens.space4,
            vertical: context.tokens.space3,
          ),
          child: Text(
            l10n.Stackup_Footnote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }

  /// The user's own name for a dimension when they gave one, and its position
  /// in the chain otherwise — a result that says "housing bore" is worth more
  /// than one that says "dimension 3".
  static String _nameOf(BuildContext context, StackupShare share) {
    final label = share.contributor.label;
    return label.isEmpty
        ? S.of(context).Stackup_Dimension_N('${share.index + 1}')
        : label;
  }

  List<String> _steps(
    BuildContext context,
    UnitSystem system,
    NumberPrecisionHelper precs,
  ) {
    final l10n = S.of(context);
    String len(double v) => precs.formatSI(v, UnitCategory.length, system);
    return [
      '${l10n.Stackup_Worst_Case}: gap = Σ ±dᵢ',
      '${l10n.Stackup_Minimum} = ${len(result.worstCaseMin)}, '
          '${l10n.Stackup_Maximum} = ${len(result.worstCaseMax)}',
      '${l10n.Stackup_RSS}: T = √(Σ tᵢ²) = ${len(result.rssTolerance)}',
      '${l10n.Stackup_Mean} = ${len(result.rssMean)}, '
          '${l10n.Stackup_Minimum} = ${len(result.rssMin)}, '
          '${l10n.Stackup_Maximum} = ${len(result.rssMax)}',
    ];
  }
}

/// The share each dimension takes of the variation, drawn as bars.
///
/// Bars rather than another table of percentages: the question this answers is
/// "which one do I tighten", and a length is read at a glance where a column
/// of numbers has to be compared.
class _ContributionsCard extends StatelessWidget {
  const _ContributionsCard({required this.result});

  final StackupResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final scheme = Theme.of(context).colorScheme;
    final dominant = result.dominant;
    return AppSectionCard(
      title: l10n.Stackup_Contributions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final share in result.shares)
            Padding(
              padding: EdgeInsets.only(bottom: context.tokens.space3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ToleranceStackupResultPage._nameOf(context, share),
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(share.rssShare * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                              color: share.index == dominant.index
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.tokens.space1),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: share.rssShare,
                      minHeight: 6,
                      backgroundColor: scheme.surfaceContainerHighest,
                      color: share.index == dominant.index
                          ? scheme.primary
                          : scheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
