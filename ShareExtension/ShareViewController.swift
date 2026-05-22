import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

enum MediaType: String, Codable { case article, video, image, text, unknown }
enum ProcessingStatus: String, Codable { case pending, analyzing, generating, completed, failed }
struct SharedMedia: Identifiable, Codable {
    let id: UUID
    var sourceURL: String?
    var sourceApp: String?
    var contentText: String?
    var mediaType: MediaType
    var status: ProcessingStatus
    let createdAt: Date
    init(id: UUID = UUID(), sourceURL: String? = nil, sourceApp: String? = nil, contentText: String? = nil, mediaType: MediaType = .unknown, status: ProcessingStatus = .pending) {
        self.id = id; self.sourceURL = sourceURL; self.sourceApp = sourceApp; self.contentText = contentText; self.mediaType = mediaType; self.status = status; self.createdAt = Date()
    }
}
enum AppConstants { static let appGroupID = "group.com.yourcompany.GymGenie"; static let sharedContainerPendingKey = "pending_shared_items" }
final class SharedContainerService {
    static let shared = SharedContainerService()
    var sharedDefaults: UserDefaults? { UserDefaults(suiteName: AppConstants.appGroupID) }
    func savePendingMedia(_ media: SharedMedia) {
        guard let defaults = sharedDefaults else { return }
        var pending = retrievePendingMedia(); pending.append(media)
        if let data = try? JSONEncoder().encode(pending) { defaults.set(data, forKey: AppConstants.sharedContainerPendingKey) }
    }
    func retrievePendingMedia() -> [SharedMedia] {
        guard let defaults = sharedDefaults, let data = defaults.data(forKey: AppConstants.sharedContainerPendingKey), let items = try? JSONDecoder().decode([SharedMedia].self, from: data) else { return [] }
        return items
    }
}
class ShareViewController: UIViewController {
    private let statusLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    override func viewDidLoad() { super.viewDidLoad(); setupUI(); handleSharedContent() }
    private func setupUI() {
        view.backgroundColor = .systemBackground
        statusLabel.translatesAutoresizingMaskIntoConstraints = false; statusLabel.textAlignment = .center; statusLabel.numberOfLines = 0; statusLabel.font = UIFont.preferredFont(forTextStyle: .headline); statusLabel.text = "Importing to GymGenie..."
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false; activityIndicator.startAnimating()
        view.addSubview(activityIndicator); view.addSubview(statusLabel)
        NSLayoutConstraint.activate([activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor), activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20), statusLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 16), statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20), statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)])
    }
    private func handleSharedContent() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem, let attachments = extensionItem.attachments else { showError("No content found"); return }
        var capturedURL: String?; var capturedText: String?; var mediaType: MediaType = .unknown
        let group = DispatchGroup()
        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) { group.enter(); provider.loadItem(forTypeIdentifier: UTType.url.identifier) { (item, error) in defer { group.leave() }; if let url = item as? URL { capturedURL = url.absoluteString; mediaType = .article } else if let urlStr = item as? String { capturedURL = urlStr; mediaType = .article } } }
            if provider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) { group.enter(); provider.loadItem(forTypeIdentifier: UTType.plainText.identifier) { (item, error) in defer { group.leave() }; if let text = item as? String { capturedText = text; if mediaType == .unknown { mediaType = .text } } } }
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) { group.enter(); provider.loadItem(forTypeIdentifier: UTType.movie.identifier) { (item, error) in defer { group.leave() }; if let url = item as? URL { capturedURL = url.absoluteString; mediaType = .video } } }
        }
        group.notify(queue: .main) { self.saveAndFinish(url: capturedURL, text: capturedText, type: mediaType) }
    }
    private func saveAndFinish(url: String?, text: String?, type: MediaType) {
        guard url != nil || text != nil else { showError("Could not read shared content. Try sharing a link instead."); return }
        let media = SharedMedia(sourceURL: url, sourceApp: nil, contentText: text, mediaType: type, status: .pending)
        SharedContainerService.shared.savePendingMedia(media)
        statusLabel.text = "Saved! Open GymGenie to build your workout."; activityIndicator.stopAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil) }
    }
    private func showError(_ message: String) {
        statusLabel.text = message; activityIndicator.stopAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.extensionContext?.cancelRequest(withError: NSError(domain: "GymGenieShare", code: 1, userInfo: [NSLocalizedDescriptionKey: message])) }
    }
}
