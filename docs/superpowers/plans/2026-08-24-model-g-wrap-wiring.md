---
tags: [penwork, model-g, pipeline, plan, wrap, writing-partner, ohmhasmeaning]
project: Penwork Studios
created: 2026-08-24
updated: 2026-08-24
status: phase-0-shipped — single Model G path; writing partner injects into generateFullVerse
---

# Model G — Wrap Wiring Plan (Ohm → Writing Partner)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make Model G reliably wrap like Gunna — last stress on beats 3–4, 4-bar pocket, setup that aims at a flip — by wiring Ohm’s clock + word recipe + semantic cage + copy-flow into the writing partner and the actual generation call, not by pasting more lecture into a prompt the live path ignores.

**Architecture:** Model G is an orchestrated LLM, not a trained Gunna model. SuperGunna still owns *what* (1 brand/bar, templates). This plan owns *when it lands* and *how the writing partner actually reaches the model*. v5 rule stands: **add signal to the prompt; do not add vetoes.** No new coordinator. Fix `generateFullVerse` + `DirectedGenerationParams` + `BarClock` on `GenerationContext`.

**Tech Stack:** Swift / SwiftUI, `XJournal AI/`, existing `ModelGLLMService`, `ModelGCoreCoordinatorV3/V4/V4_1`, `ModelGControlSurfaceView` (“Suggest next lines” = writing partner), `FlowDNAEngine`, `GenerateLyricsFromFlowService`, CMUDICT / `RhymeClusterEngine`.

**Specs this plan executes:** [[Model G — Wrap Clock & Punch Rules (Ohm 2026-08-24)]] · [[Model G — Ohm Technique Inventory]] · [[02_Engine Translation — What Model G was missing]] · v5 principle in [[Model G — v5 Simplified Pipeline & Audio Input (Design 2026-06-10)]].

## Global Constraints

- Do **not** dump the full Ohm inventory into one prompt. Order: dead-path fix → BarClock → B1 word recipe → B4 semantic cage → L4 copy-flow. Everything else is a chip or a drill.
- Keep SuperGunna **1 brand per bar**. Steal Ohm’s clock, not his battle name-stack.
- Soft score / debug overlay only. No regenerate-until-pass on wrap signals.
- Hats at 140–160 with a ~10s 4-bar fill are **92, not double-time**.
- Writing partner `lineCount` 2/4 is a **cycle size**, not “ignore and write 16 captions.”
- Copy the clock, not the nouns. Copy-flow retrieves a **syllable-placement map**, never “Ah / Yeah” fragments.
- `DirectedGenerationPromptBuilder` is a **dead path** while `useModelGCore` is on. Do not add features only there.

---

## Why Model G is only semi-good (diagnosis, not a vibe)

The Ohm rules *are* present in Gunna. They are **not** present in the live generation call.

```
Writing partner (Suggest next lines)
  └─ DirectedGenerationParams (direction, must-use, topics, world-building, lineCount 2/4, rhyme groups)
       └─ RapSuggestionAPI.generateSuggestions
            └─ useModelGCore == true  (forced on)
                 └─ Coordinator v3 / v4 / v4.1
                      └─ generateVersePlan        ← ignores userPrompt / must-use / cage
                      └─ generateFullVerse        ← ALWAYS 16 bars
                           uses: luxury, beatDirective, punchlineMode, minEndRhymeLines, corpus
                           IGNORES: userPrompt, mustUseTokens, highlightAnchors,
                                    selectedRhymeGroupIDs, selectedTopics, worldBuildingWords,
                                    lineCount, selectedTones
```

Must-use / world-building / direction **do** appear in `buildBarCandidatesPrompt` (v1/v2 per-bar path) and in `DirectedGenerationPromptBuilder` (legacy non-Core path). Neither is what the writing partner runs today.

v4.1 “Punchline Mode” is a **different grammar**: bars 1–3 premise, bar 4 payoff. Ohm/Gunna wrap is **couplet + last stress on beats 3–4** inside a 4-bar cycle. Turning v4.1 on does not implement Ohm.

`generateFullVerse` still ends with `do not repeat the same word; imply more than you state` — the v4.1 P2 surgery that was supposed to drop those (anaphora is Gunna; imply-more kills the reveal) **did not land in the live prompt**. Luxury/brands still sit **above** the punchline block.

`beatDirective`: `bpm >= 140` → “fast — short, clipped bars, double-time pockets.” A Wheezy/Gunna hat-bed at 140–150 will be written as Cory Gunz. Same function also asks for **fewer** syllables at high BPM (`tempoSyllableTarget` ~8 at 140). Double-time + short bars are opposite density instructions.

Gemini Light ignores `directedParams` except BPM/syllable range and returns max 8 lines. **Worse: the writing-partner GL toggle is dead routing.** The sheet always generates with `SuggestionModel.modelG`. `RapSuggestionAPI` only enters `ModelGeminiLightCoordinator` when `model == .geminiLight`. Flipping “Use Model GL” does not change the path.

Further live-path bugs (pipeline audit 2026-08-24):

- `IntentExtractor.extractFromTopic` is fed **the draft**, not `userPrompt`. Empty draft becomes `"Continue in melodic trap style with luxury flex and smooth flow"`. Tone is hardcoded `.confident`. Direction never becomes the theme.
- `ScoringEngine.userFit` *does* score must-use + topics + world-building after the fact (`ScoringEngine.swift:280–318`). The verse prompt never asked for those words. Selector can punish a verse for missing tokens it was never told to use.
- Luxury layers are **always sampled**, no writing-partner control.
- Coordinators **pad/truncate to 16** even if the model returns a 4.
- `BeatFingerprint.pocketDensityScore` is computed and used in scoring, not in `generateFullVerse`.
- `transcriptionRhythmMapData` is accepted on v3/v4 then set `rhythmMap: nil`.
- Rap suggestions **Regenerate** (non-parallel) **drops `directedParams`**.
- SuperGunna templates live on the legacy non-Core path. Core v3/v4.1 is luxury lexicon + RAG, not the old SuperGunna assembler.

**Reliability will not come from training a new “Model G.”** It comes from (1) the writing partner’s fields actually reaching the prompt, (2) a BarClock, (3) generating 4-bar cycles, (4) retrieving *flow maps* not lyric fragments, (5) a listen/overlay test so a bad wrap is visible.

---

## File map (what each file is for)

| File | Role in this update |
|---|---|
| `XJournal AI/ModelGControlSurfaceView.swift` | Writing partner UI. Add wrap section. Bind new params. |
| `XJournal AI/DirectedGenerationParams.swift` | Add wrap/pocket/cage/recipe/copy-flow fields. Keep PromptBuilder in sync *and* unused until Core is off. |
| `XJournal AI/ModelG/ModelGEnvironment.swift` | Add `BarClock` + fields on `GenerationContext`. |
| `XJournal AI/ModelG/ModelGLLMService.swift` | **The live prompt.** `generateVersePlan`, `generateFullVerse`, `beatDirective`. This is the product. |
| `XJournal AI/ModelG/VersePlan.swift` | Extend plan with word-recipe + semantic map + pocket. |
| `XJournal AI/ModelG/ModelGCoreCoordinatorV4_1.swift` | Stop encoding 3+1 as “the” punchline. Wrap mode uses couplet+clock. |
| `XJournal AI/ModelG/ModelGCoreCoordinatorV3.swift` / `V4.swift` | Pass BarClock; honor `lineCount` as cycle size × repeats. |
| `XJournal AI/ModelG/Corpus/ModelGCorpusRetriever.swift` | Add flow-map retrieve (Phase 3). Keep lexical retrieve. Filter `< 4` words. |
| `XJournal AI/GenerateLyricsFromFlowService.swift` | Existing mumble/onset skeleton. Copy-flow *source*, not a parallel product. |
| `XJournal AI/ModelG/FlowDNA/` | Existing syllable/stress fingerprint. Copy-flow uses this, don’t reinvent. |
| `XJournal AI/ModelG/ScoringEngine.swift` | Soft wrap overlay only (Phase 5). No new veto. |
| Vault notes | This plan + wrap-clock spec + inventory. Update Build Status when a phase ships. |

---

## Current writing partner vs missing buttons

### Already on “Suggest next lines”

| Control | Bound into live `generateFullVerse`? |
|---|---|
| Engine: GL / v4 / v4.1 | Yes (router). GL bypasses wrap entirely. |
| Direction (`userPrompt`) | **No** (plan uses `intent.theme` instead) |
| Style override | Yes (coordinator `styleOverride`) |
| Lines to generate 2 / 4 | **No** — always 16 |
| Lines per rhyme 2/4/6/8 | **Yes** (`minEndRhymeLines`) |
| Words to emphasize | **No** |
| Must appear verbatim | **No** (weak keyword cage, dead) |
| Topics | Partial — v4 retrieval tags only, not the prompt |
| World-building (disclosure) | Partial — same, retrieval tags only |
| Tone chips | **No** |
| Rhyme groups (Magnifier) | **No** |

### Buttons / chips that are missing (add in Phase 4, bind in Phases 0–3)

Must have for Gunna wrap (writing partner, not Profile):

1. **Wrap preset** — one toggle: “Gunna wrap.” Sets pocket `.behind`, BPM 92 if none, couplet grammar, 4-bar cycle, drops imply/no-repeat, folds hats. Replaces “pick v4 vs v4.1 vs GL.”
2. **Pocket** — Behind (Gunna) / On top / Ahead.
3. **BPM source** — Use note BPM / force 92 / interpolation BPM. Show folded value when hats read 140–160.
4. **Job** — Continue 4 (one cycle) / Repeat pocket to 16 / Full 16 planned verse. Today the sheet says 2/4 and the engine writes 16.
5. **Punch grammar** — Couplet (default Gunna) / 3+1 (current v4.1) / closed-loop 4 (seed `first/second/nothing`).
6. **Word recipe seed** — one word. Engine runs B1 (pick → parse meaning+rhyme → cultural ref → combine) *in the plan call*.
7. **Semantic / homophone cage** — one sound + 3–6 labeled meanings (`switch`: swap / walk / pistol / circuit). Not the same as must-use.
8. **Keyword cage** — 4–6 words, every bar touches one. Upgrade of must-use. Default **off** for Gunna sparsity.
9. **Copy-flow** — Use last 4 bars’ rhythm / paste 4 bars / pick a named pocket later. Retrieves a syllable map.
10. **Ad-lib metronome** — `yeah` may mark the 4. Off = don’t write ad-libs as bars.

Nice later (chips, not default):

11. Acrostic scheme
12. Story arc (hero’s journey) vs punch-couplet 16
13. Lyrical painting / instructional mode
14. Break the run (after N of one end-rime)
15. Scat-first / mumble-pass
16. GREEN/RED overlay + onset/rime + punch-window on the result (this is how you *see* a bad wrap)
17. Hear against metronome / attached beat (without this, “reliable” is reading captions)

Do **not** put on the generator: 6-step memory, memory palace, beatbox, Cory Gunz ladder, Head-Nod state ladder, contracts/theory, cypher recipe. Those are practice.

---

## Pipeline change (current → after Phase 1)

```
NOW
  plan(theme) → retrieve lyric bars by word overlap
    → generateFullVerse(16 captions, luxury first, optional 3+1)
    → score average v4Total (anti-wit) → pick

AFTER PHASE 1 (minimum reliable wrap)
  BarClock (default 92, fold hats, pocket behind)
    → plan(direction + one concept + recipe seed if any)
    → generate 4-bar cycle (clock exemplar above brands)
    → if job=16, three more cycles: SAME pocket, swap nouns
    → overlay (advisory): last-stress window, setup↔punch share, rime grade
```

After Phase 3, retrieval grows a second index: **flow maps** (syllable placement / stress per beat), not just `ModelGCorpus.json` text.

---

## Phase 0 — Make the writing partner real

Without this, every new Ohm chip is theater.

**What to implement**

Wire `DirectedGenerationParams` into `generateVersePlan` + `generateFullVerse` the way `buildBarCandidatesPrompt` already does.

**Files**

- Modify: `XJournal AI/ModelG/ModelGLLMService.swift` (`generateVersePlan` ~L221–246, `generateFullVerse` ~L249–336)
- Modify: `XJournal AI/ModelGControlSurfaceView.swift` — caption under “Lines to generate”: this is the **cycle** (2 = one couplet, 4 = one wrap cycle). Do not yet change the 16-bar coordinator.

**Interfaces**

- Consumes: existing `GenerationContext.directedParams`
- Produces: prompt blocks `DIRECTION`, `MUST-USE`, `CAGE/TOPICS`, `TONES`, `WORLD`, `HIGHLIGHTS` inside `generateFullVerse` **above** luxury

**Prompt surgery (copy this order)**

```
BAR CLOCK / WRAP block          ← Phase 1; stub a one-liner in Phase 0
DIRECTION: {userPrompt}
MUST-USE / CAGE: {mustUseTokens}
HIGHLIGHTS: {highlightAnchors}
TOPICS / WORLD / TONES: …
THEN luxury / brands
THEN corpus exemplars
THEN end-rhyme cadence
THEN wrap rules (drop "do not repeat the same word"; drop "imply more than you state"
     when wrap preset or punchlineMode; replace with "anaphora allowed; earn the reveal")
```

Honor `lineCount` as a **hint** in Phase 0: “Write a 4-bar cycle; if filling a 16, repeat the pocket.” Do not yet change JSON to variable length (that’s Phase 1).

**Verification**

- [ ] Generate from writing partner with Direction = `closed-loop on "first / nothing"` and Must-use = `nothing`. The JSON bars mention those words.
- [ ] Same run with Direction empty still falls back to `Continue the draft in the same vein.`
- [ ] `grep -n "do not repeat the same word" ModelGLLMService.swift` — gone from `generateFullVerse` when wrap/punchline path. Keep it nowhere as a hard rule on this path.
- [ ] World-building words appear in the user prompt string (DEBUG print or breakpoint on `user`).
- [ ] Empty draft + filled Direction still plans from Direction, not `"Continue in melodic trap style with luxury flex and smooth flow"`.
- [ ] Must-use is in the **prompt** before `userFit` can penalize its absence.
- [ ] GL toggle either routes to `.geminiLight` or is removed/disabled until wrap ships (do not leave a fake switch).

**Anti-patterns**

- Do not add new UI yet.
- Do not only update `DirectedGenerationPromptBuilder` — Core never calls it.
- Do not put must-use into `HardRejectionEngine`.
- Do not treat the GL toggle as a working A/B until routing is fixed.

---

## Phase 1 — BarClock + 4-bar cycles (the wrap)

This is the slice that makes it *sound* like Gunna instead of caption-rap.

**What to implement**

1. `BarClock` on `GenerationContext`.
2. Hat-fold in `beatDirective`.
3. Wrap prompt block from the wrap-clock spec, **above** brands, with the performed 4-bar exemplar.
4. `generateFullVerse` asks for **four 4-bar cycles**, same pocket, swapped nouns.
5. v4.1 wrap grammar becomes couplet + last-stress 3–4. Keep 3+1 as an explicit chip, not the default.

**Create:** `XJournal AI/ModelG/BarClock.swift`

```swift
enum WrapPocket: String, Codable {
    case behind   // Gunna / Thug / Wheezy
    case onTop
    case ahead
}

struct BarClock: Equatable {
    var bpm: Double
    var beatsPerBar: Int
    var barsPerMinute: Double { bpm / Double(beatsPerBar) }
    var secondsPerBar: Double { 240.0 / bpm }
    var punchWindowBeats: ClosedRange<Double>
    var pocket: WrapPocket
    var generateChunkBars: Int
    var hatsFolded: Bool

    static let wrapDefaultBPM: Double = 92

    static func resolve(userBPM: Int?, pocket: WrapPocket = .behind) -> BarClock {
        let raw = Double(userBPM ?? Int(wrapDefaultBPM))
        let (bpm, folded) = foldHats(raw)
        return BarClock(
            bpm: bpm,
            beatsPerBar: 4,
            punchWindowBeats: 3.0...4.0,
            pocket: pocket,
            generateChunkBars: 4,
            hatsFolded: folded
        )
    }

    /// Hats at 118–160 with wrap intent are usually 2×. Fold once into 80–96.
    static func foldHats(_ bpm: Double) -> (Double, Bool) {
        if bpm >= 118, bpm <= 170 {
            let half = bpm / 2.0
            if half >= 70 && half <= 100 { return (half, true) }
        }
        return (bpm, false)
    }
}
```

**Modify:** `GenerationContext` in `ModelGEnvironment.swift` — add `var barClock: BarClock? = nil`. Coordinators fill it via `BarClock.resolve(userBPM: bpm)`.

**Replace `beatDirective` ≥140 branch:**

```swift
if let clock = context.barClock {
    let foldNote = clock.hatsFolded ? " (hats folded; write the vocal at this pocket, not double-time)" : ""
    parts.append("\(Int(clock.bpm.rounded())) BPM, \(String(format: "%.1f", clock.barsPerMinute)) bars/min, \(String(format: "%.2f", clock.secondsPerBar))s/bar, pocket \(clock.pocket.rawValue), last stress on beats 3–4\(foldNote)")
} else if let bpm = context.musicalBPM, bpm > 0 {
    // legacy fallback only
}
```

**Wrap prompt block** — copy verbatim from [[Model G — Wrap Clock & Punch Rules (Ohm 2026-08-24)]] “Prompt block (inject once, above brand rules).” Teach-by-rapping. One performed 4-bar. Do not paste the whole inventory.

**JSON shape** — keep `{"hook","bars":[16]}` but instruct:

```
Write FOUR 4-bar cycles. Each cycle: same pocket (syllable placement), same scheme, new nouns.
Bars 1–2 = setup/punch. Bars 3–4 = same pocket, second couplet, same concept.
Do not punch-in one caption at a time.
```

If writing-partner job is Continue 4, return 4 bars (hook optional). Coordinator already accepts `bars.count >= 8` in v4.1 consider() — **change the floor to `generateChunkBars`** or Continue-4 can never win.

**Verification**

- [ ] User BPM 140, wrap preset on → prompt says ~70–96, **not** “double-time.”
- [ ] No BPM on note → 92, ~23 bars/min, ~2.61s/bar.
- [ ] 16-bar output is readable as 4×4 (same end-stress pattern, nouns change).
- [ ] Luxury brands still appear at **1 per bar max**, below the clock block.
- [ ] v4.1 default no longer requires “bars 4,8,12,16 strongest.”

**Anti-patterns**

- Do not add a fifth coordinator.
- Do not veto lines that miss the punch window.
- Do not retrieve Ohm’s own bars as Gunna exemplars (battle density).

---

## Phase 2 — Word recipe + semantic cage (punch *content*)

Clock without content = empty pocket. This is B1 + B4.

**What to implement**

Extend the plan call so it actually cooks a punch, then write.

**Modify:** `VersePlan.swift`

```swift
struct WordRecipe: Codable {
    var seed: String                 // "laser"
    var meanings: [String]           // ["firearm sight", "Herculaneum light"]
    var rimeFamily: [String]         // ["scope", "notes", "hope"]
    var culturalRef: String          // "Herculaneum scrolls"
    var combinedImage: String        // "working laser and scope / Herculaneum notes"
}

struct SemanticCage: Codable {
    var sound: String                // "switch"
    var senses: [String]             // ["swap", "walk", "punishment", "pistol", "circuit"]
}

struct VersePlan: Codable {
    let centralImage: String
    let angle: String
    let anchorRhymes: [String]
    var wordRecipe: WordRecipe?
    var semanticCage: SemanticCage?
}
```

**Modify:** `DirectedGenerationParams` — `recipeSeed: String = ""`, `semanticSound: String = ""`, `semanticSenses: [String] = []`, `keywordCage: [String] = []`.

**Modify:** `generateVersePlan` — if `recipeSeed` non-empty, require JSON:

```
{"centralImage","angle","anchorRhymes",
 "wordRecipe":{"seed","meanings","rimeFamily","culturalRef","combinedImage"},
 "semanticCage":{"sound","senses"}}
```

Then `generateFullVerse` injects:

```
WORD RECIPE (use this cooked image, do not restate the steps):
{combinedImage} — meanings in play: {meanings}. Rime family: {rimeFamily}.

SEMANTIC CAGE: the sound "{sound}" may mean {senses}. Each 4-bar cycle uses at least two senses. Do not define the word.
```

Must-use becomes the **keyword cage** only when the user typed 4–6 words. One must-use word is a seed, not a cage.

**Verification**

- [ ] Seed `switch` → plan lists ≥3 senses; verse uses at least two without saying “the word switch has many meanings.”
- [ ] Seed `laser` produces a cultural ref, not “I got a laser.”
- [ ] Empty seed → plan stays as today’s three fields (back-compat).

**Anti-patterns**

- Do not run a second LLM “explain the recipe” into the verse.
- Do not force every sense into every bar (that’s battle density).

---

## Phase 3 — Copy-flow retrieval (the wrap people recognize)

Lexical RAG copies *words*. Gunna wrap copies *where the mouth hits*.

**What to implement**

A flow exemplar is 4 bars + a stress/syllable map. Fill new SuperGunna nouns into that map.

**Existing code to reuse, not replace**

- `FlowDNAEngine` / `CadenceProfiler` — stress density, offbeat entry, syllable counts
- `GenerateLyricsFromFlowService` Scenario B — onset skeleton from audio
- `ModelGCorpusRetriever.retrieve` — keep for vocab; **add** `retrieveFlow(near: FlowDNAFeatures, k:)`

**New small type** (same file or `FlowExemplar.swift`):

```swift
struct FlowExemplar {
    var bars: [String]               // 4 lines, for the model to see length only
    var syllableMap: [Int]           // syllables per bar
    var stressHint: String           // "end-loaded, last stress on 3–4"
}
```

**Retriever rule:** `pool.filter { $0.text.split(separator: " ").count >= 4 }` (v4.1 P3, if not already live). Never return “Yeah” / “Ah.”

**Prompt:**

```
COPY-FLOW (copy the CLOCK, not the nouns):
Syllable map: {e.g. 9 / 10 / 9 / 8}
Stress: last stress of each bar in the punch window.
Reference shape (do not reuse these words): {4 bars}
```

Writing-partner control: “Use last 4 bars’ rhythm” builds the map from the draft via existing `FlowDNAEngine.analyze`. Paste-4-bars is the interpolation slot (Fergie → Kreayshawn).

**Verification**

- [ ] Draft with a lazy 8–10 syllable end-loaded 4 → next cycle keeps syllable ±2 and end-load, nouns change.
- [ ] Inspiration slider high no longer says “lean HARD on this exact style” for *lyric* exemplars; that directive moves to the **flow** map only.
- [ ] Fragment exemplars (`Yeah`, `Ah`) never appear in COPY-FLOW.

**Anti-patterns**

- Do not ship a J Hus / Gunna lyric pack as the copy-flow source (legal + battle-density). User’s own last bars + onset skeleton first.
- Do not Jaccard-score candidate verses against the flow exemplar’s words.

---

## Phase 4 — Writing partner wrap section (the buttons)

Only after Phases 0–3 have fields to bind.

**Modify:** `ModelGControlSurfaceView.swift` `formContent` — insert **after** engine toggles, **before** Direction:

Section title: **Wrap** (not “BarClock”, not “Ohm”).

| Control | Maps to |
|---|---|
| Toggle “Gunna wrap” (default ON for this sheet) | preset: pocket behind, fold hats, couplet, drop imply/no-repeat |
| Segmented Pocket: Behind / On top / Ahead | `WrapPocket` |
| BPM: “Note” / “92 wrap” / number field | `BarClock.resolve` |
| Job: 4-bar cycle / Repeat to 16 | `lineCount` + coordinator stop condition |
| Punch: Couplet / 3+1 / Closed-loop 4 | grammar |
| TextField “Recipe word” | `recipeSeed` |
| TextField “Sound cage (one sound)” + comma senses | `SemanticCage` |
| Existing must-use, relabeled “Keyword cage (optional, 4–6)” | `keywordCage` |
| Toggle “Copy last 4 bars’ rhythm” | copy-flow from draft |
| Toggle “yeah on the 4” | ad-lib metronome |

Engine toggles: when Gunna wrap is on, **hide** GL/v4/v4.1 as the primary choice. Advanced disclosure can still A/B. GL on + wrap on is a contradiction — wrap wins, GL off.

World-building stays; it is SuperGunna *what*, not the clock.

**Copy (labels):** follow `clear-ui-labels`. “Gunna wrap” not “BarClock.” “Copy last 4 bars’ rhythm” not “FlowDNA interpolate.” “Sound cage” not “semantic/homophone metonymy.”

**Verification**

- [ ] Toggle wrap off → Phase 0 fields still inject; clock block omitted.
- [ ] Recipe word empty → no recipe JSON required.
- [ ] 4-bar job returns 4 lines on the suggestion card, not a 16 with 12 thrown away.

**Anti-patterns**

- Do not add 15 Ohm chips in this phase.
- Do not put BPM *only* on the note editor; the writing partner must show the folded number.

---

## Phase 5 — Reliability: overlay + listen test (definition of done)

If you can’t see a missed punch window, you will keep calling it “semi-good.”

**Soft overlay only** (debug + card subtitle), from wrap-clock scoring table:

| Signal | How |
|---|---|
| Last-stress in punch window | CMUDICT stress + BarClock |
| Setup shares lemma or rime with punch | 2-bar window |
| Rime grade ≥ near-perfect | onset/rime split; stop rewarding identical-word echo |
| Pocket repeated from bar n–2 | syllable-placement cosine |
| Concept carried across 4 | embedding vs 4-bar centroid |

No regenerate-until-pass. Selector may *tie-break* on these; it may not discard a witty line that is 1 syllable long.

**Listen test (you, not the grader):** 3 beats you actually rap over.

1. No-BPM wrap preset → should nod at ~92, punches on 3–4.
2. A 140-hat Wheezy-type instrumental → vocal still lazy, not double-time.
3. Recipe seed `ice` or `switch` + copy-last-4 → recognizable pocket, new nouns, one concept.

Pass = you would keep 2 of the 4 cycles without rewriting the rhythm. Fail = more prompt text will not save it; inspect overlay.

**Eval:** add a wrap cell to the existing ablation folder only after overlay exists. Do not trust NET (jargon-heavy, anti-repeat).

---

## Phase 6 — Optional chips (after wrap is reliable)

Only if Phase 5 listen test passes. Each is one chip, one prompt flag:

- Acrostic
- Story arc (F2) instead of 8 couplets
- Lyrical painting / instructional
- Break the run (already adjacent to 2/4/6/8)
- Scat-first (A7) via existing flow service
- Setup-only refs allowed (B2) — default on for Gunna (don’t cash every name)

Still never on the generator: memory palace, 6-step memorize, beatbox, Cory Gunz ladder, Head-Nod state ladder, “go home,” battle interlocking.

---

## What you haven’t mentioned (the complications)

These are why “inject Ohm into the writing partner” can fail even with good skills:

1. **Dead control path.** The sheet already has must-use, direction, world-building. v3/v4/v4.1 don’t read them. New buttons without Phase 0 = same disappointment.
2. **Two jobs smashed together.** Writing partner thinks “next 2/4 lines.” Coordinators always write a 16. Wrap needs a 4-bar *cycle* you can repeat. Until Job exists, “lines to generate” is a lie.
3. **v4.1 fights Ohm.** 3+1 payoff on bar 4 vs couplet with flip on beats 3–4 of *every* bar. Don’t stack them.
4. **Hats lie.** `beatDirective` treats ≥140 as double-time. Gunna wrap on modern trap will keep failing until fold exists.
5. **Prompt order.** Brands and “name something concrete” still outrank punch. The model optimizes the first thing it reads.
6. **P2 never landed.** “Do not repeat / imply more” still in `generateFullVerse`. That bans Gunna anaphora and the reveal.
7. **Copy-flow is new data, not more RAG.** Current retriever is words + embeddings of words. Without a syllable map, “copy flow” copies slang.
8. **Scoring still kills punchlines.** v4.1 P4: grader anti-correlated with wit. Overlay-only until the selector is a tie-break, not a tournament.
9. **Gemini Light is a third product.** Fast and deaf to wrap. Don’t A/B it against wrap as if they share a pipeline.
10. **Model G is not trained on Gunna.** Fine-tuning is a different project (data rights, not a prompt). This plan does not train weights.
11. **Dumping all Ohm skills → battle rap.** Interlock, keyword cages, acrostics, name-stack. Gunna is sparse. Clock + one recipe word + pocket repeat is the product.
12. **Legal interpolation.** Copy the clock from the user’s last bars or a pasted 4, not a bundled Thug/J Hus lyric pack.
13. **No ear on the sheet.** If you only read the card, caption-rap still “looks” specific (brands). Wrap is audible. Phase 5 listen test is the gate.
14. **Syllable count ≠ clock.** BPM already scales 8–10 syllables. That is density, not *when* the last stress lands.
15. **Rhyme groups aren’t rimes.** Magnifier groups words. Ohm rhymes `ap`, not the whole token. Point `RhymeClusterEngine` at rime (wrap-clock rule 6) before adding more rhyme chips.
16. **Inspiration slider currently asks for family resemblance of phrasing.** That’s plagiarism pressure. Move it onto flow-map resemblance.
17. **World-building is buried** and only hits retrieval tags. After Phase 0 it can stay as SuperGunna *what*.
18. **Exposure “imply don’t explain”** from Signal Layer still fights punch reveals on low-exposure notes. Wrap preset must win on the punch bar.
19. **Facebook harvest still incomplete.** Don’t block wrap on more Ohm clips. You have the clock.
20. **Success metric.** “Sounds like Gunna” is pocket + delay + sparsity, not more luxury nouns. If NET goes down and the nod goes up, that is a win.

---

## Skill routing (what goes where)

| Skill | Where it lives | Phase |
|---|---|---|
| BarClock, punch 3–4, 4-bar cycles, hat-fold, pocket | Prompt + `GenerationContext` | 1 |
| Direction / must-use / topics actually inject | `generateFullVerse` | 0 |
| Word recipe (B1) | Plan JSON + writing-partner field | 2 |
| Semantic / homophone cage (B4) | Plan JSON + writing-partner field | 2 |
| Keyword cage 4–6 | Relabel must-use; default off | 2 / 4 |
| Copy-flow (L4) | Flow map retrieve + “last 4 rhythm” | 3 |
| Couplet vs 3+1 vs closed-loop | Punch grammar chip | 1 / 4 |
| Onset/rime grades | Overlay; later rhyme groups | 5 |
| Story / acrostic / painting / break-run | Chips | 6 |
| Articulation, memory, Head-Nod ladder, beatbox | **Not generation** | never |
| SuperGunna 1 brand/bar | Keep | all |

---

## Suggested ship order (do not parallelize 0–1)

0. Dead path (one afternoon). Prove must-use + direction appear in the live prompt.
1. BarClock + 4-bar + hat-fold + wrap block + drop imply/no-repeat. Listen test on 92 and on a 140-hat beat.
2. Word recipe + semantic cage on the plan call. One writing-partner text field each.
3. Copy last-4 rhythm. Filter fragments.
4. Wrap section UI (preset, pocket, job, grammar).
5. Overlay + your three-beat listen gate.
6. Optional chips only if 5 passes.

If time is short: **0 + 1 + listen test.** That is the reliability jump. Recipe/cage/copy-flow make it *clever*. Clock makes it *wrap*.

---

## Verification (final)

- [ ] Writing partner Direction + must-use show up in `generateFullVerse` user string.
- [ ] 140 BPM note + Gunna wrap → folded pocket in prompt, not “double-time.”
- [ ] Default wrap writes 4×4, last stress instructed on 3–4, exemplar 4-bar present **above** brands.
- [ ] `do not repeat the same word` / `imply more than you state` absent on wrap path.
- [ ] v4.1 3+1 is a chip, not the silent default.
- [ ] Recipe seed changes the plan JSON; empty seed does not.
- [ ] Copy-flow uses a syllable map; “Yeah” never retrieved.
- [ ] No new HardRejection reasons.
- [ ] Listen test 3/3 recorded in Build Status when you ship.

---

## Execution handoff

Plan saved to:

- Vault (canonical): `🧠 Penwork Studios - Model G/Model G — Wrap Wiring Plan (Ohm → Writing Partner, 2026-08-24).md`
- Repo: `Documents/The Final Journal AI/docs/superpowers/plans/2026-08-24-model-g-wrap-wiring.md`

## Desktop lyric CSV — do not ingest for wrap (2026-08-24)

Found `~/Desktop/CGO 2026/chronological_lyrics_source_of_truth.csv` (8,133 lines, 524 songs: Gunna 4,215 / Thug 1,407 + YSL collabs) and `ground_truth_rap_bars_MODEL_G.csv` (phonetic + `bar_group_4` + stress). The second file is already what `GroundTruthRetriever` and `ModelGCorpus.json` RAG read.

**Use later (Phase 3 copy-flow), not now:**
- `bar_group_4` + `syllable_count` + `stress_pattern` → retrieve a *syllable map*, strip the nouns
- Verse rows only (skip Chorus — 2,367 of 8,133 are chorus)

**Do not dump into Phase 1 prompts:**
- No BPM / pocket / punch-window columns. `flow_vector` is `syllables|density|index`, not beat 3–4 placement
- Verbatim Gunna/Thug as BLUEPRINT = plagiarism + caption-rap (the v4 failure)
- SuperGunna already owns the nouns; wrap needs the clock

**Gaps if you want it as a flow index:** add BPM (or 4-bar duration), verse-vs-chorus already exists, onset/rime split, stress aligned to beats 1–4. Until then it is a lexicon, not a wrap teacher.

---

## Phase 0 shipped (2026-08-24)

Samuel asked to drop every other product model and start Phase 0 on a clean slate. Done. Simulator build **BUILD SUCCEEDED**.

**Product path now:** writing partner → `DirectedGenerationParams` → `ModelGCoreCoordinatorV4` → `generateVersePlan` + `generateFullVerse`. Corpus RAG stays (needed for copy-flow later). v4.1 3+1 is **not** on.

**Removed from the app (UI + router), files still on disk unused:**
- Model GL toggle and `ModelGeminiLightCoordinator` routing
- v4 / v4.1 engine toggles on Suggest next lines and Model Preferences
- v1 / v2 / v3 coordinator routing and v1+v2 parallel A/B
- Legacy generateSuggestions fallthrough (Core miss now throws `modelGCoreFailed` instead of Model Y)
- `do not repeat the same word` / `imply more than you state` on the live verse prompt
- House-style-over-topic system line (DIRECTION now wins)

**Added while building (plan addenda):**
- `DirectedGenerationParams.selectedRhymeGroups` so Core can inject Magnifier groups without a lookup table
- `IntentExtractor.extractForModelG` — Direction + must-use beat the draft; empty draft is no longer `"Continue in melodic trap style with luxury flex..."`
- Luxury moved **below** the writing-partner block
- Low-exposure voice no longer forbids naming the punch
- Regenerating a suggestion **keeps** last directed params (was dropping them)
- `SuggestionModel` enum cases kept so old UserDefaults don't crash; they all route to Model G
- `ModelGEnvironment.pinSingleModelGPipeline()` on launch + every generate

**Phase 1 shipped (2026-08-24):** `BarClock.swift`, hat-fold, wrap prompt block + Ohm 4-bar exemplar above luxury, four 4-bar cycles in the ask, dummy pad removed. Still asked for 16 JSON bars (four cycles). Wrap-section UI is Phase 4. Word recipe / copy-flow are Phase 2–3.

**Phase 2 shipped (2026-08-24):** `WordRecipe` + `SemanticCage` on `VersePlan`. Writing partner: Recipe word + Sound cage. Plan call cooks the image when a seed is present (or a single must-use token). `generateFullVerse` injects the cooked image, not the steps. 4–6 must-use words = keyword cage; 1 must-use = seed. Empty seed keeps the old 3-field plan JSON.

**Phase 3 shipped (2026-08-24):** Copy-flow. Priority: last 4 draft bars → pasted 4 → corpus *syllable map only* (no Gunna nouns in the prompt). Lyric RAG no longer says “lean HARD.” Fragments (`Yeah`/`Ah`) filtered from retrieval. Writing partner: “Copy last 4 bars' rhythm” (on by default) + paste a 4-bar pocket.

**Phase 4 shipped (2026-08-24):** Wrap section on Suggest next lines: Gunna wrap (default on), pocket, BPM Note/92/Custom with folded caption, job 4 vs 16, punch couplet/3+1/closed-loop 4, yeah on the 4. Wrap off omits the BarClock prompt block. 4-bar job returns 4 lines, not a padded 16.

**Phase 5 shipped (2026-08-24):** Soft **Wrap read** on the suggestion card (punch window / setup↔punch / rime near+ / pocket / concept). Selector may tie-break when v4Total is within 1.5; never a veto. One-word bars (Ohm's "special") count as punch even if CMUDICT stresses the first syllable. `WrapOverlayTests` **TEST SUCCEEDED** (8). Listen test: [[Model G — Wrap Listen Test (Phase 5)]]. Eval note: `eval/wrap_overlay.md`.

---

Plan saved to:

- Vault (canonical): `🧠 Penwork Studios - Model G/Model G — Wrap Wiring Plan (Ohm → Writing Partner, 2026-08-24).md`
- Repo: `Documents/The Final Journal AI/docs/superpowers/plans/2026-08-24-model-g-wrap-wiring.md`

**Phase 6 shipped (2026-08-24):** Optional schemes on Suggest next lines — one chip, one prompt flag. **Names can stay in the setup** (B2, default on). **Story arc** (F2, forces 16). **Describe the flow** (B7). **Rhythm first** (A7, fills copy-flow map). **Acrostic** (B6, blank = off). **Break the run** (F4, next to lines-per-rhyme). Not on the generator: memory palace, beatbox, Cory Gunz ladder, Head-Nod ladder, battle interlocking.

**Next:** run the three-beat listen test if you haven't. Extra chips stay off unless you want that drill.
