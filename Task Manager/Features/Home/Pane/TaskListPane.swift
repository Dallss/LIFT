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
    @State private var hasDueDate = false
    @State private var newTaskDue = Date()
    @State private var newTaskTagIDs: Set<PersistentIdentifier> = []
    @State private var newTagName = ""
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
                            TaskRowView(task: task, allTags: tags, showDueTime: true)
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
                    newTaskTagIDs = []
                    newTagName = ""
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

// MARK: - Row

private struct TaskRowView: View {
    @Bindable var task: TaskItem
    let allTags: [TaskTag]
    @Environment(\.modelContext) private var modelContext
    @State private var isPresentingNewTagSheet = false
    @State private var newTagName = ""

    let showDueDate: Bool
    let showDueTime: Bool

    init(
        task: TaskItem,
        allTags: [TaskTag],
        showDueDate: Bool = false,
        showDueTime: Bool = false
    ) {
        self.task = task
        self.allTags = allTags
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

                if !task.tags.isEmpty {
                    Text(task.tags.map(\.name).sorted().joined(separator: " • "))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
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
            // Three-dot menu button
            Menu {
                Button {
                } label: {
                    Label("Rename", systemImage: "pencil")
                }

                Button {
                    // Present your deadline picker here
                } label: {
                    Label("Move Deadline", systemImage: "calendar")
                }

                Menu("Tags", systemImage: "tag") {
                    if allTags.isEmpty {
                        Text("No tags available")
                    } else {
                        ForEach(allTags) { tag in
                            Button {
                                toggle(tag)
                            } label: {
                                Label(tag.name, systemImage: has(tag) ? "checkmark" : "circle")
                            }
                        }
                    }

                    Divider()
                    Button {
                        isPresentingNewTagSheet = true
                    } label: {
                        Label("Add New Tag", systemImage: "plus")
                    }

                    if !task.tags.isEmpty {
                        Divider()
                        Button(role: .destructive) {
                            task.tags.removeAll()
                        } label: {
                            Label("Remove All Tags", systemImage: "tag.slash")
                        }
                    }
                }
            } label: {
                Image(systemName: "ellipsis") // TODO: make this vertical
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .fixedSize()
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
        .sheet(isPresented: $isPresentingNewTagSheet) {
            newTagSheet
        }
    }

    private func has(_ tag: TaskTag) -> Bool {
        task.tags.contains { $0.persistentModelID == tag.persistentModelID }
    }

    private func toggle(_ tag: TaskTag) {
        if let index = task.tags.firstIndex(where: { $0.persistentModelID == tag.persistentModelID }) {
            task.tags.remove(at: index)
        } else {
            task.tags.append(tag)
        }
    }

    private var newTagSheet: some View {
        NavigationStack {
            Form {
                TextField("Tag Name", text: $newTagName)
            }
            .formStyle(.grouped)
            .navigationTitle("New Tag")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newTagName = ""
                        isPresentingNewTagSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addTagFromMenu()
                    }
                    .disabled(newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .frame(minWidth: 320, minHeight: 180)
    }

    private func addTagFromMenu() {
        do {
            if let tag = try TaskTagStore.createCustomTagIfNeeded(name: newTagName, in: modelContext) {
                if !has(tag) {
                    task.tags.append(tag)
                }
            }
        } catch {
            // Keep the menu flow functional if persistence fails.
        }

        newTagName = ""
        isPresentingNewTagSheet = false
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        TaskListPane()
            .navigationTitle("Home")
    }
    .modelContainer(for: [TaskItem.self, TaskTag.self], inMemory: true)
}
