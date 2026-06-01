# AI Config Simplification — Model G v3 Only (Design)

**Date:** 2026-06-01  
**Status:** Phases 1–4 complete  
**Goal:** Reduce reading and decision fatigue while preserving all AI control and prompt wiring.

## Guardrails

- Do **not** delete `ModelSettings` fields or `RapSuggestionAPI` prompt switches (except dead UI).
- Keep `SuggestionModel` enum (`modelG`, `modelY`, `modelGv3`) for API/back-compat.
- Generation from the note control surface stays on **`model: .modelG`** + pinned `useModelGCore` / `useModelGv3` so **DirectedGenerationParams** and **ModelGCoreCoordinatorV3** keep working.
- User-facing settings persist in **`modelGv3_settings`**; migrate from `modelG_settings` once on launch.

---

## Phase 1 — v3-only product surface (this PR)

| Task | File(s) | Detail |
|------|---------|--------|
| 1.1 | `ModelGEnvironment.swift` | `applyV3OnlyProductDefaultsIfNeeded()` — migrate toolbar → v3, copy `modelG_settings` → `modelGv3_settings` if needed, pin Core+v3 on |
| 1.2 | `The_Final_Journal_AIApp.swift` | Call migration on launch |
| 1.3 | `ModelPreferencesView.swift` | Remove 3-tab selector; remove Core/v2/v3 toggles; v3-only body (Originality + `ModelSettingsForm`); save only `modelGv3_settings` |
| 1.4 | `ModelPreferencesView.swift` | Remove dead **cultural context sensitivity** question (field never read in prompts) |
| 1.5 | `ContentView.CCV.14.swift` | Single “Suggest Next Lines”; default `@AppStorage` v3; drop G/Y menu items; primary action always `beginModelGv3Flow` |
| 1.6 | `ContentView.CCV.13.swift` | `modelGControlSurfaceAPIModel` → `.modelG`; remove parallel v1+v2 path; default toolbar v3 |
| 1.7 | `ModelGControlSurfaceView.swift` | Remove Engine section (Core/v2 toggles) |
| 1.8 | `RapSuggestionAPI.swift` | `loadModelSettings(for: .modelG)` reads `modelGv3_settings` |

**Verify:** Profile → Model Preferences shows one scroll (no tabs); toolbar AI → one suggest action; control surface has no Engine block; generation still returns suggestions with directed params.

**Implemented 2026-06-01:** Tasks 1.1–1.8; Xcode build (`XJournal AI` / iPhone 17 sim) succeeded.

---

## Phase 2 — Advanced disclosure

- Collapse `ModelSettingsForm` into **Voice · Boundaries · Flow** + **Advanced** (all 23 wired fields remain).
- Shorter section copy; drop redundant “Affects:” lines on every block.

**Implemented 2026-06-01:** `ModelSettingsForm` reorganized; `SectionHeader` uses optional subtitle; Advanced `DisclosureGroup` holds formality, confidence, tone, narrative, rhyme/beat controls.

---

## Phase 3 — Merged controls

- One **Show vs tell** control → writes `implicationLevel` + `compressionLevel`.
- One **Formality** control → writes `registerStrictness` + derived `registerWeight`.
- **Confidence** cluster in Advanced → `authorityLevel`, `dominanceLevel`, `finalityLevel`.
- **Silence** slider → also maps `refusalFrequency`.

`ModelSettings` struct and `CodingKeys` unchanged.

**Implemented 2026-06-01:** `ModelSettingsUIMapping` merges show/tell, formality (+ weight), confidence cluster, and silence→refusal; removed duplicate Advanced questions.

---

## Phase 4 — Control surface trim

- Merge Highlight + Must-use into one block.
- Merge Topics + World-building (or disclosure).
- Title: “Suggest next lines” (not “Model G”).

**Implemented 2026-06-01:** `ModelGControlSurfaceView` — merged “Words to emphasize” block; topics + collapsible world-building; rhyme groups moved below tone; clearer copy.

---

## Settings audit (24 controls)

| # | Field | Prompt role | UI phase |
|---|--------|-------------|----------|
| 1 | `editorialProtection` | North-star protection | Visible |
| 2–3 | `implicationLevel`, `compressionLevel` | Show vs tell | Phase 3 merge |
| 4–5 | `registerStrictness`, `registerWeight` | Formality | Phase 3 merge |
| 6–7, 12 | authority, dominance, finality | Confidence | Advanced |
| 8 | `exposureLevel` | Voice | Visible |
| 9 | `culturalSpecificity` | References | Advanced |
| 10 | `riskTolerance` | Bold vs safe | Visible |
| 11 | `symbolismLevel` | Abstract vs literal | Advanced |
| 13–14 | restraint, posture | Narrative | Advanced |
| 15 | `refusalFrequency` | Refusal rate | Phase 3 → silence slider |
| 16–19 | flow, rhyme, syllable, beat | Flow & rhyme | Advanced group |
| 20 | `topicRestrictions` | Avoid list | Visible |
| 21 | `languageRestrictions` | Explicit filter | Visible |
| 22 | `referenceStyle` | Reference style | Advanced |
| 23 | `culturalContextSensitivity` | **Unused** | **Removed** |
| 24 | `silenceThreshold` | Confidence floor | Visible |

**Removed from UI only:** #23. **Enum/decode retained** for saved data.

---

## Impact vs benefit (summary)

| Change | Benefit | Risk |
|--------|---------|------|
| v3-only UI | −2 models, −5 toggles | Low — API enum kept |
| Dead question removed | Less confusion | None |
| Settings key unify | One source of truth | Migration copies G→v3 |
| Engine hidden | Cleaner surface | Pinned flags in UserDefaults |
