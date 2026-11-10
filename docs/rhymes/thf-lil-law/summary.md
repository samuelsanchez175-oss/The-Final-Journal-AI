# THF LIL LAW rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: THF LIL LAW
- Songs: 1
- Bars kept (THF LIL LAW lyric lines): 44
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: THF LIL LAW.
- Credit strings: THF LIL LAW.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 455
- REPEAT pairs, recorded separately: 41
- END rhymes: 49
- INNER rhymes: 406

By match:

- PERFECT: 36 (END 5, INNER 31)
- SLANT: 226 (END 15, INNER 211)
- ASSONANCE: 190 (END 28, INNER 162)
- MULTI: 3 (END 1, INNER 2)

By confidence:

- HIGH: 34
- MED: 390
- LOW: 31

## Core

- Core Y: 451
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 230 (50.5%)
- vowel: 190 (41.8%)
- spelling: 32 (7.0%)
- multi: 3 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AW` — 41 pairs (END 16, INNER 25). Words: thousand, about, browsin, now, power, houses, crowded, 'bow.
2. `slant:IH:stop` — 38 pairs (END 1, INNER 37). Words: nigga, big, hit, city, shit, nick, stick, outfit.
3. `vow:OW` — 36 pairs (END 2, INNER 34). Words: broke, know, go, bones, show, ople, fold, brodie.
4. `vow:IH` — 35 pairs (END 0, INNER 35). Words: killers, precision, bitch, business, hit, limit, hitters, ricks.
5. `slant:AA:stop` — 32 pairs (END 2, INNER 30). Words: got, pop, block, glock, want, gotta, shop, cost.
6. `slant:IH:sib-stop` — 28 pairs (END 1, INNER 27). Words: bitch, big, city, sis, hit, outfit, busy, diss.
7. `vow:AA` — 27 pairs (END 3, INNER 24). Words: got, boxed, rocks, nothin, socks, want, cost, pop.
8. `slant:IH:nas-stop` — 19 pairs (END 0, INNER 19). Words: him, hit, skinny, nick, big, city, rick, i'ma.
9. `cmu:AO-L` — 10 pairs (END 0, INNER 10). Words: all, y'all, call.
10. `vow:AH` — 9 pairs (END 0, INNER 9). Words: fuck, hundred, somethin, fuckin, what, months, guns, jumped.
11. `cmu:AA-T` — 8 pairs (END 0, INNER 8). Words: got, spot, caught.
12. `vow:AY` — 8 pairs (END 1, INNER 7). Words: by, wild, cyrus, i'll, ice, miley, pies, retired.
13. `vow:AO` — 7 pairs (END 0, INNER 7). Words: law, y'all, all, board, talk.
14. `vow:EH` — 7 pairs (END 0, INNER 7). Words: never, get, next, went, m, eleven, drench, respect.
15. `vow:ER` — 7 pairs (END 6, INNER 1). Words: thorough, world, jersey, early, twirl, curly, girl.
16. `vow:IY` — 7 pairs (END 0, INNER 7). Words: g, see, feel, tweak, p, beatin, d, keep.
17. `slant:AO:liq` — 6 pairs (END 0, INNER 6). Words: all, door, call, backdoor, four, shore, ball.
18. `slant:ER:liq-stop` — 6 pairs (END 6, INNER 0). Words: world, twirl, curly, early, girl.
19. `slant:IH:fric-stop` — 6 pairs (END 0, INNER 6). Words: give, big, shit, stick.
20. `slant:AA:liq-stop` — 5 pairs (END 0, INNER 5). Words: rockstar, got, spot.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 17 pair sides, mostly spelling via spelling phonetic key, often with hit (5)
- homie — 4 pair sides, mostly spelling via spelling phonetic key, often with rodie (1)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with over (2)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- rodie — 3 pair sides, mostly spelling via spelling phonetic key, often with homie (1)
- homies — 2 pair sides, mostly spelling via spelling phonetic key, often with homie (1)
- opps — 2 pair sides, mostly vowel via spelling phonetic key, often with show (2)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with rick (1)
- dyin — 1 pair sides, mostly spelling via spelling phonetic key, often with fuckin (1)
- glizzies — 1 pair sides, mostly spelling via spelling phonetic key, often with business (1)
- herbo — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| THF LIL LAW | All Talk | 44 | 49 | 406 | loose |
