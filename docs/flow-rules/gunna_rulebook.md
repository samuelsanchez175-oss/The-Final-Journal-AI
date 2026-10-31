# Gunna rulebook — mined from his vault

**Vault:** `tools/bar-hits-catalog/BarHitsCatalog.sqlite` (opened read-only).
**Pulled:** 2026-10-30. **Validated through v4:** 2026-10-30.
**Scope:** 7 artist variants matched (`artist LIKE '%gunna%'`), 31,508 lines across 739 unique songs.
**Solo-only subset** (`artist = "Gunna"`): 30,553 lines. All rules below use the solo subset unless noted. CMU dict loaded.

## Caveats found in validation — read before trusting any number

### A. Vault stores a MINORITY of songs alphabetically — true-order subset is 593 of 739.

Full per-song flag table in `song_order_flags.json`:

| flag | definition | songs | lines |
| --- | --- | ---:| ---:|
| **order_preserved** (alpha-pair-rate < 0.6) | real song order | **593** | **25,361** |
| alphabetical (rate ≥ 0.9) | row-sorted at ingest | 102 | 4,469 |
| unclear (0.6 ≤ rate < 0.9) | mixed | 21 | 705 |
| too_short (<5 lines) | — | 5 | 18 |

Earlier estimate "most songs stored alphabetically" was wrong — based on the biggest 7 songs only. In fact **80% of Gunna's songs preserve order**, 14% are alphabetical, 3% unclear. Order-dependent stats in v5 are reported on the **order_preserved subset only** (593 songs, 25,361 lines, 24,768 adjacent pairs).

### Can we restore the alphabetical subset from Genius click-logs?

Looked for `docs/play-on-words/genius-clicks/gunna*.jsonl` and other local Gunna lyric caches. **Nothing exists on this branch for Gunna.** No new fetching yet (per instructions). Restoration count: **0 of 102 alphabetical songs**.

Per-line rules (commas, inner-rhyme-per-line, triplet, POV, mood, subtopics, multisyllable-end-word, top end words) are UNAFFECTED by order — those still describe his vault faithfully.

Fix: this rulebook's order-dependent stats are reported with a caveat marker. A clean rerun requires either reconstructing song order (hard without a click-log / Genius ingest side-file) or ignoring order-dependent stats until that lands.

### B. CMU dict was read incorrectly in v1-v3.

`CMU.get(word)` returns a flat phone list for the first pronunciation (e.g. `understood` → `['AH2', 'N', 'D', 'ER0', 'S', 'T', 'UH1', 'D']`). Three scripts (`02_analyze_text.py`, `03_migos_triplet_reference.py`, `12_rhyme_anchor.py`, `09_slant_rhyme.py`, `11_hook_vs_verse.py`, `05_pull_examples.py`) treated it as a list of pronunciation strings and called `phones[0].split()`, which returned only the first phone. Syllable counts collapsed to 1 for every CMU-known word; anchor tails collapsed to 1-element tails for every word.

Fixed in all six scripts. Deltas on key stats below. The learned-via-end_rime stats (`inner-rhyme mean`, `end-rime 4-bar`, `end-word consecutive`) were NOT affected because `lyriclib.end_rime` reads the dict correctly.

### Combined effect — v3 → v4 corrected numbers

| rule | v3 (bug) | v4 (bug fixed) | notes |
| --- | ---:| ---:| --- |
| anchor adjacent exact | 2.77% | **11.92%** | order-dependent — mostly alphabetical pairs |
| anchor adjacent slant | 0.36% | **3.68%** | order-dependent |
| anchor adjacent assonance | 14.56% | **27.54%** | order-dependent |
| anchor adjacent none | 82.32% | 56.86% | order-dependent |
| anchor 4-bar single-rime | 0.27% | **1.27%** | order-dependent |
| end-word adjacent exact | 8.46% | **14.39%** | end-word-only; still order-dependent |
| end-word adjacent slant+assonance | 5.68% | **32.77%** | — |
| multisyl internal rhyme on 2+syl end-word lines | 49.35% | **29.73%** | per-line; now correct |
| triplet rate (text-only, 3 runs / 8 tokens) | 1.46% | **53.27%** | threshold tightened post-fix; still indistinguishable from Migos 47.64% / Quavo 51.17% / Takeoff 46.89% / Offset 52.08% — text alone can't see triplet flow |
| density (≥16 syl + ≥3 commas) | 0% | 1.52% | now meaningful |

### C. Detector precision/recall on hand-labeled rhyme (3 verified-order sections)

Three sections where the vault preserves song order; hand-labeled rhyme groups per bar then compared against the anchor detector (exact + slant + assonance = "rhyme"):

| song (bars) | n_bars | hand pairs | detector pairs | TP | FP | FN | **precision** | **recall** | F1 |
| --- | ---:| ---:| ---:| ---:| ---:| ---:| ---:| ---:| ---:|
| pushin P 3-13 | 11 | 37 | 36 | 36 | 0 | 1 | **1.000** | **0.973** | 0.986 |
| Understood 5-14 | 10 | 9 | 8 | 6 | 2 | 3 | 0.750 | 0.667 | 0.706 |
| Floyd Mayweather 5-14 | 10 | 22 | 29 | 12 | 17 | 10 | 0.414 | 0.545 | 0.471 |
| **overall** | 31 | 68 | 73 | 54 | 19 | 14 | **0.740** | **0.794** | **0.766** |

The detector reaches **F1 ≈ 0.77 on verified-order sections**. `pushin P` is a stylized AAAA song, trivially caught. `Floyd Mayweather` drops in precision because many "I" vowel lines land false-positive assonance against each other (`wrist / dick` as "same AA/IH vowel" when they aren't). Full comparison + false-positive / false-negative lists in `rhyme_hand_vs_detector.md`.

### D. 4-bar window — any 2+ bars share anchor vowel

On the order-preserved subset (593 songs, 6,126 four-bar blocks): **90.94%** of 4-bar windows have at least two bars sharing their anchor vowel. On the full set it was 88.36%. Gunna keeps vowel families inside short windows almost universally.

### E. v5 — order-dependent numbers on the clean subset only

| rule | v4 (full set) | **v5 (order-preserved only)** |
| --- | ---:| ---:|
| adjacent exact (anchor) | 11.92% | **12.88%** |
| adjacent slant (anchor) | 3.68% | **4.03%** |
| adjacent assonance (anchor) | 27.54% | **29.81%** |
| adjacent none | 56.86% | 53.27% |
| 4-bar single-rime (anchor) | 1.27% | **1.39%** |
| 4-bar any-2-share-vowel | 88.36% | **90.94%** |
| carry rate (grammar) | 27.39% | **27.54%** |

Numbers barely move because 80% of songs already preserved order; alphabetical contamination was small.

Carry lengths on the clean subset: length-2 × 4,472, length-3 × 533, length-4+ × 172.

### F. Detector precision / recall by tier (31 hand-labeled bars across 3 verified-order sections)

| tier | precision | recall | F1 | TP | FP | FN |
| --- | ---:| ---:| ---:| ---:| ---:| ---:|
| exact only | **0.955** | 0.309 | 0.467 | 21 | 1 | 47 |
| exact + slant | **0.933** | 0.412 | 0.571 | 28 | 2 | 40 |
| exact + slant + assonance | 0.740 | **0.794** | 0.766 | 54 | 19 | 14 |

Reading: the exact rule is nearly perfect precision (95.5%) but misses two-thirds of real rhymes because many Gunna "rhymes" are slant/assonance that don't share the full stressed-syllable tail. The exact+slant tier buys +10 pp recall at a cost of ~2 pp precision. Including assonance pushes recall to 79% at ~26 pp precision cost — assonance is correctly a looser signal. False-positive examples (Floyd Mayweather `wrist` / `dick`): both share IH vowel but have different consonant tails; detector correctly tags as assonance, hand said "no", so precision drops.

The user's directive was followed: `exact` requires the full anchor tuple to match (not just vowel), `assonance` stays vowel-only. The precision gap is in the assonance tier by design.

### G. Same CMU bug check across `tools/lyric-llm/`

Full grep for `phones[0].split()` and `cmu.get(...)[0].split()` patterns in `tools/lyric-llm/`:

| file | line | status |
| --- | ---:| --- |
| `tools/lyric-llm/taste/chips_export.py` | 90 | **HAS the bug** — same `phones[0].split()` pattern as the flow-rules scripts |
| `tools/lyric-llm/catalog_retriever.py` | 1483 | not the same bug — splits a whitespace-separated rime string, intentional |

Every other direct `cmu.get(word)` dereference in the lyric-llm core (`desk.py`, `inner_rhyme_check.py`, `lyriclib.py`, `cadence_analyzer.py`, `catalog_retriever.py:200`, `frontier_v5.py:1189`, `polish.py`) treats the result as the flat phone list and does NOT split, i.e. correct.

Reporting only, per instruction — did NOT edit `frontier_v5.py` or any other `tools/lyric-llm/` file. `chips_export.py:90` fix is deferred to a session that owns that code; the only downstream user of its syllable count is the chips.jsonl `syllables` field (which under-reports syllables and should be regenerated once fixed).

## Validation summary (v1 → v3)

v1 → v2: ad-libs stripped, slant/assonance broken out, carry recomputed on grammar.
v2 → v3: rhyme anchor shifted from end-word rime to **last stressed syllable + all suffix phones** (so `flipped it` / `dipped it` → `IH1 P T IH0 T` match); hook detector loosened to **SequenceMatcher ratio ≥ 0.8, cluster ≥ 3**.

### Rhyme — v2 end-word vs v3 anchor (adjacent pairs, ad-libs stripped)

| category | v2 end-word | v3 anchor | definition |
| --- | ---:| ---:| --- |
| exact     | 8.46%  | **2.77%** | anchor tuples equal (last stressed vowel through end of line) |
| slant     | 1.98%  | **0.36%** | same anchor vowel + same consonant-group tail |
| assonance | 3.70%  | **14.56%** | same anchor vowel only |
| none      | 85.85% | 82.32% | — |
| **total touching** | 14.14% | **17.69%** | sum of exact + slant + assonance |

Pairs examined v2 29,754 → v3 29,832.

**Reading this.** The anchor makes `exact` stricter (fewer pairs match the full stressed-syllable tail) and `assonance` more generous (he lands on the same stressed vowel often, varies the consonants). Net rhyme-touching rate rises from 14.1% to 17.7%. The 4-bar single-rime rate drops from 3.11% to **0.27%** on the anchor — the long stressed-syllable tail rarely holds across four lines in a row.

### Hooks — strict vs fuzzy

| detector | hook lines | % of 30,553 solo | songs with ≥1 hook (of 739) | cluster-size histogram |
| --- | ---:| ---:| ---:| --- |
| strict (norm equal, ≥3 copies) | 75 | 0.25% | 19 | 25 clusters of size 3 (plus ties); very narrow |
| **fuzzy (SequenceMatcher ratio ≥ 0.8, ≥3 copies)** | **293** | **0.96%** | **73** | size 3 × 71, size 4 × 16, size 5 × 2, size 6 × 1 |

Fuzzy picks up 4× more hook lines. Still low — Gunna hooks often repeat twice (not three times), or vary heavily between repeats (so the 0.8 similarity floor can't cluster them). This is a floor, not a ceiling. Sample fuzzy clusters in `hook_fuzzy_stats.json`.

Verse-only recompute (hooks excluded) still moves every rule under 0.3 pp, so hook contamination of the overall numbers is small.

### Other v1 → v2 fixes (unchanged in v3)

| rule | v1 | v2 | why it moved |
| --- | ---:| ---:| --- |
| top end word | `yeah` 1,944 | `it` 907, `me` 592, `up` 283, `you` 187, `out` 168 | ad-libs stripped before taking the end word |
| carry (enjambment) | 5.68% | **27.39%** | capitalization-based detector missed every carry that ended on a comma or no punctuation; grammar-based detector picks them up |

### Line-order sanity (unchanged)

3 well-known songs (`pushin P`, `fukumean`, `Baby Birkin`) pulled in rowid order. Median rowid stride 1, zero >5× gaps, zero exact-duplicate lines across the three. First 8 lines of `pushin P` match the released song's opening. No external Genius click-log on this branch. See `line_order_check.md`.

### AcousticBrainz run

Running at write time; MusicBrainz 1 req/s → AcousticBrainz (frozen 2022). Partial cache at `docs/flow-rules/cache/{musicbrainz,acousticbrainz}/`. Final CSV at `docs/flow-rules/gunna_acousticbrainz.csv` once the fetch finishes. Tempo correlation (step 8) runs after.

Variants in the vault:

| artist tag | lines |
| --- | ---:|
| `Gunna` | 30,553 |
| `Young Stoner Life, Young Thug & Gunna` | 361 |
| `Lil Baby & Gunna` | 304 |
| `Lil Baby, Gunna, Drake` | 100 |
| `Young Stoner Life & Gunna` | 85 |
| `Gunna & Future` | 78 |
| `Internet Money, Gunna & Don Toliver` | 27 |

The vault doesn't tag which verse belongs to whom inside a collab track, so collab rows mix voices — that's why the solo subset is the primary measurement.

---

## Commas (caesura)

**Rule 1 — Most lines carry 0 or 1 comma.** 44.25% of lines have NO comma; 40.65% have exactly one; 11.19% have two; 3.90% have three or more. Mean commas per line: **0.76**. He breathes once per line more often than any other pattern.

0 commas (3/5):
- `[$$$ (dollar sign)]` "I caterpillar all the way up and down the road for this cake"
- `[$$$ (dollar sign)]` "Young rich success from the city of finesse (Yeah)"
- `[$$$ (dollar sign)]` "Wunna sayin' these words like a vow"

1 comma (3/5):
- `[$$$ (dollar sign)]` "I ain't gon' ask a nigga, I rather tryna get a loan from a bank"
- `[$$$ (dollar sign)]` "It's cloudy all in my face, it's all shades of gray"
- `[$$$ (dollar sign)]` "Dollar sign, dollar sign"

2 commas (3/5):
- `[$$$ (dollar sign)]` "I just wanna get paid, I don't wanna wait, nothin' less"
- `[$$$ (dollar sign)]` "They all told me that life's a game of chess, shit, I guess"
- `[$$$ (dollar sign)]` "Dollar sign, dollar sign, yeah"

3+ commas (3/5):
- `[$$$ (dollar sign)]` "One of one, I'm Wun, bitch, I'm rare"
- `[.223]` "No, no, no, you can not get these lens crafters"
- `[10 X Outta 10*]` "I'm grown, I'm goin', I'm stoned, canary, it look like the Sims"

**Rule 2 — Comma placement sits past the midpoint.** When present, commas land at median relative position 0.56 (p25 0.37, p75 0.77). The breath comes after the hook, not before. (`n` = all commas in solo subset.)

**Note on source** — Genius transcriber style introduces some comma noise. Treat +/- a few % as transcriber variance; the overall shape is stable.

---

## Sentence carry (enjambment)

**Rule 3 — Carries are far more common than Genius punctuation suggests.** With a grammar-based detector (ad-libs stripped, carry declared when the current line ends on a hanging word like `with`/`on`/`for`/`'cause` OR the next line starts with a conjunction / preposition / relative, OR the current line has no verb and the next does), **27.39% of adjacent pairs carry** (`n = 22,694`). Length-2 carries dominate (5,408), length-3 599, length-4+ 208. The old 5.68% number used Genius line capitalization, which can't be trusted on his vault — lines routinely end mid-clause with a comma. Precision check in `carry_grammar_sample.md` (200 random pairs for human spot-check).

**Rule 4 — Carries end on hanging prepositions / verb particles.** The grammar detector's hang-word list: `to, of, in, on, with, by, for, at, from, into, about, over, under, through, across, between, around, like, upon, within, 'cause, cause, where`. These signal "sentence not done." Example carry pairs auto-tagged:
- `[200 FOR LUNCH]` "Just picked up two hundred" → "bust on her spleen (Ooh)"
- `[200 FOR LUNCH]` "can't wait for me to screw her" → "cold as a slush (Cold as a slush)"

---

## Rhyme (ad-libs stripped before taking end word)

**Rule 5 — End rhymes are varied, not AABB.** 4-bar blocks with a single rime across all four lines:
- v2 end-word measurement: **3.11%**
- v3 anchor (last stressed syllable + suffix): **0.27%**

The anchor shows he almost never locks a stressed-syllable tail across four lines in a row.

**Rule 6 — Adjacent rhyme on the stressed-syllable anchor.** The anchor is the LAST primary-stressed vowel in the line (ad-libs stripped) plus every phone through end-of-line, including unstressed suffix words like `it / me / up / you / out / that`. So `flipped it` and `dipped it` both anchor on `IH1 P T IH0 T` → EXACT. `n = 29,832` adjacent pairs.

| category | count | rate | definition |
| --- | ---:| ---:| --- |
| exact | 826 | **2.77%** | anchor tuples equal |
| slant | 108 | 0.36% | same anchor vowel + same consonant-group tail |
| assonance | 4,344 | **14.56%** | same anchor vowel only |
| none | 24,554 | 82.32% | no match |

Total rhyme-touching (exact + slant + assonance) = **17.69%**. Compared to the end-word rime measurement (14.14% v2 total): the anchor makes `exact` stricter and `assonance` more generous. Ten random examples per category under both measurements in `slant_rhyme_examples.md`. ESTIMATE: CMU-based with letter-level fallback.

Matching adjacent pairs (3 real examples):
- `[$$$ (dollar sign)]` "I just wanna get paid, I don't wanna wait, nothin' less" → "They all told me that life's a game of chess, shit, I guess"
- `[$$$ (dollar sign)]` "Wunna sayin' these words like a vow" → "Made it out of the dirt, get my crown now"
- `[.223]` "Drop the top off it like I get sore" → "Come see the paint on my Christian Dior (Christian Dior)"

**Rule 7 — Multisyllable internal rhyme stays frequent.** Among lines whose end word has ≥2 syllables (`n = 7,787`), **49.35%** feature a multisyllable match earlier in the SAME line. Inner-rhyme hits per line: mean **1.02**, median 1. He almost always lands at least one internal echo.

**Rule 8 — Repeated end words are rare.** 0.47% of consecutive pairs repeat the same literal end word (`n = 25,195`). Hooks are the main cause.

**Rule 9 — Top end-word slots AFTER ad-lib strip.** The v1 top-10 was dominated by `yeah` (1,944) and other ad-libs. After stripping parentheticals + trailing yeah/uh/ayy/ooh/woah/nah/hey (etc.), the real top-10 is:

| rank | end word | count |
| ---:| --- | ---:|
| 1 | `it` | 907 |
| 2 | `me` | 592 |
| 3 | `up` | 283 |
| 4 | `you` | 187 |
| 5 | `out` | 168 |

(Full list in `adlib_strip_stats.json`.) Function words still dominate but the "ad-lib IS the end word" claim from v1 is wrong — those were transcription artifacts.

---

## Triplets (ESTIMATE)

Three detectors run on the text:
1. **triplet-flag** — ≥2 runs of three single-syllable words in a row AND line length ≥6 tokens.
2. **repeated-stack** — the same word three times in a row.
3. **density** — line has ≥16 syllables AND ≥3 commas.

**Rule 9 — Text alone does NOT identify triplet flow.** The triplet-flag rate on Gunna's solo subset is **1.46%** — basically the same as Migos (1.09%), Quavo (1.29%), Takeoff (1.23%), Offset (1.19%). The Migos triplet flow is a **rhythmic** feature over the beat (three notes per beat with repeated stress), which text can't see. The text-only detector should be read as "lines that COULD be delivered as a triplet," not as "triplet flow on tape." See `migos_triplet_reference.md`.

Triplet-candidate examples (text alone):
- `[$$$ (dollar sign)]` "I ain't gon' ask a nigga, I rather tryna get a loan from a bank"
- `[.223]` "Pull up, I Lam' it, no I won't crash it"
- `[200 FOR LUNCH (Original)]` "Runnin' it up (It up), got that shit out the ground in a month (A month)"

**Rule 10 — Repeated-word stacks happen in ~1% of lines.** 0.97% rate — the "ice ice ice", "yeah yeah yeah" moments. Low but non-zero.

**Rule 11 — Dense bars (16+ syllables with 3+ commas) are ~0%.** The 16+syl + 3+comma gate caught 0.00% of solo lines. Gunna doesn't write dense bars. His line budget sits short.

---

## POV & Mood (LEXICON-BASED)

**Rule 12 — First-person dominates.** **62.67%** of lines contain an I/me/my/we/us/our token. 7.09% second-person (you/your), 6.75% third-person (they/them/his/her), 23.49% carry none of these (ad-libs or neutral).

Example first-person lines:
- `[$$$ (dollar sign)]` "I ain't gon' ask a nigga, I rather tryna get a loan from a bank"
- `[$$$ (dollar sign)]` "I caterpillar all the way up and down the road for this cake"
- `[$$$ (dollar sign)]` "I just wanna get paid, I don't wanna wait, nothin' less"

**Rule 13 — Mood is understated.** First-match mood tags (one per line):
- flex / luxury 5.04%
- threat / violence 4.09%
- love 3.80%
- pain / loss 1.14%

Lexicons attached in `gunna_stats.json`. The mood weight is low because most Gunna lines imply mood through subject matter (brands, status) without using a mood-marker word. These rates are a floor, not a ceiling.

---

## Subtopics (LEXICON-BASED)

**Rule 14 — Women > loyalty > jewelry > cars > brands > come-up > drugs.**

| subtopic | rate on 30,553 solo lines |
| --- | ---:|
| women | 6.66% |
| loyalty / gang / fam | 2.67% |
| jewelry | 2.32% |
| cars | 1.85% |
| brands | 1.84% |
| come-up / struggle | 1.70% |
| drugs | 0.95% |

Full lexicons + 3-5 example lines per subtopic in `gunna_stats.json`.

---

## Tempo & energy — MEASURED

**Partial.** AcousticBrainz fetch (MusicBrainz 1 req/s → AcousticBrainz low+high level, no API key required) is running in the background at write time. GetSongBPM still waits for `GETSONGBPM_API_KEY` (user-held).

Cache lives at `docs/flow-rules/cache/musicbrainz/` + `/acousticbrainz/`. Final CSV at `docs/flow-rules/gunna_acousticbrainz.csv` once the run completes.

Once the CSV lands, step 8 (`scripts/12_tempo_correlation.py`) bins songs by BPM, by energy/danceability tertile, by key/mode; computes **Spearman correlations with bootstrap 95% CIs** against commas/line, carry rate (grammar-based), inner-rhyme rate, multisyllable rate. Only effects whose CI excludes 0 land as MEASURED. GetSongBPM pull (`scripts/04_fetch_metadata.py`) runs after `GETSONGBPM_API_KEY` is exported; its tempos are cross-checked against AB's, disagreements >3 BPM flagged, half-time candidates flagged (×2 within 3).

Expected gap: AB is frozen 2022, so Gunna's post-2022 catalogue (DS4EVER was Jan-2022, the WUNNA follow-ups are 2023+) will miss AB. GSB fills most of that gap when the key is in.

---

## Hook vs verse

Two detectors reported:
- strict (norm equal, ≥3 copies): 75 hook lines (0.25%) across 19 songs.
- fuzzy (SequenceMatcher ratio ≥ 0.8, ≥3 copies in cluster): **293** hook lines (**0.96%**) across **73** songs; cluster sizes 3 × 71, 4 × 16, 5 × 2, 6 × 1.

Fuzzy catches ~4× more hook lines than strict. Still a floor — Gunna hooks that repeat only twice (very common) or that vary beyond 0.8 similarity between repeats aren't picked up. Full data: `hook_fuzzy_stats.json`, `hook_vs_verse_stats.json`.

Verse-only recompute (hooks excluded) moves every rule under 0.3 pp either way, so hook contamination of the headline numbers is small.

## Formulas a writer could follow (from v2 numbers)

1. **Line length and breath**: default to 0 or 1 comma; use 2+ only in hook refrains or boast bars.
2. **End-rhyme policy**: don't lock an AABB couplet past 4 lines (he does it ~3% of the time). Rotate rime families every 2 bars.
3. **Multisyllable landing**: when the end word has 2+ syllables, plant a matching 2+ syllable word earlier in the SAME line (~50/50 chance).
4. **Slant is a legitimate option**: of all rhymed pairs, exact is 60%, slant 14%, assonance 26%. Slant + assonance together are ~40% of his rhyming vocabulary — he's not restricted to CMU-exact matches.
5. **Enjambment is common**: ~27% of adjacent pairs carry grammatically. End the carrying line on a hanging prep / particle (`with`, `on`, `for`, `'cause`), start the next on a conj / prep / relative, or dangle a verb-less phrase into a verbed one.
6. **POV**: lead with "I" / "my" more than half the time.
7. **Mood through subject, not marker**: fewer than 5% of lines contain a mood-keyword — the mood comes from brands, cars, women, loyalty talk.
8. **Don't write Migos-dense bars**: 16+syl with 3+ commas is 0% of his vault.
9. **Ad-libs are decoration, not end words**: they go in parens or trail off the line — they aren't the writer's chosen end word.

---

## What the data can't tell us

- **Flow / cadence over the beat.** The vault is text only; triplet rate 1.46% is text-based and doesn't distinguish rhythmic triplets from monosyllabic word runs. Measuring real triplet flow needs stem-level audio alignment.
- **Who said which line in a collab track.** The 955 collab lines are untagged, so Rules 1–14 use the pure `Gunna` subset only.
- **Order within a song.** No explicit line-order column; we use `rowid` ascending within (artist, song). Reliability depends on the ingestion script having inserted lines top-to-bottom. Spot checks look consistent; not guaranteed.
- **Tempo correlation.** Blocked on `GETSONGBPM_API_KEY` (see Tempo section).
- **Live mood weight.** The mood tagger is a word-list filter. A line like "cry wit' me" would hit "cry" but "my eyes dry" wouldn't hit the lexicon despite being the same subject. Rates are floors.

---

## Reproduce

```bash
# text-only (vault read-only, no API)
python3 docs/flow-rules/scripts/01_pull_gunna.py
python3 docs/flow-rules/scripts/02_analyze_text.py
python3 docs/flow-rules/scripts/03_migos_triplet_reference.py
python3 docs/flow-rules/scripts/05_pull_examples.py

# metadata (needs GETSONGBPM_API_KEY)
export GETSONGBPM_API_KEY=...
python3 docs/flow-rules/scripts/04_fetch_metadata.py
```

Outputs in `docs/flow-rules/`:
- `gunna_rulebook.md` (this file)
- `gunna_stats.json`
- `gunna_examples.jsonl`
- `gunna_rule_examples.json`
- `gunna_lines.jsonl`
- `gunna_songs.csv`
- `migos_triplet_reference.md`
- `inventory.md`, `gunna_pull_report.md`
- `gunna_track_meta.csv` (once the API key is in the env)
