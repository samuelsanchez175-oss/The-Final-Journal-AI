# KEY! rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: KEY!
- Songs: 1
- Bars kept (KEY! lyric lines): 22
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: KEY!.
- Credit strings: KEY!.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 207
- REPEAT pairs, recorded separately: 39
- END rhymes: 20
- INNER rhymes: 187

By match:

- PERFECT: 12 (END 3, INNER 9)
- SLANT: 77 (END 10, INNER 67)
- ASSONANCE: 110 (END 7, INNER 103)
- MULTI: 8 (END 0, INNER 8)

By confidence:

- HIGH: 20
- MED: 176
- LOW: 11

## Core

- Core Y: 207
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 78 (37.7%)
- vowel: 110 (53.1%)
- spelling: 11 (5.3%)
- multi: 8 (3.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 45 pairs (END 0, INNER 45). Words: no, romo, mo, tony, polls, roll.
2. `vow:IH` — 29 pairs (END 5, INNER 24). Words: fifty, bitch, hits, fist, living, windows, think, dip.
3. `slant:OW:nas` — 14 pairs (END 0, INNER 14). Words: tony, romo, homi, gon.
4. `slant:AH:nas` — 12 pairs (END 0, INNER 12). Words: drum, run, one, gun, come, young, fuckin.
5. `vow:AH` — 11 pairs (END 0, INNER 11). Words: fuckin, rubber, love, rub, drum, come, young.
6. `vow:EY` — 11 pairs (END 0, INNER 11). Words: ain't, playin, made, place.
7. `cmu:OW` — 9 pairs (END 0, INNER 9). Words: no, mo.
8. `multi:OW-M-OW` — 8 pairs (END 0, INNER 8). Words: tony romo, no mo.
9. `slant:IH:stop` — 8 pairs (END 2, INNER 6). Words: shit, fifty, fist, nigga, dip, listed, ballistic.
10. `vow:UW` — 7 pairs (END 2, INNER 5). Words: through, computers, use, shooter, losers, ruger.
11. `slant:IH:sib-stop` — 6 pairs (END 3, INNER 3). Words: bitch, shit, dip, hits, nigga, niggas.
12. `slant:UW:sib-stop` — 5 pairs (END 3, INNER 2). Words: shooter, use, computers, ruger.
13. `slant:AH:nas-stop` — 4 pairs (END 0, INNER 4). Words: drum, rubber, rub.
14. `cmu:AH-N` — 3 pairs (END 3, INNER 0). Words: gun, run, one.
15. `slant:AH:fric-stop` — 3 pairs (END 0, INNER 3). Words: love, rubber, rub.
16. `slant:OW:liq-nas` — 3 pairs (END 0, INNER 3). Words: roll, romo, tony, gon.
17. `vow:AE` — 3 pairs (END 0, INNER 3). Words: rambo, handle, scratched.
18. `slant:AH:stop` — 2 pairs (END 0, INNER 2). Words: rubber, rub.
19. `slant:AW:nas-stop` — 2 pairs (END 0, INNER 2). Words: round, down.
20. `slant:EY:nas-stop` — 2 pairs (END 0, INNER 2). Words: playin, made.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- homi — 4 pair sides, mostly spelling via spelling phonetic key, often with tony (2)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with tony (1)
- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| KEY! | 50 Round Drum | 22 | 20 | 187 | loose |
