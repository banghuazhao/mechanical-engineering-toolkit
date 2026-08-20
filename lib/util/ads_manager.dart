import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mechanical_engineering_toolkit/util/secrets.dart';

class AdsManager {
  static bool disableAllAdsForScreenshot = false;
  static String bannerAdUnitIdIOS = Secrets.bannerAdUnitIdIOS;
  static String openAdUnitIDIOS = Secrets.openAdUnitIDIOS;
  static String bannerAdUnitIdAndroid = Secrets.bannerAdUnitIdAndroid;
  static String openAdUnitIDAndroid = Secrets.openAdUnitIDAndroid;
  static Future<bool>? _consentFuture;
  static Future<InitializationStatus>? _mobileAdsInitialization;
  static bool _adsRemoved = false;
  static bool _trackingAuthorized = false;
  static final Set<AppOpenAdManager> _appOpenManagers = {};

  static bool get adsRemoved => _adsRemoved;

  static void setAdsRemoved(bool value) {
    if (_adsRemoved == value) return;
    _adsRemoved = value;
    if (value) {
      for (final manager in _appOpenManagers.toList()) {
        manager.dispose();
      }
    }
  }

  /// Updates UMP consent on every app launch and only enables ads after all
  /// required consent messages have been handled.
  static Future<bool> canRequestAds() {
    if (_adsRemoved) return Future.value(false);
    return _consentFuture ??= _requestConsent();
  }

  static Future<bool> isPrivacyOptionsRequired() async {
    await canRequestAds();
    return await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  static Future<FormError?> showPrivacyOptions() async {
    final completer = Completer<FormError?>();
    await ConsentForm.showPrivacyOptionsForm(completer.complete);
    return completer.future;
  }

  /// Debug-only: pretends the device is in the EEA so the GDPR/UMP consent
  /// form can be exercised on a simulator, which otherwise geolocates to
  /// wherever the host machine is and never shows the form.
  ///
  /// Enable with `--dart-define=FORCE_EEA_CONSENT=true` on a debug run. The
  /// key is a const literal with a safe `false` default, and the whole thing
  /// is additionally gated on [kDebugMode], so a release build ignores it even
  /// if the define is passed.
  static const bool _forceEeaConsentGeography =
      bool.fromEnvironment('FORCE_EEA_CONSENT');

  static ConsentDebugSettings? get _debugConsentSettings {
    if (!kDebugMode || !_forceEeaConsentGeography) return null;
    return ConsentDebugSettings(
      debugGeography: DebugGeography.debugGeographyEea,
    );
  }

  static Future<bool> _requestConsent() async {
    final completer = Completer<bool>();
    final parameters = ConsentRequestParameters(
      consentDebugSettings: _debugConsentSettings,
    );

    ConsentInformation.instance.requestConsentInfoUpdate(
      parameters,
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((formError) async {
          if (formError != null) {
            debugPrint('Unable to show the consent form: $formError');
          }
          await _finishConsentRequest(completer);
        });
      },
      (error) async {
        // A previously stored valid choice may still permit ad requests when
        // refreshing consent information temporarily fails.
        debugPrint('Unable to update consent information: $error');
        await _finishConsentRequest(completer);
      },
    );

    return completer.future;
  }

  /// Requests iOS App Tracking Transparency permission, and reports whether
  /// the user allows tracking. Runs *after* UMP consent has been gathered,
  /// which is the order Google documents for apps using both.
  ///
  /// The system prompt is only available while the app is active, and iOS only
  /// shows it while the authorization state is undetermined — an earlier
  /// denial is read back and never re-asked. Platforms without ATT have no
  /// such restriction and report `true`.
  static Future<bool> _requestTrackingAuthorizationIfNeeded() async {
    if (!Platform.isIOS) return true;

    try {
      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await _waitUntilAppIsResumed();
        // Allow the first frame and launch transition to settle before asking
        // iOS to present its native permission sheet.
        await Future<void>.delayed(const Duration(milliseconds: 350));
        status = await AppTrackingTransparency.requestTrackingAuthorization();
      }
      return status == TrackingStatus.authorized;
    } catch (error) {
      debugPrint(
          'Unable to request App Tracking Transparency permission: $error');
      // An unusable ATT result is never treated as permission to track.
      return false;
    }
  }

  static Future<void> _waitUntilAppIsResumed() async {
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      return;
    }

    final completer = Completer<void>();
    final observer = _AppResumeObserver(completer);
    WidgetsBinding.instance.addObserver(observer);
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      observer.complete();
    }
    await completer.future;
    WidgetsBinding.instance.removeObserver(observer);
  }

  static Future<void> _finishConsentRequest(Completer<bool> completer) async {
    if (completer.isCompleted) return;

    // UMP consent has been gathered by this point; ask for ATT second, per
    // Google's documented order for apps that use both.
    _trackingAuthorized = await _requestTrackingAuthorizationIfNeeded();

    final allowed =
        !_adsRemoved && await ConsentInformation.instance.canRequestAds();
    if (allowed) {
      _mobileAdsInitialization ??= MobileAds.instance.initialize();
      await _mobileAdsInitialization;
    }
    if (!completer.isCompleted) completer.complete(allowed);
  }

  /// Whether the user allows tracking. Always `true` off iOS, where there is
  /// no ATT prompt and UMP alone governs.
  static bool get trackingAuthorized => _trackingAuthorized;

  /// The single source of truth for "may we personalize this ad".
  ///
  /// Combines the UMP consent state (which the SDK applies from stored
  /// consent) with the iOS ATT answer. The most restrictive of the two wins
  /// regardless of which prompt the user saw first: a denial in either one
  /// yields a non-personalized request, and iOS additionally withholds the
  /// advertising identifier on its own.
  static AdRequest buildAdRequest() =>
      AdRequest(nonPersonalizedAds: !_trackingAuthorized);

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        if (disableAllAdsForScreenshot) {
          return "";
        } else {
          return "ca-app-pub-3940256099942544/6300978111";
        }
      } else {
        // android banner ID
        return bannerAdUnitIdAndroid;
      }
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        if (disableAllAdsForScreenshot) {
          return "";
        } else {
          return "ca-app-pub-3940256099942544/2934735716";
        }
      } else {
        // ios banner ID
        return bannerAdUnitIdIOS;
      }
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get openAdUnitID {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        if (disableAllAdsForScreenshot) {
          return "";
        } else {
          return 'ca-app-pub-3940256099942544/9257395921';
        }
      } else {
        // android openAd ID
        return openAdUnitIDAndroid;
      }
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        if (disableAllAdsForScreenshot) {
          return "";
        } else {
          return 'ca-app-pub-3940256099942544/5575463023';
        }
      } else {
        // ios openAd ID
        return openAdUnitIDIOS;
      }
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static void debugPrintID() {
    if (kDebugMode) {
      debugPrint("bannerAdUnitId: ${AdsManager.bannerAdUnitId}");
      debugPrint("openAdUnitID: ${AdsManager.openAdUnitID}");
    }
  }
}

class _AppResumeObserver with WidgetsBindingObserver {
  _AppResumeObserver(this.completer);

  final Completer<void> completer;

  void complete() {
    if (!completer.isCompleted) completer.complete();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) complete();
  }
}

class AppOpenAdManager {
  AppOpenAdManager() {
    AdsManager._appOpenManagers.add(this);
  }

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  static bool bypassShowAd = false;

  /// Maximum duration allowed between loading and showing the ad.
  final Duration maxCacheDuration = const Duration(hours: 4);

  /// Keep track of load time so we don't show an expired ad.
  DateTime? _appOpenLoadTime;

  /// Load an AppOpenAd.
  Future<void> loadAd() async {
    if (!await AdsManager.canRequestAds()) return;

    AppOpenAd.load(
      adUnitId: AdsManager.openAdUnitID,
      request: AdsManager.buildAdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded');
          _appOpenLoadTime = DateTime.now();
          _appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
          // Handle the error.
        },
      ),
    );
  }

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return _appOpenAd != null;
  }

  void showAdIfAvailable() {
    if (AdsManager.adsRemoved) {
      dispose();
      return;
    }
    if (bypassShowAd) {
      bypassShowAd = false;
      return;
    }
    if (!isAdAvailable) {
      debugPrint('Tried to show ad before available.');
      loadAd();
      return;
    }
    if (_isShowingAd) {
      debugPrint('Tried to show ad while already showing an ad.');
      return;
    }
    if (DateTime.now().subtract(maxCacheDuration).isAfter(_appOpenLoadTime!)) {
      debugPrint('Maximum cache duration exceeded. Loading another ad.');
      _appOpenAd!.dispose();
      _appOpenAd = null;
      loadAd();
      return;
    }

    // Set the fullScreenContentCallback and show the ad.
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );
    _appOpenAd!.show();
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _appOpenLoadTime = null;
  }
}

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor extends WidgetsBindingObserver {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    // Try to show an app open ad if the app is being resumed and
    // we're not already showing an app open ad.
    debugPrint("didChangeAppLifecycleState: $state");
    if (state == AppLifecycleState.resumed) {
      appOpenAdManager.showAdIfAvailable();
    }
  }
}
