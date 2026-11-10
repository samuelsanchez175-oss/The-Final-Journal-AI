# Ye rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ye
- Songs: 1
- Bars kept (Ye lyric lines): 48
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Ye.
- Credit strings: Ye.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 390
- REPEAT pairs, recorded separately: 26
- END rhymes: 56
- INNER rhymes: 334

By match:

- PERFECT: 29 (END 8, INNER 21)
- SLANT: 148 (END 19, INNER 129)
- ASSONANCE: 212 (END 29, INNER 183)
- MULTI: 1 (END 0, INNER 1)

By confidence:

- HIGH: 30
- MED: 337
- LOW: 23

## Core

- Core Y: 385
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 159 (40.8%)
- vowel: 212 (54.4%)
- spelling: 18 (4.6%)
- multi: 1 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:UW` — 48 pairs (END 17, INNER 31). Words: funeral, beautiful, knew, superman, who, future, pharmaceuticals, roof.
2. `vow:EY` — 43 pairs (END 2, INNER 41). Words: ain't, make, day, pay, today, playin, saying, made.
3. `vow:EH` — 26 pairs (END 0, INNER 26). Words: empty, vest, never, let, 'jects, teflon, meant, messed.
4. `vow:IY` — 25 pairs (END 7, INNER 18). Words: pee, feeling, even, free, key, lean, these, meat.
5. `vow:IH` — 20 pairs (END 3, INNER 17). Words: drink, pimpin, shit, women, bitches, victim, bitch, thinkin.
6. `vow:AA` — 17 pairs (END 0, INNER 17). Words: got, talkin, dollars, dark, retarded, watch, fox, startin.
7. `vow:AY` — 13 pairs (END 0, INNER 13). Words: high, hi, right, time, fire, life, hide, sometimes.
8. `slant:UW:fric-sib` — 12 pairs (END 8, INNER 4). Words: bulletproof, loose, truth, booth, hoover, screws, future.
9. `slant:IH:nas-stop` — 10 pairs (END 0, INNER 10). Words: i'ma, dick, shit, slim, fit, win.
10. `slant:AA:stop` — 9 pairs (END 0, INNER 9). Words: got, heart, part, retarded, not, gotta, closet.
11. `slant:UW:sib` — 9 pairs (END 5, INNER 4). Words: loose, truth, booth, future, screws.
12. `slant:IH:sib-stop` — 8 pairs (END 0, INNER 8). Words: bitch, dick, shit, fit, things, think.
13. `slant:IY:sib-stop` — 7 pairs (END 0, INNER 7). Words: these, keep, yeezy, cheaper, feet, sweep.
14. `slant:OW:nas-stop` — 7 pairs (END 3, INNER 4). Words: cloned, woke, clone, phone, tone, own.
15. `vow:AE` — 7 pairs (END 0, INNER 7). Words: fantasies, back, can't, planning, jack, fallin.
16. `vow:OW` — 7 pairs (END 0, INNER 7). Words: know, hoes, don't, ho, own, over, owe.
17. `cmu:EY` — 6 pairs (END 1, INNER 5). Words: day, pay, today, everyday, way.
18. `slant:EH:liq-stop` — 6 pairs (END 0, INNER 6). Words: let, cell, already, tell, there, better, hell.
19. `slant:EH:stop` — 6 pairs (END 0, INNER 6). Words: let, step, tec, tech, dead, messed, already.
20. `slant:IH:nas-sib` — 6 pairs (END 0, INNER 6). Words: bitch, i'ma, slim, win.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 10 pair sides, mostly spelling via spelling phonetic key, often with bitch (4)
- tryna — 5 pair sides, mostly spelling via spelling phonetic key, often with freeze (1)
- jects — 4 pair sides, mostly vowel via spelling phonetic key, often with heffer (1)
- heffer — 3 pair sides, mostly vowel via spelling phonetic key, often with every (1)
- yeezy — 2 pair sides, mostly spelling via spelling phonetic key, often with sweep (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ye | BULLETPROOF | 48 | 56 | 334 | loose |
