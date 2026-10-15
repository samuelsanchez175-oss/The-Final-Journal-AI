import SwiftUI

/// One breath comma offered when Setup and punch turns on.
/// The line already had no pause. Setup is green and punch is red once the comma lands.
nonisolated struct BreathCommaEdit: Equatable, Sendable, Identifiable {
    var lineIndex: Int
    var original: String
    var revised: String
    var setup: String
    var punch: String
    var setupSyllables: Int
    var punchSyllables: Int

    var id: Int { lineIndex }
}

/// Places a breath comma only when the line is long enough for a full bar,
/// a word boundary sits near the wrap's halfway count, and the words
/// around that boundary actually change clause (or repeat a picture).
/// A short line against a longer wrap, a list, and a line that already
/// breaks are left alone.
nonisolated enum BreathCommaFormatter {
    static func wrapCount(min: Int?, max: Int?) -> Int? {
        let lo = (min ?? 0) > 0 ? min : nil
        let hi = (max ?? 0) > 0 ? max : nil
        switch (lo, hi) {
        case let (a?, b?):
            return (a + b) / 2
        case let (a?, nil):
            return a
        case let (nil, b?):
            return b
        case (nil, nil):
            return nil
        }
    }

    static func edits(in text: String, wrapSyllables: Int? = nil) -> [BreathCommaEdit] {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        let clauses: [LyricClause?] = lines.map { raw in
            let trimmed = raw.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !hasHardStop(trimmed) else { return nil }
            return LyricClause.split(trimmed)
        }
        let verseWrap = wrapSyllables ?? inferredWrap(from: lines)
        var out: [BreathCommaEdit] = []
        for (index, raw) in lines.enumerated() {
            if let edit = edit(
                for: raw,
                index: index,
                verseWrap: verseWrap,
                lines: lines,
                clauses: clauses
            ) {
                out.append(edit)
            }
        }
        return out
    }

    static func applying(_ edits: [BreathCommaEdit], to text: String) -> String {
        var lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        for edit in edits {
            guard lines.indices.contains(edit.lineIndex) else { continue }
            guard lines[edit.lineIndex] == edit.original else { continue }
            lines[edit.lineIndex] = edit.revised
        }
        return lines.joined(separator: "\n")
    }

    private static func edit(
        for raw: String,
        index: Int,
        verseWrap: Int?,
        lines: [String],
        clauses: [LyricClause?]
    ) -> BreathCommaEdit? {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !hasHardStop(trimmed) else { return nil }
        guard LyricClause.split(trimmed) == nil else { return nil }

        let syllables = LineSyllableCounter.syllableCount(forLine: trimmed)
        guard syllables >= 4 else { return nil }
        let wrap = verseWrap ?? syllables
        let fullBar = syllables >= max(8, wrap - 2)
        let words = words(in: raw)
        guard words.count >= 4 else { return nil }

        let setups = neighborSetups(clauses: clauses, skipping: index, lineSyllables: syllables)
        let target = agreedSetup(setups, lineSyllables: syllables) ?? halfSetup(syllables)
        let previous = adjacentClause(clauses, lines: lines, index: index, step: -1)
        let next = adjacentClause(clauses, lines: lines, index: index, step: 1)

        var best: (score: Int, distance: Int, edit: BreathCommaEdit)?
        for cut in words.indices.dropLast() {
            let revised = insertingComma(in: raw, after: words[cut].end)
            guard let clause = LyricClause.split(revised) else { continue }
            let distance = abs(clause.setupSyllables - target)
            let opener = openerKind(firstWord(of: clause.punch))
            let parallel = clause.pictureReRead || clause.rhymesAcross
            let slack = syllables >= 12 && (opener == .strong || parallel) ? 2 : 1
            guard distance <= slack else { continue }
            if (!fullBar || syllables < 8) && !parallel { continue }
            if !parallel && opener == .none { continue }
            if !parallel && endsWithDangler(clause.setup) { continue }
            if min(clause.setup.count, clause.punch.count) < 8 && !parallel { continue }
            guard clause.setupSyllables >= 2, clause.punchSyllables >= 2 else { continue }

            var score = 20 - distance * 5
            switch opener {
            case .strong: score += 6
            case .soft: score += 3
            case .none: break
            }
            if clause.rhymesAcross { score += 5 }
            if clause.pictureReRead { score += 5 }
            if clause.nearRhymes { score += 2 }
            if matchesNeighbor(clause.setupSyllables, previous: previous, next: next, lineSyllables: syllables) {
                score += 3
            }
            if openerKind(lastWord(of: clause.setup)) != .none { score -= 4 }

            let edit = BreathCommaEdit(
                lineIndex: index,
                original: raw,
                revised: revised,
                setup: clause.setup,
                punch: clause.punch,
                setupSyllables: clause.setupSyllables,
                punchSyllables: clause.punchSyllables
            )
            if let current = best {
                let better = score > current.score
                    || (score == current.score && distance < current.distance)
                if better { best = (score, distance, edit) }
            } else {
                best = (score, distance, edit)
            }
        }
        return best?.edit
    }

    private enum Opener {
        case strong, soft, none
    }

    private static let strongOpeners: Set<String> = [
        "yea", "yeah", "yeh", "yah", "ay", "aye", "aight", "ok", "okay",
        "then", "so", "cause", "cuz", "cos", "because", "but", "still", "now"
    ]

    private static let softOpeners: Set<String> = [
        "i", "im", "i'm", "i’m", "we", "they", "she", "he", "you", "ya",
        "and", "while", "when", "where", "until", "till", "before", "after",
        "like", "just", "though", "yet"
    ]

    private static let danglers: Set<String> = [
        "the", "a", "an", "of", "to", "in", "on", "at", "for", "with", "from",
        "and", "or", "nor", "my", "your", "his", "her", "our", "their", "its"
    ]

    private static func openerKind(_ word: String) -> Opener {
        let key = normalized(word)
        if strongOpeners.contains(key) { return .strong }
        if softOpeners.contains(key) { return .soft }
        return .none
    }

    private static func endsWithDangler(_ setup: String) -> Bool {
        danglers.contains(normalized(lastWord(of: setup)))
    }

    private static func normalized(_ word: String) -> String {
        word.lowercased().filter { $0.isLetter || $0 == "'" || $0 == "’" }
    }

    private static func firstWord(of text: String) -> String {
        text.split(whereSeparator: \.isWhitespace).first.map(String.init) ?? ""
    }

    private static func lastWord(of text: String) -> String {
        text.split(whereSeparator: \.isWhitespace).last.map(String.init) ?? ""
    }

    private static func hasHardStop(_ line: String) -> Bool {
        line.contains { character in
            character == "," || character == "—" || character == "–"
                || character == ";" || character == ":" || character == "!"
                || character == "?" || character == "."
        }
    }

    private struct Word {
        var end: String.Index
    }

    private static func words(in line: String) -> [Word] {
        var out: [Word] = []
        var index = line.startIndex
        while index < line.endIndex {
            while index < line.endIndex, line[index].isWhitespace {
                index = line.index(after: index)
            }
            if index >= line.endIndex { break }
            while index < line.endIndex, !line[index].isWhitespace {
                index = line.index(after: index)
            }
            out.append(Word(end: index))
        }
        return out
    }

    /// Comma sits on the word, then one space, then the punch.
    private static func insertingComma(in line: String, after end: String.Index) -> String {
        let head = line[..<end]
        let tail = line[end...].drop(while: \.isWhitespace)
        if tail.isEmpty { return String(head) + "," }
        return String(head) + ", " + tail
    }

    private static func halfSetup(_ syllables: Int) -> Int {
        let mid = (syllables + 1) / 2
        return min(max(mid, 2), max(syllables - 2, 2))
    }

    private static func inferredWrap(from lines: [String]) -> Int? {
        let counts = lines
            .map { LineSyllableCounter.syllableCount(forLine: $0) }
            .filter { $0 >= 6 }
        guard counts.count >= 2 else { return nil }
        var bestCount = 0
        var bestHits = 0
        for count in Set(counts) {
            let hits = counts.filter { abs($0 - count) <= 1 }.count
            if hits > bestHits || (hits == bestHits && count > bestCount) {
                bestHits = hits
                bestCount = count
            }
        }
        guard bestHits >= 2, bestHits * 2 >= counts.count else { return nil }
        return bestCount
    }

    private static func neighborSetups(clauses: [LyricClause?], skipping index: Int, lineSyllables: Int) -> [Int] {
        clauses.enumerated().compactMap { offset, clause in
            guard offset != index, let clause else { return nil }
            let wrap = clause.setupSyllables + clause.punchSyllables
            guard abs(wrap - lineSyllables) <= 2 else { return nil }
            return clause.setupSyllables
        }
    }

    /// Two nearby breaths that share a setup count override a blind halfway cut.
    private static func agreedSetup(_ setups: [Int], lineSyllables: Int) -> Int? {
        guard setups.count >= 2 else { return nil }
        var bestCount = 0
        var bestHits = 0
        for count in Set(setups) {
            let hits = setups.filter { abs($0 - count) <= 1 }.count
            if hits > bestHits || (hits == bestHits && count > bestCount) {
                bestHits = hits
                bestCount = count
            }
        }
        guard bestHits >= 2, bestCount >= 2, bestCount <= lineSyllables - 2 else { return nil }
        return bestCount
    }

    private static func adjacentClause(
        _ clauses: [LyricClause?],
        lines: [String],
        index: Int,
        step: Int
    ) -> LyricClause? {
        var cursor = index + step
        var skippedBlanks = 0
        while lines.indices.contains(cursor), skippedBlanks < 2 {
            if let clause = clauses[cursor] { return clause }
            let blank = lines[cursor].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if !blank { return nil }
            cursor += step
            skippedBlanks += 1
        }
        return nil
    }

    private static func matchesNeighbor(
        _ setupSyllables: Int,
        previous: LyricClause?,
        next: LyricClause?,
        lineSyllables: Int
    ) -> Bool {
        for clause in [previous, next].compactMap({ $0 }) {
            let wrap = clause.setupSyllables + clause.punchSyllables
            if abs(wrap - lineSyllables) <= 2, abs(clause.setupSyllables - setupSyllables) <= 1 {
                return true
            }
        }
        return false
    }
}

struct BreathCommaPromptSheet: View {
    let edits: [BreathCommaEdit]
    var onAdd: () -> Void
    var onLeave: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(explanation)
                        .font(.subheadline)
                        .foregroundStyle(Momentum.contentPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    ForEach(edits) { edit in
                        preview(edit)
                    }
                }
                .padding(20)
            }
            .background(Momentum.surface)
            .navigationTitle("Add breath commas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Momentum.surface, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    Button(action: onAdd) {
                        Text("Add commas")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityHint("Puts the commas on the lines above. Green stays the setup and red stays the punch.")
                    Button(action: onLeave) {
                        Text("Leave lines as they are")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityHint("Keeps the highlighting and does not change the lines.")
                }
                .padding(20)
                .background(Momentum.surface)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Momentum.surface)
    }

    private var explanation: String {
        let count = edits.count
        let lines = count == 1 ? "1 line" : "\(count) lines"
        return "Setup and punch stays on. Green is the setup and red is the punch. Commas can mark that break on \(lines), using each line’s length, the wrap syllable count, and the lines around it. Short lines, and lines that already break, stay as they are."
    }

    private func preview(_ edit: BreathCommaEdit) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Line \(edit.lineIndex + 1)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Momentum.contentPrimary)
            (
                Text("\(edit.setup), \(edit.punch)")
                    .foregroundStyle(Color(uiColor: .systemGreen))
                    .font(.body)
            )
            .fixedSize(horizontal: false, vertical: true)
            Text("\(countWord(edit.setupSyllables)) in the setup, \(countWord(edit.punchSyllables)) in the punch")
                .font(.subheadline)
                .foregroundStyle(Momentum.contentPrimary.opacity(0.72))
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Momentum.surfaceElevated, in: RoundedRectangle(cornerRadius: Momentum.corner, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private func countWord(_ count: Int) -> String {
        count == 1 ? "1 syllable" : "\(count) syllables"
    }
}
