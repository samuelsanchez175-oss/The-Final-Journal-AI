# DJ Ess rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DJ Ess
- Songs: 1
- Bars kept (DJ Ess lyric lines): 37
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DJ Ess.
- Credit strings: DJ Ess.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 368
- REPEAT pairs, recorded separately: 40
- END rhymes: 62
- INNER rhymes: 306

By match:

- PERFECT: 63 (END 13, INNER 50)
- SLANT: 195 (END 29, INNER 166)
- ASSONANCE: 109 (END 19, INNER 90)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 55
- MED: 278
- LOW: 35

## Core

- Core Y: 360
- Core N among rhyme pairs: 8

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 220 (59.8%)
- vowel: 109 (29.6%)
- spelling: 38 (10.3%)
- multi: 1 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:IH:sib-stop` — 29 pairs (END 0, INNER 29). Words: bitch, shit, big, hits, wit, hit, dick, split.
2. `slant:IH:stop` — 28 pairs (END 0, INNER 28). Words: big, shit, wit, dick, hit, split.
3. `vow:AE` — 21 pairs (END 11, INNER 10). Words: past, facts, gats, back, dallas, tragedy, sack, pack.
4. `cmu:IH-T` — 17 pairs (END 0, INNER 17). Words: shit, wit, hit, split.
5. `slant:AE:sib-stop` — 16 pairs (END 1, INNER 15). Words: pass, slacks, stack, exact, ass, thrax, dad, had.
6. `vow:AH` — 16 pairs (END 0, INNER 16). Words: lunch, some, fuckin, come, drum, runnin, cut, blunts.
7. `vow:OW` — 16 pairs (END 0, INNER 16). Words: no, won't, smokin, dope, don't, known, know, getcho.
8. `vow:AA` — 14 pairs (END 0, INNER 14). Words: not, pockets, hard, want, wanna, cost, og, nothin.
9. `slant:AE:stop` — 13 pairs (END 8, INNER 5). Words: bag, had, tack, exact, dad, back, pack, slack.
10. `vow:AY` — 12 pairs (END 7, INNER 5). Words: pint, mind, like, lime, guys, time, hidin, fine.
11. `slant:AY:nas` — 10 pairs (END 10, INNER 0). Words: time, tryin, fine, sunshine, line, mine, lime, hidin.
12. `vow:EH` — 10 pairs (END 0, INNER 10). Words: get, second, lemon, utensils, when, getcho, benz, let.
13. `vow:EY` — 10 pairs (END 1, INNER 9). Words: saved, th, say, ain't, grade, take, crazy, payday.
14. `cmu:AH-M` — 9 pairs (END 0, INNER 9). Words: some, thumb, come, drum.
15. `slant:IH:nas-stop` — 8 pairs (END 0, INNER 8). Words: i'ma, shit, texting, split, wit, big, hit.
16. `cmu:AE-K` — 7 pairs (END 7, INNER 0). Words: sack, pack, slack, stack, tack, back.
17. `cmu:AY-N` — 7 pairs (END 4, INNER 3). Words: line, sunshine, mine.
18. `cmu:IH-N` — 7 pairs (END 0, INNER 7). Words: even, lyin, fuckin, mobbin.
19. `slant:AE:sib` — 7 pairs (END 0, INNER 7). Words: facts, slacks, ass, gats, thrax, dallas.
20. `slant:AY:nas-sib` — 7 pairs (END 6, INNER 1). Words: supplies, guys, time, lime, sunshine, mine, ties, fine.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 8 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- getcho — 8 pair sides, mostly vowel via spelling phonetic key, often with get (2)
- lyin — 6 pair sides, mostly spelling via spelling phonetic key, often with even (4)
- gats — 6 pair sides, mostly vowel via spelling phonetic key, often with sack (1)
- thrax — 5 pair sides, mostly spelling via spelling phonetic key, often with slacks (1)
- nem — 5 pair sides, mostly spelling via spelling phonetic key, often with get (2)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with dont (3)
- mobbin — 2 pair sides, mostly spelling via spelling phonetic key, often with fuckin (1)
- codeine — 1 pair sides, mostly spelling via spelling phonetic key, often with gon (1)
- shorties — 1 pair sides, mostly spelling via spelling phonetic key, often with supplies (1)
- dollas — 1 pair sides, mostly spelling via spelling phonetic key, often with dallas (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DJ Ess | Text Mixx | 37 | 62 | 306 | loose |
