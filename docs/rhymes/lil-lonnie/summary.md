# Lil Lonnie rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Lonnie
- Songs: 1
- Bars kept (Lil Lonnie lyric lines): 69
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lil Lonnie.
- Credit strings: Lil Lonnie.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 367
- REPEAT pairs, recorded separately: 50
- END rhymes: 74
- INNER rhymes: 293

By match:

- PERFECT: 18 (END 8, INNER 10)
- SLANT: 181 (END 27, INNER 154)
- ASSONANCE: 164 (END 36, INNER 128)
- MULTI: 4 (END 3, INNER 1)

By confidence:

- HIGH: 20
- MED: 311
- LOW: 36

## Core

- Core Y: 362
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 166 (45.2%)
- vowel: 164 (44.7%)
- spelling: 33 (9.0%)
- multi: 4 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 34 pairs (END 13, INNER 21). Words: see, green, seems, retreating, need, leave, needed, seen.
2. `vow:AH` — 33 pairs (END 7, INNER 26). Words: colors, money, hundreds, nothing, something, fuck, run, one.
3. `vow:EY` — 28 pairs (END 6, INNER 22). Words: make, stay, lowkey, ain't, face, away, way, sunday.
4. `vow:AA` — 23 pairs (END 7, INNER 16). Words: homage, honest, solid, onyx, boss, problems, body, got.
5. `slant:AH:nas` — 22 pairs (END 5, INNER 17). Words: money, thumbing, coming, one, some, nothing, run, done.
6. `vow:IH` — 19 pairs (END 1, INNER 18). Words: bitch, tripping, lil, windows, tint, distributing, think, dick.
7. `slant:IY:nas-stop` — 17 pairs (END 7, INNER 10). Words: need, green, seen, tryna, seed, scene.
8. `slant:AH:nas-stop` — 13 pairs (END 0, INNER 13). Words: fuck, money, one, monday, what, some, run, done.
9. `slant:IY:nas-sib` — 11 pairs (END 0, INNER 11). Words: tryna, either, ease, seen, green, scene, these.
10. `slant:IH:sib-stop` — 9 pairs (END 0, INNER 9). Words: nigga, niggas, bitch, bitty, sip.
11. `slant:IY:fric-nas` — 9 pairs (END 4, INNER 5). Words: leave, tryna, green, scene, seen, reefer.
12. `vow:EH` — 9 pairs (END 0, INNER 9). Words: get, twenties, trenches, every, adventure, tension, check, pretending.
13. `vow:OW` — 8 pairs (END 0, INNER 8). Words: hold, told, don't, go, broke, going, ho, blow.
14. `slant:IH:liq-sib` — 7 pairs (END 0, INNER 7). Words: lil, bitch.
15. `slant:IY:nas` — 6 pairs (END 0, INNER 6). Words: tryna, scene, seen, green.
16. `slant:IY:sib-stop` — 6 pairs (END 1, INNER 5). Words: these, keep, need, either, please, seed.
17. `cmu:AY-D` — 5 pairs (END 5, INNER 0). Words: ride, pride, inside.
18. `slant:IH:nas-sib` — 5 pairs (END 0, INNER 5). Words: bitch, thing.
19. `slant:IH:nas-stop` — 5 pairs (END 0, INNER 5). Words: thing, dick, win, think, sip, i'ma, tint.
20. `cmu:EY` — 4 pairs (END 0, INNER 4). Words: way, stay, away.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 20 pair sides, mostly spelling via spelling phonetic key, often with need (4)
- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with niggas (6)
- niggas — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- lowkey — 4 pair sides, mostly vowel via spelling phonetic key, often with stay (2)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with dick (1)
- soons — 1 pair sides, mostly spelling via spelling phonetic key, often with soon (1)
- rari — 1 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- hydroponics — 1 pair sides, mostly vowel via spelling phonetic key, often with retreating (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Lonnie | Colors (Remix) | 69 | 74 | 293 | loose |
