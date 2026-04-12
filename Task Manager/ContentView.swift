import SwiftUI

struct ContentView: View {
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .frame(width: 640, height: 480)
        .modelContainer(for: TaskItem.self, inMemory: true)
}
