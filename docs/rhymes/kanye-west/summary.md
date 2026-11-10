# Kanye West rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Kanye West
- Songs: 4
- Bars kept (Kanye West lyric lines): 194
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Kanye West.
- Credit strings: Kanye West.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1113
- REPEAT pairs, recorded separately: 163
- END rhymes: 268
- INNER rhymes: 845

By match:

- PERFECT: 120 (END 46, INNER 74)
- SLANT: 530 (END 155, INNER 375)
- ASSONANCE: 452 (END 65, INNER 387)
- MULTI: 11 (END 2, INNER 9)

By confidence:

- HIGH: 125
- MED: 920
- LOW: 68

## Core

- Core Y: 1100
- Core N among rhyme pairs: 13

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 590 (53.0%)
- vowel: 452 (40.6%)
- spelling: 60 (5.4%)
- multi: 11 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 4 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 80 pairs (END 1, INNER 79). Words: jesus, e, p, see, yeezy, thirty, believe, chief.
2. `vow:AY` — 74 pairs (END 12, INNER 62). Words: like, life, high, christ, crucify, by, find, lights.
3. `vow:IH` — 56 pairs (END 20, INNER 36). Words: vision, different, bitch, politics, television, pimpin, wit, tits.
4. `vow:OW` — 53 pairs (END 2, INNER 51). Words: don't, dope, lows, hope, whole, smokin, old, ho.
5. `slant:AY:stop` — 50 pairs (END 34, INNER 16). Words: like, right, soundbite, pipe, spite, kite, night, write.
6. `vow:EY` — 47 pairs (END 7, INNER 40). Words: ain't, way, play, pay, waste, yesterday, shakin, name.
7. `vow:EH` — 42 pairs (END 6, INNER 36). Words: when, friends, trifecta, pen's, reckless, bent, empty, repentin.
8. `slant:AY:fric-stop` — 39 pairs (END 28, INNER 11). Words: life, like, right, night, light, sight, white, soundbite.
9. `slant:IH:stop` — 36 pairs (END 1, INNER 35). Words: nigga, shit, ric, wit, clip, split, drip, crib.
10. `vow:AA` — 35 pairs (END 1, INNER 34). Words: followin, college, shot, apostles, confidence, droppin, gospel, colossal.
11. `slant:IH:sib-stop` — 33 pairs (END 2, INNER 31). Words: bitch, shit, snitch, crip, niggas, nigga, dick, split.
12. `vow:AO` — 23 pairs (END 9, INNER 14). Words: all, lord, saw, exhausted, naughty, mornin, scored, bored.
13. `slant:EY:stop` — 22 pairs (END 14, INNER 8). Words: made, steak, cake, straight, baby, paid, shake, break.
14. `slant:AY:sib-stop` — 20 pairs (END 15, INNER 5). Words: twice, like, right, nice, ice, spite, night, lights.
15. `slant:AO:liq-stop` — 19 pairs (END 18, INNER 1). Words: four, chore, lord, bored, cord, more, afford, door.
16. `slant:EY:nas` — 18 pairs (END 8, INNER 10). Words: sayin, same, train, insane, lame, pain, prayin.
17. `vow:AH` — 17 pairs (END 3, INNER 14). Words: what, hundred, come, somethin, sudden, stunt, fuckin, suckers.
18. `cmu:AO-R-D` — 14 pairs (END 14, INNER 0). Words: bored, ford, afford, cord, lord, scored.
19. `slant:EH:liq-stop` — 14 pairs (END 0, INNER 14). Words: tribeca, get, where, chair, hair, better, there, dread.
20. `slant:EY:nas-stop` — 14 pairs (END 2, INNER 12). Words: same, steak, straight, cake, sayin, made, make, shakin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 26 pair sides, mostly spelling via spelling phonetic key, often with shit (16)
- yeezy — 10 pair sides, mostly vowel via spelling phonetic key, often with see (3)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- shawty — 4 pair sides, mostly vowel via spelling phonetic key, often with naughty (2)
- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with drip (1)
- disser — 2 pair sides, mostly spelling via spelling phonetic key, often with snitch (1)
- 8am — 2 pair sides, mostly spelling via spelling phonetic key, often with ass (1)
- phife — 1 pair sides, mostly spelling via spelling phonetic key, often with hit (1)
- vegetary — 1 pair sides, mostly vowel via spelling phonetic key, often with pussy (1)
- shoutout — 1 pair sides, mostly spelling via spelling phonetic key, often with bout (1)
- blang — 1 pair sides, mostly spelling via spelling phonetic key, often with bang (1)
- lowlifes — 1 pair sides, mostly vowel via spelling phonetic key, often with surrounded (1)
- ballers — 1 pair sides, mostly spelling via spelling phonetic key, often with players (1)
- staceys — 1 pair sides, mostly spelling via spelling phonetic key, often with backs (1)
- sonyas — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- maga — 1 pair sides, mostly spelling via spelling phonetic key, often with attack (1)
- summ — 1 pair sides, mostly spelling via spelling phonetic key, often with come (1)
- kournikova — 1 pair sides, mostly multi via spelling phonetic key, often with jehovah (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with even (1)
- philippes — 1 pair sides, mostly vowel via spelling phonetic key, often with pippen (1)
- hearses — 1 pair sides, mostly vowel via spelling phonetic key, often with these (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Kanye West | Don’t Like.1 | 64 | 132 | 373 | loose |
| Kanye West | Jam 15 | 56 | 79 | 197 | loose |
| Kanye West | Tell The Vision | 14 | 7 | 33 | loose |
| Kanye West | Tell The Vision (Original) | 60 | 50 | 242 | loose |
