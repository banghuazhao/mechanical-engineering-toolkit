import Flutter
import UIKit

/// Receives the `metoolkit://` URLs a widget tile or an App Intent opens.
///
/// This has to be a scene delegate rather than a method on `AppDelegate`.
/// The app adopts the UIScene lifecycle — `Info.plist` names
/// `FlutterSceneDelegate` under `UIApplicationSceneManifest` — and once a
/// scene manifest exists UIKit stops calling
/// `application(_:open:options:)` entirely. An override there compiles,
/// reads as though it works, and silently never runs.
///
/// `FlutterSceneDelegate` forwards these callbacks on to the plugins, so both
/// overrides call `super`: the consent flow and StoreKit reach their own
/// callback URLs through it.
class METoolkitSceneDelegate: FlutterSceneDelegate {
  /// A cold launch: the URL that started the app arrives here, before the
  /// engine exists. `METoolkitBridgeHost` holds it until it does.
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    METoolkitBridgeHost.shared.open(
      contexts: connectionOptions.urlContexts.map(\.url))
  }

  /// The app was already running.
  override func scene(
    _ scene: UIScene,
    openURLContexts URLContexts: Set<UIOpenURLContext>
  ) {
    METoolkitBridgeHost.shared.open(contexts: URLContexts.map(\.url))
    super.scene(scene, openURLContexts: URLContexts)
  }
}
