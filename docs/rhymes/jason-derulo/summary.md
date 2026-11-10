# Jason Derulo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Jason Derulo
- Songs: 3
- Bars kept (Jason Derulo lyric lines): 80
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Jason Derulo.
- Credit strings: Jason Derulo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 457
- REPEAT pairs, recorded separately: 68
- END rhymes: 103
- INNER rhymes: 354

By match:

- PERFECT: 32 (END 4, INNER 28)
- SLANT: 242 (END 68, INNER 174)
- ASSONANCE: 181 (END 31, INNER 150)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 33
- MED: 399
- LOW: 25

## Core

- Core Y: 449
- Core N among rhyme pairs: 8

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 256 (56.0%)
- vowel: 181 (39.6%)
- spelling: 18 (3.9%)
- multi: 2 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:AY:stop` — 65 pairs (END 21, INNER 44). Words: like, night, slide, vibe, ride, tonight, sight, might.
2. `vow:AY` — 58 pairs (END 11, INNER 47). Words: bae, like, diamond, night, try, behind, times, dive.
3. `vow:EY` — 44 pairs (END 8, INNER 36). Words: baby, waitin, take, play, player, taste, way, waste.
4. `slant:AY:fric-stop` — 29 pairs (END 16, INNER 13). Words: dive, life, night, like, slide, invite, tonight, sight.
5. `vow:AA` — 23 pairs (END 12, INNER 11). Words: socks, tart, shots, wop, drop, watch, hop, pop.
6. `slant:AY:sib-stop` — 21 pairs (END 2, INNER 19). Words: twice, like, dice, thighs, night, christ, tonight, bright.
7. `vow:OW` — 20 pairs (END 0, INNER 20). Words: don't, know, blow, huncho, lambo, derulo, rolls, hoes.
8. `vow:EH` — 14 pairs (END 0, INNER 14). Words: when, friends, jealous, spend, tell, independent, felt, get.
9. `slant:AY:nas-stop` — 11 pairs (END 5, INNER 6). Words: flyin, night, like, tryin, mine, tired, bright, slide.
10. `slant:EY:stop` — 9 pairs (END 0, INNER 9). Words: wait, make, take, taste, maybe, ain't, waste.
11. `slant:IH:liq-stop` — 9 pairs (END 0, INNER 9). Words: really, will, slip, dip, pick, shit, until, bill.
12. `slant:AA:sib-stop` — 8 pairs (END 5, INNER 3). Words: watch, wop, yacht, shots, drop, hop, pop, forgot.
13. `cmu:AA-P` — 7 pairs (END 0, INNER 7). Words: drop, wop, hop, pop, top.
14. `slant:AY:liq-stop` — 7 pairs (END 3, INNER 4). Words: smile, like, i'll, night, vibe, slide, ride, might.
15. `slant:IH:nas-stop` — 7 pairs (END 0, INNER 7). Words: i'ma, slip, dip, grip, bring.
16. `vow:IH` — 7 pairs (END 0, INNER 7). Words: things, singin, didn't, hit, think, big, shit, bill.
17. `cmu:AY-T` — 6 pairs (END 1, INNER 5). Words: night, tonight, invite, bright, sight.
18. `slant:AA:stop` — 6 pairs (END 1, INNER 5). Words: got, gotta, want, stop, tart, yacht.
19. `cmu:IY` — 5 pairs (END 0, INNER 5). Words: e, probably, three, see.
20. `slant:AE:nas-stop` — 5 pairs (END 0, INNER 5). Words: can, can't, had, back.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 9 pair sides, mostly spelling via spelling phonetic key, often with slip (3)
- derulo — 7 pair sides, mostly spelling via spelling phonetic key, often with tell (2)
- huncho — 4 pair sides, mostly vowel via spelling phonetic key, often with blow (1)
- lambo — 4 pair sides, mostly vowel via spelling phonetic key, often with blow (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Jason Derulo | Last Night | 39 | 40 | 151 | loose |
| Jason Derulo | Slidin’ | 37 | 61 | 202 | loose |
| Jason Derulo | Slidin’ (BADDIES ONLY Remix) | 4 | 2 | 1 | loose |
