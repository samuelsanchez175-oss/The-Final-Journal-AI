# Jimin (지민) rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Jimin (지민)
- Songs: 1
- Bars kept (Jimin (지민) lyric lines): 41
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Jimin (지민).
- Credit strings: Jimin (지민).
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 209
- REPEAT pairs, recorded separately: 23
- END rhymes: 24
- INNER rhymes: 185

By match:

- PERFECT: 18 (END 3, INNER 15)
- SLANT: 80 (END 9, INNER 71)
- ASSONANCE: 108 (END 11, INNER 97)
- MULTI: 3 (END 1, INNER 2)

By confidence:

- HIGH: 21
- MED: 187
- LOW: 1

## Core

- Core Y: 209
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 97 (46.4%)
- vowel: 108 (51.7%)
- spelling: 1 (0.5%)
- multi: 3 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 24 pairs (END 3, INNER 21). Words: day, ain't, way, game, take, cake, pain, generation.
2. `vow:EH` — 22 pairs (END 3, INNER 19). Words: end, never, jets, blessings, get, heaven, perfect, flesh.
3. `vow:OW` — 18 pairs (END 4, INNER 14). Words: don't, know, road, souls, close, those, own, goals.
4. `vow:IH` — 15 pairs (END 0, INNER 15). Words: risk, givens, middle, whip, give, 'til, still, whisper.
5. `vow:AA` — 11 pairs (END 0, INNER 11). Words: droppin, heart, watching, harm's, bodies, gonna, god, body.
6. `slant:EH:fric-stop` — 7 pairs (END 1, INNER 6). Words: let, never, ever, fled, set, get.
7. `vow:AE` — 6 pairs (END 0, INNER 6). Words: family, fast, matter, bang, hang, can, dash, have.
8. `slant:EH:sib-stop` — 5 pairs (END 0, INNER 5). Words: jets, let, set, flesh.
9. `slant:EY:nas-stop` — 5 pairs (END 0, INNER 5). Words: take, pain, game, break, same.
10. `cmu:OW` — 4 pairs (END 1, INNER 3). Words: no, go, know.
11. `slant:AH:sib-stop` — 4 pairs (END 2, INNER 2). Words: truck, brother, other, what.
12. `vow:AH` — 4 pairs (END 0, INNER 4). Words: ugly, truck, brother, what, other.
13. `cmu:EY` — 3 pairs (END 1, INNER 2). Words: way, day, betray, away.
14. `slant:AA:stop` — 3 pairs (END 0, INNER 3). Words: want, not, god, body.
15. `slant:AY:sib-stop` — 3 pairs (END 0, INNER 3). Words: ties, like, why’d, mind, signs.
16. `slant:EH:fric-liq` — 3 pairs (END 0, INNER 3). Words: ever, where, devil.
17. `slant:EH:fric-nas` — 3 pairs (END 0, INNER 3). Words: when, ever, heaven, never.
18. `slant:EH:sib` — 3 pairs (END 3, INNER 0). Words: lessons, blessings, message.
19. `slant:EY:stop` — 3 pairs (END 1, INNER 2). Words: plate, cake, ain't, take.
20. `slant:OW:liq-stop` — 3 pairs (END 1, INNER 2). Words: soul, shoulder, told, road.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- None.

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Jimin (지민) | Angel Pt. 1 | 41 | 24 | 185 | loose |
