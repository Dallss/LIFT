import SwiftUI

struct HomeView: View {

    // MARK: - STATE

    // ✅ Clean state-based system (NO CGFloat hacks)
    @State private var focusedPane: HomePane = .taskList

    @State private var calendarSelection = Date.now

    var body: some View {
        NavigationStack {

            // MARK: - LAYOUT

            HomeTriPaneLayout(focusFraction: CGFloat(focusedPane.rawValue)) {

                pane(
                    pane: .taskList,
                    title: "Tasks",
                    systemImage: "checklist"
                ) {
                    TaskListView()
                }

                pane(
                    pane: .calendar,
                    title: "Calendar",
                    systemImage: "calendar"
                ) {
                    HomeCalendarPane(selectedDate: $calendarSelection)
                }

                pane(
                    pane: .miniStacks,
                    title: "Lists",
                    systemImage: "square.stack.3d.up"
                ) {
                    MiniTaskListsPane()
                }
            }

            .padding(10)
            .navigationTitle("Home")

            // MARK: - TOOLBAR

            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {

                    Picker("Focus", selection: $focusedPane) {
                        Text("Tasks").tag(HomePane.taskList)
                        Text("Calendar").tag(HomePane.calendar)
                        Text("Lists").tag(HomePane.miniStacks)
                    }
                    .pickerStyle(.segmented)
                    .frame(minWidth: 280)
                }
            }
        }
    }

    // MARK: - PANE BUILDER

    @ViewBuilder
    private func pane<Pane: View>(
        pane target: HomePane,
        title: String,
        systemImage: String,
        @ViewBuilder content: () -> Pane
    ) -> some View {

        let isFocused = focusedPane == target

        VStack(alignment: .leading, spacing: 0) {

            focusHeader(
                title: title,
                systemImage: systemImage,
                target: target,
                isFocused: isFocused
            )

            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .layoutPriority(isFocused ? 1 : 0)
        }
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
    }

    // MARK: - HEADER

    private func focusHeader(
        title: String,
        systemImage: String,
        target: HomePane,
        isFocused: Bool
    ) -> some View {

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
            focus(target)
        }
    }

    // MARK: - FOCUS ACTION (SMOOTH + CLEAN)

    private func focus(_ pane: HomePane) {
        withAnimation(.spring(
            response: 0.75,
            dampingFraction: 0.85,
            blendDuration: 0.2
        )) {
            focusedPane = pane
        }
    }
}
