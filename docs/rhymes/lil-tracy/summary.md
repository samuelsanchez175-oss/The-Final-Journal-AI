# Lil Tracy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Tracy
- Songs: 1
- Bars kept (Lil Tracy lyric lines): 39
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lil Tracy.
- Credit strings: Lil Tracy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 189
- REPEAT pairs, recorded separately: 20
- END rhymes: 34
- INNER rhymes: 155

By match:

- PERFECT: 10 (END 3, INNER 7)
- SLANT: 87 (END 17, INNER 70)
- ASSONANCE: 89 (END 13, INNER 76)
- MULTI: 3 (END 1, INNER 2)

By confidence:

- HIGH: 13
- MED: 168
- LOW: 8

## Core

- Core Y: 187
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 91 (48.1%)
- vowel: 89 (47.1%)
- spelling: 6 (3.2%)
- multi: 3 (1.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 20 pairs (END 0, INNER 20). Words: don't, over, know, go, open, only, bowl, smoke.
2. `vow:EY` — 17 pairs (END 3, INNER 14). Words: way, ain't, freeway, anyway, waist, say, came, face.
3. `vow:AH` — 13 pairs (END 0, INNER 13). Words: hundred, fuckin, hundreds, money, judge, fucked, mud, some.
4. `vow:AE` — 11 pairs (END 0, INNER 11). Words: pants, panoramic, cameras, can, understand, glance, hand, racks.
5. `vow:AA` — 8 pairs (END 1, INNER 7). Words: hard, start, mama, want, broccoli, wanna, hot, dollar.
6. `slant:AE:stop` — 7 pairs (END 2, INNER 5). Words: lab, back, can't, bad, mad, hand, understand.
7. `vow:IY` — 7 pairs (END 6, INNER 1). Words: key, cheese, e, weed, green, please.
8. `slant:EY:sib-stop` — 6 pairs (END 4, INNER 2). Words: face, taste, crazy, fakers, baby, maybe, make, take.
9. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: money, fuck, some, makeup, mud, fucked, fuckin.
10. `slant:AA:nas-stop` — 4 pairs (END 0, INNER 4). Words: wanna, hot, mama, want, body.
11. `slant:IY:sib-stop` — 4 pairs (END 2, INNER 2). Words: weed, these, keep, kiki, easy, cheese, please.
12. `vow:IH` — 4 pairs (END 0, INNER 4). Words: chicken, link, rich, hit, lil, him.
13. `slant:AA:liq-stop` — 3 pairs (END 1, INNER 2). Words: star, hard, far, got, rock.
14. `slant:AE:sib-stop` — 3 pairs (END 0, INNER 3). Words: glance, can't, hand, pants.
15. `slant:AY:stop` — 3 pairs (END 0, INNER 3). Words: like, wide, might.
16. `slant:EY:nas-stop` — 3 pairs (END 0, INNER 3). Words: breaking, shake, came, make, take.
17. `slant:IH:nas-stop` — 3 pairs (END 0, INNER 3). Words: i'ma, shit, dick.
18. `slant:IH:sib-stop` — 3 pairs (END 0, INNER 3). Words: bitch, shit, dick.
19. `slant:IH:stop` — 3 pairs (END 3, INNER 0). Words: shit, dick.
20. `vow:AW` — 3 pairs (END 2, INNER 1). Words: now, round, proud, thousand, how.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- ferragamo — 2 pair sides, mostly vowel via spelling phonetic key, often with ho (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Tracy | Chicken Soup | 39 | 34 | 155 | loose |
