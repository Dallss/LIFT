import SwiftData
import SwiftUI

/// Lists persisted tasks from SwiftData. Embedded by ``TaskListPane``.
struct TaskListPane: HomePaneContent {
    
    static let paneKind = HomePane.taskList
    static let paneTitle = "Tasks"
    static let paneSystemImage = "checklist"
    
    @Environment(\.focusPane) var focus
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]
    @Query(sort: \TaskTag.name) private var tags: [TaskTag]
    
    @State private var isPresentingNewTask = false
    @State private var newTaskTitle = ""
    @State private var hasDueDate = true
    @State private var newTaskDue: Date = {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = 23
        components.minute = 59
        return Calendar.current.date(from: components) ?? Date()
    }()
    @State private var newTaskTagIDs: Set<PersistentIdentifier> = []
    @State private var newTagName = ""
    @State private var selectedDate = Calendar.current.startOfDay(for: Date())

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Header(
                "Today",
                showsMenu: true,
                items: [
                    HeaderMenuItem(
                        title: "New Task",
                        action: {
                            isPresentingNewTask = true
                        }
                    ),
                    HeaderMenuItem(
                        title: "Clear Completed",
                        action: {
                            deleteCompletedTasks()
                        }
                    )
                ]
            )
            .onTapGesture {
                focus(.taskList)
            }

            if tasks.isEmpty {
                ContentUnavailableView(
                    "No tasks yet",
                    systemImage: "checklist",
                    description: Text(" ")
                )
                .font(.footnote)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(tasksByDueDate(selectedDate)) { task in
                        TaskRowView(task: task, allTags: tags, showDueTime: true)
                    }
                    .onDelete(perform: deleteTasks)
                }
            }
        }
        .sheet(isPresented: $isPresentingNewTask) {
            NewTaskView(
                title: $newTaskTitle,
                hasDueDate: $hasDueDate,
                dueDate: $newTaskDue,
                selectedTagIDs: $newTaskTagIDs,
                tags: tags,
                onAddTask: addTask,
                onCancel: { isPresentingNewTask = false },
                onToggleTag: toggleSelection
            )
        }
        .task {
            try? TaskTagStore.ensureDefaults(in: modelContext)
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

                Text("Tags")
                    .font(.headline)

                if tags.isEmpty {
                    Text("No tags yet. Add one below.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(tags, id: \.persistentModelID) { tag in
                        Button {
                            toggleSelection(for: tag)
                        } label: {
                            HStack {
                                Text(tag.name)
                                Spacer()
                                if newTaskTagIDs.contains(tag.persistentModelID) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color.accentColor)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                HStack {
                    TextField("New Tag", text: $newTagName)
                    Button("Add") {
                        addTagForNewTask()
                    }
                    .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
        let selectedTags = tags.filter { newTaskTagIDs.contains($0.persistentModelID) }
        task.tags = selectedTags

        modelContext.insert(task)

        // reset state
        newTaskTitle = ""
        hasDueDate = false
        newTaskDue = Date()
        newTaskTagIDs = []
        newTagName = ""

        isPresentingNewTask = false
    }

    private func toggleSelection(for tag: TaskTag) {
        let id = tag.persistentModelID
        if newTaskTagIDs.contains(id) {
            newTaskTagIDs.remove(id)
        } else {
            newTaskTagIDs.insert(id)
        }
    }

    private func addTagForNewTask() {
        do {
            if let tag = try TaskTagStore.createCustomTagIfNeeded(name: newTagName, in: modelContext) {
                newTaskTagIDs.insert(tag.persistentModelID)
                newTagName = ""
            }
        } catch {
            // Keep UI responsive even if persistence fails.
        }
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
