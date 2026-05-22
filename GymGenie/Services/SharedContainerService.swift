import Foundation

final class SharedContainerService {
    static let shared = SharedContainerService()

    var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: AppConstants.appGroupID)
    }

    func savePendingMedia(_ media: SharedMedia) {
        guard let defaults = sharedDefaults else { return }
        var pending = retrievePendingMedia()
        pending.append(media)
        if let data = try? JSONEncoder().encode(pending) {
            defaults.set(data, forKey: AppConstants.sharedContainerPendingKey)
        }
    }

    func retrievePendingMedia() -> [SharedMedia] {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: AppConstants.sharedContainerPendingKey),
              let items = try? JSONDecoder().decode([SharedMedia].self, from: data) else {
            return []
        }
        return items
    }

    func clearPendingMedia() {
        sharedDefaults?.removeObject(forKey: AppConstants.sharedContainerPendingKey)
    }

    func removePendingItem(id: UUID) {
        var pending = retrievePendingMedia()
        pending.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(pending) {
            sharedDefaults?.set(data, forKey: AppConstants.sharedContainerPendingKey)
        }
    }
}
