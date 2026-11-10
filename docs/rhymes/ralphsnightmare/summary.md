# Ralphsnightmare rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Ralphsnightmare
- Songs: 1
- Bars kept (Ralphsnightmare lyric lines): 28
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Ralphsnightmare.
- Credit strings: Ralphsnightmare.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 211
- REPEAT pairs, recorded separately: 54
- END rhymes: 39
- INNER rhymes: 172

By match:

- PERFECT: 28 (END 8, INNER 20)
- SLANT: 103 (END 22, INNER 81)
- ASSONANCE: 80 (END 9, INNER 71)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 28
- MED: 181
- LOW: 2

## Core

- Core Y: 211
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 129 (61.1%)
- vowel: 80 (37.9%)
- spelling: 2 (0.9%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 21 pairs (END 0, INNER 21). Words: told, going, no, glo, control, dope, rolling, know.
2. `cmu:OW` — 13 pairs (END 0, INNER 13). Words: no, know, glo, show, slow, glow.
3. `vow:EY` — 13 pairs (END 0, INNER 13). Words: ain't, make, cases, came, name, chains, may, showcase.
4. `slant:AA:stop` — 12 pairs (END 0, INNER 12). Words: not, drop, pocket, lot, glock, hop, hopped, got.
5. `slant:EY:nas-sib` — 12 pairs (END 12, INNER 0). Words: pace, face, came, showcase, lane, game, name.
6. `slant:EH:nas-stop` — 10 pairs (END 0, INNER 10). Words: get, many, went, when, ten, bet, getting, send.
7. `slant:EY:nas` — 10 pairs (END 3, INNER 7). Words: name, wayne, came, lane, brain, game.
8. `vow:AA` — 9 pairs (END 0, INNER 9). Words: tops, got, cars, car, hopped, not, lot, pocket.
9. `vow:IH` — 9 pairs (END 0, INNER 9). Words: bitch, hits, since, killing, windows, dick, everything, give.
10. `vow:UW` — 9 pairs (END 9, INNER 0). Words: two, soup, juice, boot, roof, truth.
11. `cmu:EY-M` — 5 pairs (END 5, INNER 0). Words: name, game, came.
12. `slant:AA:liq-stop` — 5 pairs (END 0, INNER 5). Words: car, lot, not, hop, got.
13. `vow:AW` — 5 pairs (END 0, INNER 5). Words: how, ounces, thousand, down.
14. `slant:AH:nas-stop` — 4 pairs (END 0, INNER 4). Words: some, suck.
15. `slant:EH:liq-nas` — 4 pairs (END 0, INNER 4). Words: many, square.
16. `slant:IH:liq-sib` — 4 pairs (END 0, INNER 4). Words: bitch, lil, still.
17. `slant:IH:sib-stop` — 4 pairs (END 0, INNER 4). Words: bitch, dick.
18. `vow:EH` — 4 pairs (END 0, INNER 4). Words: send, getting, when, bet, get.
19. `cmu:EY-S` — 3 pairs (END 3, INNER 0). Words: showcase, face, pace.
20. `slant:AE:nas-sib` — 3 pairs (END 0, INNER 3). Words: gang, man, catch, ass, pass.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- None.

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Ralphsnightmare | More Than 2 | 28 | 39 | 172 | loose |
