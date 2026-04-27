import SwiftData
import SwiftUI

struct AllTasksPane: HomePaneContent {
    static let paneKind = HomePane.allTasks
    static let paneTitle = "All Tasks"
    static let paneSystemImage = "list.bullet"

    @Environment(\.focusPane) var focus
    @Environment(\.selectedCalendarDate) private var selectedCalendarDateBinding

    @Query(sort: \TaskItem.deadline) private var tasks: [TaskItem]
    @Query(sort: \TaskTag.name) private var tags: [TaskTag]
    @State private var showUnfinishedOnly = true

    private var visibleTasks: [TaskItem] {
        let filteredByStatus = showUnfinishedOnly ? tasks.filter { !$0.isCompleted } : tasks

        guard let selectedDate = selectedCalendarDate else {
            return filteredByStatus.sorted(by: compareDueDate)
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        return filteredByStatus
            .filter { task in
                guard let due = task.deadline else { return false }
                return due >= startOfDay && due < endOfDay
            }
            .sorted(by: compareDueDate)
    }

    private var selectedCalendarDate: Date? {
        selectedCalendarDateBinding.wrappedValue
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(titleText)
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
            .onTapGesture { focus(.allTasks) }

            Divider()

            if visibleTasks.isEmpty {
                VStack(alignment: .center, spacing: 0) {
                    ContentUnavailableView(
                        emptyTitle,
                        systemImage: emptySystemImage,
                        description: Text(emptyDescription)
                    )
                    .frame(maxWidth: .infinity, alignment: .top)
                    .padding(.top, 12)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            } else {
                List {
                    ForEach(visibleTasks) { task in
                        TaskRowView(task: task, allTags: tags, showDueDate: true, showDueTime: true)
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
            }
        }
    }

    private var titleText: String {
        guard let selectedDate = selectedCalendarDate else { return "All Tasks" }
        return selectedDate.formatted(date: .abbreviated, time: .omitted)
    }

    private var emptyTitle: String {
        if selectedCalendarDate != nil {
            return "No tasks for this day"
        }
        return showUnfinishedOnly ? "All caught up!" : "No tasks yet"
    }

    private var emptySystemImage: String {
        selectedCalendarDate != nil ? "calendar.badge.exclamationmark" : (showUnfinishedOnly ? "checkmark.circle" : "list.bullet")
    }

    private var emptyDescription: String {
        if selectedCalendarDate != nil {
            return "Select another date or clear the date selection in Calendar."
        }
        return showUnfinishedOnly ? "No unfinished tasks remaining." : "Tasks you add will appear here."
    }

    private func compareDueDate(lhs: TaskItem, rhs: TaskItem) -> Bool {
        let lhsDate = lhs.deadline ?? .distantFuture
        let rhsDate = rhs.deadline ?? .distantFuture
        if lhsDate == rhsDate {
            return lhs.createdAt > rhs.createdAt
        }
        return lhsDate < rhsDate
    }
}
