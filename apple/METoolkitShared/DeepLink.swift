import Foundation

/// The URLs a widget tile or a Shortcuts action uses to reach a screen.
///
/// Both platforms register the `metoolkit` scheme, and both hand whatever
/// arrives to the same Dart-side router (`lib/util/deep_links.dart`), so a
/// link added here needs a case added there and nowhere else.
enum METoolkitDeepLink {
  static let scheme = "metoolkit"

  /// Opens one calculator. `id` is a `Tool.id` from
  /// `lib/home/tool_model.dart`, which is stable across releases.
  static func tool(id: Int) -> URL {
    URL(string: "\(scheme)://tool/\(id)")!
  }

  /// The Unit Converter's own `Tool.id`, so the widget's converter tile and
  /// the "Open Unit Converter" shortcut travel the same `tool/<id>` route as
  /// everything else rather than needing a case of their own.
  static let unitConverterToolID = 500

  static var converter: URL { tool(id: unitConverterToolID) }

  /// Pops back to the tool library.
  static var library: URL {
    URL(string: "\(scheme)://library")!
  }
}

/// Posted once the system has launched the app to run an App Intent that
/// wants a screen opened.
///
/// A notification rather than a direct call because the intents are compiled
/// into both the iOS and the macOS app target and must not reach for UIKit or
/// AppKit. [METoolkitShortcutBridge] listens and forwards to Dart, buffering
/// while the Flutter side is still starting up.
extension Notification.Name {
  static let meToolkitOpenDeepLink = Notification.Name("METoolkitOpenDeepLink")
}

/// The `userInfo` key carrying the `URL` of a ``Notification/Name/meToolkitOpenDeepLink``.
let METoolkitDeepLinkUserInfoKey = "url"
