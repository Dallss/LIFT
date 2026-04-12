import SwiftUI

struct StatisticsView: View {
    var body: some View {
        ContentUnavailableView(
            "Statistics",
            systemImage: "chart.bar",
            description: Text("Charts and summaries will appear here.")
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    StatisticsView()
        .frame(width: 400, height: 300)
}
