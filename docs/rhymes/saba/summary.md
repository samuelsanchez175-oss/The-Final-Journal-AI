# Saba rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Saba
- Songs: 1
- Bars kept (Saba lyric lines): 74
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Saba.
- Credit strings: Saba.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 483
- REPEAT pairs, recorded separately: 20
- END rhymes: 66
- INNER rhymes: 417

By match:

- PERFECT: 38 (END 7, INNER 31)
- SLANT: 208 (END 31, INNER 177)
- ASSONANCE: 235 (END 28, INNER 207)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 37
- MED: 419
- LOW: 27

## Core

- Core Y: 481
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 217 (44.9%)
- vowel: 235 (48.7%)
- spelling: 29 (6.0%)
- multi: 2 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 43 pairs (END 3, INNER 40). Words: careless, confessions, send, sex, when, desert, letters, get.
2. `vow:AA` — 32 pairs (END 3, INNER 29). Words: block, partners, rocks, acknowledge, armed, boxes, god, want.
3. `vow:EY` — 32 pairs (END 3, INNER 29). Words: say, make, ain't, sacred, day, vacation, h, raised.
4. `vow:AY` — 30 pairs (END 7, INNER 23). Words: like, behind, life, mind, island, alliance, die, time.
5. `vow:IH` — 24 pairs (END 4, INNER 20). Words: careers, thinkin, listen, didn't, sister, tuition, still, really.
6. `vow:IY` — 20 pairs (END 4, INNER 16). Words: even, heathen, meetings, probably, people, need, feed, these.
7. `vow:AE` — 18 pairs (END 1, INNER 17). Words: saks, album's, bands, savage, grabbin, strapped, can't, had.
8. `vow:OW` — 18 pairs (END 3, INNER 15). Words: no, old, globetrotter, don't, go, supposed, cold, 'go.
9. `slant:IH:sib-stop` — 16 pairs (END 5, INNER 11). Words: rich, shit, gliz, trip, bitch, hip, grip, lips.
10. `slant:IH:liq-stop` — 12 pairs (END 0, INNER 12). Words: really, shit, zero, still, fear, lit, quick, kill.
11. `slant:IH:sib` — 12 pairs (END 12, INNER 0). Words: kids, ears, biz, years, mills, pills, careers, gliz.
12. `slant:EH:stop` — 11 pairs (END 1, INNER 10). Words: check, better, desert, regret, wet, said, rhetoric, mcgregor.
13. `slant:IH:liq-sib` — 11 pairs (END 0, INNER 11). Words: rich, fear, zero, still, bitch, gliz, biz, years.
14. `slant:AA:stop` — 10 pairs (END 0, INNER 10). Words: got, block, plotted, top, squatter, harder, watched, gotta.
15. `cmu:EH-T` — 8 pairs (END 0, INNER 8). Words: get, wet, sweat, jet, regret.
16. `slant:AY:nas` — 8 pairs (END 0, INNER 8). Words: identifyin, swine, wintertime, time, summertime, cryin, line.
17. `slant:AE:nas-stop` — 7 pairs (END 0, INNER 7). Words: man, can, had, can't, band, land, van, gang.
18. `slant:AH:nas-sib` — 6 pairs (END 0, INNER 6). Words: some, mother, come, another, much, once, one.
19. `slant:EH:liq-stop` — 6 pairs (END 0, INNER 6). Words: tell, wet, said, deadly, check, get, fare.
20. `slant:EH:nas-stop` — 6 pairs (END 0, INNER 6). Words: when, again, said, ten, better, regret, mcgregor, twenty.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gliz — 9 pair sides, mostly spelling via spelling phonetic key, often with biz (1)
- dyin — 4 pair sides, mostly spelling via spelling phonetic key, often with even (1)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with everything (2)
- conor — 2 pair sides, mostly spelling via spelling phonetic key, often with mcgregor (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- guap — 2 pair sides, mostly spelling via spelling phonetic key, often with some (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with these (1)
- lyin — 1 pair sides, mostly spelling via spelling phonetic key, often with need (1)
- sorta — 1 pair sides, mostly spelling via spelling phonetic key, often with corporate (1)
- fam — 1 pair sides, mostly spelling via spelling phonetic key, often with can (1)
- niemans — 1 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)
- baguettes — 1 pair sides, mostly vowel via spelling phonetic key, often with strapped (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Saba | Survivor’s Guilt | 74 | 66 | 417 | loose |
