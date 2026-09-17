import Foundation

/// One tool as the running app describes it.
///
/// The title arrives already localized, because the app builds it from
/// `S.of(context)` and there is no second copy of those strings on this side.
/// A German user's widget therefore reads German without any `.strings` file
/// in the extension.
struct METoolkitTool: Codable, Hashable, Identifiable, Sendable {
  /// The `Tool.id` from `lib/home/tool_model.dart`. Stable across releases
  /// and across locales, so it is what a deep link and a widget tile carry.
  let id: Int
  let title: String

  /// The `ToolType` case name, e.g. `machineDesign`. Locale-independent, so
  /// it is what the widget maps to a glyph — [category] cannot be, since it
  /// reads "Maschinenbau" for a German user.
  let categoryID: String

  /// Localized category name, e.g. "Machine Design". Shown under the title
  /// on the larger widget sizes.
  let category: String

  /// True when this build holds the tool behind Premium. A locked tool is
  /// still offered — tapping it opens the app's own upgrade sheet, which is
  /// the same thing the in-app library does — but the widget marks it so the
  /// tap is not a surprise.
  let locked: Bool
}

/// What the app publishes for the widget and the Shortcuts actions to read.
struct METoolkitSnapshot: Codable, Sendable {
  var tools: [METoolkitTool]
  var favoriteIDs: [Int]
  var recentIDs: [Int]
  var updatedAt: Date

  static let empty = METoolkitSnapshot(
    tools: [], favoriteIDs: [], recentIDs: [], updatedAt: .distantPast)

  func tool(id: Int) -> METoolkitTool? {
    tools.first { $0.id == id }
  }

  /// The tools a "Favourites" widget should show: the user's favourites in
  /// the order they starred them, falling back to [recentTools] while they
  /// have none, so a freshly added widget is never blank.
  var favoriteTools: [METoolkitTool] {
    let starred = favoriteIDs.compactMap(tool(id:))
    return starred.isEmpty ? recentTools : starred
  }

  /// Most recently calculated first, de-duplicated — a tool run five times
  /// in a row should not fill the widget.
  var recentTools: [METoolkitTool] {
    var seen = Set<Int>()
    var result: [METoolkitTool] = []
    for id in recentIDs where seen.insert(id).inserted {
      if let tool = tool(id: id) { result.append(tool) }
    }
    return result
  }
}

/// Reads and writes the snapshot in the App Group container both the app and
/// its extensions can see.
enum METoolkitSharedStore {
  /// The App Group identifier, taken from the running bundle's Info.plist
  /// rather than written out here.
  ///
  /// iOS and macOS do not spell it the same way — a sandboxed Mac app's
  /// groups must carry the team identifier prefix, iOS's must not — so each
  /// target substitutes `$(ME_APP_GROUP_ID)` into its own Info.plist and
  /// entitlements from one build setting. Reading it back at runtime is what
  /// guarantees the app and the widget open the same container instead of two
  /// silently different ones.
  static let appGroupIdentifier: String? = {
    let value = Bundle.main.object(forInfoDictionaryKey: "METoolkitAppGroup")
    guard let identifier = value as? String, !identifier.isEmpty,
      // An unexpanded build setting means the target is missing
      // ME_APP_GROUP_ID. Treat that as absent rather than trying to open a
      // container literally named "$(ME_APP_GROUP_ID)".
      !identifier.hasPrefix("$(")
    else { return nil }
    return identifier
  }()

  private static let snapshotKey = "METoolkitSnapshot"

  static var defaults: UserDefaults? {
    guard let identifier = appGroupIdentifier else { return nil }
    return UserDefaults(suiteName: identifier)
  }

  /// The last snapshot the app published, or [METoolkitSnapshot.empty] when
  /// the app has not run since the widget was added — or when the App Group
  /// is not configured, which is what a missing entitlement looks like from
  /// here.
  static func read() -> METoolkitSnapshot {
    guard let data = defaults?.data(forKey: snapshotKey) else {
      return .empty
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .millisecondsSince1970
    guard let snapshot = try? decoder.decode(METoolkitSnapshot.self, from: data)
    else {
      // A snapshot written by a newer build that this extension cannot parse.
      // Showing the placeholder beats crashing the widget.
      return .empty
    }
    return snapshot
  }

  @discardableResult
  static func write(_ snapshot: METoolkitSnapshot) -> Bool {
    guard let defaults else { return false }
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .millisecondsSince1970
    guard let data = try? encoder.encode(snapshot) else { return false }
    defaults.set(data, forKey: snapshotKey)
    return true
  }
}
