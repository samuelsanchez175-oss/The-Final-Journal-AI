# Benji Glo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Benji Glo
- Songs: 1
- Bars kept (Benji Glo lyric lines): 36
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Benji Glo.
- Credit strings: Benji Glo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 240
- REPEAT pairs, recorded separately: 60
- END rhymes: 54
- INNER rhymes: 186

By match:

- PERFECT: 24 (END 7, INNER 17)
- SLANT: 115 (END 14, INNER 101)
- ASSONANCE: 101 (END 33, INNER 68)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 23
- MED: 191
- LOW: 26

## Core

- Core Y: 233
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 119 (49.6%)
- vowel: 101 (42.1%)
- spelling: 20 (8.3%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 69 pairs (END 30, INNER 39). Words: type, nights, pipe, riding, breitling, cry, eye, driving.
2. `slant:AY:stop` — 21 pairs (END 4, INNER 17). Words: type, like, indict, pipe, right, white, fight, sight.
3. `vow:IH` — 21 pairs (END 2, INNER 19). Words: killers, finger, bitch, nigga, hittas, shit, shitters, fear.
4. `slant:IH:stop` — 17 pairs (END 0, INNER 17). Words: nigga, shit, trigger, finger, quick.
5. `slant:AY:fric-stop` — 14 pairs (END 3, INNER 11). Words: type, life, knife, white, fight, five, right.
6. `slant:AY:liq-stop` — 10 pairs (END 0, INNER 10). Words: while, type, indict.
7. `slant:IH:sib-stop` — 10 pairs (END 0, INNER 10). Words: bitch, shit, trigger, itch, niggas, nigga.
8. `slant:IH:fric-sib` — 9 pairs (END 0, INNER 9). Words: bitch, give.
9. `cmu:AY-P` — 7 pairs (END 0, INNER 7). Words: type, pipe.
10. `slant:IH:liq-sib` — 7 pairs (END 0, INNER 7). Words: still, bitch, killers, itch, till.
11. `slant:EY:sib-stop` — 4 pairs (END 4, INNER 0). Words: paid, shades, face, lemonade.
12. `cmu:AY` — 3 pairs (END 2, INNER 1). Words: dubai, buy, cry, eye, high, dry.
13. `cmu:AY-T` — 3 pairs (END 3, INNER 0). Words: right, white, fight.
14. `cmu:IH-CH` — 3 pairs (END 0, INNER 3). Words: bitch, itch.
15. `cmu:OW` — 3 pairs (END 0, INNER 3). Words: no, glo, go, o.
16. `slant:IH:liq-stop` — 3 pairs (END 0, INNER 3). Words: still, shit, trigger.
17. `vow:AH` — 3 pairs (END 0, INNER 3). Words: one, trust.
18. `slant:AA:nas-stop` — 2 pairs (END 0, INNER 2). Words: got, gonna.
19. `slant:IH:fric-stop` — 2 pairs (END 0, INNER 2). Words: give, shit, quick.
20. `vow:AE` — 2 pairs (END 0, INNER 2). Words: man, braggin, can, that'll.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 22 pair sides, mostly spelling via spelling phonetic key, often with shit (8)
- hittas — 6 pair sides, mostly vowel via spelling phonetic key, often with nigga (5)
- shitters — 4 pair sides, mostly spelling via spelling phonetic key, often with killers (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- homies — 1 pair sides, mostly spelling via spelling phonetic key, often with close (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Benji Glo | Type Of Nigga | 36 | 54 | 186 | loose |
