# Hotboii rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Hotboii
- Songs: 1
- Bars kept (Hotboii lyric lines): 33
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Hotboii.
- Credit strings: Hotboii.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 256
- REPEAT pairs, recorded separately: 27
- END rhymes: 37
- INNER rhymes: 219

By match:

- PERFECT: 14 (END 2, INNER 12)
- SLANT: 122 (END 10, INNER 112)
- ASSONANCE: 118 (END 25, INNER 93)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 16
- MED: 222
- LOW: 18

## Core

- Core Y: 253
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 121 (47.3%)
- vowel: 118 (46.1%)
- spelling: 15 (5.9%)
- multi: 2 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 31 pairs (END 18, INNER 13). Words: jeans, plea, see, leaving, here, even, leavin, z.
2. `vow:EY` — 15 pairs (END 0, INNER 15). Words: ain't, always, say, pray, made, way, take.
3. `vow:AH` — 14 pairs (END 1, INNER 13). Words: nothing, what, sudden, jumpin, fuck, thuggin, some, nutella.
4. `vow:OW` — 14 pairs (END 0, INNER 14). Words: don't, no, lovin, only, smoke, go, o, know.
5. `slant:AA:stop` — 13 pairs (END 0, INNER 13). Words: got, gotta, rock, shot, pop, block, top, not.
6. `vow:AY` — 12 pairs (END 0, INNER 12). Words: like, bye, guy, fire, bae, remind, eyes, 'ion.
7. `vow:EH` — 9 pairs (END 4, INNER 5). Words: extra, weekend, stretcher, never, bed, ever, when, better.
8. `vow:AA` — 7 pairs (END 1, INNER 6). Words: monster, gotta, not, park, got, block, sorry, want.
9. `slant:EH:fric-nas` — 6 pairs (END 0, INNER 6). Words: when, never, whenever, kevin, pen, ever.
10. `slant:EH:fric-stop` — 6 pairs (END 0, INNER 6). Words: ever, better, whenever, get, head, bed, never, let.
11. `vow:UW` — 6 pairs (END 1, INNER 5). Words: used, shootin, soon, bulletproof, bluetooth.
12. `slant:AA:sib-stop` — 5 pairs (END 0, INNER 5). Words: boss, top, pop, rock, shot.
13. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: some, what, suge, fuck, sun.
14. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: nigga, hit, shit, trick, rip, whip, kid.
15. `slant:IY:nas-sib` — 5 pairs (END 0, INNER 5). Words: tryna, these, luigi, jeans, scene.
16. `slant:AA:fric-stop` — 4 pairs (END 0, INNER 4). Words: mafia, top, pop, rock, shot.
17. `slant:AA:nas-stop` — 4 pairs (END 0, INNER 4). Words: wanna, want, gotta, top.
18. `slant:IY:fric-nas` — 4 pairs (END 2, INNER 2). Words: stevie, tryna, even, believe, leavin, leaving, weave.
19. `slant:IY:fric-sib` — 4 pairs (END 3, INNER 1). Words: stevie, luigi, ege, easy, believe, breathe, weave.
20. `slant:IY:sib-stop` — 4 pairs (END 1, INNER 3). Words: sleep, easy, luigi, ege, tweet, 'eat.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 7 pair sides, mostly spelling via spelling phonetic key, often with these (2)
- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with hit (1)
- suge — 3 pair sides, mostly spelling via spelling phonetic key, often with what (1)
- thuggin — 2 pair sides, mostly vowel via spelling phonetic key, often with jumpin (1)
- nutella — 1 pair sides, mostly vowel via spelling phonetic key, often with what (1)
- tweeting — 1 pair sides, mostly spelling via spelling phonetic key, often with tweet (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Hotboii | Record First | 33 | 37 | 219 | loose |
