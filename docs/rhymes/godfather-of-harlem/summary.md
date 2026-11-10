# Godfather of Harlem rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Godfather of Harlem
- Songs: 2
- Bars kept (Godfather of Harlem lyric lines): 98
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Godfather of Harlem.
- Credit strings: Godfather of Harlem.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 711
- REPEAT pairs, recorded separately: 72
- END rhymes: 161
- INNER rhymes: 550

By match:

- PERFECT: 57 (END 18, INNER 39)
- SLANT: 291 (END 41, INNER 250)
- ASSONANCE: 359 (END 99, INNER 260)
- MULTI: 4 (END 3, INNER 1)

By confidence:

- HIGH: 57
- MED: 615
- LOW: 39

## Core

- Core Y: 705
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 303 (42.6%)
- vowel: 359 (50.5%)
- spelling: 45 (6.3%)
- multi: 4 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 73 pairs (END 27, INNER 46). Words: fifty, shrimp, rinsing, ripley, sixty, ling, him, 'til.
2. `vow:AY` — 62 pairs (END 32, INNER 30). Words: cry, lie, flights, inside, ride, fights, like, alive.
3. `vow:AA` — 55 pairs (END 13, INNER 42). Words: hard, got, problems, want, rob, cars, washed, dropper.
4. `vow:AE` — 44 pairs (END 19, INNER 25). Words: imagine, magically, relaxin, majesty, rats, mad, savage, latched.
5. `vow:EH` — 39 pairs (END 2, INNER 37). Words: never, ten, friends, health, twelve, question, checker's, special.
6. `slant:AA:stop` — 38 pairs (END 8, INNER 30). Words: got, not, want, cob, heart, somebody, poverty, lottery.
7. `vow:OW` — 26 pairs (END 0, INNER 26). Words: don't, no, gold, know, almost, cold, froze, go.
8. `slant:IH:nas-sib` — 24 pairs (END 4, INNER 20). Words: bling, bitch, stings, thing, things, rings, ring, kings.
9. `vow:EY` — 22 pairs (END 1, INNER 21). Words: ain't, named, main, day, ave, changin, baby, safe.
10. `cmu:IH-NG` — 18 pairs (END 7, INNER 11). Words: bling, ling, ring, thing, bring, anything, fling, strugglin.
11. `slant:AY:stop` — 18 pairs (END 6, INNER 12). Words: outside, pipe, night, strike, like, child, died, ride.
12. `vow:IY` — 17 pairs (END 3, INNER 14). Words: see, agree, feeds, britney, hear, treat, he's, probably.
13. `slant:IH:nas-stop` — 14 pairs (END 0, INNER 14). Words: shit, think, thing, split, ling, i'ma, ding, anything.
14. `vow:AH` — 14 pairs (END 0, INNER 14). Words: couple, nothing, jumpin, money, drug, son's, strugglin, plus.
15. `slant:IH:liq-nas` — 13 pairs (END 0, INNER 13). Words: 'til, i'ma, spin, ding, killer, lil, ling, still.
16. `slant:AY:fric-stop` — 12 pairs (END 5, INNER 7). Words: alive, life, ride, live, like, bite, pipe, outside.
17. `cmu:AY` — 10 pairs (END 1, INNER 9). Words: cry, why, lie, die, try.
18. `slant:IH:stop` — 10 pairs (END 1, INNER 9). Words: hit, split, nigga, lick, fifty, fist, guilty, strip.
19. `slant:IH:sib-stop` — 8 pairs (END 1, INNER 7). Words: niggas, nigga, hits, shit, hit, hickeys, sixty, bitch.
20. `slant:AE:nas-stop` — 7 pairs (END 0, INNER 7). Words: rapper, bad, gang, ran, pack, can, trappin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- bling — 20 pair sides, mostly spelling via spelling phonetic key, often with ling (2)
- ima — 8 pair sides, mostly spelling via spelling phonetic key, often with til (5)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- blimpy — 5 pair sides, mostly vowel via spelling phonetic key, often with fifty (2)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- hickeys — 3 pair sides, mostly vowel via spelling phonetic key, often with whitney (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with even (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with door (1)
- choppa — 1 pair sides, mostly spelling via spelling phonetic key, often with broke (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Godfather of Harlem | Everything’s For Sale | 51 | 71 | 237 | loose |
| Godfather of Harlem | On the Inside | 47 | 90 | 313 | loose |
