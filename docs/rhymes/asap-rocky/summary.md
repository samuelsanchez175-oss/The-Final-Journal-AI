# A$AP Rocky rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: A$AP Rocky
- Songs: 2
- Bars kept (A$AP Rocky lyric lines): 81
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: A$AP Rocky.
- Credit strings: A$AP Rocky.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 478
- REPEAT pairs, recorded separately: 64
- END rhymes: 65
- INNER rhymes: 413

By match:

- PERFECT: 53 (END 13, INNER 40)
- SLANT: 181 (END 19, INNER 162)
- ASSONANCE: 236 (END 32, INNER 204)
- MULTI: 8 (END 1, INNER 7)

By confidence:

- HIGH: 58
- MED: 410
- LOW: 10

## Core

- Core Y: 477
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 220 (46.0%)
- vowel: 236 (49.4%)
- spelling: 14 (2.9%)
- multi: 8 (1.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 55 pairs (END 7, INNER 48). Words: ain't, way, baby, take, away, play, plate, glaciers.
2. `vow:OW` — 39 pairs (END 7, INNER 32). Words: don't, go, know, flow, toes, foes, clothes, stole.
3. `vow:IY` — 35 pairs (END 11, INNER 24). Words: sneaks, d, even, see, three, these, reason, free.
4. `vow:EH` — 24 pairs (END 3, INNER 21). Words: m's, correctional, many, seconds, subject, there, ready, went.
5. `vow:AH` — 20 pairs (END 0, INNER 20). Words: suckers, money, hundred, fuckin, buckle, couple, london, summer.
6. `vow:AA` — 17 pairs (END 1, INNER 16). Words: got, nothin, harlem, want, da, cocky, rock, watch.
7. `vow:AE` — 16 pairs (END 2, INNER 14). Words: phantoms, can't, random, cameras, man, ran, bad, ballin.
8. `slant:IY:nas-sib` — 12 pairs (END 1, INNER 11). Words: team, g's, overseas, cream, cheese, either, scene, supreme.
9. `vow:IH` — 12 pairs (END 0, INNER 12). Words: whips, switch, bitch, pillows, zeros, mink, bitches, hills.
10. `cmu:EY` — 10 pairs (END 3, INNER 7). Words: way, lay, bay, play, say, ashtray, highway.
11. `slant:IY:sib-stop` — 10 pairs (END 1, INNER 9). Words: league, keep, overseas, these, cheerleader, cheese, oversees, disease.
12. `slant:AA:stop` — 8 pairs (END 0, INNER 8). Words: got, cocky, want, rock, cost.
13. `vow:AY` — 8 pairs (END 0, INNER 8). Words: kind, ridin, time, diamonds, pine, sign, like.
14. `cmu:IY-Z` — 7 pairs (END 0, INNER 7). Words: these, disease, cheese, overseas, oversees, he's, she's, g's.
15. `cmu:OW` — 7 pairs (END 4, INNER 3). Words: know, go, no, flow, ho, show.
16. `slant:AY:nas-stop` — 7 pairs (END 0, INNER 7). Words: like, kind, pine, shiny, tiny, time.
17. `slant:IY:fric-nas` — 7 pairs (END 4, INNER 3). Words: sleeve, leave, supreme, scene, machine, lean.
18. `slant:EY:nas-stop` — 6 pairs (END 3, INNER 3). Words: came, maybe, blame, baby, wake, make, game.
19. `slant:EY:stop` — 6 pairs (END 2, INNER 4). Words: baby, wake, prepaid, inmate, ain't, plate, take, fake.
20. `slant:IY:fric-sib` — 6 pairs (END 0, INNER 6). Words: leave, sleeve, she's, either, g's.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with woke (2)
- daps — 2 pair sides, mostly vowel via spelling phonetic key, often with cant (1)
- mes — 2 pair sides, mostly spelling via spelling phonetic key, often with many (2)
- droptops — 1 pair sides, mostly spelling via spelling phonetic key, often with eyedrops (1)
- aps — 1 pair sides, mostly spelling via spelling phonetic key, often with daps (1)
- dungarees — 1 pair sides, mostly spelling via spelling phonetic key, often with knees (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- capris — 1 pair sides, mostly spelling via spelling phonetic key, often with rappers (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| A$AP Rocky | CALLDROPS | 27 | 16 | 62 | loose |
| A$AP Rocky | Cocky | 54 | 49 | 351 | loose |
