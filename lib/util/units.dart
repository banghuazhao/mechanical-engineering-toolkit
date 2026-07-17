import 'dart:math' as math;

import 'unit_system.dart';

// Length
double mm2m(double v) => v * 0.001;
double m2mm(double v) => v * 1000;
double cm2m(double v) => v * 0.01;
double m2cm(double v) => v * 100;
double km2m(double v) => v * 1000;
double m2km(double v) => v * 0.001;
double in2m(double v) => v * 0.0254;
double m2in(double v) => v / 0.0254;
double ft2m(double v) => v * 0.3048;
double m2ft(double v) => v / 0.3048;
double yd2m(double v) => v * 0.9144;
double m2yd(double v) => v / 0.9144;
double mi2m(double v) => v * 1609.344;
double m2mi(double v) => v / 1609.344;
double mm2in(double v) => v / 25.4;
double in2mm(double v) => v * 25.4;
// Force
double kN2N(double v) => v * 1e3;
double N2kN(double v) => v * 1e-3;
double MN2N(double v) => v * 1e6;
double N2MN(double v) => v * 1e-6;
double lbf2N(double v) => v * 4.44822;
double N2lbf(double v) => v / 4.44822;
double kip2N(double v) => v * 4448.22;
double N2kip(double v) => v / 4448.22;
// Distributed load (force / length): N/m <-> lbf/ft
double Npm2lbfpft(double v) => v / 14.5939;
double lbfpft2Npm(double v) => v * 14.5939;
// Stress / pressure
double kPa2Pa(double v) => v * 1e3;
double Pa2kPa(double v) => v * 1e-3;
double MPa2Pa(double v) => v * 1e6;
double Pa2MPa(double v) => v * 1e-6;
double GPa2Pa(double v) => v * 1e9;
double Pa2GPa(double v) => v * 1e-9;
double psi2Pa(double v) => v * 6894.76;
double Pa2psi(double v) => v / 6894.76;
double ksi2Pa(double v) => v * 6.89476e6;
double Pa2ksi(double v) => v / 6.89476e6;
double atm2Pa(double v) => v * 101325;
double Pa2atm(double v) => v / 101325;
double bar2Pa(double v) => v * 1e5;
double Pa2bar(double v) => v * 1e-5;
double MPa2ksi(double v) => v * 1e6 / 6.89476e6;
double ksi2MPa(double v) => v * 6.89476e6 / 1e6;
double GPa2Mpsi(double v) => v * 1e9 / 6894.76e6;
double Mpsi2GPa(double v) => v * 6894.76e6 / 1e9;
// Mass
double g2kg(double v) => v * 0.001;
double kg2g(double v) => v * 1000;
double t2kg(double v) => v * 1000;
double kg2t(double v) => v * 0.001;
double oz2kg(double v) => v * 0.0283495;
double kg2oz(double v) => v / 0.0283495;
double lb2kg(double v) => v * 0.453592;
double kg2lb(double v) => v / 0.453592;
double slug2kg(double v) => v * 14.5939;
double kg2slug(double v) => v / 14.5939;
// Density
double kgm3_2_lbft3(double v) => v / 16.0185;
double lbft3_2_kgm3(double v) => v * 16.0185;
// Temperature (absolute, base = degC)
double F2C(double v) => (v - 32) * 5 / 9;
double C2F(double v) => v * 9 / 5 + 32;
double K2C(double v) => v - 273.15;
double C2K(double v) => v + 273.15;
// Temperature delta (ratio-only, no offset)
double dC2dF(double v) => v * 9 / 5;
double dF2dC(double v) => v * 5 / 9;
// Torque / moment
double kNm2Nm(double v) => v * 1000;
double Nm2kNm(double v) => v * 0.001;
double lbfft2Nm(double v) => v * 1.35582;
double Nm2lbfft(double v) => v / 1.35582;
double lbfin2Nm(double v) => v * 0.112985;
double Nm2lbfin(double v) => v / 0.112985;
// Power
double kW2W(double v) => v * 1000;
double W2kW(double v) => v * 0.001;
double MW2W(double v) => v * 1e6;
double W2MW(double v) => v * 1e-6;
double hp2W(double v) => v * 745.7;
double W2hp(double v) => v / 745.7;
double kW2hp(double v) => v * 1000 / 745.7;
double hp2kW(double v) => v * 745.7 / 1000;
// Angular velocity
double rpm2rads(double v) => v * math.pi / 30;
double rads2rpm(double v) => v * 30 / math.pi;
double degs2rads(double v) => v * math.pi / 180;
double rads2degs(double v) => v * 180 / math.pi;
// Angle
double deg2rad(double v) => v * math.pi / 180;
double rad2deg(double v) => v * 180 / math.pi;
// Area
double mm2_2_in2(double v) => v / 645.16;
double in2_2_mm2(double v) => v * 645.16;
// Area (structural scale): m^2 <-> ft^2
double m2_2_ft2(double v) => v / 0.09290304;
double ft2_2_m2(double v) => v * 0.09290304;
// Moment of inertia (length^4)
double mm4_2_in4(double v) => v / 416231.4256;
double in4_2_mm4(double v) => v * 416231.4256;
// Section modulus (length^3)
double mm3_2_in3(double v) => v / 16387.064;
double in3_2_mm3(double v) => v * 16387.064;
// Moment/torque at cross-section scale (force * mm): N·mm <-> lbf·in
double Nmm2lbfin(double v) => v / 112.985;
double lbfin2Nmm(double v) => v * 112.985;
// Distributed load at cross-section scale (force / mm): N/mm <-> lbf/in
double Npmm2lbfpin(double v) => v / 0.175127;
double lbfpin2Npmm(double v) => v * 0.175127;
// Identity
double id(double v) => v;

/// A physical quantity category with a fixed SI display unit and a fixed
/// Imperial display unit. These are the two units the app switches between
/// (not the full multi-unit list used by the standalone Unit Converter tool).
enum UnitCategory {
  /// Small lengths: cross-section dimensions, thicknesses, deflections.
  length,

  /// Larger lengths: beam/member spans.
  span,

  /// Concentrated force / point load (component-scale: N / lbf).
  force,

  /// Concentrated force / point load (structural-scale: kN / kip).
  forceStructural,

  /// Distributed load, force per unit length (component-scale: N/m / lbf/ft).
  distributedLoad,

  /// Distributed load, force per unit length (structural-scale: kN/m / kip/ft).
  distributedLoadStructural,

  /// Stress or pressure.
  stress,

  /// Elastic modulus (E, G) — large stiffness values.
  modulus,

  /// Torque (component-scale: N·m / lbf·ft).
  torque,

  /// Bending moment (structural-scale: kN·m / kip·ft).
  momentStructural,

  /// Torque or bending moment at cross-section scale (N·mm / lbf·in) —
  /// used by "quick formula" tools whose other quantities are already
  /// mm-based (length in mm, moment of inertia in mm⁴, stress in MPa), where
  /// [torque]'s N·m would be 1000x too large to stay dimensionally
  /// consistent. See e.g. τ = T·r/Ip or σ = M·y/I.
  momentSection,

  /// Distributed load at cross-section scale (N/mm / lbf/in) — the mm-scale
  /// counterpart of [distributedLoad] (N/m), for formulas whose length terms
  /// are in mm rather than m.
  distributedLoadSmall,

  /// Second moment of area (I).
  momentOfInertia,

  /// Section modulus (S).
  sectionModulus,

  /// Area (component-scale: mm² / in²).
  area,

  /// Area (structural-scale: m² / ft²).
  areaStructural,

  /// Angle — same unit (degrees) in both systems.
  angle,

  /// Absolute temperature.
  temperature,

  /// Temperature difference (ratio-only conversion, no 32° offset).
  temperatureDelta,

  /// Power.
  power,

  /// Angular velocity.
  angularVelocity,

  /// Density.
  density,
}

class _UnitPair {
  final String siLabel;
  final String imperialLabel;
  final double Function(double) siToImperial;
  final double Function(double) imperialToSi;

  const _UnitPair({
    required this.siLabel,
    required this.imperialLabel,
    required this.siToImperial,
    required this.imperialToSi,
  });
}

final Map<UnitCategory, _UnitPair> _pairs = {
  UnitCategory.length: _UnitPair(
    siLabel: 'mm',
    imperialLabel: 'in',
    siToImperial: mm2in,
    imperialToSi: in2mm,
  ),
  UnitCategory.span: _UnitPair(
    siLabel: 'm',
    imperialLabel: 'ft',
    siToImperial: m2ft,
    imperialToSi: ft2m,
  ),
  UnitCategory.force: _UnitPair(
    siLabel: 'N',
    imperialLabel: 'lbf',
    siToImperial: N2lbf,
    imperialToSi: lbf2N,
  ),
  UnitCategory.forceStructural: _UnitPair(
    siLabel: 'kN',
    imperialLabel: 'kip',
    siToImperial: N2lbf,
    imperialToSi: lbf2N,
  ),
  UnitCategory.distributedLoad: _UnitPair(
    siLabel: 'N/m',
    imperialLabel: 'lbf/ft',
    siToImperial: Npm2lbfpft,
    imperialToSi: lbfpft2Npm,
  ),
  UnitCategory.distributedLoadStructural: _UnitPair(
    siLabel: 'kN/m',
    imperialLabel: 'kip/ft',
    siToImperial: Npm2lbfpft,
    imperialToSi: lbfpft2Npm,
  ),
  UnitCategory.stress: _UnitPair(
    siLabel: 'MPa',
    imperialLabel: 'ksi',
    siToImperial: MPa2ksi,
    imperialToSi: ksi2MPa,
  ),
  UnitCategory.modulus: _UnitPair(
    siLabel: 'GPa',
    imperialLabel: 'Mpsi',
    siToImperial: GPa2Mpsi,
    imperialToSi: Mpsi2GPa,
  ),
  UnitCategory.torque: _UnitPair(
    siLabel: 'N·m',
    imperialLabel: 'lbf·ft',
    siToImperial: Nm2lbfft,
    imperialToSi: lbfft2Nm,
  ),
  UnitCategory.momentStructural: _UnitPair(
    siLabel: 'kN·m',
    imperialLabel: 'kip·ft',
    siToImperial: Nm2lbfft,
    imperialToSi: lbfft2Nm,
  ),
  UnitCategory.momentSection: _UnitPair(
    siLabel: 'N·mm',
    imperialLabel: 'lbf·in',
    siToImperial: Nmm2lbfin,
    imperialToSi: lbfin2Nmm,
  ),
  UnitCategory.distributedLoadSmall: _UnitPair(
    siLabel: 'N/mm',
    imperialLabel: 'lbf/in',
    siToImperial: Npmm2lbfpin,
    imperialToSi: lbfpin2Npmm,
  ),
  UnitCategory.momentOfInertia: _UnitPair(
    siLabel: 'mm⁴',
    imperialLabel: 'in⁴',
    siToImperial: mm4_2_in4,
    imperialToSi: in4_2_mm4,
  ),
  UnitCategory.sectionModulus: _UnitPair(
    siLabel: 'mm³',
    imperialLabel: 'in³',
    siToImperial: mm3_2_in3,
    imperialToSi: in3_2_mm3,
  ),
  UnitCategory.area: _UnitPair(
    siLabel: 'mm²',
    imperialLabel: 'in²',
    siToImperial: mm2_2_in2,
    imperialToSi: in2_2_mm2,
  ),
  UnitCategory.areaStructural: _UnitPair(
    siLabel: 'm²',
    imperialLabel: 'ft²',
    siToImperial: m2_2_ft2,
    imperialToSi: ft2_2_m2,
  ),
  UnitCategory.angle: _UnitPair(
    siLabel: '°',
    imperialLabel: '°',
    siToImperial: id,
    imperialToSi: id,
  ),
  UnitCategory.temperature: _UnitPair(
    siLabel: '°C',
    imperialLabel: '°F',
    siToImperial: C2F,
    imperialToSi: F2C,
  ),
  UnitCategory.temperatureDelta: _UnitPair(
    siLabel: '°C',
    imperialLabel: '°F',
    siToImperial: dC2dF,
    imperialToSi: dF2dC,
  ),
  UnitCategory.power: _UnitPair(
    siLabel: 'kW',
    imperialLabel: 'hp',
    siToImperial: kW2hp,
    imperialToSi: hp2kW,
  ),
  UnitCategory.angularVelocity: _UnitPair(
    siLabel: 'rpm',
    imperialLabel: 'rpm',
    siToImperial: id,
    imperialToSi: id,
  ),
  UnitCategory.density: _UnitPair(
    siLabel: 'kg/m³',
    imperialLabel: 'lb/ft³',
    siToImperial: kgm3_2_lbft3,
    imperialToSi: lbft3_2_kgm3,
  ),
};

String unitLabel(UnitCategory category, UnitSystem system) {
  final pair = _pairs[category]!;
  return system == UnitSystem.si ? pair.siLabel : pair.imperialLabel;
}

/// Converts [value], expressed in the unit of [from], to the app's SI
/// display unit for [category].
double toSI(double value, UnitCategory category, UnitSystem from) {
  if (from == UnitSystem.si) return value;
  return _pairs[category]!.imperialToSi(value);
}

/// Converts [siValue], expressed in the app's SI display unit for
/// [category], to the unit of [to].
double fromSI(double siValue, UnitCategory category, UnitSystem to) {
  if (to == UnitSystem.si) return siValue;
  return _pairs[category]!.siToImperial(siValue);
}
