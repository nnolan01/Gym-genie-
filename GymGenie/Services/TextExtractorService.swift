import Foundation

final class TextExtractorService {
    static let shared = TextExtractorService()

    func extract(from urlString: String) async throws -> String {
        guard let url = URL(string: urlString) else {
            throw AppError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200,
              let html = String(data: data, encoding: .utf8) else {
            throw AppError.noContentExtracted
        }

        return extractReadableText(from: html, url: url)
    }

    private func extractReadableText(from html: String, url: URL) -> String {
        let lowered = html.lowercased()

        if url.host?.contains("youtube.com") == true || url.host?.contains("youtu.be") == true {
            return extractYouTubeContext(from: html, url: url)
        }

        if url.host?.contains("tiktok.com") == true || url.host?.contains("instagram.com") == true {
            return extractSocialContext(from: html, url: url)
        }

        var result = ""
        if let title = extractMetaTag(html: html, property: "og:title") {
            result += "TITLE: \(title)\n"
        }
        if let desc = extractMetaTag(html: html, property: "og:description") {
            result += "DESCRIPTION: \(desc)\n"
        }

        let body = html.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if body.count > 100 {
            let maxLen = min(4000, body.count)
            result += "\nBODY:\n" + String(body.prefix(maxLen))
        }

        return result.isEmpty ? html : result
    }

    private func extractYouTubeContext(from html: String, url: URL) -> String {
        let title = extractMetaTag(html: html, property: "og:title") ?? "YouTube Video"
        let desc = extractMetaTag(html: html, property: "og:description") ?? ""
        return "YOUTUBE VIDEO\nTITLE: \(title)\nDESCRIPTION: \(desc)\nURL: \(url.absoluteString)"
    }

    private func extractSocialContext(from html: String, url: URL) -> String {
        let title = extractMetaTag(html: html, property: "og:title") ?? ""
        let desc = extractMetaTag(html: html, property: "og:description") ?? ""
        return "SOCIAL MEDIA POST\nTITLE: \(title)\nDESCRIPTION: \(desc)\nURL: \(url.absoluteString)"
    }

    private func extractMetaTag(html: String, property: String) -> String? {
        let pattern = "<meta[^>]+property=\"\\Q\(property)\\E\"[^>]+content=\"([^\"]+)\""
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: html, options: [], range: NSRange(html.startIndex..., in: html)),
           match.numberOfRanges > 1,
           let range = Range(match.range(at: 1), in: html) {
            return String(html[range]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
}
