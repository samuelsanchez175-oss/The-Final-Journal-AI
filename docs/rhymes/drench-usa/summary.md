# Drench (USA) rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Drench (USA)
- Songs: 2
- Bars kept (Drench (USA) lyric lines): 105
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Drench (USA).
- Credit strings: Drench (USA).
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 575
- REPEAT pairs, recorded separately: 56
- END rhymes: 111
- INNER rhymes: 464

By match:

- PERFECT: 68 (END 26, INNER 42)
- SLANT: 289 (END 43, INNER 246)
- ASSONANCE: 211 (END 37, INNER 174)
- MULTI: 7 (END 5, INNER 2)

By confidence:

- HIGH: 71
- MED: 471
- LOW: 33

## Core

- Core Y: 569
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 326 (56.7%)
- vowel: 211 (36.7%)
- spelling: 31 (5.4%)
- multi: 7 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 32 pairs (END 3, INNER 29). Words: ain't, basics, bail, day, play, stay, say, brakin.
2. `vow:OW` — 30 pairs (END 5, INNER 25). Words: know, soul, flow, old, opps, don't, go, most.
3. `vow:AY` — 29 pairs (END 12, INNER 17). Words: slide, fried, like, lightning, try, sky, tired, die.
4. `vow:AE` — 26 pairs (END 3, INNER 23). Words: can't, blast, last, bag, jam, ask, rap, back.
5. `slant:AE:sib-stop` — 25 pairs (END 5, INNER 20). Words: bad, bag, raps, catch, ass, pass, rap, straps.
6. `vow:IH` — 24 pairs (END 1, INNER 23). Words: didn't, bitch, him, sins, spin, hit, little, bitches.
7. `vow:IY` — 20 pairs (END 8, INNER 12). Words: field, tee, cleats, deep, sleep, three, reason, hear.
8. `slant:EH:nas-stop` — 18 pairs (END 1, INNER 17). Words: again, already, get, wet, em, when, twenty, many.
9. `vow:EH` — 18 pairs (END 1, INNER 17). Words: left, let's, again, pressed, when, get, drench, dead.
10. `vow:AH` — 17 pairs (END 4, INNER 13). Words: run, love, ones, drum, dumped, muscle, guns, sus.
11. `slant:AE:nas-stop` — 15 pairs (END 0, INNER 15). Words: gang, back, jam, 8am, had, tan, bag, rap.
12. `slant:IH:liq-nas` — 14 pairs (END 0, INNER 14). Words: him, lil, kill, still, really, clear, rim, swim.
13. `slant:AA:stop` — 13 pairs (END 0, INNER 13). Words: got, want, glock, opp, body, gotta, everybody, alot.
14. `slant:IH:nas` — 12 pairs (END 0, INNER 12). Words: spin, sinnin, sin, him, winnin, win, spinnin.
15. `cmu:AA-T` — 11 pairs (END 0, INNER 11). Words: bought, got, alot, lot, headshot.
16. `vow:AA` — 11 pairs (END 0, INNER 11). Words: bodies, wanna, shots, glock, want, headshot, droppin, gotta.
17. `slant:AY:stop` — 10 pairs (END 5, INNER 5). Words: slide, like, tired, sight, indict, night, fried, strike.
18. `slant:AE:sib` — 9 pairs (END 3, INNER 6). Words: catch, spaz, trash, ass, pass.
19. `slant:IH:nas-sib` — 8 pairs (END 0, INNER 8). Words: bitch, spin, him, switch, sins, win, twin.
20. `cmu:IH-N` — 6 pairs (END 0, INNER 6). Words: spin, sin, win, dawgs, merchin, thuggin, twin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 13 pair sides, mostly spelling via spelling phonetic key, often with only (4)
- opps — 4 pair sides, mostly vowel via spelling phonetic key, often with know (3)
- drac — 4 pair sides, mostly spelling via spelling phonetic key, often with catch (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with tips (2)
- tryina — 2 pair sides, mostly spelling via spelling phonetic key, often with these (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with hit (2)
- 8am — 2 pair sides, mostly spelling via spelling phonetic key, often with rap (1)
- thuggin — 2 pair sides, mostly spelling via spelling phonetic key, often with merchin (1)
- homie — 2 pair sides, mostly spelling via spelling phonetic key, often with tony (1)
- dawgs — 1 pair sides, mostly cmu via vault phonetic_class, often with spin (1)
- blitzin — 1 pair sides, mostly vowel via spelling phonetic key, often with limit (1)
- merchin — 1 pair sides, mostly spelling via spelling phonetic key, often with thuggin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Drench (USA) | Bout It | 58 | 54 | 213 | loose |
| Drench (USA) | WYGD | 47 | 57 | 251 | loose |
