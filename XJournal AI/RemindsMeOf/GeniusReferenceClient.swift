import Foundation

enum GeniusReferenceClient {
    /// Genius API overview — how keys and clients work.
    static let developersURL = URL(string: "https://genius.com/developers")!
    /// Form that creates a Genius API client so you can copy a Client Access Token.
    static let newAPIClientURL = URL(string: "https://genius.com/api-clients/new")!
    /// Same as `newAPIClientURL` — the page that actually issues a token.
    static let apiClientsURL = newAPIClientURL

    /// Public Genius.com search rejects empty UA; iPhone Safari is what the lyric endpoint accepts.
    private static let publicUserAgent =
        "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1"

    struct SearchResponse: Decodable {
        struct Response: Decodable {
            let hits: [Hit]?
        }
        struct Hit: Decodable {
            let result: Result?
        }
        struct Result: Decodable {
            let id: Int
            let title: String
            let url: String?
            let primary_artist: Artist?
        }
        struct Artist: Decodable {
            let name: String
        }
        let response: Response?
    }

    struct LyricSearchResponse: Decodable {
        struct Response: Decodable {
            let sections: [Section]?
            let hits: [Hit]?
        }
        struct Section: Decodable {
            let type: String?
            let hits: [Hit]?
        }
        struct Hit: Decodable {
            let highlights: [Highlight]?
            let result: Result?
        }
        struct Highlight: Decodable {
            let property: String?
            let value: String?
        }
        struct Result: Decodable {
            let id: Int
            let title: String
            let url: String?
            let primary_artist: SearchResponse.Artist?
            let artist_names: String?
            let primary_artist_names: String?
        }
        let response: Response?
    }

    static func parseSearch(data: Data) throws -> [GeniusSongHit] {
        let decoded = try JSONDecoder().decode(SearchResponse.self, from: data)
        return (decoded.response?.hits ?? []).compactMap { hit in
            guard let result = hit.result else { return nil }
            return GeniusSongHit(
                id: result.id,
                title: result.title,
                artist: result.primary_artist?.name ?? "",
                url: result.url.flatMap(URL.init(string:))
            )
        }
    }

    /// Lyric sections only — snippet text is the bar, not the song title.
    static func parseLyricSearch(data: Data) throws -> [GeniusLyricHit] {
        let decoded = try JSONDecoder().decode(LyricSearchResponse.self, from: data)
        let sectionHits = (decoded.response?.sections ?? [])
            .filter { section in
                let type = section.type?.lowercased() ?? "lyric"
                return type == "lyric" || type == "top_hit"
            }
            .flatMap { $0.hits ?? [] }
        let hits = sectionHits.isEmpty ? (decoded.response?.hits ?? []) : sectionHits
        var seen = Set<Int>()
        return hits.compactMap { hit in
            guard let result = hit.result, seen.insert(result.id).inserted else { return nil }
            let snippet = hit.highlights?
                .first { ($0.property ?? "lyrics").lowercased() == "lyrics" }?
                .value
                ?? hit.highlights?.first?.value
                ?? ""
            let artist = result.primary_artist?.name
                ?? result.primary_artist_names
                ?? result.artist_names
                ?? ""
            return GeniusLyricHit(
                id: result.id,
                title: result.title,
                artist: artist,
                url: result.url.flatMap(URL.init(string:)),
                snippet: snippet
            )
        }
    }

    /// Official API when the user pasted a token; otherwise the same search Genius.com uses (no key).
    static func searchEndpoint(apiKey: String?) -> URL {
        if let apiKey, !apiKey.isEmpty {
            return URL(string: "https://api.genius.com/search")!
        }
        return URL(string: "https://genius.com/api/search")!
    }

    static func lyricSearchEndpoint() -> URL {
        URL(string: "https://genius.com/api/search/lyric")!
    }

    static func search(query: String, apiKey: String? = nil, session: URLSession = .shared) async throws -> [GeniusSongHit] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let userKey = apiKey?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !userKey.isEmpty {
            do {
                return try await performSearch(query: trimmed, apiKey: userKey, session: session)
            } catch {
                if let rap = error as? RapAPIError, case .rateLimitExceeded = rap {
                    throw error
                }
                return try await performSearch(query: trimmed, apiKey: nil, session: session)
            }
        }
        return try await performSearch(query: trimmed, apiKey: nil, session: session)
    }

    /// Raw lyric-search hits (snippet + song). Ingest picks bars; Reminds-me-of picks one line.
    static func searchLyricHits(
        query: String,
        apiKey: String? = nil,
        session: URLSession = .shared
    ) async throws -> [GeniusLyricHit] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let data = try await performLyricSearch(query: trimmed, apiKey: apiKey, session: session)
        return try parseLyricSearch(data: data)
    }

    /// Bars Genius matched — the highlighted lyric line, not the song title.
    static func searchLyrics(
        query: String,
        matching queryLine: String,
        syllables: Int,
        apiKey: String? = nil,
        session: URLSession = .shared
    ) async throws -> [GeniusSongHit] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let data = try await performLyricSearch(query: trimmed, apiKey: apiKey, session: session)
        let parsed = try parseLyricSearch(data: data)
        return parsed.compactMap { hit in
            guard let line = RemindsMeOfScorer.pickSnippetLine(
                hit.snippet,
                queryLine: queryLine,
                syllables: syllables
            ) else { return nil }
            guard RemindsMeOfScorer.isLyricBar(line) else { return nil }
            guard !RemindsMeOfScorer.isTitleLeak(line, song: hit.title) else { return nil }
            return GeniusSongHit(
                id: hit.id,
                title: hit.title,
                artist: hit.artist,
                url: hit.url,
                lyricLine: line
            )
        }
    }

    private static func performSearch(query: String, apiKey: String?, session: URLSession) async throws -> [GeniusSongHit] {
        var components = URLComponents(url: searchEndpoint(apiKey: apiKey), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "q", value: query)]
        guard let url = components?.url else { return [] }
        let data = try await fetch(url: url, apiKey: apiKey, session: session)
        return try parseSearch(data: data)
    }

    private static func performLyricSearch(query: String, apiKey: String?, session: URLSession) async throws -> Data {
        var components = URLComponents(url: lyricSearchEndpoint(), resolvingAgainstBaseURL: false)
        components?.queryItems = [URLQueryItem(name: "q", value: query)]
        guard let url = components?.url else {
            throw RapAPIError.serverError(statusCode: 400, message: nil)
        }
        return try await fetch(url: url, apiKey: apiKey, session: session)
    }

    private static func fetch(url: URL, apiKey: String?, session: URLSession) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(publicUserAgent, forHTTPHeaderField: "User-Agent")
        if let apiKey, !apiKey.isEmpty {
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await session.data(for: request)
        if let http = response as? HTTPURLResponse {
            if http.statusCode == 429 {
                throw RapAPIError.rateLimitExceeded(retryAfterSeconds: nil)
            }
            if !(200..<300).contains(http.statusCode) {
                throw RapAPIError.serverError(statusCode: http.statusCode, message: nil)
            }
        }
        return data
    }

    static func searchQuery(from lines: [String]) -> String {
        searchQuery(forLine: lines.suffix(2).joined(separator: " "))
    }

    /// One verse line → one Genius search. Keep the line intact so hits are about that bar.
    static func searchQuery(forLine line: String) -> String {
        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "" }
        if trimmed.count <= 80 { return trimmed }
        return String(trimmed.prefix(80))
    }

    /// Song search from the bar's distinctive words — not the whole sentence (that matches books).
    static func trackSearchQuery(forLine line: String) -> String {
        RemindsMeOfScorer.trackSearchTokens(forLine: line).joined(separator: " ")
    }
}
