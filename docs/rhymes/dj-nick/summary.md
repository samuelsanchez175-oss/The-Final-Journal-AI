# DJ Nick rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DJ Nick
- Songs: 1
- Bars kept (DJ Nick lyric lines): 43
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DJ Nick.
- Credit strings: DJ Nick.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 167
- REPEAT pairs, recorded separately: 21
- END rhymes: 42
- INNER rhymes: 125

By match:

- PERFECT: 17 (END 9, INNER 8)
- SLANT: 72 (END 17, INNER 55)
- ASSONANCE: 73 (END 13, INNER 60)
- MULTI: 5 (END 3, INNER 2)

By confidence:

- HIGH: 20
- MED: 131
- LOW: 16

## Core

- Core Y: 163
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 75 (44.9%)
- vowel: 73 (43.7%)
- spelling: 14 (8.4%)
- multi: 5 (3.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 32 pairs (END 4, INNER 28). Words: whippin, bitch, listen, itchin, shits, finger, bitches, clippin.
2. `vow:IY` — 14 pairs (END 4, INNER 10). Words: piece, squeezin, actavis, feelin, identity, keep, b's, see.
3. `slant:ER:stop` — 10 pairs (END 6, INNER 4). Words: twerk, perc, skirt, squirt, heard, vert, dirt, lurk.
4. `slant:IH:nas-stop` — 8 pairs (END 3, INNER 5). Words: grip, whippin, kin, whip, dick, lick, trippin, clippin.
5. `slant:IH:sib-stop` — 8 pairs (END 0, INNER 8). Words: bitch, shit, dick, grip, shits, clip, nigga, niggas.
6. `cmu:ER-T` — 7 pairs (END 6, INNER 1). Words: squirt, skirt, vert, dirt.
7. `slant:IH:nas` — 6 pairs (END 3, INNER 3). Words: dissin, anything, sippin, sniffin, trippin, whippin, listen, clippin.
8. `slant:ER:liq-stop` — 5 pairs (END 0, INNER 5). Words: girl, skirt, squirt, twerk, perc.
9. `slant:IH:nas-sib` — 5 pairs (END 0, INNER 5). Words: chris, bitch, anything, i'ma, listen.
10. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: finger, virginity, whip, shit, dick, clip, grip, nigga.
11. `vow:AH` — 5 pairs (END 0, INNER 5). Words: compulsive, sucked, gun, huggin, guns, fuckin.
12. `slant:AA:liq-stop` — 4 pairs (END 3, INNER 1). Words: star, pot, glock, shock.
13. `vow:AA` — 4 pairs (END 4, INNER 0). Words: drops, pot, glock, star.
14. `vow:AE` — 4 pairs (END 0, INNER 4). Words: faggot, addie, ant, that'll, mad, thang, ass.
15. `vow:OW` — 4 pairs (END 0, INNER 4). Words: don't, know, phone, hold, hoe.
16. `cmu:ER-K` — 3 pairs (END 3, INNER 0). Words: twerk, perc, lurk.
17. `multi:IH-P-IH-NG` — 3 pairs (END 3, INNER 0). Words: trippin, whippin, clippin.
18. `slant:AA:stop` — 3 pairs (END 2, INNER 1). Words: pot, glock, shock.
19. `slant:AE:stop` — 3 pairs (END 0, INNER 3). Words: trap, bad, wack.
20. `vow:AO` — 3 pairs (END 0, INNER 3). Words: all, foreign, audi, forgi's.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- twerk — 8 pair sides, mostly spelling via spelling phonetic key, often with skirt (2)
- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- actavis — 3 pair sides, mostly vowel via vault phonetic_class, often with feelin (1)
- finessin — 2 pair sides, mostly vowel via spelling phonetic key, often with sippin (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- forgis — 1 pair sides, mostly vowel via spelling phonetic key, often with audi (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- pyrex — 1 pair sides, mostly vowel via spelling phonetic key, often with these (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DJ Nick | 187 | 43 | 42 | 125 | loose |
