import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/util/converter_catalog.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart' as units;

/// Every unit in the catalogue paired with the hand-written function it
/// replaced, so moving the Unit Converter onto factors cannot have changed
/// what it converts.
///
/// Keyed `<categoryId>/<label>`; the test below fails if the catalogue grows a
/// unit that is missing here, which is what stops a new row shipping
/// unchecked.
final Map<String, double Function(double)> _legacyToBase = {
  'length/mm': units.mm2m,
  'length/cm': units.cm2m,
  'length/m': units.id,
  'length/km': units.km2m,
  'length/in': units.in2m,
  'length/ft': units.ft2m,
  'length/yd': units.yd2m,
  'length/mi': units.mi2m,
  'force/N': units.id,
  'force/kN': units.kN2N,
  'force/MN': units.MN2N,
  'force/lbf': units.lbf2N,
  'force/kip': units.kip2N,
  'pressure/Pa': units.id,
  'pressure/kPa': units.kPa2Pa,
  'pressure/MPa': units.MPa2Pa,
  'pressure/GPa': units.GPa2Pa,
  'pressure/psi': units.psi2Pa,
  'pressure/ksi': units.ksi2Pa,
  'pressure/atm': units.atm2Pa,
  'pressure/bar': units.bar2Pa,
  'mass/g': units.g2kg,
  'mass/kg': units.id,
  'mass/tonne': units.t2kg,
  'mass/oz': units.oz2kg,
  'mass/lb': units.lb2kg,
  'mass/slug': units.slug2kg,
  'temperature/°C': units.id,
  'temperature/°F': units.F2C,
  'temperature/K': units.K2C,
  'torque/N·m': units.id,
  'torque/kN·m': units.kNm2Nm,
  'torque/lbf·ft': units.lbfft2Nm,
  'torque/lbf·in': units.lbfin2Nm,
  'power/W': units.id,
  'power/kW': units.kW2W,
  'power/MW': units.MW2W,
  'power/hp': units.hp2W,
  'angularVelocity/rad/s': units.id,
  'angularVelocity/rpm': units.rpm2rads,
  'angularVelocity/deg/s': units.degs2rads,
  'angle/rad': units.id,
  'angle/deg': units.deg2rad,
};

final Map<String, double Function(double)> _legacyFromBase = {
  'length/mm': units.m2mm,
  'length/cm': units.m2cm,
  'length/m': units.id,
  'length/km': units.m2km,
  'length/in': units.m2in,
  'length/ft': units.m2ft,
  'length/yd': units.m2yd,
  'length/mi': units.m2mi,
  'force/N': units.id,
  'force/kN': units.N2kN,
  'force/MN': units.N2MN,
  'force/lbf': units.N2lbf,
  'force/kip': units.N2kip,
  'pressure/Pa': units.id,
  'pressure/kPa': units.Pa2kPa,
  'pressure/MPa': units.Pa2MPa,
  'pressure/GPa': units.Pa2GPa,
  'pressure/psi': units.Pa2psi,
  'pressure/ksi': units.Pa2ksi,
  'pressure/atm': units.Pa2atm,
  'pressure/bar': units.Pa2bar,
  'mass/g': units.kg2g,
  'mass/kg': units.id,
  'mass/tonne': units.kg2t,
  'mass/oz': units.kg2oz,
  'mass/lb': units.kg2lb,
  'mass/slug': units.kg2slug,
  'temperature/°C': units.id,
  'temperature/°F': units.C2F,
  'temperature/K': units.C2K,
  'torque/N·m': units.id,
  'torque/kN·m': units.Nm2kNm,
  'torque/lbf·ft': units.Nm2lbfft,
  'torque/lbf·in': units.Nm2lbfin,
  'power/W': units.id,
  'power/kW': units.W2kW,
  'power/MW': units.W2MW,
  'power/hp': units.W2hp,
  'angularVelocity/rad/s': units.id,
  'angularVelocity/rpm': units.rads2rpm,
  'angularVelocity/deg/s': units.rads2degs,
  'angle/rad': units.id,
  'angle/deg': units.rad2deg,
};

/// Sample values spanning the ranges the converter is used over. Negative and
/// zero included for temperature, where the offset matters.
const _samples = <double>[0, 1, -1, 2.5, -273.15, 25.4, 1000, 1e-4, 1e6];

void main() {
  group('the catalogue converts as the original functions did', () {
    test('every unit has a legacy counterpart listed', () {
      final keys = <String>{
        for (final category in converterCategories)
          for (final unit in category.units) '${category.id}/${unit.label}',
      };
      expect(
        keys.difference(_legacyToBase.keys.toSet()),
        isEmpty,
        reason: 'a catalogue unit is not covered by this test',
      );
      expect(
        _legacyToBase.keys.toSet().difference(keys),
        isEmpty,
        reason: 'this test names a unit the catalogue no longer has',
      );
      expect(_legacyFromBase.keys.toSet(), keys);
    });

    for (final category in converterCategories) {
      for (final unit in category.units) {
        final key = '${category.id}/${unit.label}';
        test('$key round-trips against units.dart', () {
          for (final sample in _samples) {
            // The affine form re-associates the arithmetic — `(v - 32) * 5/9`
            // becomes `v * 5/9 - 160/9` — so the two agree to rounding rather
            // than bit for bit. A relative 1e-12 is eleven orders below what
            // the converter displays.
            expect(
              unit.toBase(sample),
              closeTo(_legacyToBase[key]!(sample), 1e-12 * _scale(sample)),
              reason: 'toBase($sample) for $key',
            );
            expect(
              unit.fromBase(sample),
              closeTo(_legacyFromBase[key]!(sample), 1e-12 * _scale(sample)),
              reason: 'fromBase($sample) for $key',
            );
          }
        });
      }
    }
  });

  group('convertUnit', () {
    test('converts through the base unit', () {
      final length = converterCategoryById('length')!;
      final mm = length.unitByLabel('mm')!;
      final inch = length.unitByLabel('in')!;
      expect(convertUnit(25.4, mm, inch), closeTo(1, 1e-12));
      expect(convertUnit(1, inch, mm), closeTo(25.4, 1e-12));
    });

    test('handles the temperature offsets in both directions', () {
      final temperature = converterCategoryById('temperature')!;
      final celsius = temperature.unitByLabel('°C')!;
      final fahrenheit = temperature.unitByLabel('°F')!;
      final kelvin = temperature.unitByLabel('K')!;

      expect(convertUnit(100, celsius, fahrenheit), closeTo(212, 1e-9));
      expect(convertUnit(-40, celsius, fahrenheit), closeTo(-40, 1e-9));
      expect(convertUnit(32, fahrenheit, celsius), closeTo(0, 1e-9));
      expect(convertUnit(0, celsius, kelvin), closeTo(273.15, 1e-9));
      expect(convertUnit(273.15, kelvin, celsius), closeTo(0, 1e-9));
      expect(convertUnit(212, fahrenheit, kelvin), closeTo(373.15, 1e-9));
    });
  });

  group('formatConverterValue', () {
    // Also the table quoted in METoolkitFormat's doc comment, which is the
    // Swift translation of this function.
    // A list of pairs rather than a map: a double cannot be a const map key.
    const cases = <(double, String)>[
      (0, '0'),
      (1, '1'),
      (25.4, '25.4'),
      (2.5, '2.5'),
      (-273.15, '-273.15'),
      (0.001, '0.001'),
      (999999.5, '999999.5'),
      (1234567, '1.234567e+6'),
      (1e9, '1e+9'),
      (3e9, '3e+9'),
      (0.0001, '1e-4'),
      (-0.0005, '-5e-4'),
      (1e-7, '1e-7'),
    ];

    for (final (value, expected) in cases) {
      test('$value prints as "$expected"', () {
        expect(formatConverterValue(value), expected);
      });
    }

    test('a round number in exponential form carries no stray point', () {
      // The bug this replaced printed "1.e+9" — the mantissa's zeros were
      // stripped but the decimal point they hung from was left behind.
      for (final value in [1e6, 1e7, 1e9, 1e-4, 1e-6]) {
        expect(formatConverterValue(value), isNot(contains('.e')));
      }
    });

    test('eight decimals is the limit, with no trailing zeros', () {
      expect(formatConverterValue(1 / 3), '0.33333333');
      expect(formatConverterValue(1.5), '1.5');
    });
  });
}

/// Scales the tolerance with the magnitude under test, so a comparison at
/// 1e6 is not held to an absolute 1e-12.
double _scale(double sample) {
  final magnitude = sample.abs();
  return magnitude < 1 ? 1 : magnitude;
}
