# Obasi Jackson rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Obasi Jackson
- Songs: 2
- Bars kept (Obasi Jackson lyric lines): 79
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Obasi Jackson.
- Credit strings: Obasi Jackson.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 253
- REPEAT pairs, recorded separately: 75
- END rhymes: 43
- INNER rhymes: 210

By match:

- PERFECT: 21 (END 6, INNER 15)
- SLANT: 139 (END 23, INNER 116)
- ASSONANCE: 93 (END 14, INNER 79)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 15
- MED: 221
- LOW: 17

## Core

- Core Y: 250
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 140 (55.3%)
- vowel: 93 (36.8%)
- spelling: 20 (7.9%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 23 pairs (END 0, INNER 23). Words: don't, smoke, know, go, over, holds, robo, o.
2. `vow:AE` — 11 pairs (END 0, INNER 11). Words: mans, man, strapped, ass, dancin, back, tat, actin.
3. `slant:AA:stop` — 10 pairs (END 0, INNER 10). Words: got, robbed, not, want, pop, gotta, rob, glock.
4. `slant:AE:stop` — 10 pairs (END 6, INNER 4). Words: bag, tat, strapped, back, automatic.
5. `vow:AA` — 10 pairs (END 3, INNER 7). Words: problems, robin, got, follow, want, pop, bottles, spot.
6. `vow:EY` — 10 pairs (END 0, INNER 10). Words: baby, make, ain't, waist, say, take, came, hatin.
7. `slant:AA:nas-stop` — 9 pairs (END 0, INNER 9). Words: 'pon, wan, wanna, top, rob, pop, body, hop.
8. `slant:EH:liq-stop` — 9 pairs (END 0, INNER 9). Words: get, where, care, let, tell, air.
9. `vow:UW` — 9 pairs (END 5, INNER 4). Words: huey, coupe, booth, amusing, jew, jewels, new, who's.
10. `vow:IY` — 8 pairs (END 4, INNER 4). Words: schemin, tootsie, feeling, ruly, huey, piece, suvy, these.
11. `slant:IH:liq-stop` — 7 pairs (END 1, INNER 6). Words: really, drill, shit, tit, big, crip, drip, amiri.
12. `vow:IH` — 7 pairs (END 0, INNER 7). Words: listen, bitches, big, crip, drip, really, shit, bitch.
13. `slant:AY:stop` — 6 pairs (END 0, INNER 6). Words: like, slide, tight, white, mike.
14. `slant:EY:sib-stop` — 6 pairs (END 1, INNER 5). Words: face, make, waist.
15. `slant:IH:sib-stop` — 6 pairs (END 2, INNER 4). Words: bitch, shit, drip, niggas, nigga.
16. `slant:IH:stop` — 6 pairs (END 0, INNER 6). Words: nigga, big, crip, tit, hippo.
17. `cmu:EH-R` — 5 pairs (END 1, INNER 4). Words: air, where, care, belaire.
18. `slant:AY:fric-stop` — 5 pairs (END 2, INNER 3). Words: like, life, tight, wife.
19. `vow:EH` — 5 pairs (END 0, INNER 5). Words: ex, let, weapon, tell, head.
20. `slant:AA:liq-stop` — 4 pairs (END 0, INNER 4). Words: follow, bottle, spot, rob, got, shot.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 5 pair sides, mostly spelling via spelling phonetic key, often with big (2)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with pon (4)
- ruly — 4 pair sides, mostly vowel via spelling phonetic key, often with tootsie (1)
- boosie — 3 pair sides, mostly spelling via spelling phonetic key, often with tootsie (1)
- suvy — 3 pair sides, mostly spelling via spelling phonetic key, often with ruly (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with piece (2)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with give (1)
- feinding — 1 pair sides, mostly spelling via spelling phonetic key, often with schemin (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Obasi Jackson | In My Bag* | 43 | 22 | 117 | loose |
| Obasi Jackson | Need Your Love (Remix) | 36 | 21 | 93 | loose |
