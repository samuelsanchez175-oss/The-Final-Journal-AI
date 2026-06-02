# Dynamic Type — remaining `.system(size:)` offenders (follow-up sweep backlog)

**Snapshot:** 2026-06-01. **Line numbers drift** (parallel editing) — regenerate before working:

```sh
grep -rno '\.system(size:[^)]*)' "XJournal AI"/*.swift "XJournal AI"/Momentum/*.swift
```

Context: the **foundation + core surfaces** pass is done (see
`docs/superpowers/specs/2026-06-01-dynamic-type-foundation-core-surfaces-design.md`). The Momentum
ramp scales, and the Journal list + Note editor are converted. What remains below are inline fixed
sizes on **non-core** screens. Convert each to the recommended semantic style (scales + reactive),
or — for large decorative SF Symbol glyphs in fixed layouts — decide per-case whether it should
scale at all. Wrap dense chrome in `.chromeClamp()`.

## Mapping cheat-sheet (default/"Large" base sizes)

| pt | token | | pt | token |
|----|-------|-|----|-------|
| 11 | `.caption2` | | 17 | `.body` |
| 12 | `.caption` | | 18 | `.headline` / `.title3` |
| 13 | `.footnote` | | 20–22 | `.title3` / `.title2` |
| 14 | `.subheadline` | | 24–28 | `.title2` / `.title` |
| 15 | `.subheadline` | | 32–34 | `.title` / `.largeTitle` |
| 16 | `.callout` | | ≥40 | decorative — see below |

- Monospaced: keep the design, e.g. `12 mono → .system(.caption, design: .monospaced)`.
- **Decorative hero glyph (≥40pt SF Symbol in a fixed circle/frame):** usually KEEP fixed (it's
  sized to its container). Only scale if it carries meaning — then `@ScaledMetric(relativeTo: .largeTitle)`.
- Add `.weight(...)` after the token to preserve weight (e.g. `.callout.weight(.medium)`).

## Intentional keeps (NOT offenders — do not convert)

| File:line | Why |
|-----------|-----|
| `ContentView.CCV.13.swift` :877, :944 | Editor body — user's own `writingFontSize` control (locked decision B). |
| `ContentView.CCV.11.swift` :296 | Empty-state hero glyph sized to fixed concentric circles (decorative). |
| `Momentum/MomentumDesignSystem.swift` :81 | `momentumHero` — already scaled via `UIFontMetrics`, clamped. |

## P1 — Design-system internals ✅ DONE 2026-06-01 (build verified)

All 5 converted in `Momentum/MomentumDesignSystem.swift`. Shared components, so the fix propagates app-wide.

| Component | Was | Applied |
|-----------|-----|---------|
| `FontSizeStepperPopover` — value readout | 17 semibold | `.body.weight(.semibold).monospacedDigit()` |
| `FontSizeStepperPopover` — ± glyphs | 15 bold | `.subheadline.weight(.bold)` (+ popover `.chromeClamp()` — fixed 38pt circles) |
| `MomentumChip` — icon | 12 semibold | `.caption.weight(.semibold)` |
| `MomentumChip` — text | 14 medium | `.subheadline.weight(.medium)` |
| `MomentumSquareButtonStyle` — label | 16 semibold | `.callout.weight(.semibold)` |

## P2 — High-traffic content screens ✅ DONE 2026-06-01 (build verified)

**19 text fonts converted** across RapSuggestionView, OnboardingWelcomeFlow, AnalyticsDashboardView,
CCV.12, ModelGControlSurfaceView, InlineAudioCardView, AudioDetailSheet (9 incl. monospaced/digit groups),
ReleaseNotesSheetView. **8 kept fixed** (decorative SF Symbol hero/control glyphs in fixed frames):
RapSuggestionView ×3 (empty-state icons), OnboardingWelcomeFlow `house.fill`, CCV.12 avatar,
InlineAudioCardView reload button, AudioDetailSheet play/pause, ReleaseNotesSheetView version-card icon.

| File:line | Was | → Applied |
|-----------|---------|---------------|
| `RapSuggestionView.swift` :261, :281, :319 | 48 | decorative glyph — review (likely keep) |
| `RapSuggestionView.swift` :1296 | 11 medium | `.caption2.weight(.medium)` + `.chromeClamp()` |
| `OnboardingWelcomeFlow.swift` :266 | 16 semibold | `.callout.weight(.semibold)` |
| `OnboardingWelcomeFlow.swift` :296 | 38 semibold | `.largeTitle.weight(.semibold)` (or `momentumHero`) |
| `AnalyticsDashboardView.swift` :441 | 32 bold | `.title.weight(.bold)` |
| `ContentView.CCV.12.swift` :125 | 15 semibold | `.subheadline.weight(.semibold)` |
| `ContentView.CCV.12.swift` :410 | 42 | decorative/title — review (`.largeTitle`?) |
| `ContentView.CCV.12.swift` :483 | 13 medium | `.footnote.weight(.medium)` |
| `ModelGControlSurfaceView.swift` :96 | 13 bold | `.footnote.weight(.bold)` |
| `ModelGControlSurfaceView.swift` :266 | 13 semibold | `.footnote.weight(.semibold)` |
| `ModelGControlSurfaceView.swift` :267 | 14 medium | `.subheadline.weight(.medium)` |
| `InlineAudioCardView.swift` :368 | 17 regular | `.body` |
| `InlineAudioCardView.swift` :496 | 16 | `.callout` |
| `AudioDetailSheet.swift` :319 | 22 bold | `.title2.weight(.bold)` |
| `AudioDetailSheet.swift` :765 | 17 regular | `.body` |
| `AudioDetailSheet.swift` :1020, :1206, :1254 | 12 medium mono | `.system(.caption, design: .monospaced).weight(.medium)` |
| `AudioDetailSheet.swift` :1067, :1232, :1279 | 12 medium | `.caption.weight(.medium)` |
| `AudioDetailSheet.swift` :1492 | 32 semibold mono | `.system(.title, design: .monospaced).weight(.semibold)` |
| `AudioDetailSheet.swift` :1524 | 36 | `.largeTitle` (or decorative) |
| `ReleaseNotesSheetView.swift` :155 | 26 semibold | `.title.weight(.semibold)` |
| `ReleaseNotesSheetView.swift` :169 | 10 bold | `.caption2.weight(.bold)` |

## P3 — Sheets, banners, badges, splash ✅ DONE 2026-06-01 (build verified)

**8 text fonts converted** (AIErrorBanner ×5 — glyph + title + message + dismiss + fix label;
AchievementBadgeView stat readout; SplashScreenView app name; ThemeExpansionSheet header).
**28 kept fixed** (decorative SF Symbol hero/empty-state/avatar/control glyphs in fixed frames, +
proportional `size * 0.x` badge glyphs). 15 P3 files needed no edits at all.

| File:line | Was | → Applied |
|-----------|---------|---------------|
| `AIErrorBanner.swift` :33 | 18 semibold | `.headline` |
| `AIErrorBanner.swift` :37 | 14 bold | `.subheadline.weight(.bold)` |
| `AIErrorBanner.swift` :41 | 13 | `.footnote` |
| `AIErrorBanner.swift` :53 | 18 | `.title3` |
| `AIErrorBanner.swift` :67 | 14 semibold | `.subheadline.weight(.semibold)` |
| `AchievementBadgeView.swift` :26, :31 | `size*0.4`, `size*0.3` | proportional to badge size — likely keep |
| `AchievementBadgeView.swift` :88 | 40 semibold | decorative — review |
| `AchievementBadgeView.swift` :94 | 12 | `.caption` |
| `AchievementBadgeView.swift` :194 | 48 bold | decorative — review |
| `SplashScreenView.swift` :30 | 14 semibold | `.subheadline.weight(.semibold)` |
| `SplashScreenView.swift` :187 | 60 | decorative — review |
| `SplashScreenView.swift` :202 | 32 bold | `.title.weight(.bold)` |
| `SplashScreenView.swift` :263 | 16 medium | `.callout.weight(.medium)` |
| `SplashScreenView.swift` :468 | 48 medium | decorative — review |
| `SplashScreenView.swift` :621, :627 | 24 bold | `.title2.weight(.bold)` |
| `ThemeExpansionSheet.swift` :126 | 64 | decorative — review |
| `ThemeExpansionSheet.swift` :137 | 32 bold | `.title.weight(.bold)` |
| `ThemeExpansionSheet.swift` :268 | 32 | `.title` |
| `SocialPostCardView.swift` :52, :130 | 60 | decorative — review |
| `SocialPostCardView.swift` :113 | 80 | decorative — review |
| `ProactiveFeedbackView.swift` :53 | 48 | decorative — review |
| `ProactiveFeedbackView.swift` :105 | 32 | `.title` |
| `SuggestionFavoriteManager.swift` :88, :167 | 48 | decorative — review |
| `ImportNotesInstructionsView.swift` :48 | 64 | decorative — review |
| `ImportNotesInstructionsView.swift` :125 | 48 | decorative — review |
| `SupportShopSheetView.swift` :183 | 28 semibold | `.title.weight(.semibold)` |
| `APIDebugInspector.swift` :457, :478 | 48 | decorative (DEBUG only) — low priority |
| `WhisperMicButton.swift` :150 | 18 medium | `.headline.weight(.medium)` |
| `AudioRecorderView.swift` :115 | 44 | decorative — review |
| `RapTrackPlaybackView.swift` :344 | 60 | decorative — review |
| `SocialFeedView.swift` :248 | 60 | decorative — review |
| `PaywallView.swift` :63 | 64 | decorative — review |
| `CouponRedemptionView.swift` :22 | 64 | decorative — review |
| `ExportSheet.swift` :35 | 48 | decorative — review |
| `ARCritiqueSheet.swift` :68 | 48 | decorative — review |
| `StyleTransferSheet.swift` :27 | 48 | decorative — review |
| `UpgradePromptView.swift` :18 | 40 | decorative — review |

**Summary: ✅ COMPLETE 2026-06-01.** P1 (5) + P2 (19) + P3 (8) = **32 text fonts converted to scale**;
all build-verified. Every remaining `.system(size:)` in the app is an **intentional keep** — verified
2026-06-01: decorative/control SF Symbol glyphs in fixed frames, proportional `size * 0.x` badge
glyphs, the scaled `momentumHero`, and the editor `writingFontSize` body (decision B). **No
text-bearing fixed fonts remain.** Re-run the grep at the top to confirm; new code should use
semantic styles (or a documented decorative-keep).
