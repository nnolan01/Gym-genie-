import Foundation

struct Exercise: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var muscleGroup: String
    var sets: Int
    var reps: String
    var restSeconds: Int
    var instructions: String
    var videoURL: String?
    init(id: UUID = UUID(), name: String, muscleGroup: String, sets: Int, reps: String, restSeconds: Int, instructions: String, videoURL: String? = nil) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.instructions = instructions
        self.videoURL = videoURL
    }
}
