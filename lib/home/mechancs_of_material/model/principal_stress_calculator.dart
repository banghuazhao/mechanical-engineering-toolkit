import 'dart:math';

class PrincipalStressResult {
  const PrincipalStressResult({
    required this.sigmaAvg,
    required this.sigma1,
    required this.sigma2,
    required this.tauMax,
    required this.thetaP,
    required this.thetaS,
  });

  /// Center of Mohr's circle, (σx + σy) / 2.
  final double sigmaAvg;

  /// Maximum principal (normal) stress.
  final double sigma1;

  /// Minimum principal (normal) stress.
  final double sigma2;

  /// Radius of Mohr's circle; also the maximum in-plane shear stress.
  final double tauMax;

  /// Angle (degrees) from the x-axis to the principal plane.
  final double thetaP;

  /// Angle (degrees) from the x-axis to the maximum-shear plane.
  final double thetaS;
}

/// Plane-stress transformation: principal stresses, maximum in-plane shear,
/// and their orientations, from a stress state (σx, σy, τxy).
abstract final class PrincipalStressCalculator {
  static PrincipalStressResult calculate({
    required double sigmaX,
    required double sigmaY,
    required double tauXY,
  }) {
    final sigmaAvg = (sigmaX + sigmaY) / 2;
    final r = sqrt(pow((sigmaX - sigmaY) / 2, 2) + pow(tauXY, 2));
    final thetaP = 0.5 * atan2(2 * tauXY, sigmaX - sigmaY) * 180 / pi;
    return PrincipalStressResult(
      sigmaAvg: sigmaAvg,
      sigma1: sigmaAvg + r,
      sigma2: sigmaAvg - r,
      tauMax: r,
      thetaP: thetaP,
      thetaS: thetaP - 45,
    );
  }
}
