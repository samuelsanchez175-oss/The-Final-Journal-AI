# Lil Nizzy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Nizzy
- Songs: 1
- Bars kept (Lil Nizzy lyric lines): 32
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lil Nizzy.
- Credit strings: Lil Nizzy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 275
- REPEAT pairs, recorded separately: 43
- END rhymes: 38
- INNER rhymes: 237

By match:

- PERFECT: 34 (END 5, INNER 29)
- SLANT: 167 (END 15, INNER 152)
- ASSONANCE: 68 (END 15, INNER 53)
- MULTI: 6 (END 3, INNER 3)

By confidence:

- HIGH: 40
- MED: 212
- LOW: 23

## Core

- Core Y: 274
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 179 (65.1%)
- vowel: 68 (24.7%)
- spelling: 22 (8.0%)
- multi: 6 (2.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:AA:liq-stop` — 68 pairs (END 8, INNER 60). Words: star, pop, rockstar, block, car, hard, cop, not.
2. `vow:AA` — 31 pairs (END 9, INNER 22). Words: hard, pop, cars, want, stars, block, top, cop.
3. `slant:AA:stop` — 27 pairs (END 0, INNER 27). Words: pop, block, not, knock, top, opp, want, lot.
4. `cmu:AA-R` — 16 pairs (END 4, INNER 12). Words: star, rockstar, car.
5. `vow:AH` — 12 pairs (END 3, INNER 9). Words: fucked, bomin, fucks, some, stuff, fuckin, dumb, drummin.
6. `slant:AH:fric-nas` — 10 pairs (END 1, INNER 9). Words: stuff, some, bruh, done, stunner.
7. `cmu:AA-P` — 9 pairs (END 1, INNER 8). Words: pop, opp, cop, top.
8. `slant:AA:liq-sib` — 8 pairs (END 4, INNER 4). Words: cars, star, rockstar, car.
9. `slant:AH:nas` — 8 pairs (END 0, INNER 8). Words: some, done, dumb, drummin, comin, gun, fuckin.
10. `vow:EY` — 7 pairs (END 3, INNER 4). Words: way, always, champagne, made, pain, campaign, ain't.
11. `slant:IH:sib-stop` — 6 pairs (END 0, INNER 6). Words: nigga, niggas.
12. `vow:OW` — 6 pairs (END 0, INNER 6). Words: know, smoke, showin, no, don't, won't, show.
13. `slant:AA:sib-stop` — 4 pairs (END 1, INNER 3). Words: boss, cars, hard, lot, block, rock.
14. `slant:AH:nas-stop` — 4 pairs (END 0, INNER 4). Words: what, some, fuckin, fucked, done.
15. `vow:AE` — 4 pairs (END 0, INNER 4). Words: can't, rap, damn, rastas.
16. `multi:AE-M-P-EY-N` — 3 pairs (END 3, INNER 0). Words: damn pain, some champagne, champagne, campaign, could campaign.
17. `slant:EY:nas-stop` — 3 pairs (END 0, INNER 3). Words: ain't, champagne, pain, campaign.
18. `slant:OW:liq-nas` — 3 pairs (END 0, INNER 3). Words: gon, whole, lonely.
19. `vow:AO` — 3 pairs (END 0, INNER 3). Words: austin, all, water.
20. `vow:EH` — 3 pairs (END 0, INNER 3). Words: tellin, ever, better, get, givenchy.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 8 pair sides, mostly spelling via spelling phonetic key, often with niggas (6)
- bruh — 7 pair sides, mostly spelling via spelling phonetic key, often with some (3)
- niggas — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with whole (2)
- bomin — 3 pair sides, mostly vowel via vault phonetic_class, often with dumb (1)
- rari — 1 pair sides, mostly spelling via spelling phonetic key, often with damn (1)
- rastas — 1 pair sides, mostly vowel via spelling phonetic key, often with cant (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Nizzy | Block Star | 32 | 38 | 237 | loose |
