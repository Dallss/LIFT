import Foundation
import SwiftData

@Model
final class TaskItem {
    var title: String
    var createdAt: Date
    var isCompleted: Bool

    init(
        title: String,
        createdAt: Date = .now,
        isCompleted: Bool = false
    ) {
        self.title = title
        self.createdAt = createdAt
        self.isCompleted = isCompleted
    }
}
