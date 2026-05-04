import SwiftUI

/// Root shell: native tab bar with one view per tab.
struct MainTabView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView()
            }
            Tab("Statistics", systemImage: "chart.bar") {
                StatisticsView()
            }
        }
    }
}
