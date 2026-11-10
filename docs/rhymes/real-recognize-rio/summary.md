# Real Recognize Rio rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Real Recognize Rio
- Songs: 1
- Bars kept (Real Recognize Rio lyric lines): 31
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Real Recognize Rio.
- Credit strings: Real Recognize Rio.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 245
- REPEAT pairs, recorded separately: 29
- END rhymes: 42
- INNER rhymes: 203

By match:

- PERFECT: 9 (END 3, INNER 6)
- SLANT: 106 (END 19, INNER 87)
- ASSONANCE: 128 (END 20, INNER 108)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 10
- MED: 210
- LOW: 25

## Core

- Core Y: 238
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 96 (39.2%)
- vowel: 128 (52.2%)
- spelling: 19 (7.8%)
- multi: 2 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 41 pairs (END 17, INNER 24). Words: melt, swear, help, schedule, level, medal, dresser, pepper.
2. `vow:EY` — 16 pairs (END 1, INNER 15). Words: ain't, graduatin, everyday, play, inhaler, way, change, game.
3. `vow:IH` — 12 pairs (END 2, INNER 10). Words: shit, triple, pistol, bitches, griselda, sip, him, nigga.
4. `slant:EH:sib-stop` — 10 pairs (END 5, INNER 5). Words: let, stretcher, dresser, pressure, dead, pepper, breath, coretta.
5. `vow:IY` — 10 pairs (END 0, INNER 10). Words: feelin, mean, b, real, screamin, free, three.
6. `slant:EH:liq` — 9 pairs (END 9, INNER 0). Words: schedule, level, pebble, medal, wrestler.
7. `slant:IH:nas-stop` — 9 pairs (END 1, INNER 8). Words: shit, i'ma, him, dip, king.
8. `vow:AA` — 9 pairs (END 0, INNER 9). Words: started, pockets, robbin, problems, talkin, want, dark, got.
9. `vow:OW` — 9 pairs (END 0, INNER 9). Words: know, close, told, hoes, don't, swoller, bando, roaches.
10. `slant:EH:stop` — 8 pairs (END 1, INNER 7). Words: melt, coretta, slept, went, let, dead, pepper, get.
11. `vow:AE` — 8 pairs (END 0, INNER 8). Words: can't, grab, angle, can, advantage, catch.
12. `vow:AH` — 8 pairs (END 0, INNER 8). Words: comin, hustle, fuck, buzz, fuckin, blood, none, thuggin.
13. `vow:AO` — 7 pairs (END 0, INNER 7). Words: all, fourth, quarter, fall, call, lost.
14. `slant:IH:liq-stop` — 6 pairs (END 0, INNER 6). Words: lil, shit, build, dip, 'til, still.
15. `slant:IH:sib-stop` — 5 pairs (END 1, INNER 4). Words: niggas, bitch, nigga, shit, dip, jigga.
16. `slant:IH:stop` — 4 pairs (END 0, INNER 4). Words: nigga, shit, dip, sip.
17. `vow:AY` — 4 pairs (END 0, INNER 4). Words: like, bae, silent, might.
18. `cmu:AO-L` — 3 pairs (END 3, INNER 0). Words: all, fall, call.
19. `slant:AH:nas-stop` — 3 pairs (END 0, INNER 3). Words: cup, one, money, none, fuck.
20. `slant:AY:stop` — 3 pairs (END 0, INNER 3). Words: like, might, tried, right.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 8 pair sides, mostly spelling via spelling phonetic key, often with shit (4)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- griselda — 3 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)
- jigga — 2 pair sides, mostly vowel via spelling phonetic key, often with griselda (1)
- swoller — 2 pair sides, mostly vowel via spelling phonetic key, often with close (1)
- shawty — 2 pair sides, mostly spelling via spelling phonetic key, often with lost (1)
- thuggin — 2 pair sides, mostly vowel via spelling phonetic key, often with comin (1)
- bando — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- eliantte — 1 pair sides, mostly vowel via spelling phonetic key, often with left (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Real Recognize Rio | Pressure | 31 | 42 | 203 | loose |
