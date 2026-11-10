# Yung Mazi rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Yung Mazi
- Songs: 1
- Bars kept (Yung Mazi lyric lines): 28
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Yung Mazi.
- Credit strings: Yung Mazi.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 158
- REPEAT pairs, recorded separately: 19
- END rhymes: 32
- INNER rhymes: 126

By match:

- PERFECT: 8 (END 3, INNER 5)
- SLANT: 61 (END 9, INNER 52)
- ASSONANCE: 89 (END 20, INNER 69)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 8
- MED: 130
- LOW: 20

## Core

- Core Y: 156
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 51 (32.3%)
- vowel: 89 (56.3%)
- spelling: 18 (11.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 28 pairs (END 11, INNER 17). Words: get, exit, left, sex, getting, when, blessing, necklace.
2. `slant:IH:stop` — 22 pairs (END 1, INNER 21). Words: nigga, shit, hit, mid, lick, bullshit, wrist.
3. `vow:IH` — 22 pairs (END 8, INNER 14). Words: bricks, hit, sticks, wrist, shit, bitch, mid, since.
4. `vow:AH` — 16 pairs (END 0, INNER 16). Words: hundred, bloods, fuck, mud, enough, money, flood, love.
5. `slant:IH:sib-stop` — 5 pairs (END 2, INNER 3). Words: bitch, lick, bricks, hit, shit, mid.
6. `vow:OW` — 5 pairs (END 0, INNER 5). Words: broke, no, low, dope, smoking, hold.
7. `slant:IH:nas-stop` — 4 pairs (END 1, INNER 3). Words: thing, hit, lick, shit.
8. `vow:AA` — 4 pairs (END 0, INNER 4). Words: wasn't, got, dollars, shot, large.
9. `vow:IY` — 4 pairs (END 0, INNER 4). Words: keep, d, petty, real.
10. `cmu:IH-T` — 3 pairs (END 0, INNER 3). Words: hit, shit.
11. `slant:AA:sib-stop` — 3 pairs (END 0, INNER 3). Words: boss, got, gotta, shot.
12. `slant:AH:sib-stop` — 3 pairs (END 2, INNER 1). Words: bloods, mud, flood.
13. `vow:AE` — 3 pairs (END 1, INNER 2). Words: falt, trap, gang, daddy, fast.
14. `vow:AO` — 3 pairs (END 0, INNER 3). Words: calling, ot, more, foreign.
15. `slant:AA:stop` — 2 pairs (END 0, INNER 2). Words: got, gotta.
16. `slant:AH:fric-stop` — 2 pairs (END 0, INNER 2). Words: enough, mud, flood.
17. `slant:AH:liq-stop` — 2 pairs (END 0, INNER 2). Words: hundred, hundr.
18. `slant:AH:nas-stop` — 2 pairs (END 0, INNER 2). Words: money, mud, flood.
19. `slant:EH:nas` — 2 pairs (END 2, INNER 0). Words: flexing, blessing, weapon.
20. `slant:EH:nas-stop` — 2 pairs (END 0, INNER 2). Words: get, getting, when.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 16 pair sides, mostly spelling via spelling phonetic key, often with shit (5)
- falt — 2 pair sides, mostly vowel via spelling phonetic key, often with trap (1)
- hundr — 2 pair sides, mostly spelling via spelling phonetic key, often with hundred (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Yung Mazi | Wit Da Shit | 28 | 32 | 126 | loose |
