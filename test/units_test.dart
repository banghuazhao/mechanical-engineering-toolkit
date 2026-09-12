import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Relative tolerance for a value that has been through one multiply and one
/// divide by the same constant — a couple of ulps at most.
Matcher _closeRel(double expected, [double rel = 1e-9]) =>
    closeTo(expected, math.max(1e-12, expected.abs() * rel));

/// One hand-checked conversion per [UnitCategory], pinning both the factor and
/// the unit labels. Pinning them together is the point: a category whose label
/// says `kN` but whose factor is the one for `N` is exactly the silent 1000x
/// error this table is here to catch.
class _Known {
  const _Known({
    required this.si,
    required this.imperial,
    required this.siLabel,
    required this.imperialLabel,
  });

  final double si;
  final double imperial;
  final String siLabel;
  final String imperialLabel;
}

const Map<UnitCategory, _Known> _known = {
  UnitCategory.length: _Known(
    si: 25.4, imperial: 1, siLabel: 'mm', imperialLabel: 'in', // 1 in = 25.4 mm
  ),
  UnitCategory.span: _Known(
    si: 3.048, imperial: 10, siLabel: 'm', imperialLabel: 'ft', // 1 ft = .3048 m
  ),
  UnitCategory.force: _Known(
    si: 4.44822, imperial: 1, siLabel: 'N', imperialLabel: 'lbf',
  ),
  UnitCategory.forceStructural: _Known(
    si: 4.44822, imperial: 1, siLabel: 'kN', imperialLabel: 'kip',
  ),
  UnitCategory.distributedLoad: _Known(
    si: 14.5939, imperial: 1, siLabel: 'N/m', imperialLabel: 'lbf/ft',
  ),
  UnitCategory.distributedLoadStructural: _Known(
    si: 14.5939, imperial: 1, siLabel: 'kN/m', imperialLabel: 'kip/ft',
  ),
  UnitCategory.stress: _Known(
    si: 6.89476, imperial: 1, siLabel: 'MPa', imperialLabel: 'ksi',
  ),
  UnitCategory.modulus: _Known(
    si: 6.89476, imperial: 1, siLabel: 'GPa', imperialLabel: 'Mpsi',
  ),
  UnitCategory.torque: _Known(
    si: 1.35582, imperial: 1, siLabel: 'N·m', imperialLabel: 'lbf·ft',
  ),
  UnitCategory.momentStructural: _Known(
    si: 1.35582, imperial: 1, siLabel: 'kN·m', imperialLabel: 'kip·ft',
  ),
  UnitCategory.momentSection: _Known(
    si: 112.985, imperial: 1, siLabel: 'N·mm', imperialLabel: 'lbf·in',
  ),
  UnitCategory.distributedLoadSmall: _Known(
    si: 0.175127, imperial: 1, siLabel: 'N/mm', imperialLabel: 'lbf/in',
  ),
  UnitCategory.momentOfInertia: _Known(
    si: 416231.4256, imperial: 1, siLabel: 'mm⁴', imperialLabel: 'in⁴', // 25.4^4
  ),
  UnitCategory.sectionModulus: _Known(
    si: 16387.064, imperial: 1, siLabel: 'mm³', imperialLabel: 'in³', // 25.4^3
  ),
  UnitCategory.area: _Known(
    si: 645.16, imperial: 1, siLabel: 'mm²', imperialLabel: 'in²', // 25.4^2
  ),
  UnitCategory.areaStructural: _Known(
    si: 0.09290304, imperial: 1, siLabel: 'm²', imperialLabel: 'ft²', // .3048^2
  ),
  UnitCategory.angle: _Known(
    si: 45, imperial: 45, siLabel: '°', imperialLabel: '°',
  ),
  UnitCategory.temperature: _Known(
    si: 100, imperial: 212, siLabel: '°C', imperialLabel: '°F',
  ),
  UnitCategory.temperatureDelta: _Known(
    si: 100, imperial: 180, siLabel: '°C', imperialLabel: '°F', // no 32° offset
  ),
  UnitCategory.power: _Known(
    si: 0.7457, imperial: 1, siLabel: 'kW', imperialLabel: 'hp',
  ),
  UnitCategory.angularVelocity: _Known(
    si: 1750, imperial: 1750, siLabel: 'rpm', imperialLabel: 'rpm',
  ),
  UnitCategory.density: _Known(
    si: 16.0185, imperial: 1, siLabel: 'kg/m³', imperialLabel: 'lb/ft³',
  ),
  UnitCategory.mass: _Known(
    si: 0.453592, imperial: 1, siLabel: 'kg', imperialLabel: 'lb',
  ),
  UnitCategory.linearDensity: _Known(
    // 1 lb/ft = 0.45359237 kg / 0.3048 m.
    si: 1.4881639436, imperial: 1, siLabel: 'kg/m', imperialLabel: 'lb/ft',
  ),
  UnitCategory.massMomentOfInertia: _Known(
    // 1 lb·ft² = 0.45359237 kg · 0.3048² m².
    si: 0.04214011, imperial: 1, siLabel: 'kg·m²', imperialLabel: 'lb·ft²',
  ),
  UnitCategory.frequency: _Known(
    si: 60, imperial: 60, siLabel: 'Hz', imperialLabel: 'Hz',
  ),
  UnitCategory.angularFrequency: _Known(
    si: 314.159, imperial: 314.159,
    siLabel: 'rad/s', imperialLabel: 'rad/s',
  ),
  UnitCategory.velocity: _Known(
    si: 0.3048, imperial: 1, siLabel: 'm/s', imperialLabel: 'ft/s',
  ),
  UnitCategory.volumeFlow: _Known(
    // 1 US gal = 3.785411784 L exactly, so 1 gpm = that over 60 s.
    si: 0.0630901964, imperial: 1, siLabel: 'L/s', imperialLabel: 'gpm',
  ),
  UnitCategory.dynamicViscosity: _Known(
    // 1 lb/(ft·s) = 0.45359237 kg / (0.3048 m · s).
    si: 1.4881639436, imperial: 1,
    siLabel: 'Pa·s', imperialLabel: 'lb/(ft·s)',
  ),
  UnitCategory.pressure: _Known(
    si: 6.89476, imperial: 1, siLabel: 'kPa', imperialLabel: 'psi',
  ),
  UnitCategory.thermalConductivity: _Known(
    si: 1.730735, imperial: 1,
    siLabel: 'W/(m·K)', imperialLabel: 'BTU/(h·ft·°F)',
  ),
  UnitCategory.heatTransferCoefficient: _Known(
    si: 5.678263, imperial: 1,
    siLabel: 'W/(m²·K)', imperialLabel: 'BTU/(h·ft²·°F)',
  ),
  UnitCategory.heatFlow: _Known(
    // 1 BTU = 1055.056 J, so 1 W = 3600/1055.056 BTU/h.
    si: 1, imperial: 3.412142, siLabel: 'W', imperialLabel: 'BTU/h',
  ),
  UnitCategory.specificEnergy: _Known(
    // 1 BTU/lb = 2.326 kJ/kg exactly (International Table BTU) — which is
    // why saturated steam at 212 °F reads 1150.3 BTU/lb against 2675.6.
    si: 2.326, imperial: 1, siLabel: 'kJ/kg', imperialLabel: 'BTU/lb',
  ),
  UnitCategory.specificEntropy: _Known(
    // 1 BTU/(lb·°R) = 4.1868 kJ/(kg·K) exactly, so air's cp of 1.005 reads
    // 0.240 in Imperial tables.
    si: 4.1868, imperial: 1, siLabel: 'kJ/(kg·K)',
    imperialLabel: 'BTU/(lb·°R)',
  ),
  UnitCategory.specificVolume: _Known(
    // 1 ft³/lb = 0.028316846592 m³ / 0.45359237 kg.
    si: 0.0624279605761, imperial: 1, siLabel: 'm³/kg', imperialLabel: 'ft³/lb',
  ),
  UnitCategory.volume: _Known(
    // 1 ft = 0.3048 m, cubed.
    si: 0.028316846592, imperial: 1, siLabel: 'm³', imperialLabel: 'ft³',
  ),
  UnitCategory.energy: _Known(
    si: 1.05505585262, imperial: 1, siLabel: 'kJ', imperialLabel: 'BTU',
  ),
  UnitCategory.entropy: _Known(
    // 1 BTU/°R = 1.05505585262 kJ per 5/9 K.
    si: 1.899100534716, imperial: 1, siLabel: 'kJ/K', imperialLabel: 'BTU/°R',
  ),
  UnitCategory.massFlow: _Known(
    si: 0.45359237, imperial: 1, siLabel: 'kg/s', imperialLabel: 'lb/s',
  ),
};

/// Categories whose two systems share a unit, so conversion must be exact
/// identity rather than merely close.
const _identityCategories = {
  UnitCategory.angle,
  UnitCategory.angularVelocity,
  UnitCategory.frequency,
  UnitCategory.angularFrequency,
};

/// Round-trip probes. Chosen to span the magnitudes real inputs cover, and to
/// include zero and negatives (deflections, compressive stresses, sub-zero
/// temperatures all go negative in practice).
const _probes = <double>[0, 1, -1, 0.001, -0.25, 12.5, 1234.5, -6789.25, 1e6];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UnitCategory table', () {
    test('every category has a conversion pair and non-empty labels', () {
      for (final category in UnitCategory.values) {
        for (final system in UnitSystem.values) {
          final label = unitLabel(category, system);
          expect(label, isNotEmpty, reason: 'no label for $category/$system');
          // Would throw on a category missing from the internal pair map.
          expect(toSI(1, category, system), isA<double>());
          expect(fromSI(1, category, system), isA<double>());
        }
      }
    });

    test('the known-value table covers every category', () {
      expect(
        _known.keys.toSet(),
        equals(UnitCategory.values.toSet()),
        reason: 'a new UnitCategory needs a hand-checked row in _known',
      );
    });
  });

  group('SI is the identity system', () {
    test('toSI and fromSI leave SI values untouched, bit for bit', () {
      for (final category in UnitCategory.values) {
        for (final v in _probes) {
          expect(toSI(v, category, UnitSystem.si), equals(v));
          expect(fromSI(v, category, UnitSystem.si), equals(v));
        }
      }
    });
  });

  group('known conversions', () {
    _known.forEach((category, known) {
      test('${category.name}: ${known.si} ${known.siLabel} '
          '= ${known.imperial} ${known.imperialLabel}', () {
        expect(
          fromSI(known.si, category, UnitSystem.imperial),
          _closeRel(known.imperial),
        );
        expect(
          toSI(known.imperial, category, UnitSystem.imperial),
          _closeRel(known.si),
        );
        expect(unitLabel(category, UnitSystem.si), known.siLabel);
        expect(unitLabel(category, UnitSystem.imperial), known.imperialLabel);
      });
    });
  });

  group('round trips', () {
    for (final category in UnitCategory.values) {
      test('${category.name} survives SI -> imperial -> SI', () {
        for (final v in _probes) {
          final there = fromSI(v, category, UnitSystem.imperial);
          final back = toSI(there, category, UnitSystem.imperial);
          expect(back, _closeRel(v),
              reason: '$category lost precision round-tripping $v');
        }
      });

      test('${category.name} survives imperial -> SI -> imperial', () {
        for (final v in _probes) {
          final there = toSI(v, category, UnitSystem.imperial);
          final back = fromSI(there, category, UnitSystem.imperial);
          expect(back, _closeRel(v),
              reason: '$category lost precision round-tripping $v');
        }
      });
    }

    test('identity categories round-trip exactly, not just closely', () {
      for (final category in _identityCategories) {
        for (final v in _probes) {
          expect(fromSI(v, category, UnitSystem.imperial), equals(v));
          expect(toSI(v, category, UnitSystem.imperial), equals(v));
        }
      }
    });
  });

  // The app deliberately carries two scales of several quantities (N vs kN,
  // N·m vs N·mm, mm² vs m²) so that each formula's terms stay dimensionally
  // consistent. If a scale variant ever drifts from its sibling, results come
  // out off by a clean factor of 1000 or 12 — plausible-looking and easy to
  // miss. These pin the siblings to each other.
  group('scale variants stay coherent with their siblings', () {
    const imperial = UnitSystem.imperial;

    test('kN -> kip matches N -> lbf', () {
      expect(
        fromSI(1, UnitCategory.forceStructural, imperial),
        _closeRel(fromSI(1, UnitCategory.force, imperial)),
      );
    });

    test('kN/m -> kip/ft matches N/m -> lbf/ft', () {
      expect(
        fromSI(1, UnitCategory.distributedLoadStructural, imperial),
        _closeRel(fromSI(1, UnitCategory.distributedLoad, imperial)),
      );
    });

    test('kN·m -> kip·ft matches N·m -> lbf·ft', () {
      expect(
        fromSI(1, UnitCategory.momentStructural, imperial),
        _closeRel(fromSI(1, UnitCategory.torque, imperial)),
      );
    });

    test('1000 N·mm reads as 12x the lbf·in of 1 N·m in lbf·ft', () {
      // 1 N·m = 1000 N·mm and 1 lbf·ft = 12 lbf·in.
      expect(
        fromSI(1000, UnitCategory.momentSection, imperial),
        _closeRel(fromSI(1, UnitCategory.torque, imperial) * 12, 1e-5),
      );
    });

    test('1000 N/m reads as 1/12 the lbf/in of 1 N/mm', () {
      // 1 N/mm = 1000 N/m and 1 lbf/in = 12 lbf/ft.
      expect(
        fromSI(1, UnitCategory.distributedLoadSmall, imperial),
        _closeRel(
            fromSI(1000, UnitCategory.distributedLoad, imperial) / 12, 1e-5),
      );
    });

    test('1e6 mm² reads as 144x the in² of 1 m² in ft²', () {
      // 1 m² = 1e6 mm² and 1 ft² = 144 in².
      expect(
        fromSI(1e6, UnitCategory.area, imperial),
        _closeRel(fromSI(1, UnitCategory.areaStructural, imperial) * 144, 1e-5),
      );
    });

    test('GPa -> Mpsi matches MPa -> ksi', () {
      // 1 GPa = 1000 MPa and 1 Mpsi = 1000 ksi.
      expect(
        fromSI(1, UnitCategory.modulus, imperial),
        _closeRel(fromSI(1000, UnitCategory.stress, imperial) / 1000, 1e-5),
      );
    });

    test('area categories agree with their length categories squared', () {
      // in² from mm² must be the square of in from mm.
      final lengthFactor = fromSI(1, UnitCategory.length, imperial);
      expect(
        fromSI(1, UnitCategory.area, imperial),
        _closeRel(lengthFactor * lengthFactor, 1e-6),
      );
      // ft² from m² must be the square of ft from m.
      final spanFactor = fromSI(1, UnitCategory.span, imperial);
      expect(
        fromSI(1, UnitCategory.areaStructural, imperial),
        _closeRel(spanFactor * spanFactor, 1e-6),
      );
    });

    test('velocity converts by the same factor as a structural span', () {
      // m/s -> ft/s is just m -> ft; a drift between them would put a pipe
      // velocity and the pipe's own length on different scales.
      expect(
        fromSI(1, UnitCategory.velocity, imperial),
        _closeRel(fromSI(1, UnitCategory.span, imperial)),
      );
    });

    test('h divided by a length gives k, in both systems', () {
      // h = k/L is the defining relation between the two; if the factors ever
      // drift apart, a conduction result and a convection result stop adding
      // up in a resistance network. Length here is the span category (m/ft).
      expect(
        fromSI(1, UnitCategory.heatTransferCoefficient, imperial),
        _closeRel(
          fromSI(1, UnitCategory.thermalConductivity, imperial) /
              fromSI(1, UnitCategory.span, imperial),
          1e-5,
        ),
      );
    });

    test('I and S agree with the length category to the 4th and 3rd power', () {
      final f = fromSI(1, UnitCategory.length, imperial);
      expect(
        fromSI(1, UnitCategory.momentOfInertia, imperial),
        _closeRel(math.pow(f, 4).toDouble(), 1e-6),
      );
      expect(
        fromSI(1, UnitCategory.sectionModulus, imperial),
        _closeRel(math.pow(f, 3).toDouble(), 1e-6),
      );
    });
  });

  group('temperature', () {
    const imperial = UnitSystem.imperial;

    test('absolute temperature carries the 32° offset', () {
      expect(fromSI(0, UnitCategory.temperature, imperial), _closeRel(32));
      expect(fromSI(100, UnitCategory.temperature, imperial), _closeRel(212));
      expect(fromSI(-40, UnitCategory.temperature, imperial), _closeRel(-40));
      expect(toSI(32, UnitCategory.temperature, imperial), _closeRel(0));
      expect(toSI(212, UnitCategory.temperature, imperial), _closeRel(100));
    });

    test('a temperature *difference* does not carry the offset', () {
      // The whole reason temperatureDelta exists: ΔT = 0 is 0, not 32.
      expect(fromSI(0, UnitCategory.temperatureDelta, imperial), equals(0));
      expect(fromSI(1, UnitCategory.temperatureDelta, imperial), _closeRel(1.8));
      expect(
          fromSI(100, UnitCategory.temperatureDelta, imperial), _closeRel(180));
      expect(toSI(180, UnitCategory.temperatureDelta, imperial), _closeRel(100));
    });

    test('the two temperature categories are genuinely different', () {
      expect(
        fromSI(0, UnitCategory.temperature, imperial),
        isNot(_closeRel(fromSI(0, UnitCategory.temperatureDelta, imperial))),
      );
    });

    test('Celsius/Kelvin and Celsius/Fahrenheit agree at the fixed points', () {
      expect(C2K(0), _closeRel(273.15));
      expect(K2C(373.15), _closeRel(100));
      expect(F2C(-40), _closeRel(-40));
      expect(C2F(37), _closeRel(98.6));
    });
  });

  // The standalone Unit Converter tool uses these raw functions directly rather
  // than going through UnitCategory, so they need their own coverage.
  group('raw converters', () {
    final pairs = <String, List<Object>>{
      // name: [forward, inverse, input, expected forward output]
      'mm->m': [mm2m, m2mm, 1500.0, 1.5],
      'cm->m': [cm2m, m2cm, 250.0, 2.5],
      'km->m': [km2m, m2km, 2.5, 2500.0],
      'in->m': [in2m, m2in, 1.0, 0.0254],
      'ft->m': [ft2m, m2ft, 1.0, 0.3048],
      'yd->m': [yd2m, m2yd, 1.0, 0.9144],
      'mi->m': [mi2m, m2mi, 1.0, 1609.344],
      'mm->in': [mm2in, in2mm, 25.4, 1.0],
      'kN->N': [kN2N, N2kN, 2.5, 2500.0],
      'MN->N': [MN2N, N2MN, 1.5, 1.5e6],
      'lbf->N': [lbf2N, N2lbf, 1.0, 4.44822],
      'kip->N': [kip2N, N2kip, 1.0, 4448.22],
      'kPa->Pa': [kPa2Pa, Pa2kPa, 2.5, 2500.0],
      'MPa->Pa': [MPa2Pa, Pa2MPa, 1.5, 1.5e6],
      'GPa->Pa': [GPa2Pa, Pa2GPa, 200.0, 2e11],
      'psi->Pa': [psi2Pa, Pa2psi, 1.0, 6894.76],
      'ksi->Pa': [ksi2Pa, Pa2ksi, 1.0, 6.89476e6],
      'atm->Pa': [atm2Pa, Pa2atm, 1.0, 101325.0],
      'bar->Pa': [bar2Pa, Pa2bar, 1.0, 1e5],
      'ksi->MPa': [ksi2MPa, MPa2ksi, 1.0, 6.89476],
      'Mpsi->GPa': [Mpsi2GPa, GPa2Mpsi, 1.0, 6.89476],
      'g->kg': [g2kg, kg2g, 1500.0, 1.5],
      't->kg': [t2kg, kg2t, 2.5, 2500.0],
      'oz->kg': [oz2kg, kg2oz, 1.0, 0.0283495],
      'lb->kg': [lb2kg, kg2lb, 1.0, 0.453592],
      'slug->kg': [slug2kg, kg2slug, 1.0, 14.5939],
      'lb/ft³->kg/m³': [lbft3_2_kgm3, kgm3_2_lbft3, 1.0, 16.0185],
      'kNm->Nm': [kNm2Nm, Nm2kNm, 2.5, 2500.0],
      'lbf·ft->Nm': [lbfft2Nm, Nm2lbfft, 1.0, 1.35582],
      'lbf·in->Nm': [lbfin2Nm, Nm2lbfin, 1.0, 0.112985],
      'lbf·in->Nmm': [lbfin2Nmm, Nmm2lbfin, 1.0, 112.985],
      'lbf/ft->N/m': [lbfpft2Npm, Npm2lbfpft, 1.0, 14.5939],
      'lbf/in->N/mm': [lbfpin2Npmm, Npmm2lbfpin, 1.0, 0.175127],
      'kW->W': [kW2W, W2kW, 2.5, 2500.0],
      'MW->W': [MW2W, W2MW, 1.5, 1.5e6],
      'hp->W': [hp2W, W2hp, 1.0, 745.7],
      'hp->kW': [hp2kW, kW2hp, 1.0, 0.7457],
      'in²->mm²': [in2_2_mm2, mm2_2_in2, 1.0, 645.16],
      'ft²->m²': [ft2_2_m2, m2_2_ft2, 1.0, 0.09290304],
      'in⁴->mm⁴': [in4_2_mm4, mm4_2_in4, 1.0, 416231.4256],
      'in³->mm³': [in3_2_mm3, mm3_2_in3, 1.0, 16387.064],
      'deg->rad': [deg2rad, rad2deg, 180.0, math.pi],
      'deg/s->rad/s': [degs2rads, rads2degs, 180.0, math.pi],
      'ft/s->m/s': [ftps2mps, mps2ftps, 1.0, 0.3048],
      'gpm->L/s': [gpm2Lps, Lps2gpm, 1.0, 0.0630901964],
      'lb/(ft·s)->Pa·s': [lbpfts2Pas, Pas2lbpfts, 1.0, 1.4881639436],
      'psi->kPa': [psi2kPa, kPa2psi, 1.0, 6.89476],
      'BTU/(h·ft·°F)->W/(m·K)': [BtuphftF2WpmK, WpmK2BtuphftF, 1.0, 1.730735],
      'BTU/(h·ft²·°F)->W/(m²·K)': [
        Btuphft2F2Wpm2K,
        Wpm2K2Btuphft2F,
        1.0,
        5.678263
      ],
      'W->BTU/h': [W2Btuph, Btuph2W, 1.0, 3.412142],
    };

    pairs.forEach((name, spec) {
      final forward = spec[0] as double Function(double);
      final inverse = spec[1] as double Function(double);
      final input = spec[2] as double;
      final expected = spec[3] as double;

      test('$name converts and inverts', () {
        expect(forward(input), _closeRel(expected));
        expect(inverse(forward(input)), _closeRel(input));
        expect(forward(0), _closeRel(0));
        expect(forward(-input), _closeRel(-expected));
      });
    });

    test('rpm and rad/s convert through π/30', () {
      expect(rpm2rads(60), _closeRel(2 * math.pi));
      expect(rads2rpm(2 * math.pi), _closeRel(60));
      expect(rads2rpm(rpm2rads(1750)), _closeRel(1750));
    });

    test('id is the identity', () {
      for (final v in _probes) {
        expect(id(v), equals(v));
      }
    });
  });

  group('formatFixed', () {
    test('drops trailing zeros but keeps significant decimals', () {
      expect(formatFixed(1.5), '1.5');
      expect(formatFixed(1.23456), '1.235');
      expect(formatFixed(10.5000), '10.5');
      expect(formatFixed(1.100), '1.1');
    });

    test('drops the decimal point entirely for whole numbers', () {
      expect(formatFixed(0), '0');
      expect(formatFixed(1), '1');
      expect(formatFixed(100), '100');
      expect(formatFixed(1000), '1000');
      expect(formatFixed(-42), '-42');
    });

    test('honours a custom decimal count', () {
      expect(formatFixed(1.23456, decimals: 1), '1.2');
      expect(formatFixed(1.23456, decimals: 5), '1.23456');
      expect(formatFixed4(1.23456), '1.2346');
      expect(formatFixed4(2.5), '2.5');
    });

    test('does not eat trailing zeros of an integer at decimals: 0', () {
      // Regression guard: the zero-stripping must only apply after a decimal
      // point, or "10" formats as "1".
      expect(formatFixed(10, decimals: 0), '10');
      expect(formatFixed(100, decimals: 0), '100');
      expect(formatFixed(1050, decimals: 0), '1050');
    });
  });

  group('formatFixedSI', () {
    test('converts and appends the label for the active system', () {
      expect(formatFixedSI(25.4, UnitCategory.length, UnitSystem.si), '25.4 mm');
      expect(
        formatFixedSI(25.4, UnitCategory.length, UnitSystem.imperial),
        '1 in',
      );
      expect(
        formatFixedSI(100, UnitCategory.temperature, UnitSystem.imperial),
        '212 °F',
      );
    });

    test('respects the decimals argument', () {
      expect(
        formatFixedSI(1.23456, UnitCategory.length, UnitSystem.si, decimals: 1),
        '1.2 mm',
      );
    });
  });

  group('NumberPrecisionHelper.formatSI', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPreferencesHelper.init();
    });

    test('formats a dimensionless value with no unit suffix', () {
      final precs = NumberPrecisionHelper();
      expect(precs.formatSI(2.5, null, UnitSystem.si), '2.500');
    });

    test('converts to the active system and appends the label', () {
      final precs = NumberPrecisionHelper();
      expect(precs.formatSI(25.4, UnitCategory.length, UnitSystem.si),
          '25.400 mm');
      expect(precs.formatSI(25.4, UnitCategory.length, UnitSystem.imperial),
          '1.000 in');
    });

    test('follows the user precision setting', () {
      final precs = NumberPrecisionHelper();
      precs.set(1);
      expect(
        precs.formatSI(25.4, UnitCategory.length, UnitSystem.imperial),
        '1.0 in',
      );
    });
  });

  group('NumberPrecisionHelper.formatSmallSI', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPreferencesHelper.init();
    });

    test('keeps two nearly-equal viscosities distinguishable', () {
      // The bug this exists for: at the default three decimals both of these
      // render as a bare "0.001" through formatSI.
      final precs = NumberPrecisionHelper();
      const water = 1.002e-3;
      const seawater = 1.070e-3;
      expect(precs.formatSI(water, UnitCategory.dynamicViscosity,
          UnitSystem.si), '0.001 Pa·s');
      expect(precs.formatSI(seawater, UnitCategory.dynamicViscosity,
          UnitSystem.si), '0.001 Pa·s');

      final formattedWater = precs.formatSmallSI(
          water, UnitCategory.dynamicViscosity, UnitSystem.si);
      final formattedSeawater = precs.formatSmallSI(
          seawater, UnitCategory.dynamicViscosity, UnitSystem.si);
      expect(formattedWater, isNot(equals(formattedSeawater)));
      expect(formattedWater, '1.002e-3 Pa·s');
      expect(formattedSeawater, '1.070e-3 Pa·s');
    });

    test('leaves ordinary magnitudes in the normal decimal form', () {
      final precs = NumberPrecisionHelper();
      // Glycerin and engine oil are well above the cutoff.
      expect(
        precs.formatSmallSI(1.519, UnitCategory.dynamicViscosity,
            UnitSystem.si),
        '1.519 Pa·s',
      );
      expect(
        precs.formatSmallSI(0.8374, UnitCategory.dynamicViscosity,
            UnitSystem.si),
        '0.837 Pa·s',
      );
    });

    test('handles zero and dimensionless values', () {
      final precs = NumberPrecisionHelper();
      expect(precs.formatSmallSI(0, UnitCategory.dynamicViscosity,
          UnitSystem.si), '0 Pa·s');
      expect(precs.formatSmallSI(1.5e-4, null, UnitSystem.si), '1.500e-4');
    });

    test('converts before deciding, so the unit system is honoured', () {
      final precs = NumberPrecisionHelper();
      final imperial = precs.formatSmallSI(
          1.002e-3, UnitCategory.dynamicViscosity, UnitSystem.imperial);
      expect(imperial, contains('lb/(ft·s)'));
      expect(imperial, contains('e-4'));
    });
  });
}
