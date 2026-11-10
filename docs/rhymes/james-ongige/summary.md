# James Ongige rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: James Ongige
- Songs: 1
- Bars kept (James Ongige lyric lines): 28
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: James Ongige.
- Credit strings: James Ongige.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 225
- REPEAT pairs, recorded separately: 19
- END rhymes: 14
- INNER rhymes: 211

By match:

- PERFECT: 11 (END 2, INNER 9)
- SLANT: 88 (END 3, INNER 85)
- ASSONANCE: 115 (END 8, INNER 107)
- MULTI: 11 (END 1, INNER 10)

By confidence:

- HIGH: 6
- MED: 146
- LOW: 73

## Core

- Core Y: 191
- Core N among rhyme pairs: 34

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 53 (23.6%)
- vowel: 115 (51.1%)
- spelling: 46 (20.4%)
- multi: 11 (4.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 27 pairs (END 4, INNER 23). Words: make, hatin, haters, james, fakin, th, paper, daily.
2. `vow:AE` — 26 pairs (END 1, INNER 25). Words: tragic, kwani, mahari, bad, mavijana, alleys, ajali, lazima.
3. `vow:AA` — 15 pairs (END 1, INNER 14). Words: quafff, darlings, wa, block's, project, na, model, armed.
4. `vow:IY` — 14 pairs (END 1, INNER 13). Words: ni, kumarry, bila, si, d, real, beat, leave.
5. `vow:EH` — 9 pairs (END 0, INNER 9). Words: next, f, myself, end, bear, threat, ever, respek.
6. `slant:IH:stop` — 8 pairs (END 0, INNER 8). Words: niomoke, mzike, inabake, inataka, big, kitu, ninasaka, think.
7. `vow:OW` — 8 pairs (END 1, INNER 7). Words: no, tokens, ndio, open, role, ndogo.
8. `cmu:IH-NG` — 7 pairs (END 2, INNER 5). Words: warning, megatroning, throning, hatin, king.
9. `vow:AO` — 7 pairs (END 0, INNER 7). Words: warning, doors, scores, hawaoni, all, call.
10. `vow:IH` — 7 pairs (END 0, INNER 7). Words: think, big, official, mimba, inabake, mzike, mjini, ilikuwa.
11. `slant:EY:nas-stop` — 6 pairs (END 0, INNER 6). Words: make, fakin, game, naingia, heda, fame.
12. `slant:IH:fric-stop` — 6 pairs (END 0, INNER 6). Words: mih, mzike, big, kitu.
13. `slant:EH:fric-stop` — 5 pairs (END 0, INNER 5). Words: f, threat, ready, ever.
14. `slant:EY:stop` — 5 pairs (END 1, INNER 4). Words: make, paper, heda, safety, ain't.
15. `multi:OW-K-EH` — 4 pairs (END 0, INNER 4). Words: wabonge wachoke, wachoke, lazima niomoke, niomoke, mavijana waomoke, waomoke.
16. `slant:EY:liq-stop` — 4 pairs (END 0, INNER 4). Words: daily, make, paper, heda.
17. `slant:EY:sib-stop` — 4 pairs (END 0, INNER 4). Words: th, make, paper.
18. `slant:IH:nas-stop` — 4 pairs (END 0, INNER 4). Words: mjini, king, wid, mzike, big, kitu.
19. `slant:AE:sib` — 3 pairs (END 0, INNER 3). Words: fans, manners, alleys.
20. `slant:EH:fric-liq` — 3 pairs (END 0, INNER 3). Words: bear, f, ever.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- mih — 8 pair sides, mostly spelling via spelling phonetic key, often with mzike (2)
- kwani — 7 pair sides, mostly vowel via spelling phonetic key, often with tragic (1)
- niomoke — 7 pair sides, mostly multi via spelling phonetic key, often with wachoke (2)
- mzike — 7 pair sides, mostly spelling via spelling phonetic key, often with mih (2)
- mjini — 6 pair sides, mostly spelling via spelling phonetic key, often with mih (2)
- mahari — 6 pair sides, mostly vowel via spelling phonetic key, often with mistari (2)
- throning — 5 pair sides, mostly spelling via spelling phonetic key, often with warning (2)
- megatroning — 5 pair sides, mostly spelling via spelling phonetic key, often with warning (2)
- wachoke — 5 pair sides, mostly multi via spelling phonetic key, often with niomoke (2)
- waomoke — 5 pair sides, mostly multi via spelling phonetic key, often with niomoke (2)
- kitu — 5 pair sides, mostly spelling via spelling phonetic key, often with mih (2)
- kumarry — 5 pair sides, mostly vowel via spelling phonetic key, often with ni (2)
- ajali — 4 pair sides, mostly vowel via spelling phonetic key, often with mahari (1)
- hawaoni — 3 pair sides, mostly vowel via spelling phonetic key, often with warning (2)
- wabonge — 3 pair sides, mostly vowel via spelling phonetic key, often with rappin (1)
- ndio — 3 pair sides, mostly vowel via spelling phonetic key, often with ndogo (2)
- inabake — 3 pair sides, mostly spelling via spelling phonetic key, often with niomoke (1)
- mavijana — 3 pair sides, mostly vowel via spelling phonetic key, often with lazima (1)
- ndogo — 3 pair sides, mostly vowel via spelling phonetic key, often with ndio (2)
- naingia — 2 pair sides, mostly spelling via spelling phonetic key, often with game (1)
- dem — 2 pair sides, mostly spelling via spelling phonetic key, often with ever (1)
- lazima — 2 pair sides, mostly vowel via spelling phonetic key, often with wataisha (1)
- wataisha — 2 pair sides, mostly vowel via spelling phonetic key, often with lazima (1)
- inataka — 2 pair sides, mostly spelling via spelling phonetic key, often with niomoke (1)
- ndakas — 2 pair sides, mostly vowel via spelling phonetic key, often with mavijana (1)
- halali — 2 pair sides, mostly vowel via spelling phonetic key, often with mahari (1)
- yako — 2 pair sides, mostly spelling via spelling phonetic key, often with bila (1)
- mistari — 2 pair sides, mostly multi via spelling phonetic key, often with mahari (2)
- mimba — 2 pair sides, mostly vowel via spelling phonetic key, often with nilikam (1)
- nilikam — 2 pair sides, mostly vowel via spelling phonetic key, often with mimba (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| James Ongige | Armed and Dangerous | 28 | 14 | 211 | loose |
