import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/generated/l10n.dart';
import 'package:mechanical_engineering_toolkit/home/tool_launcher.dart';
import 'package:mechanical_engineering_toolkit/home/tool_model.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium_upsell.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_page.dart';
import 'package:mechanical_engineering_toolkit/purchase/remove_ads_service.dart';
import 'package:mechanical_engineering_toolkit/purchase/tool_unlock_service.dart';
import 'package:mechanical_engineering_toolkit/ui/app_theme.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remove_ads_service_test.dart' show FakePersistence, FakePurchaseClient;
import 'tool_unlock_service_test.dart' show FakeToolAds;

/// Android sells the Play `remove_ads` product as Premium, on the same terms
/// as iOS: a free set of tools, one rewarded ad per extra tool, or all of them
/// with the purchase. Only the store wording differs.
void main() {
  late FakeToolAds ads;
  late ToolUnlockService unlocks;
  late RemoveAdsService purchases;
  late FakePurchaseClient client;
  var opened = 0;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
    AppPlatform.overrideWith(AppPlatform.android);
    ads = FakeToolAds();
    unlocks = ToolUnlockService(ads: ads);
    client = FakePurchaseClient();
    purchases = RemoveAdsService(
        client: client,
        persistence: FakePersistence(),
        store: AppStore.playStore);
    opened = 0;
  });
  tearDown(() {
    unlocks.dispose();
    purchases.dispose();
    AppPlatform.clearOverride();
  });

  Widget launcher({int toolId = 704}) => Builder(
      builder: (context) => Scaffold(
            body: Center(
                child: ElevatedButton(
              onPressed: () => launchTool(
                context,
                Tool(
                  id: toolId,
                  title: 'Bearing L10 Life',
                  type: ToolType.mechanicsOfMaterial,
                  action: (context, title, id,
                          {Map<String, String>? initialInputs}) =>
                      opened++,
                ),
              ),
              child: const Text('open'),
            )),
          ));

  Widget wrap(Widget home) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: purchases),
          ChangeNotifierProvider.value(value: unlocks),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: home,
        ),
      );

  test('Android gates tools and accepts rewarded unlocks, as iOS does', () {
    expect(AppPlatform.android.gatesTools, isTrue);
    expect(AppPlatform.android.supportsRewardedToolUnlocks, isTrue);
    expect(AppPlatform.android.gatesFeatures, isFalse);
    expect(AppPlatform.android.supportsAds, isTrue);
  });

  test('every capability that decides what is paid for matches iOS', () {
    const ios = AppPlatform.iOS;
    const android = AppPlatform.android;
    expect(android.gatesTools, ios.gatesTools);
    expect(android.gatesFeatures, ios.gatesFeatures);
    expect(android.supportsRewardedToolUnlocks, ios.supportsRewardedToolUnlocks);
    expect(android.supportsAds, ios.supportsAds);
  });

  test('Premium unlocks every tool on Android, exactly as on iOS', () {
    for (final platform in [AppPlatform.android, AppPlatform.iOS]) {
      AppPlatform.overrideWith(platform);
      const premium = PremiumGate(isEntitled: true, gatesFeatures: false, gatesTools: true);
      const free = PremiumGate(isEntitled: false, gatesFeatures: false, gatesTools: true);
      const watchedOne =
          PremiumGate(isEntitled: false, gatesFeatures: false, gatesTools: true, rewardedToolIds: {704});
      for (final id in [704, 705, 900, 901]) {
        expect(premium.isToolLocked(id), isFalse, reason: 'Premium, tool $id on $platform');
      }
      expect(premium.isUnlocked, isTrue);
      expect(free.isToolLocked(704), isTrue);
      expect(free.isToolLocked(kFreeToolIds.first), isFalse);
      // One rewarded ad unlocks that one tool and nothing else.
      expect(watchedOne.isToolLocked(704), isFalse);
      expect(watchedOne.isToolLocked(705), isTrue);
      // Exports, projects, history and sweeps stay free on both.
      for (final feature in PremiumFeature.values) {
        expect(free.isFeatureLocked(feature), isFalse);
      }
    }
  });

  testWidgets('a free tool opens straight away', (tester) async {
    await tester.pumpWidget(wrap(launcher(toolId: kFreeToolIds.first)));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(find.byType(PremiumOffer), findsNothing);
  });

  testWidgets('a completed ad unlocks only the chosen tool', (tester) async {
    await tester.pumpWidget(wrap(launcher()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(opened, 0);
    expect(find.byType(RewardedToolUnlockButton), findsOneWidget);
    await tester.tap(find.text('Watch ad to unlock'));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(unlocks.unlockedToolIds, {704});
    expect(purchases.isEntitled, isFalse);
    final gate = PremiumGate.read(tester.element(find.text('open')));
    expect(gate.isToolLocked(705), isTrue);
  });

  testWidgets('the offer speaks of Google Play, not Apple', (tester) async {
    await tester.runAsync(purchases.init);
    await tester.pumpWidget(wrap(const RemoveAdsPage()));
    await tester.pumpAndSettle();
    expect(find.byType(PremiumOffer), findsOneWidget);
    expect(find.text('Remove all ads'), findsOneWidget);
    expect(find.text(S.current.Premium_Description_Play), findsOneWidget);
    expect(find.textContaining('Apple'), findsNothing);
    expect(find.textContaining('iPhone'), findsNothing);
    expect(client.loadedProductIds, contains('remove_ads'));
  });

  testWidgets('an existing Remove Ads purchase is Premium', (tester) async {
    await tester.runAsync(purchases.init);
    await tester.pumpWidget(wrap(const RemoveAdsPage()));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      client.emit(const StorePurchaseUpdate(
        productId: 'remove_ads',
        status: StorePurchaseStatus.restored,
      ));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(find.text('Premium user'), findsOneWidget);
    expect(
        find.text(S.current.Premium_Unlocked_Description_Play), findsOneWidget);
    final gate = PremiumGate.read(tester.element(find.byType(RemoveAdsPage)));
    expect(gate.isToolLocked(704), isFalse);
    expect(purchases.isAdsRemoved, isTrue);
    expect(ads.calls, 0);
  });
}
