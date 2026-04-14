import SwiftUI

struct TaskListPane: HomePaneContent {

    static let paneKind = HomePane.taskList
    static let paneTitle = "Tasks"
    static let paneSystemImage = "checklist"

    var body: some View {
        TaskListView()
    }
}
