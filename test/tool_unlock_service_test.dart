import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mechanical_engineering_toolkit/purchase/premium.dart';
import 'package:mechanical_engineering_toolkit/purchase/tool_unlock_service.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';
import 'package:mechanical_engineering_toolkit/util/others.dart';
import 'package:mechanical_engineering_toolkit/util/rewarded_tool_ad.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeToolAds implements RewardedToolAdClient {
  bool earnsReward = true;
  int calls = 0;
  Completer<RewardedToolAdOutcome>? pending;
  RewardedToolAdOutcome outcome = RewardedToolAdOutcome.dismissed;

  @override
  Future<RewardedToolAdOutcome> show({required VoidCallback onReward}) async {
    calls++;
    if (earnsReward) {
      onReward();
      onReward(); // A duplicate callback must not grant a second tool.
    }
    return pending == null ? outcome : await pending!.future;
  }
}

class FailingToolPersistence implements ToolUnlockPersistence {
  @override
  Set<int> read() => {};
  @override
  Future<bool> write(Set<int> toolIds) async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesHelper.init();
    AppPlatform.overrideWith(AppPlatform.iOS);
  });
  tearDown(AppPlatform.clearOverride);

  test('one ad unlocks only one tool and survives a service restart', () async {
    final ads = FakeToolAds();
    final service = ToolUnlockService(ads: ads);
    expect(await service.unlockWithAd(704), ToolUnlockResult.unlocked);
    expect(service.unlockedToolIds, {704});
    expect(await service.unlockWithAd(704), ToolUnlockResult.unlocked);
    expect(ads.calls, 1);
    final restored = ToolUnlockService(ads: ads);
    expect(restored.unlockedToolIds, {704});
    expect(await restored.unlockWithAd(705), ToolUnlockResult.unlocked);
    expect(restored.unlockedToolIds, {704, 705});
    expect(ads.calls, 2);
    service.dispose();
    restored.dispose();
  });

  test('skipped ads and no-fill never unlock a tool', () async {
    final ads = FakeToolAds()..earnsReward = false;
    final service = ToolUnlockService(ads: ads);
    expect(await service.unlockWithAd(704), ToolUnlockResult.skipped);
    ads.outcome = RewardedToolAdOutcome.unavailable;
    expect(await service.unlockWithAd(704), ToolUnlockResult.unavailable);
    expect(service.unlockedToolIds, isEmpty);
    service.dispose();
  });

  test('a concurrent tap cannot spend the same reward on another tool',
      () async {
    final ads = FakeToolAds()..pending = Completer();
    final service = ToolUnlockService(ads: ads);
    final first = service.unlockWithAd(704);
    expect(await service.unlockWithAd(705), ToolUnlockResult.busy);
    // The reward is persisted before dismissal, not only when the screen closes.
    await Future<void>.delayed(Duration.zero);
    expect(SharedPreferencesToolUnlockPersistence().read(), {704});
    ads.pending!.complete(RewardedToolAdOutcome.dismissed);
    expect(await first, ToolUnlockResult.unlocked);
    expect(ads.calls, 1);
    expect(service.isBusy, isFalse);
    service.dispose();
  });

  test('storage failure is reported without claiming a permanent unlock',
      () async {
    final service = ToolUnlockService(
        ads: FakeToolAds(), persistence: FailingToolPersistence());
    expect(await service.unlockWithAd(704), ToolUnlockResult.saveFailed);
    expect(service.unlockedToolIds, isEmpty);
    expect(service.isBusy, isFalse);
    service.dispose();
  });

  test('iOS gates only tools and rewarded unlocks do not grant Premium', () {
    const gate = PremiumGate(
        isEntitled: false,
        gatesFeatures: false,
        gatesTools: true,
        rewardedToolIds: {704});
    expect(gate.isToolLocked(500), isFalse);
    expect(gate.isToolLocked(704), isFalse);
    expect(gate.isToolLocked(705), isTrue);
    expect(gate.isEntitled, isFalse);
    expect(gate.historyLimit, isNull);
    for (final feature in PremiumFeature.values) {
      expect(gate.isFeatureLocked(feature), isFalse);
    }
    expect(AppPlatform.current.gatesTools, isTrue);
    expect(AppPlatform.current.gatesFeatures, isFalse);
  });

  test('macOS and Android never request rewarded ads', () async {
    final ads = FakeToolAds();
    final service = ToolUnlockService(ads: ads);
    for (final platform in [AppPlatform.macOS, AppPlatform.mobile]) {
      AppPlatform.overrideWith(platform);
      expect(await service.unlockWithAd(704), ToolUnlockResult.unavailable);
    }
    expect(ads.calls, 0);
    service.dispose();
  });
}
