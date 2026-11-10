# S.Dot (Rapper) rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: S.Dot (Rapper)
- Songs: 1
- Bars kept (S.Dot (Rapper) lyric lines): 70
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: S.Dot (Rapper).
- Credit strings: S.Dot (Rapper).
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 299
- REPEAT pairs, recorded separately: 39
- END rhymes: 73
- INNER rhymes: 226

By match:

- PERFECT: 36 (END 10, INNER 26)
- SLANT: 125 (END 32, INNER 93)
- ASSONANCE: 137 (END 30, INNER 107)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 36
- MED: 249
- LOW: 14

## Core

- Core Y: 296
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 149 (49.8%)
- vowel: 137 (45.8%)
- spelling: 12 (4.0%)
- multi: 1 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 36 pairs (END 16, INNER 20). Words: hard, options, pocket, coughin, droppin, got, guard, spot.
2. `vow:IH` — 23 pairs (END 0, INNER 23). Words: big, sippin, dissin, drillin, drills, killed, drinkin, district.
3. `vow:IY` — 20 pairs (END 3, INNER 17). Words: z, east, feet, see, paparazzi, these, here, beat.
4. `vow:OW` — 20 pairs (END 0, INNER 20). Words: over, no, smokin, local, know, don't, showin, go.
5. `cmu:OW` — 13 pairs (END 4, INNER 9). Words: know, no, low, bro, blow, hoe, show, doe.
6. `vow:AW` — 11 pairs (END 4, INNER 7). Words: down, loud, rounds, pounds, broski, now.
7. `slant:AA:stop` — 9 pairs (END 0, INNER 9). Words: got, top, popped, stomp, zombie, og, block, spot.
8. `slant:AE:nas-stop` — 9 pairs (END 5, INNER 4). Words: man, back, can't, rack, trap, hat.
9. `slant:IH:sib-stop` — 9 pairs (END 3, INNER 6). Words: bitch, drilled, drills, pills, killed, shit, spit, crib.
10. `slant:AW:nas-stop` — 8 pairs (END 4, INNER 4). Words: down, around, loud.
11. `vow:AE` — 8 pairs (END 4, INNER 4). Words: bands, ballin, can't, rack, man, that'll, hands, bad.
12. `cmu:IY` — 6 pairs (END 0, INNER 6). Words: d, e, p, see.
13. `slant:AW:sib-stop` — 6 pairs (END 3, INNER 3). Words: around, rounds, pounds.
14. `slant:EH:liq-nas` — 6 pairs (END 0, INNER 6). Words: tell, when, 'nem, pelle.
15. `vow:EH` — 6 pairs (END 0, INNER 6). Words: get, myself, l's, let, together, every, gettin.
16. `slant:AH:nas-stop` — 5 pairs (END 0, INNER 5). Words: fuck, fucking, fuckin, come.
17. `vow:UW` — 5 pairs (END 1, INNER 4). Words: who, stupid, news, coupe, shoes, true.
18. `slant:EH:liq-stop` — 4 pairs (END 0, INNER 4). Words: tell, get, pelle, let.
19. `slant:EY:sib-stop` — 4 pairs (END 3, INNER 1). Words: face, take, played, made, paid.
20. `slant:IY:fric-stop` — 4 pairs (END 2, INNER 2). Words: beat, beef, chief, keef, feet.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nem — 5 pair sides, mostly spelling via spelling phonetic key, often with tell (2)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with sleep (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- edai — 2 pair sides, mostly spelling via spelling phonetic key, often with better (1)
- killas — 2 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)
- niggasll — 1 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| S.Dot (Rapper) | Hustle Hard (Remix) | 70 | 73 | 226 | loose |
