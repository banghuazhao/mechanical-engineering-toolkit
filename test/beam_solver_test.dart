import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/beam_solver.dart';

/// The solver is checked against the closed forms it replaces, one per support
/// case, because that is the only independent check there is: a stiffness
/// solve that is wrong is wrong self-consistently, and every diagram it draws
/// would agree with every other one.
///
/// Span 4 m, E = 200 GPa, I = 1e8 mm⁴, so EI = 2e7 N·m² exactly.
const _span = 4.0;
const _e = 200.0;
const _i = 1e8;
const _ei = 2e7;

BeamInput _input({
  required BeamSupportCase supportCase,
  required List<BeamLoad> loads,
  double span = _span,
  double? leftSupport,
  double? rightSupport,
  double? extremeFibre,
}) =>
    BeamInput(
      span: span,
      supports: supportsFor(supportCase, span,
          leftSupport: leftSupport, rightSupport: rightSupport),
      loads: loads,
      elasticModulus: _e,
      secondMoment: _i,
      extremeFibreDistance: extremeFibre,
    );

/// Deflection in mm from a rigidity in N·m², a load in kN and a span in m.
double _mm(double metres) => metres * 1000;

void main() {
  group('simply supported', () {
    test('central point load matches PL/4 and PL³/48EI', () {
      const p = 10.0; // kN
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [BeamPointLoad(position: _span / 2, magnitude: p)],
      ));

      expect(result.reactions[0].force, closeTo(p / 2, 1e-6));
      expect(result.reactions[1].force, closeTo(p / 2, 1e-6));
      expect(result.reactions[0].moment, 0);

      expect(result.maximumMoment.value, closeTo(p * _span / 4, 1e-6));
      expect(result.maximumMoment.position, closeTo(_span / 2, 1e-6));
      expect(result.maximumHoggingMoment.value, 0);

      final expected =
          _mm(p * 1000 * math.pow(_span, 3) / (48 * _ei));
      expect(result.maximumDeflection.value, closeTo(expected, expected * 1e-4));
      expect(result.maximumDeflection.position, closeTo(_span / 2, 1e-6));
      expect(result.isDeterminate, isTrue);
    });

    test('uniform load matches wL²/8 and 5wL⁴/384EI', () {
      const w = 12.0; // kN/m
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [
          BeamDistributedLoad(
              start: 0, end: _span, startIntensity: w, endIntensity: w),
        ],
      ));

      expect(result.reactions[0].force, closeTo(w * _span / 2, 1e-6));
      expect(result.maximumMoment.value,
          closeTo(w * _span * _span / 8, 1e-4));

      final expected =
          _mm(5 * w * 1000 * math.pow(_span, 4) / (384 * _ei));
      expect(result.maximumDeflection.value, closeTo(expected, expected * 1e-3));
      expect(result.maximumDeflection.position, closeTo(_span / 2, 0.02));
    });

    test('an off-centre point load lands where the closed form puts it', () {
      const p = 10.0;
      const a = 1.5;
      const b = _span - a;
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [BeamPointLoad(position: a, magnitude: p)],
      ));

      expect(result.reactions[0].force, closeTo(p * b / _span, 1e-6));
      expect(result.reactions[1].force, closeTo(p * a / _span, 1e-6));
      // M under the load = Pab/L.
      expect(result.maximumMoment.value, closeTo(p * a * b / _span, 1e-6));
      expect(result.maximumMoment.position, closeTo(a, 1e-6));

      // The peak deflection is not under the load. It sits in the longer
      // segment, √((L²−s²)/3) from the far support, where s is the *shorter*
      // of the two distances — here a, since the load is left of centre.
      const s = a < b ? a : b;
      final fromFarSupport = math.sqrt((_span * _span - s * s) / 3);
      final expected = _mm(p *
          1000 *
          s *
          math.sqrt(math.pow(_span * _span - s * s, 3)) /
          (9 * math.sqrt(3) * _span * _ei));
      expect(result.maximumDeflection.value, closeTo(expected, expected * 1e-3));
      expect(result.maximumDeflection.position,
          closeTo(_span - fromFarSupport, 0.05));
    });

    test('two point loads superpose', () {
      const p = 6.0;
      final one = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [BeamPointLoad(position: 1, magnitude: p)],
      ));
      final other = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [BeamPointLoad(position: 3, magnitude: p)],
      ));
      final both = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [
          BeamPointLoad(position: 1, magnitude: p),
          BeamPointLoad(position: 3, magnitude: p),
        ],
      ));

      expect(both.reactions[0].force,
          closeTo(one.reactions[0].force + other.reactions[0].force, 1e-6));
      // Superposition holds point by point, not peak by peak: each single
      // load peaks somewhere else, so it is the midspan station that has to
      // add up.
      double atMidspan(BeamResult result) => result.deflection
          .firstWhere((point) => (point.x - _span / 2).abs() < 1e-9)
          .value;
      expect(atMidspan(both),
          closeTo(atMidspan(one) + atMidspan(other), 1e-6));
    });
  });

  group('cantilever', () {
    test('tip load matches PL and PL³/3EI', () {
      const p = 10.0;
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.cantileverLeft,
        loads: const [BeamPointLoad(position: _span, magnitude: p)],
      ));

      expect(result.reactions, hasLength(1));
      expect(result.reactions.single.force, closeTo(p, 1e-6));
      // A downward tip load hogs the wall, and the restraining couple is
      // counter-clockwise positive.
      expect(result.reactions.single.moment, closeTo(p * _span, 1e-6));

      expect(result.maximumHoggingMoment.value, closeTo(-p * _span, 1e-6));
      expect(result.maximumHoggingMoment.position, closeTo(0, 1e-6));
      expect(result.maximumSaggingMoment.value, 0);

      final expected = _mm(p * 1000 * math.pow(_span, 3) / (3 * _ei));
      expect(result.maximumDeflection.value, closeTo(expected, expected * 1e-4));
      expect(result.maximumDeflection.position, closeTo(_span, 1e-6));
    });

    test('uniform load matches wL²/2 and wL⁴/8EI', () {
      const w = 12.0;
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.cantileverLeft,
        loads: const [
          BeamDistributedLoad(
              start: 0, end: _span, startIntensity: w, endIntensity: w),
        ],
      ));

      expect(result.reactions.single.force, closeTo(w * _span, 1e-6));
      expect(result.maximumHoggingMoment.value,
          closeTo(-w * _span * _span / 2, 1e-4));

      final expected = _mm(w * 1000 * math.pow(_span, 4) / (8 * _ei));
      expect(result.maximumDeflection.value, closeTo(expected, expected * 1e-3));
    });

    test('fixing the right end mirrors the left-hand answer', () {
      const p = 10.0;
      final left = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.cantileverLeft,
        loads: const [BeamPointLoad(position: _span, magnitude: p)],
      ));
      final right = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.cantileverRight,
        loads: const [BeamPointLoad(position: 0, magnitude: p)],
      ));

      expect(right.reactions.single.force, closeTo(p, 1e-6));
      expect(right.maximumDeflection.value,
          closeTo(left.maximumDeflection.value, 1e-6));
      expect(right.maximumDeflection.position, closeTo(0, 1e-6));
      expect(right.maximumHoggingMoment.value.abs(),
          closeTo(left.maximumHoggingMoment.value.abs(), 1e-6));
    });
  });

  group('propped cantilever', () {
    // Indeterminate to the first degree: these reactions cannot be found from
    // equilibrium, so getting them right is the real test of the solve.
    test('uniform load splits 5/8 and 3/8', () {
      const w = 12.0;
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.proppedCantilever,
        loads: const [
          BeamDistributedLoad(
              start: 0, end: _span, startIntensity: w, endIntensity: w),
        ],
      ));

      expect(result.isDeterminate, isFalse);
      expect(result.reactions[0].force, closeTo(5 * w * _span / 8, 1e-3));
      expect(result.reactions[1].force, closeTo(3 * w * _span / 8, 1e-3));

      // Wall moment wL²/8 hogging, peak sagging 9wL²/128 at 5L/8.
      expect(result.maximumHoggingMoment.value,
          closeTo(-w * _span * _span / 8, 1e-3));
      expect(result.maximumSaggingMoment.value,
          closeTo(9 * w * _span * _span / 128, 1e-3));
      expect(result.maximumSaggingMoment.position, closeTo(5 * _span / 8, 0.02));

      // δmax = wL⁴/(185 EI) at about 0.5785 L.
      final expected = _mm(w * 1000 * math.pow(_span, 4) / (185 * _ei));
      expect(result.maximumDeflection.value, closeTo(expected, expected * 5e-3));
      expect(result.maximumDeflection.position, closeTo(0.5785 * _span, 0.05));
    });
  });

  group('fixed at both ends', () {
    test('uniform load matches wL²/12 at the ends and wL⁴/384EI at midspan',
        () {
      const w = 12.0;
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.fixedFixed,
        loads: const [
          BeamDistributedLoad(
              start: 0, end: _span, startIntensity: w, endIntensity: w),
        ],
      ));

      expect(result.reactions[0].force, closeTo(w * _span / 2, 1e-3));
      expect(result.reactions[1].force, closeTo(w * _span / 2, 1e-3));
      expect(result.maximumHoggingMoment.value,
          closeTo(-w * _span * _span / 12, 1e-3));
      expect(result.maximumSaggingMoment.value,
          closeTo(w * _span * _span / 24, 1e-3));

      final expected = _mm(w * 1000 * math.pow(_span, 4) / (384 * _ei));
      expect(result.maximumDeflection.value, closeTo(expected, expected * 2e-3));
    });

    test('central point load matches PL/8 and PL³/192EI', () {
      const p = 10.0;
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.fixedFixed,
        loads: const [BeamPointLoad(position: _span / 2, magnitude: p)],
      ));

      expect(result.reactions[0].force, closeTo(p / 2, 1e-6));
      expect(result.maximumHoggingMoment.value,
          closeTo(-p * _span / 8, 1e-6));
      expect(result.maximumSaggingMoment.value, closeTo(p * _span / 8, 1e-6));

      final expected = _mm(p * 1000 * math.pow(_span, 3) / (192 * _ei));
      expect(result.maximumDeflection.value, closeTo(expected, expected * 1e-4));
    });
  });

  group('overhang', () {
    test('a load on the tail lifts the far support', () {
      const p = 10.0;
      // Supports at 1 m and 3 m; the load hangs 1 m past the right support.
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.overhang,
        leftSupport: 1,
        rightSupport: 3,
        loads: const [BeamPointLoad(position: _span, magnitude: p)],
      ));

      // ΣM about the right support: RA(2) = −P(1), so the left support pulls
      // down. That uplift is the whole reason an overhang gets checked.
      expect(result.reactions[0].force, closeTo(-p / 2, 1e-6));
      expect(result.reactions[1].force, closeTo(3 * p / 2, 1e-6));
      expect(
          result.reactions[0].force + result.reactions[1].force, closeTo(p, 1e-6));

      // Hogging peaks over the right support at P × overhang.
      expect(result.maximumHoggingMoment.value, closeTo(-p * 1, 1e-6));
      expect(result.maximumHoggingMoment.position, closeTo(3, 1e-6));
      expect(result.isDeterminate, isTrue);
    });
  });

  group('applied couples', () {
    test('an end couple on a simple span turns into a pair of reactions', () {
      const c = 8.0; // kN·m, counter-clockwise
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [BeamAppliedMoment(position: 0, magnitude: c)],
      ));

      expect(result.reactions[0].force, closeTo(c / _span, 1e-6));
      expect(result.reactions[1].force, closeTo(-c / _span, 1e-6));
      // The moment runs linearly from −C at the loaded end to zero at the far
      // one, so the peak is the couple itself.
      expect(result.maximumMoment.value.abs(), closeTo(c, 1e-6));

      // δmax = M L² / (9√3 EI).
      final expected =
          _mm(c * 1000 * _span * _span / (9 * math.sqrt(3) * _ei));
      expect(result.maximumDeflection.value.abs(),
          closeTo(expected, expected * 2e-3));
    });
  });

  group('distributed load shapes', () {
    test('a triangular load matches its closed form on a simple span', () {
      const w = 12.0; // peak intensity at the right end
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [
          BeamDistributedLoad(
              start: 0, end: _span, startIntensity: 0, endIntensity: w),
        ],
      ));

      // A triangle throws a third of its weight at the near support.
      expect(result.reactions[0].force, closeTo(w * _span / 6, 1e-3));
      expect(result.reactions[1].force, closeTo(w * _span / 3, 1e-3));
      // Mmax = wL²/(9√3) at x = L/√3 from the light end.
      expect(result.maximumMoment.value,
          closeTo(w * _span * _span / (9 * math.sqrt(3)), 1e-2));
      expect(result.maximumMoment.position,
          closeTo(_span / math.sqrt(3), 0.03));

      final expected = _mm(0.00652 * w * 1000 * math.pow(_span, 4) / _ei);
      expect(result.maximumDeflection.value, closeTo(expected, expected * 5e-3));
    });

    test('a partial uniform load only loads the length it covers', () {
      const w = 12.0;
      final half = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [
          BeamDistributedLoad(
              start: 0, end: _span / 2, startIntensity: w, endIntensity: w),
        ],
      ));

      // Total load is w × L/2, and it sits on the left half, so the left
      // support takes three quarters of it.
      const total = w * _span / 2;
      expect(half.reactions[0].force + half.reactions[1].force,
          closeTo(total, 1e-3));
      expect(half.reactions[0].force, closeTo(0.75 * total, 1e-3));
    });

    test('a trapezoid puts its resultant where statics says', () {
      const w1 = 6.0;
      const w2 = 18.0;
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [
          BeamDistributedLoad(
              start: 0, end: _span, startIntensity: w1, endIntensity: w2),
        ],
      ));

      // Total load, and the centroid of the trapezoid measured from the light
      // end: x̄ = L(w1 + 2w2) / (3(w1 + w2)).
      const total = (w1 + w2) / 2 * _span;
      const centroid = _span * (w1 + 2 * w2) / (3 * (w1 + w2));
      expect(result.reactions[0].force + result.reactions[1].force,
          closeTo(total, 1e-3));
      expect(result.reactions[1].force,
          closeTo(total * centroid / _span, 1e-3));
    });
  });

  group('bending stress', () {
    test('follows Mc/I from the governing moment', () {
      const p = 10.0;
      const c = 150.0; // mm to the extreme fibre
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [BeamPointLoad(position: _span / 2, magnitude: p)],
        extremeFibre: c,
      ));

      // M = 10 kN·m = 1e7 N·mm; σ = 1e7 × 150 / 1e8 = 15 MPa.
      expect(result.bendingStress, closeTo(15, 1e-6));
    });

    test('is left out when no extreme-fibre distance is given', () {
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [BeamPointLoad(position: _span / 2, magnitude: 10)],
      ));
      expect(result.bendingStress, isNull);
    });
  });

  group('diagrams', () {
    test('shear steps vertically under a point load', () {
      const p = 10.0;
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [BeamPointLoad(position: _span / 2, magnitude: p)],
      ));

      final atMid = result.shear
          .where((point) => (point.x - _span / 2).abs() < 1e-9)
          .toList();
      expect(atMid, hasLength(2));
      expect(atMid.first.value, closeTo(p / 2, 1e-6));
      expect(atMid.last.value, closeTo(-p / 2, 1e-6));
    });

    test('moment closes to zero at a simple support', () {
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.simplySupported,
        loads: const [BeamPointLoad(position: 1, magnitude: 10)],
      ));
      expect(result.moment.first.value, closeTo(0, 1e-6));
      expect(result.moment.last.value, closeTo(0, 1e-6));
      expect(result.deflection.first.value, closeTo(0, 1e-9));
      expect(result.deflection.last.value, closeTo(0, 1e-9));
    });

    test('a fixed end holds both deflection and slope at zero', () {
      final result = BeamSolver.solve(_input(
        supportCase: BeamSupportCase.cantileverLeft,
        loads: const [BeamPointLoad(position: _span, magnitude: 10)],
      ));
      expect(result.deflection.first.value, closeTo(0, 1e-9));
      // The first sampled station is a whole element along, so a zero slope
      // is what keeps it near zero as well.
      expect(result.deflection[1].value.abs(), lessThan(0.01));
    });
  });

  group('rejects what it cannot analyse', () {
    test('a span of zero', () {
      expect(
          () => BeamSolver.solve(_input(
                supportCase: BeamSupportCase.simplySupported,
                span: 0,
                loads: const [BeamPointLoad(position: 0, magnitude: 1)],
              )),
          throwsA(isA<FormatException>()));
    });

    test('no loads at all', () {
      expect(
          () => BeamSolver.solve(_input(
                supportCase: BeamSupportCase.simplySupported,
                loads: const [],
              )),
          throwsA(isA<FormatException>()));
    });

    test('a load hanging past the end of the beam', () {
      expect(
          () => BeamSolver.solve(_input(
                supportCase: BeamSupportCase.simplySupported,
                loads: const [BeamPointLoad(position: _span + 1, magnitude: 5)],
              )),
          throwsA(isA<FormatException>()));
    });

    test('a single simple support, which is a mechanism', () {
      expect(
          () => BeamSolver.solve(const BeamInput(
                span: _span,
                supports: [BeamSupport(0, BeamSupportType.simple)],
                loads: [BeamPointLoad(position: 2, magnitude: 5)],
                elasticModulus: _e,
                secondMoment: _i,
              )),
          throwsA(isA<FormatException>()));
    });

    test('two supports in the same place', () {
      expect(
          () => BeamSolver.solve(const BeamInput(
                span: _span,
                supports: [
                  BeamSupport(1, BeamSupportType.simple),
                  BeamSupport(1, BeamSupportType.simple),
                ],
                loads: [BeamPointLoad(position: 2, magnitude: 5)],
                elasticModulus: _e,
                secondMoment: _i,
              )),
          throwsA(isA<FormatException>()));
    });
  });
}
