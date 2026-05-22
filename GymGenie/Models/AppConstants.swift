import Foundation

enum AppConstants {
    static let appGroupID = "group.com.yourcompany.GymGenie"
    static let sharedContainerPendingKey = "pending_shared_items"
    static let openAIAPIKey = "YOUR_OPENAI_API_KEY"
    static let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    static let openAIModel = "gpt-4o"
}

enum AppError: LocalizedError {
    case apiKeyMissing
    case invalidURL
    case networkError(Error)
    case decodingError
    case noContentExtracted
    case generationFailed(String)

    var errorDescription: String? {
        switch self {
        case .apiKeyMissing:
            return "OpenAI API Key is missing. Add it in AppConstants.swift or use your backend."
        case .invalidURL:
            return "The shared URL is invalid."
        case .networkError(let err):
            return "Network error: \(err.localizedDescription)"
        case .decodingError:
            return "Failed to parse AI response."
        case .noContentExtracted:
            return "Could not extract content from the shared link."
        case .generationFailed(let msg):
            return "Workout generation failed: \(msg)"
        }
    }
}
