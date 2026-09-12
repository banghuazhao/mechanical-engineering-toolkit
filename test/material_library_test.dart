import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/util/lamina_library.dart';
import 'package:mechanical_engineering_toolkit/util/material_library.dart';

void main() {
  group('isotropic presets', () {
    test('names are unique', () {
      final names = builtInMaterials.map((m) => m.name).toList();
      expect(names.toSet().length, names.length);
    });

    test('yield never exceeds ultimate', () {
      for (final m in builtInMaterials) {
        final sy = m.yieldStrengthSI, su = m.ultimateStrengthSI;
        if (sy == null || su == null) continue;
        expect(sy, lessThanOrEqualTo(su), reason: m.name);
      }
    });

    test('G agrees with E and ν for an isotropic solid', () {
      // G = E / 2(1 + ν) holds exactly for an isotropic material, so a preset
      // that disagrees by more than rounding has a transcription error in one
      // of the three. The allowance is for the plastics, whose handbook
      // triples are quoted to a figure or two.
      for (final m in builtInMaterials) {
        final e = m.elasticModulusSI, g = m.shearModulusSI, nu = m.poissonsRatio;
        if (e == null || g == null || nu == null) continue;
        final expected = e / (2 * (1 + nu));
        expect(g, closeTo(expected, expected * 0.08), reason: m.name);
      }
    });

    test('densities are those of solids', () {
      for (final m in builtInMaterials) {
        expect(m.densitySI, inInclusiveRange(500, 9000), reason: m.name);
      }
    });
  });

  group('lamina presets', () {
    test('fibre direction is the stiff and strong one', () {
      for (final l in builtInLaminae) {
        expect(l.e1, greaterThan(l.e2), reason: l.name);
        expect(l.xt, greaterThan(l.yt), reason: l.name);
        expect(l.xc, greaterThan(l.yc), reason: l.name);
      }
    });

    test('Poisson ratios are physical', () {
      for (final l in builtInLaminae) {
        expect(l.nu12, inExclusiveRange(0, 0.5), reason: l.name);
      }
    });

    test('T300/5208 carries its textbook constants', () {
      final t300 = builtInLaminae.firstWhere((l) => l.name.startsWith('T300'));
      expect(t300.e1, 181);
      expect(t300.e2, 10.3);
      expect(t300.g12, 7.17);
      expect(t300.nu12, 0.28);
    });
  });
}
