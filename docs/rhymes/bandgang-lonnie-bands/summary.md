# BandGang Lonnie Bands rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: BandGang Lonnie Bands
- Songs: 1
- Bars kept (BandGang Lonnie Bands lyric lines): 59
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: BandGang Lonnie Bands.
- Credit strings: BandGang Lonnie Bands.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 236
- REPEAT pairs, recorded separately: 50
- END rhymes: 52
- INNER rhymes: 184

By match:

- PERFECT: 25 (END 10, INNER 15)
- SLANT: 89 (END 25, INNER 64)
- ASSONANCE: 116 (END 15, INNER 101)
- MULTI: 6 (END 2, INNER 4)

By confidence:

- HIGH: 31
- MED: 188
- LOW: 17

## Core

- Core Y: 232
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 100 (42.4%)
- vowel: 116 (49.2%)
- spelling: 14 (5.9%)
- multi: 6 (2.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 23 pairs (END 0, INNER 23). Words: make, ain't, afraid, play, away, way, straight, change.
2. `vow:EH` — 19 pairs (END 2, INNER 17). Words: tellin, ever, recipe, blessin, connect, spent, get, let.
3. `vow:AA` — 18 pairs (END 5, INNER 13). Words: got, cards, balis, dark, choppers, gotta, part, raw.
4. `vow:AE` — 16 pairs (END 0, INNER 16). Words: back, savage, wrappin, rappin, man, package, bands, rat.
5. `slant:IH:stop` — 15 pairs (END 2, INNER 13). Words: nigga, quit, brick, chick, lick, whip, shit.
6. `vow:OW` — 14 pairs (END 4, INNER 10). Words: sold, don't, gold, o, float, go, ho, tolls.
7. `vow:IH` — 12 pairs (END 4, INNER 8). Words: digital, wrist, nigga, brick, chick, bitch, quit, lick.
8. `cmu:EY` — 9 pairs (END 2, INNER 7). Words: play, way, say, highway, pay, away, throwaway.
9. `slant:AA:stop` — 9 pairs (END 3, INNER 6). Words: smarter, got, part, gotta, dark.
10. `slant:IH:sib-stop` — 9 pairs (END 5, INNER 4). Words: kiss, niggas, nigga, bitch, brick, quit, chick, lick.
11. `vow:AH` — 9 pairs (END 0, INNER 9). Words: plug, hundred, function, stuff, young, somethin, comin, runnin.
12. `slant:AH:nas` — 8 pairs (END 5, INNER 3). Words: comin, runnin, somethin, young, money, run.
13. `slant:EH:stop` — 6 pairs (END 1, INNER 5). Words: best, connect, get, let, recipe.
14. `cmu:AO-R` — 5 pairs (END 0, INNER 5). Words: more, store, four, pour.
15. `cmu:IH-K` — 3 pairs (END 3, INNER 0). Words: brick, chick, lick.
16. `multi:AH-W-EY` — 3 pairs (END 1, INNER 2). Words: away, throwaway, float away, around throwaway.
17. `slant:AA:liq-stop` — 3 pairs (END 0, INNER 3). Words: got, cali.
18. `slant:AO:liq` — 3 pairs (END 0, INNER 3). Words: all, four, pour.
19. `slant:EH:liq-stop` — 3 pairs (END 0, INNER 3). Words: sell, get, let, check, pair.
20. `cmu:EY-K` — 2 pairs (END 0, INNER 2). Words: shake, make.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 15 pair sides, mostly spelling via spelling phonetic key, often with digital (3)
- bandgang — 2 pair sides, mostly spelling via spelling phonetic key, often with shredgang (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- shredgang — 1 pair sides, mostly spelling via spelling phonetic key, often with bandgang (1)
- lyin — 1 pair sides, mostly spelling via spelling phonetic key, often with seen (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| BandGang Lonnie Bands | High Way | 59 | 52 | 184 | loose |
