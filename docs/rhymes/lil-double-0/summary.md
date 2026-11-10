# Lil Double 0 rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Double 0
- Songs: 1
- Bars kept (Lil Double 0 lyric lines): 45
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lil Double 0.
- Credit strings: Lil Double 0.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 559
- REPEAT pairs, recorded separately: 56
- END rhymes: 42
- INNER rhymes: 517

By match:

- PERFECT: 68 (END 12, INNER 56)
- SLANT: 237 (END 10, INNER 227)
- ASSONANCE: 254 (END 20, INNER 234)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 65
- MED: 455
- LOW: 39

## Core

- Core Y: 555
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 267 (47.8%)
- vowel: 254 (45.4%)
- spelling: 38 (6.8%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 101 pairs (END 11, INNER 90). Words: safe, made, lay, play, spray, sprayin, ain't, way.
2. `vow:OW` — 51 pairs (END 4, INNER 47). Words: no, don't, home, go, phone, alone, chrome, hoe.
3. `cmu:EY` — 40 pairs (END 5, INNER 35). Words: spray, play, lay, way, pay, say, bay, stay.
4. `vow:IH` — 29 pairs (END 0, INNER 29). Words: pimp, gorilla, precision, give, mr, big, blitz, hittin.
5. `slant:IH:stop` — 24 pairs (END 0, INNER 24). Words: nigga, hit, big, shit, sit, flip, mr, city.
6. `vow:IY` — 14 pairs (END 1, INNER 13). Words: three, streets, free, thirteen, need, real, keep, nobody.
7. `slant:IY:stop` — 13 pairs (END 0, INNER 13). Words: geeked, geek, need, sleep, keep.
8. `slant:OW:nas` — 13 pairs (END 4, INNER 9). Words: home, phone, alone, chrome, vlone, gon, motion, grown.
9. `slant:OW:nas-stop` — 13 pairs (END 0, INNER 13). Words: don't, phone, alone, vlone, gon, grown.
10. `vow:EH` — 13 pairs (END 0, INNER 13). Words: memphis, welcome, get, benz, where, went, m, any.
11. `vow:AO` — 12 pairs (END 1, INNER 11). Words: walk, court, songs, scorin, song, wrong, gone, cross.
12. `vow:AY` — 12 pairs (END 2, INNER 10). Words: like, die, fire, lines, time, recline, slide, died.
13. `slant:IH:liq-stop` — 11 pairs (END 0, INNER 11). Words: gorilla, hit, lil, shit, still, city, big.
14. `slant:IH:sib-stop` — 11 pairs (END 0, INNER 11). Words: shit, blitz, niggas, nigga, switch, hit, city, diss.
15. `slant:EH:liq-stop` — 10 pairs (END 0, INNER 10). Words: already, where, get, hell, chair, air.
16. `slant:IY:liq-stop` — 9 pairs (END 0, INNER 9). Words: real, keep, geek, need, sleep, here.
17. `vow:AE` — 9 pairs (END 0, INNER 9). Words: trappin, back, habit, had, can't, traps, blanked, facetime.
18. `slant:EY:nas-stop` — 8 pairs (END 0, INNER 8). Words: sprayin, made, raid, sprayed.
19. `slant:AO:nas-stop` — 7 pairs (END 0, INNER 7). Words: song, broad, walk, wrong, thought, along.
20. `slant:AY:nas-stop` — 7 pairs (END 1, INNER 6). Words: like, time, recline, slide, died, hidin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 16 pair sides, mostly spelling via spelling phonetic key, often with hit (5)
- geeked — 8 pair sides, mostly spelling via spelling phonetic key, often with geek (2)
- vlone — 6 pair sides, mostly spelling via spelling phonetic key, often with dont (3)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- blicks — 2 pair sides, mostly vowel via vault phonetic_class, often with trunk (1)
- glocks — 2 pair sides, mostly vowel via spelling phonetic key, often with dont (2)
- sumn — 1 pair sides, mostly spelling via spelling phonetic key, often with somethin (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with need (1)
- facetime — 1 pair sides, mostly vowel via spelling phonetic key, often with blanked (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Double 0 | LAY IT DOWN | 45 | 42 | 517 | loose |
