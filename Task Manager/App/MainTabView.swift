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

#Preview {
    MainTabView()
        .frame(width: 640, height: 480)
        .modelContainer(for: [TaskItem.self, TaskTag.self], inMemory: true)
}
