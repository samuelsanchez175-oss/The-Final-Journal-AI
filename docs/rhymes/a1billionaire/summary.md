# A1Billionaire rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: A1Billionaire
- Songs: 1
- Bars kept (A1Billionaire lyric lines): 58
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: A1Billionaire.
- Credit strings: A1Billionaire.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 254
- REPEAT pairs, recorded separately: 53
- END rhymes: 55
- INNER rhymes: 199

By match:

- PERFECT: 20 (END 7, INNER 13)
- SLANT: 131 (END 30, INNER 101)
- ASSONANCE: 103 (END 18, INNER 85)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 18
- MED: 202
- LOW: 34

## Core

- Core Y: 249
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 119 (46.9%)
- vowel: 103 (40.6%)
- spelling: 32 (12.6%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 29 pairs (END 9, INNER 20). Words: don't, fargo, ho, no, close, fold, lilo, road.
2. `vow:IH` — 26 pairs (END 2, INNER 24). Words: bitch, shit, think, clips, ribs, lil, wrist, period.
3. `vow:AE` — 16 pairs (END 5, INNER 11). Words: stanford, can't, banging, savage, trap, scanners, stand, fast.
4. `slant:IH:stop` — 15 pairs (END 0, INNER 15). Words: nigga, shit, didn't, lick, big, wrist.
5. `slant:IH:liq-sib` — 11 pairs (END 1, INNER 10). Words: bitch, lil, lilo, stitch, zero, superior, interior.
6. `slant:IH:liq-stop` — 9 pairs (END 4, INNER 5). Words: big, shit, lil, ill, pill, chill, superior, period.
7. `slant:AE:sib` — 8 pairs (END 8, INNER 0). Words: dancers, dances, bandanas, scanners, campus.
8. `vow:EH` — 8 pairs (END 0, INNER 8). Words: feds, scared, when, get, leg, wells, wet.
9. `vow:AA` — 7 pairs (END 2, INNER 5). Words: hearts, patek, watch, top, got, yacht, bottom, shots.
10. `slant:AA:stop` — 6 pairs (END 3, INNER 3). Words: got, patek, yacht, top, fanta, not, pop, spot.
11. `slant:EH:stop` — 6 pairs (END 0, INNER 6). Words: red, scared, get, leg, wet.
12. `slant:IH:liq` — 6 pairs (END 1, INNER 5). Words: lil, cereal, interior, superior, miracle, lilo.
13. `slant:IH:sib-stop` — 6 pairs (END 0, INNER 6). Words: shit, bitch, niggas, nigga, stitch, lick.
14. `vow:AH` — 6 pairs (END 0, INNER 6). Words: guts, fuckin, crush, money, truck, much, cuff, fucking.
15. `cmu:IH-L` — 5 pairs (END 3, INNER 2). Words: pill, lil, chill, ill.
16. `slant:EH:nas-stop` — 5 pairs (END 0, INNER 5). Words: when, red, get, leg.
17. `vow:AY` — 5 pairs (END 0, INNER 5). Words: find, like, nice.
18. `cmu:AA-T` — 4 pairs (END 1, INNER 3). Words: dot, got, shot, yacht, spot.
19. `cmu:OW` — 4 pairs (END 0, INNER 4). Words: fargo, ho, no, go, throw.
20. `slant:AY:stop` — 4 pairs (END 0, INNER 4). Words: like, white.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 16 pair sides, mostly spelling via spelling phonetic key, often with shit (6)
- lilo — 9 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with interior (1)
- taperra — 1 pair sides, mostly vowel via spelling phonetic key, often with stand (1)
- thots — 1 pair sides, mostly spelling via spelling phonetic key, often with shots (1)
- rari — 1 pair sides, mostly spelling via spelling phonetic key, often with banana (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with mode (1)
- hunnid — 1 pair sides, mostly spelling via spelling phonetic key, often with tinted (1)
- cuffing — 1 pair sides, mostly spelling via spelling phonetic key, often with fucking (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with lawyer (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| A1Billionaire | Chill Pill | 58 | 55 | 199 | loose |
