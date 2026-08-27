import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';

/// Which way a dimension acts on the gap being closed.
///
/// A stack-up is a loop: walk from one side of the gap to the other, and every
/// dimension you cross either carries you towards the far side or back. Getting
/// a direction wrong is the classic stack-up error, which is why this is an
/// explicit per-dimension choice rather than a signed nominal the user has to
/// remember to negate.
enum StackupDirection { adds, subtracts }

extension StackupDirectionLabel on StackupDirection {
  String label(BuildContext context) => this == StackupDirection.adds
      ? S.of(context).Stackup_Adds
      : S.of(context).Stackup_Subtracts;

  /// +1 or -1, for multiplying a nominal.
  double get sign => this == StackupDirection.adds ? 1 : -1;
}

/// One dimension in the chain, with its tolerance written as a drawing writes
/// it: a nominal, and how far the feature may run over and under it.
///
/// [plusTolerance] and [minusTolerance] are magnitudes, both non-negative. A
/// dimension of 25 +0.10/-0.05 has plus 0.10 and minus 0.05, and a symmetric
/// 25 ±0.05 has 0.05 in both.
@immutable
class StackupContributor {
  const StackupContributor({
    required this.nominal,
    required this.plusTolerance,
    required this.minusTolerance,
    this.direction = StackupDirection.adds,
    this.label = '',
  });

  /// Free-text name, e.g. "housing bore" — carried so a result can name the
  /// dimension worth tightening rather than calling it "dimension 3".
  final String label;

  /// Nominal size, mm. Always positive; [direction] carries the sign.
  final double nominal;

  /// Upper deviation, mm, as a magnitude.
  final double plusTolerance;

  /// Lower deviation, mm, as a magnitude.
  final double minusTolerance;

  final StackupDirection direction;

  /// The nominal as it enters the sum.
  double get signedNominal => direction.sign * nominal;

  /// Total width of the tolerance band.
  double get band => plusTolerance + minusTolerance;

  /// Half the band — the tolerance this dimension would carry if it were
  /// written as an equal-bilateral ±t.
  double get halfBand => band / 2;

  /// How far the middle of the band sits from the nominal.
  ///
  /// Zero for a symmetric tolerance. A dimension of 25 +0.10/-0.00 is really
  /// 25.05 ±0.05, and it is that 25.05 the statistical methods must sum:
  /// treating it as 25 would bias the whole stack low.
  double get meanShift => (plusTolerance - minusTolerance) / 2;

  /// Largest and smallest this dimension may actually measure.
  double get maxSize => nominal + plusTolerance;
  double get minSize => nominal - minusTolerance;
}

/// What the closing gap does at its worst.
enum StackupOutcome { clearance, lineToLine, interference }

extension StackupOutcomeLabel on StackupOutcome {
  String label(BuildContext context) => switch (this) {
        StackupOutcome.clearance => S.of(context).Stackup_Clearance,
        StackupOutcome.lineToLine => S.of(context).Stackup_Line_To_Line,
        StackupOutcome.interference => S.of(context).Stackup_Interference,
      };
}

/// One dimension's share of the closing gap's variation.
class StackupShare {
  const StackupShare({
    required this.index,
    required this.contributor,
    required this.worstCaseShare,
    required this.rssShare,
  });

  /// Position in the chain as entered, so a result can point back at a row.
  final int index;

  final StackupContributor contributor;

  /// Fraction of the worst-case spread this dimension is responsible for,
  /// 0 to 1. Proportional to its band.
  final double worstCaseShare;

  /// Fraction of the RSS variance, 0 to 1. Proportional to the *square* of
  /// its band, which is why RSS points so much harder at the loosest
  /// dimension than the worst-case share does.
  final double rssShare;
}

class StackupResult {
  const StackupResult({
    required this.nominalGap,
    required this.worstCaseMin,
    required this.worstCaseMax,
    required this.rssMean,
    required this.rssTolerance,
    required this.shares,
  });

  /// Sum of the signed nominals — the gap if every part were made perfectly.
  final double nominalGap;

  /// Smallest and largest the gap can be with every dimension at the end of
  /// its band that hurts most.
  ///
  /// Held as the two limits rather than as a centre and a half-width: an
  /// asymmetric chain moves them independently, so ± about the nominal would
  /// not describe them.
  final double worstCaseMin;
  final double worstCaseMax;

  /// Centre of the statistical distribution. Differs from [nominalGap]
  /// whenever any dimension's tolerance is asymmetric.
  final double rssMean;

  /// Half-width of the RSS band: √(Σ tᵢ²) over the equal-bilateral halves.
  final double rssTolerance;

  /// Per-dimension responsibility for the variation, in entry order.
  final List<StackupShare> shares;

  double get rssMin => rssMean - rssTolerance;
  double get rssMax => rssMean + rssTolerance;

  /// Total worst-case spread, max less min.
  double get worstCaseSpread => worstCaseMax - worstCaseMin;

  /// Total RSS spread.
  double get rssSpread => 2 * rssTolerance;

  /// How much narrower the statistical band is, as a fraction of the
  /// worst-case band. The reason anyone runs RSS at all.
  double get rssSaving =>
      worstCaseSpread == 0 ? 0 : 1 - rssSpread / worstCaseSpread;

  StackupOutcome get worstCaseOutcome {
    if (worstCaseMin > 0) return StackupOutcome.clearance;
    if (worstCaseMin == 0) return StackupOutcome.lineToLine;
    return StackupOutcome.interference;
  }

  /// The dimension worth tightening first — the largest RSS share, which is
  /// where a tolerance change buys the most.
  StackupShare get dominant => shares.reduce(
      (a, b) => b.rssShare > a.rssShare ? b : a);
}

/// One-dimensional tolerance stack-up by both the worst-case and the RSS
/// (root-sum-square) method.
///
/// ## Which answer to believe
///
/// Worst case is arithmetic and unarguable: every dimension sits at the end of
/// its band that hurts most, all at once. If the worst case closes, the
/// assembly always goes together, and no sampling argument can overturn that.
/// It is also, on a long chain, needlessly expensive — the odds of every
/// dimension being extreme in the same direction are vanishingly small.
///
/// RSS adds the tolerances in quadrature instead, which is right only if the
/// dimensions vary independently, are centred in their bands, and are roughly
/// normal. Real processes drift, tools wear, and a supplier who is inside
/// tolerance at one edge of the band stays there — so RSS understates the
/// spread whenever those assumptions slip, and it says nothing at all about a
/// lot of five parts. Use it to decide where to spend tolerance, and the worst
/// case to decide whether the design is safe.
abstract final class ToleranceStackupCalculator {
  static StackupResult calculate(List<StackupContributor> contributors) {
    if (contributors.isEmpty) {
      throw const FormatException('A stack-up needs at least one dimension.');
    }
    for (final c in contributors) {
      if (c.plusTolerance < 0 || c.minusTolerance < 0) {
        throw const FormatException('Tolerances are magnitudes, never negative.');
      }
    }

    var nominalGap = 0.0;
    // Worst case is directional: a dimension that adds pushes the gap to its
    // maximum when the feature runs large, while one that subtracts pushes it
    // to the maximum when the feature runs small. Summing bands without
    // regard to direction would be right only for symmetric tolerances.
    var maxExcursion = 0.0;
    var minExcursion = 0.0;
    var rssMean = 0.0;
    var sumSquares = 0.0;
    var sumBands = 0.0;

    for (final c in contributors) {
      nominalGap += c.signedNominal;
      if (c.direction == StackupDirection.adds) {
        maxExcursion += c.plusTolerance;
        minExcursion += c.minusTolerance;
      } else {
        maxExcursion += c.minusTolerance;
        minExcursion += c.plusTolerance;
      }
      rssMean += c.direction.sign * (c.nominal + c.meanShift);
      sumSquares += c.halfBand * c.halfBand;
      sumBands += c.band;
    }

    return StackupResult(
      nominalGap: nominalGap,
      worstCaseMin: nominalGap - minExcursion,
      worstCaseMax: nominalGap + maxExcursion,
      rssMean: rssMean,
      rssTolerance: math.sqrt(sumSquares),
      shares: [
        for (var i = 0; i < contributors.length; i++)
          StackupShare(
            index: i,
            contributor: contributors[i],
            worstCaseShare:
                sumBands == 0 ? 0 : contributors[i].band / sumBands,
            rssShare: sumSquares == 0
                ? 0
                : contributors[i].halfBand *
                    contributors[i].halfBand /
                    sumSquares,
          ),
      ],
    );
  }
}
