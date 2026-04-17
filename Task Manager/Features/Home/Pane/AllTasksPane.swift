import SwiftData
import SwiftUI

struct AllTasksPane: HomePaneContent {
    static let paneKind = HomePane.allTasks
    static let paneTitle = "All Tasks"
    static let paneSystemImage = "list.bullet"

    @Environment(\.focusPane) var focus
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \TaskItem.deadline) private var tasks: [TaskItem]

    @State private var collapsedDates: Set<DateComponents> = []
    @State private var showUnfinishedOnly = true

    private var visibleTasks: [TaskItem] {
        showUnfinishedOnly ? tasks.filter { !$0.isCompleted } : tasks
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("All Tasks")
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
                ContentUnavailableView(
                    showUnfinishedOnly ? "All caught up!" : "No tasks yet",
                    systemImage: showUnfinishedOnly ? "checkmark.circle" : "list.bullet",
                    description: Text(showUnfinishedOnly ? "No unfinished tasks remaining." : "Tasks you add will appear here.")
                )
            } else {
                List {
                    ForEach(groupedKeys, id: \.self) { key in
                        Section {
                            if !collapsedDates.contains(key) {
                                ForEach(groupedTasks[key] ?? []) { task in
                                    row(for: task)
                                }
                            }
                        } header: {
                            dateHeader(for: key)
                        }
                    }
                }
                .listStyle(.inset(alternatesRowBackgrounds: true))
            }
        }
    }

    // MARK: - Row

    private func row(for task: TaskItem) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Toggle("Completed", isOn: Bindable(task).isCompleted)
                .toggleStyle(.checkbox)
                .labelsHidden()

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .strikethrough(task.isCompleted, color: .secondary)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)

                Text(task.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            Spacer(minLength: 0)

            if let due = task.deadline {
                Text(due.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(!task.isCompleted && due < .now ? .red : .secondary)
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Date Header

    private func dateHeader(for key: DateComponents) -> some View {
        let collapsed = collapsedDates.contains(key)
        let date = Calendar.current.date(from: key) ?? .now
        let count = groupedTasks[key]?.count ?? 0

        return Button {
            if collapsed { collapsedDates.remove(key) }
            else         { collapsedDates.insert(key) }
        } label: {
            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 1) {
                    if Calendar.current.isDateInToday(date) {
                        Text("Today")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(date.formatted(date: .complete, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if Calendar.current.isDateInYesterday(date) {
                        Text("Yesterday")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(date.formatted(date: .complete, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if Calendar.current.isDateInTomorrow(date) {
                        Text("Tomorrow")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(date.formatted(date: .complete, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(date.formatted(date: .complete, time: .omitted))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                }

                Spacer()

                Text("\(count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.quaternary, in: Capsule())

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .rotationEffect(.degrees(collapsed ? 0 : 90))
                    .animation(.spring(duration: 0.25), value: collapsed)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Grouping

    private var groupedTasks: [DateComponents: [TaskItem]] {
        var dict = Dictionary(grouping: visibleTasks.filter { $0.deadline != nil }) {
            Calendar.current.dateComponents([.year, .month, .day], from: $0.deadline!)
        }
        let noDeadline = visibleTasks.filter { $0.deadline == nil }
        if !noDeadline.isEmpty {
            dict[DateComponents()] = noDeadline
        }
        return dict
    }

    private var groupedKeys: [DateComponents] {
        groupedTasks.keys.sorted {
            guard $0 != DateComponents() else { return false }
            guard $1 != DateComponents() else { return true }
            let d0 = Calendar.current.date(from: $0) ?? .distantPast
            let d1 = Calendar.current.date(from: $1) ?? .distantPast
            return d0 < d1
        }
    }
}
