# Ice Billion Berg rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ice Billion Berg
- Songs: 2
- Bars kept (Ice Billion Berg lyric lines): 90
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Ice Billion Berg.
- Credit strings: Ice Billion Berg.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 548
- REPEAT pairs, recorded separately: 73
- END rhymes: 126
- INNER rhymes: 422

By match:

- PERFECT: 39 (END 22, INNER 17)
- SLANT: 225 (END 60, INNER 165)
- ASSONANCE: 283 (END 43, INNER 240)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 40
- MED: 475
- LOW: 33

## Core

- Core Y: 543
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 234 (42.7%)
- vowel: 283 (51.6%)
- spelling: 30 (5.5%)
- multi: 1 (0.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 54 pairs (END 5, INNER 49). Words: jump, other, fuckin, bubble, strugglin, bustin, oven, clutchin.
2. `vow:EY` — 53 pairs (END 15, INNER 38). Words: ain't, pay, cable, hate, famous, maple, ashamed, lay.
3. `vow:IH` — 45 pairs (END 9, INNER 36). Words: mix, mixed, missin, shit, lil, wrist, little, whip.
4. `vow:OW` — 42 pairs (END 1, INNER 41). Words: don't, told, know, hoes, go, old, whole, no.
5. `vow:AE` — 25 pairs (END 8, INNER 17). Words: bands, cashed, lamb, crank, can't, hand, last, raggedy.
6. `slant:IH:stop` — 22 pairs (END 3, INNER 19). Words: shit, whip, stick, nigga, lick, hit, wrist, mixed.
7. `slant:EH:sib-stop` — 17 pairs (END 17, INNER 0). Words: lex, check, flex, wreck, tech, heads, bread.
8. `slant:IH:sib-stop` — 16 pairs (END 1, INNER 15). Words: bitch, shit, stick, whip, mix, ms, nigga, niggas.
9. `slant:IH:liq-stop` — 15 pairs (END 0, INNER 15). Words: lil, shit, little, quick, really, hip, hit, still.
10. `vow:EH` — 15 pairs (END 1, INNER 14). Words: get, heads, x, remember, gettin, anywhere, befriend, bet.
11. `vow:AO` — 13 pairs (END 4, INNER 9). Words: wallie, foreign, deported, borin, call, lord, all, performin.
12. `slant:AE:nas-stop` — 12 pairs (END 4, INNER 8). Words: crank, gang, bang, can't, bank, plan, can, man.
13. `vow:IY` — 12 pairs (END 0, INNER 12). Words: nobody, need, fiend, dream, cheese, see, stealin, beef.
14. `vow:AY` — 11 pairs (END 0, INNER 11). Words: why, slidin, eye, right, buy, grindin, ridin, types.
15. `vow:AA` — 9 pairs (END 0, INNER 9). Words: hard, cause, nothin, la, got, projects, dropped, watch.
16. `slant:AO:sib-stop` — 7 pairs (END 7, INNER 0). Words: fork, porsche, porch, lord, pork, dorks.
17. `slant:AE:nas` — 6 pairs (END 6, INNER 0). Words: can, lamb, plan, ham, damn.
18. `slant:IH:nas-sib` — 6 pairs (END 0, INNER 6). Words: bitch, i'ma, winnin, winners, pitch, switchin.
19. `cmu:AE-M` — 5 pairs (END 5, INNER 0). Words: lamb, ham, damn.
20. `slant:AA:stop` — 5 pairs (END 0, INNER 5). Words: heart, got, dropped, hard, hop.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- ima — 6 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- dorks — 6 pair sides, mostly spelling via spelling phonetic key, often with porch (1)
- glist — 4 pair sides, mostly spelling via spelling phonetic key, often with wrist (2)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- forgis — 2 pair sides, mostly spelling via spelling phonetic key, often with dorks (1)
- celi — 2 pair sides, mostly spelling via spelling phonetic key, often with debbie (1)
- thuggin — 1 pair sides, mostly cmu via vault phonetic_class, often with stick (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with dream (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ice Billion Berg | Heart of 100 Men | 49 | 72 | 210 | loose |
| Ice Billion Berg | Watch Me Crank | 41 | 54 | 212 | loose |
