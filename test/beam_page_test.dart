import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/beam/model/beam_solver.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/beam_calculator_page.dart';
import 'package:mechanical_engineering_toolkit/home/beam/page/beam_calculator_result_page.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/language.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/theme_preference.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => RemoveAdsService()),
        ChangeNotifierProvider(create: (_) => Favorites()),
        ChangeNotifierProvider(create: (_) => ToolHistory()),
        ChangeNotifierProvider(create: (_) => LanguagePreference()),
        ChangeNotifierProvider(create: (_) => ThemePreference()),
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

/// Types [value] into the field labelled [label] — the label is the only
/// handle a [UnitField] exposes.
Future<void> _fill(WidgetTester tester, String label, String value) async {
  await tester.enterText(
    find.ancestor(of: find.text(label), matching: find.byType(TextField)),
    value,
  );
  await tester.pump();
}

Future<void> _calculate(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

/// Opens the tool on a viewport tall enough that the load rows and the
/// calculate button are both built.
Future<void> _open(
  WidgetTester tester, {
  Map<String, String>? initialInputs,
}) async {
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_wrap(BeamCalculatorPage(
    title: 'Beam Load Analysis',
    toolId: 401,
    initialInputs: initialInputs,
  )));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  group('input page', () {
    testWidgets('opens on a simple span with one point load', (tester) async {
      await _open(tester);
      expect(find.text('Simply supported'), findsWidgets);
      expect(find.text('Load 1'), findsOneWidget);
      // Support positions belong to the overhang alone; everywhere else the
      // supports are at the ends by definition.
      expect(find.text('Left support at'), findsNothing);
    });

    testWidgets('the overhang case asks where its supports are',
        (tester) async {
      await _open(tester);
      await tester.tap(find.byKey(const Key('beamSupportCase')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Overhang').last);
      await tester.pumpAndSettle();

      expect(find.text('Left support at'), findsOneWidget);
      expect(find.text('Right support at'), findsOneWidget);
    });

    testWidgets('a load row swaps its fields with its type', (tester) async {
      await _open(tester);
      expect(find.text('Position, x'), findsOneWidget);
      expect(find.text('Starts at'), findsNothing);

      await tester.tap(find.text('Distributed'));
      await tester.pumpAndSettle();

      expect(find.text('Starts at'), findsOneWidget);
      expect(find.text('Intensity at end'), findsOneWidget);
      expect(find.text('Position, x'), findsNothing);
    });

    testWidgets('loads can be added and removed', (tester) async {
      await _open(tester);
      // The last load keeps its row: calculating without one would only be
      // refused, so offering the delete would be a dead control.
      expect(find.byTooltip('Remove load'), findsNothing);

      await tester.tap(find.byKey(const Key('addBeamLoad')));
      await tester.pumpAndSettle();
      expect(find.text('Load 2'), findsOneWidget);
      expect(find.byTooltip('Remove load'), findsNWidgets(2));

      await tester.tap(find.byTooltip('Remove load').last);
      await tester.pumpAndSettle();
      expect(find.text('Load 2'), findsNothing);
    });

    testWidgets('an incomplete load is refused rather than guessed at',
        (tester) async {
      await _open(tester);
      await tester.tap(find.byKey(const Key('addBeamLoad')));
      await tester.pumpAndSettle();
      await _calculate(tester);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(BeamCalculatorResultPage), findsNothing);
    });
  });

  group('calculating', () {
    testWidgets('a central point load reaches the result page',
        (tester) async {
      await _open(tester);
      await _fill(tester, 'Span, L', '4');
      await _fill(tester, 'Position, x', '2');
      await _fill(tester, 'Magnitude, P (down +)', '10');
      await _calculate(tester);

      expect(find.byType(BeamCalculatorResultPage), findsOneWidget);
      // PL/4 = 10 kN·m sagging, and half the load on each support. A value
      // renders as one string of number and unit together.
      expect(find.text('10.000 kN·m'), findsWidgets);
      expect(find.text('5.000 kN'), findsNWidgets(2));
      expect(find.text('Maximum hogging moment'), findsOneWidget);
      // A section card sets its title in capitals.
      expect(find.text('SUPPORT REACTIONS'), findsOneWidget);
      // Zero formats as a bare "0", not to the set number of decimals.
      expect(find.text('Reaction at x = 0 m'), findsOneWidget);
    });

    testWidgets('a fixed end reports its fixing moment', (tester) async {
      await _open(tester);
      await tester.tap(find.byKey(const Key('beamSupportCase')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cantilever, fixed at left').last);
      await tester.pumpAndSettle();

      await _fill(tester, 'Span, L', '4');
      await _fill(tester, 'Position, x', '4');
      await _fill(tester, 'Magnitude, P (down +)', '10');
      await _calculate(tester);

      expect(find.text('Fixing moment at x = 0 m'), findsOneWidget);
      // One support, so one reaction row and one fixing moment.
      expect(find.textContaining('Reaction at x ='), findsOneWidget);
    });

    testWidgets('an extreme-fibre distance adds the bending stress',
        (tester) async {
      await _open(tester);
      await _fill(tester, 'Span, L', '4');
      await _fill(tester, 'Position, x', '2');
      await _fill(tester, 'Magnitude, P (down +)', '10');
      await _fill(tester, 'Extreme fibre, c', '150');
      await _calculate(tester);

      expect(find.text('Bending stress at Mmax'), findsOneWidget);
      // M = 10 kN·m, c = 150 mm, I = 1e8 mm⁴ gives 15 MPa.
      expect(find.text('15.000 MPa'), findsOneWidget);
    });

    testWidgets('leaving c out leaves the stress out', (tester) async {
      await _open(tester);
      await _fill(tester, 'Span, L', '4');
      await _fill(tester, 'Position, x', '2');
      await _fill(tester, 'Magnitude, P (down +)', '10');
      await _calculate(tester);

      expect(find.text('Bending stress at Mmax'), findsNothing);
    });
  });

  group('history and saved projects', () {
    testWidgets('records the loads as one JSON key', (tester) async {
      await _open(tester);
      await _fill(tester, 'Span, L', '4');
      await _fill(tester, 'Position, x', '2');
      await _fill(tester, 'Magnitude, P (down +)', '10');
      await _calculate(tester);

      final recorded = ToolHistory().entries.first.inputs!;
      expect(recorded['Support case'], 'simplySupported');
      final loads = jsonDecode(recorded[beamLoadsKey]!) as List;
      expect(loads, hasLength(1));
      expect(loads.first['type'], 'point');
      expect(loads.first['magnitude'], 10);
    });

    testWidgets('reopens a saved calculation with its loads', (tester) async {
      await _open(tester, initialInputs: {
        'Span (m)': '6',
        'Support case': 'proppedCantilever',
        'Elastic modulus (GPa)': '200',
        'Second moment (mm4)': '100000000',
        beamLoadsKey: jsonEncode([
          {'type': 'point', 'position': 2.0, 'magnitude': 8.0},
          {
            'type': 'distributed',
            'start': 0.0,
            'end': 6.0,
            'startIntensity': 5.0,
            'endIntensity': 5.0,
          },
        ]),
      });

      expect(find.text('Propped cantilever'), findsWidgets);
      expect(find.text('Load 2'), findsOneWidget);
      expect(find.text('Intensity at start'), findsOneWidget);
    });

    testWidgets('reopens a pre-1.12 entry, which had no load list',
        (tester) async {
      // The old tool recorded one point load and one full-span UDL in keys of
      // their own. Those entries are still in people's projects.
      await _open(tester, initialInputs: const {
        'Span (m)': '4',
        'Point load (kN)': '10',
        'Point position (m)': '1.5',
        'UDL (kN/m)': '3',
        'Elastic modulus (GPa)': '200',
        'Second moment (mm4)': '100000000',
      });

      expect(find.text('Load 1'), findsOneWidget);
      expect(find.text('Load 2'), findsOneWidget);
      // The UDL came across as a distributed load over the whole span.
      expect(find.text('Intensity at start'), findsOneWidget);

      await _calculate(tester);
      expect(find.byType(BeamCalculatorResultPage), findsOneWidget);
    });

    testWidgets('a pre-1.12 entry with no UDL restores one load only',
        (tester) async {
      // Zero meant "not used" in the old tool, so it must not come across as
      // a distributed load of nothing.
      await _open(tester, initialInputs: const {
        'Span (m)': '4',
        'Point load (kN)': '10',
        'Point position (m)': '2',
        'UDL (kN/m)': '0',
        'Elastic modulus (GPa)': '200',
        'Second moment (mm4)': '100000000',
      });

      expect(find.text('Load 1'), findsOneWidget);
      expect(find.text('Load 2'), findsNothing);
    });
  });

  group('describeBeamLoads', () {
    test('reads a saved set of loads back as a line of prose', () {
      final text = describeBeamLoads(jsonEncode([
        {'type': 'point', 'position': 2.0, 'magnitude': 10.0},
        {
          'type': 'distributed',
          'start': 0.0,
          'end': 4.0,
          'startIntensity': 5.0,
          'endIntensity': 12.0,
        },
        {'type': 'couple', 'position': 1.0, 'magnitude': -3.5},
      ]));
      expect(text, '10 kN @ 2 m, 5–12 kN/m over 0–4 m, -3.5 kN·m @ 1 m');
    });

    test('gives up on anything it cannot read, rather than printing JSON', () {
      expect(describeBeamLoads('not json'), isNull);
      expect(describeBeamLoads('{}'), isNull);
      expect(describeBeamLoads('[]'), isNull);
      // A row missing the numbers it needs is skipped, not half-printed.
      expect(describeBeamLoads('[{"type":"point"}]'), isNull);
    });
  });

  group('support arrangements', () {
    test('put the supports where each case says', () {
      expect(supportsFor(BeamSupportCase.simplySupported, 4), hasLength(2));
      expect(supportsFor(BeamSupportCase.cantileverLeft, 4).single.type,
          BeamSupportType.fixed);
      expect(supportsFor(BeamSupportCase.cantileverRight, 4).single.position, 4);
      expect(supportsFor(BeamSupportCase.fixedFixed, 4).every((s) => s.type == BeamSupportType.fixed),
          isTrue);
      expect(supportsFor(BeamSupportCase.proppedCantilever, 4).last.type,
          BeamSupportType.simple);

      final overhang = supportsFor(BeamSupportCase.overhang, 10,
          leftSupport: 2, rightSupport: 8);
      expect(overhang.map((s) => s.position), [2, 8]);
      // Defaults keep the supports inside the span when none are given.
      final defaulted = supportsFor(BeamSupportCase.overhang, 10);
      expect(defaulted.first.position, greaterThan(0));
      expect(defaulted.last.position, lessThan(10));
    });
  });
}
