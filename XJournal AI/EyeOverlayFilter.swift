import Foundation

/// Highlight choices on the eye popover. One at a time; tap the active row to turn all off.
enum EyeHighlightOption: String, CaseIterable, Identifiable {
    case rhymes
    case setupAndPunch
    case techniques

    var id: String { rawValue }

    var label: String {
        switch self {
        case .rhymes: return "Rhymes"
        case .setupAndPunch: return "Setup and punch"
        case .techniques: return "Techniques"
        }
    }

    static let setupAndPunchStorageKey = "editor_setup_and_punch_highlight"
    static let rhymesStorageKey = "defaultRhymeOverlayVisible"
    static let techniquesStorageKey = "editor_technique_highlight"
}
