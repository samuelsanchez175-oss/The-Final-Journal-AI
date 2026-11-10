# Manifest Music Group rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Manifest Music Group
- Songs: 1
- Bars kept (Manifest Music Group lyric lines): 51
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Manifest Music Group.
- Credit strings: Manifest Music Group.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 446
- REPEAT pairs, recorded separately: 27
- END rhymes: 56
- INNER rhymes: 390

By match:

- PERFECT: 18 (END 6, INNER 12)
- SLANT: 190 (END 23, INNER 167)
- ASSONANCE: 234 (END 25, INNER 209)
- MULTI: 4 (END 2, INNER 2)

By confidence:

- HIGH: 22
- MED: 397
- LOW: 27

## Core

- Core Y: 441
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 186 (41.7%)
- vowel: 234 (52.5%)
- spelling: 22 (4.9%)
- multi: 4 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 60 pairs (END 15, INNER 45). Words: em, send, myself, x, respect, kendrick, get, gettin.
2. `vow:IH` — 40 pairs (END 7, INNER 33). Words: bring, bitch, fifty, pistols, killers, switches, six, shit.
3. `vow:IY` — 37 pairs (END 1, INNER 36). Words: these, people, g, see, east, freaks, streets, recent.
4. `vow:AH` — 29 pairs (END 2, INNER 27). Words: government, frontin, cullinan, hundred, fucked, hundreds, run, another.
5. `vow:EY` — 24 pairs (END 0, INNER 24). Words: ain’t, way, lame, say, babe, takin, same, make.
6. `slant:IY:sib-stop` — 16 pairs (END 6, INNER 10). Words: piece, these, beat, cease, eat, heat, sweet, easy.
7. `vow:AW` — 15 pairs (END 0, INNER 15). Words: now, tryouts, countin, bout, mouth, around.
8. `slant:IH:stop` — 14 pairs (END 1, INNER 13). Words: shit, nigga, flippa, stick.
9. `slant:EH:stop` — 13 pairs (END 1, INNER 12). Words: get, check, slept, stepped, respect, center, went.
10. `slant:EH:sib-stop` — 10 pairs (END 4, INNER 6). Words: check, death, get, x, dead, finesse, says, members.
11. `vow:AE` — 9 pairs (END 0, INNER 9). Words: gangsta, ass, can, romantic, act, have, standin, static.
12. `slant:IH:sib-stop` — 8 pairs (END 1, INNER 7). Words: bitch, shit, nigga, niggas, stick.
13. `slant:AA:stop` — 7 pairs (END 0, INNER 7). Words: got, everybody, pop, drop, gotta.
14. `slant:EH:nas-stop` — 7 pairs (END 0, INNER 7). Words: when, get, went, veteran, gettin, send, em, ahead.
15. `slant:IH:liq-stop` — 7 pairs (END 0, INNER 7). Words: shit, lil, really, year, til.
16. `vow:AA` — 7 pairs (END 0, INNER 7). Words: poppin, nothin, top, everybody, drop, solve, bodies, pop.
17. `cmu:IY-T` — 6 pairs (END 6, INNER 0). Words: concrete, heat, street, sweet, beat.
18. `slant:IY:fric-stop` — 6 pairs (END 4, INNER 2). Words: beef, heat, street, concrete, sweet, need, eat.
19. `slant:IY:liq-stop` — 6 pairs (END 0, INNER 6). Words: here, real, speak, heat, sleep.
20. `slant:EH:fric-nas` — 5 pairs (END 0, INNER 5). Words: em, never, every, heavy, when.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 14 pair sides, mostly spelling via spelling phonetic key, often with shit (7)
- niggas — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- flippa — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- pizzils — 3 pair sides, mostly vowel via spelling phonetic key, often with shit (1)
- youngin — 2 pair sides, mostly spelling via spelling phonetic key, often with team (1)
- nics — 2 pair sides, mostly vowel via spelling phonetic key, often with pizzils (1)
- niggasll — 1 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Manifest Music Group | Heat | 51 | 56 | 390 | loose |
