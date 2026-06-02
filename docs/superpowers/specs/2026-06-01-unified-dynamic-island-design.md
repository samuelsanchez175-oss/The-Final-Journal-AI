# Unified Dynamic Island — Editor ⇄ Rap Suggestions (matched, with Stack)

**Date:** 2026-06-01
**Surfaces:** editor island (`ContentView.CCV.14.swift` + `WritingSurface` in `CCV.13`) and the Rap Suggestions island (`RapIslandToolbar.swift`).
**Status:** Design approved (brainstorm). Ready for implementation plan.
**Mode:** Advisory; Samuel edits `CCV.13`/`CCV.14`/`RapSuggestionView` in parallel — coordinate commits (pathspec only; never sweep his staged/WIP work).

---

## 1. Goal

Make the editor's dynamic island and the Rap Suggestions island **one-to-one**: the **same button set** and the **same look** on both screens, and bring the **Stack** (syllable stress / spacing) feature — built for the suggestions deck — onto the **editor** island too.

---

## 2. Decisions (locked in brainstorm)

| # | Decision | Choice |
|---|----------|--------|
| Parity | What "one-to-one" means | **Literally identical button set** on both screens (editor-only buttons appear on the suggestions sheet too, inert there) |
| Stack on editor | Editor text is live-editable | **Read-only "stacked preview" toggle** — ☰ overlays a read-only stress/spacing render of the note; tap again to edit |
| Architecture | Shared vs mirrored | **B — matched concrete islands**: two concrete island containers kept identical by mirroring, NOT one generic component (respects "keep Momentum components concrete / don't genericize", and the locked/flat editor island) |

---

## 3. Design

### 3.1 Architecture

Two **concrete** island containers — the editor's (in `CCV.14`, kept intact) and the suggestions' (`RapIslandToolbar`, rebuilt to mirror it). They're identical by construction, not by sharing a generic view. Only **small primitives** are shared:

- The **Stack button** treatment (SF Symbol + action), added to both rows.
- A **read-only stacked-text renderer** (`StackedTextView`) used by the editor's preview overlay — built on the existing `LyricLineView` / `StressMap` / `CascadeFormatter`.

This keeps the editor island's locked geometry (`ToolbarConstants`, `matchedGeometryEffect`, expand/collapse, **64pt height — unchanged**) untouched except for one added button.

### 3.2 Identical button set (both islands)

`close · attach · generate · eye 👁 · groups 🔍 · keyboard · font-size Aa · stack ☰ (new)` — same SF Symbols, same `ToolbarConstants` values, same `enhancedButton`-style treatment. (Exact inventory is whatever the editor island currently renders + Stack; the plan confirms the final list from `CCV.14`.)

**Per-screen wiring:**

| Button | Editor | Rap Suggestions |
|--------|--------|-----------------|
| close | collapse island | dismiss sheet (= Done) |
| attach | attach to note | **inert (present for parity)** |
| generate ✨ | generate suggestions | regenerate (`onRegenerate`) |
| eye 👁 | rhyme overlay | rhyme highlight (deck) |
| groups 🔍 | rhyme-groups popover | rhyme-groups popover (deck text) |
| keyboard | toggle keyboard | **inert (present for parity)** |
| font-size Aa | `writingFontSize` stepper | `writingFontSize` stepper (sizes lyrics) |
| **stack ☰** | **read-only stacked preview (§3.3)** | toggle deck stress view (`stackOn`, already wired) |

### 3.3 Editor — Stack = read-only stacked preview

Mirrors the **existing rhyme-overlay pattern** in `WritingSurface` (`CCV.13:875–928`), where the rhyme overlay hides the `TextEditor` (`.foregroundStyle(.clear)` + `.allowsHitTesting(false)`) and lays `RhymeHighlightTextView` over it.

Add `@State stackPreviewOn`. When on: overlay a read-only `StackedTextView(text:)` on the `TextEditor` (editor text clear + non-interactive underneath); tap ☰ again → off → editable. `StackedTextView` renders each line of the note via `LyricLineView(mode: .stress)` (or cascade at large Dynamic Type), scrolling. No change to how text is stored — purely a render mode. Mutually exclusive with the rhyme overlay (turning one on turns the other off) to avoid stacked overlays.

### 3.4 Rap Suggestions — full island parity

Rebuild `RapIslandToolbar` to carry the **same 8 buttons** and the editor's styling (replicate the small set of `ToolbarConstants` values + button treatment locally — do NOT import the editor's `private` toolbar internals; per the "concrete components" guidance). Wire the applicable buttons per §3.2; `attach` and `keyboard` render but no-op on this screen. `stack` drives the deck's existing `stackOn`; `eye`/`groups` the existing rhyme state; `font-size` the shared `writingFontSize`.

### 3.5 Font-size shared

Both islands' Aa button drives the same `@AppStorage(EditorChromeSettings.writingFontSizeKey)`. The editor already uses it (`FontSizeStepperPopover(fontSize: $writingFontSize)`). On the suggestions screen, lyric rendering (`LyricLineView`) reads it so note text and lyrics scale from one control. (Bonus: progresses the deferred font-scalability concern for these surfaces.)

---

## 4. Components & interfaces

| Unit | Responsibility | Depends on |
|------|----------------|------------|
| `StackedTextView` (new) | A plain `String` → read-only scrolling stress/spacing render (per line). Used by the editor's Stack overlay. | `LyricLineView`, `StressMap`, `CascadeFormatter` |
| Stack button (shared treatment) | One SF Symbol + toggle action, dropped into both island rows | `ToolbarConstants` values |
| Editor island (`CCV.14`, modify) | Add the Stack button to the row, bound to `stackPreviewOn` | existing island |
| `WritingSurface` (`CCV.13`, modify) | Conditionally overlay `StackedTextView` when `stackPreviewOn` (rhyme-overlay pattern) | `StackedTextView` |
| `RapIslandToolbar` (rebuild) | Mirror the editor's full button set + styling; wire applicable actions | local constants, deck state, `writingFontSize` |
| Reused as-is | `LyricLineView`, `StressMap`, `CascadeFormatter`, `RhymeGroupListView`, `FontSizeStepperPopover`, `EditorChromeSettings` | — |

`StackedTextView` is the only genuinely new, isolatable unit; the rest is wiring into two concrete containers.

---

## 5. Risks & constraints

1. **Locked/flat editor island.** Change is **additive only** — one button in the row + one conditional overlay following the existing rhyme-overlay pattern. 64pt height and `matchedGeometryEffect`/expand-collapse untouched. No genericizing.
2. **Type-check timeouts** (memory, CCV.12). Keep new view bodies small; extract helpers; type-erase complex accessories with `AnyView` if a body gets heavy.
3. **Parallel editing.** Samuel is in `CCV.13`/`CCV.14`/`RapSuggestionView`. Re-check git before each edit; commit via `git commit -- <paths>`; never sweep his staged/WIP work.
4. **Two-project build/test.** Build/test via the **`XJournal AI` scheme** (module `XJournal_AI`), out-of-iCloud derivedData, `CODE_SIGNING_ALLOWED=NO`.
5. **Mutual exclusion** of rhyme overlay vs stacked preview on the editor (both can't be on at once).

## 6. Out of scope / follow-ups

- True single shared island component (approach A) — deliberately rejected.
- Editable stress-rendering (stress emphasis while still typing) — preview is read-only by design.
- The deck-card legacy affordances (separate follow-up already noted).

## 7. Testing notes

- `StackedTextView` line-splitting/mode selection: small logic, lightly testable; the heavy lifting (`StressMap`/`CascadeFormatter`) is already unit-tested.
- Island parity + the editor preview toggle: **manual in the Simulator** (SwiftUI; no snapshot harness).
- Compile-check via the `XJournal AI` scheme after each phase.
