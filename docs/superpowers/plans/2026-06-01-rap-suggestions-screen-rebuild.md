# Rap Suggestions Screen Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.
>
> **Note on verification:** these are SwiftUI view tasks. Unlike the foundations plan, most verification is **manual in the Simulator** (there's no snapshot-test harness in this project). Where logic is pure, it stays in the foundations plan and is unit-tested there. Expect to iterate view bodies in Xcode — the code here is the real structure and the tricky bits in full, not pixel-final layout.

**Goal:** Rebuild `RapSuggestionView` into a swipeable deck of generation cards with a floating editor-style island, single-line bars, rhyme highlighting, the Stack view, per-card Critic-below, and the freshness flash.

**Architecture:** A paged `TabView` (`RapDeckView`) of `GenerationCardView`s, fed by a new `@Published var generations` on `RapSuggestionEngine`. Each card renders `LyricLineView`s (consuming `StressMap`/`CascadeFormatter`/rhyme highlights) then `HumanCriticSectionView`. A self-contained `RapIslandToolbar` floats at the bottom and drives three screen-level toggles.

**Tech Stack:** SwiftUI, `@Environment(\.dynamicTypeSize)`, `RhymeHighlighterEngine` (`ContentView.CCV.3.swift:188`), `RhymeGroupListView` (`ContentView.CCV.15.swift:15`), `HumanCriticSectionView`.

**Depends on:** `2026-06-01-rap-suggestions-foundations.md` (Tasks 1–3 landed). **Spec:** `docs/superpowers/specs/2026-06-01-rap-suggestions-screen-redesign-design.md`.

---

## File Structure

| File | Responsibility |
|------|----------------|
| Modify `XJournal AI/RapSuggestionView.swift:1549`+ (`RapSuggestionEngine`) | Add `@Published var generations: [Generation]`, `currentGenerationIndex`; append via `GenerationDeck.inserting` on each successful generation; snapshot the critic per generation. |
| Modify `XJournal AI/RapSuggestionView.swift:108` (`body`) + `:326` (`suggestionsList`) | Replace the single list with `RapDeckView` + island overlay; remove the top-level `HumanCriticSectionView` (now per card). Leave `sideBySideView` (`:347`) untouched. |
| Create `XJournal AI/RapDeckView.swift` | Paged `TabView` over `generations`, page dots, blue swipe hint. |
| Create `XJournal AI/GenerationCardView.swift` | One card: lyrics (preserving existing per-suggestion affordances) then Critic; freshness-flash timer. |
| Create `XJournal AI/LyricLineView.swift` | One bar in the active mode (plain shrink-to-fit / stress / cascade) + rhyme highlight + freshness color. Supersedes `SuggestionLineRow` (`:1387`). |
| Create `XJournal AI/RapIslandToolbar.swift` | Screen-local island (👁/🔍/☰) matching the editor's look; local style constants. |

---

## Task 1: Engine — populate the generation deck

**Files:** Modify `XJournal AI/RapSuggestionView.swift` (`RapSuggestionEngine`, from `:1549`).

- [ ] **Step 1:** Add state next to the existing published vars (`:1549`+):

```swift
@Published var generations: [Generation] = []   // index 0 = newest
@Published var currentGenerationIndex: Int = 0
```

- [ ] **Step 2:** In the existing post-generation success path (the same place that sets `suggestions` / updates recall around `:1549`+; trace `lastBatchSuggestions` assignment), append a generation and select it:

```swift
let newGen = Generation(
    id: UUID(),
    suggestions: batch,                 // the suggestions just produced
    critic: humanCriticFeedback,        // snapshot if present, else nil (refreshable)
    createdAt: Date(),
    isFavorite: false,
    isFresh: true
)
generations = GenerationDeck.inserting(newGen, into: generations)
currentGenerationIndex = 0
```

- [ ] **Step 3 (verify):** Build the app (Simulator). Add a temporary `print(generations.count)` after a generate; confirm it grows and caps at 10 across repeated generations. Remove the print.

- [ ] **Step 4: Commit** (`feat: track generation deck on RapSuggestionEngine`).

---

## Task 2: LyricLineView — single-line bar with modes

**Files:** Create `XJournal AI/LyricLineView.swift`. (Keep `SuggestionLineRow` until Task 6 swaps callers.)

- [ ] **Step 1:** Define the view. Interface:

```swift
enum LyricRenderMode { case plain, stress, cascade }

struct LyricLineView: View {
    let line: String
    var mode: LyricRenderMode = .plain
    var rhymeAttributed: AttributedString? = nil   // from Task 3 when eye is on
    var isFresh: Bool = false                       // freshness flash (blue)
    // preserved feedback state from SuggestionLineRow:
    let isLiked: Bool; let isDisliked: Bool; let isModelGMoment: Bool
    let onTap: () -> Void

    @Environment(\.dynamicTypeSize) private var typeSize

    var body: some View { /* see steps */ }
}
```

- [ ] **Step 2:** Rendering rules (spec §3.2, §3.7):
  - If `isFresh` → render the plain string in blue (`Color.blue`), `.lineLimit(1)`, `.minimumScaleFactor(0.6)` — suppress stress/rhyme while fresh.
  - Else if `typeSize >= .accessibility1` OR `mode == .cascade` → render `CascadeFormatter.chunks(for: line)` as a `VStack(alignment:.leading)` of `Text` rows, each `.padding(.leading, CGFloat(chunk.indentLevel) * 16)`. (Multi-line; no shrink.)
  - Else if `mode == .stress` → build an `AttributedString` from `StressMap.spans(for: line)` (stressed → `.bold()` + `.primary`; else `.foregroundColor(.secondary)`), `.lineLimit(1).minimumScaleFactor(0.6)`.
  - Else if `rhymeAttributed != nil` → render it, `.lineLimit(1).minimumScaleFactor(0.6)`.
  - Else → `Text(line).font(.body).lineLimit(1).minimumScaleFactor(0.6)`.
  - Keep the trailing ✴ / 👍 / 👎 affordances and the green/red liked/disliked background from `SuggestionLineRow:1395-1429`, and `.onTapGesture { onTap() }`.

- [ ] **Step 3 (verify):** Add a `#Preview` with a short bar and a long bar in each mode and at `.accessibility3`; confirm: long bar shrinks (plain/stress), large type → cascade steps, stress bolds the right syllables.

- [ ] **Step 4: Commit** (`feat: LyricLineView (shrink-to-fit + stress + cascade)`).

---

## Task 3: Rhyme highlighting for the visible card

**Files:** Modify `XJournal AI/GenerationCardView.swift` (Task 4) or a small `RhymeHighlightModel` helper.

- [ ] **Step 1:** When the eye toggle is on, compute highlights for the visible generation's joined text and cache by generation id:

```swift
let (_, highlights) = await RhymeHighlighterEngine.computeAll(text: joinedLines)
```

- [ ] **Step 2:** Build a per-line `AttributedString` by mapping each `Highlight`'s range/color (reuse the editor's `RhymeColorPalette`) onto the line. **Fallback:** if range mapping is fiddly, render the line with `RhymeHighlightTextView` (`ContentView.CCV.6.swift:10`) in a non-editable config instead — guarantees editor parity. Pick one; note which.

- [ ] **Step 3 (verify):** Toggle eye on in the Simulator; confirm rhyme groups color identically to the editor; performance is one engine pass per visible card (debounced), not per line.

- [ ] **Step 4: Commit** (`feat: rhyme highlighting on Rap Suggestions`).

---

## Task 4: GenerationCardView — lyrics, Critic-below, freshness flash

**Files:** Create `XJournal AI/GenerationCardView.swift`.

- [ ] **Step 1:** Compose the card: a `ScrollView` of the generation's suggestion(s) — for each suggestion, the existing `cardContent` affordances (theme tags, quality indicators, feedback buttons, Tighten — reuse helpers from `RapSuggestionView`) with lines rendered via `LyricLineView` — **then** `HumanCriticSectionView(feedback: generation.critic, …)` BELOW (spec §3.5, item 2).

- [ ] **Step 2:** Freshness flash (spec §3.6) — start a cancellable 4s timer on appear; clear on tap or timeout; animate the fade (respect `reduceMotion`):

```swift
@State private var fresh: Bool
// ...
.task(id: generation.id) {
    guard fresh else { return }
    try? await Task.sleep(nanoseconds: 4_000_000_000)
    if !Task.isCancelled {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) { fresh = false }
    }
}
.onTapGesture {
    if fresh { withAnimation(reduceMotion ? nil : .easeOut(duration: 0.3)) { fresh = false } }
}
```

Pass `isFresh: fresh` down to each `LyricLineView`.

- [ ] **Step 3 (verify):** Generate → new card lands blue, fades to normal palette after ~4s; tapping before 4s fades immediately; swiping away cancels cleanly.

- [ ] **Step 4: Commit** (`feat: GenerationCardView with critic-below + freshness flash`).

---

## Task 5: RapDeckView — the paged deck

**Files:** Create `XJournal AI/RapDeckView.swift`.

- [ ] **Step 1:** Paged `TabView` over `generations`, bound to `currentGenerationIndex`, newest at index 0:

```swift
TabView(selection: $engine.currentGenerationIndex) {
    ForEach(Array(engine.generations.enumerated()), id: \.element.id) { idx, gen in
        GenerationCardView(generation: gen, /* toggles, callbacks */).tag(idx)
    }
}
.tabViewStyle(.page(indexDisplayMode: .never))
```

- [ ] **Step 2:** Overlay page dots + the blue hint `Text("swipe → for previous generations").foregroundStyle(.blue)` (hide hint when `generations.count <= 1`).

- [ ] **Step 3 (verify):** Multiple generations → swipe moves between cards; dots track; newest is front after generating.

- [ ] **Step 4: Commit** (`feat: RapDeckView paged generation deck`).

---

## Task 6: RapIslandToolbar + assemble the screen

**Files:** Create `XJournal AI/RapIslandToolbar.swift`; modify `RapSuggestionView.swift` body (`:108`) and replace `suggestionsList` (`:326`).

- [ ] **Step 1:** Build `RapIslandToolbar` — a bottom-floating capsule (`.ultraThinMaterial`/dark, matching the editor's pill geometry & haptics) with three buttons bound to `@Binding var rhymeOn`, `showGroups`, `stackOn`, using SF Symbols `eye`/`eye.fill`, `text.magnifyingglass`, and a Stack glyph (e.g. `text.aligncenter`). Replicate the small constant set locally (don't import the editor's private `ToolbarConstants` — spec §3.4). Attach the groups `.popover { RhymeGroupListView(groups:currentText:) }`.

- [ ] **Step 2:** In `body`, add screen-level `@State` `rhymeOn/showGroups/stackOn`; replace the `suggestionsList` branch with `RapDeckView(...)` and overlay `RapIslandToolbar(...)` at the bottom. Delete the top-level `HumanCriticSectionView` from the old list (now per card). Keep all other `body` branches (loading/error/silence/parallel/empty) as-is.

- [ ] **Step 3 (verify):** Full screen in Simulator: deck + island; eye toggles highlighting; groups popover opens; Stack toggles stress emphasis; Critic sits below lyrics on each card.

- [ ] **Step 4: Commit** (`feat: screen-local island + assemble deck into RapSuggestionView`).

---

## Task 7: Dynamic Type pass (this screen)

- [ ] **Step 1:** Confirm `LyricLineView` routes to cascade at `typeSize >= .accessibility1`; verify Critic, theme tags, quality indicators read well at large sizes (they already use semantic fonts).
- [ ] **Step 2 (verify):** Simulator → Settings → Accessibility → Larger Text to a large size; bars become cascade and stay readable; nothing clips.
- [ ] **Step 3: Commit** (`feat: Dynamic Type pass for Rap Suggestions screen`).

---

## Task 8: Cleanup + final manual verification

- [ ] **Step 1:** Remove `SuggestionLineRow` if no longer referenced (grep first); ensure the parallel `sideBySideView` still compiles (it may also adopt `LyricLineView`, optional).
- [ ] **Step 2 (verify checklist):** one line per bar (long bar shrinks) · Stack bolds stresses · eye highlights rhymes like the editor · groups popover · deck swipes, newest-first · freshness flash (4s/tap) · Critic below lyrics · large Dynamic Type → cascade.
- [ ] **Step 3: Commit** (`chore: remove dead SuggestionLineRow; finalize Rap Suggestions rebuild`).

---

## Self-Review

- **Spec coverage:** architecture/island §3.1/§3.4 → T6; 1.a shrink-to-fit §3.2 → T2; 1.b/1.c rhyme §3.3 → T3/T6; item 2 critic-below §3.5 → T4; item 3 deck + freshness §3.6 → T1/T4/T5; item 4 Stack §3.7 → T2 (+ foundations); a11y §5 → T2/T7. Reuse map honored (RhymeHighlighterEngine, RhymeGroupListView, HumanCriticSectionView, RhymeHighlightTextView fallback).
- **Known iteration points:** rhyme range→AttributedString mapping (T3, has a `RhymeHighlightTextView` fallback); island visual parity (T6); SwiftUI layout polish across tasks.
- **Risk watch (spec §7):** keep `generations` population additive to existing recall/ledger state; one highlighter pass per visible card; build out-of-iCloud / `CODE_SIGNING_ALLOWED=NO`.
