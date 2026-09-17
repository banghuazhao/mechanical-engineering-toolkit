import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/favorites.dart';
import 'package:mechanical_engineering_toolkit/home/history.dart';
import 'package:mechanical_engineering_toolkit/home/saved_projects.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/purchase/tool_unlock_service.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:mechanical_engineering_toolkit/util/material_library.dart';
import 'package:mechanical_engineering_toolkit/util/number.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/shortcut_bridge.dart';
import 'package:mechanical_engineering_toolkit/util/shortcut_publisher.dart';
import 'package:mechanical_engineering_toolkit/util/unit_system.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remove_ads_service_test.dart' show FakePersistence, FakePurchaseClient;

/// Stands in for `METoolkitShortcutBridge` on the native side.
class _FakeHost {
  final List<MethodCall> calls = [];

  /// What `publishSnapshot` reports back — false is a build with no App Group
  /// entitlement.
  bool writeSucceeds = true;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel(ShortcutBridge.channelName),
      (call) async {
        calls.add(call);
        return switch (call.method) {
          'publishSnapshot' => writeSucceeds,
          'appGroupIdentifier' => 'group.test',
          _ => null,
        };
      },
    );
  }

  void remove() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
            const MethodChannel(ShortcutBridge.channelName), null);
  }

  List<MethodCall> get publishes =>
      calls.where((c) => c.method == 'publishSnapshot').toList();

  Map<String, Object?> get lastPayload =>
      (publishes.last.arguments as Map).cast<String, Object?>();
}

/// Delivers a call from the native side to Dart, as the real bridge does.
Future<void> _sendFromNative(String method, Object? arguments) {
  return TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .handlePlatformMessage(
    ShortcutBridge.channelName,
    const StandardMethodCodec().encodeMethodCall(MethodCall(method, arguments)),
    (_) {},
  );
}


/// Settles the tree and then lets [ShortcutPublisher.firstPublishDelay]
/// elapse, since the first publish is deliberately held back until after the
/// app has drawn — `pumpAndSettle` alone returns before that timer fires.
Future<void> _settleAndPublish(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(
      ShortcutPublisher.firstPublishDelay + const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeHost host;
  late RemoveAdsService purchases;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
    // Tests run on a Mac host, where isSupported is already true, but saying
    // so keeps the suite honest on a Linux CI box.
    ShortcutBridge.debugForceSupported = true;
    ShortcutBridge.debugReset();
    host = _FakeHost()..install();
    purchases = RemoveAdsService(
      client: FakePurchaseClient(),
      persistence: FakePersistence(value: false),
      store: AppStore.macAppStore,
    )..loadPersistedEntitlement();
  });

  tearDown(() {
    host.remove();
    ShortcutBridge.debugReset();
    ShortcutBridge.debugForceSupported = false;
    AppPlatform.clearOverride();
    purchases.dispose();
  });

  group('the link handshake', () {
    test('installing a handler tells the native side it is ready', () async {
      await ShortcutBridge.installLinkHandler((_) {});
      expect(host.calls.map((c) => c.method), contains('ready'));
    });

    test('a link from the native side reaches the handler', () async {
      final seen = <Uri>[];
      await ShortcutBridge.installLinkHandler(seen.add);

      await _sendFromNative('openDeepLink', 'metoolkit://tool/500');

      expect(seen, [Uri.parse('metoolkit://tool/500')]);
    });

    test('a link that is not a string is ignored', () async {
      final seen = <Uri>[];
      await ShortcutBridge.installLinkHandler(seen.add);

      await _sendFromNative('openDeepLink', 42);

      expect(seen, isEmpty);
    });

    test('an unknown method is ignored', () async {
      final seen = <Uri>[];
      await ShortcutBridge.installLinkHandler(seen.add);

      await _sendFromNative('somethingElse', 'metoolkit://tool/500');

      expect(seen, isEmpty);
    });
  });

  group('publishSnapshot', () {
    test('reports what the native side says', () async {
      expect(
        await ShortcutBridge.publishSnapshot(
            tools: const [], favoriteIds: [], recentIds: []),
        isTrue,
      );

      host.writeSucceeds = false;
      expect(
        await ShortcutBridge.publishSnapshot(
            tools: const [], favoriteIds: [], recentIds: []),
        isFalse,
      );
    });

    test('a host without the bridge is not an error', () async {
      host.remove();
      expect(
        await ShortcutBridge.publishSnapshot(
            tools: const [], favoriteIds: [], recentIds: []),
        isFalse,
      );
    });
  });

  group('ShortcutPublisher', () {
    Widget wrap({
      required Favorites favorites,
      required ToolHistory history,
    }) =>
        MultiProvider(
          providers: [
            ChangeNotifierProvider<RemoveAdsService>.value(value: purchases),
            ChangeNotifierProvider(create: (_) => ToolUnlockService()),
            ChangeNotifierProvider(create: (_) => NumberPrecisionHelper()),
            ChangeNotifierProvider(create: (_) => UnitSystemPreference()),
            ChangeNotifierProvider<Favorites>.value(value: favorites),
            ChangeNotifierProvider(create: (_) => SavedProjects()),
            ChangeNotifierProvider<ToolHistory>.value(value: history),
            ChangeNotifierProvider(create: (_) => MaterialLibrary()),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: S.delegate.supportedLocales,
            home: const ShortcutPublisher(child: SizedBox.shrink()),
          ),
        );

    testWidgets('publishes the whole library once on first build',
        (tester) async {
      await tester.pumpWidget(
          wrap(favorites: Favorites(), history: ToolHistory()));
      await _settleAndPublish(tester);

      expect(host.publishes, hasLength(1));
      final tools = (host.lastPayload['tools'] as List).cast<Map>();
      expect(tools, isNotEmpty);

      final context = tester.element(find.byType(ShortcutPublisher));
      expect(tools, hasLength(ToolLibrary.shared.getTools(context).length));

      // Localized title and a stable category id on every entry.
      for (final tool in tools) {
        expect(tool['id'], isA<int>());
        expect(tool['title'], isA<String>());
        expect(tool['title'], isNotEmpty);
        expect(tool['categoryId'], isNotEmpty);
        expect(tool['category'], isNotEmpty);
        expect(tool['locked'], isA<bool>());
      }
    });

    testWidgets('the Unit Converter travels with its real id', (tester) async {
      // The widget's convert button and the "Open Unit Converter" shortcut
      // both hardcode 500 on the Swift side.
      await tester.pumpWidget(
          wrap(favorites: Favorites(), history: ToolHistory()));
      await _settleAndPublish(tester);

      final tools = (host.lastPayload['tools'] as List).cast<Map>();
      expect(tools.where((t) => t['id'] == 500), hasLength(1));
    });

    testWidgets('carries favourites in the order they were starred',
        (tester) async {
      final favorites = Favorites()
        ..add(500)
        ..add(103);
      await tester.pumpWidget(
          wrap(favorites: favorites, history: ToolHistory()));
      await _settleAndPublish(tester);

      expect(host.lastPayload['favoriteIds'], [500, 103]);
    });

    testWidgets('collapses repeated runs of one tool in recents',
        (tester) async {
      final history = ToolHistory()
        ..record(103)
        ..record(500)
        ..record(500)
        ..record(103);
      await tester.pumpWidget(
          wrap(favorites: Favorites(), history: history));
      await _settleAndPublish(tester);

      // Newest first, each tool once.
      expect(host.lastPayload['recentIds'], [103, 500]);
    });

    testWidgets('does not republish when nothing has changed',
        (tester) async {
      final favorites = Favorites();
      await tester.pumpWidget(
          wrap(favorites: favorites, history: ToolHistory()));
      await _settleAndPublish(tester);
      expect(host.publishes, hasLength(1));

      // A rebuild that changes none of the published data.
      favorites.notifyListeners();
      await tester.pumpAndSettle();

      expect(host.publishes, hasLength(1));
    });

    testWidgets('republishes when a favourite is added', (tester) async {
      final favorites = Favorites();
      await tester.pumpWidget(
          wrap(favorites: favorites, history: ToolHistory()));
      await _settleAndPublish(tester);
      expect(host.publishes, hasLength(1));

      favorites.add(500);
      await tester.pumpAndSettle();

      expect(host.publishes, hasLength(2));
      expect(host.lastPayload['favoriteIds'], [500]);
    });

    testWidgets('retries after a publish the host could not write',
        (tester) async {
      // A build without the App Group entitlement. The next change must try
      // again rather than assume the widget already has the data.
      host.writeSucceeds = false;
      final favorites = Favorites();
      await tester.pumpWidget(
          wrap(favorites: favorites, history: ToolHistory()));
      await _settleAndPublish(tester);
      expect(host.publishes, hasLength(1));

      favorites.notifyListeners();
      await tester.pumpAndSettle();

      expect(host.publishes, hasLength(2));
    });

    testWidgets('marks locked tools on a build that gates them',
        (tester) async {
      AppPlatform.overrideWith(AppPlatform.macOS);

      await tester.pumpWidget(
          wrap(favorites: Favorites(), history: ToolHistory()));
      await _settleAndPublish(tester);

      final tools = (host.lastPayload['tools'] as List).cast<Map>();
      expect(tools.where((t) => t['locked'] == true), isNotEmpty,
          reason: 'macOS holds most of the library behind Premium');
      // The free tier still includes the Unit Converter.
      expect(
        tools.firstWhere((t) => t['id'] == 500)['locked'],
        isFalse,
      );
    });

    testWidgets('nothing is locked on a build that gates nothing',
        (tester) async {
      AppPlatform.overrideWith(AppPlatform.mobile);

      await tester.pumpWidget(
          wrap(favorites: Favorites(), history: ToolHistory()));
      await _settleAndPublish(tester);

      final tools = (host.lastPayload['tools'] as List).cast<Map>();
      expect(tools.where((t) => t['locked'] == true), isEmpty);
    });
  });
}
