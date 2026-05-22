import Foundation

final class AIWorkoutService {
    static let shared = AIWorkoutService()
    let apiKey: String

    init(apiKey: String = AppConstants.openAIAPIKey) {
        self.apiKey = apiKey
    }

    func generateWorkout(from media: SharedMedia) async throws -> WorkoutProgram {
        guard apiKey != "YOUR_OPENAI_API_KEY" else {
            throw AppError.apiKeyMissing
        }

        let prompt = buildPrompt(from: media)
        let messages: [[String: Any]] = [
            ["role": "system", "content": systemInstruction],
            ["role": "user", "content": prompt]
        ]
        let body: [String: Any] = [
            "model": AppConstants.openAIModel,
            "messages": messages,
            "temperature": 0.7,
            "max_tokens": 2048,
            "response_format": ["type": "json_object"]
        ]

        guard let url = URL(string: AppConstants.openAIEndpoint) else {
            throw AppError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let bodyStr = String(data: data, encoding: .utf8) ?? ""
            throw AppError.generationFailed("HTTP \(httpResponse) — \(bodyStr)")
        }

        return try parseResponse(data, originalSource: media.sourceURL ?? media.contentText)
    }

    private var systemInstruction: String {
        """
        You are GymGenie, the world’s smartest workout builder. You turn ANY piece of content into a gym workout program.

        RULES:
        1. Analyze the content for context clues: sport, athlete, physique, goals, vibe, movement patterns.
        2. Build a realistic, progressive gym program.
        3. Return ONLY valid JSON matching the schema below.

        JSON SCHEMA:
        {
          "title": "string (catchy program name, max 4 words)",
          "subtitle": "string (1 sentence pitch)",
          "difficulty": "beginner | intermediate | advanced | elite",
          "durationMinutes": integer,
          "frequencyPerWeek": integer (3 to 6),
          "goal": "string",
          "equipmentNeeded": ["string", ... ],
          "notes": "string",
          "exercises": [
            {
              "name": "string",
              "muscleGroup": "string",
              "sets": integer,
              "reps": "string",
              "restSeconds": integer,
              "instructions": "string"
            }
          ],
          "schedule": [
            {
              "dayName": "string",
              "focus": "string",
              "isRestDay": boolean,
              "exerciseIndices": [integer]
            }
          ]
        }
        """
    }

    private func buildPrompt(from media: SharedMedia) -> String {
        var prompt = "CONTENT TYPE: \(media.mediaType.rawValue.uppercased())\n"
        if let url = media.sourceURL {
            prompt += "SOURCE URL: \(url)\n"
        }
        if let text = media.contentText {
            prompt += "EXTRACTED CONTENT:\n\(text)\n"
        }
        prompt += "\nGenerate a gym workout program based on this content."
        return prompt
    }

    private func parseResponse(_ data: Data, originalSource: String?) throws -> WorkoutProgram {
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = root["choices"] as? [[String: Any]],
              let first = choices.first,
              let message = first["message"] as? [String: Any],
              let content = message["content"] as? String,
              let jsonData = content.data(using: .utf8),
              let obj = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw AppError.decodingError
        }

        let title = obj["title"] as? String ?? "Custom Program"
        let subtitle = obj["subtitle"] as? String ?? ""
        let diffRaw = obj["difficulty"] as? String ?? "intermediate"
        let difficulty = Difficulty(rawValue: diffRaw) ?? .intermediate
        let duration = obj["durationMinutes"] as? Int ?? 45
        let freq = obj["frequencyPerWeek"] as? Int ?? 4
        let goal = obj["goal"] as? String ?? "General Fitness"
        let equipment = obj["equipmentNeeded"] as? [String] ?? []
        let notes = obj["notes"] as? String ?? ""

        var exercises: [Exercise] = []
        if let exArray = obj["exercises"] as? [[String: Any]] {
            for exDict in exArray {
                let ex = Exercise(
                    name: exDict["name"] as? String ?? "Unnamed Exercise",
                    muscleGroup: exDict["muscleGroup"] as? String ?? "Full Body",
                    sets: exDict["sets"] as? Int ?? 3,
                    reps: exDict["reps"] as? String ?? "10",
                    restSeconds: exDict["restSeconds"] as? Int ?? 60,
                    instructions: exDict["instructions"] as? String ?? ""
                )
                exercises.append(ex)
            }
        }

        var schedule: [DayPlan] = []
        if let schedArray = obj["schedule"] as? [[String: Any]] {
            for dayDict in schedArray {
                let indices = dayDict["exerciseIndices"] as? [Int] ?? []
                let ids = indices.compactMap { idx in
                    exercises.indices.contains(idx) ? exercises[idx].id : nil
                }
                let plan = DayPlan(
                    dayName: dayDict["dayName"] as? String ?? "Day",
                    focus: dayDict["focus"] as? String ?? "",
                    exerciseIDs: ids,
                    isRestDay: dayDict["isRestDay"] as? Bool ?? false
                )
                schedule.append(plan)
            }
        }

        return WorkoutProgram(
            title: title,
            subtitle: subtitle,
            difficulty: difficulty,
            durationMinutes: duration,
            frequencyPerWeek: freq,
            goal: goal,
            equipmentNeeded: equipment,
            exercises: exercises,
            schedule: schedule,
            notes: notes,
            originalSource: originalSource
        )
    }
}
