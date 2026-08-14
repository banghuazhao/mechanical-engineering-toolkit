import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/heat_transfer_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/fluids_thermal/model/pipe_flow_calculator.dart';
import 'package:mechanical_engineering_toolkit/util/fluid_library.dart';
import 'package:mechanical_engineering_toolkit/util/thermal_material_library.dart';

/// Node labels are supplied by the caller so the model carries no English;
/// the tests pass fixed ones and assert on positions rather than wording.
const _labels = (
  inside: 'inside',
  outside: 'outside',
  surface: 'surface',
  interface: 'interface',
);

CompositeWallResult _wall({
  required List<WallLayer> layers,
  double area = 1,
  double inside = 20,
  double outside = 0,
  double? hIn,
  double? hOut,
}) =>
    CompositeWallCalculator.calculate(
      layers: layers,
      area: area,
      insideTemperature: inside,
      outsideTemperature: outside,
      insideLabel: _labels.inside,
      outsideLabel: _labels.outside,
      surfaceLabel: _labels.surface,
      interfaceLabel: _labels.interface,
      insideCoefficient: hIn,
      outsideCoefficient: hOut,
    );

void main() {
  group('reynoldsNumber', () {
    test('matches a hand-computed Re for water in a 50 mm pipe', () {
      // ρ=998.2, V=2 m/s, D=0.05 m, μ=1.002e-3 -> Re = 99621...
      final re = reynoldsNumber(
        velocity: 2,
        diameter: 0.05,
        density: 998.2,
        viscosity: 1.002e-3,
      );
      expect(re, closeTo(998.2 * 2 * 0.05 / 1.002e-3, 1e-6));
      expect(re, closeTo(99620.8, 1));
    });

    test('is sign-insensitive: reversing the flow does not change Re', () {
      final forward = reynoldsNumber(
          velocity: 2, diameter: 0.05, density: 998.2, viscosity: 1e-3);
      final backward = reynoldsNumber(
          velocity: -2, diameter: 0.05, density: 998.2, viscosity: 1e-3);
      expect(backward, closeTo(forward, 1e-9));
    });

    test('rejects a non-positive viscosity', () {
      expect(
        () => reynoldsNumber(
            velocity: 1, diameter: 0.05, density: 998, viscosity: 0),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('regimeFor', () {
    test('splits at the conventional 2300 and 4000', () {
      expect(regimeFor(1000), FlowRegime.laminar);
      expect(regimeFor(2299), FlowRegime.laminar);
      expect(regimeFor(3000), FlowRegime.transitional);
      expect(regimeFor(5000), FlowRegime.turbulent);
    });
  });

  group('darcyFrictionFactor', () {
    test('laminar flow is exactly 64/Re', () {
      expect(darcyFrictionFactor(reynolds: 1000, relativeRoughness: 0),
          closeTo(0.064, 1e-12));
      expect(darcyFrictionFactor(reynolds: 2000, relativeRoughness: 0.01),
          closeTo(0.032, 1e-12),
          reason: 'roughness must not affect laminar friction');
    });

    test('the Colebrook root actually satisfies Colebrook', () {
      // The real check on an iterative solver: put the answer back into the
      // equation it is supposed to solve and see if it balances.
      for (final re in [5e3, 1e4, 1e5, 1e6, 1e8]) {
        for (final rr in [0.0, 1e-5, 1e-4, 1e-3, 5e-2]) {
          final f = darcyFrictionFactor(reynolds: re, relativeRoughness: rr);
          final lhs = 1 / math.sqrt(f);
          final rhs = -2 *
              (math.log(rr / 3.7 + 2.51 / (re * math.sqrt(f))) / math.ln10);
          expect(lhs, closeTo(rhs, 1e-9),
              reason: 'Colebrook not satisfied at Re=$re, e/D=$rr');
        }
      }
    });

    test('smooth-pipe turbulent friction lands on the Moody chart', () {
      // Classic reference points for a hydraulically smooth pipe.
      expect(darcyFrictionFactor(reynolds: 1e5, relativeRoughness: 0),
          closeTo(0.0180, 5e-4));
      expect(darcyFrictionFactor(reynolds: 1e6, relativeRoughness: 0),
          closeTo(0.0116, 5e-4));
    });

    test('a rough pipe reaches its fully-rough plateau', () {
      // At high Re the Reynolds term drops out and f depends on ε/D alone.
      final at1e7 = darcyFrictionFactor(reynolds: 1e7, relativeRoughness: 0.01);
      final at1e9 = darcyFrictionFactor(reynolds: 1e9, relativeRoughness: 0.01);
      expect(at1e9, closeTo(at1e7, 5e-4));
      expect(at1e9, closeTo(0.0380, 1e-3));
    });

    test('friction rises with roughness and falls with Reynolds number', () {
      expect(darcyFrictionFactor(reynolds: 1e5, relativeRoughness: 1e-3),
          greaterThan(darcyFrictionFactor(reynolds: 1e5, relativeRoughness: 0)));
      expect(darcyFrictionFactor(reynolds: 1e6, relativeRoughness: 1e-4),
          lessThan(darcyFrictionFactor(reynolds: 1e4, relativeRoughness: 1e-4)));
    });
  });

  group('PipeFlowCalculator', () {
    PipeFlowInput input({
      double diameter = 50,
      double length = 100,
      double flowRate = 3.927,
      double density = 998.2,
      double viscosity = 1.002e-3,
      double roughness = 0.045,
      double minorLossK = 0,
    }) =>
        PipeFlowInput(
          diameter: diameter,
          length: length,
          flowRate: flowRate,
          density: density,
          viscosity: viscosity,
          roughness: roughness,
          minorLossK: minorLossK,
        );

    test('velocity follows from flow rate and bore', () {
      // Q = 3.927 L/s through a 50 mm bore (A = 1963.5 mm²) is ~2 m/s.
      final result = PipeFlowCalculator.calculate(input());
      expect(result.velocity, closeTo(2.0, 1e-3));
    });

    test('head loss matches a hand-worked Darcy-Weisbach', () {
      final result = PipeFlowCalculator.calculate(input());
      final expected = result.frictionFactor *
          (100 / 0.05) *
          math.pow(result.velocity, 2) /
          (2 * gravity);
      expect(result.frictionHeadLoss, closeTo(expected, 1e-9));

      // Water at 2 m/s through 100 m of 50 mm commercial steel (ε = 0.045 mm,
      // so ε/D = 9.0e-4) runs at Re = 99621. Substituting the root f = 0.02184
      // back into Colebrook by hand: √f = 0.147783, and
      //   -2·log₁₀(9.0e-4/3.7 + 2.51/(99621·0.147783)) = 6.7668 = 1/√f.
      expect(result.reynolds, closeTo(99621, 1));
      expect(result.frictionFactor, closeTo(0.02184, 1e-5));
      expect(result.frictionHeadLoss, closeTo(8.91, 0.01));
    });

    test('pressure drop is rho*g*h in kPa', () {
      final result = PipeFlowCalculator.calculate(input());
      expect(
        result.pressureDrop,
        closeTo(998.2 * gravity * result.totalHeadLoss / 1000, 1e-9),
      );
    });

    test('minor losses add K velocity heads on top of the pipe loss', () {
      final without = PipeFlowCalculator.calculate(input());
      final with3 = PipeFlowCalculator.calculate(input(minorLossK: 3));
      expect(with3.minorHeadLoss, closeTo(3 * without.velocityHead, 1e-9));
      expect(
        with3.totalHeadLoss,
        closeTo(without.frictionHeadLoss + 3 * without.velocityHead, 1e-9),
      );
      // Major loss itself is untouched by the fittings.
      expect(with3.frictionHeadLoss, closeTo(without.frictionHeadLoss, 1e-12));
    });

    test('head loss scales with length at fixed velocity', () {
      final short = PipeFlowCalculator.calculate(input(length: 50));
      final long = PipeFlowCalculator.calculate(input(length: 200));
      expect(long.frictionHeadLoss, closeTo(4 * short.frictionHeadLoss, 1e-9));
    });

    test('viscous oil runs laminar where water runs turbulent', () {
      final water = PipeFlowCalculator.calculate(input());
      expect(water.regime, FlowRegime.turbulent);
      final oil = PipeFlowCalculator.calculate(
          input(density: 888.1, viscosity: 0.8374));
      expect(oil.regime, FlowRegime.laminar);
      expect(oil.frictionFactor, closeTo(64 / oil.reynolds, 1e-12));
    });

    test('rejects impossible geometry and fluid properties', () {
      expect(() => PipeFlowCalculator.calculate(input(diameter: 0)),
          throwsA(isA<FormatException>()));
      expect(() => PipeFlowCalculator.calculate(input(flowRate: 0)),
          throwsA(isA<FormatException>()));
      expect(() => PipeFlowCalculator.calculate(input(density: -1)),
          throwsA(isA<FormatException>()));
      expect(() => PipeFlowCalculator.calculate(input(viscosity: 0)),
          throwsA(isA<FormatException>()));
      expect(() => PipeFlowCalculator.calculate(input(roughness: -0.1)),
          throwsA(isA<FormatException>()));
      expect(() => PipeFlowCalculator.calculate(input(minorLossK: -1)),
          throwsA(isA<FormatException>()));
    });
  });

  group('ReynoldsCalculator', () {
    test('velocity and flow rate are two ways in to the same answer', () {
      final fromVelocity = ReynoldsCalculator.calculate(
        diameter: 50,
        density: 998.2,
        viscosity: 1.002e-3,
        velocity: 2,
      );
      final fromFlow = ReynoldsCalculator.calculate(
        diameter: 50,
        density: 998.2,
        viscosity: 1.002e-3,
        flowRate: fromVelocity.flowRate,
      );
      expect(fromFlow.reynolds, closeTo(fromVelocity.reynolds, 1e-6));
      expect(fromFlow.velocity, closeTo(2, 1e-9));
    });

    test('reports the flow area in mm² and kinematic viscosity in m²/s', () {
      final result = ReynoldsCalculator.calculate(
        diameter: 50,
        density: 1000,
        viscosity: 1e-3,
        velocity: 1,
      );
      expect(result.area, closeTo(math.pi * 25 * 25, 1e-6));
      expect(result.kinematicViscosity, closeTo(1e-6, 1e-15));
    });

    test('needs one of velocity or flow rate', () {
      expect(
        () => ReynoldsCalculator.calculate(
            diameter: 50, density: 998, viscosity: 1e-3),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('PumpPowerCalculator', () {
    test('hydraulic power is the product of head rise and flow', () {
      // 50 L/s against 300 kPa = 15 kW of useful work.
      final result = PumpPowerCalculator.calculate(
        flowRate: 50,
        pressureRise: 300,
        density: 998.2,
        efficiency: 75,
      );
      expect(result.hydraulicPower, closeTo(15, 1e-9));
      expect(result.shaftPower, closeTo(20, 1e-9));
      expect(result.lostPower, closeTo(5, 1e-9));
    });

    test('head is the pressure rise expressed in metres of the fluid', () {
      final result = PumpPowerCalculator.calculate(
        flowRate: 10,
        pressureRise: 100,
        density: 1000,
        efficiency: 70,
      );
      expect(result.head, closeTo(100000 / (1000 * gravity), 1e-9));
      expect(result.head, closeTo(10.197, 1e-3));
    });

    test('a denser fluid needs less head for the same pressure rise', () {
      double headFor(double density) => PumpPowerCalculator.calculate(
            flowRate: 10,
            pressureRise: 200,
            density: density,
            efficiency: 80,
          ).head;
      expect(headFor(13529), lessThan(headFor(998.2)));
    });

    test('rejects an efficiency outside 0-100%', () {
      expect(
        () => PumpPowerCalculator.calculate(
            flowRate: 10, pressureRise: 100, density: 1000, efficiency: 0),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => PumpPowerCalculator.calculate(
            flowRate: 10, pressureRise: 100, density: 1000, efficiency: 120),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('CompositeWallCalculator', () {
    test('a single layer reduces to R = t/k', () {
      final result = _wall(layers: [
        const WallLayer(thickness: 200, conductivity: 0.72),
      ]);
      expect(result.totalResistance, closeTo(0.2 / 0.72, 1e-12));
      expect(result.overallCoefficient, closeTo(0.72 / 0.2, 1e-12));
      expect(result.heatFlux, closeTo(20 / (0.2 / 0.72), 1e-9));
    });

    test('layer resistances add in series', () {
      final result = _wall(layers: [
        const WallLayer(thickness: 100, conductivity: 0.72),
        const WallLayer(thickness: 50, conductivity: 0.043),
        const WallLayer(thickness: 12, conductivity: 0.17),
      ]);
      const expected = 0.1 / 0.72 + 0.05 / 0.043 + 0.012 / 0.17;
      expect(result.totalResistance, closeTo(expected, 1e-12));
      expect(result.layerResistances, hasLength(3));
      // The insulation dominates, which is the whole point of putting it in.
      expect(result.layerResistances[1],
          greaterThan(result.layerResistances[0] + result.layerResistances[2]));
    });

    test('convection films add 1/h at each face', () {
      final bare = _wall(
        layers: [const WallLayer(thickness: 100, conductivity: 0.72)],
      );
      final filmed = _wall(
        layers: [const WallLayer(thickness: 100, conductivity: 0.72)],
        hIn: 8,
        hOut: 25,
      );
      expect(filmed.insideFilmResistance, closeTo(1 / 8, 1e-12));
      expect(filmed.outsideFilmResistance, closeTo(1 / 25, 1e-12));
      expect(filmed.totalResistance,
          closeTo(bare.totalResistance + 1 / 8 + 1 / 25, 1e-12));
      expect(filmed.heatFlux, lessThan(bare.heatFlux));
    });

    test('heat flow is the flux times the area', () {
      final result = _wall(
        layers: [const WallLayer(thickness: 100, conductivity: 0.72)],
        area: 12.5,
      );
      expect(result.heatFlow, closeTo(result.heatFlux * 12.5, 1e-9));
    });

    test('node temperatures march monotonically from hot to cold', () {
      final result = _wall(
        layers: [
          const WallLayer(thickness: 100, conductivity: 0.72),
          const WallLayer(thickness: 50, conductivity: 0.043),
        ],
        inside: 22,
        outside: -5,
        hIn: 8,
        hOut: 25,
      );
      // inside air, inside surface, interface, outside surface, outside air.
      expect(result.nodes, hasLength(5));
      expect(result.nodes.first.temperature, closeTo(22, 1e-12));
      expect(result.nodes.last.temperature, closeTo(-5, 1e-9));
      for (var i = 1; i < result.nodes.length; i++) {
        expect(result.nodes[i].temperature,
            lessThan(result.nodes[i - 1].temperature));
      }
    });

    test('without films the end nodes are the surfaces themselves', () {
      final result = _wall(
        layers: [const WallLayer(thickness: 100, conductivity: 0.72)],
        inside: 30,
        outside: 10,
      );
      expect(result.nodes, hasLength(2));
      expect(result.nodes.first.temperature, closeTo(30, 1e-12));
      expect(result.nodes.last.temperature, closeTo(10, 1e-9));
    });

    test('the temperature drop across a layer is proportional to its R', () {
      final result = _wall(
        layers: [
          const WallLayer(thickness: 100, conductivity: 0.72),
          const WallLayer(thickness: 50, conductivity: 0.043),
        ],
        inside: 20,
        outside: 0,
      );
      final firstDrop =
          result.nodes[0].temperature - result.nodes[1].temperature;
      final secondDrop =
          result.nodes[1].temperature - result.nodes[2].temperature;
      expect(
        firstDrop / secondDrop,
        closeTo(result.layerResistances[0] / result.layerResistances[1], 1e-9),
      );
    });

    test('heat flows backwards when the outside is hotter', () {
      final result = _wall(
        layers: [const WallLayer(thickness: 100, conductivity: 0.72)],
        inside: 20,
        outside: 35,
      );
      expect(result.heatFlux, lessThan(0));
      expect(result.nodes.last.temperature,
          greaterThan(result.nodes.first.temperature));
    });

    test('rejects an empty stack and non-positive properties', () {
      expect(() => _wall(layers: const []), throwsA(isA<FormatException>()));
      expect(
        () => _wall(layers: [const WallLayer(thickness: 0, conductivity: 1)]),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => _wall(layers: [const WallLayer(thickness: 10, conductivity: 0)]),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => _wall(
            layers: [const WallLayer(thickness: 10, conductivity: 1)], area: 0),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('FinCalculator', () {
    FinResult fin({
      double length = 50,
      double thickness = 3,
      double width = 100,
      double conductivity = 237,
      double coefficient = 40,
      double base = 100,
      double ambient = 25,
    }) =>
        FinCalculator.calculate(
          length: length,
          thickness: thickness,
          width: width,
          conductivity: conductivity,
          coefficient: coefficient,
          baseTemperature: base,
          ambientTemperature: ambient,
        );

    test('corrected length adds half the thickness', () {
      expect(fin().correctedLength, closeTo(51.5, 1e-9));
    });

    test('the fin parameter is sqrt(2h/kt)', () {
      expect(fin().finParameter,
          closeTo(math.sqrt(2 * 40 / (237 * 0.003)), 1e-9));
    });

    test('efficiency is tanh(mLc)/(mLc) and sits between 0 and 1', () {
      final result = fin();
      final mLc = result.finParameter * result.correctedLength / 1000;
      final tanh = (math.exp(2 * mLc) - 1) / (math.exp(2 * mLc) + 1);
      expect(result.efficiency, closeTo(tanh / mLc, 1e-9));
      expect(result.efficiency, greaterThan(0));
      expect(result.efficiency, lessThan(1));
    });

    test('a short thick fin of copper is nearly 100% efficient', () {
      final result = fin(length: 5, thickness: 10, conductivity: 401);
      expect(result.efficiency, greaterThan(0.99));
      expect(result.tipTemperature, closeTo(100, 1.0));
    });

    test('a long thin fin of steel is inefficient and cold at the tip', () {
      final result =
          fin(length: 200, thickness: 1, conductivity: 14.9, coefficient: 100);
      expect(result.efficiency, lessThan(0.2));
      // Nearly all the excess temperature is gone by the tip.
      expect(result.tipTemperature, closeTo(25, 2.0));
    });

    test('heat flow is the efficiency times the isothermal maximum', () {
      final result = fin();
      expect(result.heatFlow,
          closeTo(result.efficiency * result.maximumHeatFlow, 1e-9));
      expect(result.heatFlow, lessThan(result.maximumHeatFlow));
    });

    test('a fin worth adding has effectiveness above 2', () {
      // The usual rule of thumb: below ~2 the fin is not earning its place.
      expect(fin().effectiveness, greaterThan(2));
    });

    test('conducting better raises efficiency', () {
      expect(fin(conductivity: 401).efficiency,
          greaterThan(fin(conductivity: 14.9).efficiency));
    });

    test('the tip never falls below ambient or rises above the base', () {
      final result = fin(length: 500);
      expect(result.tipTemperature, greaterThanOrEqualTo(25));
      expect(result.tipTemperature, lessThanOrEqualTo(100));
    });

    test('rejects non-positive geometry and properties', () {
      expect(() => fin(length: 0), throwsA(isA<FormatException>()));
      expect(() => fin(thickness: 0), throwsA(isA<FormatException>()));
      expect(() => fin(width: -1), throwsA(isA<FormatException>()));
      expect(() => fin(conductivity: 0), throwsA(isA<FormatException>()));
      expect(() => fin(coefficient: 0), throwsA(isA<FormatException>()));
    });
  });

  group('LmtdCalculator', () {
    LmtdResult exchanger({
      double hotIn = 150,
      double hotOut = 90,
      double coldIn = 30,
      double coldOut = 70,
      FlowArrangement arrangement = FlowArrangement.counterFlow,
      double u = 500,
      double duty = 100000,
    }) =>
        LmtdCalculator.calculate(
          hotInlet: hotIn,
          hotOutlet: hotOut,
          coldInlet: coldIn,
          coldOutlet: coldOut,
          arrangement: arrangement,
          overallCoefficient: u,
          heatDuty: duty,
        );

    test('counter-flow pairs each inlet with the opposite outlet', () {
      final result = exchanger();
      expect(result.deltaT1, closeTo(150 - 70, 1e-12));
      expect(result.deltaT2, closeTo(90 - 30, 1e-12));
      expect(result.lmtd, closeTo((80 - 60) / math.log(80 / 60), 1e-9));
      expect(result.lmtd, closeTo(69.52, 0.01));
    });

    test('parallel flow pairs the inlets together', () {
      final result = exchanger(arrangement: FlowArrangement.parallelFlow);
      expect(result.deltaT1, closeTo(150 - 30, 1e-12));
      expect(result.deltaT2, closeTo(90 - 70, 1e-12));
      expect(result.lmtd, closeTo((120 - 20) / math.log(120 / 20), 1e-9));
    });

    test('counter-flow gives the larger driving force, as it must', () {
      expect(
        exchanger().lmtd,
        greaterThan(exchanger(arrangement: FlowArrangement.parallelFlow).lmtd),
      );
    });

    test('the log mean sits between the two end approaches', () {
      final result = exchanger();
      final low = math.min(result.deltaT1, result.deltaT2);
      final high = math.max(result.deltaT1, result.deltaT2);
      expect(result.lmtd, greaterThan(low));
      expect(result.lmtd, lessThan(high));
    });

    test('equal end approaches degenerate to that value, not a NaN', () {
      final result = exchanger(hotIn: 100, hotOut: 80, coldIn: 30, coldOut: 50);
      expect(result.deltaT1, closeTo(50, 1e-12));
      expect(result.deltaT2, closeTo(50, 1e-12));
      expect(result.lmtd, closeTo(50, 1e-9));
      expect(result.lmtd.isFinite, isTrue);
    });

    test('area is the duty over U times the log mean', () {
      final result = exchanger();
      expect(result.area, closeTo(100000 / (500 * result.lmtd), 1e-9));
    });

    test('reports each stream temperature range', () {
      final result = exchanger();
      expect(result.hotRange, closeTo(60, 1e-12));
      expect(result.coldRange, closeTo(40, 1e-12));
    });

    test('rejects a temperature cross', () {
      // Parallel flow cannot take the cold stream past the hot outlet.
      expect(
        () => exchanger(
          hotIn: 150,
          hotOut: 60,
          coldIn: 30,
          coldOut: 80,
          arrangement: FlowArrangement.parallelFlow,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects streams that heat or cool the wrong way', () {
      expect(() => exchanger(hotIn: 90, hotOut: 150),
          throwsA(isA<FormatException>()));
      expect(() => exchanger(coldIn: 70, coldOut: 30),
          throwsA(isA<FormatException>()));
    });

    test('rejects a non-positive U or duty', () {
      expect(() => exchanger(u: 0), throwsA(isA<FormatException>()));
      expect(() => exchanger(duty: 0), throwsA(isA<FormatException>()));
    });
  });

  group('property libraries', () {
    test('every fluid preset is physically plausible', () {
      for (final fluid in builtInFluids) {
        expect(fluid.name.trim(), isNotEmpty);
        expect(fluid.densitySI, greaterThan(0), reason: fluid.name);
        expect(fluid.viscositySI, greaterThan(0), reason: fluid.name);
      }
    });

    test('fluid names are unique and state a temperature', () {
      final names = builtInFluids.map((f) => f.name).toList();
      expect(names.toSet(), hasLength(names.length));
      for (final name in names) {
        expect(name, contains('°C'),
            reason: '$name must say what temperature it is quoted at');
      }
    });

    test('a warmer water preset is thinner than a colder one', () {
      final cold =
          builtInFluids.firstWhere((f) => f.name == 'Water, 20 °C');
      final hot = builtInFluids.firstWhere((f) => f.name == 'Water, 90 °C');
      expect(hot.viscositySI, lessThan(cold.viscositySI));
      expect(hot.densitySI, lessThan(cold.densitySI));
    });

    test('every thermal material preset is plausible', () {
      for (final material in builtInThermalMaterials) {
        expect(material.name.trim(), isNotEmpty);
        expect(material.conductivitySI, greaterThan(0), reason: material.name);
        // Diamond aside, nothing in a toolkit like this beats silver.
        expect(material.conductivitySI, lessThan(430), reason: material.name);
      }
    });

    test('thermal material names are unique', () {
      final names = builtInThermalMaterials.map((m) => m.name).toList();
      expect(names.toSet(), hasLength(names.length));
    });

    test('the groups are ordered by how well they conduct', () {
      double worstOf(ThermalMaterialGroup group) => builtInThermalMaterials
          .where((m) => m.group == group)
          .map((m) => m.conductivitySI)
          .reduce(math.min);
      double bestOf(ThermalMaterialGroup group) => builtInThermalMaterials
          .where((m) => m.group == group)
          .map((m) => m.conductivitySI)
          .reduce(math.max);

      expect(worstOf(ThermalMaterialGroup.metal),
          greaterThan(bestOf(ThermalMaterialGroup.building)));
      expect(worstOf(ThermalMaterialGroup.building),
          greaterThan(bestOf(ThermalMaterialGroup.insulation)));
    });
  });
}
