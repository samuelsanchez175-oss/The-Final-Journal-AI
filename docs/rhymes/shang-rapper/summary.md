# $hang (Rapper) rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: $hang (Rapper)
- Songs: 1
- Bars kept ($hang (Rapper) lyric lines): 45
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: $hang (Rapper).
- Credit strings: $hang (Rapper).
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 142
- REPEAT pairs, recorded separately: 42
- END rhymes: 31
- INNER rhymes: 111

By match:

- PERFECT: 19 (END 4, INNER 15)
- SLANT: 58 (END 8, INNER 50)
- ASSONANCE: 61 (END 19, INNER 42)
- MULTI: 4 (END 0, INNER 4)

By confidence:

- HIGH: 20
- MED: 119
- LOW: 3

## Core

- Core Y: 142
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 72 (50.7%)
- vowel: 61 (43.0%)
- spelling: 5 (3.5%)
- multi: 4 (2.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 21 pairs (END 10, INNER 11). Words: breasts, myself, ex, check, when, questions, vet, neck.
2. `vow:EY` — 17 pairs (END 6, INNER 11). Words: faded, ain't, sayin, skatin, game, playin, crazy, make.
3. `slant:AY:sib-stop` — 16 pairs (END 0, INNER 16). Words: night, tonight's.
4. `cmu:OW` — 7 pairs (END 0, INNER 7). Words: know, go, no.
5. `slant:AH:nas-stop` — 7 pairs (END 0, INNER 7). Words: fuck, one, money, run, flood, come.
6. `vow:OW` — 5 pairs (END 0, INNER 5). Words: know, go, sold, told, don't, bowl, old.
7. `slant:AE:stop` — 4 pairs (END 1, INNER 3). Words: can't, bank, damaged.
8. `slant:EH:stop` — 4 pairs (END 2, INNER 2). Words: neck, vet, forget, spent.
9. `vow:AE` — 4 pairs (END 0, INNER 4). Words: can't, hang, practise, can, savage, blanket.
10. `vow:IY` — 4 pairs (END 3, INNER 1). Words: guaranteed, free, reachin, preachin, sleepin.
11. `slant:IH:nas-stop` — 3 pairs (END 0, INNER 3). Words: askin, chick, shit, begin, pretty.
12. `slant:IH:stop` — 3 pairs (END 0, INNER 3). Words: big, nigga, pretty, shit, ciroc, blink.
13. `vow:AA` — 3 pairs (END 0, INNER 3). Words: nothin, boss, gotta, poppin, got.
14. `vow:AH` — 3 pairs (END 0, INNER 3). Words: drugs, money, run, fuck.
15. `cmu:AY` — 2 pairs (END 0, INNER 2). Words: by, die.
16. `cmu:IY` — 2 pairs (END 2, INNER 0). Words: free, see.
17. `cmu:IY-T` — 2 pairs (END 0, INNER 2). Words: cheat, skeet.
18. `cmu:OW-L-D` — 2 pairs (END 0, INNER 2). Words: sold, told, old, cold.
19. `multi:EY-IH-NG` — 2 pairs (END 0, INNER 2). Words: sayin, playin, what sayin, think playin.
20. `multi:IY-CH-IH-NG` — 2 pairs (END 0, INNER 2). Words: niggas reachin, what preachin, reachin, preachin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- flossin — 1 pair sides, mostly spelling via spelling phonetic key, often with askin (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with big (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with titties (1)
- titties — 1 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- ciroc — 1 pair sides, mostly spelling via spelling phonetic key, often with blink (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with patron (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| $hang (Rapper) | Faded | 45 | 31 | 111 | loose |
