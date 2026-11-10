# TGUT rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: TGUT
- Songs: 1
- Bars kept (TGUT lyric lines): 50
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: TGUT.
- Credit strings: TGUT.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 319
- REPEAT pairs, recorded separately: 29
- END rhymes: 68
- INNER rhymes: 251

By match:

- PERFECT: 41 (END 19, INNER 22)
- SLANT: 116 (END 19, INNER 97)
- ASSONANCE: 160 (END 30, INNER 130)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 36
- MED: 277
- LOW: 6

## Core

- Core Y: 319
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 144 (45.1%)
- vowel: 160 (50.2%)
- spelling: 13 (4.1%)
- multi: 2 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 38 pairs (END 7, INNER 31). Words: bitches, bitch, quilt, stitches, crip, bricks, whip, prince.
2. `vow:IY` — 36 pairs (END 14, INNER 22). Words: bleedin, jesus, beat, seasons, reefer, g, leave, complete.
3. `vow:OW` — 24 pairs (END 9, INNER 15). Words: don't, loafs, know, dope, show, coke, kokomo, tokyo.
4. `slant:AE:nas-stop` — 17 pairs (END 4, INNER 13). Words: man, tan, can't, grand, back, indiana, gang, trap.
5. `cmu:OW` — 14 pairs (END 9, INNER 5). Words: know, though, bro, show, kokomo, tokyo, blow, no.
6. `vow:AA` — 13 pairs (END 0, INNER 13). Words: chopper's, talkin, got, artist, start, allah, pablo, juan.
7. `vow:AH` — 11 pairs (END 0, INNER 11). Words: fuck, hundred, running, puzzle, money, come, other, butter.
8. `vow:EY` — 11 pairs (END 0, INNER 11). Words: racist, ain't, chains, race, slave, haters, take, days.
9. `vow:EH` — 10 pairs (END 0, INNER 10). Words: best, mentally, sellin, remember, get, gettin, ever, unless.
10. `slant:AA:stop` — 9 pairs (END 5, INNER 4). Words: got, robbed, god, start, mob, slob, not, chopper.
11. `cmu:AE-N` — 7 pairs (END 7, INNER 0). Words: tan, man.
12. `slant:IY:sib` — 7 pairs (END 6, INNER 1). Words: seasons, jesus, pieces, leases, nieces, police.
13. `slant:AH:nas-stop` — 6 pairs (END 0, INNER 6). Words: money, fuck, what, come, butter, muddy.
14. `vow:AY` — 6 pairs (END 0, INNER 6). Words: lie, times, designer, like, iced, writin, rhymes.
15. `slant:AH:stop` — 5 pairs (END 0, INNER 5). Words: fuck, muddy, fucked, what, butter, blunt.
16. `slant:OW:stop` — 5 pairs (END 0, INNER 5). Words: coke, dope.
17. `vow:AE` — 5 pairs (END 0, INNER 5). Words: back, rap, grand, can't, racks, trap, havin, fans.
18. `cmu:AE-G` — 4 pairs (END 0, INNER 4). Words: swag, bag, sag.
19. `slant:IH:nas-stop` — 4 pairs (END 0, INNER 4). Words: him, whip, crip, hip, stick.
20. `vow:UW` — 4 pairs (END 0, INNER 4). Words: soon, true, shoes, shoot, blue, few, two.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- swag — 4 pair sides, mostly spelling via spelling phonetic key, often with bag (2)
- geewee — 2 pair sides, mostly spelling via spelling phonetic key, often with free (2)
- bape — 1 pair sides, mostly spelling via spelling phonetic key, often with indiana (1)
- blooda — 1 pair sides, mostly spelling via spelling phonetic key, often with used (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with houston (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with hear (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| TGUT | MONEYMAN | 50 | 68 | 251 | loose |
