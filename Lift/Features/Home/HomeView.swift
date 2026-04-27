import SwiftUI

/// Home hub: tri-pane layout with a shared ``Pane`` shell around each ``HomePaneContent`` column.
struct HomeView: View {

    // MARK: - STATE

    @State private var focusedPane: HomePane = .taskList
    @State private var calendarSelection: Date?

    var body: some View {
        NavigationStack {

            HomeTriPaneLayout(focusFraction: CGFloat(focusedPane.rawValue)) {

                Pane(isFocused: focusedPane == .taskList, onFocus: { focus(.taskList) }) {
                    TaskListPane()
                }
                .padding(8)

                Pane(isFocused: focusedPane == .calendar, onFocus: { focus(.calendar) }) {
                    CalendarPane()
                }
                .padding(8)

                Pane(isFocused: focusedPane == .allTasks, onFocus: { focus(.allTasks) }) {
                    AllTasksPane()
                }
                .padding(8)
            }
            .padding(10)
            .navigationTitle("Home")
            .environment(\.focusPane, focus)
            .environment(\.selectedCalendarDate, $calendarSelection)

            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {

                    Picker("Focus", selection: $focusedPane) {
                        Text("Tasks").tag(HomePane.taskList)
                        Text("Calendar").tag(HomePane.calendar)
                        Text("Lists").tag(HomePane.allTasks)
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

// MARK: -Global Focus Action
private struct FocusPaneKey: EnvironmentKey {
    static let defaultValue: (HomePane) -> Void = { _ in }
}

extension EnvironmentValues {
    var focusPane: (HomePane) -> Void {
        get { self[FocusPaneKey.self] }
        set { self[FocusPaneKey.self] = newValue }
    }
}

private struct SelectedCalendarDateKey: EnvironmentKey {
    static let defaultValue: Binding<Date?> = .constant(nil)
}

extension EnvironmentValues {
    var selectedCalendarDate: Binding<Date?> {
        get { self[SelectedCalendarDateKey.self] }
        set { self[SelectedCalendarDateKey.self] = newValue }
    }
}
