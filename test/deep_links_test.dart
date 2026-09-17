import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/home/unit_converter/unit_converter_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium_upsell.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/purchase/tool_unlock_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:mechanical_engineering_toolkit/util/deep_links.dart';
import 'package:mechanical_engineering_toolkit/util/language.dart';
import 'package:mechanical_engineering_toolkit/util/material_library.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remove_ads_service_test.dart' show FakePersistence, FakePurchaseClient;

/// A stand-in for the library the app launches at, so a successful deep link
/// is visibly a push on top of it rather than a replacement.
class _LibraryStub extends StatelessWidget {
  const _LibraryStub();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('library')),
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final navigatorKey = GlobalKey<NavigatorState>();
  late DeepLinkRouter router;
  late RemoveAdsService purchases;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
    router = DeepLinkRouter(navigatorKey);
    // Fakes rather than the real client: an unentitled service that reaches
    // for a live store leaves the upgrade sheet spinning, and pumpAndSettle
    // then never settles.
    purchases = RemoveAdsService(
      client: FakePurchaseClient(),
      persistence: FakePersistence(value: false),
      store: AppStore.macAppStore,
    )..loadPersistedEntitlement();
  });

  tearDown(() {
    AppPlatform.clearOverride();
    purchases.dispose();
  });

  Widget app() => MultiProvider(
        providers: [
          ChangeNotifierProvider<RemoveAdsService>.value(value: purchases),
          ChangeNotifierProvider(create: (_) => ToolUnlockService()),
          ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
          ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
          ChangeNotifierProvider(create: (_) => Favorites()),
          ChangeNotifierProvider(create: (_) => SavedProjects()),
          ChangeNotifierProvider(create: (_) => ToolHistory()),
          ChangeNotifierProvider(create: (_) => MaterialLibrary()),
          ChangeNotifierProvider(create: (_) => LanguagePreference()),
        ],
        child: MaterialApp(
          navigatorKey: navigatorKey,
          theme: AppTheme.light(),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: const _LibraryStub(),
        ),
      );

  group('opening a tool', () {
    testWidgets('metoolkit://tool/500 opens the Unit Converter',
        (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await router.handle(Uri.parse('metoolkit://tool/500'));
      await tester.pumpAndSettle();

      expect(find.byType(UnitConverterPage), findsOneWidget);
    });

    testWidgets('a tool opened from a widget replaces whatever was open',
        (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      // Something the user left open — a second tool, deeper in the stack.
      await router.handle(Uri.parse('metoolkit://tool/103'));
      await tester.pumpAndSettle();
      expect(find.byType(UnitConverterPage), findsNothing);

      await router.handle(Uri.parse('metoolkit://tool/500'));
      await tester.pumpAndSettle();

      expect(find.byType(UnitConverterPage), findsOneWidget);
      // Back from here reaches the library, not the tool opened before it.
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(find.text('library'), findsOneWidget);
    });

    testWidgets('every published tool id resolves to a tool', (tester) async {
      // The widget and the Shortcuts picker offer whatever ids the app
      // publishes, so each one has to be openable. This is also what catches
      // an id removed from the library but left in a major's recommendation
      // list or a widget's snapshot.
      //
      // Generous surface because this opens all sixty-four pages and the
      // question is whether the route was pushed, not whether a matrix-heavy
      // composite page fits an 800x600 phone in landscape.
      tester.view.physicalSize = const Size(1400, 2600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      final context = navigatorKey.currentContext!;
      final ids = ToolLibrary.shared.getTools(context).map((t) => t.id);
      expect(ids, isNotEmpty);
      expect(ids.toSet().length, ids.length, reason: 'duplicate tool ids');

      for (final id in ids) {
        await router.handle(Uri.parse('metoolkit://tool/$id'));
        await tester.pumpAndSettle();
        // A tool page was pushed on top of the library, so there is something
        // to pop. An id the router could not resolve pushes nothing and
        // leaves the library frontmost, which is what this catches.
        expect(
          navigatorKey.currentState!.canPop(),
          isTrue,
          reason: 'tool $id opened nothing',
        );
        navigatorKey.currentState!.popUntil((route) => route.isFirst);
        await tester.pumpAndSettle();
      }
    });
  });

  group('links that name nothing openable', () {
    testWidgets('an unknown tool id is ignored', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      // What an old widget tile looks like after a tool is withdrawn.
      await router.handle(Uri.parse('metoolkit://tool/999999'));
      await tester.pumpAndSettle();

      expect(find.text('library'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a non-numeric tool id is ignored', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await router.handle(Uri.parse('metoolkit://tool/not-a-number'));
      await tester.pumpAndSettle();

      expect(find.text('library'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tool with no id is ignored', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await router.handle(Uri.parse('metoolkit://tool'));
      await tester.pumpAndSettle();

      expect(find.text('library'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('an unknown destination is ignored', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await router.handle(Uri.parse('metoolkit://somewhere-else'));
      await tester.pumpAndSettle();

      expect(find.text('library'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('another app\'s scheme is left alone', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await router.handle(Uri.parse('https://example.com/tool/500'));
      await tester.pumpAndSettle();

      expect(find.byType(UnitConverterPage), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('the library link', () {
    testWidgets('metoolkit://library pops back to the library',
        (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await router.handle(Uri.parse('metoolkit://tool/500'));
      await tester.pumpAndSettle();
      expect(find.byType(UnitConverterPage), findsOneWidget);

      await router.handle(Uri.parse('metoolkit://library'));
      await tester.pumpAndSettle();

      expect(find.byType(UnitConverterPage), findsNothing);
      expect(find.text('library'), findsOneWidget);
    });
  });

  group('a build that gates tools', () {
    testWidgets('a locked tool offers the upgrade instead of opening',
        (tester) async {
      // macOS holds most of the library behind Premium. A widget tile for a
      // locked tool must reach the same upgrade sheet the in-app library
      // shows, not bypass it.
      AppPlatform.overrideWith(AppPlatform.macOS);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      final context = navigatorKey.currentContext!;
      final gate = PremiumGate.read(context);
      final locked = ToolLibrary.shared
          .getTools(context)
          .firstWhere((tool) => gate.isToolLocked(tool.id));

      // Deliberately not awaited: the upsell is a modal sheet, so `handle`
      // does not return until it is dismissed, and awaiting it here would
      // hang the test rather than let it look at the sheet.
      final routed = router.handle(Uri.parse('metoolkit://tool/${locked.id}'));
      await tester.pumpAndSettle();

      // The upgrade sheet, naming the tool the tile pointed at.
      expect(
        find.text(S.of(context).Premium_Locked_Tool(locked.title)),
        findsOneWidget,
      );

      // Dismissing it leaves the library, not the locked tool.
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      await routed;
      expect(find.text('library'), findsOneWidget);
      expect(navigatorKey.currentState!.canPop(), isFalse);
    });

    testWidgets('a free tool still opens straight from a link', (tester) async {
      AppPlatform.overrideWith(AppPlatform.macOS);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      // The Unit Converter is in kFreeToolIds, so no offer should appear.
      await router.handle(Uri.parse('metoolkit://tool/500'));
      await tester.pumpAndSettle();

      expect(find.byType(UnitConverterPage), findsOneWidget);
      expect(find.byType(PremiumOffer), findsNothing);
    });
  });
}
