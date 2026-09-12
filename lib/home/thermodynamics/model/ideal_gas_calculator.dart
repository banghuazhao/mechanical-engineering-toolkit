import 'dart:math' as math;

/// A gas treated as ideal with constant specific heats — the "cold" model of
/// an introductory thermodynamics course.
class IdealGas {
  const IdealGas({
    required this.name,
    required this.gasConstant,
    required this.cp,
  });

  final String name;

  /// Specific gas constant R, kJ/(kg·K).
  final double gasConstant;

  /// Constant-pressure specific heat at 300 K, kJ/(kg·K).
  final double cp;

  /// Constant-volume specific heat, cp − R.
  double get cv => cp - gasConstant;

  /// Ratio of specific heats, cp / cv.
  double get k => cp / cv;
}

/// R and cp at 300 K, from Çengel & Boles table A-2(a) — the values most
/// coursework is set against.
const List<IdealGas> idealGases = [
  IdealGas(name: 'Air', gasConstant: 0.2870, cp: 1.005),
  IdealGas(name: 'Nitrogen, N₂', gasConstant: 0.2968, cp: 1.039),
  IdealGas(name: 'Oxygen, O₂', gasConstant: 0.2598, cp: 0.918),
  IdealGas(name: 'Carbon dioxide, CO₂', gasConstant: 0.1889, cp: 0.846),
  IdealGas(name: 'Hydrogen, H₂', gasConstant: 4.1240, cp: 14.307),
  IdealGas(name: 'Helium, He', gasConstant: 2.0769, cp: 5.1926),
  IdealGas(name: 'Argon, Ar', gasConstant: 0.2081, cp: 0.5203),
  IdealGas(name: 'Methane, CH₄', gasConstant: 0.5182, cp: 2.2537),
  IdealGas(name: 'Carbon monoxide, CO', gasConstant: 0.2968, cp: 1.040),
  IdealGas(name: 'Steam, H₂O (low pressure)', gasConstant: 0.4615, cp: 1.8723),
];

enum GasProcess { isothermal, isobaric, isochoric, isentropic, polytropic }

/// Which end-state property the user supplied. Isothermal processes always
/// take a pressure and isobaric ones a temperature — the other choice would
/// not move the state — so this only matters for the rest.
enum FinalStateSpec { pressure, temperature }

class IdealGasProcessInput {
  const IdealGasProcessInput({
    required this.gasConstant,
    required this.cp,
    required this.p1,
    required this.t1C,
    required this.mass,
    required this.process,
    this.spec = FinalStateSpec.pressure,
    this.p2,
    this.t2C,
    this.n,
  });

  /// kJ/(kg·K).
  final double gasConstant;
  final double cp;

  /// kPa.
  final double p1;

  /// °C.
  final double t1C;

  /// kg.
  final double mass;

  final GasProcess process;
  final FinalStateSpec spec;

  /// kPa.
  final double? p2;

  /// °C.
  final double? t2C;

  /// Polytropic exponent in p·vⁿ = constant.
  final double? n;
}

enum IdealGasProblem {
  missingInput,
  nonPositive,
  belowAbsoluteZero,
  cpNotAboveR,
  polytropicExponent,
  noChange,
}

class IdealGasException implements Exception {
  const IdealGasException(this.kind);
  final IdealGasProblem kind;
}

/// Both end states and the energy bookkeeping for one process, per unit mass
/// and for the whole mass. Temperatures in K, pressures kPa, specific
/// volumes m³/kg, energies kJ/kg (lower case) and kJ (upper case).
class IdealGasProcessResult {
  const IdealGasProcessResult({
    required this.p1,
    required this.t1,
    required this.v1,
    required this.p2,
    required this.t2,
    required this.v2,
    required this.mass,
    required this.work,
    required this.heat,
    required this.deltaU,
    required this.deltaH,
    required this.deltaS,
    required this.k,
    required this.path,
  });

  final double p1, t1, v1, p2, t2, v2, mass;

  /// Boundary work done by the gas, kJ/kg. Positive in expansion.
  final double work;

  /// Heat added to the gas, kJ/kg.
  final double heat;
  final double deltaU, deltaH;

  /// kJ/(kg·K).
  final double deltaS;

  final double k;

  /// The process on a p–v diagram, (v m³/kg, p kPa), from state 1 to 2.
  final List<({double v, double p})> path;

  double get volume1 => mass * v1;
  double get volume2 => mass * v2;
}

abstract final class IdealGasCalculator {
  static IdealGasProcessResult calculate(IdealGasProcessInput input) {
    final r = input.gasConstant;
    final cp = input.cp;
    if (r <= 0 || cp <= 0 || input.p1 <= 0 || input.mass <= 0) {
      throw const IdealGasException(IdealGasProblem.nonPositive);
    }
    if (cp <= r) throw const IdealGasException(IdealGasProblem.cpNotAboveR);
    final cv = cp - r;
    final k = cp / cv;
    final t1 = input.t1C + 273.15;
    if (t1 <= 0) throw const IdealGasException(IdealGasProblem.belowAbsoluteZero);
    final p1 = input.p1;
    final v1 = r * t1 / p1;

    double kelvin(double? celsius) {
      if (celsius == null) {
        throw const IdealGasException(IdealGasProblem.missingInput);
      }
      final t = celsius + 273.15;
      if (t <= 0) {
        throw const IdealGasException(IdealGasProblem.belowAbsoluteZero);
      }
      return t;
    }

    double pressure(double? p) {
      if (p == null) throw const IdealGasException(IdealGasProblem.missingInput);
      if (p <= 0) throw const IdealGasException(IdealGasProblem.nonPositive);
      return p;
    }

    // For the exponent forms: p·vⁿ = const, so T2/T1 = (p2/p1)^((n−1)/n).
    ({double p2, double t2}) polytropic(double exponent) {
      if (input.spec == FinalStateSpec.pressure) {
        final p2 = pressure(input.p2);
        return (p2: p2, t2: t1 * math.pow(p2 / p1, (exponent - 1) / exponent));
      }
      final t2 = kelvin(input.t2C);
      return (p2: p1 * math.pow(t2 / t1, exponent / (exponent - 1)), t2: t2);
    }

    late double p2, t2;
    switch (input.process) {
      case GasProcess.isothermal:
        p2 = pressure(input.p2);
        t2 = t1;
      case GasProcess.isobaric:
        p2 = p1;
        t2 = kelvin(input.t2C);
      case GasProcess.isochoric:
        if (input.spec == FinalStateSpec.pressure) {
          p2 = pressure(input.p2);
          t2 = t1 * p2 / p1;
        } else {
          t2 = kelvin(input.t2C);
          p2 = p1 * t2 / t1;
        }
      case GasProcess.isentropic:
        final end = polytropic(k);
        p2 = end.p2;
        t2 = end.t2;
      case GasProcess.polytropic:
        final n = input.n;
        if (n == null) throw const IdealGasException(IdealGasProblem.missingInput);
        // n = 1 is the isothermal case and n = 0 the isobaric one; both have
        // their own entry, and the general formula divides by zero at each.
        if (n <= 0 || (n - 1).abs() < 1e-9) {
          throw const IdealGasException(IdealGasProblem.polytropicExponent);
        }
        final end = polytropic(n);
        p2 = end.p2;
        t2 = end.t2;
    }
    if ((p2 - p1).abs() < 1e-12 * p1 && (t2 - t1).abs() < 1e-12 * t1) {
      throw const IdealGasException(IdealGasProblem.noChange);
    }
    final v2 = r * t2 / p2;

    final work = switch (input.process) {
      GasProcess.isothermal => r * t1 * math.log(v2 / v1),
      GasProcess.isobaric => p1 * (v2 - v1),
      GasProcess.isochoric => 0.0,
      GasProcess.isentropic => cv * (t1 - t2),
      GasProcess.polytropic => r * (t2 - t1) / (1 - input.n!),
    };
    final deltaU = cv * (t2 - t1);
    final deltaH = cp * (t2 - t1);
    final heat = deltaU + work;
    // The general ideal-gas entropy change holds whatever the path; for the
    // isentropic process it comes out as zero to rounding, as it should.
    final deltaS = cp * math.log(t2 / t1) - r * math.log(p2 / p1);

    return IdealGasProcessResult(
      p1: p1,
      t1: t1,
      v1: v1,
      p2: p2,
      t2: t2,
      v2: v2,
      mass: input.mass,
      work: work,
      heat: heat,
      deltaU: deltaU,
      deltaH: deltaH,
      deltaS: input.process == GasProcess.isentropic ? 0 : deltaS,
      k: k,
      path: _path(input.process, p1, v1, p2, v2, k, input.n),
    );
  }

  static List<({double v, double p})> _path(GasProcess process, double p1,
      double v1, double p2, double v2, double k, double? n) {
    // A constant-volume or constant-pressure process is a straight line.
    if (process == GasProcess.isochoric || process == GasProcess.isobaric) {
      return [(v: v1, p: p1), (v: v2, p: p2)];
    }
    final exponent = switch (process) {
      GasProcess.isothermal => 1.0,
      GasProcess.isentropic => k,
      _ => n!,
    };
    const samples = 40;
    final path = <({double v, double p})>[];
    for (var i = 0; i <= samples; i++) {
      // Geometric spacing in v, so an expansion over a decade or more is
      // sampled as evenly on a log axis as on a linear one.
      final v = v1 * math.pow(v2 / v1, i / samples);
      path.add((v: v, p: p1 * math.pow(v1 / v, exponent).toDouble()));
    }
    return path;
  }
}
