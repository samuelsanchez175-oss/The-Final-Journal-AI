//
// DirectedGenerationParams.swift
// Model G control surface: user prompt, highlight injection, style injection.
// Used when user selects "Suggest Next Lines with Model G" and the post-select page is shown.
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
    /// B) Highlight/anchor tokens from Magnifier (word + optional strength).
    var highlightAnchors: [TokenSpan]
    /// B) Words that must appear verbatim at least once in the output.
    var mustUseTokens: [String]
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

    /// When userPrompt is empty, this fallback is used. No silent inference of direction from narrative.
    static let defaultUserPromptWhenEmpty = "Continue the draft in the same vein."
    static let emptyPlaceholder = "—"

    init(
        userPrompt: String = "",
        selectedRhymeGroupIDs: [RhymeGroupID] = [],
        highlightAnchors: [TokenSpan] = [],
        mustUseTokens: [String] = [],
        selectedTopics: [String] = [],
        selectedTones: [EmotionalTone] = [],
        worldBuildingWords: [String] = [],
        lineCount: Int = 4,
        syllableTolerance: Int = 2,
        minEndRhymeLines: Int? = nil,
        styleOverride: StyleProfile? = nil
    ) {
        self.userPrompt = userPrompt
        self.selectedRhymeGroupIDs = selectedRhymeGroupIDs
        self.highlightAnchors = highlightAnchors
        self.mustUseTokens = mustUseTokens
        self.selectedTopics = selectedTopics
        self.selectedTones = selectedTones
        self.worldBuildingWords = worldBuildingWords
        self.lineCount = lineCount
        self.syllableTolerance = syllableTolerance
        self.minEndRhymeLines = minEndRhymeLines ?? max(1, lineCount / 2)
        self.styleOverride = styleOverride
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
        let selectedTonesStr = params.selectedTones.isEmpty ? DirectedGenerationParams.emptyPlaceholder : params.selectedTones.map(\.rawValue).joined(separator: ", ")
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
