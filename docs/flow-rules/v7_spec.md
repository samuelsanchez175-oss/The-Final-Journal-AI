# v7 generation target spec — derived from v5 clean numbers

**Source of truth:** `gunna_rulebook.md` v5. Every rule below cites its stat
and `n` from `gunna_stats.json` / `true_order_stats.json` /
`adlib_strip_stats.json` / `slant_rhyme_recompute.json` /
`rhyme_hand_vs_detector.json`.

Clean subset: 593 order-preserved Gunna songs, 25,361 lines, 24,768
adjacent pairs. All order-dependent rules below are from that subset only.

## Hard rules the generator must satisfy

1. **End-rhyme tiers.** When writing a Gunna verse:
   - **Pass gate: anchor vowel match** between adjacent lines. `n = 24,768`
     adjacent pairs; vowel match (exact + slant + assonance) = **46.72%**
     of pairs. Over 4-bar windows, 90.94% have at least 2 bars sharing
     the anchor vowel (`n = 6,126` blocks). So the generator should write
     at least 2 of every 4 bars to share the stressed vowel.
   - **Prefer exact** on bars 2 and 4 of a 4-bar unit (classic couplet
     feel). Exact anchor rate across all adjacent pairs: **12.88%**.
     The hand-checked exact tier scores precision 0.955 — exact matches
     are the ones listeners register as "a rhyme." (See
     `rhyme_hand_vs_detector.md` tier table.)
   - **Avoid strict AABB locking across 4 bars**: only **1.39%** of
     4-bar blocks share a single anchor across all four lines. Rotate
     the end word every 1-2 bars.

2. **Multisyllable internal rhyme.** When a bar's end word is 2+ syllables,
   plant a 2+-syllable word earlier in the SAME bar that shares the
   stressed-vowel rime, **~30% of the time** (`29.73%` on `n = 7,787`
   bars with a 2+-syl end word — `gunna_stats.json`). This is a stylistic
   target, not a floor.

3. **Inner rhyme per line.** Mean ≈ 1.0 pair of words sharing an end-rime
   per bar (`inner_rhyme_mean = 1.016`). The generator should land at
   least one internal echo per bar as its default.

4. **Comma mix.** Across 30,553 solo lines:
   - 0 commas 44.25%
   - 1 comma 40.65%
   - 2 commas 11.19%
   - 3+ commas 3.90%
   - mean 0.76 commas / bar
   Mean comma position (when present) median at relative 0.56 (p25 0.37,
   p75 0.77). Target 0 or 1 comma per bar; reserve 2 for boast bars or
   hook refrains; never land 3+ commas on more than 1 bar in 25.

5. **Syllables per bar.** Gunna's lines sit short. Density gate
   (≥16 syl AND ≥3 commas) fires on **1.52%** of lines
   (`gunna_stats.json`). The generator should default to ~10-14 syllables
   per bar and never produce >=16 syl with 3+ commas on more than ~2% of
   output. (Specific median/stdev needs a separate per-bar count report;
   current rulebook only emits aggregate density.)

6. **Carry rate (enjambment) — NOT USABLE from text-only grammar heuristics.**
   v1 (capitalization) reported 27.39%, v2 (spaCy POS) reported 10.44%,
   both over-estimate. On a 30-pair hand-check of v2 output
   (`carry_v2_handcheck.md`), **precision was only 5.6%** — the detector
   mislabels noun-phrase imagery bars ("Audemars Piguet" / "Rondo
   number nine") as dangling clauses, and misses `-in'` slang verbs
   (`Pullin'`, `Heatin'`). Real carry rate on the clean subset is
   almost certainly **under 1-2%**, but we can't pin it down without
   either a dependency parser that distinguishes phrasal particles from
   hanging prepositions, or a per-song hand-mark on 5-10 verses.
   Treat carry rate as **"low single-digit percent"** for generation
   targets; don't try to enforce it as a hard rule until the
   measurement is sound.

7. **Ad-libs don't own the end word.** The vault's apparent "yeah 1,944
   end-word" was a transcription artifact. After ad-lib strip, the real
   top-5 end words are `it, me, up, you, out` (`adlib_strip_stats.json`).
   The generator must NOT land a content bar's end word on an ad-lib
   (`yeah, uh, ayy, ooh, woah, nah, hey`). Ad-libs may trail the bar in
   parentheses but never substitute for the end word.

8. **First-person voice.** 62.67% of lines contain an I/me/my/we/us/our
   token (`gunna_stats.json`). Default the generator to first-person;
   second- and third-person land in ~7% each.

9. **Subject-driven mood, not mood-words.** The mood lexicon catches
   fewer than 5% of lines per category (flex 5.04%, threat 4.09%, love
   3.80%, pain 1.14%). Imply mood through brands / cars / women /
   loyalty / come-up subjects; keep explicit mood-markers under 5%.

10. **Subtopic mix (per 100 bars, from `gunna_stats.json`):**
    - women 6.66%
    - loyalty / fam 2.67%
    - jewelry 2.32%
    - cars 1.85%
    - brands 1.84%
    - come-up 1.70%
    - drugs 0.95%
    These sum to ~18% of lines — most lines are subject-free or carry a
    mood through chip nouns the lexicon doesn't cover. The generator
    should hit at least one women-subject line and one luxury-subject
    line per 16-bar verse.

11. **No vault copying.** The novelty guard in
    `tools/lyric-llm/taste/novelty.py` is the active enforcement; the
    rule here is a reminder: no bar is allowed to share more than 5
    consecutive content words with any BarHitsCatalog line, exclusive of
    chip words. (See `baseline_duplicate_rate.md`: `pathA_matched`
    hit 83% near-dup before novelty landed; that is the regression to
    avoid.)

## Can't measure from text alone — needs audio / hand-marked data

- **Triplet flow.** `scripts/02_analyze_text.py` + `03_migos_triplet_reference.py`
  text-only detector finds Gunna at 53%, Migos at 48%, Quavo 51%,
  Takeoff 47%, Offset 52% — statistically indistinguishable. Real
  triplet flow is three notes per beat with rising stress, not three
  monosyllabic words in a row. Needs beat-aligned audio or hand marks
  on a stem-level dataset.

- ~~**BPM / energy / key correlation.**~~ **Resolved null.** AcousticBrainz
  coverage 136/739, median 130 BPM. Spearman syl/bar vs BPM:
  ρ = −0.002, CI95% [−0.200, +0.195]. Comma/bar vs BPM: ρ = +0.022,
  CI95% [−0.192, +0.215]. Both CIs cross 0 — no clear BPM effect on
  per-bar syllable or comma counts in the AB-matched Gunna subset.
  **BPM dropped from V7 blocked_targets** (no generation target depends
  on it). GetSongBPM pull still available if the key is ever supplied,
  but it would re-measure the same null.

- **Who delivered which bar in collab tracks.** 955 lines from 6 collab
  variants are untagged; all per-line stats above use the pure solo
  subset.

- **Semantic hook detection.** The fuzzy detector catches hooks that
  repeat ≥3 times at ≥0.8 similarity; it misses hooks that only repeat
  twice or vary by >20%. Full hook capture needs line-level section
  tags from Genius.

## Open — resolved by in-flight work

- Carry v2 precision + corrected carry rate (needs spaCy run on 593
  order-preserved songs + 30-pair hand-check). In flight.
- AcousticBrainz BPM distribution + syl-per-bar vs BPM correlation. In
  flight.
- Fix `tools/lyric-llm/taste/chips_export.py:90` CMU bug + regenerate
  `eval/chips.jsonl` syllables. Reported, not touched this session.

## Rule gating

Rules 1-5 and 7-10 are directly measurable at generation time:
`frontier_v5._hard_check_bars` already enforces 1, 11 (via novelty), and
can be extended to check 2 (multisyl), 3 (inner), 4 (commas), 5 (syl).
Rules 7-10 are prompt-side: planner / editor should see them as
grounded style constraints next to the chip bank and wordplay examples.
