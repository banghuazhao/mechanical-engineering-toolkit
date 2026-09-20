import 'dart:io';

import 'package:flutter/foundation.dart';

/// What the host platform can do, asked as capabilities rather than as
/// `Platform.isX` checks scattered through the widget tree.
///
/// Two things make a single place worth having. First, a capability answers
/// the question the caller actually has — "can this build show an ad?" — which
/// stays correct if another desktop platform is added later. Second, the
/// answers are overridable, so a widget test can exercise the macOS paths on
/// whatever host the test happens to run on; `Platform.isMacOS` cannot be
/// faked, and every test runs on a Mac here anyway, which would make the
/// mobile paths untestable.
class AppPlatform {
  const AppPlatform._();

  static AppPlatform? _override;

  /// Forces every getter below to describe [platform] instead of the host.
  /// Pair with [clearOverride] in a test's tearDown.
  @visibleForTesting
  static void overrideWith(AppPlatform platform) => _override = platform;

  @visibleForTesting
  static void clearOverride() => _override = null;

  static const macOS = _MacOSPlatform();
  static const mobile = _MobilePlatform();
  static const iOS = _IOSPlatform();
  static const android = _AndroidPlatform();

  /// True while `flutter test` is running, which it sets in the environment.
  ///
  /// Never true in a shipped app: the variable is injected by the test runner.
  static final bool _inFlutterTest =
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  static AppPlatform get current {
    final override = _override;
    if (override != null) return override;
    // Every test here runs on a Mac, so reading the host would silently gate
    // features in tests that are about something else entirely — a widget test
    // for the result page would find the export button behind a paywall it
    // never asked for. Tests therefore start ungated and name the platform
    // they mean with [overrideWith].
    if (_inFlutterTest) return mobile;
    if (!kIsWeb && Platform.isMacOS) return macOS;
    if (!kIsWeb && Platform.isIOS) return iOS;
    if (!kIsWeb && Platform.isAndroid) return android;
    return mobile;
  }

  /// Whether this build serves banner and app-open ads.
  ///
  /// False on macOS: `google_mobile_ads` has no macOS implementation, so every
  /// call into it would fail, and the Mac app is sold as a one-off unlock
  /// rather than funded by advertising.
  bool get supportsAds => true;

  /// Whether some of the app is held back until a purchase.
  ///
  /// macOS gates exports and other advanced features. iOS and Android gate
  /// tools only.
  bool get gatesFeatures => false;

  bool get gatesTools => gatesFeatures;

  bool get supportsRewardedToolUnlocks => false;

  /// Whether the OS reports device model and OS version through
  /// `device_info_plus` in a form the feedback email uses.
  bool get hasDeviceInfo => true;

  /// Whether the app draws a native menu bar with keyboard shortcuts.
  ///
  /// Only macOS has one. It also decides whether tooltips quote shortcuts:
  /// "Calculate (⌘↩)" is a promise a phone cannot keep.
  bool get hasMenuBar => false;
}

class _MobilePlatform extends AppPlatform {
  const _MobilePlatform() : super._();
}

/// The phones and tablets: a free set of tools, each of the rest unlocked by
/// one rewarded ad or all of them by Premium. Advanced features stay free.
abstract class _RewardedToolsPlatform extends AppPlatform {
  const _RewardedToolsPlatform() : super._();

  @override
  bool get gatesTools => true;

  @override
  bool get supportsRewardedToolUnlocks => true;
}

class _IOSPlatform extends _RewardedToolsPlatform {
  const _IOSPlatform();
}

class _AndroidPlatform extends _RewardedToolsPlatform {
  const _AndroidPlatform();
}

class _MacOSPlatform extends AppPlatform {
  const _MacOSPlatform() : super._();

  @override
  bool get supportsAds => false;

  @override
  bool get gatesFeatures => true;

  @override
  bool get hasDeviceInfo => false;

  @override
  bool get hasMenuBar => true;
}
