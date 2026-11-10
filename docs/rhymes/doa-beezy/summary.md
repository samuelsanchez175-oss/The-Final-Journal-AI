# Doa Beezy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Doa Beezy
- Songs: 1
- Bars kept (Doa Beezy lyric lines): 47
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Doa Beezy.
- Credit strings: Doa Beezy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 277
- REPEAT pairs, recorded separately: 45
- END rhymes: 71
- INNER rhymes: 206

By match:

- PERFECT: 31 (END 7, INNER 24)
- SLANT: 144 (END 34, INNER 110)
- ASSONANCE: 97 (END 25, INNER 72)
- MULTI: 5 (END 5, INNER 0)

By confidence:

- HIGH: 34
- MED: 218
- LOW: 25

## Core

- Core Y: 267
- Core N among rhyme pairs: 10

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 156 (56.3%)
- vowel: 97 (35.0%)
- spelling: 19 (6.9%)
- multi: 5 (1.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:AA:stop` — 23 pairs (END 0, INNER 23). Words: got, block, pop, knocked, stop, not, popped, shot.
2. `vow:IY` — 21 pairs (END 6, INNER 15). Words: brazy, even, least, see, thirty, these, streets, police.
3. `vow:AW` — 19 pairs (END 12, INNER 7). Words: now, rounds, down, hours, round, drownin, house, frownin.
4. `slant:EH:liq-stop` — 17 pairs (END 0, INNER 17). Words: where, get, better, tell, bet.
5. `vow:AA` — 17 pairs (END 0, INNER 17). Words: hoppin, got, mamas, poppin, block, cause, not, knocked.
6. `slant:IH:liq-stop` — 14 pairs (END 4, INNER 10). Words: will, shit, kill, really, sit, lit, drilled, lil.
7. `vow:EH` — 13 pairs (END 0, INNER 13). Words: get, send, anybody, em, left, where, invented, getting.
8. `vow:IH` — 11 pairs (END 3, INNER 8). Words: chiraq, kids, innocents, shit, drilled, really, nigga, niggas.
9. `slant:AA:sib-stop` — 9 pairs (END 0, INNER 9). Words: cause, watch, got, block, pop, not, shots.
10. `slant:AE:stop` — 8 pairs (END 7, INNER 1). Words: cap, raq, adapt, clapped, whacked, back.
11. `slant:AW:nas-stop` — 8 pairs (END 5, INNER 3). Words: round, down, found, clownin, frownin, clout, drownin.
12. `slant:EH:stop` — 7 pairs (END 0, INNER 7). Words: better, get, left, bet.
13. `cmu:AA-T` — 6 pairs (END 0, INNER 6). Words: got, not, lot, shot.
14. `slant:AE:sib-stop` — 5 pairs (END 4, INNER 1). Words: apps, cap, clapped, adapt, raq, brazy.
15. `slant:IH:sib-stop` — 5 pairs (END 0, INNER 5). Words: niggas, nigga, shit, diss.
16. `vow:AY` — 5 pairs (END 1, INNER 4). Words: right, smilin, childish, die, wildin.
17. `cmu:IH-L` — 4 pairs (END 0, INNER 4). Words: will, kill, lil, still, until.
18. `slant:AW:nas-sib` — 4 pairs (END 2, INNER 2). Words: down, hours, house.
19. `slant:AW:sib-stop` — 4 pairs (END 2, INNER 2). Words: hours, rounds, clout, shout, round, found.
20. `slant:IY:stop` — 4 pairs (END 0, INNER 4). Words: deep, feet, heat, least.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- brazy — 9 pair sides, mostly vowel via spelling phonetic key, often with baby (2)
- raq — 7 pair sides, mostly spelling via spelling phonetic key, often with cap (2)
- niggas — 7 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- chiraq — 6 pair sides, mostly vowel via spelling phonetic key, often with raq (2)
- oppin — 2 pair sides, mostly cmu via vault phonetic_class, often with about (2)
- jumpout — 2 pair sides, mostly spelling via spelling phonetic key, often with clout (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Doa Beezy | Chiraq Baby | 47 | 71 | 206 | loose |
