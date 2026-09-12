import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/iapws_if97.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/steam_tables_calculator.dart';

class RankineInput {
  const RankineInput({
    required this.boilerPressure,
    required this.condenserPressure,
    this.turbineInletC,
    this.turbineEfficiency = 1,
    this.pumpEfficiency = 1,
    this.massFlow,
  });

  /// kPa.
  final double boilerPressure;

  /// kPa.
  final double condenserPressure;

  /// Turbine inlet temperature, °C. Null for saturated vapour at the boiler
  /// pressure — the cycle without superheat.
  final double? turbineInletC;

  /// Isentropic efficiencies, 0–1. 1 is the ideal cycle.
  final double turbineEfficiency;
  final double pumpEfficiency;

  /// kg/s. Optional: without it the answer is per kilogram of steam.
  final double? massFlow;
}

/// One state around the cycle, in display-ready SI: kPa, K, kJ/kg,
/// kJ/(kg·K), m³/kg. [quality] is set only inside the dome.
class RankineState {
  const RankineState({
    required this.p,
    required this.t,
    required this.h,
    required this.s,
    required this.v,
    this.quality,
  });

  factory RankineState.from(SteamPoint point) => RankineState(
        p: point.pressure * 1000,
        t: point.temperature,
        h: point.enthalpy,
        s: point.entropy,
        v: point.specificVolume,
        quality: point.quality,
      );

  final double p, t, h, s, v;
  final double? quality;
}

class RankineResult {
  const RankineResult({
    required this.states,
    required this.pumpWork,
    required this.turbineWork,
    required this.heatIn,
    required this.heatOut,
    required this.massFlow,
    required this.cyclePath,
    required this.dome,
  });

  /// States 1–4: pump inlet, boiler inlet, turbine inlet, turbine exit.
  final List<RankineState> states;

  /// kJ/kg.
  final double pumpWork, turbineWork, heatIn, heatOut;

  final double? massFlow;

  /// The cycle on a T–s diagram, (s, T K), and the saturation dome behind
  /// it.
  final List<({double s, double t})> cyclePath;
  final List<({double s, double t})> dome;

  double get netWork => turbineWork - pumpWork;
  double get efficiency => netWork / heatIn;
  double get backWorkRatio => pumpWork / turbineWork;

  /// kW, when a mass flow was given.
  double? get netPower => massFlow == null ? null : massFlow! * netWork;
  double? get heatInputRate => massFlow == null ? null : massFlow! * heatIn;

  /// Turbine-exit quality; null when the exhaust is still superheated.
  double? get exitQuality => states[3].quality;
}

enum RankineProblem {
  nonPositive,
  condenserNotBelowBoiler,
  pressureOutOfRange,
  efficiencyRange,
  inletNotSuperheated,
  supercriticalNeedsTemperature,
  outsideFormulation,
}

class RankineException implements Exception {
  const RankineException(this.kind, [this.limitK]);
  final RankineProblem kind;

  /// For [RankineProblem.inletNotSuperheated]: the boiler's saturation
  /// temperature, K.
  final double? limitK;
}

/// The simple Rankine cycle with IAPWS-IF97 steam: pump, boiler, turbine,
/// condenser, with isentropic efficiencies on the two machines.
abstract final class RankineCalculator {
  static RankineResult calculate(RankineInput input) {
    final pb = input.boilerPressure / 1000;
    final pc = input.condenserPressure / 1000;
    if (pb <= 0 || pc <= 0) {
      throw const RankineException(RankineProblem.nonPositive);
    }
    if (pc >= pb) {
      throw const RankineException(RankineProblem.condenserNotBelowBoiler);
    }
    if (pc < 611.213e-6 || pc >= If97.pc || pb > If97.pMax) {
      throw const RankineException(RankineProblem.pressureOutOfRange);
    }
    final etaT = input.turbineEfficiency;
    final etaP = input.pumpEfficiency;
    if (etaT <= 0 || etaT > 1 || etaP <= 0 || etaP > 1) {
      throw const RankineException(RankineProblem.efficiencyRange);
    }
    final mass = input.massFlow;
    if (mass != null && mass <= 0) {
      throw const RankineException(RankineProblem.nonPositive);
    }

    try {
      // 1: saturated liquid leaving the condenser.
      final condenser = If97.saturationAtPressure(pc);
      final s1 = SteamPoint.mixture(condenser, 0);

      // 1→2: pump. Liquid is nearly incompressible, so the isentropic work
      // is v·Δp — the textbook shortcut, and within a fraction of a percent
      // of integrating along the isentrope at these pressures.
      final pumpIdeal = condenser.liquid.specificVolume * (pb - pc) * 1000;
      final pumpWork = pumpIdeal / etaP;
      final s2 = If97.stateFromPressureEnthalpy(pb, s1.enthalpy + pumpWork);

      // 3: turbine inlet.
      SteamPoint s3;
      final inletC = input.turbineInletC;
      if (inletC == null) {
        if (pb >= If97.pc) {
          throw const RankineException(
              RankineProblem.supercriticalNeedsTemperature);
        }
        s3 = SteamPoint.mixture(If97.saturationAtPressure(pb), 1);
      } else {
        final t3 = inletC + 273.15;
        if (pb < If97.pc) {
          final tSat = If97.saturationTemperature(pb);
          if (t3 <= tSat) {
            throw RankineException(RankineProblem.inletNotSuperheated, tSat);
          }
        }
        s3 = SteamPoint.single(If97.state(pb, t3));
      }

      // 3→4: turbine, down to the condenser pressure.
      final ideal4 = If97.stateFromPressureEntropy(pc, s3.entropy);
      final h4 = s3.enthalpy - etaT * (s3.enthalpy - ideal4.enthalpy);
      final s4 = If97.stateFromPressureEnthalpy(pc, h4);

      final states = [
        RankineState.from(s1),
        RankineState.from(s2),
        RankineState.from(s3),
        RankineState.from(s4),
      ];
      return RankineResult(
        states: states,
        pumpWork: pumpWork,
        turbineWork: s3.enthalpy - h4,
        heatIn: s3.enthalpy - s2.enthalpy,
        heatOut: h4 - s1.enthalpy,
        massFlow: mass,
        cyclePath: _path(states, pb, pc),
        dome: SteamTablesCalculator.saturationDome,
      );
    } on SteamRangeException {
      throw const RankineException(RankineProblem.outsideFormulation);
    }
  }

  /// The cycle traced on T–s: the pump and turbine as straight lines between
  /// their end states, the boiler and condenser along their isobars —
  /// through the dome at constant temperature where they cross it.
  static List<({double s, double t})> _path(
      List<RankineState> states, double pb, double pc) {
    final path = <({double s, double t})>[];
    void add(RankineState st) => path.add((s: st.s, t: st.t));

    add(states[0]);
    add(states[1]);
    path.addAll(_isobar(pb, states[1], states[2]));
    add(states[2]);
    add(states[3]);
    path.addAll(_isobar(pc, states[3], states[0]));
    add(states[0]);
    return path;
  }

  /// Points along the isobar [p] (MPa) between [from] and [to], by
  /// temperature in single-phase stretches and straight across the dome.
  static List<({double s, double t})> _isobar(
      double p, RankineState from, RankineState to) {
    final points = <({double s, double t})>[];
    void sweep(double tA, double tB) {
      const samples = 16;
      for (var i = 1; i < samples; i++) {
        final t = tA + (tB - tA) * i / samples;
        try {
          points.add((s: If97.state(p, t).entropy, t: t));
        } on SteamRangeException {
          // A sample that lands exactly on a boundary is simply skipped.
        }
      }
    }

    if (p >= If97.pc) {
      sweep(from.t, to.t);
      return points;
    }
    final sat = If97.saturationAtPressure(p);
    final tSat = sat.temperature;
    final heating = to.t > from.t || to.s > from.s;
    if (heating) {
      if (from.t < tSat - 1e-6) {
        sweep(from.t, tSat);
        points.add((s: sat.liquid.entropy, t: tSat));
      }
      if (to.quality == null && to.t > tSat + 1e-6) {
        points.add((s: sat.vapour.entropy, t: tSat));
        sweep(tSat, to.t);
      }
    } else {
      if (from.quality == null && from.t > tSat + 1e-6) {
        sweep(from.t, tSat);
        points.add((s: sat.vapour.entropy, t: tSat));
      }
    }
    return points;
  }
}
