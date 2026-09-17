#if os(macOS)
  import FlutterMacOS
#else
  import Flutter
#endif
import Foundation
import WidgetKit

/// The one channel between Dart and everything outside the app: the widget's
/// shared container, and the deep links that arrive from a widget tile or an
/// App Intent.
///
/// Both platforms instantiate this with their engine's binary messenger — iOS
/// from `AppDelegate`, macOS from `MainFlutterWindow` — and the Dart side
/// talks to it through `lib/util/shortcut_bridge.dart`.
final class METoolkitShortcutBridge {
  static let channelName = "com.appsbay.mechanicalEngineeringToolkit/shortcuts"

  private let channel: FlutterMethodChannel

  /// Links that arrived before Dart was ready to route them.
  ///
  /// A cold launch from a widget tap delivers the URL during
  /// `didFinishLaunching`, long before `runApp` has built a navigator, and an
  /// `OpenToolIntent` can perform at any moment during startup. Dropping
  /// those would make the feature fail exactly when it is used most — the
  /// first tap of the day — so they queue here until Dart says it is
  /// listening.
  private var pendingLinks: [String] = []
  private var dartIsReady = false

  init(messenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: METoolkitShortcutBridge.channelName, binaryMessenger: messenger)

    channel.setMethodCallHandler { [weak self] call, result in
      self?.handle(call, result: result)
    }

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleDeepLinkNotification(_:)),
      name: .meToolkitOpenDeepLink,
      object: nil
    )
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - Dart -> native

  private func handle(
    _ call: FlutterMethodCall, result: @escaping FlutterResult
  ) {
    switch call.method {
    case "publishSnapshot":
      guard let arguments = call.arguments as? [String: Any] else {
        result(
          FlutterError(
            code: "bad_arguments",
            message: "publishSnapshot expects a map", details: nil))
        return
      }
      publish(arguments, result: result)

    case "ready":
      // Dart has installed its router. Hand over anything that arrived while
      // it was still starting, oldest first.
      dartIsReady = true
      let queued = pendingLinks
      pendingLinks.removeAll()
      for link in queued { channel.invokeMethod("openDeepLink", arguments: link) }
      result(nil)

    case "appGroupIdentifier":
      // Read by the Dart side purely so a debug build can report whether the
      // App Group is wired up; nothing branches on it.
      result(METoolkitSharedStore.appGroupIdentifier)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Writes the snapshot and asks WidgetKit to redraw.
  ///
  /// Reports false when there is no App Group to write to — a missing
  /// entitlement — which the Dart side logs in debug rather than treating as
  /// an error, since the app itself works fine without a widget.
  ///
  /// The write happens off the platform thread on purpose. Opening a group
  /// container is not guaranteed to be quick: on macOS the first access can
  /// put up the system's "would like to access data from other apps" consent
  /// prompt, and doing that from the platform thread holds up the frame the
  /// app is drawing — the window stays blank until the user answers. Decoding
  /// the arguments stays here, because they are Flutter's and must be read
  /// before this returns.
  private func publish(
    _ arguments: [String: Any], result: @escaping FlutterResult
  ) {
    let rawTools = arguments["tools"] as? [[String: Any]] ?? []
    let tools: [METoolkitTool] = rawTools.compactMap { entry in
      guard let id = entry["id"] as? Int,
        let title = entry["title"] as? String
      else { return nil }
      return METoolkitTool(
        id: id,
        title: title,
        categoryID: entry["categoryId"] as? String ?? "",
        category: entry["category"] as? String ?? "",
        locked: entry["locked"] as? Bool ?? false
      )
    }

    let snapshot = METoolkitSnapshot(
      tools: tools,
      favoriteIDs: arguments["favoriteIds"] as? [Int] ?? [],
      recentIDs: arguments["recentIds"] as? [Int] ?? [],
      updatedAt: Date()
    )

    DispatchQueue.global(qos: .utility).async {
      let wrote = METoolkitSharedStore.write(snapshot)
      if wrote {
        // Cheap when nothing changed — WidgetKit coalesces reloads — and the
        // only thing that makes an already-placed widget notice a new
        // favourite.
        WidgetCenter.shared.reloadAllTimelines()
      }
      // A FlutterResult has to be answered on the platform thread.
      DispatchQueue.main.async { result(wrote) }
    }
  }

  // MARK: - Native -> Dart

  @objc private func handleDeepLinkNotification(_ note: Notification) {
    guard
      let url = note.userInfo?[METoolkitDeepLinkUserInfoKey] as? URL
    else { return }
    open(url)
  }

  /// Routes [url] to Dart, or queues it if Dart is not listening yet.
  ///
  /// Returns whether the URL was one of ours, so the callers can tell the OS
  /// whether they handled it.
  @discardableResult
  func open(_ url: URL) -> Bool {
    guard url.scheme == METoolkitDeepLink.scheme else { return false }
    if dartIsReady {
      channel.invokeMethod("openDeepLink", arguments: url.absoluteString)
    } else {
      pendingLinks.append(url.absoluteString)
    }
    return true
  }
}

/// Holds the bridge, and the links that arrive before there is one.
///
/// The bridge cannot exist until the Flutter engine does, and on both
/// platforms a URL can land earlier than that: iOS delivers a cold launch's
/// URL in `scene(_:willConnectTo:options:)`, and macOS in
/// `application(_:open:)` before the window has woken from its nib. Without
/// somewhere to put them, the feature would fail on exactly the tap that
/// starts the app.
///
/// A singleton because the objects that need it — two app delegates, a scene
/// delegate and a window — are all created by the OS, with nowhere to thread
/// a reference through.
final class METoolkitBridgeHost {
  static let shared = METoolkitBridgeHost()

  private init() {}

  private var bridge: METoolkitShortcutBridge?
  private var pendingURLs: [URL] = []

  /// Called once the engine exists. Hands over anything already queued,
  /// oldest first.
  func attach(_ bridge: METoolkitShortcutBridge) {
    self.bridge = bridge
    let queued = pendingURLs
    pendingURLs.removeAll()
    for url in queued { bridge.open(url) }
  }

  /// Returns whether the URL was one of ours.
  @discardableResult
  func open(_ url: URL) -> Bool {
    guard url.scheme == METoolkitDeepLink.scheme else { return false }
    if let bridge {
      return bridge.open(url)
    }
    pendingURLs.append(url)
    return true
  }

  /// Convenience for the scene delegate, which is handed a set of contexts.
  @discardableResult
  func open<S: Sequence>(contexts: S) -> Bool where S.Element == URL {
    var handledAny = false
    for url in contexts where open(url) { handledAny = true }
    return handledAny
  }
}
