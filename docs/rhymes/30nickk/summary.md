# 30nickk rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: 30nickk
- Songs: 1
- Bars kept (30nickk lyric lines): 36
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: 30nickk.
- Credit strings: 30nickk.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 166
- REPEAT pairs, recorded separately: 38
- END rhymes: 24
- INNER rhymes: 142

By match:

- PERFECT: 34 (END 5, INNER 29)
- SLANT: 48 (END 7, INNER 41)
- ASSONANCE: 83 (END 11, INNER 72)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 35
- MED: 130
- LOW: 1

## Core

- Core Y: 166
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 81 (48.8%)
- vowel: 83 (50.0%)
- spelling: 1 (0.6%)
- multi: 1 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 15 pairs (END 7, INNER 8). Words: dunkin, nuggets, muscles, nothing, love, youngest, duncan, guns.
2. `vow:IH` — 13 pairs (END 2, INNER 11). Words: think, little, figured, diggin, shit, give.
3. `vow:OW` — 12 pairs (END 0, INNER 12). Words: know, smoking, don't, o, go, broke, blowing, ceo.
4. `vow:AA` — 11 pairs (END 0, INNER 11). Words: rocking, got, wanna, hard, mavs, charged, shots, want.
5. `cmu:IY` — 10 pairs (END 1, INNER 9). Words: p, t, d, e.
6. `cmu:OW` — 10 pairs (END 0, INNER 10). Words: know, o, go.
7. `vow:AY` — 9 pairs (END 0, INNER 9). Words: high, try, might, nine, white, right, time, drive.
8. `slant:AA:nas-stop` — 7 pairs (END 0, INNER 7). Words: wanna, top, want, got.
9. `slant:AA:stop` — 7 pairs (END 0, INNER 7). Words: got, gotta, squad, charged, hard.
10. `slant:IH:sib-stop` — 6 pairs (END 4, INNER 2). Words: bitch, shit, sit, hit.
11. `vow:EH` — 6 pairs (END 0, INNER 6). Words: flexin, hell, denver, deadly, expensive, set.
12. `vow:AW` — 5 pairs (END 0, INNER 5). Words: now, about, down, thou.
13. `slant:AY:nas-stop` — 4 pairs (END 0, INNER 4). Words: time, might, white, nine.
14. `vow:EY` — 4 pairs (END 0, INNER 4). Words: baby, ain't, divalent, take.
15. `vow:IY` — 4 pairs (END 2, INNER 2). Words: methazine, p, e, t.
16. `cmu:AO-L` — 3 pairs (END 0, INNER 3). Words: tall, call, ball.
17. `cmu:AW` — 3 pairs (END 2, INNER 1). Words: thou, now, how.
18. `cmu:AY` — 3 pairs (END 2, INNER 1). Words: high, guy, try.
19. `vow:AE` — 3 pairs (END 0, INNER 3). Words: ballin, slam, ass.
20. `cmu:IH-T` — 2 pairs (END 0, INNER 2). Words: hit, shit.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with beat (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| 30nickk | This kinda mid lmao.mp3 | 36 | 24 | 142 | loose |
