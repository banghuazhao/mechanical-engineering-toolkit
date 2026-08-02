import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/reference/fits_tolerances_page.dart';
import 'package:mechanical_engineering_toolkit/home/reference/iso_fit_data.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RemoveAdsService()),
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

FitEntry _entryFor(String fit, num diameter) => fitEntries.singleWhere(
      (entry) => entry.fit.name == fit && entry.band.contains(diameter),
    );

/// Text inside the table body. Fit names also label the filter chips, so a
/// bare [find.text] would match both.
Finder _inTable(String text) => find.descendant(
      of: find.byKey(const Key('referenceTable')),
      matching: find.text(text),
    );

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  group('ISO 286 data', () {
    test('every tolerance grade covers every size band', () {
      for (final grade in toleranceGrades.entries) {
        expect(grade.value, hasLength(sizeBands.length),
            reason: 'IT${grade.key} does not cover all bands');
      }
      for (final deviation in shaftDeviations.values) {
        expect(deviation.microns, hasLength(sizeBands.length),
            reason: '${deviation.letter} does not cover all bands');
      }
    });

    test('size bands are contiguous and cover 1–500 mm', () {
      expect(sizeBands.first.min, 1);
      expect(sizeBands.last.max, 500);
      for (var i = 1; i < sizeBands.length; i++) {
        expect(sizeBands[i].min, sizeBands[i - 1].max,
            reason: 'gap before band ${sizeBands[i].label}');
      }
      // Bounds are exclusive below, inclusive above, so a diameter on a
      // boundary lands in exactly one band.
      for (final diameter in [1, 3, 10, 30, 120, 500]) {
        expect(sizeBands.where((band) => band.contains(diameter)), hasLength(1),
            reason: 'Ø$diameter matches the wrong number of bands');
      }
      expect(sizeBands.any((band) => band.contains(0.5)), isFalse);
      expect(sizeBands.any((band) => band.contains(501)), isFalse);
    });

    test('every fit is defined for every band', () {
      expect(fitEntries, hasLength(preferredFits.length * sizeBands.length));
    });

    test('limits match published fit tables', () {
      // H7/g6 at Ø25: hole +21/0, shaft -7/-20, clearance 7 to 41 µm.
      final sliding = _entryFor('H7/g6', 25);
      expect(sliding.holeUpper, 21);
      expect(sliding.holeLower, 0);
      expect(sliding.shaftUpper, -7);
      expect(sliding.shaftLower, -20);
      expect(sliding.minClearance, 7);
      expect(sliding.maxClearance, 41);

      // H8/f7 at Ø10: clearance 13 to 50 µm.
      final running = _entryFor('H8/f7', 10);
      expect(running.minClearance, 13);
      expect(running.maxClearance, 50);

      // H7/k6 at Ø25 is a transition fit: -15 to +19 µm.
      final transition = _entryFor('H7/k6', 25);
      expect(transition.minClearance, -15);
      expect(transition.maxClearance, 19);
      expect(transition.isTransition, isTrue);

      // H7/p6 at Ø40 is interference throughout: -1 to -42 µm.
      final interference = _entryFor('H7/p6', 40);
      expect(interference.maxClearance, -1);
      expect(interference.minClearance, -42);
      expect(interference.isInterference, isTrue);

      // H7/h6 at Ø50 closes on zero at the tight end.
      final locational = _entryFor('H7/h6', 50);
      expect(locational.minClearance, 0);
      expect(locational.maxClearance, 41);
    });

    test('fits get looser as the class loosens', () {
      for (var i = 0; i < sizeBands.length; i++) {
        final free = fitEntries.singleWhere(
            (e) => e.fit.name == 'H9/d9' && e.band == sizeBands[i]);
        final sliding = fitEntries.singleWhere(
            (e) => e.fit.name == 'H7/g6' && e.band == sizeBands[i]);
        expect(free.minClearance, greaterThan(sliding.minClearance),
            reason: 'H9/d9 is not looser than H7/g6 at ${sizeBands[i].label}');
      }
    });

    test('formats microns with an explicit sign', () {
      expect(formatMicrons(21), '+21');
      expect(formatMicrons(0), '0');
      expect(formatMicrons(-20), '-20');
    });
  });

  group('fits & tolerances page', () {
    testWidgets('searching a diameter shows the band containing it',
        (tester) async {
      await tester.pumpWidget(_wrap(const FitsTolerancesPage()));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('referenceSearchField')), '25');
      await tester.pumpAndSettle();

      expect(_inTable('18–30'), findsWidgets);
      expect(_inTable('30–50'), findsNothing);
      // One row per fit, all for the same band.
      expect(_inTable('H7/g6'), findsOneWidget);
      expect(_inTable('H9/d9'), findsOneWidget);
    });

    testWidgets('a fit chip narrows to that fit', (tester) async {
      await tester.pumpWidget(_wrap(const FitsTolerancesPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('H9/d9').first);
      await tester.pumpAndSettle();

      expect(_inTable('1–3'), findsOneWidget);
      expect(_inTable('H7/g6'), findsNothing);
    });

    testWidgets('shows both limits of a cell', (tester) async {
      await tester.pumpWidget(_wrap(const FitsTolerancesPage()));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('referenceSearchField')), 'h7/g6');
      await tester.pumpAndSettle();

      // The 1–3 band: hole +10/0, shaft -2/-8.
      expect(_inTable('+10'), findsOneWidget);
      expect(_inTable('-2'), findsOneWidget);
      expect(_inTable('-8'), findsOneWidget);
    });
  });
}
