import Foundation

enum GhostMode: String, CaseIterable, Identifiable {
    case off, free, live, cadence
    var id: String { rawValue }
    var label: String {
        switch self {
        case .off: return "Off"
        case .free: return "End rhymes"
        case .live: return "End rhymes + AI"
        case .cadence: return "Line completions"
        }
    }
    static let storageKey = "ghost_bar_mode"
}

/// Ghost end-rhyme list. Catalog keeps today's pool. Anything else is an artist map in the rhyme index.
nonisolated enum GhostRhymeSource {
    static let storageKey = "ghostRhymeSource"
    static let catalog = "Catalog"
    static let allArtists = "All artists"

    static func current() -> String {
        let raw = UserDefaults.standard.string(forKey: storageKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return raw.isEmpty ? catalog : raw
    }

    /// nil reads the "All artists" map. Only call this when `current()` is not Catalog.
    static func artistArgument() -> String? {
        let source = current()
        return source == allArtists ? nil : source
    }
}
