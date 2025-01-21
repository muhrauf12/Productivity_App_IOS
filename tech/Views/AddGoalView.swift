import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProductivityViewModel
    
    @State private var title = ""
    @State private var targetDate = Date()
    @State private var taskTitle = ""
    @State private var taskNotes = ""
    @State private var taskDueDate = Date()
    @State private var tasks: [Task] = []
    @State private var showingTaskInput = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Goal Details") {
                    TextField("Goal Title", text: $title)
                    DatePicker("Target Date", selection: $targetDate, displayedComponents: [.date])
                }
                
                Section {
                    Button(action: { showingTaskInput = true }) {
                        Label("Add New Task", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Tasks")
                } footer: {
                    if tasks.isEmpty {
                        Text("Add at least one task to create a goal")
                    }
                }
                
                if !tasks.isEmpty {
                    Section {
                        ForEach(tasks) { task in
                            TaskListItem(task: task)
                        }
                        .onDelete { indexSet in
                            tasks.remove(atOffsets: indexSet)
                        }
                    }
                }
            }
            .navigationTitle("New Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let goal = Goal(title: title, tasks: tasks, targetDate: targetDate)
                        viewModel.addGoal(goal)
                        dismiss()
                    }
                    .disabled(title.isEmpty || tasks.isEmpty)
                }
            }
            .sheet(isPresented: $showingTaskInput) {
                AddTaskView(tasks: $tasks)
            }
        }
    }
}

struct TaskListItem: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.headline)
            if let notes = task.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Text(task.dueDate.formatted(date: .abbreviated, time: .shortened))
                .font(.caption2)
                .foregroundStyle(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var tasks: [Task]
    
    @State private var title = ""
    @State private var notes = ""
    @State private var dueDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Task Title", text: $title)
                TextField("Notes (Optional)", text: $notes)
                DatePicker("Due Date", selection: $dueDate)
            }
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let task = Task(
                            title: title,
                            isCompleted: false,
                            dueDate: dueDate,
                            notes: notes.isEmpty ? nil : notes
                        )
                        tasks.append(task)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
} 