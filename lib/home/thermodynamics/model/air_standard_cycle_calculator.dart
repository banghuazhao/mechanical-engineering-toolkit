import 'dart:math' as math;

/// The three air-standard cycles of an introductory course.
enum AirCycle { otto, diesel, brayton }

/// How the Otto cycle's heat addition is specified.
enum OttoHeatSpec { heatAdded, peakTemperature }

class AirCycleInput {
  const AirCycleInput({
    required this.cycle,
    required this.t1C,
    required this.p1,
    this.cp = 1.005,
    this.k = 1.4,
    this.compressionRatio,
    this.cutoffRatio,
    this.ottoHeatSpec = OttoHeatSpec.heatAdded,
    this.heatAdded,
    this.peakTemperatureC,
    this.pressureRatio,
    this.compressorEfficiency = 1,
    this.turbineEfficiency = 1,
  });

  final AirCycle cycle;

  /// Compressor or cylinder inlet temperature, °C.
  final double t1C;

  /// Inlet pressure, kPa.
  final double p1;

  /// kJ/(kg·K), constant — the cold-air-standard assumption.
  final double cp;
  final double k;

  /// Otto and Diesel: v1/v2.
  final double? compressionRatio;

  /// Diesel: v3/v2, the volume ratio over the constant-pressure heat addition.
  final double? cutoffRatio;

  final OttoHeatSpec ottoHeatSpec;

  /// Otto: heat added per kg, kJ/kg.
  final double? heatAdded;

  /// Otto (when so specified) and Brayton: the cycle's highest temperature,
  /// °C — the turbine inlet temperature for Brayton.
  final double? peakTemperatureC;

  /// Brayton: p2/p1.
  final double? pressureRatio;

  /// Brayton: isentropic efficiencies, 0–1. 1 is the ideal cycle.
  final double compressorEfficiency;
  final double turbineEfficiency;
}

/// One corner of the cycle. Entropy is measured from state 1, which is all
/// a T–s diagram needs and saves inventing a reference state.
class CycleState {
  const CycleState({
    required this.t,
    required this.p,
    required this.v,
    required this.s,
  });

  /// K.
  final double t;

  /// kPa.
  final double p;

  /// m³/kg.
  final double v;

  /// kJ/(kg·K), relative to state 1.
  final double s;
}

class AirCycleResult {
  const AirCycleResult({
    required this.cycle,
    required this.states,
    required this.heatIn,
    required this.heatOut,
    required this.compressionWork,
    required this.expansionWork,
    required this.carnotEfficiency,
    required this.pv,
    required this.ts,
    this.meanEffectivePressure,
  });

  final AirCycle cycle;

  /// States 1–4, in order.
  final List<CycleState> states;

  /// kJ/kg.
  final double heatIn, heatOut;

  /// Work into the gas on compression and out of it on expansion, kJ/kg.
  final double compressionWork, expansionWork;

  /// 1 − T_min/T_max between the same two temperature extremes.
  final double carnotEfficiency;

  /// Otto and Diesel only, kPa: the constant pressure that would do the net
  /// work over the displacement.
  final double? meanEffectivePressure;

  /// The closed cycle as polylines: (v, p) and (s, T K).
  final List<({double v, double p})> pv;
  final List<({double s, double t})> ts;

  double get netWork => heatIn - heatOut;
  double get efficiency => netWork / heatIn;
  double get backWorkRatio => compressionWork / expansionWork;
}

enum AirCycleProblem {
  missingInput,
  nonPositive,
  belowAbsoluteZero,
  kNotAboveOne,
  ratioNotAboveOne,
  cutoffNotBelowCompression,
  efficiencyRange,
  peakBelowCompression,
}

class AirCycleException implements Exception {
  const AirCycleException(this.kind, [this.limitK]);
  final AirCycleProblem kind;

  /// For [AirCycleProblem.peakBelowCompression], the compression-end
  /// temperature the peak has to exceed, K.
  final double? limitK;
}

/// Cold-air-standard analysis: air as an ideal gas with constant cp and k,
/// every process internally reversible except the Brayton compressor and
/// turbine where their efficiencies say otherwise.
abstract final class AirCycleCalculator {
  static AirCycleResult calculate(AirCycleInput input) {
    final cp = input.cp;
    final k = input.k;
    if (cp <= 0 || input.p1 <= 0) {
      throw const AirCycleException(AirCycleProblem.nonPositive);
    }
    if (k <= 1) throw const AirCycleException(AirCycleProblem.kNotAboveOne);
    final t1 = input.t1C + 273.15;
    if (t1 <= 0) throw const AirCycleException(AirCycleProblem.belowAbsoluteZero);
    final cv = cp / k;
    final r = cp - cv;
    return switch (input.cycle) {
      AirCycle.otto => _otto(input, t1, cp, cv, r, k),
      AirCycle.diesel => _diesel(input, t1, cp, cv, r, k),
      AirCycle.brayton => _brayton(input, t1, cp, cv, r, k),
    };
  }

  static double _ratio(double? value) {
    if (value == null) throw const AirCycleException(AirCycleProblem.missingInput);
    if (value <= 1) throw const AirCycleException(AirCycleProblem.ratioNotAboveOne);
    return value;
  }

  static AirCycleResult _otto(
      AirCycleInput input, double t1, double cp, double cv, double r, double k) {
    final ratio = _ratio(input.compressionRatio);
    final p1 = input.p1;
    final v1 = r * t1 / p1;
    final t2 = t1 * math.pow(ratio, k - 1);
    final v2 = v1 / ratio;
    final p2 = r * t2 / v2;
    late double t3;
    if (input.ottoHeatSpec == OttoHeatSpec.heatAdded) {
      final q = input.heatAdded;
      if (q == null) throw const AirCycleException(AirCycleProblem.missingInput);
      if (q <= 0) throw const AirCycleException(AirCycleProblem.nonPositive);
      t3 = t2 + q / cv;
    } else {
      final peak = input.peakTemperatureC;
      if (peak == null) {
        throw const AirCycleException(AirCycleProblem.missingInput);
      }
      t3 = peak + 273.15;
      if (t3 <= t2) {
        throw AirCycleException(AirCycleProblem.peakBelowCompression, t2);
      }
    }
    final v3 = v2;
    final p3 = r * t3 / v3;
    final t4 = t3 / math.pow(ratio, k - 1);
    final v4 = v1;
    final p4 = r * t4 / v4;
    final qIn = cv * (t3 - t2);
    final qOut = cv * (t4 - t1);
    final states = _withEntropy([
      (t: t1, p: p1, v: v1),
      (t: t2, p: p2, v: v2),
      (t: t3, p: p3, v: v3),
      (t: t4, p: p4, v: v4),
    ], cp, r);
    return AirCycleResult(
      cycle: AirCycle.otto,
      states: states,
      heatIn: qIn,
      heatOut: qOut,
      compressionWork: cv * (t2 - t1),
      expansionWork: cv * (t3 - t4),
      carnotEfficiency: 1 - t1 / t3,
      meanEffectivePressure: (qIn - qOut) / (v1 - v2),
      pv: [
        ..._isentrope(states[0], states[1], k),
        ..._isentrope(states[2], states[3], k),
        (v: v1, p: p1),
      ],
      ts: [
        (s: 0, t: t1),
        (s: states[1].s, t: t2),
        ..._heating(states[1], states[2], cv),
        (s: states[3].s, t: t4),
        ..._heating(states[3], states[0], cv),
      ],
    );
  }

  static AirCycleResult _diesel(
      AirCycleInput input, double t1, double cp, double cv, double r, double k) {
    final ratio = _ratio(input.compressionRatio);
    final cutoff = _ratio(input.cutoffRatio);
    if (cutoff >= ratio) {
      throw const AirCycleException(AirCycleProblem.cutoffNotBelowCompression);
    }
    final p1 = input.p1;
    final v1 = r * t1 / p1;
    final t2 = t1 * math.pow(ratio, k - 1);
    final v2 = v1 / ratio;
    final p2 = r * t2 / v2;
    final v3 = v2 * cutoff;
    final t3 = t2 * cutoff;
    final p3 = p2;
    final v4 = v1;
    final t4 = t3 * math.pow(v3 / v4, k - 1);
    final p4 = r * t4 / v4;
    final qIn = cp * (t3 - t2);
    final qOut = cv * (t4 - t1);
    final states = _withEntropy([
      (t: t1, p: p1, v: v1),
      (t: t2, p: p2, v: v2),
      (t: t3, p: p3, v: v3),
      (t: t4, p: p4, v: v4),
    ], cp, r);
    return AirCycleResult(
      cycle: AirCycle.diesel,
      states: states,
      heatIn: qIn,
      heatOut: qOut,
      compressionWork: cv * (t2 - t1),
      // Boundary work over the whole expansion: the constant-pressure leg
      // and the isentropic one after it.
      expansionWork: p2 * (v3 - v2) + cv * (t3 - t4),
      carnotEfficiency: 1 - t1 / t3,
      meanEffectivePressure: (qIn - qOut) / (v1 - v2),
      pv: [
        ..._isentrope(states[0], states[1], k),
        ..._isentrope(states[2], states[3], k),
        (v: v1, p: p1),
      ],
      ts: [
        (s: 0, t: t1),
        (s: states[1].s, t: t2),
        ..._heating(states[1], states[2], cp),
        (s: states[3].s, t: t4),
        ..._heating(states[3], states[0], cv),
      ],
    );
  }

  static AirCycleResult _brayton(
      AirCycleInput input, double t1, double cp, double cv, double r, double k) {
    final ratio = _ratio(input.pressureRatio);
    final etaC = input.compressorEfficiency;
    final etaT = input.turbineEfficiency;
    if (etaC <= 0 || etaC > 1 || etaT <= 0 || etaT > 1) {
      throw const AirCycleException(AirCycleProblem.efficiencyRange);
    }
    final peak = input.peakTemperatureC;
    if (peak == null) throw const AirCycleException(AirCycleProblem.missingInput);
    final p1 = input.p1;
    final exponent = (k - 1) / k;
    final t2s = t1 * math.pow(ratio, exponent);
    final t2 = t1 + (t2s - t1) / etaC;
    final t3 = peak + 273.15;
    if (t3 <= t2) {
      throw AirCycleException(AirCycleProblem.peakBelowCompression, t2);
    }
    final t4s = t3 / math.pow(ratio, exponent);
    final t4 = t3 - etaT * (t3 - t4s);
    final p2 = p1 * ratio;
    final states = _withEntropy([
      (t: t1, p: p1, v: r * t1 / p1),
      (t: t2, p: p2, v: r * t2 / p2),
      (t: t3, p: p2, v: r * t3 / p2),
      (t: t4, p: p1, v: r * t4 / p1),
    ], cp, r);
    final ideal = etaC == 1 && etaT == 1;
    return AirCycleResult(
      cycle: AirCycle.brayton,
      states: states,
      heatIn: cp * (t3 - t2),
      heatOut: cp * (t4 - t1),
      compressionWork: cp * (t2 - t1),
      expansionWork: cp * (t3 - t4),
      carnotEfficiency: 1 - t1 / t3,
      pv: [
        ..._compression(states[0], states[1], k, ideal),
        ..._isobar(states[1], states[2]),
        ..._compression(states[2], states[3], k, ideal),
        ..._isobar(states[3], states[0]),
      ],
      ts: [
        (s: 0, t: t1),
        (s: states[1].s, t: t2),
        ..._heating(states[1], states[2], cp),
        (s: states[3].s, t: t4),
        ..._heating(states[3], states[0], cp),
      ],
    );
  }

  static List<CycleState> _withEntropy(
    List<({double t, double p, double v})> raw,
    double cp,
    double r,
  ) {
    final first = raw.first;
    return [
      for (final s in raw)
        CycleState(
          t: s.t,
          p: s.p,
          v: s.v,
          s: cp * math.log(s.t / first.t) - r * math.log(s.p / first.p),
        ),
    ];
  }

  /// p·v^k = constant from [a] to [b], sampled geometrically in v.
  static List<({double v, double p})> _isentrope(
      CycleState a, CycleState b, double k) {
    const samples = 30;
    final path = <({double v, double p})>[];
    for (var i = 0; i <= samples; i++) {
      final v = a.v * math.pow(b.v / a.v, i / samples);
      path.add((v: v, p: a.p * math.pow(a.v / v, k).toDouble()));
    }
    return path;
  }

  /// A Brayton compressor or turbine: the isentrope when ideal, otherwise a
  /// polytrope fitted to the end states — the real path is not an
  /// equilibrium process, and the fitted curve is how textbooks sketch it.
  static List<({double v, double p})> _compression(
      CycleState a, CycleState b, double k, bool ideal) {
    if (ideal) return _isentrope(a, b, k);
    final n = math.log(b.p / a.p) / math.log(a.v / b.v);
    return _isentrope(a, b, n);
  }

  static List<({double v, double p})> _isobar(CycleState a, CycleState b) => [
        (v: a.v, p: a.p),
        (v: b.v, p: b.p),
      ];

  /// Heat exchange at constant volume (c = cv) or pressure (c = cp) from [a]
  /// to [b]: s rises as c·ln(T/Ta), sampled in T.
  static List<({double s, double t})> _heating(
      CycleState a, CycleState b, double c) {
    const samples = 24;
    return [
      for (var i = 0; i <= samples; i++)
        (
          s: a.s + c * math.log((a.t + (b.t - a.t) * i / samples) / a.t),
          t: a.t + (b.t - a.t) * i / samples,
        ),
    ];
  }
}
