import AppIntents

/// The shortcuts that appear in the Shortcuts app — and answer to Siri —
/// without the user assembling anything first.
///
/// This provider has to live in the app target, not in an extension, which is
/// why every intent it names is compiled into the app as well. Each phrase
/// must contain `\(.applicationName)`; Apple rejects a phrase without it,
/// and in practice it is also what stops "convert millimetres" from being
/// claimed by whichever app asked first.
@available(iOS 16.0, macOS 13.0, *)
struct METoolkitShortcuts: AppShortcutsProvider {
  /// Tinted to match the app icon's ground rather than left at the default
  /// grey.
  static var shortcutTileColor: ShortcutTileColor = .orange

  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: ConvertUnitIntent(),
      phrases: [
        "Convert a unit with \(.applicationName)",
        "Convert units in \(.applicationName)",
        "\(.applicationName) unit conversion",
      ],
      shortTitle: "Convert Unit",
      systemImageName: "arrow.left.arrow.right"
    )

    AppShortcut(
      intent: OpenUnitConverterIntent(),
      phrases: [
        "Open the \(.applicationName) unit converter",
        "Show the unit converter in \(.applicationName)",
      ],
      shortTitle: "Unit Converter",
      systemImageName: "ruler"
    )

    AppShortcut(
      intent: OpenToolIntent(),
      phrases: [
        "Open a tool in \(.applicationName)",
        "Open a \(.applicationName) calculator",
      ],
      shortTitle: "Open Tool",
      systemImageName: "wrench.and.screwdriver"
    )
  }
}
