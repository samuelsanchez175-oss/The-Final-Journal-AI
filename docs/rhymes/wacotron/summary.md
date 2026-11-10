# Wacotron rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Wacotron
- Songs: 1
- Bars kept (Wacotron lyric lines): 53
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Wacotron.
- Credit strings: Wacotron.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 453
- REPEAT pairs, recorded separately: 26
- END rhymes: 122
- INNER rhymes: 331

By match:

- PERFECT: 89 (END 40, INNER 49)
- SLANT: 156 (END 33, INNER 123)
- ASSONANCE: 207 (END 48, INNER 159)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 85
- MED: 353
- LOW: 15

## Core

- Core Y: 444
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 235 (51.9%)
- vowel: 207 (45.7%)
- spelling: 10 (2.2%)
- multi: 1 (0.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 75 pairs (END 17, INNER 58). Words: know, go, don’t, don't, folks, only, boat, toes.
2. `vow:EY` — 74 pairs (END 23, INNER 51). Words: ain’t, today, ain't, make, safe, say, pray, day.
3. `cmu:OW` — 22 pairs (END 13, INNER 9). Words: go, know, pro, low, flow, ho, no, o.
4. `slant:AA:stop` — 20 pairs (END 4, INNER 16). Words: art, apart, glock, shark, remark, dark, start, park.
5. `vow:AY` — 20 pairs (END 8, INNER 12). Words: find, time, die, like, mind, lying, grind, try.
6. `cmu:AA-R-K` — 15 pairs (END 1, INNER 14). Words: remark, shark, dark, park, spark, clark.
7. `cmu:EY` — 14 pairs (END 6, INNER 8). Words: way, stay, pray, day, k, today.
8. `cmu:EY-S` — 13 pairs (END 13, INNER 0). Words: pace, chase, trace, space, ace, place, base, face.
9. `slant:AY:nas-stop` — 12 pairs (END 5, INNER 7). Words: shine, pine, like, aside, time, mind, find, grind.
10. `vow:EH` — 11 pairs (END 0, INNER 11). Words: myself, any, next, when, texas, umbrellas, get, forever.
11. `slant:AA:liq-stop` — 10 pairs (END 4, INNER 6). Words: far, start, art, shark, remark, dark, park, spark.
12. `slant:EY:sib-stop` — 10 pairs (END 0, INNER 10). Words: pace, made, make, face, waist, straight, place, base.
13. `vow:AA` — 10 pairs (END 0, INNER 10). Words: promise, cause, constantly, partner, somebody, wanna, heart, start.
14. `slant:OW:sib-stop` — 9 pairs (END 6, INNER 3). Words: throws, decode, reload, o's, hoes, exposed, code.
15. `vow:IY` — 9 pairs (END 0, INNER 9). Words: free, feelings, prolly, c, carlito, easy, seat, somebody.
16. `slant:IH:stop` — 7 pairs (END 0, INNER 7). Words: pick, big, shit, nigga, trip.
17. `cmu:AA-R-T` — 6 pairs (END 1, INNER 5). Words: heart, start, art, apart.
18. `slant:EY:fric-sib` — 6 pairs (END 6, INNER 0). Words: safe, face, pace, chase, trace, space, ace.
19. `slant:IH:liq-stop` — 6 pairs (END 0, INNER 6). Words: pick, still, lil, big.
20. `slant:EY:stop` — 5 pairs (END 0, INNER 5). Words: hate, ain’t, straight, prayed, make, waist.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- opps — 4 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- finito — 3 pair sides, mostly vowel via spelling phonetic key, often with o (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with umbrellas (2)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with give (1)
- prolly — 2 pair sides, mostly vowel via spelling phonetic key, often with somebody (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- freeload — 1 pair sides, mostly multi via spelling phonetic key, often with reload (1)
- cutta — 1 pair sides, mostly spelling via spelling phonetic key, often with must (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Wacotron | Umbrella | 53 | 122 | 331 | loose |
