# Rap Suggestions Screen — Redesign (deck, island, no-wrap, stress, critic order)

**Date:** 2026-06-01
**Surface:** `XJournal AI/RapSuggestionView.swift` (the "Rap Suggestions" sheet) + a screen-local island toolbar.
**Status:** Design approved (visual brainstorm). Ready for implementation plan.
**Mode:** Advisory by default — Samuel codes in parallel; do not auto-edit code without "you build it."

---

## 1. Goal

The Model G generator produces strong rap verses. This redesign makes the results screen a better tool for **writing and performing**: bars read as single lines, generations stack into a swipeable **deck**, the editor's **rhyme highlighting** and a new **syllable "Stack"** view are available right here behind the editor's **dynamic-island** toolbar, and the **Critic** moves below the lyrics.

It also makes *this screen* correct under iOS **Dynamic Type**. The broader app-wide font pass is intentionally **out of scope** here and is logged in the Obsidian roadmap (Phase 4).

---

## 2. Decisions (locked in brainstorm)

| # | Decision | Choice |
|---|----------|--------|
| Architecture | Where the rhyme/flow controls live | **Floating dynamic-island toolbar at the bottom**, canonical to the editor |
| 1.a | Bars never wrap | **Shrink-to-fit** (`lineLimit(1)` + scaling font + `minimumScaleFactor` floor); horizontal scroll rejected (collides with deck swipe) |
| 1.b | "Eye" toggle | Highlights rhyme groups / inner rhymes on the visible card, reusing `RhymeHighlighterEngine` + the editor's exact style |
| 1.c | "Magnifying glass" | Toggles the rhyme-groups popover (reuse `RhymeGroupListView`) |
| 1.c (plan) | The dynamic island on this screen | **Screen-local island** that reuses the editor's look (constants, button styling, symbols, haptics), wired to this screen's 3 toggles — *not* a literal re-host of the editor's coupled toolbar |
| 2 | Critic order | **Critic moves below the lyrics**, per card |
| 3 | Deck of generations | **Newest-first, auto-land** at the front; swipe right for older; **freshness flash** (see §3.6); **session-lived**, cap ~10; blue swipe hint |
| 4 | "Stack" view | **③ Stress emphasis (in place)** — stressed syllables bold, rest faded; one line. Umbrella term: *scansion / cadence mapping* |
| 4 (a11y) | Large Dynamic Type | Bars **fall back to ① phrase-cascade** (multi-line) at large accessibility sizes — the cascade is the large-text reading mode |

---

## 3. Design

### 3.1 Screen architecture

`RapSuggestionView` body becomes a **deck** (`TabView`, `.page` style) of generation cards, with a **screen-local island** floating at the bottom. Today's `suggestionsList` (a single `ScrollView` with `HumanCriticSectionView` first, then cards — `RapSuggestionView.swift:326`) is replaced by the deck. The side-by-side V1/V2 parallel mode (`sideBySideView`, `:347`) is unaffected by this change and stays as-is for now.

```
NavigationView
└─ ZStack
   ├─ AtmosphereGlow (unchanged background)
   ├─ RapDeckView                      // paged TabView of generations
   │    └─ GenerationCardView (per generation)
   │         ├─ ScrollView
   │         │    ├─ LyricLineView × N   // lyrics FIRST
   │         │    └─ HumanCriticSectionView   // critic BELOW (item 2)
   │         └─ freshness-flash controller
   ├─ page dots + blue swipe hint (overlay, bottom-ish)
   └─ RapIslandToolbar (floating, bottom)   // 👁 Rhymes · 🔍 Groups · ☰ Stack
```

### 3.2 Item 1.a — bars on one line (Dynamic-Type-aware shrink-to-fit)

`SuggestionLineRow` (`RapSuggestionView.swift:1387`) today renders `Text(line).font(.body)` with no line limit, so it wraps. New behavior in `LyricLineView`:

- `.lineLimit(1)` + `.minimumScaleFactor(0.6)` (floor — never smaller than 60%).
- Font is a **scaling** font (semantic `.body` or `@ScaledMetric(relativeTo: .body)` size), so normal-range Dynamic Type still grows the text; shrink-to-fit only kicks in for over-long bars.
- **At large accessibility sizes** (`@Environment(\.dynamicTypeSize) >= .accessibility1`, tunable), the line **does not shrink** — it renders in **cascade mode** (§3.7) instead, because a shrunk line of huge text is unreadable.

### 3.3 Item 1.b / 1.c — rhyme highlighting on this screen

Reuse the existing, text-pure engine: `RhymeHighlighterEngine.computeAll(text:) async -> ([RhymeGroup], [Highlight])` (`ContentView.CCV.3.swift:188`). The screen computes highlights for the **visible card's** lyrics (debounced; cached per generation id).

- **Eye toggle (👁 Rhymes):** when on, each bar renders its rhyme groups in the editor's palette (`RhymeColorPalette`). Two rendering options for the implementation plan to choose:
  1. **Reuse `RhymeHighlightTextView`** (`ContentView.CCV.6.swift:10`, a `UIViewRepresentable`) in a non-editable configuration — guarantees identical look to the editor, at the cost of a `UITextView` per line.
  2. **Build an `AttributedString`** from `[Highlight]` and render with SwiftUI `Text` — lighter, must match palette/underline styling. *(Recommended starting point; falls back to option 1 if parity is hard.)*
- **Magnifying glass (🔍 Groups):** toggles a popover hosting `RhymeGroupListView(groups:currentText:)` (`ContentView.CCV.15.swift:15`), computed over the visible generation. Same component the editor uses.
- **Scope:** highlighting applies to all lyric lines on the visible card. Both toggles are **per-screen** state (persist across cards while the sheet is open).

### 3.4 Item 1.c — the screen-local island (feasibility plan)

The editor's island is in `ContentView.CCV.14.swift`: `ToolbarConstants` (`:19`, `private enum`, height **LOCKED at 64pt**) and `enhancedButton` (`:196`, `private func`) — both private and wired to editor-only state (`isRhymeOverlayVisible`, `showRhymeGroupsPopover`, `isEditorFocused`, auto-collapse timer, `currentText`). A literal re-host would drag that coupling onto this screen.

**Plan:** build `RapIslandToolbar` — a small, **self-contained** island view local to the suggestions surface that visually matches the editor (same pill geometry, blur, haptics, SF Symbols `eye`/`eye.fill`, `text.magnifyingglass`, plus a Stack glyph) wired to three bindings: `rhymeHighlightOn`, `showGroupsPopover`, `stackOn`. Per the "Momentum components stay concrete" guidance, **replicate the small constant set locally** rather than extracting the editor's `ToolbarConstants`/`enhancedButton` (extraction risks type-check timeouts and over-coupling). If the duplication proves clean, a later refactor can lift a shared `IslandToolbarStyle` — but that is **not** required for this work.

### 3.5 Item 2 — Critic below the lyrics, per card

`HumanCriticSectionView(feedback:isLoading:errorMessage:onRetry:)` (`HumanCriticSectionView.swift`) moves to render **after** the lyrics inside each `GenerationCardView`. Critic becomes **per-generation**: each `Generation` carries its own critic snapshot (taken when the generation is produced, refreshable). This replaces today's single screen-level critic binding that renders first (`RapSuggestionView.swift:329`). The legacy inline "Critic" / A&R blocks (`lineComparisonCritique` `:495`, `arCritiqueSection`) remain gated off when the human critic is active, as today.

### 3.6 Item 3 — the deck of generations

**Model.** Introduce an ordered, session-lived list of generations on `RapSuggestionEngine` (`RapSuggestionView.swift:1549`), alongside the existing `suggestions` / `previousSuggestions` / `lastBatchSuggestions` state:

```
struct Generation: Identifiable {
    let id: UUID
    let suggestions: [RapSuggestion]   // the verse(s) from this run
    var critic: HumanCriticFeedback?   // per-card critic snapshot (§3.5)
    let createdAt: Date
    var isFavorite: Bool
    var isFresh: Bool                  // drives the freshness flash (§ below)
}
@Published var generations: [Generation] = []   // index 0 = newest (front)
@Published var currentGenerationIndex: Int = 0
```

- On a successful generation: **insert at index 0**, set `currentGenerationIndex = 0`, `isFresh = true`. Cap at **10** (drop the oldest).
- Deck order left→right = **newest → oldest**; swipe right reveals older. Page dots + blue hint **"swipe → for previous generations"**.
- **Persistence:** session-only. Re-opening the note starts a fresh deck. Saving generations to the `Item` is **future work** (§6).
- If a generation yields **multiple** `RapSuggestion`s, the card stacks them within its scroll (above the single Critic for that generation).

**Preserved behavior (do not drop).** A card retains today's per-suggestion affordances from `suggestionCard`/`cardContent` (`RapSuggestionView.swift:412`): per-line like/dislike (`toggleLineFeedback`, the green/red `SuggestionLineRow` states), theme tags, quality indicators, the feedback form, "Tighten for authority," Model-G-moment markers, and favoriting. The redesign changes **layout and line rendering**, not these interactions — `LyricLineView` extends `SuggestionLineRow` rather than replacing its feedback semantics.

**Freshness flash.** When a card is `isFresh`:
- It auto-lands at the front and its lyric text renders **blue** (overriding the normal palette; stress/rhyme styling is suppressed while blue).
- A ~**4-second** timer starts on appear. `isFresh` clears on **whichever comes first**: the user **taps** the card, or the timer fires.
- On clear, animate a fade from blue → normal light/dark `.primary`, revealing stress (§3.7) and rhyme (§3.3) styling underneath.
- Implementation: timer is per-card, cancelled on tap and on disappear (`.task`/`Task` with cancellation; respect `reduceMotion` for the fade).

### 3.7 Item 4 — the "Stack" view (③ stress emphasis) + cascade fallback

Two related transforms on a bar, both driven by syllable/stress data:

**③ Stress emphasis (the Stack button, everyday look).** Stressed syllables render **bold + full-strength**, unstressed **faded** — one line, layers on top of shrink-to-fit. Needs a `StressMap` service:
- Stress pattern per word from `FJCMUDICTStore.phonemesByWord` (CMU vowel phonemes carry stress digits; primary stress = `1`).
- A **grapheme syllabifier** to split the *spelled* word into syllable ranges (today `Syllabifier.syllableCount(word:)` gives counts, not boundaries — `Syllabifier.swift:57`). Add a boundary-producing splitter (vowel-group heuristic).
- Map stressed syllable index → grapheme range; bold that range.
- **Fallback when alignment is uncertain:** bold the whole content word at its primary stress; leave function words (the/of/and/I'm…) faded. Never crash on out-of-dictionary words — fall back to "no emphasis" for that word.
- This is the **highest-effort piece**; isolate it as a pure, unit-testable service (input line → `[SyllableSpan(range, isStressed)]`).

**① Phrase cascade (the large-text accessibility fallback).** Break the bar at natural breath/phrase points (~3–5 syllable chunks at word boundaries, preferring commas & conjunctions; chunk sizing via `Syllabifier.syllableCount(line:)` `TasteScorer.swift:322`), step each chunk down-and-right. Triggered automatically at large Dynamic Type sizes (§3.2); also reachable as the multi-line reading layout. Pure function: line → `[CascadeChunk(text, indentLevel)]`.

The Stack toggle promotes to the island once working (it is included in `RapIslandToolbar` from the start, behind the same on/off state).

---

## 4. Components & interfaces (built for isolation)

| Unit | Responsibility | Depends on |
|------|----------------|------------|
| `RapDeckView` | Paged `TabView` of generations; page dots; blue hint; binds `currentGenerationIndex` | `GenerationCardView` |
| `GenerationCardView` | One generation: lyrics (scroll) then Critic; owns freshness-flash timer | `LyricLineView`, `HumanCriticSectionView` |
| `LyricLineView` | Renders one bar in the active mode: plain shrink-to-fit / stress-emphasis / cascade; applies rhyme highlight + freshness color | `StressMap`, `CascadeFormatter`, rhyme highlights |
| `RapIslandToolbar` | Floating island; 3 toggles (Rhymes/Groups/Stack); editor-matching style | local constants; bindings |
| `StressMap` (service) | line → `[SyllableSpan(range, isStressed)]` | `FJCMUDICTStore`, grapheme syllabifier |
| `CascadeFormatter` (service) | line → `[CascadeChunk(text, indent)]` | `Syllabifier` |
| `RapSuggestionEngine` (existing) | add `generations`, `currentGenerationIndex`, per-card critic; insert-newest-at-front + cap | existing generation flow |
| Reused as-is | `RhymeHighlighterEngine.computeAll`, `RhymeGroupListView`, `RhymeHighlightTextView` (option), `HumanCriticSectionView`, `Syllabifier`, `FJCMUDICTStore` | — |

Each service (`StressMap`, `CascadeFormatter`) is pure and testable without UI. Each view answers "what does it do / how do you use it / what does it depend on" in one line.

---

## 5. Accessibility / Dynamic Type (this screen only)

- Lyric font scales with Dynamic Type; shrink-to-fit has a 0.6 floor; large accessibility sizes route to cascade instead of shrinking.
- Island buttons keep accessibility labels matching the editor ("Show/Hide rhyme overlay", "Rhyme groups", + "Stack syllables").
- Freshness fade respects `reduceMotion`.
- **App-wide font scalability is OUT OF SCOPE** here — logged in `OB CLAUDE vault/XJournal AI - App/Improvement Roadmap — Phased Goals.md` (Phase 4: convert the Momentum ramp `MomentumDesignSystem.swift:60` + ~90 fixed `.system(size:)` sites; optional in-app text-size slider).

---

## 6. Out of scope / future

- App-wide Dynamic Type pass + optional in-app text-size slider (Obsidian roadmap, Phase 4).
- **② Syllable beat-grid** ("flow map") — deferred; needs the same grapheme-syllable splitter plus per-syllable chips.
- Persisting the generation deck to the `Item` across sessions.
- Changes to the parallel V1/V2 `sideBySideView`.

---

## 7. Risks & open implementation choices

1. **Stress→grapheme alignment (§3.7)** is the hard part. Mitigation: isolate `StressMap`, ship the graceful word-level fallback first, refine syllable boundaries later. Unit-test against a fixed word list.
2. **Rhyme rendering parity** — start with `AttributedString`; if it can't match the editor, switch to `RhymeHighlightTextView`. Watch performance (one highlighter pass per visible card, not per line).
3. **Island constant duplication** vs extraction — deliberately duplicate locally to avoid coupling/type-check risk (per memory). Revisit only if it gets unwieldy.
4. **Engine wiring** — `generations` must populate from both the standard and Model G generation paths without disturbing existing recall/ledger state. Verify `RapSuggestionView.swift:1549`+ flow.
5. **Two live Xcode projects** — new files auto-compile via synchronized groups; no manual target add. Build out-of-iCloud or with `CODE_SIGNING_ALLOWED=NO` to dodge the CodeSign "detritus" failure.

---

## 8. Testing notes

- `StressMap` and `CascadeFormatter`: pure unit tests (known lines → expected spans/chunks; out-of-dictionary words; punctuation).
- Deck: insert-newest-at-front, cap-at-10, freshness clears on tap and on 4s timeout (and cancels on disappear).
- Dynamic Type: snapshot at default and `.accessibility3` (cascade fallback engaged).
- Critic renders after lyrics for every card.
