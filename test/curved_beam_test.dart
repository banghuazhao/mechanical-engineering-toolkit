import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/curved_beam_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/curved_beam_page.dart';

/// ∫dA/r, A and ∫r·dA by brute force over a section described by its width
/// at each radius — the check the closed forms have to agree with.
({double area, double integral, double firstMoment}) _numeric(
  double ri,
  double ro,
  double Function(double r) width,
) {
  const n = 200000;
  final dr = (ro - ri) / n;
  var area = 0.0, integral = 0.0, first = 0.0;
  for (var i = 0; i < n; i++) {
    final r = ri + (i + 0.5) * dr;
    final dA = width(r) * dr;
    area += dA;
    integral += dA / r;
    first += dA * r;
  }
  return (area: area, integral: integral, firstMoment: first);
}

void _agreesWithIntegration(
  CurvedBeamInput input,
  double Function(double r) width,
) {
  final result = CurvedBeamCalculator.calculate(input);
  final numeric = _numeric(result.innerRadius, result.outerRadius, width);
  // The midpoint rule is the loose end here, not the closed form: a flange
  // edge falls mid-step and costs it a few parts in a hundred thousand.
  const tolerance = 5e-5;
  expect(result.area, closeTo(numeric.area, numeric.area * tolerance));
  expect(result.integralDaOverR,
      closeTo(numeric.integral, numeric.integral * tolerance));
  expect(
      result.centroidRadius,
      closeTo(numeric.firstMoment / numeric.area,
          result.centroidRadius * tolerance));
}

void main() {
  group('Winkler–Bach', () {
    test('the textbook crane hook', () {
      // Shigley's Mechanical Engineering Design, example 3-15: a rectangular
      // hook section 0.75 in × 4 in, ri = 2 in, carrying 5000 lbf through the
      // centre of curvature. The book gives σi = 16.9 kpsi and
      // σo = −5.63 kpsi. Worked here in in and lbf, which the formula does
      // not mind.
      final result = CurvedBeamCalculator.calculate(const CurvedBeamInput(
        section: CurvedSection.rectangle,
        innerRadius: 2,
        depth: 4,
        width: 0.75,
        loading: CurvedBeamLoading.hook,
        normalForce: 5000,
      ));
      expect(result.centroidRadius, 4);
      expect(result.neutralRadius, closeTo(4 / math.log(3), 1e-12));
      expect(result.eccentricity, closeTo(0.3591, 1e-4));
      expect(result.moment, 20000);
      expect(result.inner.total, closeTo(16900, 50));
      expect(result.outer.total, closeTo(-5630, 20));
    });

    test('the neutral axis moves toward the centre, and Ki > 1 > Ko', () {
      final result = CurvedBeamCalculator.calculate(const CurvedBeamInput(
        section: CurvedSection.circle,
        innerRadius: 30,
        diameter: 40,
        moment: 1e6,
      ));
      expect(result.neutralRadius, lessThan(result.centroidRadius));
      expect(result.inner.curvatureFactor, greaterThan(1));
      expect(result.outer.curvatureFactor, lessThan(1));
      // The neutral axis is where the bending stress vanishes.
      expect(result.stressAt(result.neutralRadius), closeTo(0, 1e-9));
    });

    test('tends to the flexure formula as the beam straightens', () {
      final result = CurvedBeamCalculator.calculate(const CurvedBeamInput(
        section: CurvedSection.rectangle,
        innerRadius: 1e5,
        depth: 50,
        width: 20,
        moment: 1e6,
      ));
      expect(result.inner.curvatureFactor, closeTo(1, 1e-3));
      expect(result.outer.curvatureFactor, closeTo(1, 1e-3));
    });

    test('balances: ∫σ dA = N and ∫σ·(rc − r) dA = M', () {
      const input = CurvedBeamInput(
        section: CurvedSection.trapezoid,
        innerRadius: 25,
        depth: 60,
        innerWidth: 40,
        outerWidth: 15,
        moment: 3e6,
        normalForce: 12000,
      );
      final r = CurvedBeamCalculator.calculate(input);
      const n = 100000;
      final dr = r.depth / n;
      var force = 0.0, moment = 0.0;
      for (var i = 0; i < n; i++) {
        final radius = r.innerRadius + (i + 0.5) * dr;
        final b = 40 + (15 - 40) * (radius - r.innerRadius) / r.depth;
        final dA = b * dr;
        force += r.stressAt(radius) * dA;
        moment += r.stressAt(radius) * (r.centroidRadius - radius) * dA;
      }
      expect(force, closeTo(12000, 1e-3 * 12000));
      expect(moment, closeTo(3e6, 1e-3 * 3e6));
    });
  });

  group('closed forms agree with integration', () {
    test('rectangle', () {
      _agreesWithIntegration(
        const CurvedBeamInput(
            section: CurvedSection.rectangle,
            innerRadius: 10,
            depth: 30,
            width: 12),
        (_) => 12,
      );
    });

    test('trapezoid, including a triangle', () {
      _agreesWithIntegration(
        const CurvedBeamInput(
            section: CurvedSection.trapezoid,
            innerRadius: 15,
            depth: 40,
            innerWidth: 30,
            outerWidth: 10),
        (r) => 30 + (10 - 30) * (r - 15) / 40,
      );
      _agreesWithIntegration(
        const CurvedBeamInput(
            section: CurvedSection.trapezoid,
            innerRadius: 15,
            depth: 40,
            innerWidth: 30,
            outerWidth: 0),
        (r) => 30 * (1 - (r - 15) / 40),
      );
    });

    test('solid round and tube', () {
      double chord(double r, double centre, double radius) {
        final y = radius * radius - (r - centre) * (r - centre);
        return y > 0 ? 2 * math.sqrt(y) : 0;
      }

      _agreesWithIntegration(
        const CurvedBeamInput(
            section: CurvedSection.circle, innerRadius: 20, diameter: 30),
        (r) => chord(r, 35, 15),
      );
      _agreesWithIntegration(
        const CurvedBeamInput(
            section: CurvedSection.tube,
            innerRadius: 20,
            diameter: 30,
            boreDiameter: 20),
        (r) => chord(r, 35, 15) - chord(r, 35, 10),
      );
    });

    test('T with the flange either side, and an unequal I', () {
      _agreesWithIntegration(
        const CurvedBeamInput(
          section: CurvedSection.tSection,
          innerRadius: 40,
          depth: 60,
          flangeWidth: 50,
          flangeThickness: 10,
          webThickness: 8,
        ),
        (r) => r < 50 ? 50 : 8,
      );
      _agreesWithIntegration(
        const CurvedBeamInput(
          section: CurvedSection.tSection,
          innerRadius: 40,
          depth: 60,
          flangeWidth: 50,
          flangeThickness: 10,
          webThickness: 8,
          flangeInside: false,
        ),
        (r) => r < 90 ? 8 : 50,
      );
      _agreesWithIntegration(
        const CurvedBeamInput(
          section: CurvedSection.iSection,
          innerRadius: 40,
          depth: 80,
          flangeWidth: 60,
          flangeThickness: 12,
          webThickness: 8,
          outerFlangeWidth: 30,
          outerFlangeThickness: 6,
        ),
        (r) => r < 52 ? 60 : (r < 114 ? 8 : 30),
      );
    });
  });

  group('rejects', () {
    CurvedBeamResult run(CurvedBeamInput input) =>
        CurvedBeamCalculator.calculate(input);

    test('a bore as big as the tube', () {
      expect(
        () => run(const CurvedBeamInput(
            section: CurvedSection.tube,
            innerRadius: 20,
            diameter: 30,
            boreDiameter: 30)),
        throwsFormatException,
      );
    });

    test('flanges deeper than the section', () {
      expect(
        () => run(const CurvedBeamInput(
          section: CurvedSection.iSection,
          innerRadius: 20,
          depth: 20,
          flangeWidth: 30,
          flangeThickness: 10,
          webThickness: 5,
          outerFlangeWidth: 30,
          outerFlangeThickness: 10,
        )),
        throwsFormatException,
      );
    });

    test('a zero inner radius', () {
      expect(
        () => run(const CurvedBeamInput(
            section: CurvedSection.rectangle,
            innerRadius: 0,
            depth: 10,
            width: 10)),
        throwsFormatException,
      );
    });
  });

  test('replays from its recorded inputs', () {
    final input = curvedBeamInputFrom(const {
      'section': 'tSection',
      'loading': 'hook',
      'flangeInside': 'false',
      'ri': '40',
      'h': '60',
      'bf': '50',
      'tf': '10',
      'tw': '8',
      'N': '1000',
    });
    expect(input.section, CurvedSection.tSection);
    expect(input.loading, CurvedBeamLoading.hook);
    expect(input.flangeInside, isFalse);
    expect(input.flangeWidth, 50);
    expect(input.normalForce, 1000);
  });
}
