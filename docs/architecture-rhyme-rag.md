# Penwork Studios · Rhyme RAG Architecture

_Created 2026-10-10. Scope: rhyme mining → retrieval → rap engine quality → artist tailoring → noun bank UI._
_Guardrails: the lyric vault (`tools/bar-hits-catalog/BarHitsCatalog.sqlite`) is read-only. No chip is promoted without review. Swift changes happen only in task 5, after review._

## Status

| # | Task | Status |
|---|------|--------|
| 1 | Rhyme mining from the vault | In progress (read-only analysis running) |
| 2 | Rhyme RAG / retrieval index | Not started |
| 3 | Rap engine rhyme quality (3 failure modes) | Not started |
| 4 | Artist-specific tailoring (data-backed successor to Model G axle) | Not started |
| 5 | Noun bank integration (front-end wordplay layer) | Not started |

## Order and dependencies

```
[1] Rhyme mining ──► [2] Retrieval index ──► [3] Engine quality ──► [4] Artist tailoring
        │                    │                                          │
        └── annotation ──────┴──────────────► [5] Noun bank integration ◄┘
            schema           (wordplay links + rhyme families shown as chips)
```

Recommended order: 1 → 2 → 3, with 5's data model designed alongside 2. Task 4 comes after 3 is measurable.

---

## 1. Rhyme mining from the vault

- **Goal:** find out how rappers in the vault actually rhyme (multisyllabic, internal, chains), and produce structured rhyme annotations.
- **Approach:**
  - Read-only pass over `bars` (artist, song, line, syllables, end_word, phonetic_class) and `cadence_punches`.
  - Phonetic keys from CMUdict, with a slang fallback.
  - Detect end rhymes, internal rhymes, multisyllabic matches (2+ vowel+coda syllables) and chains across consecutive bars.
  - Output: a report, vault-wide rates, real examples, and a JSON annotation schema (rhyme units, syllable/char spans, position, type, chain id, partner bars, stress, artist/genre tags, topic).
- **Dependencies:** vault only. Joins with the existing Genius click logs and wordplay highlights to cross-reference sound flips.
- **Output:** `rhyme-rag-report.md` and `sample-annotations.jsonl`, saved outside the app.

## 2. Rhyme RAG / retrieval index

- **Goal:** let the rap engine pull real rhyme examples by sound, by meaning and by style.
- **Approach:**
  - Run the annotator over the full vault into a separate store (e.g. `rhyme-index.sqlite`, never the vault).
  - Three access paths:
    - **Phonetic:** rhyme-family key, syllable count, stress pattern.
    - **Semantic:** line embedding plus topic tag.
    - **Style:** artist, era, region, slang lexicon.
  - Hybrid query: phonetic filter, then semantic rank, then style rerank. Returns bars with partner lines and chain context.
- **Dependencies:** the task 1 schema and annotator. An embedding model choice (on-device or server).

## 3. Rap engine rhyme quality

- **Goal:** fix the three failure modes.
  - **Rhymes that make sense:** retrieve candidates by phonetic family, then filter by semantic fit to the setup line. Reject rhymes that only match in sound.
  - **Genre fit:** condition generation on retrieved bars from the target style, and use a slang/lexicon whitelist per style.
  - **Inner rhyme chains:** track the active chain (rhyme family + syllable positions) across bars. Retrieval asks for chain continuations, not just end-word matches.
- **Approach:** a retrieval-augmented prompt or decoder constraint, scored by an automatic rhyme checker that reuses the task 1 annotator. Build an eval set from held-out vault bars.
- **Dependencies:** task 2 index, plus an eval set.

## 4. Artist-specific tailoring

- **Goal:** generated bars match one chosen artist's style.
- **Approach:**
  - Evolve the Model G "axle" idea into a data-backed artist profile computed from the vault.
  - Profile fields: rhyme density, multisyllable rate, chain length, internal rhyme placement, favorite rhyme families, cadence (syllables per bar, from `cadence_punches`), lexicon/slang, and wordplay type mix (sound flips vs double meanings, from the Genius wordplay pass).
  - Retrieval is biased toward that artist's bars. The checker scores how close the output stays to the profile.
- **Dependencies:** tasks 2 and 3. Per-artist coverage: the 81 artists with 20+ songs are the practical set.

## 5. Noun bank integration

- **Goal:** the existing noun bank (`NounBankStore.swift`, `NounBankSections.swift`, Wordplay / "Sound flips" chips with images) becomes the visual layer for wordplay and rhyme relationships.
- **Approach:**
  - Link rhyme families and sound flips to noun chips (e.g. a chip shows its rhyme partners and example bars).
  - Rhyme suggestions in the engine surface as tappable chips.
  - Reuse existing chip images per the noun bank image rules.
  - Data stays in the index from task 2. Swift reads it through a thin adapter, with no hard-coded strings beyond what chat 4 already wires.
- **Dependencies:** the task 2 data model, and confirmed wordplay from the re-review (chat 7) and wiring (chat 4) pipeline. Swift work starts only after review.

## Open questions

- Embedding model: on-device or server.
- Do double meanings (not just sound flips) count as wordplay for chips and retrieval? This needs Samuel's call.
- Where the rhyme index lives in the app bundle vs downloaded.
