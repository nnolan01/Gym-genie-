import Foundation
import SwiftUI

@MainActor
final class WorkoutViewModel: ObservableObject {
    @Published var programs: [WorkoutProgram] = []
    @Published var pendingItems: [SharedMedia] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTab = 0

    init() {
        self.programs = StorageManager.shared.loadPrograms()
        self.pendingItems = SharedContainerService.shared.retrievePendingMedia()
    }

    func refreshPendingItems() {
        pendingItems = SharedContainerService.shared.retrievePendingMedia()
    }

    func processPendingItem(_ media: SharedMedia) async {
        guard let index = pendingItems.firstIndex(where: { $0.id == media.id }) else { return }

        pendingItems[index].status = .analyzing
        isLoading = true
        errorMessage = nil

        do {
            var enrichedMedia = media
            if let url = media.sourceURL, media.contentText == nil || media.contentText!.isEmpty {
                do {
                    let text = try await TextExtractorService.shared.extract(from: url)
                    enrichedMedia.contentText = text
                } catch {
                    enrichedMedia.contentText = "Source: \(url)"
                }
            }

            pendingItems[index].status = .generating
            let program = try await AIWorkoutService.shared.generateWorkout(from: enrichedMedia)
            var mutableProgram = program
            mutableProgram.sharedMediaID = media.id

            programs.append(mutableProgram)
            StorageManager.shared.savePrograms(programs)

            SharedContainerService.shared.removePendingItem(id: media.id)
            pendingItems.removeAll { $0.id == media.id }

        } catch {
            pendingItems[index].status = .failed
            pendingItems[index].errorMessage = error.localizedDescription
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func deleteProgram(_ program: WorkoutProgram) {
        programs.removeAll { $0.id == program.id }
        StorageManager.shared.savePrograms(programs)
    }

    func dismissPendingItem(_ media: SharedMedia) {
        SharedContainerService.shared.removePendingItem(id: media.id)
        pendingItems.removeAll { $0.id == media.id }
    }
}
