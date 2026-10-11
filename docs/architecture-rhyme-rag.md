# Penwork Studios · Rhyme RAG Architecture

_Created 2026-10-10. Scope: rhyme mining (+ song BPM/key/scale) → retrieval → rap engine quality → artist tailoring → blocks UI._
_Guardrails: the lyric vault (`tools/bar-hits-catalog/BarHitsCatalog.sqlite`) is read-only. No chip is promoted without review. Swift changes happen only in task 5, after review._

## Status

| # | Task | Status |
|---|------|--------|
| 1 | Rhyme mining from the vault | In progress (read-only analysis running) |
| 2 | Rhyme RAG / retrieval index | Not started |
| 3 | Rap engine rhyme quality (3 failure modes) | Not started |
| 4 | Artist-specific tailoring (data-backed successor to Model G axle) | Not started |
| 5 | Blocks integration (front-end wordplay layer, formerly noun bank) | Not started |
| 6 | Song musical metadata: BPM, key, scale (sub-task of 1, feeds 2–4) | Not started (sources picked: Spotify, TuneBat, WhoSampled) |
| 7 | AI Sparkle: blocks footnote under each 16-bar suggestion | Spec written; build not started (needs Samuel's go-ahead for Swift) |

## Vault at a glance

- 1,708,472 bars, 785 artist names in the vault, but only **81 main artists** (20+ songs each; 66 have 100+).
- The other **704** are small accounts, features and one-offs that got scraped in (695 have under 20 songs). They stay in the vault for rhyme examples, but they don't get their own artist profile or blocks bank.
- Label noise to clean in task 1: "Quality Control" is a label, not an artist. Features are filed under the page owner, some titles hold HTML, and there are AI-made and fan-made entries.

## How it all fits together

1. **Vault:** 1.7M bars, 81 main artists plus small accounts. This is the raw material.
2. **Mining (1):** pulls rhyme patterns and writes per-bar annotations: rhyme sound, syllable position, stress, type and chain ID, plus the song-level block (tempo, half-time flag, key, major/minor, source, confidence).
3. **Retrieval index (2):** matches on rhyme sound first, reranks by meaning, then filters by artist, tempo range and key.
4. **Rap engine (3):** queries the index while writing. Syllable density follows the song's BPM, and inner rhyme chains hold because chain IDs link bars.
5. **Artist profiles (4):** Model G (Gunna) and Model Q (Quavo) track flow per tempo/key band, built from vault data, not hand-set sliders.
6. **Blocks (5):** the visual layer, one bank per artist, holding the wordplay relationships the suggestions should hit.
7. **Song music data (6):** fills the tempo/key table that makes the tempo and key filtering possible.
8. **AI Sparkle receipts (7):** under each 16 bars, a footnote shows the blocks the AI used. Each block traces back to real bars where that artist actually rapped about it (e.g. Quavo naming NFL players, getting his teeth straightened, his co-artists). That proves the verse came from places the artist really went, not something the AI made up.

## Order and dependencies

```
[1] Rhyme mining ──► [2] Retrieval index ──► [3] Engine quality ──► [4] Artist tailoring
        │                    │                                          │
        └── annotation ──────┴──────────────► [5] Blocks integration ◄┘
            schema           (wordplay links + rhyme families shown as chips)
[5] Blocks + [3] engine output ──► [7] AI Sparkle footnote
[6] BPM / key / scale per song ──► joins [1] schema ──► filters/weights in [2], conditions [3]/[4]
```

Recommended order: 1 (+6 in parallel) → 2 → 3, with 5's data model designed alongside 2. Task 4 comes after 3 is measurable.

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

- **Also (entity resolution):** mining tags each bar's people, characters and brands via the context-aware alias map (see task 5). It doesn't use plain string matching.

## 1b. Rhyme annotation schema: musical metadata (song level)

Every bar annotation carries its song's musical context, so retrieval can match flow to the beat, not just the sound:

```json
"song_music": {
  "bpm": 142.0,                 // detected tempo
  "bpm_feel": "half|normal|double", // trap is often felt at half time (e.g. 140 → 70)
  "key": "F#",                  // tonic, pitch class
  "scale": "minor",             // major | minor
  "source": "api|audio_analysis|manual",
  "confidence": 0.0
},
"flow": {
  "syllables_per_beat": 0.0,     // syllable_count ÷ beats in the bar at song BPM
  "density_band": "sparse|mid|dense|double_time"
}
```

**Why:** artists change speed and syllable count with the genre and the feeling of a track. The same rapper packs bars on a fast, dark minor-key beat and stretches melodic lines on a slow major-key one. If the engine pulls rhyme examples without tempo, it borrows a flow that doesn't fit the beat. So:
- **Retrieval (2):** filter or weight by BPM band (±8 BPM, half/double-time aware), key and scale alongside rhyme sound and artist.
- **Engine (3):** set the target syllables per bar from the song's BPM plus the artist's density at that tempo.
- **Artist tailoring (4):** profiles become tempo-conditioned, e.g. Model G (Gunna) and Model Q (Quavo) each with syllable density, rhyme density and melody habits per BPM/key/scale band, not a single average.

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

## 5. Blocks integration (formerly "noun bank")

- **Goal:** the existing blocks, renamed from "noun bank" on 2026-10-10 (Swift names like `NounBankStore` stay until a deliberate rename; files: `NounBankStore.swift`, `NounBankSections.swift`, Wordplay / "Sound flips" chips with images) become the visual layer for wordplay and rhyme relationships.
- **Design principle: one blocks bank per artist.** Every artist gets a dedicated blocks bank scoped to them, not one global bank. Example: bars that mention Uzi's eye roll or Uzi's shoulders, and the blocks tied to them, live in **Uzi's fold**. A block can appear in several artists' banks (same image reused), but each bank holds only that artist's bars as receipts.
  - Affects **task 5**: the data model is keyed by artist (`artist_id → blocks[] → source bar ids`), and the UI opens on the active artist's bank.
  - Affects **task 7**: AI Sparkle's footnote draws only from the active artist's bank, so every highlighted block points back to bars that artist actually rapped.
- **Design principle: catch indirect references, and resolve aliases by context, not string match.**
  - **Today:** a bar only qualifies for a block or artist fold when the name or stage name appears literally (e.g. "Lil Uzi Vert").
  - **Goal:** also catch bars that reference something strongly tied to a person or character without naming them.
  - **Known failures to stop:** "Bruce Wayne" (Batman) was missed and filed under Bruce Lee, and Hulk (Bruce Banner) landed in the wrong fold. Shared first names and secret identities can't be resolved by matching strings.
  - **Fix: a per-artist / per-entity alias map** built from known references. Each entry: `canonical_entity` (e.g. Batman), `aliases` (Bruce Wayne, the Dark Knight, Gotham), `type` (person/character/brand/place), `domain` (comics, martial arts, NFL…), `context_cues` (co-occurring words like Robin, Joker, cape vs kung fu, dragon, nunchucks), and `negative_cues`.
  - **Seed entries:**
    - **Young Thug:** aliases `Thugger`, `Jeffery` (his real name, Jeffery Lamar Williams; also the 2016 album *JEFFERY*), and the common misspelling `Jeffrey`. Bars where other artists call him Jeffery/Jeffrey file under Young Thug, not a separate person. Context cues: YSL, slime, Gunna, Lifestyle, Atlanta, Thug. Negative cues for other Jeffreys: Dahmer, Epstein, Bezos. Same context-aware scoring and review threshold as every alias.
    - **Quavo (Migos):** aliases `Huncho` (also his 2018 album *Quavo Huncho*) and `Quavious` (real name Quavious Marshall). Bars where other artists call him Huncho file under Quavo. Context cues: Migos, Takeoff, Offset, Nawf, QC, Mama. Watch out for *Huncho Jack*, his duo with Travis Scott: if Travis or "Jack" is on the line, flag it for review or file under both. Same context-aware scoring and review threshold.
    - **Future:** aliases `Pluto` (also his 2012 album *Pluto*), `Future Hendrix` and `Hndrxx`. Bars where other artists call him Pluto file under Future. Context cues: Freebandz, Hendrix, Metro Boomin, Atlanta, 56 Nights, Wizrd. Negative cues: the planet (space, planets, Mars, NASA) and the Disney dog (Mickey, Goofy). "Future" itself is a common word, so it needs these cues too and is never matched on the word alone. Same context-aware scoring and review threshold.
    - **Gunna:** legal name Sergio Giavanni Kitchens (verified: Wikipedia, Library of Congress). Aliases: `Wunna` (documented; 2020 album *WUNNA*), `Gunna Wunna`, `YSL Gunna`, and `Wanna` (per Samuel, unverified; only matches with a strong Gunna cue on the line). Context cues: YSL, Young Thug, Slime, Drip, P / pushin P, Lil Baby, Wheezy, College Park. Away: gun, "gonna", "want to", YNW. Same context-aware scoring and review threshold.
    - **Full alias map (approved by Samuel 2026-10-10):** [`docs/alias-map.md`](alias-map.md), machine-readable [`docs/alias-map.json`](alias-map.json). It covers all 77 resolved artists/groups with 20+ songs, re-file notes for 4 label/producer rows (Quality Control, Young Stoner Life, Sniper Gang, YUME), and 13 character-collision seeds. Gunna: legal name Sergio Giavanni Kitchens (verified); documented nickname Wunna; "Wanna" is unverified (no evidence found).
  - **Context-aware matching:** score each candidate entity by alias hit + context cues on the line and the neighbouring bars + the artist's known reference history (what this artist usually raps about) + genre. Choose the top entity only above a confidence threshold. If two entities are close (Bruce Wayne vs Bruce Lee), mark it **ambiguous** and send it to review. Never auto-file a near tie.
  - Every match stores `matched_alias`, `resolved_entity`, `confidence` and `evidence` (the cue words), so wrong folds can be audited and corrected. Corrections feed back into the alias map's negative cues.
  - **Affects:** task 5 (how blocks and folds are organized) and the mining pipeline (task 1 runs entity resolution and writes these fields alongside the rhyme annotations).
- **Approach:**
  - Link rhyme families and sound flips to noun chips (e.g. a chip shows its rhyme partners and example bars).
  - Rhyme suggestions in the engine surface as tappable chips.
  - Reuse existing chip images per the blocks image rules.
  - Data stays in the index from task 2. Swift reads it through a thin adapter, with no hard-coded strings beyond what chat 4 already wires.
- **Dependencies:** the task 2 data model, and confirmed wordplay from the re-review (chat 7) and wiring (chat 4) pipeline. Swift work starts only after review.

## 6. Song musical metadata (BPM, key, scale)

- **Goal:** a BPM, key and scale (major/minor) for every vault song. The vault has none today.
- **Approach:**
  - Collect it into a separate table (`song_music`, keyed by artist + song), never the vault.
  - **Sources (chosen by Samuel 2026-10-10):** Spotify, TuneBat, WhoSampled.
    - **Spotify:** tempo, key, mode (major/minor) and time signature via the Web API audio-features endpoint. This is the preferred source *if* Samuel's Spotify developer app has access. Spotify restricted audio-features for new apps in Nov 2024, so check first.
    - **TuneBat:** per-song BPM, key and scale pages (camelot key, energy). No API key, so it's the easiest to automate, but check its terms and stay polite (one request at a time, a few seconds apart).
    - **WhoSampled:** sample, interpolation and cover links (which song a beat flips). It's not a reliable BPM/key source. Use it for producer/sample context and to cross-check related tracks.
  - **Start order:** check Spotify access first. If it's unavailable, start with TuneBat. Add WhoSampled as enrichment afterwards.
  - **Fallback (Samuel: "If not, then you could also use your own sources to figure out how to get that done."):** if Spotify, TuneBat and WhoSampled don't give a song's BPM/key/scale, Penwork derives it with its own sources and methods. Use whatever works within each source's terms:
    - Audio analysis with libraries like librosa, Essentia or aubio for tempo and key detection, where audio is legally available.
    - Other public metadata sources (e.g. MusicBrainz/AcousticBrainz-style datasets, other open music databases).
    - Inference from related tracks, e.g. the same beat or sample via WhoSampled, or the same producer/album.
    - Manual entry for priority songs.
    Mark every value with its `source` and `confidence`, so derived values can be told apart from looked-up ones.
  - Store the source and confidence. Flag half-time/double-time ambiguity.
  - Start with the 81 artists with 20+ songs and the Model G (Gunna) and Model Q (Quavo) targets.
- **Dependencies:** song identity cleanup from task 1 (split features, strip HTML titles). Runs in parallel with 1 and must land before tempo-aware retrieval in 2.

## 7. AI Sparkle (blocks footnote)

- **Goal:** show how the AI was thinking. After the rap suggestion section produces 16 bars, a visual footnote at the bottom highlights the **blocks** used to write them. This builds Samuel's confidence in the lines.
- **What gets highlighted:** any block type: persons, places, things, phrases, wordplay, idioms and other figures of speech.
- **Approach:**
  - The engine (3) returns, with the 16 bars, a `used_blocks` list: block id, type, the bar number(s) and the span where it landed, and why it was used (rhyme partner, setup, sound flip, idiom twist).
  - The UI renders those as block chips with their images under the verse. Tapping a chip highlights its span in the bars and shows the retrieved example bar it came from.
  - Only blocks actually present in the output are shown, verified by span match. Never decorative or invented ones.
- **Scope:** blocks come from the active artist's own blocks bank (see the per-artist principle in task 5).
- **Receipts (the point of the feature):** every highlighted block carries 1–3 **receipt bars**, real vault bars where the active artist used that block (artist, song, line). Tapping the chip shows them. If a block has no receipt from the active artist, it's shown as "new idea, no receipt" instead of being hidden or faked.
- **Data contract (engine → UI):**
  ```json
  {"verse_id":"…","artist":"Quavo","bars":["…16 lines…"],
   "used_blocks":[{"block_id":"nfl-players","type":"person|place|thing|phrase|wordplay|idiom|figure_of_speech",
     "bar_index":7,"char_span":[12,24],"role":"rhyme_partner|setup|sound_flip|idiom_twist|reference",
     "receipts":[{"bar_id":"…","song":"…","line":"…"}],"confidence":0.0}]}
  ```
- **UI:**
  - A chip row under the verse, using the block's image and a type badge.
  - Tap a chip to highlight its span in the bars and show its receipts.
  - Blocks with no receipt get the "new idea" style.
- **Acceptance checks:**
  - Every chip's span really exists in the 16 bars.
  - Every receipt is a real vault bar from the active artist's bank.
  - No chip is shown for a block that isn't in the output.
  - Ambiguous alias matches (see task 5) never become chips without review.
- **Dependencies:** 3 (engine must record block usage), 5 (blocks data + images), 2 (provenance of retrieved examples).

## Open questions

- Embedding model: on-device or server.
- ~~Which BPM/key source is allowed~~ Answered: Spotify, TuneBat and WhoSampled are the candidate set. Still open: does Samuel's Spotify app have audio-features access?
- Do double meanings (not just sound flips) count as wordplay for chips and retrieval? This needs Samuel's call.
- Where the rhyme index lives in the app bundle vs downloaded.
