import Foundation

/// On-device wrap + end-rhyme retrieval over confirmed ArtistBrain chunks.
/// Mirrors Reminds-me-of wrapHits / landing when those engines exist.
enum ArtistBrainRAG {
    nonisolated static func endWord(of line: String) -> String? {
        if let ghost = GhostSuggestionEngine.endWord(of: line) { return ghost }
        let tokens = line
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count >= 2 }
        return tokens.last
    }

    nonisolated static func wrapFamily(of line: String) -> String? {
        let n = LineSyllableCounter.syllableCount(forLine: line)
        guard n > 0 else { return nil }
        return "syl-\(n)"
    }

    static func retrieve(
        brain: ArtistBrain,
        noteText: String,
        limit: Int = 8,
        filters: ModelYouVerseFilters = .init()
    ) -> [ArtistBrainChunk] {
        let graph = ArtistBrainGraph.rebuild(from: brain)
        var lyric = graph.retrieveChunks.filter { $0.kind == .lyricBar }
        var persona = graph.retrieveChunks.filter { $0.kind == .confirmedCard }
        if !filters.effectiveUsePeople {
            persona = []
        }
        if !filters.effectiveUseBottle {
            let punches = Set(graph.punchLabels)
            lyric = lyric.filter { chunk in
                RemindsMeOfScorer.contentTokens(chunk.text).isDisjoint(with: punches)
            }
        }
        let queryLines = RemindsMeOfScorer.queryLines(from: noteText)
        let last = Array(queryLines.suffix(4))

        guard !last.isEmpty else {
            return Array(persona.prefix(limit))
        }
        if lyric.isEmpty && persona.isEmpty {
            return []
        }

        let pool: [RemindsMeOfCandidate] = lyric.map { chunk in
            RemindsMeOfCandidate(
                id: chunk.id,
                line: chunk.text,
                artist: brain.artistName.isEmpty ? nil : brain.artistName,
                song: chunk.songTitle,
                syllableCount: chunk.syllableCount > 0
                    ? chunk.syllableCount
                    : LineSyllableCounter.syllableCount(forLine: chunk.text),
                source: .csv
            )
        }

        var picked: [ArtistBrainChunk] = []
        var seen = Set<String>()
        func take(_ chunk: ArtistBrainChunk) {
            let key = RemindsMeOfScorer.normalizedLine(chunk.text)
            guard seen.insert(key).inserted else { return }
            picked.append(chunk)
        }

        for line in last {
            let syllables = LineSyllableCounter.syllableCount(forLine: line)
            let wraps = RemindsMeOfScorer.wrapHits(
                from: pool,
                queryLine: line,
                syllables: syllables,
                limit: limit
            )
            var excluded = Set(wraps.map { RemindsMeOfScorer.normalizedLine($0.line) })
            excluded.insert(RemindsMeOfScorer.normalizedLine(line))
            let landings = RemindsMeOfScorer.landingHits(
                from: pool,
                queryLine: line,
                excluding: excluded,
                limit: 4
            )
            for hit in wraps + landings {
                if let chunk = lyric.first(where: { $0.id == hit.id }) {
                    take(chunk)
                } else if let chunk = lyric.first(where: {
                    RemindsMeOfScorer.normalizedLine($0.text) == RemindsMeOfScorer.normalizedLine(hit.line)
                }) {
                    take(chunk)
                }
                if picked.count >= limit { return picked }
            }
            if wraps.isEmpty && landings.isEmpty {
                for chunk in lyric {
                    let n = chunk.syllableCount > 0
                        ? chunk.syllableCount
                        : LineSyllableCounter.syllableCount(forLine: chunk.text)
                    let overlap = RemindsMeOfScorer.overlapScore(candidate: chunk.text, queryLines: [line])
                    let same = RemindsMeOfScorer.normalizedLine(chunk.text) == RemindsMeOfScorer.normalizedLine(line)
                    if same || (overlap > 0 && abs(n - syllables) <= 2) {
                        take(chunk)
                    }
                    if picked.count >= limit { return picked }
                }
            }
        }

        for chunk in persona {
            take(chunk)
            if picked.count >= limit { break }
        }
        return picked
    }

    nonisolated static func makeChunk(kind: ArtistBrainChunkKind, text: String) -> ArtistBrainChunk {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return ArtistBrainChunk(
            kind: kind,
            text: trimmed,
            wrapFamily: wrapFamily(of: trimmed),
            endRhyme: endWord(of: trimmed),
            syllableCount: LineSyllableCounter.syllableCount(forLine: trimmed)
        )
    }
}

enum ArtistBrainPrompt {
    static func injection(
        brain: ArtistBrain,
        noteText: String,
        noteAxes: SignalAxes?,
        filters: ModelYouVerseFilters = .init()
    ) -> String {
        var lines: [String] = []
        if brain.artistName.isEmpty && !brain.hasConfirmedBrain {
            lines.append(brain.emptyBrainCopy)
            return lines.joined(separator: "\n")
        }
        if !brain.artistName.isEmpty {
            lines.append("Artist: \(brain.artistName). Write as this artist, not as Gunna / Young Thug / Lil Baby house wrap.")
        }
        let songs = brain.includedSongs.prefix(24).map(\.title)
        if !brain.lyricBars.isEmpty {
            lines.append("Confirmed catalog (\(brain.lyricBars.count) of their bars on device). Do not paste other artists' full lyrics.")
        } else if !songs.isEmpty {
            lines.append("Confirmed catalog (titles only — bars not ingested yet): \(songs.joined(separator: ", ")).")
        }
        if filters.effectiveUsePeople {
            lines.append("Who they're talking to: \(brain.talkingTo.promptLine)")
        } else {
            lines.append("Who they're talking to: the street — not a person this verse.")
        }
        lines.append(contentsOf: filters.promptConstraintLines)
        if !brain.noLongerWriteLike.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("They don't write like this anymore — leave it out: \(brain.noLongerWriteLike)")
        }
        if !brain.leaveOut.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.append("Leave out: \(brain.leaveOut)")
        }
        let blocked = brain.neverUse
        if !blocked.isEmpty {
            lines.append("Never use: \(blocked.joined(separator: ", ")).")
        }
        let graph = ArtistBrainGraph.rebuild(from: brain)
        let punchSet = Set(graph.punchLabels)
        if filters.effectiveUseBottle, !graph.punchLabels.isEmpty {
            lines.append("Punch stays punch: \(graph.punchLabels.prefix(8).joined(separator: ", ")).")
        }
        let casual = filters.effectiveUseBottle
            ? graph.casualLabels
            : graph.casualLabels.filter { !punchSet.contains($0) }
        if !casual.isEmpty {
            lines.append("Casual furniture (do not promote to punch): \(casual.prefix(8).joined(separator: ", ")).")
        }
        let motifs = filters.effectiveUseBottle
            ? graph.motifLabels
            : graph.motifLabels.filter { !punchSet.contains($0) }
        if !motifs.isEmpty {
            lines.append("Motifs that keep coming back: \(motifs.prefix(8).joined(separator: ", ")).")
        }
        lines.append(brain.homeStance.promptLine)
        if let noteAxes {
            lines.append("This note pulls against catalog home stance: note is \(noteAxes.socialAction.rawValue) to \(noteAxes.audienceScope.rawValue), \(noteAxes.authorityPosture.rawValue) authority, exposure \(noteAxes.exposureRisk.rawValue). Keep the catalog stance unless the note clearly overrides it.")
        }
        let kept = brain.confirmedCards.filter { $0.status == .kept || $0.status == .edited }
        if filters.effectiveUsePeople, !kept.isEmpty {
            lines.append("Confirmed cards:")
            for card in kept.prefix(12) {
                let role = card.mentionRole == .punch ? "punch stays punch" : card.mentionRole.label.lowercased()
                lines.append("- \(card.title) (\(role)): \(card.body)")
            }
        }
        let retrieved = ArtistBrainRAG.retrieve(brain: brain, noteText: noteText, filters: filters)
        if !retrieved.isEmpty {
            lines.append("On-device RAG (wrap + end-rhyme, confirmed only):")
            for chunk in retrieved.prefix(8) {
                lines.append("• [\(chunk.kind.rawValue)] \(chunk.text)")
            }
        }
        if !brain.hasConfirmedBrain {
            lines.append(brain.emptyBrainCopy)
        }
        return lines.joined(separator: "\n")
    }
}
