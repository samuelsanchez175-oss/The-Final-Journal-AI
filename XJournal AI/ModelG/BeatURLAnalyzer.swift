//
//  BeatURLAnalyzer.swift
//  XJournal AI
//
//  Fetches a beat link's title/description and extracts BPM/key/scale via the LLM.
//  A text model can't analyze audio — but beat uploads list "140 BPM C# Minor" in the title.
//

import Foundation

enum BeatURLAnalyzer {
    struct Result: Equatable { let bpm: Int?; let key: String?; let scale: String? }

    /// Fetch the link's title/description, then LLM-extract beat metadata. Returns nils on any failure.
    static func analyze(_ urlString: String) async -> Result {
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), url.scheme != nil else {
            return Result(bpm: nil, key: nil, scale: nil)
        }
        let text = await fetchTitleText(url)
        guard !text.isEmpty else { return Result(bpm: nil, key: nil, scale: nil) }
        let meta = try? await ModelGLLMService.shared.extractBeatMetadata(fromText: text)
        return Result(bpm: meta?.bpm, key: meta?.key, scale: meta?.scale)
    }

    /// YouTube → oEmbed (title + author, no API key); otherwise fetch HTML and pull the title.
    private static func fetchTitleText(_ url: URL) async -> String {
        let host = url.host?.lowercased() ?? ""
        if host.contains("youtube.com") || host.contains("youtu.be") {
            let enc = url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? url.absoluteString
            if let oembed = URL(string: "https://www.youtube.com/oembed?url=\(enc)&format=json"),
               let (data, resp) = try? await URLSession.shared.data(from: oembed),
               (resp as? HTTPURLResponse).map({ (200...299).contains($0.statusCode) }) == true,
               let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let title = obj["title"] as? String ?? ""
                let author = obj["author_name"] as? String ?? ""
                return [title, author].filter { !$0.isEmpty }.joined(separator: " — ")
            }
        }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let html = String(data: data, encoding: .utf8) else { return "" }
        return extractTitle(fromHTML: html)
    }

    /// Pull og:title or <title> from raw HTML (lightweight, no parser dependency). Pure — unit-checkable.
    static func extractTitle(fromHTML html: String) -> String {
        if let r = html.range(of: "property=\"og:title\" content=\"", options: .caseInsensitive),
           let end = html.range(of: "\"", range: r.upperBound..<html.endIndex) {
            return String(html[r.upperBound..<end.lowerBound])
        }
        if let r = html.range(of: "<title>", options: .caseInsensitive),
           let end = html.range(of: "</title>", options: .caseInsensitive, range: r.upperBound..<html.endIndex) {
            return String(html[r.upperBound..<end.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }
}
