import Foundation

enum GhostMode: String, CaseIterable, Identifiable {
    case off, free, live
    var id: String { rawValue }
    var label: String { self == .off ? "Off" : self == .free ? "Free Ghost" : "Live Ghost" }
    static let storageKey = "ghost_bar_mode"
}
