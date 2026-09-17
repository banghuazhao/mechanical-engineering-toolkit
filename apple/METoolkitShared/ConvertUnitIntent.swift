import AppIntents
import Foundation

/// One selectable unit in the Shortcuts picker, e.g. `mm` under "Length".
///
/// Modelled as an entity rather than an `AppEnum` because the catalogue is
/// generated from the Dart side and its labels — `N·m`, `°C`, `lbf/ft` — are
/// not valid Swift identifiers, so there are no compile-time cases to
/// enumerate. An entity also gets a searchable picker for free, which matters
/// with roughly fifty units in the list.
@available(iOS 16.0, macOS 13.0, *)
struct METoolkitUnitEntity: AppEntity {
  /// `"<categoryID>/<label>"` — the category has to be part of the identity
  /// because a label alone would not say which table to convert in, and
  /// because a Shortcut stores this string and must still resolve it after an
  /// update adds units.
  let id: String
  let label: String
  let categoryID: String
  let categoryName: String

  static var typeDisplayRepresentation: TypeDisplayRepresentation {
    TypeDisplayRepresentation(name: "Unit")
  }

  static var defaultQuery = METoolkitUnitQuery()

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(label)", subtitle: "\(categoryName)")
  }

  init(categoryID: String, categoryName: String, label: String) {
    self.id = "\(categoryID)/\(label)"
    self.label = label
    self.categoryID = categoryID
    self.categoryName = categoryName
  }

  /// Rebuilds an entity from a stored identifier, returning nil when the
  /// category or unit no longer exists — a Shortcut written against a
  /// removed unit then reports a missing value instead of converting wrongly.
  init?(id: String) {
    guard let separator = id.firstIndex(of: "/") else { return nil }
    let categoryID = String(id[id.startIndex..<separator])
    let label = String(id[id.index(after: separator)...])
    guard let category = METoolkitUnitCategory.category(id: categoryID),
      category.unit(labeled: label) != nil
    else { return nil }
    self.init(
      categoryID: category.id, categoryName: category.name, label: label)
  }

  /// Every unit in the catalogue, in the order the app lists them.
  static var all: [METoolkitUnitEntity] {
    METoolkitUnitCategory.catalog.flatMap { category in
      category.units.map {
        METoolkitUnitEntity(
          categoryID: category.id, categoryName: category.name,
          label: $0.label)
      }
    }
  }

  /// The catalogue entry this entity names. Non-nil for any entity built
  /// through the initializers above, both of which validate first.
  var unit: METoolkitUnit? {
    METoolkitUnitCategory.category(id: categoryID)?.unit(labeled: label)
  }
}

@available(iOS 16.0, macOS 13.0, *)
struct METoolkitUnitQuery: EntityStringQuery {
  func entities(for identifiers: [String]) async throws -> [METoolkitUnitEntity] {
    identifiers.compactMap(METoolkitUnitEntity.init(id:))
  }

  /// Matches on the unit label and on the category name, so typing "torque"
  /// narrows to the four torque units and typing "mm" finds the millimetre.
  func entities(matching string: String) async throws -> [METoolkitUnitEntity] {
    METoolkitUnitEntity.all.filter {
      $0.label.localizedCaseInsensitiveContains(string)
        || $0.categoryName.localizedCaseInsensitiveContains(string)
    }
  }

  func suggestedEntities() async throws -> [METoolkitUnitEntity] {
    METoolkitUnitEntity.all
  }
}

@available(iOS 16.0, macOS 13.0, *)
enum METoolkitConvertError: Swift.Error, CustomLocalizedStringResourceConvertible {
  case unknownUnit
  case mismatchedCategories(from: String, to: String)

  var localizedStringResource: LocalizedStringResource {
    switch self {
    case .unknownUnit:
      return "That unit is no longer in the app's catalogue."
    case .mismatchedCategories(let from, let to):
      return """
        Those units measure different things — \(from) and \(to) — so one \
        cannot be converted into the other.
        """
    }
  }
}

/// "Convert 25.4 mm to in", without opening the app.
///
/// Runs entirely in Swift against the generated catalogue, so it answers in
/// milliseconds and works from the Shortcuts app, the Action button, a Home
/// Screen shortcut or Siri. `openAppWhenRun` stays false deliberately:
/// launching a Flutter engine to multiply by a constant would make the action
/// feel slower than doing the sum by hand.
@available(iOS 16.0, macOS 13.0, *)
struct ConvertUnitIntent: AppIntent {
  static var title: LocalizedStringResource = "Convert Unit"

  // `resultValueName:` would label the returned number in the Shortcuts
  // editor, but that initializer is iOS 17 only and this action is worth
  // having on iOS 16 as well.
  static var description = IntentDescription(
    """
    Converts a value between any two units the app's Unit Converter knows — \
    length, force, stress, mass, temperature, torque, power, angular \
    velocity and angle.
    """,
    categoryName: "Conversion"
  )

  static var openAppWhenRun = false

  @Parameter(title: "Value")
  var value: Double

  @Parameter(title: "From")
  var from: METoolkitUnitEntity

  @Parameter(title: "To")
  var to: METoolkitUnitEntity

  static var parameterSummary: some ParameterSummary {
    Summary("Convert \(\.$value) \(\.$from) to \(\.$to)")
  }

  func perform() async throws -> some IntentResult & ReturnsValue<Double>
    & ProvidesDialog
  {
    guard let fromUnit = from.unit, let toUnit = to.unit else {
      throw METoolkitConvertError.unknownUnit
    }
    // Two units from different tables would otherwise convert via unrelated
    // base units and return a confident, meaningless number.
    guard from.categoryID == to.categoryID else {
      throw METoolkitConvertError.mismatchedCategories(
        from: from.categoryName, to: to.categoryName)
    }

    let result = METoolkitConvert(value: value, from: fromUnit, to: toUnit)
    let formatted = METoolkitFormat(result)
    let input = METoolkitFormat(value)

    return .result(
      value: result,
      dialog: IntentDialog(
        "\(input) \(from.label) is \(formatted) \(to.label)")
    )
  }
}
