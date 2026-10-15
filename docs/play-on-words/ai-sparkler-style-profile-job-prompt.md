# AI Sparkler — Artist/Song Style Profile Job (prompt)

Paste the PROMPT section into the job agent. "Extra aspects" and "Open questions" are for you.

---

## PROMPT

You are a lyric-analysis job. Input: every track in the project (`ground_truth_rap_bars_MODEL_G.csv`, ~1.7M bars; columns include artist, song, album, section_type, text_bar_line, rhyme_word, rhyme_class, flow_vector, primary_tone, secondary_tone, syllable_count, phonetic_* fields, stress_pattern, bar_index, year). Output: one **song profile** per track and one **artist profile** per artist, written as JSONL, plus a per-artist summary markdown. These profiles teach "AI Sparkler" (lyric generator that imitates a named artist) how that artist actually writes, so it does not collapse every artist into a generic average.

Work per track, then roll up per artist. Never average across songs before recording the spread (min / median / max / stdev), because the spread is what keeps style distinct.

### 1. Subject-matter chain (topic flow)
- Segment each song into **topic runs**: consecutive bars (or bar groups of 2/4) sharing one subject. Label each run from a fixed taxonomy (money/flexing, drugs, violence/street, women/romance, loyalty/friends, pain/trauma, come-up/hustle, fame/industry, faith/mortality, party/lifestyle, wordplay/braggadocio, other). Allow primary + secondary label per run.
- Record the **chain** as an ordered list, e.g. `[money, drugs, money, women]`, with run lengths in bars.
- Per song: number of topic switches, **switch rate** (switches per 16 bars), average run length, longest run, number of distinct topics, **topic-change % ** = switches / (bars − 1).
- Per artist: mean/median/spread of the above, plus a **topic transition matrix** (P(next topic | current topic)) and topic distribution. This answers "after money talk, what does this artist go to next, and how fast."
- Also record where switches happen: at verse start, mid-verse, at hook boundary, or on a punchline (switch landing on a wordplay/double-meaning bar).

### 2. Style-change tracking
- Per bar group, compute a style vector: syllables/bar, stress density, rhyme density, internal-rhyme density, flow_vector, tone, delivery type (melodic / spoken / triplet / double-time / ad-lib heavy).
- **Style-change rate** = how often the vector shifts beyond a threshold between adjacent bar groups. Report per song and per artist, plus which dimension changed (flow, tone, topic, rhyme scheme).
- Keep topic change and style change as separate numbers and also report their correlation (does this artist change flow when the topic changes?).

### 3. Rhyme grading (0–100 each, with the raw counts behind the score)
- **End-rhyme**: scheme (AABB, ABAB, monorhyme, chain), perfect vs slant vs assonance, multi-syllable depth (1/2/3/4+ syllable matches), rhyme-family reuse.
- **Internal rhyme**: rhymes *inside* a bar. Count per bar, % of bars containing one, max rhyme words in a single bar, mid-bar to end-bar linkage (internal word rhymes with the line's end word), cross-bar internal chains (internal word in bar N rhymes with internal word in bar N+1).
- **Multisyllabic rhyme**: longest syllable match, vowel-sequence matches ignoring consonants.
- **Rhyme novelty**: share of rhyme pairs not found in a common-rhyme list (could/would/should-type pairs score low).
- Store the actual rhyme pairs and chain examples so the generator can cite them.

### 4. Song-level musical metadata (per song, never defaulted from the artist)
- BPM, key, mode/scale, time signature, tempo feel (half-time vs double-time), and **confidence** for each. If audio is unavailable, take from a reliable source or mark `unknown` — never guess.
- **Cadence profile**: syllables/second, syllables/bar distribution, pause (breath) placement, bar-lag/ahead-of-beat tendency, % of bars that are packed vs sparse, stress pattern histogram.
- Tie BPM and key to rap behavior: syllables/bar vs BPM, rhyme density vs BPM, topic-switch rate vs BPM.

### 5. Wordplay and blocks usage
- Per song: wordplay bars (double meanings, double entendres, sound flips, punchline structure, metaphor/simile, name-drop, brand-drop), as counts and % of bars.
- Match words/phrases against the Blocks bank (nouns, verbs, phrases, definitions, double meanings, sound flips). Record which blocks each artist leans on, and **which block category pairs with which topic** (e.g. "weapons nouns" in violence runs, "luxury nouns" in money runs). This teaches when to reach for a noun/verb/phrase.

### 6. Song structure
- Section map (intro / verse / hook / bridge / outro), bars per section, hook repetition %, verse-to-hook topic relationship, how the song opens and closes, section-level rhyme and cadence differences (verses vs hooks).

### 7. Vocabulary and voice
- Lexical diversity (type/token ratio, unique-word rate per 100 bars), repetition rate, signature words/phrases/ad-libs, slang and dialect markers, profanity rate, point of view (1st/2nd/3rd person), tense, and sentiment/tone arc across the song.

### 8. Artist-level synthesis
- Era drift: compare profile by year/album; flag where the artist's style materially changed.
- Feature/collab influence: does style shift on features?
- Output a **style card**: 10–15 plain-language rules the generator can follow ("switches topic every ~6 bars, usually money → women; internal rhyme in ~40% of bars; 2-syllable end rhymes; lands punchlines on bar 4 of each group").
- Output **confidence**: n songs, n bars, and a flag when the sample is too small to trust.

### Rules
- Use measured values with a method note; label inferred values `inferred`, missing values `unknown`. Do not fabricate.
- Be deterministic where possible (rule/phonetic-based: rhyme, syllables, stress, cadence). Use the LLM only for subjective labels (topic, tone, wordplay) and record the model/version and prompt version on every row so runs are comparable and re-runnable.
- Resume-safe: skip tracks already profiled, write progress to a checkpoint file, one JSONL row per track.
- Output schema per row: `{artist, song, album, year, bpm, key, scale, cadence{}, topic_chain[], topic_stats{}, style_stats{}, end_rhyme{}, internal_rhyme{}, multisyllabic{}, wordplay{}, blocks_used[], structure{}, vocab{}, confidence{}, method{}}`.

---

## EXTRA ASPECTS YOU HAVEN'T COVERED

1. **Feedback loop data model.** The footer showing "blocks + lyrics borrowed" needs stable IDs on every bar and block, a log of (generation id → source bar ids / block ids), and a thumbs up/down or edit-distance signal. Positive reinforcement is easier as a reranker/retrieval weight (boost sources that got 👍) than as model training; start there.
2. **Originality / plagiarism guard.** Score generated lines against source bars (n-gram + phonetic overlap) so the sparkler imitates style without copying lines. Cap borrowed-bar similarity.
3. **Evaluation harness.** Hold out songs per artist; generate in that artist's style; measure whether the profile of the output matches the real artist profile (rhyme density, topic-switch rate, cadence). Add a blind "which is real?" test. Without this you cannot tell if the learning helped.
4. **Prosody-to-beat alignment.** Syllables per beat, stress on downbeats, and syncopation, so lines fit a chosen BPM, not just rhyme.
5. **Controllable knobs.** Expose profile numbers as sliders (topic-switch rate, internal-rhyme density, wordplay density, syllables/bar) so the user can dial "80% Artist A, 20% Artist B".
6. **Cross-artist blends and uniqueness.** Distance between artist profiles (find nearest artists, most distinctive traits) for blending and for a "what makes X sound like X" explainer.
7. **Data quality.** Dedup repeated hooks (repeat_count) so hooks do not dominate stats; flag mis-attributed or duplicate songs; verify section_type (many rows are `unknown`) before computing structure stats.
8. **Narrative coherence.** Within-song theme consistency and callbacks (a word or image reused later), so generated songs read as songs, not stacked bars.
9. **Rights/safety.** Decide up front how much source text can be stored or shown in the footer, and keep explicit-content controls.

## DECISIONS (settled)

1. **BPM/key source: fallback chain, not one site.** Spotify's own audio-features endpoint is closed to apps created after 2024-11-27 (403), so do not depend on it. For each song (matched by artist + title, with a similarity check on the returned title/artist), try in order and stop at the first confident hit:
   1. **ReccoBeats** (free, no key; Spotify-style tempo/key/mode/energy/danceability). Resolve the track first (Spotify ID or search), then fetch features by its ReccoBeats ID. Honor HTTP 429 `Retry-After`.
   2. **GetSongBPM** (free API key; BPM + key) for songs ReccoBeats misses.
   3. **Tunebat** only as a manual/low-volume last resort (no official free API; scraping may break its terms).
   4. If none match: `unknown`. Optional later: local Essentia analysis if you have audio files.
   Record per song `source`, `matched_title`, `match_confidence`, and when two sources disagree by >5 BPM, flag half/double-time ambiguity (store both candidates, not a guess). Cache every lookup so each song is fetched once; throttle requests. Run a 200-song coverage test first and compare sources before the full run.
2. **Topic taxonomy: wide, extensible, and wired to Blocks.** Start from a broad list (the section 1 labels). The model may propose a new topic when none fit, flagged `proposed`, then merged in a review pass. Every topic gets a **block map**: the nouns, verbs, phrases, double meanings and sound flips from the Blocks bank that occur in bars of that topic, with counts and per-artist usage. Blocks therefore attach to topics (topic → blocks) and to switch points (which blocks appear on a topic's first bar).
3. **Grading: percentile against the whole catalog**, stored beside the raw metric (see below).
4. **Hybrid compute.** Deterministic Python for rhyme, syllables, stress, cadence; LLM only for topic, tone, wordplay labels.

### Grading scale
- Every graded metric stores `raw` (the measured number, e.g. 38% of bars have an internal rhyme) and `pct` (rank among all songs in the catalog, 0–100; 90 = better than 90% of songs).
- Artist grade = median of their songs' `pct`, with the spread kept.
- Display letter from `pct`: A ≥ 90, B 75–89, C 50–74, D 25–49, F < 25. Graded metrics: end rhyme, internal rhyme, multisyllabic, rhyme novelty, wordplay density, topic variety, cadence variety, vocabulary diversity.
- "Grade" means distinctiveness/skill vs the catalog, not good/bad. Also store `z` (distance from catalog mean) so a style can be "high" or "low" without being "better".

### Footer feedback wiring
- Every generated bar logs `source_bar_ids[]` and `block_ids[]` (with their topic).
- Footer shows a few of those blocks as chips; 👍/👎 on a chip writes `{block_id, topic, artist, generation_id, vote}`.
- Votes adjust retrieval weight per (block, topic, artist), so a block can be good in one topic/artist and bad in another.
- **Bar-level votes too.** Each generated bar gets its own 👍/👎. Log `{generation_id, bar_index, bar_text, source_bar_ids[], block_ids[], topic, artist, vote}`. A bar vote is the overall judgment; block chip votes say which ingredient was responsible. A 👎 on a bar with all-👍 blocks means the combination failed (credit goes to the pairing/topic fit, not the blocks). Optional reason tags on 👎: off-topic, bad rhyme, off-flow, too copied, cringe.

### Genius figurative-language pass
- Source: `docs/play-on-words/genius-clicks/<artist>.jsonl` (annotations: `line`, `meaning`, `vault_lines`, `votes`, `state`, `strength`) and `*-candidates.jsonl` (`signal_type`, `chip_form`).
- Use only `state` accepted/verified (or `strength` accepted) for style stats. Treat `pending`/`weak` as low-weight; `hedged_note` rejects are excluded.
- Per artist, compute: figurative-device mix (double meaning, metaphor, simile, wordplay, sound flip, reference/name-drop, hyperbole), devices per 100 bars, which topics each device appears in, and the typical `line → meaning` structure (the setup, the second sense).
- Feed into the style card ("uses double meanings on ~6% of bars, mostly in money/flex runs, likes brand-name flips") and into the block map as device-tagged examples the generator can imitate.
