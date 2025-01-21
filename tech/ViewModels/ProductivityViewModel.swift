import Foundation
import SwiftUI

class ProductivityViewModel: ObservableObject {
    @Published var goals: [Goal] = [] {
        didSet {
            saveGoals()
        }
    }
    @Published var selectedDate: Date = Date()
    
    init() {
        loadGoals()
    }
    
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: "savedGoals")
        }
    }
    
    private func loadGoals() {
        if let savedGoals = UserDefaults.standard.data(forKey: "savedGoals"),
           let decodedGoals = try? JSONDecoder().decode([Goal].self, from: savedGoals) {
            goals = decodedGoals
        }
    }
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
    }
    
    func addTask(to goal: Goal, task: Task) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            var updatedGoal = goal
            updatedGoal.tasks.append(task)
            goals[index] = updatedGoal
        }
    }
    
    func toggleTaskCompletion(goalId: UUID, taskId: UUID) {
        if let goalIndex = goals.firstIndex(where: { $0.id == goalId }),
           let taskIndex = goals[goalIndex].tasks.firstIndex(where: { $0.id == taskId }) {
            goals[goalIndex].tasks[taskIndex].isCompleted.toggle()
        }
    }
} 