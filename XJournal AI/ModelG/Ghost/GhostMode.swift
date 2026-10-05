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
