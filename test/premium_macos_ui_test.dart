import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_history_page.dart';
import 'package:mechanical_engineering_toolkit/home/tool_launcher.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium_upsell.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_banner_ad.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/ui/parameter_sweep_card.dart';
import 'package:mechanical_engineering_toolkit/ui/result_model.dart';
import 'package:mechanical_engineering_toolkit/ui/result_scaffold.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:mechanical_engineering_toolkit/util/units.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remove_ads_service_test.dart' show FakePersistence, FakePurchaseClient;

/// A tool the free tier includes, and one it does not.
const _freeToolId = 500; // Unit Converter
const _lockedToolId = 704; // Bearing L10 Life

const _sections = [
  ResultSection(
    title: 'Bearing L10 Life',
    values: [ResultValue(label: 'L10, million rev', valueSI: 1000)],
  ),
];

RemoveAdsService _service({bool entitled = false}) => RemoveAdsService(
      client: FakePurchaseClient(),
      persistence: FakePersistence(value: entitled),
      store: AppStore.macAppStore,
    )..loadPersistedEntitlement();

Widget _wrap(
  Widget child, {
  required RemoveAdsService service,
  SavedProjects? projects,
  ToolHistory? history,
}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider<RemoveAdsService>.value(value: service),
        ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
        ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
        ChangeNotifierProvider(create: (_) => Favorites()),
        ChangeNotifierProvider<SavedProjects>.value(
            value: projects ?? SavedProjects()),
        ChangeNotifierProvider<ToolHistory>.value(
            value: history ?? ToolHistory()),
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

/// A button that opens [toolId] the way every screen in the app does.
Widget _launcher(int toolId) => Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => launchTool(
              context,
              ToolLibrary.shared.item(toolId, context),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
    AppPlatform.overrideWith(AppPlatform.macOS);
  });

  tearDown(AppPlatform.clearOverride);

  group('opening a tool', () {
    testWidgets('a locked tool offers the upgrade instead of opening',
        (tester) async {
      final service = _service();
      await tester.pumpWidget(_wrap(_launcher(_lockedToolId),
          service: service));
      await tester.pumpAndSettle();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // The sheet names the tool, so the user knows what they just hit.
      final title = ToolLibrary.shared
          .item(_lockedToolId, tester.element(find.text('open')))
          .title;
      expect(
        find.text(S.of(tester.element(find.text('open')))
            .Premium_Locked_Tool(title)),
        findsOneWidget,
      );
      // ...and the tool itself did not open.
      expect(find.text('open'), findsOneWidget);
      service.dispose();
    });

    testWidgets('a free tool opens without any offer', (tester) async {
      final service = _service();
      await tester.pumpWidget(_wrap(_launcher(_freeToolId), service: service));
      await tester.pumpAndSettle();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(PremiumOffer), findsNothing);
      service.dispose();
    });

    testWidgets('the purchase opens what was locked', (tester) async {
      final service = _service(entitled: true);
      await tester.pumpWidget(
          _wrap(_launcher(_lockedToolId), service: service));
      await tester.pumpAndSettle();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(PremiumOffer), findsNothing);
      service.dispose();
    });
  });

  group('exporting a result', () {
    Future<void> openSharePicker(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('shareResults')));
      await tester.pumpAndSettle();
    }

    testWidgets('text stays free while the file formats are marked',
        (tester) async {
      final service = _service();
      await tester.pumpWidget(_wrap(
        const ResultScaffold(toolName: 'Bearing L10 Life', results: _sections),
        service: service,
      ));
      await tester.pumpAndSettle();
      await openSharePicker(tester);

      // Every format is still listed — seeing that a PDF report exists is the
      // point of showing rather than hiding them.
      for (final key in const [
        Key('shareFormatText'),
        Key('shareFormatCsv'),
        Key('shareFormatPdf'),
        Key('shareFormatImage'),
      ]) {
        expect(find.byKey(key), findsOneWidget, reason: '$key');
      }
      // Three of the four wear a padlock; a result you can read should be a
      // result you can paste, so text does not.
      expect(find.byType(PremiumLockBadge), findsNWidgets(3));
      expect(
        find.descendant(
          of: find.byKey(const Key('shareFormatText')),
          matching: find.byType(PremiumLockBadge),
        ),
        findsNothing,
      );
      service.dispose();
    });

    testWidgets('choosing a locked format opens the offer, not the share sheet',
        (tester) async {
      final service = _service();
      await tester.pumpWidget(_wrap(
        const ResultScaffold(toolName: 'Bearing L10 Life', results: _sections),
        service: service,
      ));
      await tester.pumpAndSettle();
      await openSharePicker(tester);

      await tester.tap(find.byKey(const Key('shareFormatPdf')));
      await tester.pumpAndSettle();

      expect(find.byType(PremiumOffer), findsOneWidget);
      service.dispose();
    });

    testWidgets('nothing is marked once the purchase is made', (tester) async {
      final service = _service(entitled: true);
      await tester.pumpWidget(_wrap(
        const ResultScaffold(toolName: 'Bearing L10 Life', results: _sections),
        service: service,
      ));
      await tester.pumpAndSettle();
      await openSharePicker(tester);

      expect(find.byType(PremiumLockBadge), findsNothing);
      service.dispose();
    });
  });

  group('saved projects', () {
    testWidgets('the screen offers the upgrade rather than an empty list',
        (tester) async {
      final service = _service();
      await tester.pumpWidget(
          _wrap(const SavedProjectsPage(), service: service));
      await tester.pumpAndSettle();

      expect(find.byType(PremiumLockedView), findsOneWidget);
      expect(find.byType(PremiumOffer), findsOneWidget);
      service.dispose();
    });

    testWidgets('the purchase reveals the real screen', (tester) async {
      final service = _service(entitled: true);
      await tester.pumpWidget(
          _wrap(const SavedProjectsPage(), service: service));
      await tester.pumpAndSettle();

      expect(find.byType(PremiumLockedView), findsNothing);
      service.dispose();
    });
  });

  group('history', () {
    ToolHistory withEntries(int count) {
      final history = ToolHistory();
      for (var i = 0; i < count; i++) {
        history.record(_freeToolId, inputs: {'n': '$i'});
      }
      return history;
    }

    testWidgets('a free build shows the most recent few and says so',
        (tester) async {
      final service = _service();
      final history = withEntries(9);
      await tester.pumpWidget(_wrap(const ToolHistoryPage(),
          service: service, history: history));
      await tester.pumpAndSettle();

      expect(find.byType(ListTile),
          findsNWidgets(PremiumGate.freeHistoryLimit + 1),
          reason: 'five entries plus the notice');
      expect(
        find.text(S
            .of(tester.element(find.byType(ToolHistoryPage)))
            .Premium_History_Limited(
                PremiumGate.freeHistoryLimit, ToolHistory.maxEntries)),
        findsOneWidget,
      );
      service.dispose();
    });

    testWidgets('nothing was thrown away — the purchase reveals it all',
        (tester) async {
      final service = _service(entitled: true);
      final history = withEntries(9);
      await tester.pumpWidget(_wrap(const ToolHistoryPage(),
          service: service, history: history));
      await tester.pumpAndSettle();

      // The list is lazy, so counting every tile would only measure the test
      // viewport. What matters is that the cap is gone: more than the free
      // limit is built, and the notice that explains the cap is absent.
      expect(
        find.byType(ListTile).evaluate().length,
        greaterThan(PremiumGate.freeHistoryLimit),
      );
      expect(
        find.text(S
            .of(tester.element(find.byType(ToolHistoryPage)))
            .Premium_History_Limited(
                PremiumGate.freeHistoryLimit, ToolHistory.maxEntries)),
        findsNothing,
      );
      service.dispose();
    });
  });

  group('the what-if chart', () {
    Widget sweep() => Scaffold(
          body: ParameterSweepCard(
            variableLabel: 'Load',
            variableCategory: UnitCategory.force,
            baseValueSI: 1000,
            outputLabel: 'Stress',
            outputCategory: UnitCategory.stress,
            compute: (x) => x * 2,
          ),
        );

    testWidgets('a free build keeps the card but not the plot', (tester) async {
      final service = _service();
      await tester.pumpWidget(_wrap(sweep(), service: service));
      await tester.pumpAndSettle();

      // The heading survives, so the page still says what could be explored.
      // AppSectionCard upper-cases it.
      final strings = S.of(tester.element(find.byType(Scaffold)));
      expect(
        find.text(strings.What_If('Load').toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(strings.Premium_Locked_Sweep), findsOneWidget);
      expect(find.text(strings.See_Premium), findsOneWidget);
      service.dispose();
    });
  });

  group('ads', () {
    testWidgets('the Mac build reserves no space for a banner', (tester) async {
      final service = _service();
      await tester.pumpWidget(_wrap(
        const Scaffold(bottomNavigationBar: AppBannerAd()),
        service: service,
      ));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(AppBannerAd)).height, 0);
      service.dispose();
    });
  });

  // The mobile apps monetize with ads and gate nothing. Everything above is
  // keyed off one flag, so these assert that the flag is the only thing
  // standing between iOS/Android and a paywall they should never see.
  group('the mobile builds are untouched', () {
    setUp(() => AppPlatform.overrideWith(AppPlatform.mobile));

    testWidgets('every export format is offered unmarked', (tester) async {
      final service = _service();
      await tester.pumpWidget(_wrap(
        const ResultScaffold(toolName: 'Bearing L10 Life', results: _sections),
        service: service,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('shareResults')));
      await tester.pumpAndSettle();

      expect(find.byType(PremiumLockBadge), findsNothing);
      service.dispose();
    });

    testWidgets('a tool outside the free set opens straight away',
        (tester) async {
      final service = _service();
      await tester.pumpWidget(
          _wrap(_launcher(_lockedToolId), service: service));
      await tester.pumpAndSettle();

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.byType(PremiumOffer), findsNothing);
      service.dispose();
    });

    testWidgets('saved projects and full history stay available',
        (tester) async {
      final service = _service();
      final history = ToolHistory();
      for (var i = 0; i < 9; i++) {
        history.record(_freeToolId, inputs: {'n': '$i'});
      }
      await tester.pumpWidget(_wrap(const ToolHistoryPage(),
          service: service, history: history));
      await tester.pumpAndSettle();
      expect(
        find.byType(ListTile).evaluate().length,
        greaterThan(PremiumGate.freeHistoryLimit),
      );

      await tester.pumpWidget(
          _wrap(const SavedProjectsPage(), service: service));
      await tester.pumpAndSettle();
      expect(find.byType(PremiumLockedView), findsNothing);
      service.dispose();
    });
  });

  group('the purchase screen', () {
    testWidgets('reads as Premium, not Remove Ads', (tester) async {
      final service = _service();
      await tester.pumpWidget(_wrap(const RemoveAdsPage(), service: service));
      await tester.pumpAndSettle();

      final strings = S.of(tester.element(find.byType(RemoveAdsPage)));
      expect(find.text(strings.Premium), findsOneWidget);
      expect(find.text(strings.Remove_Ads), findsNothing);
      expect(find.byType(PremiumOffer), findsOneWidget);
      service.dispose();
    });

    testWidgets('still reads as Remove Ads where nothing is gated',
        (tester) async {
      AppPlatform.overrideWith(AppPlatform.mobile);
      final service = RemoveAdsService(
        client: FakePurchaseClient(),
        persistence: FakePersistence(),
        store: AppStore.playStore,
      );
      await tester.pumpWidget(_wrap(const RemoveAdsPage(), service: service));
      await tester.pumpAndSettle();

      final strings = S.of(tester.element(find.byType(RemoveAdsPage)));
      expect(find.text(strings.Remove_Ads), findsWidgets);
      expect(find.byType(PremiumOffer), findsNothing);
      service.dispose();
    });
  });
}
