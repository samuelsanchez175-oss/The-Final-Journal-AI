import Foundation

enum ArtistCatalogError: LocalizedError {
    case invalidURL
    case network
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Paste a Spotify artist link, or an Apple Music artist link under not on Spotify."
        case .network: return "Couldn't reach the catalog. Check the network and try again."
        case .notFound: return "Couldn't find that artist. Check the link."
        }
    }
}

struct ArtistCatalogResult: Equatable {
    var artistName: String
    var songs: [ArtistSong]
    var spotifyURL: String
    var appleMusicURL: String
}

enum ArtistCatalogClient {
    static func parseSpotifyArtistID(from raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("spotify:artist:") {
            let id = String(trimmed.dropFirst("spotify:artist:".count))
            return id.split(separator: "?").first.map(String.init)
        }
        guard let url = URL(string: trimmed), let host = url.host?.lowercased() else { return nil }
        guard host.contains("spotify.com") else { return nil }
        let parts = url.path.split(separator: "/").map(String.init)
        guard let idx = parts.firstIndex(of: "artist"), idx + 1 < parts.count else { return nil }
        return parts[idx + 1].split(separator: "?").first.map(String.init)
    }

    static func parseAppleMusicArtistID(from raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmed), let host = url.host?.lowercased() else { return nil }
        guard host.contains("music.apple.com") || host.contains("itunes.apple.com") else { return nil }
        let parts = url.path.split(separator: "/").map(String.init)
        if let idx = parts.firstIndex(of: "artist"), idx + 1 < parts.count {
            if let last = parts.last, last.allSatisfy(\.isNumber) { return last }
            return parts[idx + 1].split(separator: "?").first.map(String.init)
        }
        if let last = parts.last, last.allSatisfy(\.isNumber) { return last }
        return nil
    }

    static func looksLikeSpotify(_ raw: String) -> Bool {
        parseSpotifyArtistID(from: raw) != nil
    }

    static func looksLikeAppleMusic(_ raw: String) -> Bool {
        parseAppleMusicArtistID(from: raw) != nil
    }

    static func resolve(spotifyURL: String, appleMusicURL: String) async throws -> ArtistCatalogResult {
        let spotify = spotifyURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let apple = appleMusicURL.trimmingCharacters(in: .whitespacesAndNewlines)
        if !spotify.isEmpty {
            return try await resolveSpotify(spotify)
        }
        if !apple.isEmpty {
            return try await resolveAppleMusic(apple)
        }
        throw ArtistCatalogError.invalidURL
    }

    private static func resolveSpotify(_ raw: String) async throws -> ArtistCatalogResult {
        guard parseSpotifyArtistID(from: raw) != nil else { throw ArtistCatalogError.invalidURL }
        guard let name = try await spotifyOEmbedName(urlString: raw), !name.isEmpty else {
            throw ArtistCatalogError.notFound
        }
        let songs = try await itunesSongs(artistName: name, source: "spotify")
        return ArtistCatalogResult(artistName: name, songs: songs, spotifyURL: raw, appleMusicURL: "")
    }

    private static func resolveAppleMusic(_ raw: String) async throws -> ArtistCatalogResult {
        guard let id = parseAppleMusicArtistID(from: raw) else { throw ArtistCatalogError.invalidURL }
        let (name, songs) = try await itunesLookup(artistID: id)
        guard !name.isEmpty else { throw ArtistCatalogError.notFound }
        return ArtistCatalogResult(artistName: name, songs: songs, spotifyURL: "", appleMusicURL: raw)
    }

    private static func spotifyOEmbedName(urlString: String) async throws -> String? {
        guard var comps = URLComponents(string: "https://open.spotify.com/oembed") else { return nil }
        comps.queryItems = [URLQueryItem(name: "url", value: urlString)]
        guard let url = comps.url else { return nil }
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            return nil
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return (json?["title"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func itunesSongs(artistName: String, source: String) async throws -> [ArtistSong] {
        guard var comps = URLComponents(string: "https://itunes.apple.com/search") else { return [] }
        comps.queryItems = [
            URLQueryItem(name: "term", value: artistName),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "attribute", value: "artistTerm"),
            URLQueryItem(name: "limit", value: "50")
        ]
        guard let url = comps.url else { return [] }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw ArtistCatalogError.network
        }
        return parseItunesSongs(data: data, artistName: artistName, source: source)
    }

    private static func itunesLookup(artistID: String) async throws -> (String, [ArtistSong]) {
        guard var comps = URLComponents(string: "https://itunes.apple.com/lookup") else {
            throw ArtistCatalogError.invalidURL
        }
        comps.queryItems = [
            URLQueryItem(name: "id", value: artistID),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "50")
        ]
        guard let url = comps.url else { throw ArtistCatalogError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw ArtistCatalogError.network
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        let results = json?["results"] as? [[String: Any]] ?? []
        let artistName = results.first(where: { ($0["wrapperType"] as? String) == "artist" })?["artistName"] as? String
            ?? results.first?["artistName"] as? String
            ?? ""
        let songs = parseItunesSongs(data: data, artistName: artistName, source: "apple")
        return (artistName, songs)
    }

    static func parseItunesSongs(data: Data, artistName: String, source: String) -> [ArtistSong] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else { return [] }
        var seen = Set<String>()
        var songs: [ArtistSong] = []
        for row in results {
            guard (row["wrapperType"] as? String) != "artist" else { continue }
            let title = (row["trackName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !title.isEmpty else { continue }
            let key = title.lowercased()
            guard seen.insert(key).inserted else { continue }
            let trackArtist = (row["artistName"] as? String) ?? ""
            guard belongsToCatalogArtist(trackArtist: trackArtist, catalogArtist: artistName) else { continue }
            let isFeature = isLikelyFeature(title: title, trackArtist: trackArtist, catalogArtist: artistName)
            songs.append(ArtistSong(
                id: String(row["trackId"] as? Int ?? songs.count),
                title: title,
                primaryArtist: trackArtist,
                isFeature: isFeature,
                included: !isFeature,
                source: source
            ))
        }
        return songs
    }

    static func belongsToCatalogArtist(trackArtist: String, catalogArtist: String) -> Bool {
        let catalog = catalogArtist.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let track = trackArtist.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if catalog.isEmpty { return true }
        if track.isEmpty { return false }
        return track == catalog || track.contains(catalog) || catalog.contains(track)
    }

    static func isLikelyFeature(title: String, trackArtist: String, catalogArtist: String) -> Bool {
        let lower = title.lowercased()
        if lower.contains("feat.") || lower.contains("ft.") || lower.contains("featuring") || lower.contains("(with ") {
            let catalog = catalogArtist.lowercased()
            if !catalog.isEmpty, lower.contains(catalog) { return false }
            return true
        }
        let catalog = catalogArtist.trimmingCharacters(in: .whitespacesAndNewlines)
        let track = trackArtist.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !catalog.isEmpty, !track.isEmpty else { return false }
        if track.caseInsensitiveCompare(catalog) == .orderedSame { return false }
        if track.lowercased().contains(catalog.lowercased()) { return false }
        return true
    }
}
