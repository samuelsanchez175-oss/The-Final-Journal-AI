//
//  VersePlan.swift
//  XJournal AI
//
//  Model G v3 — the "plan" produced before writing, so the verse has a deliberate spine
//  (central image, strategic angle, anchor rhymes) instead of 16 independently-generated bars.
//

import Foundation

struct VersePlan: Codable {
    let centralImage: String      // the verse's core motif / picture
    let angle: String             // the strategic angle, one phrase
    let anchorRhymes: [String]    // 2-3 rhyme sounds to return to

    static let empty = VersePlan(centralImage: "", angle: "", anchorRhymes: [])

    var isEmpty: Bool {
        centralImage.isEmpty && angle.isEmpty && anchorRhymes.isEmpty
    }

    /// Compact prompt rendering.
    var promptText: String {
        var parts: [String] = []
        if !centralImage.isEmpty { parts.append("Central image: \(centralImage).") }
        if !angle.isEmpty { parts.append("Angle: \(angle).") }
        if !anchorRhymes.isEmpty { parts.append("Anchor rhyme sounds to return to: \(anchorRhymes.joined(separator: ", ")).") }
        return parts.joined(separator: " ")
    }
}
