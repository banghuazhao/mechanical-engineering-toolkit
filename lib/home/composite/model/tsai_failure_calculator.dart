import 'dart:math' as math;

class TsaiFailureInput {
  const TsaiFailureInput({
    required this.sigma1,
    required this.sigma2,
    required this.tau12,
    required this.xt,
    required this.xc,
    required this.yt,
    required this.yc,
    required this.s,
  });

  /// Lamina stresses in material axes, MPa.
  final double sigma1;
  final double sigma2;
  final double tau12;

  /// Lamina strengths, MPa — all positive magnitudes.
  final double xt; // fiber-direction tensile
  final double xc; // fiber-direction compressive
  final double yt; // transverse tensile
  final double yc; // transverse compressive
  final double s; // in-plane shear
}

class TsaiFailureResult {
  const TsaiFailureResult({
    required this.tsaiHillIndex,
    required this.tsaiWuIndex,
    required this.tsaiWuStrengthRatio,
  });

  /// Tsai-Hill failure index; the lamina is predicted safe if this is < 1.
  final double tsaiHillIndex;

  /// Tsai-Wu failure index; the lamina is predicted safe if this is < 1.
  final double tsaiWuIndex;

  /// Tsai-Wu strength ratio R (load can scale by this factor before
  /// failure, per the Tsai-Wu quadratic) — null if it can't be solved
  /// (all stress components zero).
  final double? tsaiWuStrengthRatio;
}

/// Tsai-Hill and Tsai-Wu lamina failure criteria for a plane-stress state
/// in material axes. The Tsai-Wu interaction term F12 uses the common
/// simplified default -0.5·sqrt(F11·F22) (no biaxial test data assumed).
abstract final class TsaiFailureCalculator {
  static TsaiFailureResult calculate(TsaiFailureInput input) {
    final s1 = input.sigma1;
    final s2 = input.sigma2;
    final t12 = input.tau12;
    final xt = input.xt;
    final xc = input.xc;
    final yt = input.yt;
    final yc = input.yc;
    final s = input.s;

    if (xt <= 0 || xc <= 0 || yt <= 0 || yc <= 0 || s <= 0) {
      throw const FormatException('All strengths must be positive.');
    }

    // Tsai-Hill: pick tensile or compressive strength by stress sign.
    final x = s1 >= 0 ? xt : xc;
    final y = s2 >= 0 ? yt : yc;
    final tsaiHill = (s1 * s1) / (x * x) -
        (s1 * s2) / (x * x) +
        (s2 * s2) / (y * y) +
        (t12 * t12) / (s * s);

    // Tsai-Wu.
    final f1 = 1 / xt - 1 / xc;
    final f2 = 1 / yt - 1 / yc;
    final f11 = 1 / (xt * xc);
    final f22 = 1 / (yt * yc);
    final f66 = 1 / (s * s);
    final f12 = -0.5 * math.sqrt(f11 * f22);

    final a =
        f11 * s1 * s1 + f22 * s2 * s2 + f66 * t12 * t12 + 2 * f12 * s1 * s2;
    final b = f1 * s1 + f2 * s2;
    final tsaiWu = b + a;

    double? strengthRatio;
    if (a != 0) {
      strengthRatio = (-b + math.sqrt(b * b + 4 * a)) / (2 * a);
    } else if (b != 0) {
      strengthRatio = 1 / b;
    }

    return TsaiFailureResult(
      tsaiHillIndex: tsaiHill,
      tsaiWuIndex: tsaiWu,
      tsaiWuStrengthRatio: strengthRatio,
    );
  }
}
