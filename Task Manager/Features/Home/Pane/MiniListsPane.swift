import SwiftUI

struct MiniListsPane: HomePaneContent {

    static let paneKind = HomePane.miniStacks
    static let paneTitle = "Lists"
    static let paneSystemImage = "square.stack.3d.up"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Quick lists")
                .font(.headline)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.quaternary.opacity(0.5))
                            .frame(height: 44)
                            .overlay(alignment: .leading) {
                                Text("List \(index + 1)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 12)
                            }
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.quaternary.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
