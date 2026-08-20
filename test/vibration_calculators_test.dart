import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/model/beam_natural_frequency_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/model/shaft_critical_speed_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/vibration/model/torsional_frequency_calculator.dart';

/// One steel beam, reused across the frequency cases: 200 GPa, I = 1e7 mm⁴,
/// A = 1e4 mm², 5 m long, 7850 kg/m³. That makes ρA = 78.5 kg/m and
/// EI = 2e6 N·m², both round enough to check by hand.
BeamNaturalFrequencyResult _steelBeam(BeamEndCondition endCondition) =>
    BeamNaturalFrequencyCalculator.calculate(
      modulusGPa: 200,
      momentOfInertiaMm4: 1e7,
      areaMm2: 1e4,
      lengthM: 5,
      densityKgM3: 7850,
      endCondition: endCondition,
    );

void main() {
  group('BeamNaturalFrequencyCalculator', () {
    test('derives mass per length and EI in SI base units', () {
      final result = _steelBeam(BeamEndCondition.simplySupported);
      expect(result.massPerLength, closeTo(78.5, 1e-9));
      expect(result.flexuralRigidity, closeTo(2e6, 1e-3));
    });

    test('fundamental of a simply supported beam, hand-checked', () {
      final result = _steelBeam(BeamEndCondition.simplySupported);
      // f1 = (π/2)·√(EI/(ρA·L⁴)) = (π/2)·√(2e6/(78.5·625)).
      expect(result.fundamental.frequencyHz, closeTo(10.0291, 1e-3));
      expect(result.fundamental.omegaRadPerS,
          closeTo(2 * math.pi * 10.0291, 1e-2));
      expect(result.fundamental.rpm, closeTo(601.74, 0.1));
    });

    test('a simply supported beam has fn = n²·f1', () {
      final result = _steelBeam(BeamEndCondition.simplySupported);
      final f1 = result.fundamental.frequencyHz;
      expect(result.modes.length, 3);
      for (final mode in result.modes) {
        expect(mode.frequencyHz, closeTo(mode.order * mode.order * f1, 1e-6),
            reason: 'mode ${mode.order}');
      }
    });

    test('end conditions rank as their stiffness does', () {
      double f1(BeamEndCondition c) => _steelBeam(c).fundamental.frequencyHz;
      // A cantilever is the softest of the five and a fixed-fixed beam the
      // stiffest, so their fundamentals bracket the rest.
      expect(f1(BeamEndCondition.cantilever),
          lessThan(f1(BeamEndCondition.simplySupported)));
      expect(f1(BeamEndCondition.simplySupported),
          lessThan(f1(BeamEndCondition.fixedPinned)));
      expect(f1(BeamEndCondition.fixedPinned),
          lessThan(f1(BeamEndCondition.fixedFixed)));
    });

    test('free-free shares the fixed-fixed frequency equation', () {
      expect(_steelBeam(BeamEndCondition.freeFree).fundamental.frequencyHz,
          closeTo(_steelBeam(BeamEndCondition.fixedFixed).fundamental.frequencyHz,
              1e-9));
    });

    test('the fundamental goes as 1/L²', () {
      BeamNaturalFrequencyResult at(double length) =>
          BeamNaturalFrequencyCalculator.calculate(
            modulusGPa: 200,
            momentOfInertiaMm4: 1e7,
            areaMm2: 1e4,
            lengthM: length,
            densityKgM3: 7850,
            endCondition: BeamEndCondition.simplySupported,
          );
      expect(at(10).fundamental.frequencyHz,
          closeTo(at(5).fundamental.frequencyHz / 4, 1e-9));
    });

    test('rejects a non-positive input', () {
      expect(
        () => BeamNaturalFrequencyCalculator.calculate(
          modulusGPa: 200,
          momentOfInertiaMm4: 0,
          areaMm2: 1e4,
          lengthM: 5,
          densityKgM3: 7850,
          endCondition: BeamEndCondition.simplySupported,
        ),
        throwsFormatException,
      );
    });
  });

  group('ShaftCriticalSpeedCalculator', () {
    /// A 50 mm shaft on a 1 m span carrying a 100 kg rotor at midspan.
    ShaftCriticalSpeedResult shaft({
      double position = 0.5,
      ShaftSupport support = ShaftSupport.simplySupported,
      double? density,
    }) =>
        ShaftCriticalSpeedCalculator.calculate(
          modulusGPa: 200,
          diameterMm: 50,
          spanM: 1,
          rotorMassKg: 100,
          rotorPositionM: position,
          support: support,
          densityKgM3: density,
        );

    test('a rotor at midspan reproduces k = 48EI/L³', () {
      final ei = 200e9 * math.pi * math.pow(0.05, 4) / 64;
      expect(shaft().stiffnessNPerM, closeTo(48 * ei, 1e-3));
    });

    test('a rotor at the tip of a cantilever reproduces k = 3EI/L³', () {
      final ei = 200e9 * math.pi * math.pow(0.05, 4) / 64;
      expect(
        shaft(position: 1, support: ShaftSupport.cantilever).stiffnessNPerM,
        closeTo(3 * ei, 1e-6),
      );
    });

    test('a rotor at midspan of a fixed-fixed shaft gives k = 192EI/L³', () {
      final ei = 200e9 * math.pi * math.pow(0.05, 4) / 64;
      expect(
        shaft(support: ShaftSupport.fixedFixed).stiffnessNPerM,
        closeTo(192 * ei, 1e-3),
      );
    });

    test('critical speed and static deflection, hand-checked', () {
      final result = shaft();
      expect(result.criticalFrequencyHz, closeTo(27.3137, 1e-3));
      expect(result.criticalSpeedRpm, closeTo(1638.82, 0.05));
      expect(result.staticDeflectionMm, closeTo(0.33297, 1e-4));
      // Rayleigh's rule of thumb, Nc ≈ 946/√δ with δ in mm.
      expect(result.criticalSpeedRpm,
          closeTo(946 / math.sqrt(result.staticDeflectionMm), 5));
    });

    test('the shaft mass is left out unless a density is given', () {
      final bare = shaft();
      expect(bare.shaftFrequencyHz, isNull);
      expect(bare.shaftMassKg, 0);
      expect(bare.criticalFrequencyHz, closeTo(bare.rotorFrequencyHz, 1e-12));
    });

    test('Dunkerley pulls the critical speed below either contribution', () {
      final result = shaft(density: 7850);
      final shaftFrequency = result.shaftFrequencyHz;
      expect(shaftFrequency, isNotNull);
      expect(result.shaftMassKg, closeTo(15.4134, 1e-3));
      expect(result.criticalFrequencyHz, lessThan(result.rotorFrequencyHz));
      expect(result.criticalFrequencyHz, lessThan(shaftFrequency!));
      expect(result.criticalFrequencyHz, closeTo(26.3320, 1e-3));
    });

    test('an off-centre rotor is carried more stiffly than a central one', () {
      expect(shaft(position: 0.25).stiffnessNPerM,
          greaterThan(shaft().stiffnessNPerM));
    });

    test('rejects a rotor sitting on a support', () {
      expect(() => shaft(position: 0), throwsFormatException);
      expect(() => shaft(position: 1), throwsFormatException);
      expect(() => shaft(position: 1.5), throwsFormatException);
      // A cantilever's far end is free, so a rotor may sit right on it.
      expect(shaft(position: 1, support: ShaftSupport.cantilever).stiffnessNPerM,
          greaterThan(0));
    });
  });

  group('TorsionalFrequencyCalculator', () {
    TorsionalFrequencyResult torsional({
      required TorsionalSystem system,
      double? secondInertia,
    }) =>
        TorsionalFrequencyCalculator.calculate(
          shearModulusGPa: 80,
          diameterMm: 50,
          lengthM: 1,
          firstInertiaKgM2: 1,
          secondInertiaKgM2: secondInertia,
          system: system,
        );

    test('stiffness and frequency of a single rotor, hand-checked', () {
      final result = torsional(system: TorsionalSystem.singleRotor);
      // Jp = πd⁴/32, kt = G·Jp/L.
      expect(result.polarMomentMm4, closeTo(613592.3, 0.1));
      expect(result.stiffnessNmPerRad, closeTo(49087.4, 0.1));
      expect(result.frequencyHz, closeTo(35.2618, 1e-3));
      expect(result.effectiveInertia, 1);
      expect(result.nodeFromFirstRotorM, isNull);
      expect(result.rpm, closeTo(35.2618 * 60, 0.1));
    });

    test('two equal rotors halve the inertia, so ω rises by √2', () {
      final single = torsional(system: TorsionalSystem.singleRotor);
      final pair = torsional(
        system: TorsionalSystem.twoRotor,
        secondInertia: 1,
      );
      expect(pair.effectiveInertia, closeTo(0.5, 1e-12));
      expect(pair.frequencyHz,
          closeTo(single.frequencyHz * math.sqrt2, 1e-9));
      // Equal inertias put the node at the middle of the shaft.
      expect(pair.nodeFromFirstRotorM, closeTo(0.5, 1e-12));
    });

    test('the node sits nearer the heavier rotor', () {
      final result = TorsionalFrequencyCalculator.calculate(
        shearModulusGPa: 80,
        diameterMm: 50,
        lengthM: 1,
        firstInertiaKgM2: 3,
        secondInertiaKgM2: 1,
        system: TorsionalSystem.twoRotor,
      );
      // L·J2/(J1+J2) = 1·1/4 from the heavy rotor.
      expect(result.nodeFromFirstRotorM, closeTo(0.25, 1e-12));
    });

    test('a two-rotor system needs the second inertia', () {
      expect(
        () => torsional(system: TorsionalSystem.twoRotor),
        throwsFormatException,
      );
    });

    test('rejects a non-positive shaft or rotor', () {
      expect(
        () => TorsionalFrequencyCalculator.calculate(
          shearModulusGPa: 80,
          diameterMm: 0,
          lengthM: 1,
          firstInertiaKgM2: 1,
          system: TorsionalSystem.singleRotor,
        ),
        throwsFormatException,
      );
      expect(
        () => TorsionalFrequencyCalculator.calculate(
          shearModulusGPa: 80,
          diameterMm: 50,
          lengthM: 1,
          firstInertiaKgM2: 0,
          system: TorsionalSystem.singleRotor,
        ),
        throwsFormatException,
      );
    });
  });
}
