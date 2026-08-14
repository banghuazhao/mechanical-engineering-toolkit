import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';

/// Standard gravity, m/s².
const double gravity = 9.80665;

/// Which of the three friction correlations applies at a given Reynolds
/// number. The transitional band is called out rather than silently folded
/// into one of its neighbours: no correlation is reliable there, and a result
/// computed inside it deserves to be read with suspicion.
enum FlowRegime { laminar, transitional, turbulent }

extension FlowRegimeLabel on FlowRegime {
  /// Display name in the active locale.
  String label(BuildContext context) => switch (this) {
        FlowRegime.laminar => S.of(context).Flow_Laminar,
        FlowRegime.transitional => S.of(context).Flow_Transitional,
        FlowRegime.turbulent => S.of(context).Flow_Turbulent,
      };
}

/// Below this Reynolds number the flow is taken as fully laminar, above
/// [_turbulentRe] as fully turbulent. The band between is transitional.
const double _laminarRe = 2300;
const double _turbulentRe = 4000;

FlowRegime regimeFor(double reynolds) {
  if (reynolds < _laminarRe) return FlowRegime.laminar;
  if (reynolds > _turbulentRe) return FlowRegime.turbulent;
  return FlowRegime.transitional;
}

/// Reynolds number for internal flow: Re = ρVD/μ.
///
/// [velocity] m/s, [diameter] m, [density] kg/m³, [viscosity] Pa·s.
double reynoldsNumber({
  required double velocity,
  required double diameter,
  required double density,
  required double viscosity,
}) {
  if (viscosity <= 0) {
    throw const FormatException('Dynamic viscosity must be positive.');
  }
  return density * velocity.abs() * diameter / viscosity;
}

/// Darcy friction factor.
///
/// Laminar flow uses the exact f = 64/Re. Everything above it solves the
/// implicit Colebrook–White equation
///
///   1/√f = -2·log₁₀( ε/(3.7·D) + 2.51/(Re·√f) )
///
/// by fixed-point iteration on x = 1/√f, seeded with the Swamee–Jain explicit
/// approximation. Iterating rather than just returning Swamee–Jain keeps the
/// answer on the Moody chart to full precision at no meaningful cost.
///
/// [relativeRoughness] is ε/D, dimensionless.
double darcyFrictionFactor({
  required double reynolds,
  required double relativeRoughness,
}) {
  if (reynolds <= 0) {
    throw const FormatException('Reynolds number must be positive.');
  }
  if (reynolds < _laminarRe) return 64 / reynolds;

  final roughnessTerm = relativeRoughness / 3.7;
  // Swamee–Jain seed, itself an explicit fit to Colebrook.
  final seed = 0.25 /
      math.pow(
        _log10(roughnessTerm + 5.74 / math.pow(reynolds, 0.9)),
        2,
      );
  var x = 1 / math.sqrt(seed);
  for (var i = 0; i < 60; i++) {
    final next = -2 * _log10(roughnessTerm + 2.51 * x / reynolds);
    if ((next - x).abs() < 1e-12) {
      x = next;
      break;
    }
    x = next;
  }
  return 1 / (x * x);
}

double _log10(double v) => math.log(v) / math.ln10;

/// Everything a pipe-run pressure drop needs, in the app's SI display units.
class PipeFlowInput {
  const PipeFlowInput({
    required this.diameter,
    required this.length,
    required this.flowRate,
    required this.density,
    required this.viscosity,
    required this.roughness,
    required this.minorLossK,
  });

  /// Inside diameter, mm.
  final double diameter;

  /// Run length, m.
  final double length;

  /// Volumetric flow rate, L/s.
  final double flowRate;

  /// Fluid density, kg/m³.
  final double density;

  /// Dynamic viscosity, Pa·s.
  final double viscosity;

  /// Absolute wall roughness ε, mm.
  final double roughness;

  /// Summed minor loss coefficients ΣK for fittings, dimensionless.
  final double minorLossK;
}

class PipeFlowResult {
  const PipeFlowResult({
    required this.velocity,
    required this.reynolds,
    required this.regime,
    required this.relativeRoughness,
    required this.frictionFactor,
    required this.frictionHeadLoss,
    required this.minorHeadLoss,
    required this.totalHeadLoss,
    required this.pressureDrop,
    required this.velocityHead,
  });

  /// Mean flow velocity, m/s.
  final double velocity;

  final double reynolds;
  final FlowRegime regime;

  /// ε/D, dimensionless.
  final double relativeRoughness;

  /// Darcy friction factor f, dimensionless.
  final double frictionFactor;

  /// Major (pipe wall) head loss, m of fluid.
  final double frictionHeadLoss;

  /// Minor (fittings) head loss, m of fluid.
  final double minorHeadLoss;

  /// Major + minor, m of fluid.
  final double totalHeadLoss;

  /// Total pressure drop, kPa.
  final double pressureDrop;

  /// V²/2g, m of fluid — the term both loss forms scale with.
  final double velocityHead;
}

/// Darcy–Weisbach pressure drop for a full-running circular pipe:
///
///   h_f = f·(L/D)·V²/(2g),  h_minor = ΣK·V²/(2g),  Δp = ρ·g·h_total
abstract final class PipeFlowCalculator {
  static PipeFlowResult calculate(PipeFlowInput input) {
    if (input.diameter <= 0) {
      throw const FormatException('Inside diameter must be positive.');
    }
    if (input.length < 0) {
      throw const FormatException('Pipe length cannot be negative.');
    }
    if (input.density <= 0) {
      throw const FormatException('Density must be positive.');
    }
    if (input.viscosity <= 0) {
      throw const FormatException('Dynamic viscosity must be positive.');
    }
    if (input.roughness < 0) {
      throw const FormatException('Roughness cannot be negative.');
    }
    if (input.minorLossK < 0) {
      throw const FormatException('Minor loss coefficient cannot be negative.');
    }
    if (input.flowRate <= 0) {
      throw const FormatException('Flow rate must be positive.');
    }

    final diameterM = input.diameter / 1000;
    final roughnessM = input.roughness / 1000;
    final flowM3s = input.flowRate / 1000;

    final area = math.pi * diameterM * diameterM / 4;
    final velocity = flowM3s / area;
    final reynolds = reynoldsNumber(
      velocity: velocity,
      diameter: diameterM,
      density: input.density,
      viscosity: input.viscosity,
    );
    final relativeRoughness = roughnessM / diameterM;
    final frictionFactor = darcyFrictionFactor(
      reynolds: reynolds,
      relativeRoughness: relativeRoughness,
    );

    final velocityHead = velocity * velocity / (2 * gravity);
    final frictionHeadLoss =
        frictionFactor * (input.length / diameterM) * velocityHead;
    final minorHeadLoss = input.minorLossK * velocityHead;
    final totalHeadLoss = frictionHeadLoss + minorHeadLoss;
    // ρ·g·h is in Pa; the app reports pressure in kPa.
    final pressureDrop = input.density * gravity * totalHeadLoss / 1000;

    return PipeFlowResult(
      velocity: velocity,
      reynolds: reynolds,
      regime: regimeFor(reynolds),
      relativeRoughness: relativeRoughness,
      frictionFactor: frictionFactor,
      frictionHeadLoss: frictionHeadLoss,
      minorHeadLoss: minorHeadLoss,
      totalHeadLoss: totalHeadLoss,
      pressureDrop: pressureDrop,
      velocityHead: velocityHead,
    );
  }
}

class ReynoldsResult {
  const ReynoldsResult({
    required this.reynolds,
    required this.regime,
    required this.velocity,
    required this.flowRate,
    required this.kinematicViscosity,
    required this.area,
  });

  final double reynolds;
  final FlowRegime regime;

  /// Mean velocity, m/s.
  final double velocity;

  /// Volumetric flow, L/s.
  final double flowRate;

  /// ν = μ/ρ, m²/s.
  final double kinematicViscosity;

  /// Flow area, mm².
  final double area;
}

/// Reynolds number from either a velocity or a volumetric flow rate, whichever
/// the user has to hand — the other is reported back.
abstract final class ReynoldsCalculator {
  /// Exactly one of [velocity] (m/s) or [flowRate] (L/s) must be given.
  /// [diameter] mm, [density] kg/m³, [viscosity] Pa·s.
  static ReynoldsResult calculate({
    required double diameter,
    required double density,
    required double viscosity,
    double? velocity,
    double? flowRate,
  }) {
    if (diameter <= 0) {
      throw const FormatException('Diameter must be positive.');
    }
    if (density <= 0) {
      throw const FormatException('Density must be positive.');
    }
    if (viscosity <= 0) {
      throw const FormatException('Dynamic viscosity must be positive.');
    }
    if (velocity == null && flowRate == null) {
      throw const FormatException('Enter either a velocity or a flow rate.');
    }

    final diameterM = diameter / 1000;
    final area = math.pi * diameterM * diameterM / 4;
    final resolvedVelocity = velocity ?? (flowRate! / 1000) / area;
    final resolvedFlow = flowRate ?? resolvedVelocity * area * 1000;

    final reynolds = reynoldsNumber(
      velocity: resolvedVelocity,
      diameter: diameterM,
      density: density,
      viscosity: viscosity,
    );

    return ReynoldsResult(
      reynolds: reynolds,
      regime: regimeFor(reynolds),
      velocity: resolvedVelocity,
      flowRate: resolvedFlow,
      kinematicViscosity: viscosity / density,
      // m² -> mm², the app's SI display unit for a component-scale area.
      area: area * 1e6,
    );
  }
}

class PumpPowerResult {
  const PumpPowerResult({
    required this.head,
    required this.hydraulicPower,
    required this.shaftPower,
    required this.lostPower,
  });

  /// Equivalent head of the pumped fluid, m.
  final double head;

  /// Useful work delivered to the fluid, kW.
  final double hydraulicPower;

  /// Power the driver must supply, kW.
  final double shaftPower;

  /// Difference between the two, kW.
  final double lostPower;
}

/// Pump or fan power: P_hyd = Δp·Q, P_shaft = P_hyd/η, with the pressure rise
/// also expressed as a head of the pumped fluid, H = Δp/(ρ·g).
abstract final class PumpPowerCalculator {
  /// [flowRate] L/s, [pressureRise] kPa, [density] kg/m³,
  /// [efficiency] as a percentage.
  static PumpPowerResult calculate({
    required double flowRate,
    required double pressureRise,
    required double density,
    required double efficiency,
  }) {
    if (flowRate <= 0) {
      throw const FormatException('Flow rate must be positive.');
    }
    if (pressureRise <= 0) {
      throw const FormatException('Pressure rise must be positive.');
    }
    if (density <= 0) {
      throw const FormatException('Density must be positive.');
    }
    if (efficiency <= 0 || efficiency > 100) {
      throw const FormatException('Efficiency must be between 0 and 100%.');
    }

    // Δp·Q in base SI is (kPa·1e3)·(L/s·1e-3) = kPa·L/s watts exactly, so the
    // only conversion left is W -> the kW the power category displays.
    final hydraulicPower = pressureRise * flowRate / 1000;
    final shaftPower = hydraulicPower / (efficiency / 100);
    final head = pressureRise * 1000 / (density * gravity);

    return PumpPowerResult(
      head: head,
      hydraulicPower: hydraulicPower,
      shaftPower: shaftPower,
      lostPower: shaftPower - hydraulicPower,
    );
  }
}
