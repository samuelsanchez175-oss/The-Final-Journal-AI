# UI Pass — Sheets, Coral Controls & Editor Polish (Design)

**Date:** 2026-05-31
**Status:** ✅ **Shipped** (verified 2026-05-31, build green) — every task implemented; completion map below. The coral foundation co-landed with a parallel Cursor session, so it isn't an isolated commit (commits noted per task).
**Context:** Post-Momentum-reskin polish round. Companion to vault `UI Overhaul — Phased Plan` and `ContentView CCV — File Index`. Detailed design spec lives here in repo (same convention as `2026-05-31-momentum-ui-reskin-design.md`).

## Guardrails (inherited, locked w/ Samuel)
- **No nav / page-map changes, no logic/data changes.** This pass is presentation consistency + additive preferences + cleanup + one bug fix.
- **Surgical edits only** on the big CCV files (CCV.10/12/13/14 are 1k–2.2k LOC re-render hotspots). No re-architecting screens.
- **Momentum design language stays:** light, coral accent (`#FF8C66`, reuses `RhymeColorPalette`), `AtmosphereGlow` soft coral glow is a signature must-keep.

## Decisions (confirmed by Samuel, 2026-05-31)
1. **Home-pill sheet style → full-height** for all 4 non-plus buttons (with grabber). The `+` keeps its dropdown `Menu`.
2. **Coral controls → presets + strength** (curated warm/coral tints + a strength slider; no freeform color picker).
3. **Coral reach → glow + all accents** — the chosen preset drives both `AtmosphereGlow` and the app-wide coral accent (buttons, chips, active filter pills, rhyme accents). Sequenced so the glow + prefs land first, the app-wide accent recolor second.
4. **The 9 & 53 counters → removed** entirely (no relocation).

---

## ✅ Completion (verified 2026-05-31 · build green)

| Task | Status | Landed in |
|---|---|---|
| **P1** home-pill → 4 full-height sheets | ✅ | CCV.10 (`61094cc`) |
| **P2** remove Social + What's New tabs | ✅ | AnalyticsDashboardView (`61094cc`) |
| **3A** `CoralPreset` (6 tints) + `CoralSettings` | ✅ | MomentumDesignSystem |
| **3B** `AtmosphereGlow` reads preset + strength | ✅ | MomentumDesignSystem |
| **3C** editor coral breathing (BPM-damped) | ✅ | `EditorCoralGlow` → `EditorHeaderCoralBackground` → CCV.13:424 (`eab6ddf`) |
| **3D** app accent follows preset | ✅ | `Momentum.accent` computed from `CoralSettings.preset` |
| **Coral prefs** (swatches + strength + breathe toggle) | ✅ | `CoralAppearanceSection`, Profile → App → Coral (CCV.12) |
| **4A** "Created" plate removed | ✅ | CCV.13 |
| **4B** 9 & 53 counters removed | ✅ | CCV.14 (`61094cc`) |
| **4C** press-and-hold → tap | ✅ | CCV.14 (`61094cc`) |
| **4D** rhyme-overlay shift fix (`lineFragmentPadding 0→5`) | ✅ | CCV.6 (`1a49405`) |

**Notes:**
- Default preset = `classic` (#FF8C66), so nothing changes visually until a preset is chosen — backward-compatible.
- 3C ended up richer than spec'd: `EditorCoralGlow` (the BPM-damped breathing radial) is composed inside Cursor's `EditorHeaderCoralBackground`, which adds a vertical coral wash from the nav bar to the divider.
- The coral foundation (3A/3B/3D + prefs) co-landed with a large parallel Cursor WIP (Rap Suggestions redesign, Lagoon dark-mode palette, Human Critic) — not an isolated commit.
- Remaining: a visual sim pass to confirm the glow/breathing/accents read well across presets and strength.

---

## Phase 1 — Home pill: one consistent full-height sheet
**Area:** Home (`ContentView.CCV.10.swift`, `JournalLibraryView`). Profile view body is in `CCV.12` (`ProfilePopoverView`).

**Current reality** (the inconsistency, confirmed):
| Button | Action var | Presents as |
|---|---|---|
| Analytics `chart.bar.fill` (CCV.10:162) | `showAnalytics` | `.sheet` full-height, no grabber (:273) |
| Profile `person.crop.circle` (:172) | `showProfile` | **`.popover`** (:257) |
| What's New `clock.arrow.circlepath` (:182) | `showReleaseNotes` | `.sheet` `[.medium,.large]` + grabber (:263) |
| Support & Shop `bag` (:192) | `showSupportShop` | `.sheet` `[.medium,.large]` + grabber (:268) |
| `+` (:202) | — | `Menu` dropdown (:202–229) — **keep as-is** |

**Tasks:**
- 1.1 Convert Profile `.popover(isPresented:$showProfile, arrowEdge:.top)` (CCV.10:257) → `.sheet(isPresented:$showProfile)` presenting `ProfilePopoverView`, full-height + drag indicator. (`showProfile.toggle()` at :174 can stay or become `= true`.)
- 1.2 Analytics sheet (:273): add the same presentation config (drag indicator; full-height detent).
- 1.3 What's New (:263) & Support & Shop (:268): drop `.medium` so they open full-height (keep `.large` + drag indicator).
- 1.4 Standardize: extract the shared presentation config (detents/drag indicator) so all four are identical.
- 1.5 Leave the `+` `Menu` untouched.

**Verify:** tap each of the 4 → identical full-height pull-up with grabber; `+` still shows its dropdown. Screenshot the 4.
**Notes:** `ProfilePopoverView` keeps working inside a sheet; an optional later rename (`…SheetView`) is out of scope. Not a nav change — same destinations, same buttons.

## Phase 2 — Analytics: remove the Social + What's New tabs
**Area:** `AnalyticsDashboardView.swift`.

**Tasks:**
- 2.1 Remove `case whatsNew = "What's New"` (:504) and `case social = "Social"` (:505) from `enum AnalyticsTab` (:494). CaseIterable drops them from the segmented control automatically.
- 2.2 Remove their sections: What's New (~:967 → `ReleaseNotesContentView()`) and Social (~:973 → `SocialFeedContentView()`).
- 2.3 Remove the now-dead icon cases (~:533, e.g. `.whatsNew → "sparkles"`).
- 2.4 Confirm `selectedTab` default (`.overview`, :491) and `lastDiagnosticTab` (:492) don't reference removed cases.
- 2.5 **Cleanup (optional, flag):** prune unused `ReleaseNotesContentView`, `SocialFeedContentView` (struct ~:1160), and `SocialPost` seeding (`didSeedSocialPosts`) if nothing else references them. Keep `ReleaseNotesSheetView` (used by the home button).

**Verify:** Analytics shows only the real analytics tabs; What's New still opens from the home clock button. Build clean (no orphan references).
**Rationale:** Social was never a real feature (aligns with Momentum non-goal "no social/streaks"); What's New is reachable from home, so the tab is redundant.

## Phase 3 — Coral system (presets + strength; glow + all accents)
**Area:** `Momentum/MomentumDesignSystem.swift` (`AtmosphereGlow` :88–100, `accent` :37), `CCV.2` (`RhymeColorPalette` coral), `CCV.12` (preferences cluster, `@AppStorage`), `CCV.13` (editor background), `Item.swift:18` (`bpm`).

Delivered as four increments so the broad-reach part lands last:

- **3A — Theme source of truth.** New `CoralTheme` (ObservableObject) holding `selectedPreset` + `strength`, persisted via `@AppStorage`/UserDefaults (match the CCV.12 pattern). Inject once at app root (`The_Final_Journal_AIApp.swift`). Define a small curated preset set; **default preset = `#FF8C66`** (the locked coral) so existing look is unchanged.
- **3B — Background glow reads the theme.** Refactor `AtmosphereGlow` to read preset color + `strength` (strength scales glow opacity/intensity; keep the existing pulse). Keep the component **concrete** (per the locked Momentum rule — no generics, watch type-check time in CCV.12/13).
- **3C — Coral inside the editor (breathing).** Add an `AtmosphereGlow` layer behind the `NoteEditorView` text body (CCV.13), below the text, low strength. Pulse period **loosely** modulated by `item.bpm`: `period = lerp(basePeriod, beatPeriod, k)` with small `k` (~0.25–0.35) and clamped — visibly faster/slower with BPM but **not** locked to it. Off-state (no bpm) = base pulse. Gate behind a "breathing in editor" toggle in prefs (default on).
- **3D — App-wide accent (the "all accents" reach).** Make `Momentum.accent` resolve from `CoralTheme` so buttons/chips/active filter pills/rhyme accents follow the chosen preset; re-point `RhymeColorPalette` coral (CCV.2) at the theme. **Broad blast radius** (many `Momentum.accent` call sites) → ship after 3A–3C are stable and verified. Approach: single source via the env object; verify SwiftUI invalidation on preset change across home/editor/analytics.

**Preferences UI:** new **"Coral"** section in the CCV.12 preferences cluster (`PreferencesInfoView`): preset chips (Capsule pills, Momentum style) + a strength slider + the breathing toggle, all bound to `CoralTheme`.

**Verify:** changing preset/strength live-updates the home glow and (after 3D) accents; editor shows a gentle breathing glow; raising BPM speeds the pulse slightly; strength = 0 ≈ no glow. Screenshot low/high strength + two presets.
**Risk:** 3D touches many sites and a "locked" token — keep default = `#FF8C66`, test light-mode contrast, watch CCV.12/13 compile time.

## Phase 4 — Editor polish
**Area:** `CCV.13` (`NoteEditorView`), `CCV.14` (`DynamicIslandToolbarView`), `CCV.6` (`RhymeHighlightTextView`), `CCV.3` (`RhymeHighlighterEngine`).

- **4A — "Created" footer: drop the plate.** In CCV.13's meta footer (~:534 "breathing room between text and meta" region), remove the plate background (fill/cornerRadius/material), keep the "Created" + date as plain text. Intentional, Samuel-requested deviation from the "metadata = pill" rule — it's a passive footer, not interactive data.
- **4B — Remove the 9 & 53 counters.** Locate the two numeric badges in the `DynamicIslandToolbarView` (CCV.14) bottom region; delete them and any now-unused source values/preference keys. Confirm what they represent before deleting (likely word/line or token counts).
- **4C — Make all toolbar buttons tap-consistent.** One toolbar button opens via press-and-hold (`CCV.14:318` `LongPressGesture(minimumDuration: 0.5)`). Convert it to a normal tap (`Button`/`onTapGesture`) matching the others. Leave the harmless `:279` `onLongPressGesture(minimumDuration: 0, …)` press-state feedback alone unless it's the same control.
- **4D — Fix rhyme eye-toggle horizontal text shift (bug).** Toggling the rhyme eye shifts body text left. Root-cause is almost certainly an inset/padding mismatch between the plain `TextEditor` and the `RhymeHighlightTextView` overlay (`CCV.6`) — compare `textContainerInset` / `lineFragmentPadding` / leading padding between highlight-off and highlight-on. Align them so the text origin is identical in both states. **Debugging task** (reproduce → isolate the differing inset → fix → verify no shift on repeated toggles).

**Verify:** footer reads as plain text, continuous with the page; no 9/53 badges; every toolbar button opens on a single tap; toggling the eye does not move the text.

---

## Sequencing
```
P1 (home sheets)    independent · low risk
P2 (analytics tabs) independent · low risk
P3 (coral)          3A→3B→3C ship together · 3D (app-wide accent) after, med→high risk
P4 (editor polish)  4A/4B/4C low risk · 4D is a bug-hunt
```
Recommended order: **P1 → P2 → P4(A/B/C) → P3(A–C) → P4D → P3D.** (Quick wins and isolated cleanup first; the coral feature and the broad accent recolor last; the rhyme bug slotted where the editor is already open.) Each phase = its own build-verified commit + a vault status line.

## Open / to-confirm during implementation
- 4B: exact meaning of `9` & `53` (confirm before deleting).
- 3A: final curated preset list (names + hexes) — propose 4–6 warm tints anchored on `#FF8C66`.
- 3D: confirm SwiftUI re-render strategy for live accent changes across hotspot views.

## Non-goals
No new features; no nav/page-map changes; no logic/data changes; no dark-mode work; no glass-retirement work (separate Momentum phase).
