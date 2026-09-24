import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// One tool as published to the Home Screen widget and the Shortcuts actions.
@immutable
class ShortcutToolSummary {
  const ShortcutToolSummary({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.category,
    required this.locked,
  });

  final int id;

  /// Already localized — the widget and the Shortcuts picker carry no copy of
  /// the tool names, so whatever language the app is running in is the
  /// language they show.
  final String title;

  /// The `ToolType` case name. Locale-independent, so the widget can map it
  /// to a glyph.
  final String categoryId;

  /// Localized category name.
  final String category;

  /// Whether this build holds the tool behind Premium, so the widget can mark
  /// the tile. The tap is still allowed; the app answers with its own upgrade
  /// sheet, exactly as the in-app library does.
  final bool locked;

  Map<String, Object?> toChannelMap() => {
        'id': id,
        'title': title,
        'categoryId': categoryId,
        'category': category,
        'locked': locked,
      };

  @override
  bool operator ==(Object other) =>
      other is ShortcutToolSummary &&
      other.id == id &&
      other.title == title &&
      other.categoryId == categoryId &&
      other.category == category &&
      other.locked == locked;

  @override
  int get hashCode => Object.hash(id, title, categoryId, category, locked);
}

/// Talks to `apple/METoolkitShared/ShortcutBridge.swift` on iOS and macOS,
/// and to `ShortcutBridge.kt` on Android — one channel, the same three
/// methods. On Apple platforms the snapshot feeds the WidgetKit widgets and
/// the Shortcuts actions; on Android, the App Widgets and the launcher
/// shortcuts.
///
/// Everything here is a no-op elsewhere, so the caller needs no platform
/// check of its own.
class ShortcutBridge {
  ShortcutBridge._();

  @visibleForTesting
  static const channelName =
      'com.appsbay.mechanicalEngineeringToolkit/shortcuts';

  static const MethodChannel _channel = MethodChannel(channelName);

  /// Overridable so a test can install a mock channel without a real engine.
  @visibleForTesting
  static bool debugForceSupported = false;

  static bool get isSupported {
    if (debugForceSupported) return true;
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS || Platform.isAndroid;
  }

  static void Function(Uri link)? _linkHandler;
  static bool _handlerInstalled = false;

  /// Installs [handler] for links arriving from a widget tile or a Shortcuts
  /// action, then tells the native side it is safe to deliver.
  ///
  /// The two steps are ordered deliberately. The native side queues every
  /// link that arrives before this call — a cold launch from a widget tap
  /// delivers the URL long before `runApp` has a navigator — and drains the
  /// queue when it hears `ready`. Registering the handler afterwards would
  /// drop exactly those links.
  static Future<void> installLinkHandler(
    void Function(Uri link) handler,
  ) async {
    _linkHandler = handler;
    if (!isSupported) return;
    if (!_handlerInstalled) {
      _channel.setMethodCallHandler(_handleNativeCall);
      _handlerInstalled = true;
    }
    try {
      await _channel.invokeMethod<void>('ready');
    } on PlatformException catch (error) {
      debugPrint('ShortcutBridge: handshake failed — $error');
    } on MissingPluginException {
      // An older host binary without the bridge. Deep links simply will not
      // arrive; nothing else in the app depends on this.
    }
  }

  static Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method != 'openDeepLink') return null;
    final raw = call.arguments;
    if (raw is! String) return null;
    final uri = Uri.tryParse(raw);
    if (uri == null) {
      debugPrint('ShortcutBridge: unparseable deep link "$raw"');
      return null;
    }
    _linkHandler?.call(uri);
    return null;
  }

  /// Hands the widgets and shortcuts their content and asks them to redraw.
  ///
  /// Returns false when the platform has nowhere to put it — an unsupported
  /// platform, or on Apple platforms a missing App Group entitlement, which
  /// is what a build signed without it looks like from here.
  static Future<bool> publishSnapshot({
    required List<ShortcutToolSummary> tools,
    required List<int> favoriteIds,
    required List<int> recentIds,
  }) async {
    if (!isSupported) return false;
    try {
      final wrote = await _channel.invokeMethod<bool>('publishSnapshot', {
        'tools': [for (final tool in tools) tool.toChannelMap()],
        'favoriteIds': favoriteIds,
        'recentIds': recentIds,
      });
      return wrote ?? false;
    } on PlatformException catch (error) {
      debugPrint('ShortcutBridge: publish failed — $error');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// The App Group container the native side resolved, or null when it could
  /// not. Debug diagnostics only; nothing branches on it.
  static Future<String?> appGroupIdentifier() async {
    if (!isSupported) return null;
    try {
      return await _channel.invokeMethod<String>('appGroupIdentifier');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @visibleForTesting
  static void debugReset() {
    _linkHandler = null;
    _handlerInstalled = false;
  }
}
