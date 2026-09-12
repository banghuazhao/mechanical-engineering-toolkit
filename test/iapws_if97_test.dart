import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/home/thermodynamics/model/iapws_if97.dart';

/// Relative closeness, for values spanning ten orders of magnitude.
Matcher _rel(double expected, [double tolerance = 1e-8]) =>
    closeTo(expected, expected.abs() * tolerance);

/// One row of an IAPWS-IF97 computer-program verification table.
class _Row {
  const _Row(this.v, this.h, this.u, this.s, this.cp, this.w);
  final double v, h, u, s, cp, w;
}

void _expectRow(SteamProperties state, _Row row) {
  expect(state.specificVolume, _rel(row.v), reason: 'v');
  expect(state.enthalpy, _rel(row.h), reason: 'h');
  expect(state.internalEnergy, _rel(row.u), reason: 'u');
  expect(state.entropy, _rel(row.s), reason: 's');
  expect(state.cp, _rel(row.cp), reason: 'cp');
  expect(state.speedOfSound, _rel(row.w), reason: 'w');
}

void main() {
  // The numbers below are the release's own verification values, quoted to
  // the nine significant figures it gives them. An implementation that
  // reproduces them to 1e-8 has every coefficient right; one that is off in
  // a single digit of a single coefficient does not.
  group('IAPWS-IF97 verification tables', () {
    test('region 1 (table 5)', () {
      _expectRow(
        If97.region1(3, 300),
        const _Row(0.100215168e-2, 0.115331273e3, 0.112324818e3,
            0.392294792, 0.417301218e1, 0.150773921e4),
      );
      _expectRow(
        If97.region1(80, 300),
        const _Row(0.971180894e-3, 0.184142828e3, 0.106448356e3,
            0.368563852, 0.401008987e1, 0.163469054e4),
      );
      _expectRow(
        If97.region1(3, 500),
        const _Row(0.120241800e-2, 0.975542239e3, 0.971934985e3,
            0.258041912e1, 0.465580682e1, 0.124071337e4),
      );
    });

    test('region 2 (table 15)', () {
      _expectRow(
        If97.region2(0.0035, 300),
        const _Row(0.394913866e2, 0.254991145e4, 0.241169160e4,
            0.852238967e1, 0.191300162e1, 0.427920172e3),
      );
      _expectRow(
        If97.region2(0.0035, 700),
        const _Row(0.923015898e2, 0.333568375e4, 0.301262819e4,
            0.101749996e2, 0.208141274e1, 0.644289068e3),
      );
      _expectRow(
        If97.region2(30, 700),
        const _Row(0.542946619e-2, 0.263149474e4, 0.246861076e4,
            0.517540298e1, 0.103505092e2, 0.480386523e3),
      );
    });

    test('region 3 (table 33), in density and temperature', () {
      final a = If97.region3ByDensity(500, 650);
      expect(a.pressure, _rel(0.255837018e2));
      expect(a.enthalpy, _rel(0.186343019e4));
      expect(a.internalEnergy, _rel(0.181226279e4));
      expect(a.entropy, _rel(0.405427273e1));
      expect(a.cp, _rel(0.138935717e2));
      expect(a.speedOfSound, _rel(0.502005554e3));

      final b = If97.region3ByDensity(200, 650);
      expect(b.pressure, _rel(0.222930643e2));
      expect(b.enthalpy, _rel(0.237512401e4));
      expect(b.internalEnergy, _rel(0.226365868e4));
      expect(b.entropy, _rel(0.485438792e1));
      expect(b.cp, _rel(0.446579342e2));
      expect(b.speedOfSound, _rel(0.383444594e3));

      final c = If97.region3ByDensity(500, 750);
      expect(c.pressure, _rel(0.783095639e2));
      expect(c.enthalpy, _rel(0.225868845e4));
      expect(c.internalEnergy, _rel(0.210206932e4));
      expect(c.entropy, _rel(0.446971906e1));
      expect(c.cp, _rel(0.634165359e1));
      expect(c.speedOfSound, _rel(0.760696041e3));
    });

    test('region 3 solves back to the density from pressure', () {
      // The inverse the tools actually use: (p, T) in, density out.
      expect(If97.region3(0.255837018e2, 650).density, _rel(500, 1e-7));
      expect(If97.region3(0.222930643e2, 650).density, _rel(200, 1e-7));
      expect(If97.region3(0.783095639e2, 750).density, _rel(500, 1e-7));
    });

    test('region 4 (tables 35 and 36)', () {
      expect(If97.saturationPressure(300), _rel(0.353658941e-2));
      expect(If97.saturationPressure(500), _rel(0.263889776e1));
      expect(If97.saturationPressure(600), _rel(0.123443146e2));
      expect(If97.saturationTemperature(0.1), _rel(0.372755919e3));
      expect(If97.saturationTemperature(1), _rel(0.453035632e3));
      expect(If97.saturationTemperature(10), _rel(0.584149488e3));
    });

    test('region 5 (table 42)', () {
      _expectRow(
        If97.region5(0.5, 1500),
        const _Row(0.138455090e1, 0.521976855e4, 0.452749310e4,
            0.965408875e1, 0.261609445e1, 0.917068690e3),
      );
      _expectRow(
        If97.region5(30, 1500),
        const _Row(0.230761299e-1, 0.516723514e4, 0.447495124e4,
            0.772970133e1, 0.272724317e1, 0.928548002e3),
      );
      _expectRow(
        If97.region5(30, 2000),
        const _Row(0.311385219e-1, 0.657122604e4, 0.563707038e4,
            0.853640523e1, 0.288569882e1, 0.106736948e4),
      );
    });

    test('B23 boundary (equations 5 and 6)', () {
      expect(If97.b23Pressure(0.62315e3), _rel(0.165291643e2));
      expect(If97.b23Temperature(0.165291643e2), _rel(0.62315e3));
    });
  });

  group('region dispatch', () {
    test('picks the region a textbook would', () {
      expect(If97.regionOf(0.1, 300), 1); // cold water at atmospheric
      expect(If97.regionOf(0.1, 400), 2); // steam at atmospheric
      expect(If97.regionOf(25, 650), 3); // near-critical
      expect(If97.regionOf(30, 900), 2); // above the B23 temperature
      expect(If97.regionOf(1, 1500), 5); // gas-turbine exhaust steam
    });

    test('refuses states the formulation does not cover', () {
      expect(() => If97.regionOf(0.1, 250),
          throwsA(isA<SteamRangeException>()));
      expect(() => If97.regionOf(120, 500),
          throwsA(isA<SteamRangeException>()));
      expect(() => If97.regionOf(60, 1500),
          throwsA(isA<SteamRangeException>()));
      expect(() => If97.regionOf(-1, 300),
          throwsA(isA<SteamRangeException>()));
    });

    test('is continuous across the region boundaries', () {
      // IF97 matches its regions to each other along the boundaries to within
      // 0.2 kJ/kg in enthalpy — the release's own consistency requirement —
      // so a transcription error in one region shows up as a step far larger
      // than that.
      final r1 = If97.region1(40, 623.15).enthalpy;
      final r3 = If97.region3(40, 623.15 + 1e-7).enthalpy;
      expect(r3, closeTo(r1, 0.2));

      final p23 = If97.b23Pressure(700);
      final r2 = If97.region2(p23, 700).enthalpy;
      final r3b = If97.region3(p23 + 1e-7, 700).enthalpy;
      expect(r3b, closeTo(r2, 0.2));

      final r2hot = If97.region2(10, 1073.15).enthalpy;
      final r5 = If97.region5(10, 1073.15).enthalpy;
      expect(r5, closeTo(r2hot, 0.2));
    });
  });

  group('saturation', () {
    test('at 100 °C matches a steam table', () {
      final sat = If97.saturationAtTemperature(373.15);
      expect(sat.pressure * 1000, closeTo(101.42, 0.01)); // kPa
      expect(sat.liquid.enthalpy, closeTo(419.1, 0.2));
      expect(sat.vapour.enthalpy, closeTo(2675.6, 0.5));
      expect(sat.liquid.entropy, closeTo(1.3069, 0.001));
      expect(sat.vapour.entropy, closeTo(7.3545, 0.002));
      expect(sat.vapour.specificVolume, closeTo(1.6718, 0.001));
      expect(sat.hfg, closeTo(2256.5, 0.5));
    });

    test('at 10 MPa matches a steam table', () {
      final sat = If97.saturationAtPressure(10);
      expect(sat.temperature - 273.15, closeTo(311.0, 0.01));
      expect(sat.liquid.enthalpy, closeTo(1407.9, 0.5));
      expect(sat.vapour.enthalpy, closeTo(2725.5, 0.5));
      expect(sat.liquid.entropy, closeTo(3.3603, 0.002));
      expect(sat.vapour.entropy, closeTo(5.6159, 0.002));
      expect(sat.vapour.specificVolume, closeTo(0.01803, 0.0001));
    });

    test('carries on through region 3 to the critical point', () {
      // Above 623.15 K both saturated states are in region 3. They have to
      // join up with the region 1/2 values below it, and close in on each
      // other as the critical point approaches.
      final below = If97.saturationAtTemperature(623.15);
      final above = If97.saturationAtTemperature(623.16);
      expect(above.liquid.enthalpy,
          closeTo(below.liquid.enthalpy, below.liquid.enthalpy * 0.002));
      expect(above.vapour.enthalpy,
          closeTo(below.vapour.enthalpy, below.vapour.enthalpy * 0.002));

      final near = If97.saturationAtTemperature(646);
      expect(near.liquid.density, greaterThan(If97.rhoc));
      expect(near.vapour.density, lessThan(If97.rhoc));
      expect(near.hfg, greaterThan(0));
      expect(near.hfg, lessThan(below.hfg));

      final critical = If97.saturationAtPressure(If97.pc);
      expect(critical.hfg, closeTo(0, 1e-9));
    });

    test('refuses a pressure above the critical point', () {
      expect(() => If97.saturationAtPressure(25),
          throwsA(isA<SteamRangeException>()));
    });
  });

  group('inverses', () {
    test('superheated steam at 8 MPa, 500 °C, and back', () {
      final state = If97.state(8, 773.15);
      expect(state.enthalpy, closeTo(3399.5, 0.5));
      expect(state.entropy, closeTo(6.7266, 0.002));
      expect(state.specificVolume, closeTo(0.04177, 0.0001));

      final fromS = If97.stateFromPressureEntropy(8, state.entropy);
      expect(fromS.isMixture, isFalse);
      expect(fromS.temperature, closeTo(773.15, 1e-6));

      final fromH = If97.stateFromPressureEnthalpy(8, state.enthalpy);
      expect(fromH.temperature, closeTo(773.15, 1e-6));
    });

    test('isentropic expansion into the dome gives a quality', () {
      // Çengel, simple ideal Rankine example: 3 MPa and 350 °C expanded to
      // 75 kPa leaves steam of quality 0.886.
      final inlet = If97.state(3, 623.15);
      expect(inlet.enthalpy, closeTo(3116.1, 0.5));
      expect(inlet.entropy, closeTo(6.7450, 0.002));
      final outlet = If97.stateFromPressureEntropy(0.075, inlet.entropy);
      expect(outlet.isMixture, isTrue);
      expect(outlet.quality, closeTo(0.8861, 0.001));
      expect(outlet.enthalpy, closeTo(2403.0, 1.0));
    });

    test('compressed liquid and supercritical states invert too', () {
      final liquid = If97.state(20, 373.15);
      final back = If97.stateFromPressureEnthalpy(20, liquid.enthalpy);
      expect(back.temperature, closeTo(373.15, 1e-6));

      final supercritical = If97.state(30, 700);
      final back2 = If97.stateFromPressureEntropy(30, supercritical.entropy);
      expect(back2.temperature, closeTo(700, 1e-6));
    });

    test('a quality turns into the matching mixture', () {
      final point = If97.stateFromPressureQuality(0.1, 0.5);
      final sat = If97.saturationAtPressure(0.1);
      expect(point.enthalpy,
          closeTo((sat.liquid.enthalpy + sat.vapour.enthalpy) / 2, 1e-9));
      expect(() => If97.stateFromPressureQuality(0.1, 1.2),
          throwsA(isA<SteamRangeException>()));
    });
  });
}
