import SwiftUI

struct HeaderMenuItem {
    let title: String
    let action: () -> Void
}

@ViewBuilder
func Header(
    _ title: String,
    showsMenu: Bool = false,
    items: [HeaderMenuItem] = []
) -> some View {

    HStack(alignment: .center) {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)

        Spacer()

        if showsMenu {
            Menu {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    Button {
                        item.action()
                    } label: {
                        Text(item.title)
                    }
                }
            }
            
        label: {
            Image(systemName: "ellipsis")
                .rotationEffect(.degrees(90))
                .font(.headline)
                .foregroundStyle(.secondary)
                .frame(width: 44, height: 28)
                .contentShape(Rectangle())
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
            
        }
    }
    .padding(.horizontal)
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .frame(height: 44)
    .contentShape(Rectangle())
}
