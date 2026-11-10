# Calvin Harris rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Calvin Harris
- Songs: 1
- Bars kept (Calvin Harris lyric lines): 25
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Calvin Harris.
- Credit strings: Calvin Harris.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 211
- REPEAT pairs, recorded separately: 12
- END rhymes: 21
- INNER rhymes: 190

By match:

- PERFECT: 21 (END 1, INNER 20)
- SLANT: 117 (END 19, INNER 98)
- ASSONANCE: 72 (END 0, INNER 72)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 22
- MED: 175
- LOW: 14

## Core

- Core Y: 209
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 126 (59.7%)
- vowel: 72 (34.1%)
- spelling: 12 (5.7%)
- multi: 1 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:EH:stop` — 22 pairs (END 7, INNER 15). Words: check, wet, disrespect, went, yet, let, neck, said.
2. `vow:AA` — 19 pairs (END 0, INNER 19). Words: garments, bought, chartered, got, partner, spark, parked, dom.
3. `vow:EH` — 16 pairs (END 0, INNER 16). Words: fendi, went, check, never, said, left, smell, best.
4. `slant:IH:stop` — 14 pairs (END 0, INNER 14). Words: shit, hit, lick, twitter, stic, nigga, ticket.
5. `vow:UW` — 14 pairs (END 0, INNER 14). Words: noodle, stu, new, coupe, route, soup, suit, screwed.
6. `slant:IH:sib-stop` — 13 pairs (END 1, INNER 12). Words: bitch, shit, armpits, hit, twitter, niggas, nigga, lick.
7. `slant:IH:nas-stop` — 7 pairs (END 2, INNER 5). Words: thing, hit, him, shit, lick.
8. `slant:UW:stop` — 7 pairs (END 5, INNER 2). Words: route, soup, suit, screwed, coupe.
9. `cmu:AA-T` — 6 pairs (END 0, INNER 6). Words: got, bought, hot.
10. `vow:IH` — 6 pairs (END 0, INNER 6). Words: sippin, armpits, stic, ticket, shit, thing.
11. `slant:AA:liq-stop` — 5 pairs (END 2, INNER 3). Words: holler, robber, collar, bought, drop.
12. `slant:EH:nas-stop` — 5 pairs (END 0, INNER 5). Words: n, tec, tech, yet, went, let.
13. `vow:AH` — 5 pairs (END 0, INNER 5). Words: jumped, come, fuck, drugs, w, money.
14. `vow:AY` — 5 pairs (END 0, INNER 5). Words: like, hi, diamonds, why, ride, ridin, find.
15. `slant:AA:stop` — 4 pairs (END 1, INNER 3). Words: parked, robber, bark, spark, drop, bought.
16. `slant:EY:nas-stop` — 4 pairs (END 0, INNER 4). Words: ain't, plane, main.
17. `slant:IH:liq-stop` — 4 pairs (END 0, INNER 4). Words: lil, hit, lick, shit.
18. `slant:IH:nas-sib` — 4 pairs (END 0, INNER 4). Words: bitch, king, him.
19. `cmu:EH-K` — 3 pairs (END 0, INNER 3). Words: check, neck, tech, tec.
20. `cmu:IH-T` — 3 pairs (END 0, INNER 3). Words: hit, shit.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- stic — 5 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- tryna — 4 pair sides, mostly spelling via spelling phonetic key, often with even (3)
- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with hit (2)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with all (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Calvin Harris | New Money | 25 | 21 | 190 | loose |
