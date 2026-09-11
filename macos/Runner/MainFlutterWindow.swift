import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  /// Opening size for a first launch. Wide enough that the tool grid shows
  /// several columns and a result page's tables do not wrap.
  private static let defaultSize = NSSize(width: 1100, height: 800)

  /// Below this the calculator input rows — label, field, unit menu — start
  /// colliding, so the window refuses to go smaller.
  private static let minimumSize = NSSize(width: 800, height: 600)

  /// Where AppKit stores the window's frame between launches.
  private static let frameAutosaveName = "METoolkitMainWindow"

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController

    self.contentMinSize = MainFlutterWindow.minimumSize

    // Restore the frame the user left the window at, falling back to the
    // default size only when there is nothing to restore.
    //
    // Two ordering traps here, both of which silently lose the user's window
    // size. Setting the content size unconditionally discards the saved frame
    // every launch. And `setFrameAutosaveName` writes the *current* frame out
    // under that name as soon as it is set, so adopting the name before
    // reading overwrites the very value being restored. Restore first, adopt
    // second.
    if !self.setFrameUsingName(MainFlutterWindow.frameAutosaveName) {
      self.setContentSize(MainFlutterWindow.defaultSize)
      self.center()
    }
    self.setFrameAutosaveName(MainFlutterWindow.frameAutosaveName)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
