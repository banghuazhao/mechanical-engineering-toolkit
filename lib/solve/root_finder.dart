import 'dart:math' as math;

/// What [solveForInput] found.
class SolveOutcome {
  const SolveOutcome({
    this.value,
    this.achieved,
    this.solutionCount = 0,
    this.reachableMin,
    this.reachableMax,
  });

  /// The input that gives the target, or null when none was found.
  final double? value;

  /// The output at [value] — the target, to within the solver's tolerance.
  final double? achieved;

  /// How many separate solutions the scan crossed. More than one means
  /// [value] is the one nearest the starting value, not the only one.
  final int solutionCount;

  /// The smallest and largest output seen across the scan, so a target that
  /// cannot be reached can be answered with what can.
  final double? reachableMin, reachableMax;

  bool get found => value != null;
}

/// Finds the input x at which [evaluate] returns [target], starting from
/// [start] — the value the calculation was just run with.
///
/// Engineering formulas are neither linear nor, in general, monotonic, and
/// they are often undefined over part of the line (a negative diameter, an
/// efficiency above one), so a single Newton step from [start] is not safe.
/// Instead the function is sampled across twelve decades around [start]
/// — geometrically, since a diameter that is off is off by a factor, not by
/// a millimetre — and every sign change of `evaluate(x) − target` between
/// neighbouring samples is refined with Brent's method. Samples where the
/// formula throws or returns a non-finite number are skipped, and a bracket
/// is never drawn across one; where the formula stops being defined between
/// two samples, the edge itself is found and sampled, so an answer just
/// short of a limit is not lost. A sign change that refines to a large residual
/// is a pole, not a root, and is discarded.
///
/// When several roots exist the one nearest [start] wins, which is almost
/// always the one the user means: a solution in the neighbourhood of the
/// design they already have.
///
/// [positive] confines the search to x > 0, which is the domain of nearly
/// every dimension, load and property. When it is false the scan spreads
/// both ways from [start] instead.
SolveOutcome solveForInput({
  required double Function(double x) evaluate,
  required double target,
  required double start,
  bool positive = true,
}) {
  double? residual(double x) {
    try {
      final y = evaluate(x);
      return y.isFinite ? y - target : null;
    } catch (_) {
      return null;
    }
  }

  final grid = <double>[];
  final values = <double?>[];
  final coarse = positive ? _positiveGrid(start) : _signedGrid(start);
  final coarseValues = [for (final x in coarse) residual(x)];
  for (var i = 0; i < coarse.length; i++) {
    grid.add(coarse[i]);
    values.add(coarseValues[i]);
    // Where the formula stops being defined between two samples — an
    // efficiency reaching 100 %, a bore reaching the outside diameter — the
    // answer can sit in the sliver just short of the edge, where no sample
    // falls. Find the edge and sample right at it.
    if (i + 1 >= coarse.length) continue;
    final here = coarseValues[i], next = coarseValues[i + 1];
    if ((here == null) == (next == null)) continue;
    final edge = _domainEdge(residual, coarse[i], coarse[i + 1],
        definedAtStart: here != null);
    final value = residual(edge);
    if (value == null) continue;
    grid.add(edge);
    values.add(value);
  }

  double? low, high;
  for (final r in values) {
    if (r == null) continue;
    final y = r + target;
    low = low == null ? y : math.min(low, y);
    high = high == null ? y : math.max(high, y);
  }

  // How close counts as hitting the target: relative to the target where it
  // is not zero, and to the scale of the outputs seen where it is.
  final scale = math.max(
    target.abs(),
    math.max(low?.abs() ?? 0, high?.abs() ?? 0) * 1e-3,
  );
  final tolerance = math.max(scale * 1e-7, 1e-300);

  final roots = <double>[];
  for (var i = 0; i < grid.length; i++) {
    final r = values[i];
    if (r == null) continue;
    if (r == 0) {
      roots.add(grid[i]);
      continue;
    }
    if (i + 1 >= grid.length) continue;
    final next = values[i + 1];
    if (next == null || next == 0 || (r < 0) == (next < 0)) continue;
    final root = _brent(residual, grid[i], grid[i + 1], r, next);
    if (root == null) continue;
    final check = residual(root);
    // A sign flip across a pole — 1/(x − a), say — refines to a point where
    // the function is huge, not where it meets the target.
    if (check == null || check.abs() > tolerance * 1e3) continue;
    roots.add(root);
  }

  if (roots.isEmpty) {
    return SolveOutcome(reachableMin: low, reachableMax: high);
  }

  double distance(double x) => positive && start > 0
      ? (math.log(x) - math.log(start)).abs()
      : (x - start).abs();
  roots.sort((a, b) => distance(a).compareTo(distance(b)));
  final best = roots.first;
  return SolveOutcome(
    value: best,
    achieved: residual(best)! + target,
    solutionCount: roots.length,
    reachableMin: low,
    reachableMax: high,
  );
}

/// The last point between [a] and [b] where [f] is still defined, approached
/// from the defined end by bisecting on definedness.
double _domainEdge(
  double? Function(double x) f,
  double a,
  double b, {
  required bool definedAtStart,
}) {
  var inside = definedAtStart ? a : b;
  var outside = definedAtStart ? b : a;
  for (var i = 0; i < 60; i++) {
    final mid = (inside + outside) / 2;
    if (mid == inside || mid == outside) break;
    if (f(mid) == null) {
      outside = mid;
    } else {
      inside = mid;
    }
  }
  return inside;
}

/// 1e-6× to 1e6× [start], forty samples per decade.
List<double> _positiveGrid(double start) {
  final base = start > 0 && start.isFinite ? start : 1.0;
  return [
    for (var k = -240; k <= 240; k++) base * math.pow(10, k / 40).toDouble(),
  ];
}

/// [start] plus and minus offsets from a millionth of its size to a million
/// times it, sorted.
List<double> _signedGrid(double start) {
  final base = start.isFinite ? start : 0.0;
  final unit = base.abs() > 0 ? base.abs() : 1.0;
  final offsets = [
    for (var k = -240; k <= 240; k++) unit * math.pow(10, k / 40).toDouble(),
  ];
  return [
    for (final d in offsets.reversed) base - d,
    base,
    for (final d in offsets) base + d,
  ];
}

/// Brent's method on [a, b], where [fa] and [fb] bracket a root. Null if the
/// function becomes undefined inside the bracket.
double? _brent(
  double? Function(double x) f,
  double a,
  double b,
  double fa,
  double fb,
) {
  const maxIterations = 200;
  var c = a, fc = fa;
  var d = b - a, e = d;
  for (var i = 0; i < maxIterations; i++) {
    if ((fb > 0) == (fc > 0)) {
      c = a;
      fc = fa;
      d = b - a;
      e = d;
    }
    if (fc.abs() < fb.abs()) {
      a = b;
      b = c;
      c = a;
      fa = fb;
      fb = fc;
      fc = fa;
    }
    final tol = 2 * 2.2e-16 * b.abs() + 1e-300;
    final m = (c - b) / 2;
    if (m.abs() <= tol || fb == 0) return b;
    if (e.abs() >= tol && fa.abs() > fb.abs()) {
      final s = fb / fa;
      double p, q;
      if (a == c) {
        p = 2 * m * s;
        q = 1 - s;
      } else {
        final qa = fa / fc, r = fb / fc;
        p = s * (2 * m * qa * (qa - r) - (b - a) * (r - 1));
        q = (qa - 1) * (r - 1) * (s - 1);
      }
      if (p > 0) {
        q = -q;
      } else {
        p = -p;
      }
      if (2 * p < math.min(3 * m * q - (tol * q).abs(), (e * q).abs())) {
        e = d;
        d = p / q;
      } else {
        d = m;
        e = d;
      }
    } else {
      d = m;
      e = d;
    }
    a = b;
    fa = fb;
    b += d.abs() > tol ? d : (m > 0 ? tol : -tol);
    final next = f(b);
    if (next == null) return null;
    fb = next;
  }
  return b;
}
