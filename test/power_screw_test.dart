import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/model/power_screw_calculator.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/page/power_screw_page.dart';
import 'package:mechanical_engineering_toolkit/home/machine_design/page/power_screw_result_page.dart';
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

Future<void> _fill(WidgetTester tester, String label, String value) async {
  await tester.enterText(
    find.ancestor(of: find.text(label), matching: find.byType(TextField)),
    value,
  );
  await tester.pump();
}

Future<void> _open(WidgetTester tester,
    {Map<String, String>? initialInputs}) async {
  tester.view.physicalSize = const Size(1200, 2600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_wrap(PowerScrewPage(
    title: 'Power Screw',
    toolId: 712,
    initialInputs: initialInputs,
  )));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  group("Shigley's worked square-thread jack", () {
    // Example 8-1: d = 32 mm, p = 4 mm, double thread, F = 6.4 kN,
    // μ = μc = 0.08, collar mean diameter 40 mm. Published answers are
    // TR = 15.94 + 10.24 = 26.18 N·m, TL = −0.466 + 10.24 = 9.77 N·m and
    // e = 0.311, which is what makes this the check worth pinning.
    const input = PowerScrewInput(
      majorDiameter: 32,
      pitch: 4,
      starts: 2,
      load: 6400,
      form: ThreadForm.square,
      threadFriction: 0.08,
      collarFriction: 0.08,
      collarDiameter: 40,
    );

    test('geometry', () {
      final result = PowerScrewCalculator.calculate(input);
      expect(result.meanDiameter, closeTo(30, 1e-9));
      expect(result.lead, closeTo(8, 1e-9));
      // λ = atan(8 / 30π).
      expect(result.leadAngle, closeTo(4.85, 0.01));
    });

    test('torque to raise splits into thread and collar', () {
      final result = PowerScrewCalculator.calculate(input);
      expect(result.threadTorqueRaising, closeTo(15.94, 0.01));
      expect(result.collarTorque, closeTo(10.24, 0.01));
      expect(result.torqueToRaise, closeTo(26.18, 0.01));
    });

    test('torque to lower, where the thread alone would back-drive', () {
      final result = PowerScrewCalculator.calculate(input);
      expect(result.threadTorqueLowering, closeTo(-0.466, 0.005));
      expect(result.torqueToLower, closeTo(9.77, 0.01));
      // μ = 0.08 sits just under tan λ = 0.0849, so the thread does not hold
      // — but the collar makes up the difference and the jack stays put.
      expect(result.isSelfLocking, isFalse);
      expect(result.holdsWithCollar, isTrue);
    });

    test('efficiency', () {
      final result = PowerScrewCalculator.calculate(input);
      expect(result.efficiency, closeTo(0.311, 0.001));
    });
  });

  group('self-locking', () {
    PowerScrewResult withFriction(double mu) =>
        PowerScrewCalculator.calculate(PowerScrewInput(
          majorDiameter: 32,
          pitch: 4,
          starts: 2,
          load: 6400,
          form: ThreadForm.square,
          threadFriction: mu,
          collarFriction: 0,
        ));

    test('turns on at μ = tan λ', () {
      // tan λ = lead / (π·dm) = 8 / 30π = 0.08488.
      const tanLambda = 8 / (30 * math.pi);
      expect(withFriction(tanLambda * 0.99).isSelfLocking, isFalse);
      expect(withFriction(tanLambda * 1.01).isSelfLocking, isTrue);
    });

    test('a self-locking screw needs torque to lower the load too', () {
      final holding = withFriction(0.15);
      expect(holding.isSelfLocking, isTrue);
      expect(holding.torqueToLower, greaterThan(0));
    });

    test('a screw that back-drives shows it as a negative lowering torque',
        () {
      final running = withFriction(0.02);
      expect(running.isSelfLocking, isFalse);
      expect(running.torqueToLower, lessThan(0));
      // Without a collar, failing the thread test means the load runs away.
      expect(running.holdsWithCollar, isFalse);
    });
  });

  group('thread form', () {
    PowerScrewResult withForm(ThreadForm form) =>
        PowerScrewCalculator.calculate(PowerScrewInput(
          majorDiameter: 32,
          pitch: 4,
          starts: 2,
          load: 6400,
          form: form,
          threadFriction: 0.15,
          collarFriction: 0,
        ));

    test('a flank angle costs efficiency', () {
      // The load is wedged between the flanks, so the normal force and the
      // friction with it go up by 1/cos α. Square wins, and by a margin worth
      // the harder machining.
      final square = withForm(ThreadForm.square);
      final acme = withForm(ThreadForm.acme);
      final trapezoidal = withForm(ThreadForm.trapezoidal);

      expect(square.efficiency, greaterThan(acme.efficiency));
      expect(acme.efficiency, greaterThan(trapezoidal.efficiency));
      expect(square.torqueToRaise, lessThan(acme.torqueToRaise));
    });

    test('the secant factor is the flank angle and nothing else', () {
      expect(ThreadForm.square.secantFactor, closeTo(1, 1e-12));
      expect(ThreadForm.acme.secantFactor, closeTo(1.0329, 1e-4));
      expect(ThreadForm.trapezoidal.secantFactor, closeTo(1.0353, 1e-4));
    });
  });

  group('lead', () {
    test('extra starts multiply the lead, not the thread', () {
      PowerScrewResult withStarts(int starts) =>
          PowerScrewCalculator.calculate(PowerScrewInput(
            majorDiameter: 32,
            pitch: 4,
            starts: starts,
            load: 6400,
            form: ThreadForm.square,
          ));

      expect(withStarts(1).lead, 4);
      expect(withStarts(3).lead, 12);
      // Same thread, so the same mean diameter — only the helix gets steeper.
      expect(withStarts(1).meanDiameter, withStarts(3).meanDiameter);
      expect(withStarts(3).leadAngle, greaterThan(withStarts(1).leadAngle));
      // A steeper helix is more efficient and less inclined to hold.
      expect(withStarts(3).efficiency, greaterThan(withStarts(1).efficiency));
    });
  });

  group('rejects what it cannot analyse', () {
    PowerScrewInput input({
      double majorDiameter = 32,
      double pitch = 4,
      int starts = 1,
      double load = 6400,
      double threadFriction = 0.15,
      double collarDiameter = 0,
    }) =>
        PowerScrewInput(
          majorDiameter: majorDiameter,
          pitch: pitch,
          starts: starts,
          load: load,
          threadFriction: threadFriction,
          collarDiameter: collarDiameter,
        );

    test('a pitch that is not smaller than the diameter', () {
      expect(() => PowerScrewCalculator.calculate(input(pitch: 32)),
          throwsA(isA<FormatException>()));
    });

    test('zero or negative sizes and loads', () {
      expect(() => PowerScrewCalculator.calculate(input(majorDiameter: 0)),
          throwsA(isA<FormatException>()));
      expect(() => PowerScrewCalculator.calculate(input(load: 0)),
          throwsA(isA<FormatException>()));
      expect(() => PowerScrewCalculator.calculate(input(starts: 0)),
          throwsA(isA<FormatException>()));
      expect(
          () => PowerScrewCalculator.calculate(input(threadFriction: -0.1)),
          throwsA(isA<FormatException>()));
      expect(() => PowerScrewCalculator.calculate(input(collarDiameter: -1)),
          throwsA(isA<FormatException>()));
    });

    test('friction so high the screw could not be turned at all', () {
      expect(
          () => PowerScrewCalculator.calculate(
              input(threadFriction: 40, pitch: 4, starts: 6)),
          throwsA(isA<FormatException>()));
    });
  });

  group('power screw page', () {
    testWidgets("carries Shigley's jack through to the result page",
        (tester) async {
      await _open(tester);
      // The segment itself, not the SegmentedButton around it: tapping the
      // parent lands on whichever segment happens to be in the middle.
      await tester.tap(find.text('Square'));
      await tester.pumpAndSettle();

      await _fill(tester, 'Major diameter, d', '32');
      await _fill(tester, 'Pitch, p', '4');
      await _fill(tester, 'Thread starts', '2');
      await _fill(tester, 'Axial load, F', '6400');
      await _fill(tester, 'Thread friction, μ', '0.08');
      await _fill(tester, 'Collar friction, μc', '0.08');
      await _fill(tester, 'Collar mean diameter, dc', '40');

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(PowerScrewResultPage), findsOneWidget);
      // TR = 26.18 N·m, TL = 9.77 N·m, e = 31.1%, and the thread alone does
      // not hold — the numbers the model test pins, seen end to end.
      expect(find.text('26.177 N·m'), findsOneWidget);
      expect(find.text('9.774 N·m'), findsOneWidget);
      expect(find.text('Self-locking on the thread'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
    });

    testWidgets('an empty form is refused rather than guessed at',
        (tester) async {
      await _open(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byType(PowerScrewResultPage), findsNothing);
    });

    testWidgets('an impossible screw surfaces the model error', (tester) async {
      await _open(tester);
      await _fill(tester, 'Major diameter, d', '32');
      // A pitch larger than the diameter is not a screw.
      await _fill(tester, 'Pitch, p', '40');
      await _fill(tester, 'Axial load, F', '6400');
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('smaller than the major diameter'),
          findsOneWidget);
    });

    testWidgets('reopens a saved calculation', (tester) async {
      await _open(tester, initialInputs: const {
        'd': '32',
        'p': '4',
        'F': '6400',
        'starts': '2',
        'form': 'square',
        'mu': '0.08',
        'muc': '0.08',
        'dc': '40',
      });

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('26.177 N·m'), findsOneWidget);
    });
  });
}
