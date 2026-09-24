import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/my_materials_page.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/preset_picker.dart';
import 'package:mechanical_engineering_toolkit/util/fluid_library.dart';
import 'package:mechanical_engineering_toolkit/util/lamina_library.dart';
import 'package:mechanical_engineering_toolkit/util/material_library.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/thermal_material_library.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child, MaterialLibrary library) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider.value(value: library),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: child,
      ),
    );

Future<void> _init([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  await SharedPreferencesHelper.init();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the store', () {
    test('reads custom materials saved before this release', () async {
      // The exact shape 1.14 and earlier wrote: no ν, stored under the
      // original key.
      await _init({
        'CUSTOM_MATERIALS': [
          jsonEncode({
            'name': 'Shop steel',
            'category': 'other',
            'E': 205.0,
            'G': null,
            'yield': 300.0,
            'ultimate': 450.0,
            'density': 7850.0,
          }),
        ],
      });
      final library = MaterialLibrary();
      expect(library.customPresets.single.name, 'Shop steel');
      expect(library.customPresets.single.elasticModulusSI, 205);
      expect(library.all.length, builtInMaterials.length + 1);
    });

    test('skips an entry that no longer decodes rather than failing', () async {
      await _init({
        'CUSTOM_FLUIDS': [
          'not json',
          jsonEncode({'name': 'Oil', 'density': 870, 'viscosity': 0.03}),
        ],
      });
      final library = MaterialLibrary();
      expect(library.fluids.items.single.name, 'Oil');
      // Index 0 of what the reader sees is the stored entry at index 1.
      library.fluids.removeAt(0);
      expect(library.fluids.items, isEmpty);
    });

    test('edits and deletes by position, so twins stay separate', () async {
      await _init();
      final library = MaterialLibrary();
      const a = FluidPreset(
          name: 'Twin', densitySI: 1000, viscositySI: 1e-3, isCustom: true);
      library.fluids
        ..add(a)
        ..add(a);
      library.fluids.replaceAt(
          1,
          const FluidPreset(
              name: 'Renamed', densitySI: 900, viscositySI: 2e-3));
      expect(library.fluids.items.map((f) => f.name), ['Twin', 'Renamed']);
      library.fluids.removeAt(0);
      expect(library.fluids.items.map((f) => f.name), ['Renamed']);
    });

    test('names collide with built-ins and each other, ignoring case',
        () async {
      await _init();
      final library = MaterialLibrary();
      bool taken(String name, {int? except}) => MaterialLibrary.isNameTaken(
            name,
            builtIn: builtInThermalMaterials,
            custom: library.thermal,
            exceptIndex: except,
          );
      expect(taken('  copper '), isTrue);
      expect(taken('Graphite sheet'), isFalse);
      library.thermal.add(const ThermalMaterialPreset(
        name: 'Graphite sheet',
        conductivitySI: 400,
        group: ThermalMaterialGroup.metal,
      ));
      expect(taken('GRAPHITE SHEET'), isTrue);
      // Saving an entry under its own name is not a collision.
      expect(taken('Graphite sheet', except: 0), isFalse);
    });

    test('an export imports on another device, once', () async {
      await _init();
      final source = MaterialLibrary()
        ..addCustom(const MaterialPreset(
          name: 'Ti grade 2',
          category: MaterialCategory.metal,
          elasticModulusSI: 105,
          poissonsRatio: 0.37,
        ));
      source.laminae.add(const LaminaPreset(
          name: 'IM7/8552', e1: 161, e2: 11.4, g12: 5.17, nu12: 0.32));
      source.fluids.add(const FluidPreset(
          name: 'Hydraulic oil, 40 °C', densitySI: 870, viscositySI: 0.028));
      source.thermal.add(const ThermalMaterialPreset(
          name: 'Aerogel blanket',
          conductivitySI: 0.015,
          group: ThermalMaterialGroup.insulation));
      final exported = source.exportJson();

      await _init();
      final target = MaterialLibrary();
      expect(target.importJson(exported), (added: 4, skipped: 0));
      expect(target.customPresets.single.poissonsRatio, 0.37);
      expect(target.laminae.items.single.xt, isNull);
      expect(target.fluids.items.single.name, 'Hydraulic oil, 40 °C');
      expect(
          target.thermal.items.single.group, ThermalMaterialGroup.insulation);

      // The same backup twice changes nothing the second time.
      expect(target.importJson(exported), (added: 0, skipped: 4));
    });

    test('refuses JSON that is not an export', () async {
      await _init();
      final library = MaterialLibrary();
      expect(() => library.importJson('{"name": "x"}'),
          throwsA(isA<FormatException>()));
      expect(
          () => library.importJson('hello'), throwsA(isA<FormatException>()));
    });
  });

  group('the picker', () {
    testWidgets('adds a fluid and hands it straight back', (tester) async {
      await _init();
      final library = MaterialLibrary();
      FluidPreset? picked;
      await tester.pumpWidget(_wrap(
        Scaffold(
          body: FluidPresetButton(onSelected: (f) => picked = f),
        ),
        library,
      ));

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('addCustomPreset')));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('presetName')), 'Brine, 0 °C');
      final numberFields = find.descendant(
        of: find.byType(BottomSheet).last,
        matching: find.byType(TextField),
      );
      // Name, then ρ and μ.
      await tester.enterText(numberFields.at(1), '1180');
      await tester.enterText(numberFields.at(2), '0.0035');
      await tester.tap(find.byKey(const Key('savePreset')));
      await tester.pumpAndSettle();

      expect(library.fluids.items.single.densitySI, 1180);
      // The new entry heads the list, under its own heading.
      expect(find.text('Brine, 0 °C'), findsOneWidget);
      await tester.tap(find.text('Brine, 0 °C'));
      await tester.pumpAndSettle();
      expect(picked?.viscositySI, 0.0035);
    });

    testWidgets('refuses a name a built-in already uses', (tester) async {
      await _init();
      final library = MaterialLibrary();
      await tester.pumpWidget(_wrap(
        Scaffold(body: FluidPresetButton(onSelected: (_) {})),
        library,
      ));
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('addCustomPreset')));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.byKey(const Key('presetName')), 'water, 20 °c');
      await tester.tap(find.byKey(const Key('savePreset')));
      await tester.pumpAndSettle();
      expect(
          find.text('Another preset already has this name.'), findsOneWidget);
      expect(library.fluids.items, isEmpty);
    });
  });

  group('My Materials', () {
    testWidgets('duplicating a built-in starts a custom copy', (tester) async {
      await _init();
      final library = MaterialLibrary();
      await tester.pumpWidget(_wrap(const MyMaterialsPage(), library));
      await tester.pumpAndSettle();

      // The first built-in row's menu.
      await tester.tap(find.byIcon(Icons.more_vert_rounded).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Duplicate and edit'));
      await tester.pumpAndSettle();
      final first = builtInMaterials.first;
      expect(find.text('${first.name} (copy)'), findsOneWidget);
      await tester.tap(find.byKey(const Key('savePreset')));
      await tester.pumpAndSettle();

      final copy = library.customPresets.single;
      expect(copy.name, '${first.name} (copy)');
      expect(copy.elasticModulusSI, first.elasticModulusSI);
      expect(copy.isCustom, isTrue);
    });

    testWidgets('derives G from E and ν when G is left blank', (tester) async {
      await _init();
      final library = MaterialLibrary();
      await tester.pumpWidget(_wrap(const MyMaterialsPage(), library));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('addMyMaterial')));
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(TextField),
      );
      await tester.enterText(fields.at(0), 'Test alloy');
      await tester.enterText(fields.at(1), '200'); // E, GPa
      await tester.enterText(fields.at(3), '0.25'); // ν
      await tester.tap(find.byKey(const Key('savePreset')));
      await tester.pumpAndSettle();
      expect(library.customPresets.single.shearModulusSI, closeTo(80, 1e-9));
    });
  });
}
