# Haptic Feedback Rollout — Plan

**Date:** 2026-06-06
**Status:** Implemented (Phases 1, 2, 4 complete; Phase 3 seeded in Rap Suggestions)
**Scope:** App-wide tactile feedback, standardized and made consistent.

## Implementation status (2026-06-06)

- **Phase 1 (Foundation) — done.** `HapticFeedbackManager` now has a semantic `Haptic`
  enum, `fire(_:)` / `prepare(_:)`, retained + re-prepared generators, and an `isEnabled`
  gate read from `UserDefaults` key `hapticsEnabled` (default on). Old methods kept as gated
  wrappers; added `softTap()` / `rigidTap()`.
- **Phase 2 (Standardize) — done.** Every raw `UIImpactFeedbackGenerator` /
  `UINotificationFeedbackGenerator` call site across the app was routed through the manager,
  and the global `lightHaptic()` now delegates to it — so the user toggle is authoritative.
- **Phase 4 (Settings UI) — done.** `HapticsSettingsToggle` added to Settings → Preferences,
  bound to `@AppStorage("hapticsEnabled")`, fires a sample on enable.
- **Phase 3 (Coverage) — broad.** Rap Suggestions deck (swipe tick + island toggle selection);
  audio recording (medium on start, light on stop, success/error on processing); AI generation
  lifecycle (success/error on the main deck **and** Improve-Flow paths — main path was already
  wired and is now gated). Remaining low-traffic nav/segment surfaces follow the mapping table
  as a fast-follow.

Decision taken: the in-app toggle gates **all** haptics (including errors) for predictability;
revisit if we want failures to stay feel-able when haptics are off.

---

---

## 1. Goal

Give the app a single, consistent, low-latency haptic language so that meaningful
interactions (taps, toggles, swipes, generation success/failure, like/dislike, recording
start/stop, achievements) feel tactile and intentional — and so that *one* place controls
the behavior, respects a user setting, and is cheap to call.

This is **not** "add haptics everywhere." It's "make the haptics we already fire consistent,
centrally controlled, and complete in the places that matter."

---

## 2. Current state (audit)

A quick survey of the codebase (2026-06-06):

- **~99 haptic call sites across 13 files.** Haptics are already used heavily.
- **Three competing APIs are in use:**
  1. `HapticFeedbackManager.shared.lightTap()/mediumTap()/success()/…` — the intended
     central manager (`XJournal AI/HapticFeedbackManager.swift`).
  2. Raw `UIImpactFeedbackGenerator(style:).impactOccurred()` /
     `UINotificationFeedbackGenerator().notificationOccurred(.success)` scattered inline
     (e.g. `RapSuggestionView.toggleLineFeedback`, audio views).
  3. A global free function `lightHaptic()` in `ContentView.CCV.2.swift`.
- **No user setting.** There is no way to turn haptics down/off in-app. (iOS *System Haptics*
  in Settings is respected automatically by the generators, but we offer no app-level control.)
- **No `.prepare()` anywhere.** Every call constructs a generator on the spot and fires it,
  which adds first-fire latency (the Taptic Engine has to spin up) and discards the generator
  immediately.
- **Coverage is uneven.** Some flows are rich (audio detail, toolbar); others that clearly
  warrant feedback are silent.

`AI_RULES.md` already mandates: *"For haptic feedback, always use `UIImpactFeedbackGenerator`
from UIKit."* `HapticFeedbackManager` is built on exactly that, so standardizing on the manager
satisfies the rule **and** removes the inconsistency.

---

## 3. Design principles

1. **One entry point.** All haptics go through `HapticFeedbackManager.shared`. No raw
   generators, no `lightHaptic()` free function, at call sites.
2. **Semantic, not literal.** Call sites ask for an *intent* (`.selection`, `.success`,
   `.impact(.light)`, `.toggle`), not a specific engine call. The manager maps intent → engine.
3. **Respect the user.** A single `@AppStorage("hapticsEnabled")` (default `true`) gates every
   non-essential haptic centrally. The OS already respects System Haptics; we add an app toggle.
4. **Low latency.** Support `.prepare()` so flows that are about to fire (e.g. press-and-hold,
   an in-flight AI generation about to land) warm the engine first.
5. **Cheap and safe.** Main-thread, no-ops gracefully on devices without a Taptic Engine,
   never throws, never blocks.
6. **Don't double-fire.** One interaction = one haptic. Audit for places that currently stack
   a manager call *and* a raw call.

---

## 4. Phased plan

### Phase 1 — Foundation (centralize + settings + prepare)

Extend `HapticFeedbackManager` without breaking its current API (keep `lightTap()`, `success()`,
etc. as thin wrappers so nothing has to change at once):

- Add `@AppStorage`-backed `isEnabled` gate read by the manager (via `UserDefaults` so the
  singleton can read it without a SwiftUI context). Notification haptics for **errors** may
  optionally bypass the gate (accessibility — a failure should still be feel-able), TBD with Samuel.
- Add a `prepare(_:)` method that pre-warms the appropriate generator, and **retain** the
  generators as properties on the singleton instead of allocating per-call (lower latency,
  fewer allocations).
- Add a semantic enum, e.g.:
  ```swift
  enum Haptic {
      case selection                 // pickers, segment changes, tab switches
      case impact(UIImpactFeedbackGenerator.FeedbackStyle)  // taps / drags / snaps
      case success, warning, error   // operation outcomes
      case toggle(Bool)              // on = medium, off = light (or selection)
  }
  func fire(_ haptic: Haptic)
  func prepare(_ haptic: Haptic)
  ```
- Keep existing methods (`lightTap`, `mediumTap`, `heavyTap`, `success`, `warning`, `error`,
  `selection`) as wrappers over `fire(_:)` so the migration is incremental and low-risk.

**Deliverable:** richer `HapticFeedbackManager`, no behavior change at existing call sites yet.

### Phase 2 — Standardize existing call sites

Mechanical migration, file by file, no new haptics:

- Replace raw `UIImpactFeedbackGenerator(...)` / `UINotificationFeedbackGenerator(...)` calls
  with `HapticFeedbackManager.shared.fire(...)`.
- Replace the global `lightHaptic()` with `HapticFeedbackManager.shared.fire(.impact(.light))`
  and deprecate/remove the free function.
- Hotspots to convert first (highest call counts): `ContentView.CCV.14`, `InlineAudioCardView`,
  `ContentView.CCV.13`, `AudioDetailSheet`, `ContentView.CCV.10/12`, `RapSuggestionView`.

**Deliverable:** every haptic in the app flows through the manager and obeys the user setting.

### Phase 3 — Fill coverage gaps

Apply the mapping table (below) to interactions that should have feedback and don't. Add
`prepare()` to press-and-hold / in-flight flows. Notable additions:

- **Rap Suggestions deck:** light impact on card swipe between generations; `.selection` on the
  Rhymes/Groups/Stack island toggles; success when a fresh generation lands at the front.
  (Per-line like/dislike already fires `.success`/`.error` via `toggleLineFeedback`.)
- **AI generation lifecycle:** `prepare()` when a request starts; `.success` when suggestions
  arrive, `.error` on failure (centralizing what `AIErrorBanner` does today).
- **Recording:** medium impact on start, lighter on stop; warning when hitting a limit.
- **Navigation/sheets:** `.selection` on segmented controls / tab switches; light impact on
  primary button taps.
- **Achievements / milestones:** `.success` (already partially present in `AchievementBadgeView`).

### Phase 4 — Settings UI

- Add a **Haptics** toggle to the existing settings/preferences surface (alongside theme/model
  prefs), bound to `@AppStorage("hapticsEnabled")`.
- Optional: a one-line "Haptics" row that fires a sample on toggle-on so the user feels it.

---

## 5. Interaction → haptic mapping (reference)

| Interaction                                   | Haptic                    |
|-----------------------------------------------|---------------------------|
| Primary button tap                            | `.impact(.light)`         |
| Segmented control / tab / picker change       | `.selection`              |
| Toggle on / off                               | `.toggle(true/false)`     |
| Card swipe / snap (deck, carousels)           | `.impact(.light)`         |
| Expand / collapse, drawer open                | `.impact(.medium)`        |
| Like a line                                   | `.success`                |
| Dislike a line                                | `.error` (or light impact)|
| AI generation succeeded                       | `.success`                |
| AI generation failed / error banner           | `.error`                  |
| Hit a limit / blocked action                  | `.warning`                |
| Recording start / stop                        | `.impact(.medium/.light)` |
| Achievement / milestone unlocked              | `.success`                |
| Destructive confirm (delete)                  | `.warning` then `.success`|

---

## 6. Testing & rollout

- **Manual on-device** (haptics don't fire in Simulator): walk each mapped interaction with
  `hapticsEnabled` ON, then OFF (everything except possibly error should go silent), then with
  iOS *System Haptics* OFF (everything silent).
- **Unit-testable seam:** the intent→call mapping and the `isEnabled` gate can be tested by
  injecting a fake generator/closure into the manager (no Taptic Engine needed in CI).
- **Roll out by phase** behind small PRs; Phase 1+2 are safe to ship together (no UX change,
  just plumbing). Phases 3–4 are the user-visible additions.

---

## 7. Risks / open questions

- **Double-fire** during Phase 2 if a site has both a manager call and a raw call — audit as we go.
- **Should errors bypass the user toggle?** (Accessibility argument for yes.) — confirm with Samuel.
- **Singleton reading `@AppStorage`:** the manager is not a SwiftUI view, so it reads the flag via
  `UserDefaults.standard.bool(forKey: "hapticsEnabled")` (defaulting to `true` when unset).
- **Generator retention:** keeping prepared generators alive is the latency win, but we should
  release/re-prepare sensibly so we don't hold the engine warm indefinitely.
