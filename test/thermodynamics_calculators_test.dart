import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/air_standard_cycle_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/ideal_gas_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/rankine_cycle_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/steam_tables_calculator.dart';

void main() {
  group('steam tables', () {
    test('a saturation row by temperature and by pressure agree', () {
      final byT = SteamTablesCalculator.calculate(const SteamTableInput(
        lookup: SteamLookup.saturatedByTemperature,
        temperatureC: 100,
      ));
      expect(byT.isSaturationRow, isTrue);
      final kPa = byT.saturation!.pressure * 1000;
      final byP = SteamTablesCalculator.calculate(SteamTableInput(
        lookup: SteamLookup.saturatedByPressure,
        pressureKPa: kPa,
      ));
      expect(byP.saturation!.temperature,
          closeTo(byT.saturation!.temperature, 1e-6));
      expect(byP.saturation!.hfg, closeTo(byT.saturation!.hfg, 1e-6));
    });

    test('names the phase the way a table files it', () {
      SteamPhase phase(double kPa, double c) => SteamTablesCalculator.calculate(
            SteamTableInput(
              lookup: SteamLookup.pressureTemperature,
              pressureKPa: kPa,
              temperatureC: c,
            ),
          ).phase!;
      expect(phase(101.325, 20), SteamPhase.compressedLiquid);
      expect(phase(101.325, 150), SteamPhase.superheatedVapour);
      expect(phase(25000, 450), SteamPhase.supercriticalFluid);
      expect(phase(25000, 300), SteamPhase.compressedLiquid);
    });

    test('a throttle keeps enthalpy and lands in the dome', () {
      // Saturated liquid at 1 MPa throttled to 100 kPa flashes to a mixture:
      // x = (hf,1MPa − hf,100kPa) / hfg,100kPa = (762.5 − 417.5) / 2257.5.
      final hf = SteamTablesCalculator.calculate(const SteamTableInput(
        lookup: SteamLookup.saturatedByPressure,
        pressureKPa: 1000,
      )).saturation!.liquid.enthalpy;
      final out = SteamTablesCalculator.calculate(SteamTableInput(
        lookup: SteamLookup.pressureEnthalpy,
        pressureKPa: 100,
        enthalpy: hf,
      ));
      expect(out.phase, SteamPhase.wetMixture);
      expect(out.point!.quality, closeTo(0.1528, 0.001));
    });

    test('reports what is wrong with an unusable input', () {
      SteamInputProblem problem(SteamTableInput input) {
        try {
          SteamTablesCalculator.calculate(input);
        } on SteamInputException catch (e) {
          return e.kind;
        }
        fail('no exception');
      }

      expect(
        problem(const SteamTableInput(lookup: SteamLookup.saturatedByPressure)),
        SteamInputProblem.missingInput,
      );
      expect(
        problem(const SteamTableInput(
            lookup: SteamLookup.saturatedByPressure, pressureKPa: 30000)),
        SteamInputProblem.aboveCriticalForSaturation,
      );
      expect(
        problem(const SteamTableInput(
            lookup: SteamLookup.saturatedByTemperature, temperatureC: 400)),
        SteamInputProblem.temperatureOutOfRange,
      );
      expect(
        problem(const SteamTableInput(
          lookup: SteamLookup.pressureQuality,
          pressureKPa: 100,
          quality: 1.5,
        )),
        SteamInputProblem.qualityOutOfRange,
      );
      expect(
        problem(const SteamTableInput(
          lookup: SteamLookup.pressureTemperature,
          pressureKPa: 200000,
          temperatureC: 300,
        )),
        SteamInputProblem.outsideFormulation,
      );
    });

    test('the dome closes at the critical point', () {
      final dome = SteamTablesCalculator.saturationDome;
      final top = dome.reduce((a, b) => a.t > b.t ? a : b);
      expect(top.t, closeTo(647.096, 0.01));
      expect(dome.first.s, closeTo(0, 0.01)); // liquid at 0.01 °C
      expect(dome.last.s, closeTo(9.155, 0.01)); // vapour at 0.01 °C
    });
  });

  group('ideal gas processes', () {
    const air = IdealGasProcessInput(
      gasConstant: 0.287,
      cp: 1.005,
      p1: 500,
      t1C: 26.85, // 300 K
      mass: 1,
      process: GasProcess.isothermal,
      p2: 100,
    );

    IdealGasProcessResult run(GasProcess process,
            {double? p2, double? t2C, double? n, FinalStateSpec? spec}) =>
        IdealGasCalculator.calculate(IdealGasProcessInput(
          gasConstant: air.gasConstant,
          cp: air.cp,
          p1: air.p1,
          t1C: air.t1C,
          mass: 2,
          process: process,
          spec: spec ?? FinalStateSpec.pressure,
          p2: p2,
          t2C: t2C,
          n: n,
        ));

    test('isothermal expansion: W = mRT·ln(p1/p2) and Q = W', () {
      final r = run(GasProcess.isothermal, p2: 100);
      expect(r.work, closeTo(0.287 * 300 * math.log(5), 1e-9));
      expect(r.heat, closeTo(r.work, 1e-9));
      expect(r.deltaU, closeTo(0, 1e-12));
      expect(r.deltaS, closeTo(0.287 * math.log(5), 1e-9));
      expect(r.volume2, closeTo(2 * 0.287 * 300 / 100, 1e-9));
    });

    test('isentropic expansion: T2 from the pressure ratio, no heat', () {
      final r = run(GasProcess.isentropic, p2: 100);
      const k = 1.005 / (1.005 - 0.287);
      expect(r.t2, closeTo(300 * math.pow(0.2, (k - 1) / k), 1e-9));
      expect(r.heat, closeTo(0, 1e-9));
      expect(r.deltaS, 0);
      expect(r.work, closeTo((1.005 - 0.287) * (300 - r.t2), 1e-9));
    });

    test('isobaric and isochoric heating', () {
      final isobaric = run(GasProcess.isobaric, t2C: 326.85); // to 600 K
      expect(isobaric.p2, 500);
      expect(isobaric.work, closeTo(0.287 * 300, 1e-9));
      expect(isobaric.heat, closeTo(1.005 * 300, 1e-9));

      final isochoric = run(GasProcess.isochoric,
          t2C: 326.85, spec: FinalStateSpec.temperature);
      expect(isochoric.p2, closeTo(1000, 1e-9));
      expect(isochoric.work, 0);
      expect(isochoric.heat, closeTo((1.005 - 0.287) * 300, 1e-9));
    });

    test('polytropic: W = R(T2 − T1)/(1 − n)', () {
      final r = run(GasProcess.polytropic, p2: 100, n: 1.3);
      expect(r.t2, closeTo(300 * math.pow(0.2, 0.3 / 1.3), 1e-9));
      expect(r.work, closeTo(0.287 * (r.t2 - 300) / (1 - 1.3), 1e-9));
      // Heat flows in during a polytropic expansion with 1 < n < k.
      expect(r.heat, greaterThan(0));
      expect(
        () => run(GasProcess.polytropic, p2: 100, n: 1),
        throwsA(isA<IdealGasException>()),
      );
    });

    test('the p–v path runs from state 1 to state 2', () {
      final r = run(GasProcess.isentropic, p2: 100);
      expect(r.path.first.p, closeTo(500, 1e-9));
      expect(r.path.last.p, closeTo(100, 1e-6));
      expect(r.path.last.v, closeTo(r.v2, 1e-9));
    });
  });

  group('air-standard cycles', () {
    test('Otto efficiency is 1 − r^(1−k) whatever the heat added', () {
      final result = AirCycleCalculator.calculate(const AirCycleInput(
        cycle: AirCycle.otto,
        t1C: 16.85, // 290 K
        p1: 95,
        compressionRatio: 8,
        heatAdded: 750,
      ));
      expect(result.efficiency, closeTo(1 - math.pow(8, -0.4), 1e-9));
      expect(result.states[1].t, closeTo(290 * math.pow(8, 0.4), 1e-9));
      expect(result.netWork, closeTo(750 * result.efficiency, 1e-9));
      // Compression and expansion work agree with the heat balance.
      expect(result.expansionWork - result.compressionWork,
          closeTo(result.netWork, 1e-9));
      expect(result.meanEffectivePressure, greaterThan(0));
      // State 4 back to state 1 closes the cycle on the T–s diagram.
      expect(result.ts.last.s, closeTo(0, 1e-9));
    });

    test('Diesel at r = 18, rc = 2 gives the textbook 63 %', () {
      final result = AirCycleCalculator.calculate(const AirCycleInput(
        cycle: AirCycle.diesel,
        t1C: 26.85,
        p1: 95,
        compressionRatio: 18,
        cutoffRatio: 2,
      ));
      final expected =
          1 - math.pow(18, -0.4) * (math.pow(2, 1.4) - 1) / (1.4 * (2 - 1));
      expect(result.efficiency, closeTo(expected, 1e-9));
      expect(result.efficiency, closeTo(0.631, 0.001));
      expect(result.expansionWork - result.compressionWork,
          closeTo(result.netWork, 1e-9));
    });

    test('ideal Brayton efficiency is 1 − rp^((1−k)/k)', () {
      final result = AirCycleCalculator.calculate(const AirCycleInput(
        cycle: AirCycle.brayton,
        t1C: 26.85,
        p1: 100,
        pressureRatio: 8,
        peakTemperatureC: 1026.85, // 1300 K
      ));
      expect(result.efficiency, closeTo(1 - math.pow(8, -0.4 / 1.4), 1e-9));
      expect(result.backWorkRatio, closeTo(
          (result.states[1].t - 300) / (1300 - result.states[3].t), 1e-9));
    });

    test('component losses cost Brayton efficiency', () {
      final ideal = AirCycleCalculator.calculate(const AirCycleInput(
        cycle: AirCycle.brayton,
        t1C: 26.85,
        p1: 100,
        pressureRatio: 8,
        peakTemperatureC: 1026.85,
      ));
      final real = AirCycleCalculator.calculate(const AirCycleInput(
        cycle: AirCycle.brayton,
        t1C: 26.85,
        p1: 100,
        pressureRatio: 8,
        peakTemperatureC: 1026.85,
        compressorEfficiency: 0.8,
        turbineEfficiency: 0.85,
      ));
      expect(real.efficiency, lessThan(ideal.efficiency));
      expect(real.states[1].t, greaterThan(ideal.states[1].t));
      expect(real.states[1].s, greaterThan(0)); // irreversible compression
    });

    test('refuses a cycle that cannot run', () {
      expect(
        () => AirCycleCalculator.calculate(const AirCycleInput(
          cycle: AirCycle.diesel,
          t1C: 20,
          p1: 100,
          compressionRatio: 10,
          cutoffRatio: 12,
        )),
        throwsA(isA<AirCycleException>().having((e) => e.kind, 'kind',
            AirCycleProblem.cutoffNotBelowCompression)),
      );
      expect(
        () => AirCycleCalculator.calculate(const AirCycleInput(
          cycle: AirCycle.brayton,
          t1C: 20,
          p1: 100,
          pressureRatio: 30,
          peakTemperatureC: 300,
        )),
        throwsA(isA<AirCycleException>().having((e) => e.kind, 'kind',
            AirCycleProblem.peakBelowCompression)),
      );
    });
  });

  group('Rankine cycle', () {
    test('Çengel example: 3 MPa, 350 °C, 75 kPa', () {
      final result = RankineCalculator.calculate(const RankineInput(
        boilerPressure: 3000,
        condenserPressure: 75,
        turbineInletC: 350,
      ));
      expect(result.states[0].h, closeTo(384.44, 0.3));
      expect(result.pumpWork, closeTo(3.03, 0.02));
      expect(result.states[2].h, closeTo(3116.1, 0.5));
      expect(result.exitQuality, closeTo(0.8861, 0.001));
      expect(result.heatIn, closeTo(2728.6, 1.0));
      expect(result.heatOut, closeTo(2018.6, 1.0));
      expect(result.netWork, closeTo(710.0, 1.0));
      expect(result.efficiency, closeTo(0.260, 0.001));
      expect(result.netPower, isNull);
    });

    test('turbine losses raise the exit quality and lower efficiency', () {
      final ideal = RankineCalculator.calculate(const RankineInput(
        boilerPressure: 3000,
        condenserPressure: 75,
        turbineInletC: 350,
      ));
      final real = RankineCalculator.calculate(const RankineInput(
        boilerPressure: 3000,
        condenserPressure: 75,
        turbineInletC: 350,
        turbineEfficiency: 0.87,
        pumpEfficiency: 0.85,
        massFlow: 10,
      ));
      expect(real.exitQuality!, greaterThan(ideal.exitQuality!));
      expect(real.efficiency, lessThan(ideal.efficiency));
      expect(real.netPower, closeTo(10 * real.netWork, 1e-9));
    });

    test('saturated vapour at the turbine when no temperature is given', () {
      final result = RankineCalculator.calculate(const RankineInput(
        boilerPressure: 8000,
        condenserPressure: 10,
      ));
      expect(result.states[2].quality, 1);
      expect(result.exitQuality, lessThan(0.8)); // the case superheat avoids
    });

    test('a supercritical boiler needs a turbine inlet temperature', () {
      expect(
        () => RankineCalculator.calculate(const RankineInput(
          boilerPressure: 25000,
          condenserPressure: 10,
        )),
        throwsA(isA<RankineException>()),
      );
      final result = RankineCalculator.calculate(const RankineInput(
        boilerPressure: 25000,
        condenserPressure: 10,
        turbineInletC: 600,
      ));
      expect(result.efficiency, greaterThan(0.4));
    });

    test('refuses an inlet below the boiler saturation temperature', () {
      expect(
        () => RankineCalculator.calculate(const RankineInput(
          boilerPressure: 3000,
          condenserPressure: 75,
          turbineInletC: 200,
        )),
        throwsA(isA<RankineException>().having((e) => e.kind, 'kind',
            RankineProblem.inletNotSuperheated)),
      );
    });

    test('the T–s path is closed and starts at the pump inlet', () {
      final result = RankineCalculator.calculate(const RankineInput(
        boilerPressure: 3000,
        condenserPressure: 75,
        turbineInletC: 350,
      ));
      expect(result.cyclePath.first.s, closeTo(result.states[0].s, 1e-12));
      expect(result.cyclePath.last.s, closeTo(result.states[0].s, 1e-12));
      expect(result.cyclePath.length, greaterThan(20));
    });
  });
}
