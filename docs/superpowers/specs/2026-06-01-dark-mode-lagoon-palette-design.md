# Dark Mode — "Lagoon" Palette & Scheme-Aware Tokens

**Date:** 2026-06-01
**Status:** Implemented (2026-06-01) — builds green (`The Final Journal AI` scheme, simulator). In-app testable via Profile → App → Appearance. See **Implementation note** for how the shipped model refined this design.
**Goal:** Define the dark-mode color palette ("Lagoon" — green→blue, dark background) as the cool-half mirror of the light "Coral" system, and convert the `Momentum` design tokens to resolve light/dark automatically. This is the **palette + token foundation only** — the per-screen dark-mode audit is a separate, later effort.

---

## Implementation note — what shipped (2026-06-01)

The build refined the design in one important way, at Samuel's direction: **the accent picker doubles as the Light/Dark switch.** Rather than a separate `LagoonPreset` enum surfaced only in dark, the seven cool colors were appended to the existing `CoralPreset` enum (each flagged `isDark`), and a **7th** was added — **Mint `#2BD49A`** at the green end. `CoralAppearanceSection` now renders two labeled rows (**Light** = the 6 warm coral; **Dark** = the 7 cool Lagoon). Tapping a swatch sets the accent **and** writes `@AppStorage("appTheme")` — the key [`The_Final_Journal_AIApp.swift`](../../../XJournal AI/The_Final_Journal_AIApp.swift) already feeds to `.preferredColorScheme` — so a cool swatch flips the whole app to dark, a warm one back to light.

Divergences from the originally-approved design below:
- **One enum, not two.** `CoralPreset` now holds warm + cool (backward-compatible — the 6 warm raw values are unchanged). `Momentum.accent` stays `CoralSettings.preset.color`; no scheme branch is needed, since the single selected preset *is* the accent in both modes.
- **No separate dark default.** "Viridian as dark default" is moot under one unified picker (the user just taps); its hex is retained in the family.
- **Section header** "Coral" → **"Appearance"** (it now governs light/dark too).
- The dynamic `Color(light:dark:)` token mechanism and all token *values* shipped exactly as specified below.

Everything below describes the originally-approved design; the points above are the only divergences.

## Background — the seam already exists

[`MomentumDesignSystem.swift`](../../../XJournal AI/Momentum/MomentumDesignSystem.swift) is the canonical design system, and it was built light-first with a dark seam left open:

- **`ThemeMode`** enum already has `.light / .dark / .warm / .system` with a `colorScheme` resolver (`MomentumDesignSystem.swift:70`). Comment: *"Light default; editorial-dark deferred, seam kept."*
- **`Momentum`** tokens are **static, light-only** values (`surface 0xF8F8F8`, `contentPrimary 0x1C1C1E`, etc., `:32–56`). They do **not** respond to color scheme.
- **`CoralPreset`** is a 6-swatch warm accent family (`classic/blush/ember/apricot/rose/plum`, `:94`); **`CoralSettings`** stores the chosen preset + glow strength in `@AppStorage` (`:122`); `Momentum.accent` resolves to `CoralSettings.preset.color` (`:39`).
- **`AtmosphereGlow`, `EditorCoralGlow`, `EditorHeaderCoralBackground`** already branch on `@Environment(\.colorScheme)` with dark-tuned opacities and a placeholder dark base `0x121214` (`:152–161`, `:213`, `:259`) — but they read the **Coral** preset for the glow color in both schemes.

So dark mode needs: (1) real dark token **values**, (2) a **mechanism** to resolve tokens by scheme, and (3) a **Lagoon accent family** parallel to Coral.

---

## The palette — "Lagoon" (the deliverable)

### Accent family — `LagoonPreset` (cool mirror of `CoralPreset`)

| Case | Label | Hex | Hue |
|---|---|---|---|
| `jade` | Jade | `#1AB082` | green |
| `viridian` ◉ **default** | Viridian | `#0E9E92` | green-teal |
| `teal` | Teal | `#0C97B4` | teal |
| `marine` | Marine | `#1E8AD4` | blue |
| `cobalt` | Cobalt | `#3A6CE4` | blue |
| `iris` | Iris | `#5F66EA` | blue-violet |

Default = **Viridian** (`#0E9E92`). Order runs green→blue so the picker reads as a gradient (the "dynamic" quality chosen during brainstorming). "Marine" is the renamed namesake swatch so the *family* can be called Lagoon.

### Core tokens — light value → dark value

| Token | Light (unchanged) | Dark (Lagoon) | Role |
|---|---|---|---|
| `surface` | `#F8F8F8` | `#0C1417` | app background; also `AtmosphereGlow` base |
| `surfaceElevated` | `#FFFFFF` | `#16201F` | cards, sheets (lifted one step) |
| `contentPrimary` | `#1C1C1E` | `#E6EEF0` | titles, body, section rules, `MainDivider` |
| `contentSecondary` | primary @ 60% | primary @ 60% | metadata (alpha rule unchanged) |
| `hairline` | primary @ 10% | primary @ 12% | 1px rules (dark needs a touch more) |
| `inverseSurface` | `#1C1C1E` | `#E6EEF0` | high-emphasis primary button / emphasis banner — **flips** |
| `onInverse` | `#F8F8F8` | `#0C1417` | ink on inverse **and** on accent fills — **flips** |
| `accentCalm` | `#6688FF` | `#7E9FE0` | empathy / reset states only |
| `accent` | Coral preset | **Lagoon preset** | resolves by scheme **and** user pick (see below) |

**Why `onInverse` flipping is the nice part:** `MomentumSquareButtonStyle` already paints accent-filled buttons with `Momentum.onInverse` text (`:438`). Once `onInverse` is dark in dark mode, accent buttons automatically get **dark ink on the bright jewel accent** (high contrast) — no button-style edits needed.

### Editor highlight tints — dark values (deferred refinement)

`highlightPink/Green/Yellow` (`:53–55`) are bright pastels used for rhyme highlighting; on dark they must become **translucent washes**, not solid pastels. Provisional dark set, to be finalized in the editor dark pass (out of scope here):

| Token | Dark value |
|---|---|
| `highlightGreen` | `#1AB082` @ ~18% |
| `highlightPink` → cool | `#3A6CE4` @ ~18% (pink doesn't belong in the cool palette; rhyme groups recolor to accent-family hues) |
| `highlightYellow` | `#E8C24A` @ ~16% (one warm note retained for legibility) |

---

## Decisions (from brainstorming)

| Decision | Choice | Rationale |
|---|---|---|
| Direction | **Tide** (balanced green→blue) | "Most dynamic" — widest range, reads literally as "green and blue" |
| Character | **Lagoon** (deep, jewel-toned) | Richest / most premium of the variations |
| Default accent | **Viridian** `#0E9E92` | User pick; green-teal anchor |
| Family name vs swatch | Family = **Lagoon**; namesake swatch renamed **Marine** | User: "keep that" |
| Token mechanism | **Dynamic `UIColor` provider** (resolve by scheme) | Zero blast radius — consumers keep using `Momentum.x`; no `@Environment` threading |
| Accent in dark | **Separate Lagoon picker**, chosen by scheme | Light keeps Coral; dark gets its own cool family |
| Strength / breathing | Lagoon gets its own `strength`; **breathing toggle shared** | Glow reads differently per scheme; breathing is behavior, not color |

---

## Architecture — scheme-aware tokens via dynamic colors

The crux: `Momentum` is a static enum with no view context, so it can't read `@Environment(\.colorScheme)`. Solution — back each token with a **dynamic `UIColor`** that resolves at render time. Consumers (`Momentum.surface`, etc.) are **unchanged**; they simply return the right value for the active scheme.

```swift
import UIKit   // for UIColor(dynamicProvider:)

extension Color {
    /// A color that resolves light/dark automatically — no @Environment needed.
    init(light: UInt, dark: UInt, lightAlpha: Double = 1, darkAlpha: Double = 1) {
        self = Color(UIColor { tc in
            tc.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark, alpha: darkAlpha))
                : UIColor(Color(hex: light, alpha: lightAlpha))
        })
    }
}
```

Tokens become, e.g.:

```swift
static let surface         = Color(light: 0xF8F8F8, dark: 0x0C1417)
static let surfaceElevated = Color(light: 0xFFFFFF, dark: 0x16201F)
static let contentPrimary  = Color(light: 0x1C1C1E, dark: 0xE6EEF0)
static let contentSecondary = contentPrimary.opacity(0.6)   // works in both
static let hairline        = Color(light: 0x1C1C1E, dark: 0xE6EEF0, lightAlpha: 0.10, darkAlpha: 0.12)
static let inverseSurface  = Color(light: 0x1C1C1E, dark: 0xE6EEF0)
static let onInverse       = Color(light: 0xF8F8F8, dark: 0x0C1417)
static let accentCalm      = Color(light: 0x6688FF, dark: 0x7E9FE0)
```

**Accent — depends on scheme AND user pick.** The dynamic provider reads the right preset family inside the closure:

```swift
static var accent: Color {
    Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(LagoonSettings.preset.color)
            : UIColor(CoralSettings.preset.color)
    })
}
```

Data flow:

```
Device / ThemeMode  ──►  userInterfaceStyle (.light / .dark)
                              │  read inside every token's dynamic provider
                              ▼
   Momentum.surface / contentPrimary / accent / …  ──►  correct value, no consumer change
                              ▲
   CoralSettings.preset (light)   LagoonSettings.preset (dark)   ◄── user pick per scheme
```

---

## Component changes (all in `MomentumDesignSystem.swift` unless noted)

1. **`Color(light:dark:…)` helper** — new initializer (above); `import UIKit`.
2. **`Momentum` tokens → dynamic** — convert `surface, surfaceElevated, contentPrimary, contentSecondary, hairline, inverseSurface, onInverse, accentCalm` to `Color(light:dark:)`; convert `accent` to the scheme+preset resolver. Highlight tints get dynamic values too (provisional dark set above).
3. **`LagoonPreset`** — new enum mirroring `CoralPreset`: 6 cases (`jade, viridian, teal, marine, cobalt, iris`), `label`, `hex`, `color`. Default `.viridian`.
4. **`LagoonSettings`** — new enum mirroring `CoralSettings`: `presetKey = "lagoon_preset"`, `strengthKey = "lagoon_strength"`, `defaultStrength = 0.5`, `preset`/`strength` resolvers. **Reuses** the existing `coral_breathing_in_editor` key (breathing is shared).
5. **Glow structs** (`AtmosphereGlow`, `EditorCoralGlow`, `EditorHeaderCoralBackground`) — pick the preset family by scheme: add `@AppStorage(LagoonSettings.presetKey)` + `@AppStorage(LagoonSettings.strengthKey)` and select Coral vs Lagoon on `scheme == .dark`. Replace the hardcoded dark base `0x121214` with `Momentum.surface` (now dynamic → `0x0C1417`). Existing dark opacity branches stay.
6. **Accent picker UI** (`CoralAppearanceSection`) — when the active scheme is dark, show the **Lagoon** swatches + a "Lagoon" header bound to `LagoonSettings` keys; light shows Coral as today. (Section header label switches "Coral"↔"Lagoon".) Lives in Profile → App, where `CoralAppearanceSection` already renders.

---

## Edge cases

- **`Color(hex:)` inside a dynamic provider** — `UIColor(Color(hex:...))` round-trips through SwiftUI `Color`; resolved once per trait change, so cost is negligible.
- **`.warm` ThemeMode** — maps to `.light` (`ThemeMode.colorScheme`), so it uses the Coral/light side. Unaffected.
- **Snapshot / non-UIKit contexts** — dynamic colors resolve to the trait collection's style; in a `nil`/unspecified style they default to light. Acceptable.
- **Coral-named `@AppStorage` in glow structs** — adding the Lagoon keys is additive; existing stored Coral prefs untouched.
- **Existing explicit `scheme == .dark ? Color.white : …` branches scattered in other files** — out of scope; they keep working. The dynamic tokens make them redundant over time but this spec does not chase them.

---

## Dependencies to verify during planning

- **Is `ThemeMode` actually applied** (via `.preferredColorScheme` on the root) and reachable from a setting? The seam exists but may be inert. If dark isn't user-reachable, planning must add a minimal apply point (or rely on `.system` so the palette shows when the device is in dark mode). Confirm before estimating the picker-UI task.

---

## Non-goals

- **No full app-wide dark-mode audit.** The ~100 files with hardcoded `Color.white` / `Color.black` / literal hexes are **not** swept here. This spec delivers the palette + token foundation; per-screen darkening is a later effort.
- No redesign of any individual screen.
- No new `ThemeMode` UX beyond surfacing the existing seam if required (see Dependencies).
- No change to `CoralPreset` or the light theme.
- No editor rhyme-highlight retune (dark highlight values are provisional placeholders here).

---

## Verification

- **Build:** `xcodebuild -scheme "XJournal AI" -destination 'platform=iOS Simulator,name=iPhone 17' build` → BUILD SUCCEEDED (default DerivedData, **not** in-iCloud `.derivedData/`; or `CODE_SIGNING_ALLOWED=NO` for a compile-only check).
- **Manual QA:**
  1. Device/sim in **Light** → app looks exactly as today (Coral unchanged).
  2. Switch to **Dark** → `surface #0C1417`, light text, light section rules; AtmosphereGlow blooms in the Lagoon accent (not coral).
  3. Profile → App in dark → **Lagoon** picker (6 cool swatches), default **Viridian** ringed; switching swatch retints accent + glow live.
  4. Accent-filled button in dark → bright accent with **dark** ink (legible); inverse "Generate" button → light fill with dark text.
  5. Toggle Light↔Dark repeatedly → no stale colors (dynamic colors re-resolve).

---

## Files touched

| File | Change |
|---|---|
| `XJournal AI/Momentum/MomentumDesignSystem.swift` | `Color(light:dark:)` helper + `import UIKit`; tokens → dynamic; `accent` scheme+preset resolver; new `LagoonPreset` + `LagoonSettings`; glow structs pick family by scheme; `CoralAppearanceSection` shows Lagoon picker in dark |
| (verify) root view applying `.preferredColorScheme` | Only if `ThemeMode` is currently inert and dark must be user-reachable |
