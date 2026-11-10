# Tyga rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Tyga
- Songs: 2
- Bars kept (Tyga lyric lines): 88
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Tyga.
- Credit strings: Tyga.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 479
- REPEAT pairs, recorded separately: 65
- END rhymes: 60
- INNER rhymes: 419

By match:

- PERFECT: 55 (END 12, INNER 43)
- SLANT: 202 (END 27, INNER 175)
- ASSONANCE: 216 (END 20, INNER 196)
- MULTI: 6 (END 1, INNER 5)

By confidence:

- HIGH: 59
- MED: 378
- LOW: 42

## Core

- Core Y: 462
- Core N among rhyme pairs: 17

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 230 (48.0%)
- vowel: 216 (45.1%)
- spelling: 27 (5.6%)
- multi: 6 (1.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 66 pairs (END 10, INNER 56). Words: don't, no, both, show, go, know, told, toast.
2. `vow:AH` — 30 pairs (END 0, INNER 30). Words: motherfuckin, jumpin, hunnid, runnin, hunnids, bustin, touch, what.
3. `vow:IH` — 28 pairs (END 3, INNER 25). Words: things, mr, dripped, stitches, link, glizzy, bitch, shit.
4. `vow:UW` — 22 pairs (END 3, INNER 19). Words: juice, rumours, true, louis, through, boo, school, who.
5. `cmu:OW` — 17 pairs (END 1, INNER 16). Words: show, go, no, know, throw, hoe, solo, pro.
6. `slant:AA:stop` — 16 pairs (END 0, INNER 16). Words: got, drop, cock, chop, bobby, gotta, cost, hopped.
7. `slant:IH:nas-stop` — 16 pairs (END 1, INNER 15). Words: pick, slim, everything, big, fit, anything, spin, ring.
8. `slant:IH:stop` — 16 pairs (END 2, INNER 14). Words: shit, big, sticky, city, dripped, whip, pick, fit.
9. `vow:EY` — 14 pairs (END 1, INNER 13). Words: ain't, baby, lately, way, mail, freeway, same, makes.
10. `vow:IY` — 13 pairs (END 2, INNER 11). Words: see, need, streets, ceilings, beef, sneaky, glizzy, machine.
11. `slant:AY:nas-stop` — 12 pairs (END 2, INNER 10). Words: brighter, light, sunshine, time, nine, sign, tonight, like.
12. `slant:IH:nas-sib` — 11 pairs (END 4, INNER 7). Words: ring, bitch, things, dizzy, everything, thing.
13. `slant:IH:sib` — 9 pairs (END 5, INNER 4). Words: bitch, kiss, glizzy, dizzy, bitches, things.
14. `vow:AA` — 9 pairs (END 0, INNER 9). Words: got, drops, talkin, blonde, cock, chop, want, bobby.
15. `vow:AY` — 9 pairs (END 1, INNER 8). Words: like, diamonds, mind, ridin, sky, white, time, sight.
16. `slant:IH:sib-stop` — 8 pairs (END 1, INNER 7). Words: dizzy, shit, bitch, sticky, city, kiss, picky.
17. `slant:IY:liq-stop` — 7 pairs (END 0, INNER 7). Words: real, keep, need.
18. `vow:AE` — 7 pairs (END 0, INNER 7). Words: racks, bag, wang, swag, lamb, asked, have, alexander.
19. `cmu:AO-R` — 6 pairs (END 6, INNER 0). Words: adore, ignore, before, dior.
20. `cmu:EY` — 6 pairs (END 1, INNER 5). Words: way, play, freeway, hallway, foreplay, day.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- hunnid — 10 pair sides, mostly spelling via spelling phonetic key, often with hunnids (5)
- hunnids — 10 pair sides, mostly spelling via spelling phonetic key, often with hunnid (5)
- glizzy — 8 pair sides, mostly vowel via spelling phonetic key, often with whitney (1)
- swag — 7 pair sides, mostly spelling via spelling phonetic key, often with bag (2)
- tos — 4 pair sides, mostly spelling via spelling phonetic key, often with toast (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with both (1)
- nobu — 2 pair sides, mostly spelling via spelling phonetic key, often with hoes (1)
- soju — 2 pair sides, mostly spelling via spelling phonetic key, often with hoes (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with whip (1)
- karats — 1 pair sides, mostly vowel via spelling phonetic key, often with wang (1)
- papi — 1 pair sides, mostly spelling via spelling phonetic key, often with bag (1)
- locsta — 1 pair sides, mostly spelling via spelling phonetic key, often with poster (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Tyga | 100's | 43 | 25 | 225 | loose |
| Tyga | Sunshine | 45 | 35 | 194 | loose |
