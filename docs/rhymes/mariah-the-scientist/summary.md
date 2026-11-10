# Mariah the Scientist rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Mariah the Scientist
- Songs: 1
- Bars kept (Mariah the Scientist lyric lines): 39
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Mariah the Scientist.
- Credit strings: Mariah the Scientist.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 166
- REPEAT pairs, recorded separately: 10
- END rhymes: 23
- INNER rhymes: 143

By match:

- PERFECT: 11 (END 2, INNER 9)
- SLANT: 68 (END 12, INNER 56)
- ASSONANCE: 85 (END 9, INNER 76)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 13
- MED: 151
- LOW: 2

## Core

- Core Y: 164
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 79 (47.6%)
- vowel: 85 (51.2%)
- spelling: 0 (0.0%)
- multi: 2 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 18 pairs (END 1, INNER 17). Words: know, no, choke, devotion, motion, show, won't, moment.
2. `vow:EH` — 17 pairs (END 3, INNER 14). Words: else, text, seventy, many, myself, seven, let, ex.
3. `vow:AY` — 12 pairs (END 2, INNER 10). Words: nights, deprived, time, tonight, aside, pride, night, sliding.
4. `vow:EY` — 9 pairs (END 0, INNER 9). Words: make, ain't, say, taking, way, play, day, away.
5. `vow:IY` — 8 pairs (END 0, INNER 8). Words: feelings, degrees, sleeve, even, probably, feeling, selfies, leave.
6. `slant:AY:stop` — 6 pairs (END 3, INNER 3). Words: tonight, aside, pride, deprived.
7. `slant:EH:nas-stop` — 6 pairs (END 0, INNER 6). Words: seventy, seven, let, when, many, get.
8. `vow:IH` — 6 pairs (END 0, INNER 6). Words: thinks, drilling, city, issues, kiss, think, hid, hit.
9. `vow:AE` — 5 pairs (END 0, INNER 5). Words: back, can't, gangster, have, ask, having.
10. `vow:UW` — 5 pairs (END 3, INNER 2). Words: nudes, through, move, moving.
11. `slant:AY:nas-stop` — 4 pairs (END 2, INNER 2). Words: time, like, aside, night, mine.
12. `cmu:AY-D` — 3 pairs (END 0, INNER 3). Words: pride, aside, outside, hide.
13. `cmu:OW` — 3 pairs (END 0, INNER 3). Words: know, no, show.
14. `slant:AH:nas` — 3 pairs (END 0, INNER 3). Words: come, coming, one, nothing.
15. `slant:EH:liq-stop` — 3 pairs (END 1, INNER 2). Words: steady, well, where, instead.
16. `slant:EH:sib-stop` — 3 pairs (END 0, INNER 3). Words: let, guess, mess, ex, text.
17. `slant:IH:liq-stop` — 3 pairs (END 0, INNER 3). Words: still, really, pretty, blick, city.
18. `multi:OW-SH-AH-N` — 2 pairs (END 0, INNER 2). Words: having motion, love devotion, motion, devotion.
19. `slant:AH:fric-nas` — 2 pairs (END 0, INNER 2). Words: cover, one.
20. `slant:AH:fric-stop` — 2 pairs (END 2, INNER 0). Words: love, dub, club.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- coldhearted — 1 pair sides, mostly vowel via spelling phonetic key, often with choke (1)
- dickll — 1 pair sides, mostly vowel via spelling phonetic key, often with drilling (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Mariah the Scientist | 77 Degrees | 39 | 23 | 143 | loose |
