# Millyz rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Millyz
- Songs: 2
- Bars kept (Millyz lyric lines): 89
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Millyz.
- Credit strings: Millyz.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 740
- REPEAT pairs, recorded separately: 45
- END rhymes: 138
- INNER rhymes: 602

By match:

- PERFECT: 48 (END 6, INNER 42)
- SLANT: 298 (END 77, INNER 221)
- ASSONANCE: 388 (END 52, INNER 336)
- MULTI: 6 (END 3, INNER 3)

By confidence:

- HIGH: 46
- MED: 652
- LOW: 42

## Core

- Core Y: 731
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 304 (41.1%)
- vowel: 388 (52.4%)
- spelling: 42 (5.7%)
- multi: 6 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 87 pairs (END 23, INNER 64). Words: ain't, pavement, raisins, shavin, savings, same, paper, raised.
2. `vow:OW` — 56 pairs (END 6, INNER 50). Words: don't, go, show, know, no, hope, rose, dope.
3. `vow:IH` — 53 pairs (END 7, INNER 46). Words: shit, still, wrist, ignorance, fifty, risk, sympathy, clearly.
4. `vow:EH` — 39 pairs (END 0, INNER 39). Words: read, vegetable, resent, enemies, never, america's, spent, trenches.
5. `vow:AE` — 38 pairs (END 0, INNER 38). Words: can't, baggin, cash, had, blast, laugh, mask, act.
6. `vow:AY` — 31 pairs (END 0, INNER 31). Words: like, try, die, signs, priceless, prior, vibe, nights.
7. `vow:AO` — 27 pairs (END 13, INNER 14). Words: all, y'all, performin, water, walkin, border, lost, recorded.
8. `slant:AO:stop` — 18 pairs (END 18, INNER 0). Words: afford, quarter, extorted, shorted, rewarded, order, recorded, border.
9. `slant:EY:nas` — 18 pairs (END 7, INNER 11). Words: same, came, bane, game, pain, 'caine, gain, slain.
10. `slant:IH:stop` — 17 pairs (END 4, INNER 13). Words: shit, city, big, squirter, wrist, sig, trigger, outfit.
11. `slant:AE:stop` — 16 pairs (END 0, INNER 16). Words: had, stacked, can't, act, 'raq, back, mask, blast.
12. `vow:AH` — 15 pairs (END 1, INNER 14). Words: what, must, double, dumpin, become, clutchin, puttin, under.
13. `vow:AA` — 13 pairs (END 0, INNER 13). Words: darkness, got, park, gotta, lot, hard, heart, rollin.
14. `vow:IY` — 13 pairs (END 2, INNER 11). Words: either, p, beefin, frequent, sequence, paulie, p's, youtubers.
15. `slant:AY:fric-stop` — 11 pairs (END 2, INNER 9). Words: like, dive, alive, life, side, vibe, outside, ride.
16. `slant:AY:stop` — 10 pairs (END 1, INNER 9). Words: side, like, outside, smiled, ride, find, vibe, surprised.
17. `cmu:OW` — 9 pairs (END 0, INNER 9). Words: go, show, know, no, though.
18. `slant:EY:nas-sib` — 9 pairs (END 6, INNER 3). Words: same, flames, chains, savings, shavin, change, cocaine, th.
19. `slant:EY:sib-stop` — 9 pairs (END 1, INNER 8). Words: played, prayed, face, razor, days, paper, newspapers, th.
20. `slant:IH:sib-stop` — 9 pairs (END 4, INNER 5). Words: bitch, bliss, city, risk, wrist, flip, dick, stick.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- raq — 7 pair sides, mostly spelling via spelling phonetic key, often with flash (1)
- youtubers — 5 pair sides, mostly spelling via spelling phonetic key, often with flavors (1)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- homie — 4 pair sides, mostly spelling via spelling phonetic key, often with gon (1)
- runtz — 4 pair sides, mostly spelling via spelling phonetic key, often with months (1)
- chumps — 4 pair sides, mostly spelling via spelling phonetic key, often with months (1)
- squirter — 4 pair sides, mostly spelling via spelling phonetic key, often with city (4)
- tryna — 4 pair sides, mostly spelling via spelling phonetic key, often with feel (2)
- youngin — 3 pair sides, mostly spelling via spelling phonetic key, often with youngins (1)
- swerver — 3 pair sides, mostly spelling via spelling phonetic key, often with murder (1)
- herbo — 3 pair sides, mostly vowel via spelling phonetic key, often with roberto (1)
- homies — 2 pair sides, mostly spelling via spelling phonetic key, often with s (1)
- opps — 2 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- youngins — 1 pair sides, mostly spelling via spelling phonetic key, often with youngin (1)
- suckas — 1 pair sides, mostly spelling via spelling phonetic key, often with once (1)
- medell — 1 pair sides, mostly vowel via spelling phonetic key, often with left (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Millyz | Becoming | 44 | 75 | 253 | loose |
| Millyz | Emotions | 45 | 63 | 349 | loose |
