//
//  ContentView.swift
//  tech
//
//  Created by Muhammad Rauf on 1/17/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ProductivityViewModel()
    @State private var showingAddGoal = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Calendar Section
                    calendarSection
                        .padding(.bottom, 8)
                    
                    // Goals Section
                    goalsSection
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Productivity")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAddGoal) {
                AddGoalView(viewModel: viewModel)
            }
        }
    }
    
    private var calendarSection: some View {
        VStack(spacing: 0) {
            DatePicker(
                "Select Date",
                selection: $viewModel.selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
            .padding(.horizontal)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
    
    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Date header
            dateHeader
            
            // Goals list
            goalsList
        }
    }
    
    private var dateHeader: some View {
        HStack {
            Text(viewModel.selectedDate.formatted(date: .long, time: .omitted))
                .font(.headline)
            Spacer()
            addButton
        }
    }
    
    private var addButton: some View {
        Button(action: { showingAddGoal = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundStyle(.blue)
        }
        .frame(width: 44, height: 44)
    }
    
    private var goalsList: some View {
        LazyVStack(spacing: 16) {
            let filteredGoals = viewModel.goals.filter {
                Calendar.current.isDate($0.targetDate, inSameDayAs: viewModel.selectedDate)
            }
            
            if filteredGoals.isEmpty {
                emptyStateView
            } else {
                ForEach(filteredGoals) { goal in
                    GoalCardView(goal: goal, viewModel: viewModel)
                }
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
            Text("No goals for this day")
                .font(.headline)
                .foregroundStyle(.gray)
            Button(action: { showingAddGoal = true }) {
                Text("Add Goal")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

struct GoalCardView: View {
    let goal: Goal
    @ObservedObject var viewModel: ProductivityViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            goalHeader
            tasksList
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private var goalHeader: some View {
        HStack {
            Text(goal.title)
                .font(.headline)
            Spacer()
            Image(systemName: goal.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(goal.isCompleted ? .green : .gray)
                .font(.title3)
        }
    }
    
    private var tasksList: some View {
        VStack(spacing: 8) {
            ForEach(goal.tasks) { task in
                TaskRowView(task: task, goalId: goal.id, viewModel: viewModel)
                if task.id != goal.tasks.last?.id {
                    Divider()
                }
            }
        }
    }
}

struct TaskRowView: View {
    let task: Task
    let goalId: UUID
    @ObservedObject var viewModel: ProductivityViewModel
    
    var body: some View {
        HStack(spacing: 12) {
            checkboxButton
            taskDetails
            Spacer()
            dueTime
        }
    }
    
    private var checkboxButton: some View {
        Button(action: {
            withAnimation {
                viewModel.toggleTaskCompletion(goalId: goalId, taskId: task.id)
            }
        }) {
            Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(task.isCompleted ? .green : .gray)
                .font(.title3)
        }
    }
    
    private var taskDetails: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .strikethrough(task.isCompleted)
                .foregroundStyle(task.isCompleted ? .gray : .primary)
            if let notes = task.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
    }
    
    private var dueTime: some View {
        Text(task.dueDate.formatted(date: .omitted, time: .shortened))
            .font(.caption)
            .foregroundStyle(.gray)
    }
}

#Preview {
    ContentView()
}
