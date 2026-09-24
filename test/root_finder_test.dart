import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/solve/root_finder.dart';

void main() {
  test('inverts a power law far from the start', () {
    // σ = 32M/(πd³): what d gives 150 MPa under 1 kN·m?
    double stress(double d) => 32 * 1e6 / (math.pi * d * d * d);
    final outcome = solveForInput(evaluate: stress, target: 150, start: 5);
    expect(outcome.found, isTrue);
    expect(stress(outcome.value!), closeTo(150, 1e-9));
    expect(outcome.value, closeTo(40.79, 0.01));
    expect(outcome.solutionCount, 1);
  });

  test('picks the root nearest the start when there are two', () {
    // (x − 2)(x − 8) = 0 has roots at 2 and 8.
    double f(double x) => (x - 2) * (x - 8);
    expect(solveForInput(evaluate: f, target: 0, start: 3).value,
        closeTo(2, 1e-9));
    final far = solveForInput(evaluate: f, target: 0, start: 7);
    expect(far.value, closeTo(8, 1e-9));
    expect(far.solutionCount, 2);
  });

  test('says what is reachable when the target is not', () {
    // Efficiency-like: never above 1.
    double f(double x) => x / (1 + x);
    final outcome = solveForInput(evaluate: f, target: 1.5, start: 1);
    expect(outcome.found, isFalse);
    expect(outcome.reachableMax, lessThan(1));
    expect(outcome.reachableMin, greaterThan(0));
  });

  test('steps over where the formula is undefined, and ignores poles', () {
    // Undefined below 3; a pole at 10 that flips sign but is not a root.
    double f(double x) {
      if (x < 3) throw const FormatException('undefined');
      return 1 / (x - 10);
    }

    final outcome = solveForInput(evaluate: f, target: 0.5, start: 4);
    expect(outcome.value, closeTo(12, 1e-9));
    expect(outcome.solutionCount, 1);
  });

  test('searches both signs for a signed input', () {
    // A stress that must come out at −40 from a start of +10.
    double f(double x) => 2 * x + 20;
    final outcome =
        solveForInput(evaluate: f, target: -40, start: 10, positive: false);
    expect(outcome.value, closeTo(-30, 1e-9));
  });

  test('starts from zero when the current value is zero', () {
    double f(double x) => 3 * x;
    final outcome =
        solveForInput(evaluate: f, target: 12, start: 0, positive: false);
    expect(outcome.value, closeTo(4, 1e-9));
  });

  test('finds an answer just short of where the formula ends', () {
    // An efficiency-like input, defined only up to 100: the target is met at
    // 97.75, between the last defined sample and the first undefined one.
    double f(double eta) {
      if (eta > 100) throw const FormatException('over 100 %');
      return 2 * eta;
    }

    final outcome = solveForInput(evaluate: f, target: 195.5, start: 85);
    expect(outcome.value, closeTo(97.75, 1e-9));
  });
}
