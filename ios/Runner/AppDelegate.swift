import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Bridges Dart to the widget's shared container and to the deep links that
  /// arrive from a widget tile or a Shortcuts action.
  ///
  /// Held for the life of the app because it owns the queue of links that
  /// land before Dart is listening. The URLs themselves arrive at
  /// `METoolkitSceneDelegate`, not here — see the note in that file.
  private var shortcutBridge: METoolkitShortcutBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let bridge = METoolkitShortcutBridge(
      messenger: engineBridge.applicationRegistrar.messenger())
    shortcutBridge = bridge
    METoolkitBridgeHost.shared.attach(bridge)
  }
}
