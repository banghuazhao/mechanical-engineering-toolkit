import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/mechancs_of_material/model/principal_stress_calculator.dart';

void main() {
  group('PrincipalStressCalculator', () {
    test('classic textbook plane-stress state', () {
      // sigmaX = 100, sigmaY = -40, tauXY = 25 (MPa) is a standard
      // Mechanics-of-Materials textbook example: sigma1 ~= 104.3 MPa,
      // sigma2 ~= -44.3 MPa, thetaP ~= 9.8 deg.
      final result = PrincipalStressCalculator.calculate(
        sigmaX: 100,
        sigmaY: -40,
        tauXY: 25,
      );

      expect(result.sigmaAvg, 30);
      expect(result.sigma1, closeTo(104.33, 0.01));
      expect(result.sigma2, closeTo(-44.33, 0.01));
      expect(result.tauMax, closeTo(74.33, 0.01));
      expect(result.thetaP, closeTo(9.83, 0.01));
      expect(result.thetaS, closeTo(9.83 - 45, 0.01));
    });

    test('sigma1 + sigma2 == sigmaX + sigmaY (invariant)', () {
      final result = PrincipalStressCalculator.calculate(
        sigmaX: 60,
        sigmaY: -20,
        tauXY: -15,
      );
      expect(result.sigma1 + result.sigma2, closeTo(60 + -20, 1e-9));
    });

    test('pure shear (sigmaX = sigmaY = 0) gives sigma1 = -sigma2 = tauXY',
        () {
      final result = PrincipalStressCalculator.calculate(
        sigmaX: 0,
        sigmaY: 0,
        tauXY: 40,
      );
      expect(result.sigma1, closeTo(40, 1e-9));
      expect(result.sigma2, closeTo(-40, 1e-9));
      expect(result.thetaP, closeTo(45, 1e-9));
    });
  });
}
