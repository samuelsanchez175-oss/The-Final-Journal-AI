# Dynamic Type — Foundation + Core Surfaces

**Date:** 2026-06-01
**Status:** Design (approved decisions; pending spec review)
**Roadmap:** Fulfills the deferred "Font scalability / Dynamic Type" item in
`OB CLAUDE vault/XJournal AI - App/Improvement Roadmap — Phased Goals.md` (goal: the whole app
honors the iOS Text Size slider).

## Goal

Make XJournal AI respond to the iOS **Text Size** control (Control Center slider / Settings →
Accessibility → Display & Text Size). Text — and the layout around it — scales gracefully:
**full range on reading surfaces** (up to the largest accessibility size, ≈3× default),
**clamped on dense chrome** so toolbars/chips/tab rows stay usable.

This is a **foundation + core-surfaces** pass, deliberately scoped to keep the diff small and
reduce collision risk with parallel editing. It honors the **OS** setting only.

## Non-goals (this pass)

- **No in-app text-size slider.** We honor the OS setting; an in-app override is a possible future,
  not this pass.
- **The ~50 inline `.system(size:)` on non-core screens** (`AudioDetailSheet` ×10, `SplashScreenView`
  ×7, `AIErrorBanner` ×5, badges, theme/social/onboarding sheets, etc.) are **out of scope** here.
  This pass produces an **audit map** of every remaining offender so they can be swept in a
  follow-up (or handed off incrementally as those views are touched).
- **Custom font registration:** N/A — the app uses the system font everywhere (0 `.custom(` fonts).

## Current state (audit, 2026-06-01)

- **~701 font usages total. ~614 already scale** — they use semantic Dynamic Type styles
  (`.body`, `.headline`, `.title`, …). These respond to the slider **today**.
- **~87 hardcoded `.system(size:)`** do **not** scale, across ~30 files.
- **Zero** `@ScaledMetric`, `relativeTo:`, custom fonts; **1** `dynamicTypeSize`; 13 `fixedSize`;
  2 `minimumScaleFactor`.
- **The Momentum type ramp is the single biggest lever.** `Momentum/MomentumDesignSystem.swift:72-78`
  defines 5 tokens as fixed `.system(size:)`, used **~37 times** — concentrated in
  `ContentView.CCV.12` (×12), `OnboardingWelcomeFlow` (×8), `AnalyticsDashboardView` (×5),
  `ContentView.CCV.11` (×4), `ReleaseNotesSheetView` (×1).
- **The two core surfaces mostly use *inline* fixed sizes, not the ramp**, so they need explicit
  conversion:
  - **Journal list rows** — `ContentView.CCV.10` / `CCV.11` (inline `.system(16/16/12/…)`).
  - **Note editor** — `ContentView.CCV.13` body uses `.system(size: CGFloat(writingFontSize))`
    (lines 877, 944); toolbar chrome in `CCV.14` includes **size-8** labels (lines 308, 318) —
    below accessibility minimums even today.
- **~36** fixed-height / `fixedSize` / `lineLimit(1)` occurrences across the 4 core files
  (`CCV.10/11/13/14`) = real clip risk at large text.

## Locked decisions

| # | Decision | Choice |
|---|----------|--------|
| Scope | How far this pass goes | **Foundation + core surfaces** (Journal list + Note editor). |
| Range | How far text scales | **Full range on reading surfaces; clamp chrome** to `xxxLarge`. |
| A | Card-title token | Map to **`.headline` (17pt)** — accept the 1pt drop from 18 for zero call-site churn. |
| B | Editor body vs OS slider | **Independent** — `writingFontSize` solely governs the writing area; the OS slider governs all other text. |

## Design

### 1. Foundation — `Momentum/MomentumDesignSystem.swift` (one file)

**1a. Scale the type ramp** (the `extension Font` at lines 72-78). Map the four text tokens to
semantic text styles, which scale automatically *and reactively* (SwiftUI re-renders on size change
because semantic fonts declare the dependency — unlike a static `UIFontMetrics` read, which would
not update live). Base sizes are preserved almost exactly:

```swift
extension Font {
    // Display: scales relative to .largeTitle, clamped so it can't run away.
    static func momentumHero(_ size: CGFloat = 72) -> Font {
        let scaled = UIFontMetrics(forTextStyle: .largeTitle)
            .scaledValue(for: size)               // clamp applied at the few call sites / view
        return .system(size: min(scaled, size * 1.6), weight: .bold)
    }
    static let momentumCardTitle = Font.headline                       // 18 → 17 semibold (decision A)
    static let momentumBody      = Font.callout                        // 16 → 16 (exact)
    static let momentumMetadata  = Font.footnote                       // 13 → 13 (exact)
    static let momentumSection   = Font.caption.weight(.semibold)      // 12 → 12 (exact)
}
```

Result: ~37 ramp uses across CCV.11/12, Onboarding, Analytics, ReleaseNotes scale with **zero
call-site edits** (call sites stay `.font(.momentumBody)` etc.).

> **Hero reactivity note (for the plan):** `momentumHero` reads the trait imperatively, so any
> hero-only view that contains *no* semantic/ramp text must establish the dependency (read
> `@Environment(\.dynamicTypeSize)`, or apply `@ScaledMetric`) to refresh live. Most hero call
> sites co-render with ramp text and refresh already. Verify per call site.

**1b. Chrome clamp helper.** A reusable modifier for dense chrome:

```swift
extension View {
    /// Cap Dynamic Type growth for dense chrome (toolbars, chip bars, tab rows).
    func chromeClamp() -> some View { dynamicTypeSize(...DynamicTypeSize.xxxLarge) }
}
```

Reading surfaces get **no** clamp (full range). Chrome containers get `.chromeClamp()`.

**1c. Scaled touch targets.** A `@ScaledMetric`-based helper so icon-button hit areas keep a ≥44pt
minimum as text grows (icons themselves may stay fixed; the *tap area* should not shrink relatively).
Exact shape (free function vs modifier vs small view) decided in the plan.

### 2. Core-surface adoption

**Journal list (`CCV.10` / `CCV.11`):**
- Convert inline row fonts (title / preview / timestamp ≈ `.system(16/16/12)`) to the scaling ramp
  (`momentumCardTitle` / `momentumBody` / `momentumMetadata`).
- Let rows grow vertically: remove fixed row heights, loosen `lineLimit` on titles, keep a sensible
  preview cap (e.g. `lineLimit(2…3)` that grows, not a fixed height).
- Filter-chip bar + top toolbar icon row: `.chromeClamp()`; confirm horizontal scroll/wrap holds
  (chip bar already scrolls horizontally).

**Note editor (`CCV.13` / `CCV.14`):**
- **Body writing area: leave on `writingFontSize`** (decision B) — explicitly *not* coupled to the
  OS slider.
- Toolbar chrome: convert to the scaling ramp + `.chromeClamp()`; **fix the size-8 labels**
  (`CCV.14:308,318`) up to a readable scaling token.
- Metadata chips: `.chromeClamp()`.

**Clip audit:** review the ~36 fixed-height / `fixedSize` / `lineLimit(1)` spots in `CCV.10/11/13/14`;
fix only those that actually clip at large sizes (don't churn ones that are fine).

### 3. Verification

- **Build** per project constraints (memory): building into the in-iCloud `.derivedData` fails
  CodeSign ("detritus" FinderInfo) despite 0 compile errors — build **out-of-iCloud** or with
  `CODE_SIGNING_ALLOWED=NO`. Both `.xcodeproj` build the shared `XJournal AI/` via synchronized
  groups; editing the existing files needs **no** manual target membership changes.
- **Type-check timeouts:** `CCV.12`-class large bodies are prone to expression-type-check timeouts.
  Keep edits minimal and localized; if a body trips the timeout, split the offending expression
  (don't add type erasure casually).
- **Dynamic Type previews:** add `#Preview`s of the Journal list and Note editor at
  **xSmall / Large(default) / xxxLarge / accessibility3 / accessibility5**; eyeball for clipping,
  overflow, and chrome breakage. The existing DEBUG preview harness can host these.

## Deliverables

1. Scaling Momentum ramp + `chromeClamp()` + scaled-touch-target helper (foundation).
2. Journal list + Note editor adopting the scaling ramp / clamps, clip fixes.
3. Dynamic Type previews for the two core surfaces.
4. **Audit map** — an in-repo markdown file (`docs/dynamic-type-offenders.md`) listing every
   remaining inline `.system(size:)` offender by file + line + recommended target token: the
   actionable backlog for the follow-up app-wide sweep. A one-line pointer to it goes in the
   Obsidian roadmap item.

## Risks / notes

- **Parallel editing:** Samuel edits the same branch concurrently. Keep the foundation change isolated
  to `MomentumDesignSystem.swift`; touch `CCV.10/11/13/14` in small, build-verified batches; re-check
  `git status`/`git diff` immediately before editing a shared file.
- **Semantic size shifts:** only `momentumCardTitle` shifts (18→17); body/metadata/section are exact.
- **`.chromeClamp()` ceiling:** `xxxLarge` chosen as the chrome cap; revisit per surface if a specific
  toolbar still breaks at `xxxLarge`.
- Document the outcome in the Obsidian vault (`XJournal AI - App`) per the docs-in-Obsidian convention,
  and tick the roadmap item.
