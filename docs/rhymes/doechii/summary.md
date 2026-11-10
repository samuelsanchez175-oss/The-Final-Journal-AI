# Doechii rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Doechii
- Songs: 2
- Bars kept (Doechii lyric lines): 55
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Doechii.
- Credit strings: Doechii.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 278
- REPEAT pairs, recorded separately: 30
- END rhymes: 39
- INNER rhymes: 239

By match:

- PERFECT: 19 (END 1, INNER 18)
- SLANT: 134 (END 26, INNER 108)
- ASSONANCE: 125 (END 12, INNER 113)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 16
- MED: 241
- LOW: 21

## Core

- Core Y: 269
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 138 (49.6%)
- vowel: 125 (45.0%)
- spelling: 15 (5.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 22 pairs (END 4, INNER 18). Words: handlin, last, gangster, back, bad, rambo, ass, fat.
2. `slant:AE:sib-stop` — 19 pairs (END 8, INNER 11). Words: ass, pack, gas, bad, last, back, glass, fat.
3. `vow:EY` — 19 pairs (END 2, INNER 17). Words: ain't, babe, greatest, situation, say, way, name, exchange.
4. `vow:OW` — 19 pairs (END 0, INNER 19). Words: don't, no, smoke, dosin, studio, ho, only, home.
5. `vow:IY` — 16 pairs (END 1, INNER 15). Words: reason, even, shawty, deal, every, speak, keep, real.
6. `vow:IH` — 12 pairs (END 0, INNER 12). Words: kickin, little, pick, switchin, hit, still, kill, stink.
7. `vow:AH` — 11 pairs (END 5, INNER 6). Words: putting, country, love, what's, thug, money, comin, rush.
8. `slant:AH:sib-stop` — 8 pairs (END 2, INNER 6). Words: what, suck, what's, rush, hush, much.
9. `slant:AE:stop` — 7 pairs (END 5, INNER 2). Words: fat, back, bad, last, can't, panoramic, bando, rambo.
10. `slant:AY:stop` — 7 pairs (END 4, INNER 3). Words: like, white, night, site.
11. `slant:IY:liq-stop` — 7 pairs (END 0, INNER 7). Words: deal, real, speak, speed, keep, need, here.
12. `vow:AA` — 7 pairs (END 0, INNER 7). Words: got, solid, falling, hardest, gotta, body.
13. `slant:AA:stop` — 6 pairs (END 0, INNER 6). Words: body, got, gotta, solid.
14. `vow:AY` — 6 pairs (END 0, INNER 6). Words: behind, like, time, sides, site, nice, fightin, by.
15. `vow:EH` — 6 pairs (END 0, INNER 6). Words: america, energy, lemon, pepper, bread, every, smell.
16. `slant:AE:sib` — 5 pairs (END 1, INNER 4). Words: zaza, ass, handles, angles, gas, glass.
17. `slant:AH:stop` — 5 pairs (END 2, INNER 3). Words: what, tucked, stuck, thug, truck, suck.
18. `slant:AE:nas-sib` — 4 pairs (END 0, INNER 4). Words: can, gas, glass, ass, zaza.
19. `slant:AH:fric-stop` — 4 pairs (END 1, INNER 3). Words: love, what, thug.
20. `slant:EY:stop` — 4 pairs (END 0, INNER 4). Words: baby, hate, make, ain't, babe.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- zaza — 9 pair sides, mostly spelling via spelling phonetic key, often with last (2)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with lemon (1)
- shawty — 4 pair sides, mostly vowel via spelling phonetic key, often with every (2)
- vibin — 3 pair sides, mostly vowel via spelling phonetic key, often with stink (1)
- bando — 2 pair sides, mostly spelling via spelling phonetic key, often with rambo (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with pick (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Doechii | What It Is (Block Boy) | 50 | 38 | 224 | loose |
| Doechii | What It Is (Block Boy) [Sped Up] | 5 | 1 | 15 | loose |
