# Momentum UI Reskin — Design Spec

- **Date:** 2026-05-31
- **Branch:** `ui-momentum-reskin` (off `phase-0-quick-wins`)
- **Status:** Living spec — Samuel building against it (P0 done; P1 in progress). Updated with app-specific mockups 2026-05-31.
- **Type:** Visual-only UI reskin. No feature, logic, data, or navigation changes.
- **Source refs:** exported HTML mockups in `~/Downloads/design-*.html` — first the "Momentum" habit-tracker style refs, then **app-specific** screens (Note Detail + Metadata editor, Profile/Settings, Home/Create/Editor) drawn with these exact tokens. Related Obsidian docs: `XJournal AI - App/UI Overhaul — Phased Plan.md`, `UX — Slow, Dark & Hard to Use.md`.

---

## 1. Goal & scope

Reskin **the entire app** from the current dark "Silk Boys" glass aesthetic to a **light, editorial, flat** look — directly answering the documented complaint that the app feels *slow, dark, and hard to use*.

**Decisions locked with Samuel:**
- Ambition: **full reskin → light** — retire glass from **content** surfaces; floating chrome stays frosted (see **Surface rules**, §3).
- Coverage: **entire app**.
- Accent: **coral `#FF8C66`** (reuses the existing `RhymeColorPalette` coral).
- Dark mode: **light default now, editorial-dark deferred** to a later pass (clean seam left for it).
- **Signature elements (must-keep, Samuel 2026-05-31):** the **line work** (thin/thick rules + line-art circles), the **soft coral atmosphere glow**, and the **square buttons** (sharp corners — never rounded/pill). These constrain every component below.

**Critical framing (Samuel, 2026-05-31):** The HTML files are **style references, not screens to copy literally.** We do **not** import their habit-tracker *features* (day streaks, friend leaderboards, habit checkboxes, nudges). We extract the **visual language + reusable component patterns**, compare them to the app's **current** structure, and map each style pattern onto what already exists. Where a mockup concept has no analog in this app, we borrow the visual treatment only — or skip it.

**Hard constraint:** The **LOCKED PAGE MAP** in `ContentView.swift` is preserved. We reskin surfaces; we do not move, add, or remove pages. All button handlers, `@State`, queries, and behaviors stay wired exactly as they are.

---

## 2. Current state (what we're changing)

**App:** XJournal AI turns journal entries / voice notes into Gunna/Young-Thug-lineage melodic-trap lyrics (co-writer). North-star = the Authenticity Score (0–100).

**Navigation:** Single root, **no tab bar**. `ContentView` → `JournalLibraryView` (a `NavigationSplitView`). Secondary screens are sheets.

| Current screen | File(s) | Role |
|---|---|---|
| Home / Journal Library | `ContentView.CCV.10.swift` (shell), `CCV.11` (list/row/empty) | Notes list, filter chips, 5 top-bar icons, bottom search, quick-compose |
| Note Editor + keyboard toolbar | `CCV.13` (editor/cards), `CCV.14` (`DynamicIslandToolbarView`) | Writing surface, rhyme highlighting, AI-assist, magnifier |
| Generation & results | `RapSuggestionView.swift` | Verse generation + results |
| Analytics | `AnalyticsDashboardView.swift` | Stats, charts, section tabs, social feed |
| Achievements | `AchievementBadgeView.swift` | Badges, collection, celebration |
| Settings | `CCV.12` | Account / keys / subscription / audio |
| Paywall · Support/Shop · Release Notes · Splash | `PaywallView`, `SupportShopSheetView`, `ReleaseNotesSheetView`, `SplashScreenView` | Sheets / launch |
| Glass design system | `GlassEffectComponents.swift`; `GlassSettings` / `SoftBlueGlassStyle` / `RhymeColorPalette` in `CCV.2` | The aesthetic we're replacing |

**Why it reads "dark / low quality" (measured in the audit):** `.ultraThinMaterial` + `Color.black` overlay everywhere; `.foregroundStyle(.secondary)` ×270; `.font(.caption/.caption2)` ×246; `.opacity(≤0.6)` ×148 → faded, tiny, translucent micro-text on muddy glass. Two screens are **hard-coded dark** and ignore `colorScheme`: `AchievementBadgeView`, `SplashScreenView`.

---

## 3. The Momentum style kit (named + ordered)

The 32 patterns below are **reusable SwiftUI views/styles**, not features. New code lives in a `Momentum/` group; tokens in `MomentumDesignSystem.swift`. Ordered by build dependency (foundation first).

**Signature elements (non-negotiable — Samuel):** every component must preserve (1) **line work** — `lineThin`/`lineThick` rules + the thin-bordered line-art circles; (2) the **soft coral atmosphere glow** (`AtmosphereGlow`); (3) **square buttons** — sharp corners, thin or thick borders, fill-on-press; never rounded or pill-shaped.

### Design tokens
| Token | Value | Replaces |
|---|---|---|
| `surface` / `surfaceElevated` | `#F8F8F8` / `#FFFFFF` | `.ultraThinMaterial` base |
| `contentPrimary` / `contentSecondary` | `#1C1C1E` / `rgba(28,28,30,0.6)` | `.primary` / `.secondary` (raises contrast) |
| `accent` | coral `#FF8C66` | gold/blue glass tints |
| `accentCalm` | blue `#6688FF` | — (empathy/reset states only) |
| `inverseSurface` / `onInverse` | `#1C1C1E` / `#F8F8F8` | — (emphasis banner, primary button) |
| `lineThick` / `lineThin` | 3px / 1px | heavy shadows + dividers |
| `edge` | 24px | ad-hoc paddings |
| `corners` | **square / sharp (0–2px)** for cards, action buttons, toggles. *Rounded exceptions:* metadata pills (BPM/Key/Scale), counters, key-grid circles, and frosted floating chrome — see **Surface rules**. 44pt targets via size | 20pt glass radius |
| Type: `heroNumeral` (≈64–80pt, w700, tight) · `sectionTitle` (12pt UPPERCASE +tracking, secondary) · `cardTitle` (18pt w600) · `bodyContent` (**≥16pt**) · `metadata` (13pt) | | sub-16pt captions for content |

### Components (build layers)
**Layer 0 — foundation:** `1. DesignTokens` · `2. AtmosphereGlow` (radial coral top-glow + slow pulse; blue variant) · `3. SectionHeader` (UPPERCASE label + thin rule) · `4. MainDivider` (3px rule).
**Layer 1 — list/home:** `5. AppHeader` (wordmark + action) · `6. HeroStat` (giant numeral + label) · `7. LibraryRowCard` (flat, border-separated) · `8. FAB` (floating ＋).
**Layer 2 — data/analytics:** `9. MonthSelector` · `10. EmphasisBanner` (inverted dark card) · `11. BarChart` · `12. BreakdownRow` (label + value + thin track) · `13. StatGrid` (hairline 2-col boxes).
**Layer 3 — ranked/badge lists:** `14. BackNav` · `15. ViewTitleBlock` (title + subtitle) · `16. RankRow` (index + avatar + mini-bar + value) · `17. HighlightRow` (tinted self) · `18. PillButton` (outline action).
**Layer 4 — empty/empathy:** `19. HeroGraphic` (concentric circles + faded numeral) · `20. EmpathyCopyBlock` (headline + sub) · `21. PrimaryActionButton` (full-width, trailing icon) · `22. SecondaryLink`.
**Signature additions (apply across layers):** `23. SelectionToggle` (square check — sharp, thin/thick border, fills dark + checkmark on select) · `24. CircleLineGraphic` (thin-border concentric line-art circles; spin/sink/pop animation; the core of `HeroGraphic` & celebration) · `25. SuggestionGrid` (multi-select square-toggle cards + `SectionHeader` + footer `PrimaryActionButton` + coral `CounterPill`).

> All buttons (`PrimaryActionButton`, `PillButton`, `FAB`, `SelectionToggle`) are **square**. The coral glow + line-art circles are the recurring ambient motif.

### Surface rules (glass — "chrome frosted, content flat", Samuel 2026-05-31)
The app-specific mockups keep glass in specific places. Canonical 3-way split:
- **Flat + square + line work:** content cards, list rows, action buttons, selection toggles, stat boxes, dividers.
- **Frosted + rounded (`momentumFloatingBar`):** *floating chrome only* — bottom search bar, editor/keyboard toolbar, bottom sheets (e.g. the metadata editor). `.ultraThinMaterial` is **allowed here** — this is why `momentumFloatingBar` is kept, not retired.
- **Rounded pills / circles:** *data, not actions* — metadata pills (BPM/Key/Scale), the counter pill, the musical-key circle grid.

So "retire glass" = **retire it from content surfaces**, not from floating chrome.

### Layer 5 — app-specific (from the Journal/Lyrics mockups)
`26. MetadataPill` (icon + value, color-by-type via `pillBPM`/`pillKey`/`pillScale`) · `27. MetadataEditorSheet` (frosted bottom sheet: Tempo tap+stepper · `NoteKeyGrid` · Scale pills) · `28. ToggleSwitch` (iOS pill toggle) · `29. ThemeSegmentedControl` (Light/Dark/Warm) · `30. Avatar` (gradient initials) · `31. EditorToolbar` (structure marks + `HighlightSwatch` ×3 + mic, in a frosted bar) · `32. MusicPlatformRow` (icon + name + Connected/Link).

---

## 4. Mapping: current structure → new look (the core)

For each existing surface: which style patterns apply, the concrete change, and explicit no-analog calls. **Across every surface:** keep the **line work**, **soft coral glow**, and **square buttons** (Samuel's must-keeps).

### Home / Journal Library — `CCV.10` / `CCV.11`
- **Background:** add `AtmosphereGlow`; swap `.ultraThinMaterial` base → `surface`.
- **Title:** keep "Journal" `navigationTitle`; render as an editorial large title (optionally `AppHeader`). *No streak/HeroStat invented here — there's no day-streak feature.*
- **Filter chips** (`page1FiltersView`): flat pills, thin border, **coral** when active.
- **Note rows** (`JournalRowView`): glass card → `LibraryRowCard` (flat `surfaceElevated`, `lineThin` bottom separator, `cardTitle` + `metadata`; drop gradient/heavy shadow). Selection-mode checkmark → square `SelectionToggle`.
- **Empty state** (`JournalEmptyStateView`): → `HeroGraphic` + `EmpathyCopyBlock` + `PrimaryActionButton` ("New Note").
- **Bottom search bar / quick-compose:** restyle flat; compose button → `FAB` treatment.
- **Top-bar icons (5):** monochrome line icons on light; per the existing Phase-5 note, **demote shop/achievements** visually so Write/Record/Generate reads as primary. *(Visual de-emphasis only — icons stay, page map unchanged.)*

### Analytics — `AnalyticsDashboardView.swift`
The natural home for the big-number patterns (it already has real stats).
- Section `Picker` tabs → flat `SectionHeader` + restyled segmented control.
- `StatCard` / `StatRow` → `StatGrid` (hairline) + `EmphasisBanner` for the headline figure (e.g. **best Authenticity Score**) — `HeroStat` type scale here.
- Existing charts → `BarChart` style (flat bars, current period faded).
- Per-dimension stats (rhyme / flow / cadence / authenticity) → `BreakdownRow` (label + % + thin track).

### Achievements — `AchievementBadgeView.swift`
- `ViewTitleBlock` header; badge/collection rows adopt the `RankRow` visual (index/icon + label + progress track + value).
- `CategoryFilterButton` → flat pills.
- **Fix the hard-coded dark gradient** so it respects tokens (currently identical in light & dark).
- **Celebration** (`AchievementCelebrationView`) ← Milestone mockup: `CircleLineGraphic` (spinning) + big `heroNumeral` + `headline` + square `PrimaryActionButton` ("Share") + square secondary ("Keep going"). Reskin the existing unlock celebration; wire to real achievement values, not a streak.
- *No-analog:* the mockup's **friend leaderboard / nudge** has no social-ranking feature — borrow the `RankRow` layout only; **do not build social ranking**.

### Empty / re-engagement — `JournalEmptyStateView`, `ChurnInterventionManager` screens
- Empty journal + comeback/churn screens → empathy layout: `HeroGraphic` + `EmpathyCopyBlock` + `PrimaryActionButton`.
- Use **blue `accentCalm` + blue `AtmosphereGlow`** for the gentle "come back / start again" tone (matches the reset mockup).
- *No-analog:* "streak reset" copy is illustrative — wire it to real empty/churn triggers, not a streak counter.

### Note Editor + keyboard toolbar — `CCV.13` / `CCV.14`
- Writing surface → `surface`; brighten body text to `contentPrimary` (≥16pt).
- Keyboard toolbar (`DynamicIslandToolbarView`) + AI-assist menu → **frosted floating bar** (`momentumFloatingBar`, per Surface rules — chrome, *not* a flat card): structure marks + 3 `HighlightSwatch` color buttons + mic; preserve collapse/expand (Segment 5).
- ⚠️ **Risk:** rhyme-highlight colors (`RhymeColorPalette`) were tuned for dark glass. **Re-tune the highlight palette for legibility on a light surface** (perfect vs near-rhyme must stay distinguishable + readable). Treat as its own verified sub-task.
- Preserve all locked Page-3 behaviors (eye toggle, magnifier, AI-assist read-only).

### Generation & results — `RapSuggestionView.swift`
- **Steering (topic / tone / world-building word selection)** ← Welcome mockup: multi-select `SuggestionGrid` — square `SelectionToggle` cards under `SectionHeader`s, fixed footer `PrimaryActionButton` "Generate" with coral `CounterPill` showing # selected. Strong direct analog (the app already multi-selects topics/tones to steer Model G).
- Results cards → `LibraryRowCard` / `Surface`; CTAs → `PrimaryActionButton`.
- Per the Phase-4 note, lean toward **one primary Generate** + a "Customize" disclosure (visual hierarchy only; no logic change).

### Note Detail + Metadata editor — note detail (`CCV.12`) + metadata sheet ← Detail/Metadata mockup
- **Detail view:** `BackNav` + history/regenerate + add icons; centered title (22pt `cardTitle`); horizontal **`MetadataPill`** row (BPM blue / Key purple / Scale — via existing `pillBPM`/`pillKey`/`pillScale` tokens); lyric body in `bodyContent` with rhyme **highlight** spans (`highlightPink/Green/Yellow`).
- **Metadata editor** (`MetadataEditorSheet` — frosted bottom sheet): **Tempo** = big `heroNumeral` + Tap card + −/＋ stepper · **Key** = `NoteKeyGrid` (6-col circles) · **Scale** = rounded pills (selected `inverseSurface`); coral "Done".
- Pills/circles **rounded** (data); sheet **frosted** (chrome); lyric cards/buttons stay flat & square.

### Profile / Settings — `CCV.12` ← Profile mockup
- `BackNav` + "Settings"; **`Avatar`** (coral→peach gradient initials) + name + uppercase role/location.
- **`StatGrid`** (3-col, hairline dividers) — *only stats the app already tracks; no new streak feature.*
- `sectionTitle` sections: **Appearance** → `ThemeSegmentedControl` (Light/Dark/Warm = your `ThemeMode`) · **Notifications** → label + `ToggleSwitch` · **Music Platforms** → `MusicPlatformRow` (Spotify/Apple Music/Suno/Genius/Uberduck: icon + name + Connected/Link).
- Destructive **Log Out** in red.

### Everything else — Settings (`CCV.12`), Paywall, Support/Shop, Release Notes, Splash
- **Systematic token sweep:** `.ultraThinMaterial` → `Surface`; `.secondary` → `contentPrimary`/`contentSecondary`; sub-16pt content captions → `bodyContent`; CTAs → `PrimaryActionButton`.
- Release Notes is already an editorial sheet (Segment 1) — light it up, keep structure.
- **Fix hard-coded-dark `SplashScreenView`** to render light.

---

## 5. Non-goals (YAGNI)

- ❌ No new features: no day streaks, no social/friend leaderboard, no habit checkboxes, no nudges.
- ❌ No structural/navigation changes — the LOCKED PAGE MAP is untouched; no new tab bar.
- ❌ No logic, data-model, scoring, or generation-pipeline changes.
- ❌ No editorial **dark** rebuild this pass (deferred; seam left in tokens).
- ❌ No copy rewrites beyond what a restyle requires.

---

## 6. Sequencing (phases)

Each phase is independently shippable and screenshot-verified (light mode).

| Phase | Scope | Components |
|---|---|---|
| **P0 Foundation** | `MomentumDesignSystem.swift` (tokens + type + flat `Surface`) + Layer-0 primitives. No screen changes yet. Builds on existing Phase-0 WIP. | 1–4 |
| **P1 Home + core flow** | Journal Library + rows + filters + empty state + search/compose; **generation steering (multi-select) & results**. | 5–8, 19–25 |
| **P2 Analytics** | Charts, stat grid, emphasis banner, breakdown rows. | 9–13 |
| **P3 Achievements** | Badge/collection rows + **unlock celebration** + fix hard-coded-dark. | 14–18, 24 |
| **P4 Empty/churn** | Empathy flows (empty journal, comeback). | 19–22 |
| **P5 App-wide sweep** | Editor readability + rhyme-palette re-tune; settings/paywall/shop/release; fix Splash. | tokens |
| **P6 Glass scoping** | Retire glass from **content** surfaces; keep frosted floating chrome (`momentumFloatingBar`). Remove dead `GlassEffectComponents`/`SoftBlueGlass` paths; leave editorial-dark seam. | — |
| **P7 Polish** | Atmosphere animation, micro-compression (Segment 4), full contrast/accessibility audit. | — |

---

## 7. Key risks & mitigations

| Risk | Mitigation |
|---|---|
| Rhyme-highlight colors illegible on light bg | Dedicated re-tune + contrast check before P5 sign-off; keep perfect/near distinction. |
| 2 hard-coded-dark screens | Explicit fixes in P3 (achievements) & P5 (splash). |
| Large mechanical sweep (270 `.secondary` / 246 caption) | Token aliases make it find-replace-able, screen by screen; not all at once. |
| 53k-LOC scale | Strict phasing — each phase ships + verifies independently. |
| SwiftUI defaults creep in rounded corners / materials | Enforce **square corners + flat surfaces** in the design system; audit for stray `RoundedRectangle`(large radius)/`.cornerRadius`/`.ultraThinMaterial`. Meet 44pt targets via size. |
| Disturbing locked structure | Reskin is presentation-only; no edits to page map, handlers, or `@State`. |

---

## 8. Verification

- Per phase: app builds; **before/after screenshots** of each touched screen (light); behavior unchanged (manual smoke of the screen's actions).
- Contrast: body/content text meets ~WCAG AA on `surface`/`surfaceElevated`.
- Final: no remaining `.ultraThinMaterial` in user-facing screens; no screen ignores `colorScheme`; rhyme highlighting verified legible.

---

## 9. Files & artifacts

- **New:** `XJournal AI/Momentum/MomentumDesignSystem.swift` + component files (Layers 0–5).
- **Edited per phase:** `CCV.10/.11/.12/.13/.14`, `AnalyticsDashboardView`, `AchievementBadgeView`, `RapSuggestionView`, `PaywallView`, `SupportShopSheetView`, `ReleaseNotesSheetView`, `SplashScreenView`; palette re-tune in `CCV.2` (`RhymeColorPalette`).
- **Retired (P6):** `GlassEffectComponents.swift`, glass tints in `CCV.2`.
- **Branch:** `ui-momentum-reskin`. (Phase-0 token WIP from `phase-0-quick-wins` rides along; can rebase onto `main` if preferred.)
