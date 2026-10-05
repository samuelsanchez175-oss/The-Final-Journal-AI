import Foundation
import SwiftUI
import UIKit

/// Inner, mosaic, and chain are separate hues so they don't collapse into one purple on the page.
/// Inner is blue, mosaic is gold, chain is red.
enum CraftHeatPalette {
    static func uiColor(_ t: CGFloat) -> UIColor {
        let x = min(1, max(0, t))
        if x < 0.60 {
            return UIColor(hue: 0.58, saturation: 0.78, brightness: 1, alpha: 1)
        }
        if x < 0.85 {
            return UIColor(hue: 0.12, saturation: 0.95, brightness: 1, alpha: 1)
        }
        return UIColor(hue: 0.00, saturation: 0.90, brightness: 1, alpha: 1)
    }

    static func color(_ t: CGFloat) -> Color {
        Color(uiColor: uiColor(t))
    }
}

/// Finds inner rhyme, mosaic pairs, and internal-to-end chains so the writer can see the craft.
enum TechniqueOverlayEngine {
    private static let extraStops: Set<String> = [
        "yeah", "yea", "uh", "oh", "ayy", "ay", "huh", "nah", "ha", "ok", "okay"
    ]

    struct Hit {
        var range: Range<String.Index>
        var heat: CGFloat
    }

    static func highlights(in text: String) -> [Highlight] {
        hits(in: text).map { hit in
            Highlight(
                range: hit.range,
                in: text,
                colorIndex: 0,
                strength: heatStrength(hit.heat),
                rhymeType: hit.heat >= 0.85 ? .endRhyme : .internalRhyme,
                heat: hit.heat
            )
        }
    }

    static func hits(in text: String) -> [Hit] {
        let tokens = spokenTokens(in: text)
        guard tokens.count >= 2 else { return [] }

        let lines = lineBounds(in: text)
        var heatByUTF16: [Int: (Range<String.Index>, CGFloat)] = [:]

        func raise(_ range: Range<String.Index>, _ heat: CGFloat) {
            let loc = NSRange(range, in: text).location
            if let old = heatByUTF16[loc] {
                heatByUTF16[loc] = (old.0, max(old.1, heat))
            } else {
                heatByUTF16[loc] = (range, heat)
            }
        }

        for bounds in lines {
            let lineTokens = tokens.filter { bounds.contains($0.1.lowerBound) }
            guard lineTokens.count >= 2 else { continue }
            var parent = Array(lineTokens.indices)
            func find(_ i: Int) -> Int {
                var x = i
                while parent[x] != x { parent[x] = parent[parent[x]]; x = parent[x] }
                return x
            }
            func join(_ a: Int, _ b: Int) {
                let ra = find(a), rb = find(b)
                if ra != rb { parent[rb] = ra }
            }
            for i in lineTokens.indices {
                for j in lineTokens.indices where j > i {
                    if GhostSuggestionEngine.chainRhyme(lineTokens[i].0, lineTokens[j].0) {
                        join(i, j)
                    }
                }
            }
            var clusters: [Int: [Int]] = [:]
            for i in lineTokens.indices {
                clusters[find(i), default: []].append(i)
            }
            let lastIdx = lineTokens.count - 1
            for members in clusters.values where members.count >= 2 {
                let hasEnd = members.contains(lastIdx)
                let hasInternal = members.contains { $0 != lastIdx }
                var mosaic = false
                let sorted = members.sorted()
                for k in 1..<sorted.count where sorted[k] == sorted[k - 1] + 1 {
                    mosaic = true
                    break
                }
                var heat: CGFloat = 0.40
                if mosaic { heat = 0.72 }
                if hasInternal && hasEnd { heat = 0.92 }
                else if hasInternal && !hasEnd { heat = max(heat, 0.48) }
                for i in members {
                    raise(lineTokens[i].1, heat)
                }
            }
        }

        // Mosaic across the breath: last two of line N vs first two of line N+1.
        for i in 1..<lines.count {
            let a = tokens.filter { lines[i - 1].contains($0.1.lowerBound) }
            let b = tokens.filter { lines[i].contains($0.1.lowerBound) }
            guard a.count >= 2, b.count >= 2 else { continue }
            let a1 = a[a.count - 2], a2 = a[a.count - 1]
            let b1 = b[0], b2 = b[1]
            if GhostSuggestionEngine.chainRhyme(a1.0, b1.0), GhostSuggestionEngine.chainRhyme(a2.0, b2.0) {
                raise(a1.1, 0.80); raise(a2.1, 0.80)
                raise(b1.1, 0.80); raise(b2.1, 0.80)
            } else if GhostSuggestionEngine.chainRhyme(a2.0, b1.0), GhostSuggestionEngine.chainRhyme(a2.0, b2.0) {
                raise(a2.1, 0.78); raise(b1.1, 0.78); raise(b2.1, 0.78)
            }
        }

        return heatByUTF16.values
            .sorted { NSRange($0.0, in: text).location < NSRange($1.0, in: text).location }
            .map { Hit(range: $0.0, heat: $0.1) }
    }

    /// Content words stay. A short word like "my" stays when it rhymes with a
    /// content word on the same line ("eye" / "my"). Two copies of "the", and a
    /// lone "for", still stay dark.
    private static func spokenTokens(in text: String) -> [(String, Range<String.Index>)] {
        let raw = RhymeHighlighterEngine.tokenizeWords(in: text).filter { word, _ in
            (word.count >= 2 || word == "i" || (word.allSatisfy(\.isNumber) && !word.isEmpty))
                && !extraStops.contains(word)
        }
        let lines = lineBounds(in: text)
        var kept: [(String, Range<String.Index>)] = []
        for bounds in lines {
            let line = raw.filter { bounds.contains($0.1.lowerBound) }
            for (index, token) in line.enumerated() {
                let word = token.0
                if !RhymeHighlighterEngine.rhymeStopwords.contains(word) {
                    kept.append(token)
                    continue
                }
                let rhymesWithContent = line.enumerated().contains { otherIndex, other in
                    otherIndex != index
                        && !RhymeHighlighterEngine.rhymeStopwords.contains(other.0)
                        && GhostSuggestionEngine.chainRhyme(word, other.0)
                }
                if rhymesWithContent { kept.append(token) }
            }
        }
        return kept
    }

    private static func heatStrength(_ heat: CGFloat) -> RhymeHighlighterEngine.RhymeStrength {
        if heat >= 0.85 { return .perfect }
        if heat >= 0.55 { return .near }
        return .slant
    }

    private static func lineBounds(in text: String) -> [Range<String.Index>] {
        var bounds: [Range<String.Index>] = []
        var start = text.startIndex
        while start < text.endIndex {
            let end = text[start...].firstIndex(of: "\n") ?? text.endIndex
            if start < end { bounds.append(start..<end) }
            if end == text.endIndex { break }
            start = text.index(after: end)
        }
        return bounds
    }
}
