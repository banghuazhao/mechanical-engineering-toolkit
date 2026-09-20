import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mechanical_engineering_toolkit/util/ads_manager.dart';
import 'package:mechanical_engineering_toolkit/util/app_platform.dart';

enum RewardedToolAdOutcome { dismissed, unavailable }

abstract interface class RewardedToolAdClient {
  Future<RewardedToolAdOutcome> show({required VoidCallback onReward});
}

class GoogleRewardedToolAdClient implements RewardedToolAdClient {
  // Keep production configuration separate from Google's debug-only test
  // units. Each store build injects its own id with --dart-define.
  static const iosProductionAdUnitId =
      String.fromEnvironment('IOS_REWARDED_AD_UNIT_ID');
  static const androidProductionAdUnitId =
      String.fromEnvironment('ANDROID_REWARDED_AD_UNIT_ID');
  static String get adUnitId => Platform.isAndroid
      ? (kDebugMode
          ? 'ca-app-pub-3940256099942544/5224354917'
          : androidProductionAdUnitId)
      : (kDebugMode
          ? 'ca-app-pub-3940256099942544/1712485313'
          : iosProductionAdUnitId);

  @override
  Future<RewardedToolAdOutcome> show({required VoidCallback onReward}) async {
    if (!AppPlatform.current.supportsRewardedToolUnlocks ||
        AdsManager.disableAllAdsForScreenshot ||
        AdsManager.adsRemoved ||
        adUnitId.isEmpty ||
        AdsManager.rewardedAdInProgress) {
      return RewardedToolAdOutcome.unavailable;
    }

    // Also suppress app-open ads while consent or an ad's external link is open.
    AdsManager.rewardedAdInProgress = true;
    RewardedAd? ad;
    try {
      if (!await AdsManager.canRequestAds()
          .timeout(const Duration(seconds: 30))) {
        return RewardedToolAdOutcome.unavailable;
      }
      final loaded = Completer<RewardedAd?>();
      var expired = false;
      try {
        await RewardedAd.load(
          adUnitId: adUnitId,
          request: AdsManager.buildAdRequest(),
          rewardedAdLoadCallback: RewardedAdLoadCallback(
            onAdLoaded: (value) {
              if (expired || loaded.isCompleted) {
                value.dispose();
              } else {
                loaded.complete(value);
              }
            },
            onAdFailedToLoad: (_) {
              if (!loaded.isCompleted) loaded.complete(null);
            },
          ),
        );
        ad = await loaded.future.timeout(const Duration(seconds: 30));
      } finally {
        expired = true;
      }
      if (ad == null || AdsManager.adsRemoved) {
        return RewardedToolAdOutcome.unavailable;
      }
      final finished = Completer<RewardedToolAdOutcome>();
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (_) {
          if (!finished.isCompleted) {
            finished.complete(RewardedToolAdOutcome.dismissed);
          }
        },
        onAdFailedToShowFullScreenContent: (_, error) {
          if (!finished.isCompleted) {
            finished.complete(RewardedToolAdOutcome.unavailable);
          }
        },
      );
      await ad.show(onUserEarnedReward: (_, reward) => onReward());
      return await finished.future;
    } catch (_) {
      return RewardedToolAdOutcome.unavailable;
    } finally {
      try {
        await ad?.dispose();
      } finally {
        // Native dismissal and app-resume events can arrive in either order.
        AdsManager.suppressAppOpenUntil =
            DateTime.now().add(const Duration(seconds: 2));
        AdsManager.rewardedAdInProgress = false;
      }
    }
  }
}
