# Profile Page — Momentum Reskin + Unified Save (Design)

**Date:** 2026-05-31
**Branch:** `ui-momentum-reskin`
**Scope:** One screen + one component. `ProfilePopoverView` in `XJournal AI/ContentView.CCV.12.swift` and `XJournal AI/APIKeyField.swift`.

## Problem

The Profile page (`ProfilePopoverView`) looks unlike the rest of the Momentum-reskinned app. P5 (commit `e3c91d0`) did a find-replace sweep (`.ultraThinMaterial` → `Momentum.surfaceElevated`, `.secondary` → `Momentum.contentSecondary`, added `AtmosphereGlow`) but left:

- Ad-hoc `Text(...).font(.headline)` section titles instead of the app's `MomentumSectionHeader` (uppercase + thin rule), which every other Momentum screen uses (ModelG, Analytics).
- Long multi-line helper paragraphs that make the page feel cluttered.
- ~13 sections, several of them one-row (Account=Export only, Splash=Reset only, Privacy=static Keychain note).
- A bottom inline **Cancel / Save** row, where the rest of the app uses a `NavigationStack` toolbar.
- **API keys save in a separate place from the page Save:** each `APIKeyField` has its own Save button; the page's Save only writes name/email/phone. Keys already persist to Keychain (`KeychainHelper.shared`), so no migration is needed — but there's no single "Save" that captures everything.

## Goals

1. Make Profile visually consistent with other Momentum pages.
2. Make it concise: editorial section headers, one-line helper copy, fewer sections.
3. Add a single **Save** in the top-right that persists profile info **and** the API keys, with a confirmation.

Non-goals: changing where keys are stored (already Keychain), auth/sign-in (disabled), the `UserPersonalizationSheet` internals (only restyle headers if trivial), dark-mode tuning.

## Design

### Navigation & Save (the headline change)
- Wrap the body in `NavigationStack` → `.navigationTitle("Profile")`, `.navigationBarTitleDisplayMode(.inline)`. (Presented as a `.popover` from `ContentView.CCV.10.swift:265`; a NavigationStack toolbar renders correctly there.)
- Toolbar:
  - `.cancellationAction` → **Cancel**: restores name/email/phone from `@AppStorage`, dismisses. (Does not touch keys — keys only change on Save.)
  - `.confirmationAction` → **Save** (semibold), `.disabled(!isFormValid)`: runs `saveAll()`.
- Remove the bottom inline Cancel/Save `HStack` and its overlay toast.

### `saveAll()`
1. Format phone if valid (existing `formatPhoneNumber`).
2. Write `storedName/Email/Phone` from the drafts (existing).
3. Write keys to Keychain from the two key drafts: non-empty → `saveAPIKey` / `saveGeniusAPIKey`; empty → `deleteAPIKey` / `deleteGeniusAPIKey` (so clearing a field removes the key).
4. `hasUnsavedChanges = false`, medium haptic, show confirmation, dismiss after ~0.6s.

### API key fields — lift state to the parent
`APIKeyField` currently owns `@State draft` + `load`/`save` closures + its own Save button. Refactor:
- Replace `load`/`save` + internal `@State draft` with **`@Binding var draft: String`**.
- Remove the per-field **Save** button and the `.saved` phase. Keep **reveal**, **provider auto-detect**, **Test** (validates the typed draft directly via `APIKeyField.validate`, no persistence), the get-key **Link**, and `statusLine` (testing/valid/invalid).
- Restyle the input to Momentum: `Momentum.surfaceElevated` fill, `Momentum.hairline` border, `Momentum.corner` radius; `.secondary` → `Momentum.contentSecondary`.

Parent owns the drafts:
- `@State private var openAIKeyDraft = ""`, `@State private var geniusKeyDraft = ""`.
- Seed in `.onAppear`: `openAIKeyDraft = KeychainHelper.shared.getAPIKey() ?? ""`, `geniusKeyDraft = KeychainHelper.shared.getGeniusAPIKey() ?? ""`.
- Call sites pass `draft: $openAIKeyDraft` / `$geniusKeyDraft`.

Both call sites are in `CCV.12`; there are no other `APIKeyField` users, previews, or tests, so the API change is safe.

### Concise sections (target order)
Replace each `Text(...).font(.headline)` with `MomentumSectionHeader(title:)`; trim each helper paragraph to one line. Merge one-row sections.

1. **Identity** (no header): avatar picker + Name / Email / Phone.
2. **Personal Details** — one-line blurb + "Add Personal Details" row.
3. **API Keys** — one-line blurb; OpenAI/Gemini field; Genius field; a single caption: "Stored securely in your device Keychain." (this absorbs the old Privacy & Security section).
4. **Suggestion Defaults** — `SuggestionDefaultsSection` (swap its internal `.headline` title for `MomentumSectionHeader`).
5. **Notifications** — `NotificationPreferencesView`.
6. **Preferences** — rhyme overlay + advanced mode + Model Preferences row.
7. **General** *(merged)* — Export Data + Reset Splash Screens (two rows, one section).
8. **App** *(merged: About + Storage + Invites)* — version/build + total notes/audio size in one flat card, then the Share Invite link.

Dropped as standalone: Privacy & Security (folded into API Keys), Account (renamed/merged into General), Splash Screens (merged into General).

### Confirmation
A small Momentum capsule pinned top — coral `checkmark.circle.fill` + "Saved" — shown on `showSaveConfirmation`, auto-hidden, using `Momentum.surfaceElevated` + `Momentum.hairline`. (Replaces the `.ultraThinMaterial` toast.)

### Styling rules applied throughout
- Section titles → `MomentumSectionHeader`.
- Cards → flat `Momentum.surfaceElevated`, `Momentum.hairline` 1px, `Momentum.corner` (14).
- Body copy → `Momentum.contentPrimary` / secondary copy → `Momentum.contentSecondary`; keep ≥ system sizes already present.
- Keep `AtmosphereGlow()` background.

## Files
- **Modify** `XJournal AI/ContentView.CCV.12.swift` — `ProfilePopoverView` body (NavigationStack + toolbar + saveAll + key drafts), `profileContentSection` (headers, trimmed copy, merged sections, removed bottom buttons), `SuggestionDefaultsSection` header. Remove now-unused `profileSecureField` helper (dead code — no callers).
- **Modify** `XJournal AI/APIKeyField.swift` — binding-based draft, remove per-field Save, Momentum styling.

Both files already belong to both app targets (existing files), so no target-membership work.

## Verification
- `xcodebuild build` for the active scheme → `** BUILD SUCCEEDED **`.
- Manual: open Profile → edit name + paste an OpenAI key → top-right **Save** → confirmation shows, popover dismisses → reopen: name persisted, key present (reveal). Clear the key → Save → reopen: key gone. **Test** still validates. **Cancel** discards profile-field edits.

## Risks
- Parallel edits (Samuel codes on this branch concurrently) — re-check `git status`/diff for `CCV.12.swift` immediately before editing; rebase intent onto whatever is current.
- Popover + NavigationStack toolbar: verified pattern (other sheets in the app use the same), low risk.
