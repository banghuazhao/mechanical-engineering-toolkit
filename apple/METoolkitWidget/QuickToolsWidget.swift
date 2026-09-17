import SwiftUI
import WidgetKit

/// Which list a Quick Tools widget draws.
///
/// Two static widgets rather than one configurable widget: the choice is
/// "favourites or recents", the user makes it once when they add the widget,
/// and two entries in the gallery say that more plainly than a configuration
/// sheet does. It also keeps the extension free of a configuration intent,
/// which would otherwise have to be compiled into the app target too and
/// would then collide with the app's own copy.
enum METoolkitQuickToolsKind: String {
  case favorites
  case recents

  var displayName: LocalizedStringKey {
    switch self {
    case .favorites: return "Favourite Tools"
    case .recents: return "Recent Tools"
    }
  }

  var description: LocalizedStringKey {
    switch self {
    case .favorites: return "The tools you have starred, one tap away."
    case .recents: return "Jump back into your last calculations."
    }
  }

  var headerTitle: LocalizedStringKey {
    switch self {
    case .favorites: return "Favourites"
    case .recents: return "Recent"
    }
  }

  var headerSymbol: String {
    switch self {
    case .favorites: return "star.fill"
    case .recents: return "clock.fill"
    }
  }

  /// Shown when there is nothing to list. The favourites widget falls back to
  /// recents before giving up (see [METoolkitSnapshot.favoriteTools]), so
  /// reaching this message means the app has never run a calculation.
  var emptyMessage: LocalizedStringKey {
    switch self {
    case .favorites: return "Star a tool in the app to see it here."
    case .recents: return "Run a calculation to see it here."
    }
  }

  func tools(from snapshot: METoolkitSnapshot) -> [METoolkitTool] {
    switch self {
    case .favorites: return snapshot.favoriteTools
    case .recents: return snapshot.recentTools
    }
  }
}

struct METoolkitQuickToolsEntry: TimelineEntry {
  let date: Date
  let kind: METoolkitQuickToolsKind
  let tools: [METoolkitTool]
}

struct METoolkitQuickToolsProvider: TimelineProvider {
  let kind: METoolkitQuickToolsKind

  /// What the gallery and the system's redacted placeholder draw before real
  /// data is available. Real tool names would flash before being replaced, so
  /// this is deliberately made up — and deliberately plausible, because the
  /// gallery preview is how the user decides whether to add the widget.
  private var sampleTools: [METoolkitTool] {
    [
      METoolkitTool(
        id: -1, title: "Beam Load Analysis", categoryID: "beamEngineering",
        category: "Beam Engineering", locked: false),
      METoolkitTool(
        id: -2, title: "Shaft Fatigue Design", categoryID: "machineDesign",
        category: "Machine Design", locked: false),
      METoolkitTool(
        id: -3, title: "Steam Tables", categoryID: "thermodynamics",
        category: "Thermodynamics", locked: false),
      METoolkitTool(
        id: -4, title: "Unit Converter", categoryID: "utilities",
        category: "Reference & Utilities", locked: false),
      METoolkitTool(
        id: -5, title: "Column Buckling", categoryID: "mechanicsOfMaterial",
        category: "Mechanics of Material", locked: false),
      METoolkitTool(
        id: -6, title: "Pipe Pressure Drop", categoryID: "fluidsThermal",
        category: "Fluids & Thermal", locked: false),
      METoolkitTool(
        id: -7, title: "Spur Gear", categoryID: "machineDesign",
        category: "Machine Design", locked: false),
      METoolkitTool(
        id: -8, title: "Truss Analysis", categoryID: "statics",
        category: "Statics", locked: false),
    ]
  }

  func placeholder(in context: Context) -> METoolkitQuickToolsEntry {
    METoolkitQuickToolsEntry(date: .now, kind: kind, tools: sampleTools)
  }

  func getSnapshot(
    in context: Context,
    completion: @escaping (METoolkitQuickToolsEntry) -> Void
  ) {
    // `isPreview` is the widget gallery, where the app's real favourites may
    // legitimately be empty; showing the sample there is what makes the
    // widget look like something worth adding.
    if context.isPreview {
      completion(placeholder(in: context))
      return
    }
    completion(entry())
  }

  func getTimeline(
    in context: Context,
    completion: @escaping (Timeline<METoolkitQuickToolsEntry>) -> Void
  ) {
    // `.never`: nothing here changes with the clock. The app calls
    // `WidgetCenter.reloadAllTimelines()` whenever favourites or history
    // move, which is the only thing that can change what this draws, so a
    // periodic refresh would only spend the widget's budget re-reading an
    // unchanged file.
    completion(Timeline(entries: [entry()], policy: .never))
  }

  private func entry() -> METoolkitQuickToolsEntry {
    let snapshot = METoolkitSharedStore.read()
    return METoolkitQuickToolsEntry(
      date: .now, kind: kind, tools: kind.tools(from: snapshot))
  }
}

// MARK: - Views

/// One tappable tool.
///
/// `Link` rather than the whole widget's `widgetURL`, so a medium or large
/// widget sends the user to the tile they actually pressed.
private struct METoolkitToolTile: View {
  let tool: METoolkitTool
  let showsCategory: Bool

  var body: some View {
    Link(destination: METoolkitDeepLink.tool(id: tool.id)) {
      HStack(spacing: 8) {
        Image(
          systemName: METoolkitCategoryGlyph.symbolName(
            forCategoryID: tool.categoryID)
        )
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(.tint)
        .frame(width: 18)

        VStack(alignment: .leading, spacing: 1) {
          Text(tool.title)
            .font(.system(size: 12, weight: .semibold))
            .lineLimit(2)
            .minimumScaleFactor(0.85)
            .multilineTextAlignment(.leading)
          if showsCategory {
            Text(tool.category)
              .font(.system(size: 10))
              .foregroundStyle(.secondary)
              .lineLimit(1)
          }
        }
        Spacer(minLength: 0)

        // A locked tool still opens — the app answers with its own upgrade
        // sheet — but saying so up front keeps the tap honest.
        if tool.locked {
          Image(systemName: "lock.fill")
            .font(.system(size: 9))
            .foregroundStyle(.secondary)
        }
      }
      .padding(.horizontal, 8)
      .padding(.vertical, 7)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .fill(.quaternary.opacity(0.5))
      )
    }
  }
}

private struct METoolkitEmptyState: View {
  let kind: METoolkitQuickToolsKind

  var body: some View {
    VStack(spacing: 6) {
      Image(systemName: kind.headerSymbol)
        .font(.system(size: 20))
        .foregroundStyle(.tint)
      Text(kind.emptyMessage)
        .font(.system(size: 11))
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

struct METoolkitQuickToolsView: View {
  @Environment(\.widgetFamily) private var family

  let entry: METoolkitQuickToolsEntry

  /// How many tiles each size fits without the titles clipping.
  private var tileCount: Int {
    switch family {
    case .systemSmall: return 2
    case .systemMedium: return 4
    default: return 8
    }
  }

  private var columnCount: Int {
    family == .systemSmall ? 1 : 2
  }

  /// The category line is dropped on the small size, where there is only room
  /// for the tool's own name.
  private var showsCategory: Bool {
    family != .systemSmall
  }

  private var tools: [METoolkitTool] {
    Array(entry.tools.prefix(tileCount))
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(spacing: 4) {
        Image(systemName: entry.kind.headerSymbol)
          .font(.system(size: 10, weight: .semibold))
        Text(entry.kind.headerTitle)
          .font(.system(size: 11, weight: .semibold))
        Spacer(minLength: 0)
        if family != .systemSmall {
          Link(destination: METoolkitDeepLink.converter) {
            Image(systemName: "arrow.left.arrow.right")
              .font(.system(size: 10, weight: .semibold))
          }
        }
      }
      .foregroundStyle(.tint)

      if tools.isEmpty {
        METoolkitEmptyState(kind: entry.kind)
      } else {
        LazyVGrid(
          columns: Array(
            repeating: GridItem(spacing: 6), count: columnCount),
          spacing: 6
        ) {
          ForEach(tools) { tool in
            METoolkitToolTile(tool: tool, showsCategory: showsCategory)
          }
        }
        Spacer(minLength: 0)
      }
    }
    .tint(.orange)
    .containerBackground(.background, for: .widget)
  }
}

// MARK: - Widgets

struct METoolkitFavoritesWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(
      kind: "METoolkitFavoritesWidget",
      provider: METoolkitQuickToolsProvider(kind: .favorites)
    ) { entry in
      METoolkitQuickToolsView(entry: entry)
    }
    .configurationDisplayName(METoolkitQuickToolsKind.favorites.displayName)
    .description(METoolkitQuickToolsKind.favorites.description)
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

struct METoolkitRecentsWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(
      kind: "METoolkitRecentsWidget",
      provider: METoolkitQuickToolsProvider(kind: .recents)
    ) { entry in
      METoolkitQuickToolsView(entry: entry)
    }
    .configurationDisplayName(METoolkitQuickToolsKind.recents.displayName)
    .description(METoolkitQuickToolsKind.recents.description)
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}
