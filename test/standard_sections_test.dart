import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/reference/standard_section_data.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';

/// Bare-geometry properties of a symmetric I-shape: two flange plates and a
/// web, with square corners and no root fillets.
///
/// This is the whole safeguard on the tabulated data. Every published value is
/// an independent number typed in by hand, and the failure mode that matters
/// is a transcription slip — a dropped digit, a misplaced decimal point, a row
/// shifted by one column. None of those survive a comparison against the
/// shape's own dimensions, because the dimensions and the properties come from
/// different columns of the source table and a slip in one will not be
/// mirrored in the other.
({double area, double ix, double iy}) _bareGeometry(StandardSection s) {
  final webHeight = s.depth - 2 * s.flangeThickness;
  final flangeArea = s.width * s.flangeThickness;
  final area = 2 * flangeArea + s.webThickness * webHeight;

  // Flanges about x: own inertia plus the parallel-axis term to mid-flange.
  final flangeArm = (s.depth - s.flangeThickness) / 2;
  final ix = 2 *
          (s.width * math.pow(s.flangeThickness, 3) / 12 +
              flangeArea * flangeArm * flangeArm) +
      s.webThickness * math.pow(webHeight, 3) / 12;

  // About y both flanges and the web are centred, so no parallel-axis term.
  final iy = 2 * (s.flangeThickness * math.pow(s.width, 3) / 12) +
      webHeight * math.pow(s.webThickness, 3) / 12;

  return (area: area, ix: ix.toDouble(), iy: iy.toDouble());
}

void main() {
  group('library shape', () {
    test('is not empty and covers every family', () {
      expect(standardSections, isNotEmpty);
      for (final family in SectionFamily.values) {
        expect(
          standardSections.where((s) => s.family == family),
          isNotEmpty,
          reason: 'no shapes listed for $family',
        );
      }
    });

    test('designations are unique', () {
      final names = standardSections.map((s) => s.designation).toList();
      expect(names.toSet(), hasLength(names.length));
    });

    test('designations are trimmed and non-empty', () {
      for (final section in standardSections) {
        expect(section.designation, isNotEmpty);
        expect(section.designation, equals(section.designation.trim()));
      }
    });

    test('every dimension and property is positive', () {
      for (final s in standardSections) {
        final why = s.designation;
        expect(s.depth, greaterThan(0), reason: why);
        expect(s.width, greaterThan(0), reason: why);
        expect(s.webThickness, greaterThan(0), reason: why);
        expect(s.flangeThickness, greaterThan(0), reason: why);
        expect(s.area, greaterThan(0), reason: why);
        expect(s.ix, greaterThan(0), reason: why);
        expect(s.iy, greaterThan(0), reason: why);
      }
    });

    test('the two flanges fit inside the depth', () {
      for (final s in standardSections) {
        expect(2 * s.flangeThickness, lessThan(s.depth),
            reason: '${s.designation} has flanges thicker than it is deep');
      }
    });

    test('the web is thinner than the flange', () {
      // True of every rolled I-shape in these three families.
      for (final s in standardSections) {
        expect(s.webThickness, lessThan(s.flangeThickness),
            reason: '${s.designation} has a web thicker than its flange');
      }
    });

    test('the strong axis is the strong one', () {
      for (final s in standardSections) {
        expect(s.ix, greaterThan(s.iy),
            reason: '${s.designation} has Iy above Ix — axes swapped?');
      }
    });
  });

  group('published values agree with the shape geometry', () {
    // Fillets add material near the web, so a published value should sit at or
    // just above the square-cornered figure. The band is wide enough for the
    // heaviest fillets and narrow enough that a mistyped digit cannot hide.
    const lower = 0.98;
    const upper = 1.15;

    for (final section in standardSections) {
      test('${section.designation} area, Ix and Iy are self-consistent', () {
        final bare = _bareGeometry(section);

        expect(section.area / bare.area, inInclusiveRange(lower, upper),
            reason: '${section.designation}: published A ${section.area} vs '
                'geometry ${bare.area}');
        expect(section.ix / bare.ix, inInclusiveRange(lower, upper),
            reason: '${section.designation}: published Ix ${section.ix} vs '
                'geometry ${bare.ix}');
        expect(section.iy / bare.iy, inInclusiveRange(lower, upper),
            reason: '${section.designation}: published Iy ${section.iy} vs '
                'geometry ${bare.iy}');
      });
    }
  });

  group('derived properties', () {
    test('section modulus is the second moment over the extreme fibre', () {
      for (final s in standardSections) {
        expect(s.zx, closeTo(s.ix / (s.depth / 2), 1e-6), reason: s.designation);
        expect(s.zy, closeTo(s.iy / (s.width / 2), 1e-6), reason: s.designation);
      }
    });

    test('radius of gyration is sqrt(I/A)', () {
      for (final s in standardSections) {
        expect(s.rx, closeTo(math.sqrt(s.ix / s.area), 1e-9),
            reason: s.designation);
        expect(s.ry, closeTo(math.sqrt(s.iy / s.area), 1e-9),
            reason: s.designation);
      }
    });

    test('rx exceeds ry, and both fit inside the section', () {
      for (final s in standardSections) {
        expect(s.rx, greaterThan(s.ry), reason: s.designation);
        // A radius of gyration is always smaller than the half-extent it is
        // measured over.
        expect(s.rx, lessThan(s.depth), reason: s.designation);
        expect(s.ry, lessThan(s.width), reason: s.designation);
      }
    });

    test('a heavier shape in a series carries more of everything', () {
      final w12x40 =
          standardSections.firstWhere((s) => s.designation == 'W12X40');
      final w12x65 =
          standardSections.firstWhere((s) => s.designation == 'W12X65');
      expect(w12x65.area, greaterThan(w12x40.area));
      expect(w12x65.ix, greaterThan(w12x40.ix));
      expect(w12x65.zx, greaterThan(w12x40.zx));
    });
  });

  group('first moment at the neutral axis', () {
    // Twice Q about the neutral axis is the plastic modulus, which the tables
    // do publish. The rectangles leave out the root fillets, so 2Q falls a
    // few percent short of the published figure — and never above it.
    test('W12X40 against its published Zx of 57.0 in³', () {
      final s = standardSections.firstWhere((s) => s.designation == 'W12X40');
      final zx = 57.0 * 16387.064; // in³ → mm³
      final twoQ = 2 * s.firstMomentAtNeutralAxis;
      expect(twoQ, lessThan(zx));
      expect(twoQ, greaterThan(zx * 0.95));
    });

    test('IPE 300 against its published Wpl,y of 628 cm³', () {
      final s = standardSections.firstWhere((s) => s.designation == 'IPE 300');
      const wpl = 628.4 * 1000; // cm³ → mm³
      final twoQ = 2 * s.firstMomentAtNeutralAxis;
      expect(twoQ, lessThan(wpl));
      expect(twoQ, greaterThan(wpl * 0.94));
    });
  });

  group('units', () {
    test('imperial rows converted into the app SI display units', () {
      // W12X40 is published as d = 11.9 in, A = 11.7 in², Ix = 307 in⁴.
      final section =
          standardSections.firstWhere((s) => s.designation == 'W12X40');
      expect(section.depth, closeTo(11.9 * 25.4, 1e-6));
      expect(section.area, closeTo(11.7 * 645.16, 1e-3));
      expect(section.ix, closeTo(307 * 416231.4256, 1e-1));

      // ...and read back out as the original inches under an imperial display.
      expect(fromSI(section.depth, UnitCategory.length, UnitSystem.imperial),
          closeTo(11.9, 1e-9));
      expect(fromSI(section.ix, UnitCategory.momentOfInertia,
              UnitSystem.imperial),
          closeTo(307, 1e-6));
    });

    test('metric rows converted from cm-based table units', () {
      // IPE 300 is published as A = 53.8 cm², Ix = 8356 cm⁴, Iy = 604 cm⁴.
      final section =
          standardSections.firstWhere((s) => s.designation == 'IPE 300');
      expect(section.depth, closeTo(300, 1e-9));
      expect(section.area, closeTo(5380, 1e-6));
      expect(section.ix, closeTo(83560000, 1e-3));
      expect(section.iy, closeTo(6040000, 1e-3));
    });

    test('an IPE depth matches the number in its own designation', () {
      for (final s in standardSections.where((s) => s.family == SectionFamily.ipe)) {
        final nominal = double.parse(s.designation.split(' ').last);
        expect(s.depth, closeTo(nominal, 1e-9),
            reason: '${s.designation} is not ${nominal}mm deep');
      }
    });

    test('a W shape depth matches the nominal in its designation', () {
      for (final s
          in standardSections.where((s) => s.family == SectionFamily.wShape)) {
        // "W12X40" is nominally 12 in deep; the real depth is within an inch.
        final nominal =
            double.parse(s.designation.substring(1).split('X').first);
        final inches = fromSI(s.depth, UnitCategory.length, UnitSystem.imperial);
        expect((inches - nominal).abs(), lessThan(1.0),
            reason: '${s.designation} is $inches in deep');
      }
    });
  });
}
