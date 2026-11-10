# Modjo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Modjo
- Songs: 1
- Bars kept (Modjo lyric lines): 13
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Modjo.
- Credit strings: Modjo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 73
- REPEAT pairs, recorded separately: 24
- END rhymes: 32
- INNER rhymes: 41

By match:

- PERFECT: 7 (END 6, INNER 1)
- SLANT: 44 (END 20, INNER 24)
- ASSONANCE: 22 (END 6, INNER 16)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 7
- MED: 53
- LOW: 13

## Core

- Core Y: 73
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 38 (52.1%)
- vowel: 22 (30.1%)
- spelling: 13 (17.8%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:AY:stop` — 14 pairs (END 14, INNER 0). Words: like, tonight, right, moonlight, delight.
2. `vow:AY` — 14 pairs (END 6, INNER 8). Words: by, mind, right, moonlight, delight, like, time, eyes.
3. `slant:IH:stop` — 11 pairs (END 0, INNER 11). Words: nigga, shit.
4. `slant:IH:sib-stop` — 8 pairs (END 0, INNER 8). Words: shit, snitch, bitch.
5. `cmu:AY-T` — 6 pairs (END 6, INNER 0). Words: tonight, right, moonlight, delight.
6. `vow:IY` — 4 pairs (END 0, INNER 4). Words: feeling, see, sneak, hear, feel.
7. `slant:AY:nas-stop` — 3 pairs (END 3, INNER 0). Words: time, moonlight, delight, like.
8. `vow:IH` — 3 pairs (END 0, INNER 3). Words: lyrics, shit, snitch.
9. `meta:TNT` — 2 pairs (END 0, INNER 2). Words: don't, tonight.
10. `slant:AY:sib-stop` — 2 pairs (END 2, INNER 0). Words: eyes, delight, like.
11. `cmu:IH-CH` — 1 pairs (END 0, INNER 1). Words: snitch, bitch.
12. `slant:AE:sib-stop` — 1 pairs (END 0, INNER 1). Words: dance, can't.
13. `slant:AY:nas-sib` — 1 pairs (END 1, INNER 0). Words: time, eyes.
14. `slant:EH:liq-stop` — 1 pairs (END 0, INNER 1). Words: get, tell.
15. `slant:IY:liq-stop` — 1 pairs (END 0, INNER 1). Words: sneak, hear.
16. `vow:OW` — 1 pairs (END 0, INNER 1). Words: won't, know.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 11 pair sides, mostly spelling via spelling phonetic key, often with shit (11)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Modjo | Lady (Hear Me Tonight) / I Don’t Like [Laurenzo Fab Remix] [Mixed] | 13 | 32 | 41 | loose |
