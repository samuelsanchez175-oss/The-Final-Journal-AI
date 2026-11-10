# Barloe Team rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Barloe Team
- Songs: 1
- Bars kept (Barloe Team lyric lines): 57
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Barloe Team.
- Credit strings: Barloe Team.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 245
- REPEAT pairs, recorded separately: 25
- END rhymes: 81
- INNER rhymes: 164

By match:

- PERFECT: 17 (END 11, INNER 6)
- SLANT: 95 (END 18, INNER 77)
- ASSONANCE: 126 (END 50, INNER 76)
- MULTI: 7 (END 2, INNER 5)

By confidence:

- HIGH: 21
- MED: 206
- LOW: 18

## Core

- Core Y: 238
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 98 (40.0%)
- vowel: 126 (51.4%)
- spelling: 14 (5.7%)
- multi: 7 (2.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 41 pairs (END 15, INNER 26). Words: fuck, bustin, budget, jumpin, somethin, something, troubled, frontin.
2. `vow:OW` — 31 pairs (END 16, INNER 15). Words: know, bro, though, pose, token, rolling, dope, roll.
3. `vow:EY` — 11 pairs (END 4, INNER 7). Words: say, great, sacred, labels, same, today, bay, fame.
4. `vow:ER` — 8 pairs (END 8, INNER 0). Words: worst, percs, work, first, perc, word.
5. `vow:IH` — 7 pairs (END 1, INNER 6). Words: trippin, kicked, him, miss, pimpin, figure, sitting, smear.
6. `vow:UW` — 7 pairs (END 2, INNER 5). Words: who, tools, move, room, used, music, use.
7. `slant:AA:stop` — 6 pairs (END 0, INNER 6). Words: got, gotta, glock, heart.
8. `slant:AH:fric-nas` — 6 pairs (END 0, INNER 6). Words: recovering, lover, undercover, love.
9. `slant:AH:nas` — 6 pairs (END 1, INNER 5). Words: something, frontin, motherfuckin, recovering, run, young, jumpin, somethin.
10. `vow:AA` — 6 pairs (END 1, INNER 5). Words: talkin, got, margaret's, glock, floss, heart, god's, god.
11. `slant:AA:sib-stop` — 5 pairs (END 0, INNER 5). Words: got, boss, floss, gotta, god's, god.
12. `slant:ER:stop` — 5 pairs (END 3, INNER 2). Words: word, work, world, perc.
13. `slant:IH:nas-stop` — 5 pairs (END 0, INNER 5). Words: shit, thing, sitting, pretty, city, him, bring.
14. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: nigga, shit, sit, pretty, kicked.
15. `cmu:OW` — 4 pairs (END 3, INNER 1). Words: bro, though, know, no.
16. `vow:EH` — 4 pairs (END 0, INNER 4). Words: gettin, shell, never, where, benz, dare.
17. `cmu:ER-K` — 3 pairs (END 2, INNER 1). Words: work, perc.
18. `slant:ER:sib-stop` — 3 pairs (END 3, INNER 0). Words: percs, work, perc.
19. `vow:AE` — 3 pairs (END 0, INNER 3). Words: thank, had, half, have, daddy's.
20. `vow:AO` — 3 pairs (END 2, INNER 1). Words: lost, call, called, more.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- thuggin — 5 pair sides, mostly vowel via spelling phonetic key, often with jumpin (1)
- slubbin — 3 pair sides, mostly vowel via spelling phonetic key, often with somethin (2)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with need (1)
- yeeks — 2 pair sides, mostly spelling via spelling phonetic key, often with yikes (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with phone (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Barloe Team | Slugg | 57 | 81 | 164 | loose |
