import Foundation

/// Notes-style "Find in Transcript": case-insensitive row matches in display order.
nonisolated enum TranscriptFind: Sendable {
    nonisolated static func matchingIDs(
        query: String,
        rows: [(id: Int, text: String, isPause: Bool)]
    ) -> [Int] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return [] }
        return rows.compactMap { row in
            guard !row.isPause, !row.text.isEmpty else { return nil }
            return row.text.range(of: needle, options: [.caseInsensitive, .diacriticInsensitive]) != nil
                ? row.id
                : nil
        }
    }
}
