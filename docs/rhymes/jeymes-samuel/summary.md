# Jeymes Samuel rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Jeymes Samuel
- Songs: 1
- Bars kept (Jeymes Samuel lyric lines): 73
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Jeymes Samuel.
- Credit strings: Jeymes Samuel.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 599
- REPEAT pairs, recorded separately: 30
- END rhymes: 77
- INNER rhymes: 522

By match:

- PERFECT: 38 (END 5, INNER 33)
- SLANT: 227 (END 17, INNER 210)
- ASSONANCE: 334 (END 55, INNER 279)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 34
- MED: 534
- LOW: 31

## Core

- Core Y: 595
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 234 (39.1%)
- vowel: 334 (55.8%)
- spelling: 31 (5.2%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 117 pairs (END 33, INNER 84). Words: legend, armageddon, jealous, feathers, pencils, offended, regret, weapon.
2. `vow:OW` — 45 pairs (END 4, INNER 41). Words: know, no, only, road, won't, soul, go, rolling.
3. `vow:IY` — 29 pairs (END 0, INNER 29). Words: see, even, leavin, z, believed, need, we'll, please.
4. `vow:EY` — 28 pairs (END 0, INNER 28). Words: ain't, lay, navigatin, made, say, name, sale, pain.
5. `vow:AE` — 27 pairs (END 7, INNER 20). Words: fashion, actions, rappin, family, mansion, back, actin, can.
6. `slant:EH:stop` — 21 pairs (END 3, INNER 18). Words: center, web, better, let, get, fed, protect, reflect.
7. `vow:AA` — 21 pairs (END 1, INNER 20). Words: got, watchin, economy, prophets, project, god's, box, caught.
8. `vow:AY` — 20 pairs (END 1, INNER 19). Words: like, why, findin, writing, time, behind, fire, light.
9. `cmu:OW` — 15 pairs (END 3, INNER 12). Words: go, no, know, overflow, glow, though, co, blow.
10. `vow:AH` — 15 pairs (END 0, INNER 15). Words: colors, trouble, runnin, front, wonderin, papa, what, some.
11. `vow:ER` — 13 pairs (END 7, INNER 6). Words: kirkland, thirstin, hurtin, nerd, word, turn, work.
12. `slant:EH:liq-stop` — 11 pairs (END 0, INNER 11). Words: said, everywhere, where, nightmare, prayer, get, mandela, ghetto.
13. `vow:IH` — 10 pairs (END 1, INNER 9). Words: shittin, mill, sink, pink, still, him, prison, kicked.
14. `slant:EH:nas-stop` — 9 pairs (END 3, INNER 6). Words: many, pret, pen, when, men, depend, neck, said.
15. `slant:ER:nas-stop` — 8 pairs (END 2, INNER 6). Words: turn, firm, word, work, dirt, burn, murder, nerd.
16. `slant:AE:nas-stop` — 7 pairs (END 0, INNER 7). Words: can, daddy, can't, dang, ad, back, fan, crack.
17. `slant:EH:sib-stop` — 7 pairs (END 0, INNER 7). Words: said, fresh, guess, get, process, bed, letters, better.
18. `slant:IH:stop` — 7 pairs (END 3, INNER 4). Words: big, kid, relationship, shit, nigga, kicked.
19. `slant:AE:nas-sib` — 6 pairs (END 0, INNER 6). Words: ass, goddamn, fam, instagram, scram, can, badass.
20. `slant:OW:liq-nas` — 6 pairs (END 0, INNER 6). Words: only, gon, stole, stone, soul, owner, own.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- fam — 5 pair sides, mostly spelling via spelling phonetic key, often with can (1)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with only (2)
- doja — 5 pair sides, mostly spelling via spelling phonetic key, often with over (1)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with leave (1)
- shawty — 3 pair sides, mostly vowel via spelling phonetic key, often with see (2)
- yaga — 2 pair sides, mostly spelling via spelling phonetic key, often with these (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with kill (2)
- trag — 1 pair sides, mostly spelling via spelling phonetic key, often with had (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with kicked (1)
- thuggin — 1 pair sides, mostly vowel via spelling phonetic key, often with runnin (1)
- pancetta — 1 pair sides, mostly vowel via spelling phonetic key, often with back (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Jeymes Samuel | JEEZU | 73 | 77 | 522 | loose |
