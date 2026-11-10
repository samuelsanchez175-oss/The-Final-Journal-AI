# Yin Yang rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Yin Yang
- Songs: 1
- Bars kept (Yin Yang lyric lines): 61
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Yin Yang.
- Credit strings: Yin Yang.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 261
- REPEAT pairs, recorded separately: 24
- END rhymes: 95
- INNER rhymes: 166

By match:

- PERFECT: 19 (END 7, INNER 12)
- SLANT: 113 (END 38, INNER 75)
- ASSONANCE: 125 (END 46, INNER 79)
- MULTI: 4 (END 4, INNER 0)

By confidence:

- HIGH: 23
- MED: 231
- LOW: 7

## Core

- Core Y: 260
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 126 (48.3%)
- vowel: 125 (47.9%)
- spelling: 6 (2.3%)
- multi: 4 (1.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 33 pairs (END 28, INNER 5). Words: pizza, zebra, cleaning, season, reason, bleachers, cleaners, meet.
2. `vow:EY` — 31 pairs (END 0, INNER 31). Words: today, plain, rain, haters, ain't, day, training, plane.
3. `vow:EH` — 22 pairs (END 9, INNER 13). Words: spend, get, check, getting, percentages, representative, sensitive, spent.
4. `vow:IH` — 17 pairs (END 3, INNER 14). Words: bitch, tinted, trippin, women, bitches, mix, hitting, give.
5. `slant:IY:sib-stop` — 11 pairs (END 5, INNER 6). Words: treat, these, freezer, meet, need, amnesia, freaky, heat.
6. `slant:IY:sib` — 10 pairs (END 9, INNER 1). Words: bleachers, freezer, cleaners, ariza, seizure, lisa, cheese, amnesia.
7. `slant:AH:nas-stop` — 9 pairs (END 0, INNER 9). Words: money, what, fuck, come, some, buggy, nut.
8. `vow:OW` — 9 pairs (END 5, INNER 4). Words: show, clothes, bowl, broke, don't, no, own, smoking.
9. `slant:IY:fric-sib` — 7 pairs (END 7, INNER 0). Words: diva, fever, freezer, seizure, receiver, amnesia, indonesia, lisa.
10. `slant:EH:stop` — 6 pairs (END 0, INNER 6). Words: get, check, spent.
11. `cmu:EY` — 5 pairs (END 3, INNER 2). Words: today, day, say.
12. `slant:IH:sib` — 5 pairs (END 0, INNER 5). Words: bitch, bitches, titties, niggas.
13. `slant:IH:sib-stop` — 5 pairs (END 0, INNER 5). Words: bitch, wit, trip, zip, whip.
14. `slant:IY:fric-stop` — 5 pairs (END 3, INNER 2). Words: heat, fever, receiver, meet, diva, treat.
15. `slant:AH:stop` — 4 pairs (END 0, INNER 4). Words: fuck, what, buggy, nut.
16. `slant:IY:nas-sib` — 4 pairs (END 3, INNER 1). Words: ariza, season, cleaners, cleaning, reason, cheese.
17. `vow:AE` — 4 pairs (END 0, INNER 4). Words: catching, act, have, can't, trappin.
18. `vow:AH` — 4 pairs (END 1, INNER 3). Words: number, one, another, money, fucked, skurt, pump.
19. `cmu:EY-N` — 3 pairs (END 0, INNER 3). Words: plane, plain, rain.
20. `cmu:EY-S` — 3 pairs (END 3, INNER 0). Words: face, place, disgrace.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- choos — 2 pair sides, mostly spelling via spelling phonetic key, often with roof (1)
- skurt — 1 pair sides, mostly vowel via spelling phonetic key, often with pump (1)
- rari — 1 pair sides, mostly spelling via spelling phonetic key, often with man (1)
- titties — 1 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with titties (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Yin Yang | If I Wanted To | 61 | 95 | 166 | loose |
