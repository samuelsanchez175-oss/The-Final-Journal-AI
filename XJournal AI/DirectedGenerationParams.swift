//
// DirectedGenerationParams.swift
// Model G control surface: user prompt, highlight injection, style injection.
// Used by the "Suggest next lines" control surface before generation runs.
//

import Foundation

// MARK: - RhymeGroupID

/// Identifier for a rhyme group (matches RhymeHighlighterEngine.RhymeGroup.id).
typealias RhymeGroupID = UUID

// MARK: - TokenSpanStrength

/// Strength of a highlight anchor for prompt building. Mirrors RhymeHighlighterEngine.RhymeStrength for serialization.
enum TokenSpanStrength: String, Codable {
    case perfect
    case near
    case slant
}

// MARK: - TokenSpan

/// A single highlight anchor: word plus optional strength. Used for HIGHLIGHT_WORDS in the prompt.
struct TokenSpan: Codable, Equatable {
    let word: String
    /// Optional; for prompt building format as "word (strength)" when present.
    var strength: TokenSpanStrength?
}

// MARK: - RhymeGroupSummary

/// Serializable representation of a rhyme group for the Model G prompt (from Magnifier).
/// Used by prompt builder when resolving selectedRhymeGroupIDs via a lookup.
struct RhymeGroupSummary {
    let key: String
    let words: [String]
}

// MARK: - DirectedGenerationParams

/// Parameters from the Model G control surface (the page shown after user taps Model G).
/// All fields optional except lineCount/syllableTolerance; empty strings/sets use prompt defaults.
///
/// Precedence (never infer from narrative/draft):
/// - userPrompt: May be empty; fallback is defaultUserPromptWhenEmpty. No inference from narrative.
/// - selectedTones / selectedRhymeGroupIDs / highlightAnchors / mustUseTokens: Never inferred from narrative or draft.
///   If user did not select, these remain empty and prompt shows "—" or "none" for those sections.
struct DirectedGenerationParams {
    /// A) User direction. When empty, prompt builder uses "Continue the draft in the same vein."
    var userPrompt: String
    /// B) Selected rhyme groups by ID (from Magnifier). Resolved via rhyme group lookup when building prompt.
    var selectedRhymeGroupIDs: [RhymeGroupID]
    /// B) Resolved rhyme groups (key + words) so Core `generateFullVerse` can inject them without a lookup table.
    var selectedRhymeGroups: [RhymeGroupSummary]
    /// B) Highlight/anchor tokens from Magnifier (word + optional strength).
    var highlightAnchors: [TokenSpan]
    /// B) Words that must appear verbatim at least once in the output.
    var mustUseTokens: [String]
    /// Ohm word-recipe seed (one word). Empty = no recipe cook.
    var recipeSeed: String
    /// Semantic / homophone cage: one sound.
    var semanticSound: String
    /// Optional labeled meanings for `semanticSound`. Planner fills if empty.
    var semanticSenses: [String]
    /// Keyword cage (4–6 words, every bar touches one). Distinct from a single recipe seed.
    var keywordCage: [String]
    /// Copy the last 4 draft bars' syllable map (Ohm interpolation). Default on.
    var copyLastFourRhythm: Bool
    /// Optional pasted 4-bar pocket (Fergie → Kreayshawn slot). Used if last-4 is off or draft is short.
    var pastedFlowText: String
    /// Gunna wrap preset. Off = Phase 0 fields only, no BarClock prompt block.
    var gunnaWrap: Bool
    var wrapPocket: WrapPocket
    var wrapBpmSource: WrapBpmSource
    var wrapBpmCustom: Int?
    /// 4 = one cycle, 16 = four cycles.
    var targetBarCount: Int
    var punchGrammar: PunchGrammar
    /// Ad-lib "yeah" may mark beat 4 (metronome click, not a bar).
    var adlibOnFour: Bool
    /// First letters of bars spell this word. Empty = off.
    var acrosticWord: String
    /// F2: 16 is a hero's journey instead of eight punch couplets.
    var storyArc: Bool
    /// B7: verse describes its own cadence, or teaches inside the bars.
    var lyricalPainting: Bool
    /// F4: after the end-rhyme hold, switch rime AND cadence on purpose.
    var breakTheRun: Bool
    /// A7: stresses first, SuperGunna nouns second (fills copy-flow map when present).
    var scatFirst: Bool
    /// B2: punch does not have to cash every name. Default on for Gunna.
    var setupOnlyRefs: Bool
    /// C) Topic selectors chosen.
    var selectedTopics: [String]
    /// C) Tone selectors chosen.
    var selectedTones: [EmotionalTone]
    /// C) World-building word bank (imagery: places, textures, props).
    var worldBuildingWords: [String]
    /// Number of lines to generate (e.g. 2 or 4).
    var lineCount: Int
    /// Syllable tolerance ± per line.
    var syllableTolerance: Int
    /// Min lines with strong end-rhyme. Default derived as max(1, lineCount/2).
    var minEndRhymeLines: Int
    /// Model G Core style override (ColdTrap, FloatyTrap, etc.). nil = auto-detect.
    var styleOverride: StyleProfile?
    /// Model You per-verse retrieve filters. Ignored on Model G.
    var youFilters: ModelYouVerseFilters
    /// Vault tones chosen on Suggest next lines. The prompt uses these names.
    var corpusTones: [CorpusTone]
    /// Recording from Freestyle match. Analysis is not run.
    /// TODO(freestyle-match): BeatAnalyzer plus the transcription/rhythm path should
    /// read this file and set syllables per bar, pocket, and end sounds.
    /// Do not invent those numbers from the path alone.
    var freestyleMatchAudioPath: String?

    /// When userPrompt is empty, this fallback is used. No silent inference of direction from narrative.
    static let defaultUserPromptWhenEmpty = "Continue the draft in the same vein."

    /// Direction for Suggest next lines. The sheet does not ask. An empty note stays on the neutral line.
    static func directionFromOpenNote(noteText: String, transcript: String?) -> String {
        let note = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
        let spoken = (transcript ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if note.isEmpty && spoken.isEmpty {
            return defaultUserPromptWhenEmpty
        }
        var parts = ["Continue the open note in the same vein."]
        if !note.isEmpty {
            parts.append("Written:\n\(clip(note, limit: 2000))")
        }
        if !spoken.isEmpty {
            parts.append("Spoken on the attached audio:\n\(clip(spoken, limit: 2000))")
        }
        return parts.joined(separator: "\n\n")
    }

    private static func clip(_ text: String, limit: Int) -> String {
        guard text.count > limit else { return text }
        return String(text.prefix(limit)) + "…"
    }
    static let emptyPlaceholder = "—"

    /// Spark mode: keep the wrap/pocket, swap the objects.
    static func samePocketNewNouns() -> DirectedGenerationParams {
        DirectedGenerationParams(
            userPrompt: "Keep this pocket. Swap the nouns. Same wrap, new objects.",
            copyLastFourRhythm: true,
            gunnaWrap: true,
            scatFirst: true
        )
    }

    init(
        userPrompt: String = "",
        selectedRhymeGroupIDs: [RhymeGroupID] = [],
        selectedRhymeGroups: [RhymeGroupSummary] = [],
        highlightAnchors: [TokenSpan] = [],
        mustUseTokens: [String] = [],
        recipeSeed: String = "",
        semanticSound: String = "",
        semanticSenses: [String] = [],
        keywordCage: [String] = [],
        copyLastFourRhythm: Bool = true,
        pastedFlowText: String = "",
        gunnaWrap: Bool = true,
        wrapPocket: WrapPocket = .onTop,
        wrapBpmSource: WrapBpmSource = .note,
        wrapBpmCustom: Int? = nil,
        targetBarCount: Int = 16,
        punchGrammar: PunchGrammar = .couplet,
        adlibOnFour: Bool = false,
        acrosticWord: String = "",
        storyArc: Bool = false,
        lyricalPainting: Bool = false,
        breakTheRun: Bool = false,
        scatFirst: Bool = true,
        setupOnlyRefs: Bool = true,
        selectedTopics: [String] = [],
        selectedTones: [EmotionalTone] = [],
        worldBuildingWords: [String] = [],
        lineCount: Int = 4,
        syllableTolerance: Int = 2,
        minEndRhymeLines: Int? = nil,
        styleOverride: StyleProfile? = nil,
        youFilters: ModelYouVerseFilters = .init(),
        corpusTones: [CorpusTone] = [],
        freestyleMatchAudioPath: String? = nil
    ) {
        self.userPrompt = userPrompt
        self.selectedRhymeGroupIDs = selectedRhymeGroupIDs
        self.selectedRhymeGroups = selectedRhymeGroups
        self.highlightAnchors = highlightAnchors
        self.mustUseTokens = mustUseTokens
        self.recipeSeed = recipeSeed
        self.semanticSound = semanticSound
        self.semanticSenses = semanticSenses
        self.keywordCage = keywordCage
        self.copyLastFourRhythm = copyLastFourRhythm
        self.pastedFlowText = pastedFlowText
        self.gunnaWrap = gunnaWrap
        self.wrapPocket = wrapPocket
        self.wrapBpmSource = wrapBpmSource
        self.wrapBpmCustom = wrapBpmCustom
        self.punchGrammar = punchGrammar
        self.adlibOnFour = adlibOnFour
        self.acrosticWord = acrosticWord
        self.storyArc = storyArc
        self.lyricalPainting = lyricalPainting
        self.breakTheRun = breakTheRun
        self.scatFirst = scatFirst
        self.setupOnlyRefs = setupOnlyRefs
        self.targetBarCount = storyArc ? 16 : ((targetBarCount == 4) ? 4 : 16)
        self.selectedTopics = selectedTopics
        if selectedTones.isEmpty, !corpusTones.isEmpty {
            self.selectedTones = CorpusTone.emotionalTones(from: corpusTones)
        } else {
            self.selectedTones = selectedTones
        }
        self.worldBuildingWords = worldBuildingWords
        self.lineCount = lineCount
        self.syllableTolerance = syllableTolerance
        self.minEndRhymeLines = minEndRhymeLines ?? max(1, lineCount / 2)
        self.styleOverride = styleOverride
        self.youFilters = youFilters
        self.corpusTones = corpusTones
        self.freestyleMatchAudioPath = freestyleMatchAudioPath
    }

    /// Names that go in the generation prompt. Corpus tones win over the mapped EmotionalTone list.
    var promptToneNames: [String] {
        if !corpusTones.isEmpty { return corpusTones.map(\.rawValue) }
        return selectedTones.map(\.rawValue)
    }

    /// Recipe seed: explicit field, else a single must-use token is the seed (not a cage).
    var resolvedRecipeSeed: String {
        let seed = recipeSeed.trimmingCharacters(in: .whitespacesAndNewlines)
        if !seed.isEmpty { return seed }
        if mustUseTokens.count == 1 {
            return mustUseTokens[0].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }

    /// Cage sound: explicit field, else the recipe seed.
    var resolvedSemanticSound: String {
        let sound = semanticSound.trimmingCharacters(in: .whitespacesAndNewlines)
        if !sound.isEmpty { return sound }
        return resolvedRecipeSeed
    }

    /// Keyword cage only when 4–6 words (Ohm drill). One word is a seed; 2–3 stay must-use.
    var resolvedKeywordCage: [String] {
        if !keywordCage.isEmpty { return keywordCage }
        let n = mustUseTokens.count
        if (4...6).contains(n) { return mustUseTokens }
        return []
    }

    /// BPM fed to BarClock when wrap is on. `noteBPM` is the entry's stored tempo.
    func resolvedWrapBPM(noteBPM: Int?) -> Int? {
        switch wrapBpmSource {
        case .wrap92: return 92
        case .custom: return wrapBpmCustom ?? noteBPM ?? 92
        case .note: return noteBPM
        }
    }

    /// Verbatim must-use when it is not acting as seed or keyword cage.
    var resolvedMustUseVerbatim: [String] {
        if !resolvedKeywordCage.isEmpty { return [] }
        if mustUseTokens.count == 1 && recipeSeed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return []
        }
        return mustUseTokens
    }

    /// Letters only, uppercased. Empty means the acrostic chip is off.
    var resolvedAcrostic: String {
        String(acrosticWord.uppercased().filter(\.isLetter))
    }

    /// Ohm F2 journey line. Replaces SocialActionArc when `storyArc` is on.
    static let storyArcPrompt =
        "STORY ARC: comfort zone → call to leave → cross the line → climax → earn the treasure → return changed → don't recognize home. Punches still land late. One journey across the 16, not eight isolated couplets."

    /// One prompt flag per optional chip. Empty/off chips are omitted.
    func schemeChipBlock() -> String {
        var lines: [String] = []
        let word = resolvedAcrostic
        if !word.isEmpty {
            lines.append("ACROSTIC: first letter of each bar, in order, spells \(word). After the word is spelled, later bars may start normally. Do not pad to a 16-letter word.")
        }
        if storyArc {
            lines.append(Self.storyArcPrompt)
        }
        if lyricalPainting {
            lines.append("DESCRIBE THE FLOW: some bars describe the cadence itself, or teach a how-to inside the verse. Not five boasts that you rap well.")
        }
        if breakTheRun {
            lines.append("BREAK THE RUN: around every 3–4 bars, switch the ending sound AND the cadence on purpose (new pocket, not just a new noun). Do not hold one end sound for the full lines-per-rhyme count.")
        }
        if scatFirst {
            lines.append("RHYTHM FIRST: place the stresses first (yeah/uh on beats 3–4), then drop nouns into those slots. If a COPY-FLOW map is present, fill that map — do not invent a new rhythm.")
        }
        if setupOnlyRefs {
            lines.append("SETUP-ONLY REFS: a name or brand in the setup may stay in the setup. The punch does not have to cash every reference.")
        }
        guard !lines.isEmpty else { return "" }
        return "\n" + lines.joined(separator: "\n") + "\n"
    }
}

// MARK: - DirectedGenerationPromptBuilder

/// Builds Model G v2 system and user prompts with clean empty-state handling.
enum DirectedGenerationPromptBuilder {

    private static let systemPromptTemplate = """
You are Model G. You generate continuation lines for a rap draft using a dedicated control surface shown AFTER the user selects Model G.

That post-selection page provides three inputs:
A) USER PROMPT (direction)
B) HIGHLIGHT INJECTION (selected word/rhyme groups from the Magnifier)
C) STYLE INJECTION (topic/tone/world-building word selectors)

Treat those three inputs as first-class constraints. If any are present, they override generic defaults.

Goals (in order):
1) Continuity: Stay consistent with the existing draft unless the USER PROMPT explicitly redirects.
2) Control-surface obedience:
   - USER PROMPT defines the "what."
   - HIGHLIGHT INJECTION defines the "sound" (rhyme families, phonetics, anchor words).
   - STYLE INJECTION defines the "feel and imagery" (tone, topics, world-building lexicon).
3) Naturalness: Do not force awkward phrasing to satisfy constraints; prefer near-rhyme over cringe.
4) Non-repetition: Never copy existing lines; avoid near-duplicate phrasing.
5) Output discipline: Output ONLY the generated lines, nothing else.

Hard rules:
- Output exactly {LINE_COUNT} lines.
- No headings, labels, bullets, or explanations.
- Keep profanity/intensity consistent with the draft (do not escalate).
- Do not introduce new proper nouns/brands unless present in the draft or explicitly selected in STYLE INJECTION.

Constraint handling:
- If HIGHLIGHT INJECTION includes "must-use" tokens, include them verbatim at least once across the output.
- If HIGHLIGHT INJECTION includes rhyme groups, prioritize end-rhyme alignment on at least {MIN_END_RHYME_LINES} lines.
- If STYLE INJECTION includes selected tones, bias diction, imagery, and pacing to match.
- If STYLE INJECTION includes world-building words, weave them in as concrete imagery (places, textures, props), not as a list.

If constraints conflict, follow this priority:
USER PROMPT > HIGHLIGHT INJECTION > STYLE INJECTION > Draft continuity.
"""

    private static let userPromptTemplate = """
CONTEXT (existing draft):
\"\"\"
{FULL_TEXT}
\"\"\"

MODEL G CONTROL SURFACE (AFTER SELECT):
1) USER PROMPT (direction — required):
{USER_PROMPT}

2) HIGHLIGHT INJECTION (from Magnifier — optional):
- Selected rhyme groups: {SELECTED_RHYME_GROUPS}
- Selected highlight words/anchors: {HIGHLIGHT_WORDS}
- Must-use words (if any): {MUST_USE_WORDS}

3) STYLE INJECTION (topic/tone/world-building — optional):
- Topic selectors chosen: {SELECTED_TOPICS}
- Tone selectors chosen: {SELECTED_TONES}
- World-building word bank chosen: {WORLD_BUILDING_WORDS}

EMOTIONAL SPINE (every bar must reinforce - no message betrayal):
{EMOTIONAL_SPINE}

CADENCE TARGETS:
- Lines to generate: {LINE_COUNT}
- Min lines with strong end-rhyme: {MIN_END_RHYME_LINES}
- Syllable target per line: {SYLLABLE_TARGET} ± {SYLLABLE_TOLERANCE}
- Reference last lines for cadence: {LAST_N_LINES}

OUTPUT RULES:
- Output only the new lines
- Exactly {LINE_COUNT} lines
- No extra text
"""

    /// Max characters for FULL_TEXT to avoid token overflow; nil = no truncation.
    static var fullTextMaxLength: Int? = 12_000

    static func buildSystemPrompt(params: DirectedGenerationParams) -> String {
        var s = systemPromptTemplate
        s = s.replacingOccurrences(of: "{LINE_COUNT}", with: "\(params.lineCount)")
        s = s.replacingOccurrences(of: "{MIN_END_RHYME_LINES}", with: "\(params.minEndRhymeLines)")
        return s
    }

    /// Build user prompt. "Selected" sections (tones, rhyme groups, highlights, must-use) use only params.
    /// Never infer or fill selectedTones/selectedRhymeGroupIDs from narrative.detectedTones or draft.
    /// - Parameter rhymeGroupsByID: Lookup to resolve selectedRhymeGroupIDs to key+words for prompt text.
    /// - Parameter intent: Emotional spine for alignment (every bar must reinforce).
    static func buildUserPrompt(
        params: DirectedGenerationParams,
        metrics: RapMetrics,
        rhymeGroupsByID: [RhymeGroupID: RhymeGroupSummary] = [:],
        intent: GenerationIntent
    ) -> String {
        let userPrompt = params.userPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty ? DirectedGenerationParams.defaultUserPromptWhenEmpty : params.userPrompt

        var fullText = metrics.fullText
        if let maxLen = fullTextMaxLength, fullText.count > maxLen {
            fullText = String(fullText.suffix(maxLen))
            if let firstNewline = fullText.firstIndex(of: "\n") {
                fullText = "…" + String(fullText[firstNewline...])
            } else {
                fullText = "…" + fullText
            }
        }

        let lastNLines = metrics.lastNLines.isEmpty
            ? DirectedGenerationParams.emptyPlaceholder
            : metrics.lastNLines.joined(separator: "\n")

        let syllableTarget = metrics.syllableTarget
            ?? Int(metrics.cadence.averageSyllables.rounded())
        let syllableTargetStr = "\(syllableTarget)"

        let selectedSummaries = params.selectedRhymeGroupIDs.compactMap { rhymeGroupsByID[$0] }
        let selectedRhymeGroupsStr = formatRhymeGroups(selectedSummaries)
        let highlightWordsStr = formatHighlightAnchors(params.highlightAnchors)
        let mustUseWordsStr = params.mustUseTokens.isEmpty ? DirectedGenerationParams.emptyPlaceholder : params.mustUseTokens.joined(separator: ", ")
        let selectedTopicsStr = params.selectedTopics.isEmpty ? DirectedGenerationParams.emptyPlaceholder : params.selectedTopics.joined(separator: ", ")
        let selectedTonesStr = params.promptToneNames.isEmpty ? DirectedGenerationParams.emptyPlaceholder : params.promptToneNames.joined(separator: ", ")
        let worldBuildingStr = params.worldBuildingWords.isEmpty ? DirectedGenerationParams.emptyPlaceholder : params.worldBuildingWords.joined(separator: ", ")

        var s = userPromptTemplate
        s = s.replacingOccurrences(of: "{FULL_TEXT}", with: fullText)
        s = s.replacingOccurrences(of: "{USER_PROMPT}", with: userPrompt)
        s = s.replacingOccurrences(of: "{SELECTED_RHYME_GROUPS}", with: selectedRhymeGroupsStr)
        s = s.replacingOccurrences(of: "{HIGHLIGHT_WORDS}", with: highlightWordsStr)
        s = s.replacingOccurrences(of: "{MUST_USE_WORDS}", with: mustUseWordsStr)
        s = s.replacingOccurrences(of: "{SELECTED_TOPICS}", with: selectedTopicsStr)
        s = s.replacingOccurrences(of: "{SELECTED_TONES}", with: selectedTonesStr)
        s = s.replacingOccurrences(of: "{WORLD_BUILDING_WORDS}", with: worldBuildingStr)
        s = s.replacingOccurrences(of: "{LINE_COUNT}", with: "\(params.lineCount)")
        s = s.replacingOccurrences(of: "{MIN_END_RHYME_LINES}", with: "\(params.minEndRhymeLines)")
        s = s.replacingOccurrences(of: "{SYLLABLE_TARGET}", with: syllableTargetStr)
        s = s.replacingOccurrences(of: "{SYLLABLE_TOLERANCE}", with: "\(params.syllableTolerance)")
        s = s.replacingOccurrences(of: "{LAST_N_LINES}", with: lastNLines)
        s = s.replacingOccurrences(of: "{EMOTIONAL_SPINE}", with: intent.promptFragment)
        return s
    }

    private static func formatRhymeGroups(_ groups: [RhymeGroupSummary]) -> String {
        if groups.isEmpty { return DirectedGenerationParams.emptyPlaceholder }
        return groups.map { "\($0.key): \($0.words.joined(separator: ", "))" }.joined(separator: "; ")
    }

    private static func formatHighlightAnchors(_ anchors: [TokenSpan]) -> String {
        if anchors.isEmpty { return DirectedGenerationParams.emptyPlaceholder }
        return anchors.map { anchor in
            guard let strength = anchor.strength else { return anchor.word }
            return "\(anchor.word) (\(strength.rawValue))"
        }.joined(separator: ", ")
    }
}
