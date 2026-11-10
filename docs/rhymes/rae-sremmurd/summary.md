# Rae Sremmurd rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Rae Sremmurd
- Songs: 1
- Bars kept (Rae Sremmurd lyric lines): 54
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Rae Sremmurd.
- Credit strings: Rae Sremmurd.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 296
- REPEAT pairs, recorded separately: 31
- END rhymes: 78
- INNER rhymes: 218

By match:

- PERFECT: 64 (END 31, INNER 33)
- SLANT: 167 (END 47, INNER 120)
- ASSONANCE: 65 (END 0, INNER 65)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 64
- MED: 209
- LOW: 23

## Core

- Core Y: 296
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 208 (70.3%)
- vowel: 65 (22.0%)
- spelling: 23 (7.8%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `cmu:IH-L` — 38 pairs (END 23, INNER 15). Words: still, kill, chill, pill, bill, grill, spill, will.
2. `slant:IH:liq-stop` — 25 pairs (END 9, INNER 16). Words: still, shit, crib, big, spit, spill, mil, chill.
3. `slant:IH:stop` — 22 pairs (END 1, INNER 21). Words: big, nigga, grip, shit, crib, flip, spit.
4. `vow:EH` — 19 pairs (END 0, INNER 19). Words: friend, trend, dressed, left, set, cleanse, get, spends.
5. `vow:IH` — 17 pairs (END 0, INNER 17). Words: listen, big, spittin, rims, prints, pills, crib, still.
6. `slant:IH:liq-sib` — 16 pairs (END 5, INNER 11). Words: bitch, pills, still, chill, skills, kill, until, grill.
7. `slant:ER:stop` — 15 pairs (END 13, INNER 2). Words: burp, dirt, heard, hurt, superb, kirk, work, herc.
8. `slant:IH:sib-stop` — 14 pairs (END 2, INNER 12). Words: bitch, grip, big, flip, niggas, nigga, shit.
9. `vow:AE` — 12 pairs (END 0, INNER 12). Words: blast, can't, racks, snap, strap, man, cash, ass.
10. `cmu:IY-L` — 10 pairs (END 2, INNER 8). Words: real, deal, feel, steal.
11. `slant:AE:nas-sib` — 6 pairs (END 0, INNER 6). Words: cash, ass, man, cam, can.
12. `slant:EH:stop` — 6 pairs (END 0, INNER 6). Words: get, dressed, left, set, better.
13. `vow:OW` — 6 pairs (END 0, INNER 6). Words: hold, smoke, don't, over, throwin, no.
14. `meta:STL` — 5 pairs (END 3, INNER 2). Words: still, steal.
15. `slant:ER:sib-stop` — 5 pairs (END 4, INNER 1). Words: earth, dirt, hurt, heard, superb, herc.
16. `slant:EH:sib-stop` — 4 pairs (END 4, INNER 0). Words: friend, spends, cleanse, trend.
17. `slant:IH:liq` — 4 pairs (END 2, INNER 2). Words: atmosphere, grill, still, till, will.
18. `slant:IH:nas-stop` — 4 pairs (END 0, INNER 4). Words: slim, big, grip.
19. `slant:IY:liq-stop` — 4 pairs (END 0, INNER 4). Words: need, real, steal.
20. `cmu:AW-D` — 3 pairs (END 0, INNER 3). Words: allowed, loud, cloud.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 13 pair sides, mostly spelling via spelling phonetic key, often with big (5)
- herc — 3 pair sides, mostly spelling via spelling phonetic key, often with heard (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with smoke (1)
- skank — 1 pair sides, mostly spelling via spelling phonetic key, often with cant (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Rae Sremmurd | Real Chill | 54 | 78 | 218 | loose |
