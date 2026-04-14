import SwiftData
import SwiftUI

/// Lists persisted tasks from SwiftData. Embedded by ``TaskListPane``.
struct TaskListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]

    @State private var isPresentingNewTask = false
    @State private var newTaskTitle = ""

    var body: some View {
        VStack(spacing: 0) {
            Group {
                if tasks.isEmpty {
                    ContentUnavailableView(
                        "No tasks yet",
                        systemImage: "checklist",
                        description: Text("Add a task using the button below.")
                    )
                } else {
                    List {
                        ForEach(tasks) { task in
                            TaskRowView(task: task)
                        }
                        .onDelete(perform: deleteTasks)
                    }
                    .listStyle(.inset(alternatesRowBackgrounds: true))
                }
            }

            // Bottom Add Button
            Button {
                newTaskTitle = ""
                isPresentingNewTask = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Task")
                }
                .frame(maxWidth: 280)
                .padding()
            }
            .buttonStyle(.borderedProminent)
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
            }
            .formStyle(.grouped)
            .padding()
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
        .frame(minWidth: 320, minHeight: 160)
    }

    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        modelContext.insert(TaskItem(title: trimmed))
        isPresentingNewTask = false
    }

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tasks[index])
        }
    }
}

// MARK: - Row

private struct TaskRowView: View {
    @Bindable var task: TaskItem

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
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    NavigationStack {
        TaskListView()
            .navigationTitle("Home")
    }
    .modelContainer(for: TaskItem.self, inMemory: true)
}
