import Cocoa
import FlutterMacOS

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }

  /// A widget tile, or the `metoolkit://` URL an App Intent asks for.
  ///
  /// On a cold launch this runs before `MainFlutterWindow` has woken from its
  /// nib, so there is no engine and no bridge yet;
  /// [METoolkitBridgeHost] holds the URL until there is.
  override func application(_ application: NSApplication, open urls: [URL]) {
    var unhandled: [URL] = []
    for url in urls where !METoolkitBridgeHost.shared.open(url) {
      unhandled.append(url)
    }
    // Anything with another scheme still belongs to the plugins — the consent
    // flow and StoreKit reach their own callback URLs this way.
    if !unhandled.isEmpty {
      super.application(application, open: unhandled)
    }
  }
}
