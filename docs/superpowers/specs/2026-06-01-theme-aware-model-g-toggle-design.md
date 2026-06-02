# Theme-aware Model G — Toggle, Sheet Wiring & Catalog Unification

**Date:** 2026-06-01
**Status:** Design approved (2026-06-01) — ready for implementation plan
**Goal:** Give the user an on/off switch (default ON) over Model G's theme influence; make the Theme Expansion sheet's selections actually drive generation (overriding auto-detect); and unify theme detection on the new 34-theme `ThemeCatalog`.

---

## Background — the feature is mostly already built

Theme-aware Model G is **already live and always-on**, contrary to the vault's "What to build on top" TODO:

- `ThemeContextBuilder.build(from: input)` is called in all three coordinators — `ModelGCoreCoordinator.swift:87`, `ModelGCoreCoordinatorV2.swift:42`, `ModelGCoreCoordinatorV3.swift:41`.
- It auto-detects the entry's dominant theme, attaches a jargon palette + emotional tone + a few-shot example (`ThemeContext`), and `ModelGLLMService` injects a `themeDirective` block into the prompt (`ModelGLLMService.swift:40/177/233`, directive built at `:306–308`).
- When no theme is detected (or context is nil) the prompt falls back to the one-word `context.intent.theme` (`ModelGLLMService.swift:154`).

**Three gaps motivate this work:**

1. **No user control.** Theme influence is always on; the user wants to turn it off.
2. **Detection ≠ UI.** `ThemeContextBuilder` scores against the **old 232-theme `NewRapDatabase`** taxonomy, while the Theme Expansion sheet (rebuilt this session) shows the **new 34-theme `ThemeCatalog`**. They disagree on the theme set.
3. **Sheet selections are inert.** `ThemeExpansionSheet.selectedThemeIDs` is ephemeral `@State`; the user's picks never persist and never reach generation.

---

## Success criteria

- A toggle (default **ON**) in **Model Preferences** controls whether themes affect generated lyrics. OFF ⇒ no `Theme:` directive block (prompt uses the plain `intent.theme` topic, i.e. pre-theme behavior).
- When the user selects themes in the Theme Expansion sheet, **those themes drive generation** (override auto-detect). With no selection, generation **auto-detects from the 34-theme catalog**.
- Selections **persist per note** and survive sheet close + app restart.
- The prompt format is **unchanged** (reuses the existing `themeDirective`) so generation quality stays stable.
- Build green; manual QA scenarios pass.

---

## Decisions (from brainstorming)

| Decision | Choice | Rationale |
|---|---|---|
| Scope | Toggle **+** wire sheet selections **+** unify on 34-catalog | User selected "all" |
| Selection vs auto-detect | **Selection overrides** (picks win; auto-detect only when none picked) | Most predictable; explicit intent wins |
| Toggle scope | **Global** `@AppStorage`, not per-model | Cross-cutting behavior; product is v3-only |
| Toggle home | **Model Preferences** | Where model behavior is configured |
| Selection persistence | **Per-note** (`Item.selectedThemeIDs`) | Sheet opens from a note; picks belong to it; mirrors `lastSuggestionSessionData` |
| Prompt format | **Unchanged** `themeDirective` | Stability; smaller blast radius |

---

## Architecture & data flow

```
ThemeExpansionSheet (user picks)
        │  writes
        ▼
Item.selectedThemeIDs: [String]   ◄── persisted (SwiftData, additive)
        │  read at generation
        ▼
RapSuggestionAPI.generateSuggestions(…)
        │  populates
        ▼
DirectedGenerationParams.selectedThemeIDs: [String]   (new field)
        │  passed into coordinators (existing channel)
        ▼
ModelGCoreCoordinator{,V2,V3}.generate(…)
        │  ThemeContextBuilder.build(from: input,
        │       selectedThemeIDs: directedParams?.selectedThemeIDs ?? [])
        ▼
ThemeContextBuilder.build(…)
   1. gate: @AppStorage("theme_aware_generation") (default true) → nil if OFF
   2. if selectedThemeIDs non-empty → ThemeContext from those catalog themes
      else → auto-detect over ThemeCatalog.all (existing scoring)
   3. merge multiple (cap ~3 themes, jargon deduped/capped ~8)
        │
        ▼
ThemeContext → ModelGLLMService.themeDirective  (unchanged prompt block)
```

---

## Component changes

### 1. Toggle — `@AppStorage("theme_aware_generation")`, default `true`
- Read **inside** `ThemeContextBuilder.build(...)` so one gate covers all three coordinators (no per-call-site edits for the toggle).
- **Default-true correctness:** `UserDefaults.standard.bool(forKey:)` returns `false` when unset. Use `UserDefaults.standard.object(forKey: "theme_aware_generation") as? Bool ?? true` **or** register the default (`UserDefaults.standard.register(defaults:)` at launch). Spec mandates default ON when unset.
- UI: one `Toggle` in `ModelPreferencesView` ("Apply detected themes to lyrics"), bound to the same `@AppStorage` key.

### 2. Detection unified on `ThemeCatalog`
- `ThemeContextBuilder` scores against `ThemeCatalog.all` (34) instead of `NewRapDatabase.shared.themes` (232).
- `ThemeCatalog.all : [Theme]` uses the **same `Theme` struct** (`jargonTerms`, `emotionalTone`, `relatedThemes`, `contextDescription`), so `ThemeContext` construction is unchanged.
- Reuse `ThemeCatalog.theme(id:)` for selection lookups and the existing `matchThemes(in:)` / scoring for auto-detect.

### 3. Selection wiring + override
- **`Item.selectedThemeIDs: [String] = []`** — additive, mirrors the existing `aiTextRanges: [String] = []` (SwiftData lightweight migration safe).
- **`DirectedGenerationParams.selectedThemeIDs: [String] = []`** — new field; the established channel into the coordinators.
- `ThemeExpansionSheet` persists the user's picks to `Item.selectedThemeIDs` (on change or on dismiss). Sheet currently inits with `currentText` + `onDismiss`; add an `Item` reference or an `onCommitSelection: ([String]) -> Void` callback (wired in `CCV.13`/`CCV.14`).
- `RapSuggestionAPI` populates `DirectedGenerationParams.selectedThemeIDs` from the active note's `Item.selectedThemeIDs` before invoking coordinators.
- `ThemeContextBuilder.build(from:selectedThemeIDs:record:)`: if `selectedThemeIDs` non-empty → build from those catalog themes; else auto-detect.

### 4. Multiple themes
- Cap to ~3 themes (selected order, or top auto-detect scores). `themeName` = primary (or short join); `emotionalTone` = primary's; `jargonPalette` = merged + deduped, cap ~8 (matches today's `prefix(8)`); `example` = primary's (best-effort).

### 5. Prompt injection — unchanged
- Continue using `ModelGLLMService.themeDirective`. No format change.

---

## Edge cases

- **Few-shot examples:** `ThemeExampleStore` is keyed by old-taxonomy category names; new catalog names may not match → degrade gracefully (no example). Optional follow-up: name mapping.
- **Taste tracker:** `ThemeTasteTracker` counts re-accumulate under catalog names (old counts orphaned). Acceptable.
- **`directedParams == nil` flows:** still honor the toggle (gate lives in `build`); they simply carry no selection (auto-detect).
- **SwiftData migration:** `Item.selectedThemeIDs` is additive with a default → lightweight migration, no manual schema work.
- **OFF behavior:** `build` returns `nil` ⇒ existing fallback to `intent.theme`. Verified path.

---

## Non-goals

- No change to the `themeDirective` prompt wording / format.
- Not removing the 232-theme `NewRapDatabase` taxonomy (still used by legacy/other paths).
- Not hooking up `generateThemeExpansion()` lyric output (separate backlog item).
- Not Human Critic Phase 2 (deferred per Samuel, after this + generation-speed).

---

## Verification

- **Build:** `xcodebuild -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' build` → BUILD SUCCEEDED (use default DerivedData, not `.derivedData/`; or `CODE_SIGNING_ALLOWED=NO` for a compile-only check).
- **Manual QA:**
  1. Toggle OFF → generate → prompt has **no** `Theme:` directive block (plain topic).
  2. Toggle ON, no picks → auto-detects a catalog theme; jargon/tone appear.
  3. Pick themes in sheet → reopen note → picks persist → generation uses **those** themes (override).
  4. Clear picks → reverts to auto-detect.

---

## Files touched

| File | Change |
|---|---|
| `ModelG/ThemeContextBuilder.swift` | Source swap (NewRapDatabase→ThemeCatalog); `selectedThemeIDs` override; `@AppStorage` gate; multi-theme merge |
| `DirectedGenerationParams.swift` | `+ selectedThemeIDs: [String] = []` |
| `RapSuggestionAPI.swift` | Populate `directedParams.selectedThemeIDs` from `Item` |
| `ModelG/ModelGCoreCoordinator.swift` / `…V2.swift` / `…V3.swift` | Pass `selectedThemeIDs` into `build(...)` |
| `Item.swift` | `+ selectedThemeIDs: [String] = []` |
| `ThemeExpansionSheet.swift` | Persist picks to `Item` |
| `ContentView.CCV.13.swift` / `CCV.14.swift` | Sheet wiring (pass `Item`/callback) |
| `ModelPreferencesView.swift` | Toggle UI bound to `theme_aware_generation` |
