# Rap Suggestions Foundations Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the pure, test-first building blocks the Rap Suggestions redesign needs — a stress-emphasis service, a phrase-cascade service, and the deck/generation model — with zero UI so each is unit-tested in isolation.

**Architecture:** Three self-contained units in the app target (`XJournal_AI`), each pure/deterministic and injectable for tests. `StressMap` turns a bar into stressed/unstressed syllable spans (the "Stack" ③ view). `CascadeFormatter` turns a bar into indented breath-chunks (the large-text fallback ①). `GenerationDeck` is the pure list logic (insert-newest-first, cap-10) behind the engine's new `generations` state. The SwiftUI assembly that consumes these lives in the companion plan `2026-06-01-rap-suggestions-screen-rebuild.md`.

**Tech Stack:** Swift, Swift Testing (`import Testing` / `@Test` / `#expect`), `@testable import XJournal_AI`. Reuses `FJCMUDICTStore` (CMU phonemes w/ stress digits) and `Syllabifier` (vowel-group counts).

**Spec:** `docs/superpowers/specs/2026-06-01-rap-suggestions-screen-redesign-design.md` (§3.7, §3.6).

---

## File Structure

| File | Responsibility |
|------|----------------|
| Create `XJournal AI/StressMap.swift` | Line → `[SyllableSpan]` (text + isStressed), tiling the whole line so spans reassemble exactly. Pure; phoneme dict injectable. |
| Create `XJournal AI/CascadeFormatter.swift` | Line → `[CascadeChunk]` (text + indentLevel) at breath/phrase boundaries. Pure. |
| Create `XJournal AI/Generation.swift` | `Generation` model + `GenerationDeck` pure insert/cap logic. |
| Create `The Final Journal AITests/StressMapTests.swift` | Reassembly invariant + stress placement (injected fixture dict). |
| Create `The Final Journal AITests/CascadeFormatterTests.swift` | Chunk sizing, comma breaks, reassembly. |
| Create `The Final Journal AITests/GenerationDeckTests.swift` | Insert-at-front, cap-at-10, oldest dropped. |

**New app files auto-compile** via the synchronized `XJournal AI/` group (per project memory — no manual target add). The `The Final Journal AITests/` folder is also a synchronized root group, so new test files auto-join the test target too (confirmed). 

**Status (2026-06-01): all 3 tasks built, tested green, and committed.** Task 1's `StressMap` was implemented to **reuse `SyllableEngine.syllables` + `RapSlangPhonemes ?? CMU`** (the same sources as `StressMapBuilder`) rather than a standalone CMU heuristic — the committed `XJournal AI/StressMap.swift` is the source of truth; the code block below is the earlier standalone draft.

**Test command** (Swift Testing via xcodebuild; build out-of-iCloud + no signing, per project memory). **Must use the `XJournal AI` scheme** — the test files `@testable import XJournal_AI`; the `The Final Journal AI` scheme builds module `The_Final_Journal_AI` and fails (compile: `cannot find type`; link: `Undefined symbol: XJournal_AI.*`):

```bash
xcodebuild test \
  -project "XJournal AI.xcodeproj" \
  -scheme "XJournal AI" \
  -destination 'platform=iOS Simulator,id=<booted-sim-UDID>' \
  -derivedDataPath /tmp/xjai-dd \
  CODE_SIGNING_ALLOWED=NO \
  -only-testing:"The Final Journal AITests/StressMapTests"
```

Get a booted sim UDID with `xcrun simctl list devices booted`. The harness gotcha: `… ; echo "EXIT=$?"` reports the echo's exit (0) — grep the log for `** TEST SUCCEEDED/FAILED **` and the appended `EXIT=`. Or run in Xcode (⌘U). **Verified green: all 11 cases.**

---

## Task 1: StressMap service (the ③ Stack view)

**Files:**
- Create: `XJournal AI/StressMap.swift`
- Test: `The Final Journal AITests/StressMapTests.swift`

- [ ] **Step 1: Write the failing tests**

```swift
// The Final Journal AITests/StressMapTests.swift
import Testing
@testable import XJournal_AI

struct StressMapTests {
    // Small injected CMU-style dict (phoneme + stress digit on vowels). No bundle dependency.
    let dict: [String: [String]] = [
        "bag": ["B", "AE1", "G"],
        "of": ["AH1", "V"],
        "presidents": ["P", "R", "EH1", "Z", "IH0", "D", "AH0", "N", "T", "S"],
    ]

    @Test func grapheme_splitter_splits_at_vowel_group_starts() {
        #expect(StressMap.syllableSubstrings("presidents") == ["pres", "id", "ents"])
        #expect(StressMap.syllableSubstrings("birkin") == ["birk", "in"])
        #expect(StressMap.syllableSubstrings("bag") == ["bag"])
    }

    @Test func spans_reassemble_to_the_original_line() {
        let line = "bag of presidents"
        let joined = StressMap.spans(for: line, phonemesByWord: dict).map(\.text).joined()
        #expect(joined == line)
    }

    @Test func primary_stress_syllable_is_marked() {
        let spans = StressMap.spans(for: "presidents", phonemesByWord: dict)
        #expect(spans == [
            SyllableSpan(text: "pres", isStressed: true),
            SyllableSpan(text: "id", isStressed: false),
            SyllableSpan(text: "ents", isStressed: false),
        ])
    }

    @Test func function_words_are_never_stressed() {
        let spans = StressMap.spans(for: "of", phonemesByWord: dict)
        #expect(spans.allSatisfy { !$0.isStressed })
    }

    @Test func content_monosyllable_is_stressed() {
        let spans = StressMap.spans(for: "bag", phonemesByWord: dict)
        #expect(spans == [SyllableSpan(text: "bag", isStressed: true)])
    }

    @Test func out_of_dictionary_multisyllable_stresses_first() {
        // "birkin" not in dict → fallback: first syllable stressed.
        let spans = StressMap.spans(for: "birkin", phonemesByWord: dict)
        #expect(spans == [
            SyllableSpan(text: "birk", isStressed: true),
            SyllableSpan(text: "in", isStressed: false),
        ])
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run the test command above with `-only-testing:"The Final Journal AITests/StressMapTests"`.
Expected: FAIL — `StressMap` / `SyllableSpan` not found (compile error).

- [ ] **Step 3: Implement `StressMap`**

```swift
// XJournal AI/StressMap.swift
import Foundation

/// One contiguous run of a lyric line, flagged stressed or not. Spans tile the whole
/// line (words AND separators) so `spans(for:).map(\.text).joined() == line`.
struct SyllableSpan: Equatable {
    let text: String
    let isStressed: Bool
}

/// Turns a bar into stressed/unstressed syllable spans for the "Stack" stress-emphasis view.
/// Pure + deterministic; the phoneme dictionary is injectable for tests.
enum StressMap {
    private static let vowels = Set("aeiouyAEIOUY")

    /// Words that never carry emphasis (kept light).
    private static let functionWords: Set<String> = [
        "the","a","an","and","but","or","of","to","in","on","at","for","with","as","by",
        "i","i'm","im","you","he","she","it","we","they","is","are","was","were","be",
        "that","that's","this","my","your","our","no","so","up"
    ]

    /// Split a single word into syllable substrings at the start of each vowel group.
    /// e.g. "presidents" -> ["pres","id","ents"], "birkin" -> ["birk","in"], "bag" -> ["bag"].
    static func syllableSubstrings(_ word: String) -> [String] {
        let chars = Array(word)
        guard !chars.isEmpty else { return [] }
        func isVowel(_ c: Character) -> Bool { vowels.contains(c) }
        // Index where each vowel GROUP starts (a vowel not preceded by a vowel).
        var vowelStarts: [Int] = []
        for i in chars.indices {
            if isVowel(chars[i]) && (i == 0 || !isVowel(chars[i - 1])) {
                vowelStarts.append(i)
            }
        }
        guard vowelStarts.count > 1 else { return [word] }
        // Boundaries = start of each vowel group after the first.
        let boundaries = Array(vowelStarts.dropFirst())
        var pieces: [String] = []
        var start = 0
        for b in boundaries {
            pieces.append(String(chars[start..<b]))
            start = b
        }
        pieces.append(String(chars[start..<chars.count]))
        return pieces
    }

    /// Index of the primary-stressed syllable for `word`, or nil if not derivable from the dict.
    /// Primary stress = the vowel phoneme whose trailing digit is "1".
    private static func primaryStressSyllable(_ word: String, dict: [String: [String]]) -> Int? {
        guard let phonemes = dict[word.lowercased()] else { return nil }
        var syllableIndex = -1
        for p in phonemes {
            if let last = p.last, last.isNumber {        // vowel phoneme carries a stress digit
                syllableIndex += 1
                if last == "1" { return syllableIndex }
            }
        }
        return nil
    }

    /// Whole-line spans. Non-word separators (spaces, punctuation) are emitted as unstressed
    /// spans so the line reassembles exactly.
    static func spans(for line: String,
                      phonemesByWord dict: [String: [String]] = FJCMUDICTStore.shared.phonemesByWord) -> [SyllableSpan] {
        guard !line.isEmpty else { return [] }
        var result: [SyllableSpan] = []
        var token = ""
        func isWordChar(_ c: Character) -> Bool { c.isLetter || c == "'" }

        func flushWord() {
            guard !token.isEmpty else { return }
            defer { token = "" }
            // Function words: all light.
            if functionWords.contains(token.lowercased()) {
                result.append(SyllableSpan(text: token, isStressed: false))
                return
            }
            let pieces = syllableSubstrings(token)
            if pieces.count <= 1 {
                // Monosyllabic content word → stressed.
                result.append(SyllableSpan(text: token, isStressed: true))
                return
            }
            // Multisyllabic: dict stress if known, else fall back to syllable 0.
            let stressed = primaryStressSyllable(token, dict: dict) ?? 0
            let clamped = min(max(stressed, 0), pieces.count - 1)
            for (i, piece) in pieces.enumerated() {
                result.append(SyllableSpan(text: piece, isStressed: i == clamped))
            }
        }

        var separator = ""
        func flushSeparator() {
            guard !separator.isEmpty else { return }
            result.append(SyllableSpan(text: separator, isStressed: false))
            separator = ""
        }

        for c in line {
            if isWordChar(c) {
                flushSeparator()
                token.append(c)
            } else {
                flushWord()
                separator.append(c)
            }
        }
        flushWord()
        flushSeparator()
        return result
    }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run the same `-only-testing:"The Final Journal AITests/StressMapTests"` command.
Expected: PASS (6 tests).

- [ ] **Step 5: Commit**

```bash
git add "XJournal AI/StressMap.swift" "The Final Journal AITests/StressMapTests.swift"
git commit -m "feat: StressMap service for stress-emphasis Stack view

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 2: CascadeFormatter service (the ① large-text fallback)

**Files:**
- Create: `XJournal AI/CascadeFormatter.swift`
- Test: `The Final Journal AITests/CascadeFormatterTests.swift`

- [ ] **Step 1: Write the failing tests**

```swift
// The Final Journal AITests/CascadeFormatterTests.swift
import Testing
@testable import XJournal_AI

struct CascadeFormatterTests {
    @Test func short_line_is_a_single_chunk_at_indent_zero() {
        let chunks = CascadeFormatter.chunks(for: "Circle small big moves", maxSyllablesPerChunk: 6)
        #expect(chunks == [CascadeChunk(text: "Circle small big moves", indentLevel: 0)])
    }

    @Test func long_line_breaks_into_stepped_chunks() {
        let chunks = CascadeFormatter.chunks(for: "Birkin bag full of dead presidents that's what I'm haulin", maxSyllablesPerChunk: 4)
        #expect(chunks.count >= 2)
        // Indents step 0,1,2,... and the words are preserved in order.
        for (i, c) in chunks.enumerated() { #expect(c.indentLevel == i) }
        #expect(chunks.map(\.text).joined(separator: " ") == "Birkin bag full of dead presidents that's what I'm haulin")
    }

    @Test func a_comma_forces_a_break() {
        let chunks = CascadeFormatter.chunks(for: "money in, money out", maxSyllablesPerChunk: 20)
        #expect(chunks.count == 2)
        #expect(chunks[0].text == "money in,")
        #expect(chunks[1].text == "money out")
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run with `-only-testing:"The Final Journal AITests/CascadeFormatterTests"`.
Expected: FAIL — `CascadeFormatter` / `CascadeChunk` not found.

- [ ] **Step 3: Implement `CascadeFormatter`**

```swift
// XJournal AI/CascadeFormatter.swift
import Foundation

/// One breath/phrase chunk of a bar, with its step indentation (0,1,2,…).
struct CascadeChunk: Equatable {
    let text: String
    let indentLevel: Int
}

/// Breaks a bar into stepped breath-chunks for the multi-line (large Dynamic Type) reading layout.
/// Greedy: accumulate words until adding the next would exceed `maxSyllablesPerChunk`, or a word
/// ends in a comma (hard breath), then start a new, deeper-indented chunk. Pure + deterministic.
enum CascadeFormatter {
    static func chunks(for line: String, maxSyllablesPerChunk: Int = 5) -> [CascadeChunk] {
        let words = line.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        guard !words.isEmpty else { return [] }

        var chunks: [CascadeChunk] = []
        var current: [String] = []
        var currentSyllables = 0

        func flush() {
            guard !current.isEmpty else { return }
            chunks.append(CascadeChunk(text: current.joined(separator: " "), indentLevel: chunks.count))
            current = []
            currentSyllables = 0
        }

        for word in words {
            let syl = max(1, Syllabifier.syllableCount(word: word))
            if !current.isEmpty && currentSyllables + syl > maxSyllablesPerChunk {
                flush()
            }
            current.append(word)
            currentSyllables += syl
            if word.hasSuffix(",") {          // hard breath boundary
                flush()
            }
        }
        flush()
        return chunks
    }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run with `-only-testing:"The Final Journal AITests/CascadeFormatterTests"`.
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add "XJournal AI/CascadeFormatter.swift" "The Final Journal AITests/CascadeFormatterTests.swift"
git commit -m "feat: CascadeFormatter for large-text phrase-cascade layout

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Task 3: Generation model + deck logic

**Files:**
- Create: `XJournal AI/Generation.swift`
- Test: `The Final Journal AITests/GenerationDeckTests.swift`

- [ ] **Step 1: Write the failing tests**

```swift
// The Final Journal AITests/GenerationDeckTests.swift
import Testing
import Foundation
@testable import XJournal_AI

struct GenerationDeckTests {
    // Tag generations by createdAt so we avoid constructing RapSuggestion (whose
    // memberwise init has many non-defaulted optionals — a needless compile dependency here).
    private func gen(_ tag: Double) -> Generation {
        Generation(
            id: UUID(),
            suggestions: [],
            critic: nil,
            createdAt: Date(timeIntervalSince1970: tag),
            isFavorite: false,
            isFresh: true
        )
    }

    @Test func newest_is_inserted_at_the_front() {
        let deck = GenerationDeck.inserting(gen(2), into: [gen(1)])
        #expect(deck.first?.createdAt.timeIntervalSince1970 == 2)
        #expect(deck.last?.createdAt.timeIntervalSince1970 == 1)
    }

    @Test func deck_is_capped_and_drops_the_oldest() {
        var deck: [Generation] = []
        for i in 0..<12 { deck = GenerationDeck.inserting(gen(Double(i)), into: deck, cap: 10) }
        #expect(deck.count == 10)
        // Newest first; the two oldest (tags 0 and 1) were dropped.
        #expect(deck.first?.createdAt.timeIntervalSince1970 == 11)
        #expect(deck.contains { $0.createdAt.timeIntervalSince1970 == 0 } == false)
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run with `-only-testing:"The Final Journal AITests/GenerationDeckTests"`.
Expected: FAIL — `Generation` / `GenerationDeck` not found.

- [ ] **Step 3: Implement `Generation` + `GenerationDeck`**

```swift
// XJournal AI/Generation.swift
import Foundation

/// One generation (one tap of Generate) shown as one card in the deck.
struct Generation: Identifiable {
    let id: UUID
    let suggestions: [RapSuggestion]
    var critic: HumanCriticFeedback?      // per-card critic snapshot (spec §3.5)
    let createdAt: Date
    var isFavorite: Bool
    var isFresh: Bool                      // drives the freshness flash (spec §3.6)
}

/// Pure list logic for the session deck: newest at the front, capped.
enum GenerationDeck {
    static let defaultCap = 10

    static func inserting(_ new: Generation, into deck: [Generation], cap: Int = defaultCap) -> [Generation] {
        var d = deck
        d.insert(new, at: 0)               // index 0 = newest = front (spec §3.6)
        if d.count > cap { d = Array(d.prefix(cap)) }
        return d
    }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run with `-only-testing:"The Final Journal AITests/GenerationDeckTests"`.
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add "XJournal AI/Generation.swift" "The Final Journal AITests/GenerationDeckTests.swift"
git commit -m "feat: Generation model + deck insert/cap logic

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```

---

## Self-Review

- **Spec coverage:** §3.7 ③ stress → Task 1; §3.7 ① cascade → Task 2; §3.6 deck model (insert-newest, cap-10, freshness flag, per-card critic field) → Task 3. The engine *wiring* of `generations` and all SwiftUI (`LyricLineView`, `RapDeckView`, `GenerationCardView`, `RapIslandToolbar`, critic reorder, rhyme highlighting, freshness timer, Dynamic Type) is the companion plan `2026-06-01-rap-suggestions-screen-rebuild.md`.
- **Placeholder scan:** none — every step has full code and a runnable command.
- **Type consistency:** `SyllableSpan`, `CascadeChunk`, `Generation`, `GenerationDeck.inserting`, `StressMap.spans/.syllableSubstrings`, `CascadeFormatter.chunks` are used identically in tests and impl. `RapSuggestion(id:text:confidence:source:reasoning:themes:)` matches `RapSuggestionAPI.swift:98`. `HumanCriticFeedback` optional matches `HumanCriticFeedback.swift:25`.

**Done when:** all three test files pass; three commits landed; no UI changed yet.
