# Red Cafe rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Red Cafe
- Songs: 1
- Bars kept (Red Cafe lyric lines): 64
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Red Cafe.
- Credit strings: Red Cafe.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 368
- REPEAT pairs, recorded separately: 100
- END rhymes: 51
- INNER rhymes: 317

By match:

- PERFECT: 35 (END 10, INNER 25)
- SLANT: 169 (END 13, INNER 156)
- ASSONANCE: 156 (END 24, INNER 132)
- MULTI: 8 (END 4, INNER 4)

By confidence:

- HIGH: 36
- MED: 308
- LOW: 24

## Core

- Core Y: 361
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 169 (45.9%)
- vowel: 156 (42.4%)
- spelling: 35 (9.5%)
- multi: 8 (2.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 65 pairs (END 19, INNER 46). Words: everything, millions, village, bitch, wrist, villain, killin, piston.
2. `slant:IH:nas` — 17 pairs (END 2, INNER 15). Words: everything, chilling, living, i'ma, ring, livin, whipping, villain.
3. `vow:AA` — 17 pairs (END 0, INNER 17). Words: versace, college, got, hard, condo, washing, motto, stopping.
4. `slant:IH:nas-sib` — 16 pairs (END 0, INNER 16). Words: bitch, everything, village, chilling, villain, anything, bring, ring.
5. `vow:EH` — 16 pairs (END 0, INNER 16). Words: wedding, married, get, accept, better, well, enemies, getting.
6. `cmu:IH-NG` — 14 pairs (END 8, INNER 6). Words: everything, ring, bring.
7. `slant:IH:nas-stop` — 13 pairs (END 0, INNER 13). Words: everything, hit, mic, shit, bring, dipping, strip.
8. `meta:EFR0NK` — 11 pairs (END 7, INNER 4). Words: everything, everythang.
9. `slant:AA:stop` — 10 pairs (END 0, INNER 10). Words: got, cop, want, motto, pronto, condo, hobby, hard.
10. `vow:EY` — 10 pairs (END 0, INNER 10). Words: say, bathin, paper, favorite, gave, ladies, graduated, davis.
11. `vow:OW` — 10 pairs (END 3, INNER 7). Words: convo, though, no, lotto, motto, pronto, condo, combo.
12. `vow:AY` — 9 pairs (END 0, INNER 9). Words: like, why, chi, life, exciting, lie, swipe, michael.
13. `vow:UW` — 9 pairs (END 0, INNER 9). Words: gucci, shootin, jewelry, movie, blue, ruin, louis, sushi.
14. `slant:AH:nas` — 7 pairs (END 1, INNER 6). Words: money, fuckin, none, plugging, thuggin, gun, run, tongue.
15. `slant:IH:stop` — 7 pairs (END 0, INNER 7). Words: nigga, shit, strip, hit, whip.
16. `vow:AH` — 7 pairs (END 1, INNER 6). Words: plugging, fuckin, fuck, blood, love, money, dump, something.
17. `multi:IY-TH-IH-NG` — 6 pairs (END 4, INNER 2). Words: everything, anything, doing everything, doing anything.
18. `slant:AY:stop` — 6 pairs (END 0, INNER 6). Words: like, white, swipe, type.
19. `cmu:OW` — 5 pairs (END 1, INNER 4). Words: no, know, lotto, combo, go.
20. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: cut, money, gun, run, blood.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- everythang — 11 pair sides, mostly spelling via spelling phonetic key, often with everything (11)
- nigga — 8 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- convo — 7 pair sides, mostly vowel via spelling phonetic key, often with lotto (1)
- ima — 5 pair sides, mostly spelling via spelling phonetic key, often with everything (3)
- thuggin — 2 pair sides, mostly spelling via spelling phonetic key, often with killin (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with convo (1)
- coupin — 1 pair sides, mostly spelling via spelling phonetic key, often with ballin (1)
- chainz — 1 pair sides, mostly spelling via spelling phonetic key, often with js (1)
- stuy — 1 pair sides, mostly vowel via spelling phonetic key, often with gucci (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Red Cafe | Gucci Everything | 64 | 51 | 317 | loose |
