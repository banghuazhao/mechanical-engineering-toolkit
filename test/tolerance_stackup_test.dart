import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/tolerance/model/tolerance_stackup_calculator.dart';

StackupContributor _dim(
  double nominal,
  double plus,
  double minus, {
  StackupDirection direction = StackupDirection.adds,
  String label = '',
}) =>
    StackupContributor(
      nominal: nominal,
      plusTolerance: plus,
      minusTolerance: minus,
      direction: direction,
      label: label,
    );

/// Worst-case limits found by trying every combination of endpoints.
///
/// The calculator reaches the same answer by summing directionally, which is
/// O(n); this is the O(2ⁿ) definition it has to agree with.
({double min, double max}) _bruteForce(List<StackupContributor> chain) {
  var min = double.infinity;
  var max = double.negativeInfinity;
  for (var mask = 0; mask < (1 << chain.length); mask++) {
    var gap = 0.0;
    for (var i = 0; i < chain.length; i++) {
      final c = chain[i];
      final size = (mask >> i) & 1 == 1 ? c.maxSize : c.minSize;
      gap += c.direction.sign * size;
    }
    min = math.min(min, gap);
    max = math.max(max, gap);
  }
  return (min: min, max: max);
}

void main() {
  group('worst case', () {
    test('a chain of two adding dimensions sums nominals and tolerances', () {
      final result = ToleranceStackupCalculator.calculate([
        _dim(10, 0.1, 0.1),
        _dim(5, 0.05, 0.05),
      ]);

      expect(result.nominalGap, closeTo(15, 1e-12));
      expect(result.worstCaseMax, closeTo(15.15, 1e-12));
      expect(result.worstCaseMin, closeTo(14.85, 1e-12));
      expect(result.worstCaseSpread, closeTo(0.30, 1e-12));
    });

    test('a gap closed by parts inside a housing', () {
      // The everyday case: a 50 bore holding a 20 and a 29 stack.
      final result = ToleranceStackupCalculator.calculate([
        _dim(50, 0.1, 0.1),
        _dim(20, 0.05, 0.05, direction: StackupDirection.subtracts),
        _dim(29, 0.05, 0.05, direction: StackupDirection.subtracts),
      ]);

      expect(result.nominalGap, closeTo(1.0, 1e-12));
      expect(result.worstCaseMax, closeTo(1.2, 1e-12));
      expect(result.worstCaseMin, closeTo(0.8, 1e-12));
      expect(result.worstCaseOutcome, StackupOutcome.clearance);
    });

    test('a subtracting dimension takes its limits the other way round', () {
      // G = a - b with a in [10, 10.2] and b in [4.7, 5.0]: the gap is largest
      // when the subtracted feature is at its *smallest*, so the two are not
      // interchangeable and a sign error here would go unnoticed on a
      // symmetric chain.
      final chain = [
        _dim(10, 0.2, 0.0),
        _dim(5, 0.0, 0.3, direction: StackupDirection.subtracts),
      ];
      final result = ToleranceStackupCalculator.calculate(chain);

      expect(result.worstCaseMax, closeTo(5.5, 1e-12));
      expect(result.worstCaseMin, closeTo(5.0, 1e-12));
    });

    test('agrees with brute force over every endpoint combination', () {
      final random = math.Random(7);
      for (var trial = 0; trial < 200; trial++) {
        final chain = [
          for (var i = 0; i < 2 + random.nextInt(5); i++)
            _dim(
              random.nextDouble() * 100,
              random.nextDouble() * 0.5,
              random.nextDouble() * 0.5,
              direction: random.nextBool()
                  ? StackupDirection.adds
                  : StackupDirection.subtracts,
            ),
        ];
        final result = ToleranceStackupCalculator.calculate(chain);
        final expected = _bruteForce(chain);
        expect(result.worstCaseMin, closeTo(expected.min, 1e-9));
        expect(result.worstCaseMax, closeTo(expected.max, 1e-9));
      }
    });

    test('reports interference when the gap can go negative', () {
      final result = ToleranceStackupCalculator.calculate([
        _dim(10, 0.05, 0.05),
        _dim(10, 0.05, 0.05, direction: StackupDirection.subtracts),
      ]);

      expect(result.nominalGap, closeTo(0, 1e-12));
      expect(result.worstCaseMin, closeTo(-0.1, 1e-12));
      expect(result.worstCaseOutcome, StackupOutcome.interference);
    });

    test('reports line-to-line when the minimum lands exactly on zero', () {
      final result = ToleranceStackupCalculator.calculate([
        _dim(10, 0.1, 0.0),
        _dim(10, 0.0, 0.0, direction: StackupDirection.subtracts),
      ]);

      expect(result.worstCaseMin, 0);
      expect(result.worstCaseOutcome, StackupOutcome.lineToLine);
    });
  });

  group('RSS', () {
    test('adds equal-bilateral tolerances in quadrature', () {
      final result = ToleranceStackupCalculator.calculate([
        _dim(10, 0.1, 0.1),
        _dim(5, 0.05, 0.05),
      ]);

      expect(result.rssMean, closeTo(15, 1e-12));
      expect(result.rssTolerance, closeTo(math.sqrt(0.01 + 0.0025), 1e-12));
      expect(result.rssSpread, lessThan(result.worstCaseSpread));
    });

    test('shifts the mean when a tolerance is asymmetric', () {
      // 25 +0.10/-0.00 is really 25.05 ±0.05. Summing it as 25 would bias the
      // whole chain low, which is the classic RSS mistake.
      final result = ToleranceStackupCalculator.calculate([
        _dim(25, 0.10, 0.0),
        _dim(10, 0.02, 0.02),
      ]);

      expect(result.nominalGap, closeTo(35, 1e-12));
      expect(result.rssMean, closeTo(35.05, 1e-12));
    });

    test('an asymmetric subtracting dimension shifts the mean the other way',
        () {
      final result = ToleranceStackupCalculator.calculate([
        _dim(10, 0.2, 0.0),
        _dim(5, 0.0, 0.3, direction: StackupDirection.subtracts),
      ]);

      // (10 + 0.10) - (5 - 0.15)
      expect(result.rssMean, closeTo(5.25, 1e-12));
      expect(result.rssTolerance, closeTo(math.sqrt(0.01 + 0.0225), 1e-12));
    });

    test('never claims a band wider than the worst case', () {
      final random = math.Random(11);
      for (var trial = 0; trial < 200; trial++) {
        final chain = [
          for (var i = 0; i < 2 + random.nextInt(5); i++)
            _dim(
              random.nextDouble() * 50,
              random.nextDouble() * 0.4,
              random.nextDouble() * 0.4,
              direction: random.nextBool()
                  ? StackupDirection.adds
                  : StackupDirection.subtracts,
            ),
        ];
        final result = ToleranceStackupCalculator.calculate(chain);
        expect(result.rssMin, greaterThanOrEqualTo(result.worstCaseMin - 1e-9));
        expect(result.rssMax, lessThanOrEqualTo(result.worstCaseMax + 1e-9));
        expect(result.rssSaving, inInclusiveRange(0, 1));
      }
    });

    test('saves nothing on a single-dimension chain', () {
      // √(t²) is just t, so there is no averaging to be had.
      final result = ToleranceStackupCalculator.calculate([_dim(10, 0.1, 0.1)]);
      expect(result.rssSaving, closeTo(0, 1e-12));
    });
  });

  group('contributions', () {
    test('worst-case share is proportional to the band', () {
      final result = ToleranceStackupCalculator.calculate([
        _dim(10, 0.15, 0.15), // band 0.30
        _dim(10, 0.05, 0.05), // band 0.10
      ]);

      expect(result.shares[0].worstCaseShare, closeTo(0.75, 1e-12));
      expect(result.shares[1].worstCaseShare, closeTo(0.25, 1e-12));
    });

    test('RSS share is proportional to the square, so it points harder', () {
      final result = ToleranceStackupCalculator.calculate([
        _dim(10, 0.15, 0.15),
        _dim(10, 0.05, 0.05),
      ]);

      // 0.15² : 0.05² is 9:1, against 3:1 by band.
      expect(result.shares[0].rssShare, closeTo(0.9, 1e-12));
      expect(result.shares[1].rssShare, closeTo(0.1, 1e-12));
      expect(result.shares[0].rssShare,
          greaterThan(result.shares[0].worstCaseShare));
    });

    test('shares sum to one and keep entry order', () {
      final result = ToleranceStackupCalculator.calculate([
        _dim(10, 0.1, 0.05, label: 'a'),
        _dim(20, 0.02, 0.02, label: 'b'),
        _dim(5, 0.3, 0.1, label: 'c'),
      ]);

      expect(result.shares.map((s) => s.index), [0, 1, 2]);
      expect(result.shares.map((s) => s.contributor.label), ['a', 'b', 'c']);
      expect(result.shares.fold<double>(0, (sum, s) => sum + s.rssShare),
          closeTo(1, 1e-12));
      expect(result.shares.fold<double>(0, (sum, s) => sum + s.worstCaseShare),
          closeTo(1, 1e-12));
    });

    test('names the loosest dimension as the one to tighten', () {
      final result = ToleranceStackupCalculator.calculate([
        _dim(10, 0.01, 0.01, label: 'tight'),
        _dim(20, 0.20, 0.20, label: 'loose'),
        _dim(5, 0.05, 0.05, label: 'middling'),
      ]);

      expect(result.dominant.contributor.label, 'loose');
      expect(result.dominant.index, 1);
    });

    test('a chain with no tolerance at all divides by zero nowhere', () {
      final result = ToleranceStackupCalculator.calculate([
        _dim(10, 0, 0),
        _dim(5, 0, 0, direction: StackupDirection.subtracts),
      ]);

      expect(result.worstCaseSpread, 0);
      expect(result.rssSaving, 0);
      expect(result.shares.every((s) => s.rssShare == 0), isTrue);
      expect(result.shares.every((s) => s.worstCaseShare == 0), isTrue);
    });
  });

  group('input validation', () {
    test('rejects an empty chain', () {
      expect(() => ToleranceStackupCalculator.calculate([]),
          throwsA(isA<FormatException>()));
    });

    test('rejects a negative tolerance, which is a sign error not a size', () {
      expect(
          () => ToleranceStackupCalculator.calculate([_dim(10, -0.1, 0.1)]),
          throwsA(isA<FormatException>()));
    });
  });
}
