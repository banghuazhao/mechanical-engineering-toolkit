import AppIntents
import Foundation

/// One calculator, as offered in the Shortcuts picker.
///
/// The titles come from the snapshot the running app publishes, so they are
/// already in the user's language — there is no second copy of sixty-six
/// tool names on this side to translate or to let rot.
@available(iOS 16.0, macOS 13.0, *)
struct METoolkitToolEntity: AppEntity {
  let id: Int
  let title: String
  let category: String

  static var typeDisplayRepresentation: TypeDisplayRepresentation {
    TypeDisplayRepresentation(name: "Tool")
  }

  static var defaultQuery = METoolkitToolQuery()

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(title)", subtitle: "\(category)")
  }

  init(_ tool: METoolkitTool) {
    self.id = tool.id
    self.title = tool.title
    self.category = tool.category
  }
}

@available(iOS 16.0, macOS 13.0, *)
struct METoolkitToolQuery: EntityQuery {
  func entities(for identifiers: [Int]) async throws -> [METoolkitToolEntity] {
    let snapshot = METoolkitSharedStore.read()
    return identifiers.compactMap { id in
      snapshot.tool(id: id).map(METoolkitToolEntity.init)
    }
  }

  /// The whole library, so the picker lists every tool. Empty until the app
  /// has run once and published its catalogue, which is also what a missing
  /// App Group looks like from here.
  func suggestedEntities() async throws -> [METoolkitToolEntity] {
    METoolkitSharedStore.read().tools.map(METoolkitToolEntity.init)
  }
}

/// "Open Beam Load Analysis" — jumps straight into one calculator.
///
/// Opening the app is the point, so unlike [ConvertUnitIntent] this one sets
/// `openAppWhenRun`. The navigation itself happens in Dart: the intent only
/// says which tool, and the app's own [launchTool] decides what to do with a
/// tool this build holds behind Premium.
@available(iOS 16.0, macOS 13.0, *)
struct OpenToolIntent: AppIntent {
  static var title: LocalizedStringResource = "Open Tool"

  static var description = IntentDescription(
    "Opens one of the app's calculators or reference tables.",
    categoryName: "Navigation"
  )

  static var openAppWhenRun = true

  @Parameter(title: "Tool")
  var tool: METoolkitToolEntity

  static var parameterSummary: some ParameterSummary {
    Summary("Open \(\.$tool)")
  }

  func perform() async throws -> some IntentResult {
    NotificationCenter.default.post(
      name: .meToolkitOpenDeepLink,
      object: nil,
      userInfo: [
        METoolkitDeepLinkUserInfoKey: METoolkitDeepLink.tool(id: tool.id)
      ]
    )
    return .result()
  }
}

/// "Open the unit converter" — the one tool worth a shortcut of its own,
/// since it is the app's most-reached-for screen and the destination of the
/// Siri phrase below.
@available(iOS 16.0, macOS 13.0, *)
struct OpenUnitConverterIntent: AppIntent {
  static var title: LocalizedStringResource = "Open Unit Converter"

  static var description = IntentDescription(
    "Opens the Unit Converter.",
    categoryName: "Navigation"
  )

  static var openAppWhenRun = true

  func perform() async throws -> some IntentResult {
    NotificationCenter.default.post(
      name: .meToolkitOpenDeepLink,
      object: nil,
      userInfo: [METoolkitDeepLinkUserInfoKey: METoolkitDeepLink.converter]
    )
    return .result()
  }
}
