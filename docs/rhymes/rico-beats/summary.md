# Rico Beats rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Rico Beats
- Songs: 1
- Bars kept (Rico Beats lyric lines): 43
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Rico Beats.
- Credit strings: Rico Beats.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 434
- REPEAT pairs, recorded separately: 40
- END rhymes: 56
- INNER rhymes: 378

By match:

- PERFECT: 62 (END 13, INNER 49)
- SLANT: 182 (END 32, INNER 150)
- ASSONANCE: 186 (END 11, INNER 175)
- MULTI: 4 (END 0, INNER 4)

By confidence:

- HIGH: 57
- MED: 358
- LOW: 19

## Core

- Core Y: 428
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 220 (50.7%)
- vowel: 186 (42.9%)
- spelling: 24 (5.5%)
- multi: 4 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 45 pairs (END 5, INNER 40). Words: ridin, nights, lie, times, stylist, kind, mine, iron.
2. `vow:IH` — 43 pairs (END 0, INNER 43). Words: big, richard, drills, millions, clip, still, bitches, chills.
3. `vow:OW` — 38 pairs (END 0, INNER 38). Words: hoes, told, ho, know, folks, show, don't, home.
4. `slant:AA:stop` — 22 pairs (END 3, INNER 19). Words: hop, got, glock, not, guard, part, lot, harmed.
5. `vow:AE` — 22 pairs (END 4, INNER 18). Words: fast, tags, havin, bank, rappers, swag, last, cash.
6. `slant:AY:nas-stop` — 18 pairs (END 1, INNER 17). Words: kind, mine, died, iron, ridin, outside, fine, pride.
7. `slant:AE:sib-stop` — 17 pairs (END 8, INNER 9). Words: gas, swag, tags, cash, lag, jag, bag, last.
8. `slant:IY:liq-sib` — 16 pairs (END 5, INNER 11). Words: feel, these, wheels, wheel, appeals, real, deal.
9. `cmu:AE-G` — 11 pairs (END 3, INNER 8). Words: bag, lag, swag, jag.
10. `slant:AA:nas-stop` — 10 pairs (END 3, INNER 7). Words: arm, charm, charmed, harmed, alarmed, guard, gotta, wanna.
11. `vow:AA` — 10 pairs (END 2, INNER 8). Words: chargers, got, not, cars, harmed, star, glock, hot.
12. `slant:IH:liq-sib` — 8 pairs (END 2, INNER 6). Words: mille, still, drills, chills, pills, bitch, spill.
13. `slant:IH:liq-stop` — 8 pairs (END 3, INNER 5). Words: mille, big, spill, killed, lip, still, clip, year.
14. `cmu:AA-T` — 7 pairs (END 3, INNER 4). Words: not, got, lot, hot, bought.
15. `slant:EH:stop` — 7 pairs (END 0, INNER 7). Words: twenty, get, went, temp, respect.
16. `vow:EH` — 7 pairs (END 0, INNER 7). Words: get, let, pedal, stairs, twenty, myself, temp, checks.
17. `cmu:IY-L` — 6 pairs (END 3, INNER 3). Words: wheel, feel, deal, real.
18. `cmu:OW` — 6 pairs (END 0, INNER 6). Words: ho, know, show.
19. `slant:AY:fric-stop` — 6 pairs (END 0, INNER 6). Words: life, alive, died, outside, pride, hide, write, fight.
20. `slant:AY:stop` — 6 pairs (END 2, INNER 4). Words: write, hide, fight, excited, pride, like, might.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- swag — 15 pair sides, mostly spelling via spelling phonetic key, often with bag (2)
- jag — 7 pair sides, mostly spelling via spelling phonetic key, often with swag (2)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with feel (1)
- herbo — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- doin — 2 pair sides, mostly spelling via spelling phonetic key, often with goin (2)
- niggas — 1 pair sides, mostly vowel via spelling phonetic key, often with richard (1)
- hoodie — 1 pair sides, mostly spelling via spelling phonetic key, often with rookie (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Rico Beats | Real Spill | 43 | 56 | 378 | loose |
