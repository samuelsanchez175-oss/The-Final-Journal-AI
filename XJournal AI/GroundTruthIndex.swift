import Foundation

// MARK: - PR 11: Ground Truth Index Structures

/// Normalized metrics extracted from CSV
struct NormalizedMetrics: Codable {
    let syllableCount: Int
    let stressPattern: [Int]  // Stress positions (1 = stressed, 0 = unstressed)
    let rhymeClass: String?  // Rhyme class from CSV (e.g., "ood")
    let phoneticEnding: String?  // Phonetic ending (e.g., "AY1-T")
}

/// Indexed ground truth bar with normalized metrics
struct GroundTruthIndex: Codable, Identifiable, Hashable {
    let id: String
    let bar: GroundTruthBar
    let normalizedMetrics: NormalizedMetrics
    let authorityVector: String?  // From CSV flow_vector or inferred
    let syllableCount: Int
    let rhymeEnding: String?  // Phonetic ending (e.g., "ood", "AY1-T")
    let verbDensity: Double  // Ratio of verbs to total words
    let verbClasses: [VerbClass]  // Classified verbs in the bar
    
    // Convenience accessors
    var text: String { bar.text }
    var artist: String? { bar.artist }
    var song: String? { bar.song }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: GroundTruthIndex, rhs: GroundTruthIndex) -> Bool {
        return lhs.id == rhs.id
    }
}
