import SwiftUI

struct WorkoutDetailView: View {
    let program: WorkoutProgram
    @State private var selectedDayIndex = 0
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                statsSection
                scheduleSection
                exercisesSection
                notesSection
            }
            .padding()
        }
        .navigationTitle(program.title)
        .navigationBarTitleDisplayMode(.large)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(program.subtitle)
                .font(.title3)
                .foregroundColor(.secondary)
            HStack {
                DifficultyBadge(difficulty: program.difficulty)
                if !program.goal.isEmpty {
                    Text(program.goal)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.purple.opacity(0.15))
                        .foregroundColor(.purple)
                        .cornerRadius(8)
                }
            }
        }
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatBox(icon: "clock", value: "\(program.durationMinutes)m", label: "Duration")
            StatBox(icon: "calendar", value: "\(program.frequencyPerWeek)x", label: "Per Week")
            StatBox(icon: "dumbbell", value: "\(program.exercises.count)", label: "Exercises")
        }
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Schedule")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(program.schedule.enumerated()), id: \.element.id) { index, day in
                        DayButton(day: day, isSelected: selectedDayIndex == index) {
                            withAnimation { selectedDayIndex = index }
                        }
                    }
                }
            }
            if let selectedDay = program.schedule[safe: selectedDayIndex] {
                if selectedDay.isRestDay {
                    Label("Rest Day — Recover Harder", systemImage: "bed.double.fill")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                } else {
                    Text("Focus: \(selectedDay.focus)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private var exercisesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Exercises")
                .font(.headline)
            let day = program.schedule[safe: selectedDayIndex]
            let ids = day?.exerciseIDs ?? []
            let dayExercises = ids.isEmpty ? program.exercises : program.exercises.filter { ids.contains($0.id) }
            ForEach(dayExercises) { exercise in
                ExerciseRow(exercise: exercise)
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !program.notes.isEmpty {
                Text(program.notes)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            if !program.equipmentNeeded.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(program.equipmentNeeded, id: \.self) { eq in
                        Text(eq)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(8)
                    }
                }
            }
            if let source = program.originalSource {
                Text("Source: \(source)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
    }
}

struct StatBox: View {
    let icon: String
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.orange)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct DayButton: View {
    let day: DayPlan
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(day.dayName.prefix(3))
                    .font(.caption.bold())
                if day.isRestDay {
                    Image(systemName: "bed.double.fill")
                        .font(.caption2)
                } else {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(isSelected ? Color.orange.opacity(0.2) : Color(.systemGray6))
            .foregroundColor(isSelected ? .orange : .primary)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ExerciseRow: View {
    let exercise: Exercise
    @State private var isExpanded = false
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.name)
                        .font(.subheadline.bold())
                    Text(exercise.muscleGroup)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(exercise.sets) sets")
                        .font(.caption.bold())
                    Text(exercise.reps)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.secondary)
            }
            if isExpanded {
                Text(exercise.instructions)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                HStack {
                    Label("\(exercise.restSeconds)s rest", systemImage: "timer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture {
            withAnimation { isExpanded.toggle() }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX, y: result.positions[index].y + bounds.minY), proposal: .unspecified)
        }
    }
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0; y += lineHeight + spacing; lineHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
