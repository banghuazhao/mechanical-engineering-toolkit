import 'dart:async';

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
import 'package:mechanical_engineering_toolkit/util/rewarded_tool_ad.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'remove_ads_service_test.dart' show FakePersistence, FakePurchaseClient;
import 'tool_unlock_service_test.dart' show FakeToolAds;

void main() {
  late FakeToolAds ads;
  late ToolUnlockService unlocks;
  late RemoveAdsService purchases;
  late FakePurchaseClient client;
  var opened = 0;
  Map<String, String>? openedInputs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
    AppPlatform.overrideWith(AppPlatform.iOS);
    ads = FakeToolAds();
    unlocks = ToolUnlockService(ads: ads);
    client = FakePurchaseClient();
    purchases = RemoveAdsService(
        client: client,
        persistence: FakePersistence(),
        store: AppStore.appStore);
    opened = 0;
    openedInputs = null;
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
                        {Map<String, String>? initialInputs}) {
                      opened++;
                      openedInputs = initialInputs;
                    },
                  ),
                  initialInputs: {'load': '1200'}),
              child: const Text('open'),
            )),
          ));

  Widget wrap(Widget home,
          {ThemeData? theme,
          double scale = 1,
          Locale locale = const Locale('en')}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: purchases),
          ChangeNotifierProvider.value(value: unlocks),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.light(),
          locale: locale,
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate
          ],
          supportedLocales: S.delegate.supportedLocales,
          builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                  disableAnimations: true),
              child: child!),
          home: home,
        ),
      );

  testWidgets(
      'a completed ad opens only the chosen tool with its original inputs',
      (tester) async {
    await tester.pumpWidget(wrap(launcher()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(opened, 0);
    expect(find.byType(RewardedToolUnlockButton), findsOneWidget);
    await tester.tap(find.text('Watch ad to unlock'));
    await tester.pumpAndSettle();
    expect(opened, 1);
    expect(openedInputs, {'load': '1200'});
    expect(unlocks.unlockedToolIds, {704});
    expect(purchases.isEntitled, isFalse);
    expect(purchases.isAdsRemoved, isFalse);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(opened, 2);
    expect(ads.calls, 1);
  });

  testWidgets('skipping shows feedback and a retry earns the unlock',
      (tester) async {
    ads.earnsReward = false;
    await tester.pumpWidget(wrap(launcher()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Watch ad to unlock'));
    await tester.pumpAndSettle();
    expect(opened, 0);
    expect(unlocks.unlockedToolIds, isEmpty);
    expect(find.textContaining('The ad ended before'), findsOneWidget);
    ads.earnsReward = true;
    await tester.tap(find.text('Watch ad to unlock'));
    await tester.pumpAndSettle();
    expect(opened, 1);
  });

  testWidgets('loading prevents duplicate taps and concurrent purchases',
      (tester) async {
    ads.pending = Completer();
    await tester.pumpWidget(wrap(launcher()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Watch ad to unlock'));
    await tester.pump();
    expect(tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
        isNull);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);
    expect(find.text('Loading ad…'), findsOneWidget);
    ads.pending!.complete(RewardedToolAdOutcome.dismissed);
    await tester.pumpAndSettle();
    expect(opened, 1);
  });

  testWidgets('restoring the unchanged product unlocks every iOS tool',
      (tester) async {
    await tester.runAsync(purchases.init);
    await tester.pumpWidget(wrap(const RemoveAdsPage()));
    await tester.pumpAndSettle();
    expect(find.byType(PremiumOffer), findsOneWidget);
    expect(find.text('Remove all ads'), findsOneWidget);
    expect(
        find.text(
            'Premium on iPhone, iPad and Mac with the same Apple Account'),
        findsOneWidget);
    await tester.runAsync(() async {
      client.emit(const StorePurchaseUpdate(
        productId: 'com.appsbay.mechanicalEngineeringToolkit.remove_ads',
        status: StorePurchaseStatus.restored,
      ));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(find.text('Premium user'), findsOneWidget);
    final gate = PremiumGate.read(tester.element(find.byType(RemoveAdsPage)));
    expect(gate.isToolLocked(704), isFalse);
    expect(gate.isToolLocked(705), isFalse);
    expect(purchases.isAdsRemoved, isTrue);
    expect(ads.calls, 0);
  });

  for (final size in [
    const Size(375, 667),
    const Size(667, 375),
    const Size(1024, 768)
  ]) {
    for (final dark in [false, true]) {
      testWidgets('reward offer fits $size dark=$dark with large text',
          (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(wrap(launcher(),
            theme: dark ? AppTheme.dark() : AppTheme.light(),
            scale: 2,
            locale: const Locale('de')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final later = find.text(S.current.Maybe_Later);
        await tester.ensureVisible(later);
        await tester.pumpAndSettle();
        await tester.tap(later);
        await tester.pumpAndSettle();
        expect(find.byType(PremiumOffer), findsNothing);
        expect(opened, 0);
      });
    }
  }
}
