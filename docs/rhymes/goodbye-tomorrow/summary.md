# Goodbye Tomorrow rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Goodbye Tomorrow
- Songs: 1
- Bars kept (Goodbye Tomorrow lyric lines): 64
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Goodbye Tomorrow.
- Credit strings: Goodbye Tomorrow.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 397
- REPEAT pairs, recorded separately: 41
- END rhymes: 56
- INNER rhymes: 341

By match:

- PERFECT: 25 (END 8, INNER 17)
- SLANT: 146 (END 20, INNER 126)
- ASSONANCE: 212 (END 26, INNER 186)
- MULTI: 14 (END 2, INNER 12)

By confidence:

- HIGH: 38
- MED: 341
- LOW: 18

## Core

- Core Y: 394
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 155 (39.0%)
- vowel: 212 (53.4%)
- spelling: 16 (4.0%)
- multi: 14 (3.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 65 pairs (END 5, INNER 60). Words: getting, remember, when, never, impressive, yourself, breakfast, any.
2. `vow:EY` — 44 pairs (END 10, INNER 34). Words: same, changed, always, came, ain't, change, day, plates.
3. `vow:AY` — 36 pairs (END 2, INNER 34). Words: try, higher, die, y, times, life, like, lied.
4. `slant:EH:stop` — 20 pairs (END 3, INNER 17). Words: said, correct, threat, met, dreamt, went, chest, blessed.
5. `vow:IH` — 17 pairs (END 1, INNER 16). Words: living, serious, period, still, shit, pistols, spitting, sick.
6. `vow:OW` — 17 pairs (END 1, INNER 16). Words: no, don't, show, road, told, only, glow, know.
7. `vow:AH` — 11 pairs (END 5, INNER 6). Words: infrastructure, muzzle, above, humble, other, suffer, something, money.
8. `vow:IY` — 11 pairs (END 0, INNER 11). Words: these, see, freestyled, keep, peace, d, sleep, three.
9. `slant:AY:nas-stop` — 10 pairs (END 3, INNER 7). Words: time, mind, line, inside, shine, nine, lied, define.
10. `slant:EH:fric-stop` — 10 pairs (END 0, INNER 10). Words: never, met, better, said, threat, pressed, impressive, check.
11. `slant:IH:stop` — 10 pairs (END 0, INNER 10). Words: nigga, shit, sick, city.
12. `multi:EH-V-ER` — 9 pairs (END 0, INNER 9). Words: changed ever, ever, never, always never, ever never, around never, change never, never never.
13. `slant:AY:stop` — 8 pairs (END 2, INNER 6). Words: like, satisfied, terrified, right, tight, inside, mind, petrified.
14. `slant:EY:sib-stop` — 8 pairs (END 0, INNER 8). Words: change, changed, wake, breaks, ain't, always, make.
15. `slant:EH:nas-stop` — 7 pairs (END 0, INNER 7). Words: when, went, any, said, check, get, getting, better.
16. `slant:AY:fric-stop` — 6 pairs (END 3, INNER 3). Words: life, like, night, right, tight, lied.
17. `cmu:OW` — 5 pairs (END 0, INNER 5). Words: no, show, know, glow, go.
18. `vow:AA` — 5 pairs (END 1, INNER 4). Words: beyond, gotta, nothin, momma, la, harder, block, god.
19. `slant:AE:nas-stop` — 4 pairs (END 0, INNER 4). Words: humanity, can, man, can't.
20. `slant:AH:nas-sib` — 4 pairs (END 0, INNER 4). Words: cuz, young, money, judge, come, another.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 9 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- cuz — 3 pair sides, mostly spelling via spelling phonetic key, often with money (1)
- freestyled — 3 pair sides, mostly vowel via spelling phonetic key, often with these (2)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Goodbye Tomorrow | NoOne Or NoThing | 64 | 56 | 341 | loose |
