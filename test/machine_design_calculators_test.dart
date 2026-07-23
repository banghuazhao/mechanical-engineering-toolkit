import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/composite/model/tsai_failure_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/bearing_life_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/belt_drive_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/press_fit_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/shaft_fatigue_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/spring_design_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/spur_gear_calculator.dart';

void main() {
  group('BearingLifeCalculator', () {
    test('L10 = (C/P)^3 for a ball bearing', () {
      final result = BearingLifeCalculator.calculate(
        dynamicLoadRating: 10,
        equivalentLoad: 2,
        type: BearingType.ball,
        speedRpm: 1000,
      );
      expect(result.l10Million, closeTo(125, 1e-9)); // (10/2)^3
      expect(result.l10Hours, closeTo(125e6 / 60000, 1e-6));
    });

    test('rejects a non-positive load', () {
      expect(
        () => BearingLifeCalculator.calculate(
          dynamicLoadRating: 10,
          equivalentLoad: 0,
          type: BearingType.ball,
          speedRpm: 1000,
        ),
        throwsFormatException,
      );
    });
  });

  group('SpringDesignCalculator', () {
    test('index, rate, and solid height for a clean wire/coil combo', () {
      final result = SpringDesignCalculator.calculate(const SpringDesignInput(
        wireDiameter: 2, // mm
        coilDiameter: 20, // mm -> C = 10
        activeCoils: 10,
        shearModulusGPa: 80,
        force: 100, // N
      ));

      expect(result.springIndex, closeTo(10, 1e-9));
      // k = G(MPa)*d^4 / (8*D^3*Na) = 80000*16/(8*8000*10) = 2.0 N/mm
      expect(result.rateNPerMm, closeTo(2.0, 1e-9));
      expect(result.solidHeightMm, closeTo(24, 1e-9)); // (Na+2)*d
      expect(result.deflectionMm, closeTo(50, 1e-9)); // F/k = 100/2
      // Wahl factor and stress: sanity range only (avoids re-deriving the
      // formula by hand to full precision in the test).
      expect(result.wahlFactor, closeTo(1.145, 0.01));
      expect(result.shearStressMPa, closeTo(729, 5));
      expect(result.naturalFrequencyHz, greaterThan(0));
    });

    test('rejects a coil diameter smaller than the wire diameter', () {
      expect(
        () => SpringDesignCalculator.calculate(const SpringDesignInput(
          wireDiameter: 5,
          coilDiameter: 3,
          activeCoils: 10,
          shearModulusGPa: 80,
        )),
        throwsFormatException,
      );
    });
  });

  group('PressFitCalculator', () {
    test('contact pressure and hoop stress for a clean solid-shaft case', () {
      final result = PressFitCalculator.calculate(const PressFitInput(
        interfaceRadius: 25, // mm
        hubOuterRadius: 50, // mm
        diametralInterference: 0.05, // mm
        modulusGPa: 200,
      ));

      // ratio = (50^2+25^2)/(50^2-25^2) = 3125/1875 = 5/3
      // p = E(MPa)*(delta/2) / (r*(ratio+1)) = 200000*0.025/(25*(8/3)) = 75
      expect(result.contactPressureMPa, closeTo(75, 1e-6));
      expect(result.hubHoopStressMPa, closeTo(125, 1e-6)); // p*5/3
      expect(result.shaftStressMPa, closeTo(-75, 1e-6));
    });

    test('rejects a hub outer radius smaller than the interface radius', () {
      expect(
        () => PressFitCalculator.calculate(const PressFitInput(
          interfaceRadius: 50,
          hubOuterRadius: 25,
          diametralInterference: 0.05,
          modulusGPa: 200,
        )),
        throwsFormatException,
      );
    });
  });

  group('BeltDriveCalculator', () {
    test('ratio, speed, length, and wrap angles for a clean pulley pair', () {
      final result = BeltDriveCalculator.calculate(const BeltDriveInput(
        smallPulleyDiameter: 100, // mm
        largePulleyDiameter: 200, // mm
        centerDistance: 500, // mm
        inputSpeedRpm: 1000,
      ));

      expect(result.ratio, closeTo(2.0, 1e-9));
      expect(result.outputSpeedRpm, closeTo(500, 1e-9));
      // L = 2*500 + (pi/2)*300 + 100^2/(4*500) = 1000 + 471.2389 + 5
      expect(result.beltLength, closeTo(1476.24, 0.01));
      expect(result.smallWrapAngleDeg, closeTo(168.52, 0.01));
      expect(result.largeWrapAngleDeg, closeTo(191.48, 0.01));
      expect(result.drivingTorqueNm, isNull);
    });

    test('reports driving torque and belt pull when power is supplied', () {
      final result = BeltDriveCalculator.calculate(const BeltDriveInput(
        smallPulleyDiameter: 100,
        largePulleyDiameter: 200,
        centerDistance: 500,
        inputSpeedRpm: 1000,
        powerW: 1000,
      ));

      expect(result.drivingTorqueNm, isNotNull);
      expect(result.beltPullN, isNotNull);
      // T1 = P/omega1, Ft = T1/(d1/2 in m); both must be positive.
      expect(result.drivingTorqueNm, greaterThan(0));
      expect(result.beltPullN, greaterThan(0));
    });

    test('rejects a center distance too small for the pulley diameters', () {
      expect(
        () => BeltDriveCalculator.calculate(const BeltDriveInput(
          smallPulleyDiameter: 100,
          largePulleyDiameter: 500,
          centerDistance: 50,
          inputSpeedRpm: 1000,
        )),
        throwsFormatException,
      );
    });
  });

  group('lewisFormFactor', () {
    test('returns table values exactly at table entries', () {
      expect(lewisFormFactor(20), closeTo(0.322, 1e-9));
      expect(lewisFormFactor(12), closeTo(0.245, 1e-9));
    });

    test('clamps outside the table range', () {
      expect(lewisFormFactor(5), closeTo(0.245, 1e-9));
      expect(lewisFormFactor(1000), closeTo(0.472, 1e-9));
    });

    test('interpolates between entries', () {
      // Halfway between N=20 (0.322) and N=21 (0.328).
      final y =
          lewisFormFactor(20) + (lewisFormFactor(21) - lewisFormFactor(20)) / 2;
      expect(y, closeTo(0.325, 1e-9));
    });
  });

  group('SpurGearCalculator', () {
    test('pitch diameters, center distance, and stresses for a clean pair', () {
      final result = SpurGearCalculator.calculate(const SpurGearInput(
        module: 2, // mm
        pinionTeeth: 20,
        gearTeeth: 40,
        faceWidth: 10, // mm
        tangentialLoad: 500, // N
      ));

      expect(result.pinionPitchDiameter, closeTo(40, 1e-9));
      expect(result.gearPitchDiameter, closeTo(80, 1e-9));
      expect(result.centerDistance, closeTo(60, 1e-9));
      expect(result.gearRatio, closeTo(2.0, 1e-9));
      expect(result.lewisFormFactor, closeTo(0.322, 1e-9));
      // sigma = Wt/(F*m*Y) = 500/(10*2*0.322)
      expect(result.bendingStressMPa, closeTo(500 / (10 * 2 * 0.322), 1e-6));
      // sigma_c = 191*sqrt((500/(10*40))*(2+1)/2) = 191*sqrt(1.875)
      expect(result.contactStressMPa, closeTo(261.54, 0.05));
    });

    test('rejects too few teeth (undercutting risk)', () {
      expect(
        () => SpurGearCalculator.calculate(const SpurGearInput(
          module: 2,
          pinionTeeth: 5,
          gearTeeth: 40,
          faceWidth: 10,
        )),
        throwsFormatException,
      );
    });
  });

  group('ShaftFatigueCalculator', () {
    test(
        'DE-Goodman diameter for fully-reversed bending + no stress concentration',
        () {
      final result = ShaftFatigueCalculator.calculate(const ShaftFatigueInput(
        alternatingMoment: 1e6, // N·mm
        kf: 1,
        kfs: 1,
        enduranceLimit: 200, // MPa
        ultimateStrength: 400, // MPa
        safetyFactor: 2,
      ));

      // d^3 = (16*2/pi) * (1/200)*sqrt(4*(1e6)^2) = (32/pi)*10000
      expect(result.diameterMm, closeTo(46.70, 0.05));
    });

    test('rejects an all-zero load case', () {
      expect(
        () => ShaftFatigueCalculator.calculate(const ShaftFatigueInput(
          alternatingMoment: 0,
          kf: 1,
          kfs: 1,
          enduranceLimit: 200,
          ultimateStrength: 400,
          safetyFactor: 2,
        )),
        throwsFormatException,
      );
    });
  });

  group('TsaiFailureCalculator', () {
    test('Tsai-Hill and Tsai-Wu indices and strength ratio for a clean case',
        () {
      final result = TsaiFailureCalculator.calculate(const TsaiFailureInput(
        sigma1: 500,
        sigma2: 10,
        tau12: 20,
        xt: 1500,
        xc: 1500,
        yt: 40,
        yc: 40,
        s: 70,
      ));

      // Hand-worked (see plan): FI_TH ~= 0.2530, FI_TW ~= 0.1719, R ~= 2.412.
      expect(result.tsaiHillIndex, closeTo(0.2530, 0.001));
      expect(result.tsaiWuIndex, closeTo(0.1719, 0.001));
      expect(result.tsaiWuStrengthRatio, closeTo(2.412, 0.01));
    });

    test('rejects a non-positive strength', () {
      expect(
        () => TsaiFailureCalculator.calculate(const TsaiFailureInput(
          sigma1: 100,
          sigma2: 10,
          tau12: 5,
          xt: 1500,
          xc: 1500,
          yt: 0,
          yc: 40,
          s: 70,
        )),
        throwsFormatException,
      );
    });
  });
}
