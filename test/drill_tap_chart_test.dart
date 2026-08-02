import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/reference/drill_tap_chart_page.dart';
import 'package:mechanical_engineering_toolkit/home/reference/drill_tap_data.dart';
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

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
  });

  group('drill & tap data', () {
    test('every series is populated', () {
      for (final series in ThreadSeries.values) {
        expect(threadEntries.where((e) => e.series == series), isNotEmpty,
            reason: '$series has no entries');
      }
    });

    test('thread designations are unique', () {
      final seen = <String>{};
      for (final entry in threadEntries) {
        expect(seen.add('${entry.series}/${entry.size}'), isTrue,
            reason: '${entry.size} is listed twice in ${entry.series}');
      }
    });

    test('tap drill is smaller than both clearance holes', () {
      for (final entry in threadEntries) {
        expect(entry.tapDrill.mm, lessThan(entry.clearanceClose.mm),
            reason: '${entry.size}: tap drill is not below the clearance hole');
        expect(entry.clearanceClose.mm, lessThan(entry.clearanceFree.mm),
            reason: '${entry.size}: close fit is not tighter than free fit');
      }
    });

    test('inch drills carry a designation, metric drills do not', () {
      for (final entry in threadEntries) {
        final drills = [
          entry.tapDrill,
          entry.clearanceClose,
          entry.clearanceFree,
        ];
        for (final drill in drills) {
          expect(drill.designation == null, entry.isMetric,
              reason: '${entry.size}: unexpected designation on $drill');
        }
      }
    });

    test('formats inch drills as designation plus millimetres', () {
      expect(const DrillSize(5.11, '#7').toString(), '#7 (5.11)');
      expect(const DrillSize(6.8).toString(), '6.8');
    });
  });

  group('drill & tap chart page', () {
    testWidgets('lists metric threads with their tap drill', (tester) async {
      await tester.pumpWidget(_wrap(const DrillTapChartPage()));
      await tester.pumpAndSettle();

      // Rows below the fold are not built, so search for the one under test.
      // The query stays lowercase so it cannot be confused with a cell value.
      await tester.enterText(
          find.byKey(const Key('referenceSearchField')), 'm8');
      await tester.pumpAndSettle();

      expect(find.text('M8'), findsOneWidget);
      expect(find.text('6.8'), findsOneWidget); // M8 tap drill
      expect(find.text('M8×1'), findsOneWidget);
      expect(find.text('7.0'), findsOneWidget); // M8×1 tap drill
    });

    testWidgets('search narrows the table', (tester) async {
      await tester.pumpWidget(_wrap(const DrillTapChartPage()));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('referenceSearchField')), '1/4');
      await tester.pumpAndSettle();

      expect(find.text('1/4-20'), findsOneWidget);
      expect(find.text('1/4-28'), findsOneWidget);
      expect(find.text('M3'), findsNothing);
      // Inch drills lead with the designation and carry the mm value below.
      expect(find.text('#7'), findsOneWidget); // 1/4-20 tap drill
      expect(find.text('5.11'), findsOneWidget);

      await tester.tap(find.byKey(const Key('clearReferenceSearch')));
      await tester.pumpAndSettle();
      expect(find.text('M3'), findsOneWidget);
    });

    testWidgets('series chips filter the table', (tester) async {
      await tester.pumpWidget(_wrap(const DrillTapChartPage()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Unified coarse (UNC)'));
      await tester.pumpAndSettle();

      expect(find.text('#1-64'), findsOneWidget);
      expect(find.text('M3'), findsNothing);
    });

    testWidgets('tapping a row copies it', (tester) async {
      final copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add(call.arguments['text'] as String);
          }
          return null;
        },
      );
      addTearDown(() => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null));

      await tester.pumpWidget(_wrap(const DrillTapChartPage()));
      await tester.pumpAndSettle();

      // Lowercase 'tpi' matches only the 1/4-20 row and cannot collide with
      // the cell text the tap targets.
      await tester.enterText(
          find.byKey(const Key('referenceSearchField')), '1/4-20 20 tpi');
      await tester.pumpAndSettle();
      await tester.tap(find.text('1/4-20'));
      await tester.pump();

      expect(copied.single, '1/4-20  20 TPI  #7 (5.11)  F (6.53)  H (6.76)');
      expect(find.text('Result copied'), findsOneWidget);
    });

    testWidgets('shows an empty state when nothing matches', (tester) async {
      await tester.pumpWidget(_wrap(const DrillTapChartPage()));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byKey(const Key('referenceSearchField')), 'M99');
      await tester.pumpAndSettle();

      expect(find.text('No matches'), findsOneWidget);
    });
  });
}
