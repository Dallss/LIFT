import SwiftUI

/// Home hub: tri-pane layout with a shared ``Pane`` shell around each ``HomePaneContent`` column.
struct HomeView: View {

    // MARK: - STATE

    @State private var focusedPane: HomePane = .taskList

    var body: some View {
        NavigationStack {

            HomeTriPaneLayout(focusFraction: CGFloat(focusedPane.rawValue)) {

                Pane(isFocused: focusedPane == .taskList, onFocus: { focus(.taskList) }) {
                    TaskListPane()
                }

                Pane(isFocused: focusedPane == .calendar, onFocus: { focus(.calendar) }) {
                    CalendarPane()
                }

                Pane(isFocused: focusedPane == .miniStacks, onFocus: { focus(.miniStacks) }) {
                    MiniListsPane()
                }
            }
            .padding(10)
            .navigationTitle("Home")

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
