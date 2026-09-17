import Foundation

/// The SF Symbol drawn on a widget tile for each tool category.
///
/// The widget cannot reach the hand-drawn tool illustrations: those ship as
/// Flutter assets inside `App.framework`, which an extension does not load.
/// A per-category symbol is the honest alternative — it tells the user what
/// kind of tool a tile is without pretending to be the icon they know from
/// the library.
///
/// Keyed by `ToolType` case name, as published in
/// [METoolkitTool.categoryID]. An unrecognized key — a category added in a
/// newer app than this extension — falls back to a wrench rather than
/// drawing nothing.
enum METoolkitCategoryGlyph {
  static func symbolName(forCategoryID id: String) -> String {
    switch id {
    case "mechanicsOfMaterial": return "square.stack.3d.down.right"
    case "beamEngineering": return "chart.line.downtrend.xyaxis"
    case "theoryOfElasticity": return "function"
    case "composite": return "square.3.layers.3d"
    case "statics": return "triangle"
    case "utilities": return "ruler"
    case "machineDesign": return "gearshape.2"
    case "fluidsThermal": return "drop.degreesign"
    case "thermodynamics": return "thermometer.medium"
    default: return "wrench.and.screwdriver"
    }
  }
}
