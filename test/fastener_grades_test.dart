import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/reference/fastener_grade_data.dart';
import 'package:mechanical_engineering_toolkit/home/reference/fastener_grades_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RemoveAdsService()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
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

/// The tabulated stress areas are published values, not computed ones. This
/// suite checks them against the standard's own formula, which is what catches
/// a transposed digit — the failure mode a table of 78 rows invites.
void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  /// `1.25 mm` -> 1.25, `20 TPI` -> 20.
  double leadingNumber(String label) =>
      double.parse(label.split(' ').first);

  group('stress areas agree with the standard formula', () {
    test('metric coarse, ISO 898-1', () {
      for (final size in metricSizes) {
        final pitch = leadingNumber(size.threadLabel);
        final computed = metricStressArea(size.diameterMm, pitch);
        // The published values are rounded to three significant figures, so
        // half a percent is the honest tolerance here.
        expect(size.stressAreaMm2, closeTo(computed, computed * 0.005),
            reason: '${size.designation}: tabulated ${size.stressAreaMm2} mm² '
                'against ${computed.toStringAsFixed(2)} mm² from the formula');
      }
    });

    test('unified coarse, converted from in²', () {
      for (final size in inchSizes) {
        final tpi = leadingNumber(size.threadLabel);
        final diameterIn = size.diameterMm / 25.4;
        final computed = unifiedStressArea(diameterIn, tpi) * 645.16;
        expect(size.stressAreaMm2, closeTo(computed, computed * 0.005),
            reason: '${size.designation}: tabulated ${size.stressAreaMm2} mm² '
                'against ${computed.toStringAsFixed(2)} mm² from the formula');
      }
    });
  });

  group('diameter bands', () {
    // The derating above M16 and above 3/4 in is the one thing a flat table
    // gets wrong, so pin both sides of each boundary.
    test('ISO 898-1 derates class 8.8 above M16', () {
      final grade =
          metricGrades.firstWhere((g) => g.designation == '8.8');
      expect(grade.bandFor(16).proofStrength, 580);
      expect(grade.bandFor(16).tensileStrength, 800);
      expect(grade.bandFor(18).proofStrength, 600);
      expect(grade.bandFor(18).tensileStrength, 830);
    });

    test('SAE J429 derates grade 2 above 3/4 in', () {
      final grade = inchGrades.firstWhere((g) => g.designation == 'SAE 2');
      // 3/4 in = 19.05 mm is the last size in the upper band.
      expect(grade.bandFor(19.05).proofStrength, 379);
      // 7/8 in = 22.225 mm has dropped to 33 ksi.
      expect(grade.bandFor(22.225).proofStrength, 228);
    });

    test('grade 12.9 is one band all the way up', () {
      final grade = metricGrades.firstWhere((g) => g.designation == '12.9');
      expect(grade.bandFor(3).proofStrength, 970);
      expect(grade.bandFor(36).proofStrength, 970);
    });
  });

  group('derived clamp load and torque', () {
    BoltSpec specFor(String size, String grade) => boltSpecs.firstWhere(
        (s) => s.size.designation == size && s.grade.designation == grade);

    test('M10 8.8 lands on the figure handbooks quote', () {
      final spec = specFor('M10', '8.8');
      // 0.75 x 58.0 mm² x 580 MPa
      expect(spec.clampLoad, closeTo(25230, 1));
      // 0.2 x 25230 N x 0.010 m
      expect(spec.tighteningTorque, closeTo(50.5, 0.1));
    });

    test('M12 10.9 does too', () {
      final spec = specFor('M12', '10.9');
      expect(spec.clampLoad, closeTo(52476, 1));
      expect(spec.tighteningTorque, closeTo(125.9, 0.1));
    });

    test('a higher grade in the same size clamps harder', () {
      expect(specFor('M12', '12.9').clampLoad,
          greaterThan(specFor('M12', '10.9').clampLoad));
      expect(specFor('M12', '10.9').clampLoad,
          greaterThan(specFor('M12', '8.8').clampLoad));
      expect(specFor('M12', '8.8').clampLoad,
          greaterThan(specFor('M12', '4.6').clampLoad));
    });
  });

  group('the table itself', () {
    test('pairs every size with the grades of its own thread system', () {
      expect(boltSpecs, hasLength(metricSizes.length * metricGrades.length +
          inchSizes.length * inchGrades.length));
      for (final spec in boltSpecs) {
        expect(spec.size.isMetric, spec.grade.isMetric,
            reason: '${spec.size.designation} paired with '
                '${spec.grade.designation}');
      }
    });

    test('every row carries a usable number in every column', () {
      for (final spec in boltSpecs) {
        expect(spec.size.stressAreaMm2, greaterThan(0));
        expect(spec.band.proofStrength, greaterThan(0));
        expect(spec.clampLoad, greaterThan(0));
        expect(spec.tighteningTorque, greaterThan(0));
        expect(spec.grade.headMarking.trim(), isNotEmpty);
        // Proof sits below yield, which sits below tensile — a row where it
        // does not is a transcription error, not a material.
        expect(spec.band.proofStrength,
            lessThanOrEqualTo(spec.band.yieldStrength),
            reason: spec.searchText);
        expect(spec.band.yieldStrength,
            lessThanOrEqualTo(spec.band.tensileStrength),
            reason: spec.searchText);
      }
    });

    test('sizes ascend within each thread system', () {
      for (final sizes in [metricSizes, inchSizes]) {
        for (var i = 1; i < sizes.length; i++) {
          expect(sizes[i].diameterMm, greaterThan(sizes[i - 1].diameterMm));
          expect(sizes[i].stressAreaMm2,
              greaterThan(sizes[i - 1].stressAreaMm2));
        }
      }
    });
  });

  group('bolt grades page', () {
    /// A viewport tall enough to build a whole size's worth of rows: the
    /// table is a lazy ListView, so anything below the fold does not exist
    /// to a finder.
    Future<void> pumpPage(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1400, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_wrap(const FastenerGradesPage()));
      await tester.pumpAndSettle();
    }

    Future<void> search(WidgetTester tester, String query) async {
      await tester.enterText(
          find.byKey(const Key('referenceSearchField')), query);
      await tester.pumpAndSettle();
    }

    testWidgets('a size search shows every grade of that size', (tester) async {
      await pumpPage(tester);
      await search(tester, 'm10');

      expect(find.text('M10'), findsNWidgets(metricGrades.length));
      // The clamp load identifies the grade without colliding with the filter
      // chip of the same name. M10 8.8: 0.75 x 58.0 mm² x 580 MPa; M10 12.9:
      // the same area against 970 MPa. Default precision is three decimals.
      expect(find.text('25230.000'), findsOneWidget);
      expect(find.text('42195.000'), findsOneWidget);
    });

    testWidgets('a bare number finds the metric size, not a torque',
        (tester) async {
      await pumpPage(tester);
      await search(tester, '12');

      expect(find.text('M12'), findsNWidgets(metricGrades.length));
      expect(find.text('M120'), findsNothing);
      expect(find.text('1/2-13'), findsNothing);
    });

    testWidgets('an inch grade search reaches the SAE rows', (tester) async {
      await pumpPage(tester);
      await search(tester, 'sae 8');

      expect(find.text('1/4-20'), findsOneWidget);
      expect(find.text('1-8'), findsOneWidget);
      expect(find.text('M3'), findsNothing);
      expect(find.text('6 radial lines'), findsWidgets);
    });

    testWidgets('a metric class does not print its own number twice',
        (tester) async {
      await pumpPage(tester);
      await search(tester, 'm10');

      // The head marking of an ISO class is the class designation, so the
      // second line under it is dropped rather than repeated.
      expect(find.text('10.9'), findsNWidgets(2)); // the chip and the cell
      expect(find.text('no marks'), findsNothing);
    });

    testWidgets('a grade chip filters the table', (tester) async {
      await pumpPage(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, '10.9'));
      await tester.pumpAndSettle();

      // One row per metric size now, where there were five.
      expect(find.text('M3'), findsOneWidget);
      // With four of the five classes filtered out, the whole metric range
      // now fits on one screen.
      expect(find.text('M36'), findsOneWidget);
      expect(find.text('1/4-20'), findsNothing);
      // M3 10.9: 0.75 x 5.03 mm² x 830 MPa.
      expect(find.text('3131.175'), findsOneWidget);
    });

    testWidgets('switching to imperial relabels and converts the columns',
        (tester) async {
      await pumpPage(tester);
      expect(find.textContaining('(MPa)'), findsOneWidget);
      expect(find.textContaining('(N)'), findsOneWidget);

      final context = tester.element(find.byType(FastenerGradesPage));
      context.read<UnitSystemPreference>().set(UnitSystem.imperial);
      await tester.pumpAndSettle();

      expect(find.textContaining('(MPa)'), findsNothing);
      expect(find.textContaining('(ksi)'), findsOneWidget);
      expect(find.textContaining('(lbf)'), findsOneWidget);
      expect(find.textContaining('(lbf·ft)'), findsOneWidget);
    });
  });
}
