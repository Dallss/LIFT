import SwiftData
import SwiftUI

/// Lists persisted tasks from SwiftData. Embedded by ``TaskListPane``.
struct TaskListPane: HomePaneContent {
    
    static let paneKind = HomePane.taskList
    static let paneTitle = "Today"
    static let paneSystemImage = "checklist"
    
    @Environment(\.focusPane) var focus
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]
    
    @State private var isPresentingNewTask = false
    @State private var newTaskTitle = ""
    @State private var hasDueDate = false
    @State private var newTaskDue = Date()
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Tasks")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .contentShape(Rectangle())
            .onTapGesture {
                focus(.taskList)
            }
            
            Divider()

            Group {
                if tasks.isEmpty {
                    ContentUnavailableView(
                        "No tasks yet",
                        systemImage: "checklist",
                        description: Text("Add a task using the button below.")
                    )
                } else {
                    List {
                        ForEach(tasksByDueDate(selectedDate)) { task in
                            TaskRowView(task: task, showDueTime: true)
                        }
                        .onDelete(perform: deleteTasks)
                    }
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                }
            }

            HStack(spacing: 12) {

                // Add Task (forced 44)
                Button {
                    newTaskTitle = ""
                    isPresentingNewTask = true
                } label: {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add Task")
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)

                // Trash (forced 44 square)
                Button {
                    deleteCompletedTasks()
                } label: {
                    Image(systemName: "trash")
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
            .padding()
        }
        .sheet(isPresented: $isPresentingNewTask) {
            newTaskSheet
        }
    }

    private var newTaskSheet: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $newTaskTitle)
                    .textFieldStyle(.roundedBorder)

                Toggle("Due Date", isOn: $hasDueDate)

                if hasDueDate {
                    DatePicker(
                        "Due",
                        selection: $newTaskDue,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresentingNewTask = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") { addTask() }
                        .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .frame(minWidth: 320, minHeight: 200)
    }

    private func addTask() {
        let task = TaskItem(
            title: newTaskTitle,
            deadline: hasDueDate ? newTaskDue : nil
        )

        modelContext.insert(task)

        // reset state
        newTaskTitle = ""
        hasDueDate = false
        newTaskDue = Date()

        isPresentingNewTask = false
    }

    private func deleteCompletedTasks() {
        let completedTasks = tasks.filter { $0.isCompleted }
        guard !completedTasks.isEmpty else { return }

        for task in completedTasks {
            modelContext.delete(task)
        }
    }
    
    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tasks[index])
        }
    }
    
    private func tasksByDueDate(_ date: Date) -> [TaskItem] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return tasks
            .filter { task in
                guard let due = task.deadline else { return false }
                return due >= startOfDay && due < endOfDay
            }
            .sorted {
                ($0.deadline ?? .distantFuture) < ($1.deadline ?? .distantFuture)
            }
    }
}

// MARK: - Row

private struct TaskRowView: View {
    @Bindable var task: TaskItem

    let showDueDate: Bool
    let showDueTime: Bool

    init(
        task: TaskItem,
        showDueDate: Bool = false,
        showDueTime: Bool = false
    ) {
        self.task = task
        self.showDueDate = showDueDate
        self.showDueTime = showDueTime
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {

            Toggle("Completed", isOn: $task.isCompleted)
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

                let isOverdue = !task.isCompleted && due < Date()

                VStack(alignment: .trailing, spacing: 2) {

                    if showDueDate {
                        Text(due.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(isOverdue ? .red : .secondary)
                    }

                    if showDueTime {
                        Text(due.formatted(date: .omitted, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(isOverdue ? .red : .secondary)
                    }
                }
            }
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        TaskListPane()
            .navigationTitle("Home")
    }
    .modelContainer(for: TaskItem.self, inMemory: true)
}
