import Foundation

enum Difficulty: String, Codable, CaseIterable { case beginner, intermediate, advanced, elite }

struct WorkoutProgram: Identifiable, Codable, Equatable {
    let id: UUID
    let sharedMediaID: UUID?
    var title: String
    var subtitle: String
    var difficulty: Difficulty
    var durationMinutes: Int
    var frequencyPerWeek: Int
    var goal: String
    var equipmentNeeded: [String]
    var exercises: [Exercise]
    var schedule: [DayPlan]
    var notes: String
    var originalSource: String?
    let createdAt: Date

    init(id: UUID = UUID(), sharedMediaID: UUID? = nil, title: String, subtitle: String, difficulty: Difficulty, durationMinutes: Int, frequencyPerWeek: Int, goal: String, equipmentNeeded: [String], exercises: [Exercise], schedule: [DayPlan], notes: String, originalSource: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.sharedMediaID = sharedMediaID
        self.title = title
        self.subtitle = subtitle
        self.difficulty = difficulty
        self.durationMinutes = durationMinutes
        self.frequencyPerWeek = frequencyPerWeek
        self.goal = goal
        self.equipmentNeeded = equipmentNeeded
        self.exercises = exercises
        self.schedule = schedule
        self.notes = notes
        self.originalSource = originalSource
        self.createdAt = createdAt
    }
}

struct DayPlan: Identifiable, Codable, Equatable {
    let id: UUID
    var dayName: String
    var focus: String
    var exerciseIDs: [UUID]
    var isRestDay: Bool

    init(id: UUID = UUID(), dayName: String, focus: String, exerciseIDs: [UUID], isRestDay: Bool = false) {
        self.id = id
        self.dayName = dayName
        self.focus = focus
        self.exerciseIDs = exerciseIDs
        self.isRestDay = isRestDay
    }
}
