# TRENDY BOIIZ rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: TRENDY BOIIZ
- Songs: 1
- Bars kept (TRENDY BOIIZ lyric lines): 49
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: TRENDY BOIIZ.
- Credit strings: TRENDY BOIIZ.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 243
- REPEAT pairs, recorded separately: 26
- END rhymes: 77
- INNER rhymes: 166

By match:

- PERFECT: 51 (END 12, INNER 39)
- SLANT: 128 (END 39, INNER 89)
- ASSONANCE: 59 (END 22, INNER 37)
- MULTI: 5 (END 4, INNER 1)

By confidence:

- HIGH: 47
- MED: 175
- LOW: 21

## Core

- Core Y: 240
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 149 (61.3%)
- vowel: 59 (24.3%)
- spelling: 30 (12.3%)
- multi: 5 (2.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:IY:sib-stop` — 36 pairs (END 4, INNER 32). Words: weeks, techniques, seeks, unique, antique, cheek, kiki, tweek.
2. `cmu:IY-K` — 30 pairs (END 1, INNER 29). Words: cheek, tweek, speak, weak, antique, zeke, freek, monique.
3. `vow:IY` — 22 pairs (END 1, INNER 21). Words: see, weeks, cheek, kiki, techniques, unique, these, key.
4. `slant:AA:stop` — 21 pairs (END 10, INNER 11). Words: got, popped, locked, heart, opp, stopped, socked, rocked.
5. `vow:EH` — 20 pairs (END 13, INNER 7). Words: trendy, bentley, get, semi, fendi, remy, wendy's, enemy.
6. `slant:IH:sib-stop` — 13 pairs (END 10, INNER 3). Words: bitch, quick, rick, sticks, blick, picture, twitter, richer.
7. `slant:IH:stop` — 13 pairs (END 2, INNER 11). Words: blick, nigga, rick, hit, twitter, wit, blicky.
8. `vow:IH` — 10 pairs (END 5, INNER 5). Words: sticks, picture, wit, twitter, hit, bitch, lil, drill.
9. `slant:IY:stop` — 9 pairs (END 0, INNER 9). Words: kiki, antique, weak, zeke, cheek, tweek, speak, freek.
10. `slant:IH:liq-sib` — 7 pairs (END 2, INNER 5). Words: lil, richer, switch, drill, pill, bitch.
11. `cmu:IY-K-S` — 5 pairs (END 5, INNER 0). Words: weeks, techniques, seeks.
12. `slant:IH:sib` — 5 pairs (END 3, INNER 2). Words: picture, richer, bitch, switch.
13. `cmu:EH-T` — 4 pairs (END 0, INNER 4). Words: let, get.
14. `cmu:AA-K-T` — 3 pairs (END 3, INNER 0). Words: locked, socked, rocked.
15. `slant:AW:nas-stop` — 3 pairs (END 0, INNER 3). Words: down, around, doubt, without.
16. `slant:EH:sib-stop` — 3 pairs (END 3, INNER 0). Words: wendy's, trendy, fendi.
17. `slant:IH:liq-stop` — 3 pairs (END 2, INNER 1). Words: quick, lil, drill, pill.
18. `slant:IY:liq-stop` — 3 pairs (END 0, INNER 3). Words: here, weak, zeke, antique.
19. `cmu:AA-P-T` — 2 pairs (END 1, INNER 1). Words: popped, stopped.
20. `cmu:IH-T` — 2 pairs (END 0, INNER 2). Words: wit, hit.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tweek — 13 pair sides, mostly spelling via spelling phonetic key, often with weeks (2)
- freek — 9 pair sides, mostly spelling via spelling phonetic key, often with tweek (1)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with hit (1)
- blicky — 5 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- hol — 1 pair sides, mostly spelling via spelling phonetic key, often with going (1)
- cuz — 1 pair sides, mostly spelling via spelling phonetic key, often with come (1)
- imma — 1 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| TRENDY BOIIZ | Freek-A-Leek Monique | 49 | 77 | 166 | loose |
