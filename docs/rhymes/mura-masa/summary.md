# Mura Masa rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Mura Masa
- Songs: 1
- Bars kept (Mura Masa lyric lines): 26
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Mura Masa.
- Credit strings: Mura Masa.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 131
- REPEAT pairs, recorded separately: 14
- END rhymes: 20
- INNER rhymes: 111

By match:

- PERFECT: 23 (END 10, INNER 13)
- SLANT: 44 (END 4, INNER 40)
- ASSONANCE: 64 (END 6, INNER 58)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 23
- MED: 108
- LOW: 0

## Core

- Core Y: 131
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 67 (51.1%)
- vowel: 64 (48.9%)
- spelling: 0 (0.0%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 38 pairs (END 6, INNER 32). Words: know, don't, froze, almost, go, road, told, own.
2. `vow:EH` — 13 pairs (END 0, INNER 13). Words: best, messed, when, end, friend, boyfriend, step, get.
3. `cmu:OW` — 8 pairs (END 3, INNER 5). Words: know, grow, go, no.
4. `cmu:EH-R` — 6 pairs (END 3, INNER 3). Words: care, air, there, pair.
5. `slant:EH:nas-stop` — 6 pairs (END 0, INNER 6). Words: when, end, friend, boyfriend.
6. `slant:EH:liq-stop` — 5 pairs (END 0, INNER 5). Words: get, care, air, there, pair, tell, said.
7. `vow:AY` — 5 pairs (END 0, INNER 5). Words: cry, find, by, sometimes, right, time, fighting, arrive.
8. `slant:EH:liq-sib` — 4 pairs (END 3, INNER 1). Words: tears, care, air, there, pair.
9. `cmu:EH-N-D` — 3 pairs (END 3, INNER 0). Words: end, friend, boyfriend.
10. `slant:AA:stop` — 3 pairs (END 0, INNER 3). Words: not, want, part.
11. `slant:AE:nas-stop` — 3 pairs (END 0, INNER 3). Words: can, bad, had, can't.
12. `slant:AH:fric-nas` — 3 pairs (END 0, INNER 3). Words: love, someone, one.
13. `slant:OW:stop` — 3 pairs (END 0, INNER 3). Words: don't, most, almost, road, told.
14. `vow:AH` — 3 pairs (END 0, INNER 3). Words: someone, loved, love, somethin.
15. `slant:AH:fric-sib` — 2 pairs (END 0, INNER 2). Words: love, touch, another.
16. `slant:AH:nas-sib` — 2 pairs (END 0, INNER 2). Words: another, one, someone.
17. `slant:AY:liq-stop` — 2 pairs (END 0, INNER 2). Words: lifestyle, like, right.
18. `slant:EH:stop` — 2 pairs (END 0, INNER 2). Words: get, step, best.
19. `vow:AA` — 2 pairs (END 0, INNER 2). Words: wasn't, part, start.
20. `vow:IH` — 2 pairs (END 0, INNER 2). Words: will, think, things.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- None.

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Mura Masa | bbycakes | 26 | 20 | 111 | loose |
