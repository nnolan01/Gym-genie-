import SwiftUI

struct WorkoutsView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    @State private var selectedProgram: WorkoutProgram?
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.programs.isEmpty {
                        Text("Build a program first from your shared content")
                            .foregroundColor(.secondary)
                            .padding(.top, 80)
                    } else {
                        ForEach(viewModel.programs.sorted(by: { $0.createdAt > $1.createdAt })) { program in
                            Button {
                                selectedProgram = program
                            } label: {
                                ProgramCard(program: program)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Start Workout")
            .sheet(item: $selectedProgram) { program in
                ActiveWorkoutView(program: program)
            }
        }
    }
}

struct ActiveWorkoutView: View {
    let program: WorkoutProgram
    @Environment(\.dismiss) private var dismiss
    @State private var currentDayIndex = 0
    @State private var completedIDs = Set<UUID>()
    @State private var startTime = Date()
    @State private var showFinish = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    timerSection
                    daySelector
                    exerciseList
                }
                .padding()
            }
            .navigationTitle(program.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Workout Complete!", isPresented: $showFinish) {
                Button("Sick Gains", role: .cancel) { dismiss() }
            } message: {
                Text("You completed \(completedIDs.count) exercises in \(elapsedMinutes)m.")
            }
        }
    }

    private var timerSection: some View {
        HStack {
            Spacer()
            VStack {
                Text(elapsedTimeString)
                    .font(.system(size: 48, weight: .bold, design: .monospaced))
                Text("ELAPSED")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
    }

    private var daySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(program.schedule.enumerated()), id: \.element.id) { index, day in
                    Button {
                        withAnimation { currentDayIndex = index }
                    } label: {
                        Text(day.dayName.prefix(3))
                            .font(.caption.bold())
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(currentDayIndex == index ? Color.orange : Color(.systemGray5))
                            .foregroundColor(currentDayIndex == index ? .white : .primary)
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var exerciseList: some View {
        let day = program.schedule[safe: currentDayIndex]
        let ids = day?.exerciseIDs ?? []
        let exs = ids.isEmpty ? program.exercises : program.exercises.filter { ids.contains($0.id) }
        return VStack(spacing: 12) {
            ForEach(exs) { ex in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ex.name)
                            .font(.subheadline.bold())
                        Text("\(ex.sets) x \(ex.reps)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button {
                        toggleComplete(ex.id)
                    } label: {
                        Image(systemName: completedIDs.contains(ex.id) ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor(completedIDs.contains(ex.id) ? .green : .secondary)
                    }
                }
                .padding()
                .background(completedIDs.contains(ex.id) ? Color.green.opacity(0.1) : Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(completedIDs.contains(ex.id) ? Color.green : Color.clear, lineWidth: 2)
                )
            }
            if !exs.isEmpty && completedIDs.count == exs.count {
                Button("Finish Workout") {
                    showFinish = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.top)
            }
        }
    }

    private var elapsedTimeString: String {
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let mins = elapsed / 60
        let secs = elapsed % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private var elapsedMinutes: Int {
        Int(Date().timeIntervalSince(startTime)) / 60
    }

    private func toggleComplete(_ id: UUID) {
        if completedIDs.contains(id) {
            completedIDs.remove(id)
        } else {
            completedIDs.insert(id)
        }
    }
}
