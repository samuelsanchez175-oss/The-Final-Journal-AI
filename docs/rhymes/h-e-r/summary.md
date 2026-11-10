# H.E.R. rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: H.E.R.
- Songs: 1
- Bars kept (H.E.R. lyric lines): 68
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: H.E.R..
- Credit strings: H.E.R..
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 378
- REPEAT pairs, recorded separately: 62
- END rhymes: 71
- INNER rhymes: 307

By match:

- PERFECT: 20 (END 2, INNER 18)
- SLANT: 194 (END 43, INNER 151)
- ASSONANCE: 162 (END 26, INNER 136)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 18
- MED: 344
- LOW: 16

## Core

- Core Y: 376
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 198 (52.4%)
- vowel: 162 (42.9%)
- spelling: 16 (4.2%)
- multi: 2 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 35 pairs (END 1, INNER 34). Words: don't, no, snow, told, know, goals, ghost, nose.
2. `slant:AY:stop` — 24 pairs (END 8, INNER 16). Words: slide, night, type, vibe.
3. `vow:EY` — 24 pairs (END 1, INNER 23). Words: baby, ain't, vacation, lay, table, way, day, fake.
4. `vow:IH` — 20 pairs (END 1, INNER 19). Words: bitches, wrist, thing, big, fist, askin, exist, whip.
5. `vow:AH` — 19 pairs (END 4, INNER 15). Words: suckin, government, love, come, once, fuckin, one, what's.
6. `vow:EH` — 19 pairs (END 3, INNER 16). Words: gentleman, carats, embarrassed, pedal, let, never, metal, get.
7. `vow:AY` — 16 pairs (END 12, INNER 4). Words: lie, sides, slide, time, lines, type, vibe, mine.
8. `vow:AE` — 10 pairs (END 1, INNER 9). Words: fast, had, gangster, after, black, candy, makin, plan.
9. `vow:IY` — 10 pairs (END 1, INNER 9). Words: gon, even, seats, e, screamin, g, see, backseat.
10. `slant:AA:stop` — 7 pairs (END 3, INNER 4). Words: spot, cop, hotter, patek, not, gotta, rock, want.
11. `slant:AY:sib-stop` — 7 pairs (END 4, INNER 3). Words: rise, slide, eyes, bike, right, ice, disguise, vibe.
12. `slant:OW:stop` — 7 pairs (END 2, INNER 5). Words: don't, goat, coast, ghost, boat.
13. `slant:AY:fric-stop` — 6 pairs (END 4, INNER 2). Words: slide, live, five.
14. `slant:EH:stop` — 6 pairs (END 0, INNER 6). Words: read, get, said, let, already.
15. `slant:EY:nas-sib` — 6 pairs (END 0, INNER 6). Words: page, same, airplane, champagne.
16. `slant:AH:nas` — 5 pairs (END 1, INNER 4). Words: money, fuckin, one, sun, some, suckin, come.
17. `slant:AY:sib` — 5 pairs (END 5, INNER 0). Words: disguise, eyes, ice, lines, sides.
18. `slant:EY:nas-stop` — 5 pairs (END 0, INNER 5). Words: baby, ain't, came, same, airplane, champagne, playin, take.
19. `slant:IH:liq-stop` — 5 pairs (END 0, INNER 5). Words: really, dick, pic, shit.
20. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: sit, exist, big, fist, wrist, shit.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 9 pair sides, mostly spelling via spelling phonetic key, often with wagon (2)
- tryna — 9 pair sides, mostly spelling via spelling phonetic key, often with nina (2)
- fam — 2 pair sides, mostly spelling via spelling phonetic key, often with bag (1)
- buttnaked — 2 pair sides, mostly vowel via spelling phonetic key, often with love (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| H.E.R. | Slide (Remix) | 68 | 71 | 307 | loose |
