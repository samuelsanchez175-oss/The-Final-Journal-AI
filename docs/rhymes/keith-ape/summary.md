# Keith Ape rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Keith Ape
- Songs: 1
- Bars kept (Keith Ape lyric lines): 37
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Keith Ape.
- Credit strings: Keith Ape.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 141
- REPEAT pairs, recorded separately: 13
- END rhymes: 49
- INNER rhymes: 92

By match:

- PERFECT: 13 (END 5, INNER 8)
- SLANT: 81 (END 30, INNER 51)
- ASSONANCE: 47 (END 14, INNER 33)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 13
- MED: 125
- LOW: 3

## Core

- Core Y: 140
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 92 (65.2%)
- vowel: 47 (33.3%)
- spelling: 2 (1.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:ER:sib-stop` — 15 pairs (END 12, INNER 3). Words: church, disperse, earth, shirt, hurt, bird, disturb, curb.
2. `vow:IH` — 12 pairs (END 1, INNER 11). Words: think, wrist, bitch, lips, hit, city, big, shit.
3. `vow:IY` — 11 pairs (END 6, INNER 5). Words: see, av, teeth, believe, lean, breeze, knees, leanin.
4. `slant:AA:stop` — 8 pairs (END 1, INNER 7). Words: got, cop, drop, lot.
5. `vow:OW` — 8 pairs (END 5, INNER 3). Words: ho, froze, cold, gold, go, blowing, don't, phone.
6. `slant:ER:stop` — 7 pairs (END 5, INNER 2). Words: bird, disturb, vert, hurt, curb.
7. `slant:IH:stop` — 6 pairs (END 0, INNER 6). Words: hit, wrist, city, nigga, big, shit.
8. `slant:IH:liq-stop` — 5 pairs (END 0, INNER 5). Words: really, hit, city, big, chill, lil.
9. `slant:IY:fric-sib` — 5 pairs (END 2, INNER 3). Words: believe, breeze, knees, leave, teeth.
10. `vow:EY` — 5 pairs (END 0, INNER 5). Words: say, ain't, ape, wavy, play, kay.
11. `vow:AY` — 4 pairs (END 1, INNER 3). Words: diamonds, ice, dying, like.
12. `cmu:AA-T` — 3 pairs (END 0, INNER 3). Words: got, lot, not.
13. `slant:ER:fric-sib` — 3 pairs (END 3, INNER 0). Words: surf, earth, disperse, church.
14. `slant:ER:nas-sib` — 3 pairs (END 0, INNER 3). Words: turn, earth, disperse, church.
15. `slant:ER:sib` — 3 pairs (END 3, INNER 0). Words: earth, disperse, church.
16. `slant:IY:nas-sib` — 3 pairs (END 0, INNER 3). Words: lean, teeth, breeze, knees.
17. `slant:EH:fric-stop` — 2 pairs (END 0, INNER 2). Words: heavy, pepper.
18. `slant:EH:liq` — 2 pairs (END 0, INNER 2). Words: smell, air, care.
19. `slant:EH:stop` — 2 pairs (END 0, INNER 2). Words: desert, get.
20. `slant:ER:fric-stop` — 2 pairs (END 2, INNER 0). Words: surf, shirt, bird.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with hit (2)
- ramen — 1 pair sides, mostly vowel via spelling phonetic key, often with savage (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Keith Ape | The Ice Ape | 37 | 49 | 92 | loose |
