import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: WorkoutViewModel
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    pendingSection
                    programsSection
                }
                .padding()
            }
            .navigationTitle("GymGenie")
            .refreshable {
                viewModel.refreshPendingItems()
            }
        }
    }

    @ViewBuilder
    private var pendingSection: some View {
        if !viewModel.pendingItems.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Incoming Workouts")
                    .font(.headline)
                ForEach(viewModel.pendingItems) { item in
                    PendingItemRow(item: item) {
                        Task {
                            await viewModel.processPendingItem(item)
                        }
                    } onDismiss: {
                        viewModel.dismissPendingItem(item)
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(16)
        }
    }

    @ViewBuilder
    private var programsSection: some View {
        if viewModel.programs.isEmpty && viewModel.pendingItems.isEmpty {
            emptyState
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("Your Programs")
                    .font(.headline)
                ForEach(viewModel.programs.sorted(by: { $0.createdAt > $1.createdAt })) { program in
                    NavigationLink(destination: WorkoutDetailView(program: program)) {
                        ProgramCard(program: program)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.and.arrow.down")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Nothing here yet")
                .font(.title2.bold())
            Text("Go to Instagram, TikTok, Safari... literally ANY app, tap Share, and select GymGenie.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .padding(.top, 80)
    }
}

struct ProgramCard: View {
    let program: WorkoutProgram
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(program.title)
                    .font(.headline)
                Spacer()
                DifficultyBadge(difficulty: program.difficulty)
            }
            Text(program.subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            HStack(spacing: 16) {
                Label("\(program.durationMinutes)m", systemImage: "clock")
                Label("\(program.frequencyPerWeek)x/wk", systemImage: "calendar")
                Label("\(program.exercises.count) exercises", systemImage: "figure.walk")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct PendingItemRow: View {
    let item: SharedMedia
    let onGenerate: () -> Void
    let onDismiss: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.sourceURL?.replacingOccurrences(of: "https://", with: "") ?? "Shared Content")
                    .font(.subheadline)
                    .lineLimit(1)
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: onGenerate) {
                Label("Build", systemImage: "bolt.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .disabled(item.status == .analyzing || item.status == .generating)
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.orange, lineWidth: 1)
        )
    }
    private var statusText: String {
        switch item.status {
        case .pending: return "Ready to convert"
        case .analyzing: return "Analyzing..."
        case .generating: return "Building program..."
        case .completed: return "Done"
        case .failed: return "Failed: \(item.errorMessage ?? "")"
        }
    }
}

struct DifficultyBadge: View {
    let difficulty: Difficulty
    var color: Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        case .elite: return .red
        }
    }
    var body: some View {
        Text(difficulty.rawValue.capitalized)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}
