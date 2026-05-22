import Foundation

final class StorageManager {
    static let shared = StorageManager()

    private var programsURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("workout_programs.json")
    }

    func savePrograms(_ programs: [WorkoutProgram]) {
        do {
            let data = try JSONEncoder().encode(programs)
            try data.write(to: programsURL)
        } catch {
            print("Failed to save programs: \(error)")
        }
    }

    func loadPrograms() -> [WorkoutProgram] {
        guard FileManager.default.fileExists(atPath: programsURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: programsURL)
            return try JSONDecoder().decode([WorkoutProgram].self, from: data)
        } catch {
            print("Failed to load programs: \(error)")
            return []
        }
    }

    func deleteProgram(id: UUID) {
        var programs = loadPrograms()
        programs.removeAll { $0.id == id }
        savePrograms(programs)
    }
}
