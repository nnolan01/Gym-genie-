import Foundation

enum MediaType: String, Codable { case article, video, image, text, unknown }
enum ProcessingStatus: String, Codable { case pending, analyzing, generating, completed, failed }

struct SharedMedia: Identifiable, Codable, Equatable {
    let id: UUID
    var sourceURL: String?
    var sourceApp: String?
    var contentText: String?
    var localVideoPath: String?
    var localImagePath: String?
    var mediaType: MediaType
    var status: ProcessingStatus
    var errorMessage: String?
    let createdAt: Date
    var completedAt: Date?

    init(id: UUID = UUID(), sourceURL: String? = nil, sourceApp: String? = nil, contentText: String? = nil, localVideoPath: String? = nil, localImagePath: String? = nil, mediaType: MediaType = .unknown, status: ProcessingStatus = .pending, errorMessage: String? = nil, createdAt: Date = Date(), completedAt: Date? = nil) {
        self.id = id
        self.sourceURL = sourceURL
        self.sourceApp = sourceApp
        self.contentText = contentText
        self.localVideoPath = localVideoPath
        self.localImagePath = localImagePath
        self.mediaType = mediaType
        self.status = status
        self.errorMessage = errorMessage
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
}
