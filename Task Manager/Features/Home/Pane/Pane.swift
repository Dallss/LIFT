import SwiftUI

/// Which column is focused in ``HomeTriPaneLayout``; also the identity for each ``HomePaneContent``.
enum HomePane: Int, CaseIterable, Hashable {
    case taskList = 0
    case calendar = 1
    case miniStacks = 2
}

/// Metadata and content contract for a column in ``HomeView``. Concrete types
/// (`TaskListPane`, ``CalendarPane``, etc.) conform to this instead of subclassing.
protocol HomePaneContent: View {
    static var paneKind: HomePane { get }
    static var paneTitle: String { get }
    static var paneSystemImage: String { get }
}

/// Shared chrome for one column in the home tri-pane (header, border, shadow).
/// Add `@State` here for shell-only behavior shared by all panes.
struct Pane<Content: View>: View {

    let id: HomePane
    let title: String
    let systemImage: String
    let isFocused: Bool
    let onFocus: () -> Void
    @ViewBuilder var content: () -> Content
    @State private var isHovering = false

    init(
        isFocused: Bool,
        onFocus: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) where Content: HomePaneContent {
        self.id = Content.paneKind
        self.title = Content.paneTitle
        self.systemImage = Content.paneSystemImage
        self.isFocused = isFocused
        self.onFocus = onFocus
        self.content = content
    }

    init(
        id: HomePane,
        title: String,
        systemImage: String,
        isFocused: Bool,
        onFocus: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.isFocused = isFocused
        self.onFocus = onFocus
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
//            Group {
//                if isFocused {
//                    focusHeader
//                }
//                else{
//                    if isHovering {
//                        focusHeader
//                            .transition(.move(edge: .top))
//                    }
//                }
//            }
            
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .layoutPriority(isFocused ? 1 : 0)
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.85), value: isHovering)
        .background(.background, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(
                    isFocused
                    ? Color.accentColor.opacity(0.45)
                    : Color.secondary.opacity(0.25),
                    lineWidth: isFocused ? 2 : 1
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(
            color: .black.opacity(isFocused ? 0.12 : 0.04),
            radius: isFocused ? 12 : 4,
            y: isFocused ? 4 : 2
        )
        .id(id)
        .onHover { hovering in
            isHovering = hovering
        }
    }

    private var focusHeader: some View {
        HStack(spacing: 8) {

            Image(systemName: systemImage)
                .foregroundStyle(isFocused ? Color.accentColor : .secondary)

            Text(title)
                .font(.headline)
                .foregroundStyle(isFocused ? Color.primary : .secondary)

            Spacer(minLength: 0)

            if !isFocused {
                Text("Tap to expand")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .background(.quaternary.opacity(0.2))
        .onTapGesture {
            onFocus()
        }
    }
}

