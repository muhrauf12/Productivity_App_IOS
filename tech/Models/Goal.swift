import Foundation

struct Goal: Identifiable, Codable {
    var id = UUID()
    var title: String
    var tasks: [Task]
    var targetDate: Date
    var isCompleted: Bool {
        !tasks.isEmpty && tasks.allSatisfy { $0.isCompleted }
    }
} 