import SwiftUI
import WidgetKit

@main
struct METoolkitWidgetBundle: WidgetBundle {
  var body: some Widget {
    METoolkitFavoritesWidget()
    METoolkitRecentsWidget()
  }
}
