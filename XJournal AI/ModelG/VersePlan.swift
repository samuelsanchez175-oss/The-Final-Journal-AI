//
//  VersePlan.swift
//  XJournal AI
//
//  Model G v3 — the "plan" produced before writing, so the verse has a deliberate spine
//  (central image, strategic angle, anchor rhymes) instead of 16 independently-generated bars.
//  Phase 2: optional Ohm word recipe + semantic/homophone cage.
//

import Foundation

struct WordRecipe: Codable, Equatable {
    var seed: String
    var meanings: [String]
    var rimeFamily: [String]
    var culturalRef: String
    var combinedImage: String

    var isUsable: Bool {
        !combinedImage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

struct SemanticCage: Codable, Equatable {
    var sound: String
    var senses: [String]

    var isUsable: Bool {
        !sound.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && senses.count >= 2
    }
}

struct VersePlan: Codable {
    let centralImage: String
    let angle: String
    let anchorRhymes: [String]
    var wordRecipe: WordRecipe?
    var semanticCage: SemanticCage?

    static let empty = VersePlan(centralImage: "", angle: "", anchorRhymes: [])

    init(
        centralImage: String,
        angle: String,
        anchorRhymes: [String],
        wordRecipe: WordRecipe? = nil,
        semanticCage: SemanticCage? = nil
    ) {
        self.centralImage = centralImage
        self.angle = angle
        self.anchorRhymes = anchorRhymes
        self.wordRecipe = wordRecipe
        self.semanticCage = semanticCage
    }

    var isEmpty: Bool {
        centralImage.isEmpty && angle.isEmpty && anchorRhymes.isEmpty
            && wordRecipe == nil && semanticCage == nil
    }

    /// Compact prompt rendering (spine only — recipe/cage have their own blocks).
    var promptText: String {
        var parts: [String] = []
        if !centralImage.isEmpty { parts.append("Central image: \(centralImage).") }
        if !angle.isEmpty { parts.append("Angle: \(angle).") }
        if !anchorRhymes.isEmpty { parts.append("Anchor rhyme sounds to return to: \(anchorRhymes.joined(separator: ", ")).") }
        return parts.joined(separator: " ")
    }

    static func fromJSONObject(_ obj: [String: Any]) -> VersePlan {
        VersePlan(
            centralImage: obj["centralImage"] as? String ?? "",
            angle: obj["angle"] as? String ?? "",
            anchorRhymes: stringArray(obj["anchorRhymes"]),
            wordRecipe: parseWordRecipe(obj["wordRecipe"]),
            semanticCage: parseSemanticCage(obj["semanticCage"])
        )
    }

    private static func stringArray(_ value: Any?) -> [String] {
        (value as? [String])?.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty } ?? []
    }

    private static func parseWordRecipe(_ value: Any?) -> WordRecipe? {
        guard let dict = value as? [String: Any] else { return nil }
        let recipe = WordRecipe(
            seed: (dict["seed"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            meanings: stringArray(dict["meanings"]),
            rimeFamily: stringArray(dict["rimeFamily"]),
            culturalRef: (dict["culturalRef"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            combinedImage: (dict["combinedImage"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        )
        return recipe.isUsable ? recipe : nil
    }

    private static func parseSemanticCage(_ value: Any?) -> SemanticCage? {
        guard let dict = value as? [String: Any] else { return nil }
        let cage = SemanticCage(
            sound: (dict["sound"] as? String ?? "").trimmingCharacters(in: .whitespacesAndNewlines),
            senses: stringArray(dict["senses"])
        )
        return cage.isUsable ? cage : nil
    }
}
