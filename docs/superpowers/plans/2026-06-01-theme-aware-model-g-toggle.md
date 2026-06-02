# Theme-aware Model G — Toggle, Sheet Wiring & Catalog Unification — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a default-ON toggle gating Model G's (already-live) theme influence, make the Theme Expansion sheet's picks drive generation (overriding auto-detect), and unify theme detection on the 34-theme `ThemeCatalog`.

**Architecture:** Theme detection already runs in `ThemeContextBuilder.build(from:)` inside all 3 coordinators and injects a `themeDirective` into the prompt. This plan (1) rewrites `build` to read the curated catalog, honor a selection override, and gate on a setting; (2) threads per-note `selectedThemeIDs` as an explicit param from the engine down to `build` (NOT via the often-nil `directedParams`); (3) persists picks on `Item`; (4) adds the toggle UI.

**Tech Stack:** Swift, SwiftUI, SwiftData, XCTest. Xcode 26.5, iPhone 17 simulator.

---

## Execution notes (read first)

- **Samuel edits this repo in parallel.** Line numbers below are approximate — locate edits by the quoted anchor text, and run `git status`/`git diff <file>` before editing each file. Default to surgical edits.
- **Build command (do NOT build into iCloud `.derivedData/`):**
  ```bash
  cd "/Users/samuel/Documents/The Final Journal AI"
  xcodebuild -project "XJournal AI.xcodeproj" -scheme "XJournal AI" \
    -destination 'platform=iOS Simulator,name=iPhone 17' \
    CODE_SIGNING_ALLOWED=NO build 2>&1 | tail -30
  ```
  Expect `** BUILD SUCCEEDED **`. (Default DerivedData avoids the iCloud codesign failure.)
- **Spec:** `docs/superpowers/specs/2026-06-01-theme-aware-model-g-toggle-design.md`.
- **Commit cadence:** Samuel commits in batches. The `git commit` steps mark logical boundaries — coordinate with him before committing if executing inline.
- **Deviation from spec:** spec suggested a `DirectedGenerationParams.selectedThemeIDs` field. Planning found `directedParams` is `nil` on the plain toolbar flow, so we thread an explicit `selectedThemeIDs: [String]` param instead. Same data flow (note → generation → build), more robust. No `DirectedGenerationParams` change.

---

## File structure

| File | Responsibility | Change |
|---|---|---|
| `ModelG/ThemeContextBuilder.swift` | Theme detection + context construction | Rewrite `build`: catalog source, selection override, AppStorage gate, multi-theme merge |
| `The Final Journal AITests/ThemeContextBuilderTests.swift` | Unit tests for the above | **Create** |
| `RapSuggestionAPI.swift` | Generation orchestration | Thread `selectedThemeIDs` param: `generateSuggestions` → `generateModelGCoreRecordWithRetry` |
| `ModelG/ModelGCoreCoordinator.swift` / `…V2.swift` / `…V3.swift` | Per-version generation | Accept `selectedThemeIDs`, pass into `build` |
| `Item.swift` | Note model | Add `selectedThemeIDs: [String] = []` |
| `RapSuggestionView.swift` | `RapSuggestionEngine` | Read `item?.selectedThemeIDs`, pass to `api.generateSuggestions` |
| `ThemeExpansionSheet.swift` | Theme picker UI | Persist picks to `Item`; seed from `Item` |
| `ContentView.CCV.13.swift` / `CCV.14.swift` | Sheet presentation | Pass `item:` to the sheet |
| `ModelPreferencesView.swift` | Settings | Toggle bound to `theme_aware_generation` |

---

## Task 1: ThemeContextBuilder — catalog source + selection override + toggle gate

**Files:**
- Modify: `XJournal AI/ModelG/ThemeContextBuilder.swift` (the `enum ThemeContextBuilder` at the bottom, ~line 127)
- Test: `The Final Journal AITests/ThemeContextBuilderTests.swift` (create)

The `build` signature gains `selectedThemeIDs: [String] = []` with a default, so the 3 existing coordinator call sites (`build(from: input)`) keep compiling until Task 2 wires them.

- [ ] **Step 1: Write the failing test**

Create `The Final Journal AITests/ThemeContextBuilderTests.swift`:

```swift
import XCTest
@testable import XJournal_AI

final class ThemeContextBuilderTests: XCTestCase {
    private let key = "theme_aware_generation"

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: key)
        super.tearDown()
    }

    func testToggleOffReturnsNil() {
        UserDefaults.standard.set(false, forKey: key)
        let ctx = ThemeContextBuilder.build(from: "Rolex on my wrist, trap money", record: false)
        XCTAssertNil(ctx, "Theme context must be nil when theme-aware generation is OFF")
    }

    func testSelectionOverridesAutoDetect() {
        UserDefaults.standard.set(true, forKey: key)
        guard let firstID = ThemeCatalog.all.first?.id else { return XCTFail("catalog empty") }
        let expectedName = ThemeCatalog.theme(id: firstID)?.name
        let ctx = ThemeContextBuilder.build(from: "unrelated lyrics about gardening",
                                            selectedThemeIDs: [firstID], record: false)
        XCTAssertEqual(ctx?.themeName, expectedName, "Selected theme must drive the context")
    }

    func testAutoDetectWhenNoSelection() {
        UserDefaults.standard.set(true, forKey: key)
        guard let theme = ThemeCatalog.all.first(where: { !$0.jargonTerms.isEmpty }) else {
            return XCTFail("no theme with jargon")
        }
        let text = theme.jargonTerms.prefix(3).joined(separator: " ")
        let ctx = ThemeContextBuilder.build(from: text, record: false)
        XCTAssertNotNil(ctx, "Auto-detect should resolve a theme from its own jargon")
    }

    func testJargonPaletteCappedAtEight() {
        UserDefaults.standard.set(true, forKey: key)
        let ids = Array(ThemeCatalog.all.prefix(3).map(\.id))
        let ctx = ThemeContextBuilder.build(from: "x", selectedThemeIDs: ids, record: false)
        XCTAssertLessThanOrEqual(ctx?.jargonPalette.count ?? 0, 8)
    }
}
```

Confirm the file is in the **The Final Journal AITests** target (the project uses file-system synchronized groups, so a file placed in the test folder auto-joins; if a target-membership prompt is needed, add it to that test target only).

- [ ] **Step 2: Run the test, verify it fails to compile/pass**

Run:
```bash
cd "/Users/samuel/Documents/The Final Journal AI"
xcodebuild -project "XJournal AI.xcodeproj" -scheme "XJournal AI" \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  test -only-testing:"The Final Journal AITests/ThemeContextBuilderTests" 2>&1 | tail -30
```
Expected: FAIL — `testSelectionOverridesAutoDetect` fails (today `build` ignores `selectedThemeIDs`) and/or the `selectedThemeIDs:` argument doesn't compile.

- [ ] **Step 3: Rewrite `ThemeContextBuilder`**

Replace the entire `enum ThemeContextBuilder { … }` block (currently ~line 127 to end of file) with:

```swift
enum ThemeContextBuilder {
    static let themeAwareDefaultsKey = "theme_aware_generation"

    /// Whether theme-aware generation is enabled. Defaults to ON when the user has never set it.
    static var isThemeAwareEnabled: Bool {
        (UserDefaults.standard.object(forKey: themeAwareDefaultsKey) as? Bool) ?? true
    }

    /// Resolve the entry's theme(s) and build the Model G theme context.
    /// - selectedThemeIDs: user picks from the Theme Expansion sheet. Non-empty → overrides auto-detect.
    /// Returns nil when theme-aware generation is OFF, or when no theme resolves.
    static func build(from entry: String,
                      selectedThemeIDs: [String] = [],
                      record: Bool = true) -> ThemeContext? {
        guard isThemeAwareEnabled else { return nil }

        // 1. Selection overrides auto-detect.
        if !selectedThemeIDs.isEmpty {
            let picked = selectedThemeIDs.compactMap { ThemeCatalog.theme(id: $0) }
            if let ctx = makeContext(from: picked, record: record) { return ctx }
            // else fall through to auto-detect
        }

        // 2. Auto-detect over the curated 34-theme catalog.
        let text = entry.lowercased()
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return nil }
        let themes = ThemeCatalog.all
        guard !themes.isEmpty else { return nil }

        func score(_ t: Theme) -> Double {
            var s = 0.0
            for term in t.jargonTerms {
                let cleaned = term.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
                if cleaned.count > 2, text.contains(cleaned) { s += 3 }
            }
            for token in t.name.lowercased().split(separator: " ").map(String.init) where token.count > 3 {
                if text.contains(token) { s += 2 }
            }
            for token in t.contextDescription.lowercased()
                .split(whereSeparator: { !$0.isLetter }).map(String.init) where token.count > 4 {
                if text.contains(token) { s += 0.25 }
            }
            return s + ThemeTasteTracker.shared.weight(for: t.name)
        }

        var best: Theme?
        var bestScore = 0.0
        for t in themes {
            let sc = score(t)
            if sc > bestScore { bestScore = sc; best = t }
        }

        let chosen: Theme?
        if let b = best, bestScore > 0 {
            chosen = b
        } else if let fav = ThemeTasteTracker.shared.favoriteTheme {
            chosen = themes.first { $0.name == fav }
        } else {
            chosen = nil
        }
        guard let theme = chosen else { return nil }
        return makeContext(from: [theme], record: record)
    }

    /// Merge one or more themes into a single ThemeContext (cap 3 themes, 8 jargon terms).
    private static func makeContext(from themes: [Theme], record: Bool) -> ThemeContext? {
        let capped = Array(themes.prefix(3))
        guard let primary = capped.first else { return nil }
        if record { ThemeTasteTracker.shared.record(primary.name) }

        var palette: [String] = []
        var seen = Set<String>()
        for t in capped {
            for term in t.jargonTerms {
                let cleaned = term.trimmingCharacters(in: .whitespacesAndNewlines)
                let lower = cleaned.lowercased()
                if cleaned.count > 1, !seen.contains(lower) {
                    seen.insert(lower)
                    palette.append(cleaned)
                }
            }
        }
        palette = Array(palette.prefix(8))

        let name = capped.count > 1 ? capped.map(\.name).joined(separator: " + ") : primary.name

        return ThemeContext(
            themeName: name,
            emotionalTone: primary.emotionalTone,
            jargonPalette: palette,
            example: ThemeExampleStore.shared.example(forTheme: primary.name)
        )
    }
}
```

Leave `ThemeContext`, `ThemeTasteTracker`, and `ThemeExampleStore` (above this enum) unchanged.

- [ ] **Step 4: Run the test, verify it passes**

Run the same command as Step 2.
Expected: PASS (4 tests).

- [ ] **Step 5: Build the app target**

Run the build command from Execution notes. Expected `** BUILD SUCCEEDED **` (the 3 coordinator `build(from: input)` calls still compile via the defaulted param).

- [ ] **Step 6: Commit**

```bash
git add "XJournal AI/ModelG/ThemeContextBuilder.swift" "The Final Journal AITests/ThemeContextBuilderTests.swift"
git commit -m "Model G: theme detection on curated catalog + selection override + toggle gate"
```

---

## Task 2: Thread `selectedThemeIDs` through the generation stack

**Files:**
- Modify: `XJournal AI/RapSuggestionAPI.swift` (`generateSuggestions` ~534; `generateModelGCoreRecordWithRetry` ~481, call site ~574)
- Modify: `XJournal AI/ModelG/ModelGCoreCoordinator.swift`, `…V2.swift`, `…V3.swift`

- [ ] **Step 1: Add param to `generateSuggestions` (RapSuggestionAPI ~534)**

In the `func generateSuggestions(` parameter list, add after `directedParams: DirectedGenerationParams? = nil,`:
```swift
        selectedThemeIDs: [String] = [],
```

- [ ] **Step 2: Pass it into the core-record call (RapSuggestionAPI ~574)**

At the call `let record = try await self.generateModelGCoreRecordWithRetry(`, add the argument:
```swift
                                selectedThemeIDs: selectedThemeIDs,
```

- [ ] **Step 3: Add param to `generateModelGCoreRecordWithRetry` (RapSuggestionAPI ~481)**

In its parameter list (after `directedParams: DirectedGenerationParams?,`):
```swift
        selectedThemeIDs: [String] = [],
```
Then in each of the three `coordinatorVx.generateRecord(` / `coordinator.generateRecord(` calls inside it (~492, ~505, ~514), add:
```swift
                    selectedThemeIDs: selectedThemeIDs,
```

- [ ] **Step 4: Add param to all three coordinators + pass into `build`**

In each of `ModelGCoreCoordinatorV3.swift`, `ModelGCoreCoordinatorV2.swift`, `ModelGCoreCoordinator.swift`, find the `func generateRecord(` signature and add (alongside `directedParams`):
```swift
        selectedThemeIDs: [String] = [],
```
Then change the line:
```swift
        let themeContext = ThemeContextBuilder.build(from: input)
```
to:
```swift
        let themeContext = ThemeContextBuilder.build(from: input, selectedThemeIDs: selectedThemeIDs)
```

- [ ] **Step 5: Build**

Run the build command. Expected `** BUILD SUCCEEDED **`. (Engine callers still default `selectedThemeIDs` to `[]` — no behavior change yet.)

- [ ] **Step 6: Commit**

```bash
git add "XJournal AI/RapSuggestionAPI.swift" "XJournal AI/ModelG/ModelGCoreCoordinator.swift" "XJournal AI/ModelG/ModelGCoreCoordinatorV2.swift" "XJournal AI/ModelG/ModelGCoreCoordinatorV3.swift"
git commit -m "Model G: thread selectedThemeIDs from API through coordinators to ThemeContextBuilder"
```

---

## Task 3: Persist selection on `Item` + read it in the engine

**Files:**
- Modify: `XJournal AI/Item.swift`
- Modify: `XJournal AI/RapSuggestionView.swift` (`generateSuggestions` ~1675 → `api.generateSuggestions` ~1819; `generateSuggestionsModelGParallel` ~2033 → `api.generateSuggestions` ~2101/2119)

- [ ] **Step 1: Add the field to `Item`**

In `Item.swift`, after `var lastSuggestionSessionData: Data?` (~line 32), add:
```swift
    var selectedThemeIDs: [String] = []   // Theme Expansion picks that steer Model G generation
```
(Mirrors the existing `var aiTextRanges: [String] = []` — additive, SwiftData lightweight-migration safe.)

- [ ] **Step 2: Read it in the engine and pass down (non-parallel path)**

In `RapSuggestionEngine.generateSuggestions(... persistTo item: Item? ...)` (~1675), near the top of the body add:
```swift
        let resolvedThemeIDs = item?.selectedThemeIDs ?? []
```
Then at the `api.generateSuggestions(` call (~1819), add the argument (next to `directedParams: directedParams,`):
```swift
                selectedThemeIDs: resolvedThemeIDs,
```

- [ ] **Step 3: Same for the parallel path (~2033)**

In `generateSuggestionsModelGParallel(... persistTo item: Item? ...)`, add `let resolvedThemeIDs = item?.selectedThemeIDs ?? []` near the top, then add `selectedThemeIDs: resolvedThemeIDs,` to **both** `api.generateSuggestions(` calls (~2101 v1 task, ~2119 v2 task).

- [ ] **Step 4: Build**

Run the build command. Expected `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit**

```bash
git add "XJournal AI/Item.swift" "XJournal AI/RapSuggestionView.swift"
git commit -m "Editor: persist Theme Expansion picks on Item and feed them into Model G generation"
```

---

## Task 4: Theme Expansion sheet — persist picks to the note

**Files:**
- Modify: `XJournal AI/ThemeExpansionSheet.swift` (struct props ~16; auto-select `.task` ~108; `toggleSelection` ~310)
- Modify: `XJournal AI/ContentView.CCV.13.swift` (~819) and `XJournal AI/ContentView.CCV.14.swift` (~917) — presentation sites

- [ ] **Step 1: Give the sheet the note**

In `ThemeExpansionSheet` (struct header ~line 16), add a stored property near `let currentText: String`:
```swift
    let item: Item
```

- [ ] **Step 2: Seed selection from the note, persist on change**

Find where the sheet sets selection on open (the `.task` block, ~108: `selectedThemeIDs = result.themeIDs`). Change it to seed from the note first:
```swift
            if item.selectedThemeIDs.isEmpty {
                selectedThemeIDs = result.themeIDs   // no saved picks → use auto-identify
            } else {
                selectedThemeIDs = Set(item.selectedThemeIDs)   // restore the note's saved picks
            }
            item.selectedThemeIDs = Array(selectedThemeIDs)
```

In `toggleSelection` (~310), after the existing `selectedThemeIDs = updated` (~318), add:
```swift
        item.selectedThemeIDs = Array(updated)
```

- [ ] **Step 3: Pass the note at both presentation sites**

At `ContentView.CCV.14.swift` ~917, the call is:
```swift
                ThemeExpansionSheet(
                    currentText: currentText,
                    onDismiss: { showThemeExpansionSheet = false }
                )
```
Add `item: item,` (this view already has `let item: Item` at ~105):
```swift
                ThemeExpansionSheet(
                    item: item,
                    currentText: currentText,
                    onDismiss: { showThemeExpansionSheet = false }
                )
```
Do the same at `ContentView.CCV.13.swift` ~819. **Verify** the CCV.13 presentation context has an `Item` in scope (the editor's note); if it's named differently (e.g. `note`), pass that. If CCV.13 has no `Item` available, leave that call passing the editor's note reference it does have.

- [ ] **Step 4: Build**

Run the build command. Expected `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Commit**

```bash
git add "XJournal AI/ThemeExpansionSheet.swift" "XJournal AI/ContentView.CCV.13.swift" "XJournal AI/ContentView.CCV.14.swift"
git commit -m "Theme Expansion: persist selected themes to the note (seed + on toggle)"
```

---

## Task 5: The toggle UI (Model Preferences)

**Files:**
- Modify: `XJournal AI/ModelPreferencesView.swift`

- [ ] **Step 1: Add the AppStorage-backed toggle**

In `ModelPreferencesView`, add a property near the top of the view struct:
```swift
    @AppStorage("theme_aware_generation") private var themeAwareGeneration = true
```
In the form body, add a new `Section` (place it near the Model G settings section):
```swift
            Section {
                Toggle("Apply detected themes to lyrics", isOn: $themeAwareGeneration)
            } footer: {
                Text("When on, Model G draws on the themes detected in your note (or the ones you pick in Theme Expansion). Turn off to ignore themes entirely.")
            }
```
The `@AppStorage` key **must** be exactly `"theme_aware_generation"` — it is the same key `ThemeContextBuilder.isThemeAwareEnabled` reads.

- [ ] **Step 2: Build**

Run the build command. Expected `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Commit**

```bash
git add "XJournal AI/ModelPreferencesView.swift"
git commit -m "Settings: Model Preferences toggle for theme-aware Model G generation (default on)"
```

---

## Task 6: End-to-end verification + docs

- [ ] **Step 1: Full build green** — run the build command; expect `** BUILD SUCCEEDED **`.
- [ ] **Step 2: Run the unit tests** — `…test -only-testing:"The Final Journal AITests/ThemeContextBuilderTests"`; expect 4 PASS.
- [ ] **Step 3: Manual QA in Xcode (Run on iPhone 17 sim):**
  1. **Toggle OFF** (Profile → Model Preferences) → write lyrics → Suggest with Model G v3 → suggestions still generate; the prompt has **no** theme directive (behavior reverts to plain topic). *(Optional: temporarily print the system prompt to confirm no "Theme:" block.)*
  2. **Toggle ON, no picks** → write lyrics containing clear theme jargon (e.g. "Rolex", "trap") → generate → output leans into that theme's vocabulary.
  3. **Pick themes** in Theme Expansion → close → reopen the note's sheet → picks persist → generate → output reflects the **picked** themes even if the lyrics imply others.
  4. **Clear picks** → generate → reverts to auto-detect.
- [ ] **Step 4: Update vault docs** — in `Documents/OB CLAUDE vault/XJournal AI - App/`:
  - `Theme & Jargon Data.md` → mark "Theme-aware Model G ⭐" as **shipped**; note detection now uses `ThemeCatalog` (34) + the new toggle + per-note selection override.
  - `Session Handoff.md` → add a session entry; tick the 🌿 "Wire selected theme IDs from sheet into Model G" backlog item.

---

## Self-review (completed by plan author)

- **Spec coverage:** toggle (Task 1 gate + Task 5 UI) ✓; selection-overrides (Task 1 `makeContext` precedence) ✓; catalog unification (Task 1 `ThemeCatalog.all`) ✓; per-note persistence (Task 3 `Item` + Task 4 sheet) ✓; prompt unchanged (no `themeDirective` edits) ✓; verify (Task 6) ✓.
- **Placeholders:** none — every code step shows complete code. The only "verify in context" note is CCV.13's `Item` availability (Task 4 Step 3), with an explicit fallback.
- **Type consistency:** `selectedThemeIDs: [String]` everywhere; key string `"theme_aware_generation"` shared by `ThemeContextBuilder.themeAwareDefaultsKey` and the `@AppStorage` in Task 5; `ThemeContext(themeName:emotionalTone:jargonPalette:example:)` matches the existing struct; `ThemeCatalog.theme(id:)`/`.all` confirmed to exist.
