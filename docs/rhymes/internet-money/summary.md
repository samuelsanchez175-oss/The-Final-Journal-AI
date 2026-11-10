# Internet Money rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Internet Money, Gunna & Don Toliver
- Songs: 1
- Bars kept (Internet Money lyric lines): 27
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Internet Money.
- Credit strings: Internet Money, Gunna & Don Toliver.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 146
- REPEAT pairs, recorded separately: 12
- END rhymes: 19
- INNER rhymes: 127

By match:

- PERFECT: 3 (END 2, INNER 1)
- SLANT: 67 (END 7, INNER 60)
- ASSONANCE: 72 (END 8, INNER 64)
- MULTI: 4 (END 2, INNER 2)

By confidence:

- HIGH: 7
- MED: 136
- LOW: 3

## Core

- Core Y: 146
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 67 (45.9%)
- vowel: 72 (49.3%)
- spelling: 3 (2.1%)
- multi: 4 (2.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 31 pairs (END 2, INNER 29). Words: gifted, bitches, risky, stick, it'll, bridges, missin, drippin.
2. `vow:EY` — 12 pairs (END 1, INNER 11). Words: ain't, hatin, grave, fame, paid, change, say, lemonade.
3. `vow:AH` — 10 pairs (END 5, INNER 5). Words: comfortably, nothing, some, disgusting, money, done, one.
4. `vow:EH` — 9 pairs (END 0, INNER 9). Words: gettin, never, checks, blessed, empty, remember.
5. `slant:AA:stop` — 7 pairs (END 0, INNER 7). Words: gotta, copped, god, hop, got.
6. `slant:AE:stop` — 6 pairs (END 0, INNER 6). Words: had, addy, bag, can't, thank, land, back.
7. `slant:EH:fric-stop` — 5 pairs (END 0, INNER 5). Words: never, neck, get, ever.
8. `slant:IH:liq-stop` — 4 pairs (END 0, INNER 4). Words: shit, still, filled, 'til, it'll, big.
9. `slant:UW:fric-stop` — 4 pairs (END 0, INNER 4). Words: coupe, roof.
10. `vow:AE` — 4 pairs (END 0, INNER 4). Words: had, can't, thank, back.
11. `vow:OW` — 4 pairs (END 0, INNER 4). Words: woke, old, don't.
12. `slant:AA:liq-stop` — 3 pairs (END 0, INNER 3). Words: rockstar, got, hop, gotta.
13. `slant:AH:nas-sib` — 3 pairs (END 1, INNER 2). Words: one, mother, much, money, brother.
14. `slant:AO:liq-stop` — 3 pairs (END 0, INNER 3). Words: dawg, war, more, walk.
15. `slant:EY:nas-stop` — 3 pairs (END 1, INNER 2). Words: plane, fame, paid, lemonade, make.
16. `slant:IH:sib-stop` — 3 pairs (END 0, INNER 3). Words: miss, risky, shit, big.
17. `multi:EH-V-ER` — 2 pairs (END 0, INNER 2). Words: ever, never, won't ever, i'll never.
18. `multi:IH-P-IH-NG` — 2 pairs (END 2, INNER 0). Words: drippin, trippin.
19. `slant:AH:nas` — 2 pairs (END 0, INNER 2). Words: some, money.
20. `slant:AY:liq-sib` — 2 pairs (END 0, INNER 2). Words: i'll, ice.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- dawg — 3 pair sides, mostly spelling via spelling phonetic key, often with more (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Internet Money, Gunna & Don Toliver | Lemonade | 27 | 19 | 127 | loose |
