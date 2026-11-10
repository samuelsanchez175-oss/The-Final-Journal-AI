# Ray Vicks rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ray Vicks
- Songs: 1
- Bars kept (Ray Vicks lyric lines): 57
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Ray Vicks.
- Credit strings: Ray Vicks.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 364
- REPEAT pairs, recorded separately: 70
- END rhymes: 40
- INNER rhymes: 324

By match:

- PERFECT: 30 (END 7, INNER 23)
- SLANT: 166 (END 17, INNER 149)
- ASSONANCE: 168 (END 16, INNER 152)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 28
- MED: 326
- LOW: 10

## Core

- Core Y: 364
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 184 (50.5%)
- vowel: 168 (46.2%)
- spelling: 12 (3.3%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 66 pairs (END 0, INNER 66). Words: fifty, bitch, missed, him, will, years, since, hitters.
2. `slant:IH:stop` — 45 pairs (END 0, INNER 45). Words: fifty, missed, shit, mixed, pissed, wrist, nigga, zip.
3. `vow:EY` — 36 pairs (END 7, INNER 29). Words: change, play, day, ain't, hatin, paid, break, days.
4. `vow:AO` — 14 pairs (END 7, INNER 7). Words: lost, lord, morning, calls, all, ball, call, jaws.
5. `vow:EH` — 13 pairs (END 0, INNER 13). Words: get, sellin, send, gettin, less, yellow, spend, never.
6. `vow:OW` — 11 pairs (END 0, INNER 11). Words: phone, know, told, totin, don't, home, shows, hopin.
7. `slant:EY:sib-stop` — 10 pairs (END 4, INNER 6). Words: paid, days, k's, plays, break, take.
8. `vow:AH` — 9 pairs (END 0, INNER 9). Words: fucked, jumpin, done, hustlin, money, run, tons, hundred.
9. `vow:AY` — 9 pairs (END 1, INNER 8). Words: like, mind, hiding, crime, nine, iced.
10. `slant:IH:sib-stop` — 8 pairs (END 0, INNER 8). Words: nigga, niggas, bitch, city, shit, nigga's, rich, hitters.
11. `slant:AH:nas-sib` — 7 pairs (END 0, INNER 7). Words: plus, tons, run, judge, done, some, money.
12. `slant:AO:liq-sib` — 7 pairs (END 2, INNER 5). Words: calls, ball, jaws, all, call.
13. `vow:AE` — 7 pairs (END 1, INNER 6). Words: nigga, last, trap, can't, man, had, cash, bag.
14. `cmu:AH-N` — 6 pairs (END 1, INNER 5). Words: done, none, one, run.
15. `cmu:IH-S-T` — 6 pairs (END 0, INNER 6). Words: missed, pissed, wrist.
16. `slant:AY:nas-stop` — 6 pairs (END 0, INNER 6). Words: like, nine, crime, mind.
17. `slant:EY:stop` — 6 pairs (END 2, INNER 4). Words: break, paid, state, weight, take.
18. `slant:AE:stop` — 5 pairs (END 0, INNER 5). Words: bank, back, had, bag, can't, bad, band.
19. `slant:EH:fric-stop` — 5 pairs (END 0, INNER 5). Words: get, never, every.
20. `slant:AA:stop` — 4 pairs (END 0, INNER 4). Words: got, dropped, pop.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with home (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with thing (2)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ray Vicks | 50 Missed Calls | 57 | 40 | 324 | loose |
