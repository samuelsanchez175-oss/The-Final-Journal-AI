# Major Nine rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Major Nine
- Songs: 1
- Bars kept (Major Nine lyric lines): 44
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Major Nine.
- Credit strings: Major Nine.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 246
- REPEAT pairs, recorded separately: 19
- END rhymes: 20
- INNER rhymes: 226

By match:

- PERFECT: 13 (END 1, INNER 12)
- SLANT: 93 (END 2, INNER 91)
- ASSONANCE: 139 (END 16, INNER 123)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 14
- MED: 203
- LOW: 29

## Core

- Core Y: 226
- Core N among rhyme pairs: 20

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 97 (39.4%)
- vowel: 139 (56.5%)
- spelling: 9 (3.7%)
- multi: 1 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 38 pairs (END 8, INNER 30). Words: know, closely, colder, older, oak, floater, no, hold.
2. `vow:IY` — 36 pairs (END 3, INNER 33). Words: shawty, baby, probably, pieces, leavin, beef, even, reason.
3. `vow:EY` — 22 pairs (END 0, INNER 22). Words: baby, ain't, say, changin, places, came, stages, games.
4. `vow:IH` — 13 pairs (END 1, INNER 12). Words: swings, kids, different, lid, bitch, give, dick, spaceship.
5. `vow:EH` — 12 pairs (END 0, INNER 12). Words: lettin, head, tense, there's, percent, accept, many, vegan.
6. `slant:IH:liq-stop` — 7 pairs (END 0, INNER 7). Words: lil, bit, shit, still.
7. `slant:IH:sib-stop` — 7 pairs (END 0, INNER 7). Words: bitch, bit, shit, dick, spaceship.
8. `cmu:OW` — 6 pairs (END 0, INNER 6). Words: though, know, throw, go, no, trudeau.
9. `slant:EH:nas-stop` — 6 pairs (END 0, INNER 6). Words: when, get, lettin, better, any, head, percent.
10. `vow:AA` — 5 pairs (END 0, INNER 5). Words: heart, party, body, hardest, zombie, watch, soccer, rollin.
11. `slant:IH:fric-stop` — 4 pairs (END 0, INNER 4). Words: give, bit, shit, dick, spaceship.
12. `slant:IH:liq-sib` — 4 pairs (END 0, INNER 4). Words: bitch, lil, still.
13. `slant:IY:liq-stop` — 4 pairs (END 0, INNER 4). Words: keep, real, here.
14. `vow:AH` — 4 pairs (END 0, INNER 4). Words: ubers, love, come, lunch, suck, fuckin.
15. `slant:AO:liq-stop` — 3 pairs (END 1, INNER 2). Words: more, daughter, all, shawty.
16. `slant:EH:liq-stop` — 3 pairs (END 0, INNER 3). Words: get, tell, head, fell.
17. `slant:EY:stop` — 3 pairs (END 0, INNER 3). Words: baby, hate, ain't, wait, break.
18. `slant:IY:fric-stop` — 3 pairs (END 0, INNER 3). Words: keep, leave, beef, street.
19. `slant:OW:liq-stop` — 3 pairs (END 0, INNER 3). Words: soul, hold, oak, old.
20. `vow:AO` — 3 pairs (END 2, INNER 1). Words: saw, more, daughter.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- shawty — 18 pair sides, mostly vowel via spelling phonetic key, often with baby (8)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with brodie (1)
- ubers — 2 pair sides, mostly vowel via spelling phonetic key, often with come (1)
- flogged — 2 pair sides, mostly vowel via spelling phonetic key, often with colder (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with lid (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Major Nine | Shawty | 44 | 20 | 226 | loose |
