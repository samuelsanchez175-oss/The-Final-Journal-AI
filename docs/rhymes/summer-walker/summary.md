# Summer Walker rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Summer Walker
- Songs: 2
- Bars kept (Summer Walker lyric lines): 80
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Summer Walker.
- Credit strings: Summer Walker.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 338
- REPEAT pairs, recorded separately: 39
- END rhymes: 57
- INNER rhymes: 281

By match:

- PERFECT: 13 (END 3, INNER 10)
- SLANT: 146 (END 23, INNER 123)
- ASSONANCE: 176 (END 28, INNER 148)
- MULTI: 3 (END 3, INNER 0)

By confidence:

- HIGH: 12
- MED: 306
- LOW: 20

## Core

- Core Y: 334
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 139 (41.1%)
- vowel: 176 (52.1%)
- spelling: 20 (5.9%)
- multi: 3 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 43 pairs (END 5, INNER 38). Words: friends, get, again, let's, jessica, well, lessons, end.
2. `vow:OW` — 28 pairs (END 3, INNER 25). Words: don't, no, go, smoke, hope, homies, cold, brodie.
3. `vow:IH` — 20 pairs (END 3, INNER 17). Words: picking, didn't, switch, little, wish, hips, bitch, brittany.
4. `slant:EH:nas-stop` — 17 pairs (END 4, INNER 13). Words: again, get, when, already, any, end, better, friend.
5. `vow:AH` — 17 pairs (END 11, INNER 6). Words: musty, trust, dusty, fuck, kentucky, crush, touch, w.
6. `vow:AE` — 15 pairs (END 2, INNER 13). Words: family, had, can't, stand, ask, exactly, chance, plans.
7. `slant:EH:stop` — 14 pairs (END 1, INNER 13). Words: get, better, let, bestie, perfect, already, said, meant.
8. `vow:IY` — 14 pairs (END 1, INNER 13). Words: see, dreams, need, keep, tia, real, even, sleep.
9. `vow:EY` — 11 pairs (END 0, INNER 11). Words: ain't, say, player, way, always, make, place, baby.
10. `vow:AA` — 10 pairs (END 2, INNER 8). Words: forgotten, apart, locked, drama, promise, plotting, want, wanna.
11. `vow:AY` — 10 pairs (END 1, INNER 9). Words: find, why, like, right, i'll, try, night, stylist.
12. `slant:IY:sib-stop` — 9 pairs (END 0, INNER 9). Words: he'd, these, need, he's, peace, sleep, treat, please.
13. `slant:IH:sib-stop` — 8 pairs (END 0, INNER 8). Words: switch, bitch, grip, hips, slip, bit, sit, hit.
14. `slant:EH:liq-stop` — 7 pairs (END 0, INNER 7). Words: swear, let, where, better, get, forget.
15. `vow:AO` — 6 pairs (END 0, INNER 6). Words: offering, y'all, short, walkin, more, door.
16. `slant:AH:fric-nas` — 5 pairs (END 1, INNER 4). Words: love, one, done.
17. `slant:EH:liq-nas` — 5 pairs (END 0, INNER 5). Words: m, where, tell, when, well, again.
18. `slant:IH:nas-sib` — 4 pairs (END 1, INNER 3). Words: bitch, i'ma, spin, twins.
19. `slant:IH:nas-stop` — 4 pairs (END 0, INNER 4). Words: bit, askin, him, i'ma, sit, hit, brittany.
20. `slant:IY:nas-stop` — 4 pairs (END 0, INNER 4). Words: tryna, need, treat, keep.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 6 pair sides, mostly spelling via spelling phonetic key, often with need (2)
- ima — 5 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- stolie — 4 pair sides, mostly spelling via spelling phonetic key, often with homies (1)
- bestie — 4 pair sides, mostly spelling via spelling phonetic key, often with stolie (1)
- homies — 3 pair sides, mostly vowel via spelling phonetic key, often with brodie (1)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with alone (1)
- kierra — 1 pair sides, mostly spelling via spelling phonetic key, often with sick (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Summer Walker | Get Yo Boy | 49 | 39 | 168 | loose |
| Summer Walker | Good Good (Mixed) | 31 | 18 | 113 | loose |
