import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/reference/pipe_schedule_data.dart';

/// Published inside diameters, mm, for spot-checking the OD/wall pairs the
/// table stores. Taken from the inch bores ASME B36.10M lists, converted at
/// 25.4 mm/in — an independent number from the two this library carries, so
/// agreement means the stored pair is right rather than merely self-consistent.
const _publishedBores = <String, double>{
  'NPS 1 Sch 40': 1.049 * 25.4,
  'NPS 2 Sch 40': 2.067 * 25.4,
  'NPS 2 Sch 80': 1.939 * 25.4,
  'NPS 3 Sch 80': 2.900 * 25.4,
  'NPS 4 Sch 40': 4.026 * 25.4,
  'NPS 6 Sch 40': 6.065 * 25.4,
  'NPS 8 Sch 40': 7.981 * 25.4,
  'NPS 10 Sch 40': 10.020 * 25.4,
  'NPS 12 Sch 40': 11.938 * 25.4,
  'NPS 1/2 Sch 80': 0.546 * 25.4,
};

PipeSpec _spec(String designation) =>
    pipeSpecs.firstWhere((spec) => spec.designation == designation);

void main() {
  group('published dimensions', () {
    for (final entry in _publishedBores.entries) {
      test('${entry.key} bore matches the published value', () {
        // 0.06 mm covers the rounding in a 3-decimal inch bore.
        expect(_spec(entry.key).insideDiameter, closeTo(entry.value, 0.06));
      });
    }

    test('outside diameter does not vary with schedule', () {
      for (final size in pipeSizes) {
        final ods = {
          for (final schedule in size.walls.keys)
            PipeSpec(size, schedule).outsideDiameter,
        };
        expect(ods, hasLength(1),
            reason: 'NPS ${size.npsLabel} changes OD between schedules');
      }
    });

    test('NPS equals the outside diameter in inches from NPS 14 up', () {
      for (final size in pipeSizes.where((s) => s.nps >= 14)) {
        expect(size.outsideDiameter, closeTo(size.nps * 25.4, 0.5),
            reason: 'NPS ${size.npsLabel}');
      }
    });

    test('NPS is not the outside diameter below NPS 14', () {
      // The trap the footnote warns about: sizing a flow on the name rather
      // than the bore is wrong by 20% at NPS 1.
      for (final size in pipeSizes.where((s) => s.nps < 14)) {
        expect((size.outsideDiameter - size.nps * 25.4).abs(),
            greaterThan(0.5),
            reason: 'NPS ${size.npsLabel}');
      }
    });
  });

  group('derived geometry', () {
    test('a heavier schedule always narrows the bore', () {
      for (final size in pipeSizes) {
        final schedules = size.walls.keys.toList();
        for (var i = 1; i < schedules.length; i++) {
          final thinner = PipeSpec(size, schedules[i - 1]);
          final thicker = PipeSpec(size, schedules[i]);
          expect(thicker.insideDiameter, lessThan(thinner.insideDiameter),
              reason: '${thicker.designation} vs ${thinner.designation}');
        }
      }
    });

    test('every bore is positive and inside its own outside diameter', () {
      for (final spec in pipeSpecs) {
        expect(spec.insideDiameter, greaterThan(0), reason: spec.designation);
        expect(spec.insideDiameter, lessThan(spec.outsideDiameter),
            reason: spec.designation);
      }
    });

    test('flow area is the circle of the bore', () {
      final spec = _spec('NPS 4 Sch 40');
      final d = spec.insideDiameter;
      expect(spec.flowArea, closeTo(math.pi * d * d / 4, 1e-9));
    });
  });

  group('weight class aliases', () {
    test('STD tracks Sch 40 only up to NPS 10', () {
      expect(_spec('NPS 10 Sch 40').weightClass, 'STD');
      // Above NPS 10 the two part company: STD stays at 9.53 mm while Sch 40
      // keeps thickening, so claiming the alias there would be wrong.
      expect(_spec('NPS 12 Sch 40').weightClass, isNull);
    });

    test('XS tracks Sch 80 only up to NPS 8', () {
      expect(_spec('NPS 8 Sch 80').weightClass, 'XS');
      expect(_spec('NPS 10 Sch 80').weightClass, isNull);
    });

    test('the light and heavy schedules carry no weight class', () {
      expect(_spec('NPS 4 Sch 10').weightClass, isNull);
      expect(_spec('NPS 4 Sch 160').weightClass, isNull);
    });
  });

  group('catalogue', () {
    test('covers NPS 1/8 to 24 with the four schedules where they are made',
        () {
      expect(pipeSizes.first.npsLabel, '1/8');
      expect(pipeSizes.last.npsLabel, '24');
      // Sch 160 and Sch 10 are not made in the three smallest sizes.
      expect(_spec('NPS 1/8 Sch 40'), isNotNull);
      expect(pipeSpecs.where((s) => s.size.nps < 0.5), hasLength(6));
      expect(pipeSpecs.where((s) => s.schedule == PipeSchedule.sch160),
          hasLength(pipeSizes.length - 3));
    });

    test('search text carries both naming systems and the weight class', () {
      final text = _spec('NPS 2 Sch 40').searchText.toLowerCase();
      expect(text, contains('dn50'));
      expect(text, contains('sch 40'));
      expect(text, contains('std'));
    });

    test('sizes are listed smallest first', () {
      final order = pipeSizes.map((s) => s.nps).toList();
      final sorted = [...order]..sort();
      expect(order, sorted);
    });
  });
}
