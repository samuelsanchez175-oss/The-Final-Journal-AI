# Bandhunta Izzy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Bandhunta Izzy
- Songs: 4
- Bars kept (Bandhunta Izzy lyric lines): 138
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Bandhunta Izzy.
- Credit strings: Bandhunta Izzy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 944
- REPEAT pairs, recorded separately: 102
- END rhymes: 136
- INNER rhymes: 808

By match:

- PERFECT: 92 (END 8, INNER 84)
- SLANT: 388 (END 62, INNER 326)
- ASSONANCE: 454 (END 64, INNER 390)
- MULTI: 10 (END 2, INNER 8)

By confidence:

- HIGH: 96
- MED: 782
- LOW: 66

## Core

- Core Y: 933
- Core N among rhyme pairs: 11

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 418 (44.3%)
- vowel: 454 (48.1%)
- spelling: 62 (6.6%)
- multi: 10 (1.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 4 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 81 pairs (END 14, INNER 67). Words: get, stretchin, pedophiles, went, extended, credentials, checked, mental.
2. `vow:IY` — 64 pairs (END 13, INNER 51). Words: see, feast, creepin, t, need, seen, sheets, fiend.
3. `vow:EY` — 63 pairs (END 1, INNER 62). Words: ain't, same, play, say, make, take, baby, way.
4. `vow:AA` — 59 pairs (END 9, INNER 50). Words: want, shots, got, rottweiler, bark, party, top, glock.
5. `vow:IH` — 57 pairs (END 13, INNER 44). Words: shit, him, since, different, hit, film, quickly, stingy.
6. `vow:AY` — 40 pairs (END 6, INNER 34). Words: fly, might, like, mind, finest, die, violence, silent.
7. `vow:AE` — 38 pairs (END 5, INNER 33). Words: can, hands, can't, grams, strap, after, man, have.
8. `slant:AA:stop` — 36 pairs (END 6, INNER 30). Words: got, block, glock, top, popped, stop, doc, shot.
9. `vow:OW` — 34 pairs (END 3, INNER 31). Words: no, don't, know, throw, tote, told, magneto, brody.
10. `slant:EH:stop` — 30 pairs (END 1, INNER 29). Words: neck, reject, get, let, internet, wet, check, reck.
11. `slant:IH:stop` — 22 pairs (END 4, INNER 18). Words: nigga, shit, hit, sticky, chopstick, drippie, grip, tip.
12. `slant:AA:sib-stop` — 17 pairs (END 5, INNER 12). Words: cause, tops, got, drop, stop, ops, shots, shot.
13. `slant:IY:sib-stop` — 17 pairs (END 5, INNER 12). Words: eat, street, peace, sweeper, preach, teach, crease, knees.
14. `slant:AY:stop` — 16 pairs (END 1, INNER 15). Words: like, right, psychic, write, wide, mind, side, hide.
15. `slant:IY:stop` — 14 pairs (END 5, INNER 9). Words: eat, street, keep, sleep, creep, sweeper, deep, feast.
16. `slant:EH:fric-stop` — 13 pairs (END 0, INNER 13). Words: whenever, whoever, head, bed, said, dead, never, lead.
17. `slant:IH:nas-stop` — 12 pairs (END 3, INNER 9). Words: him, hit, sticky, big, everything, texting, shit, thing.
18. `slant:IH:nas` — 11 pairs (END 1, INNER 10). Words: imma, him, everything, ring, missing, christion, thing, skin.
19. `cmu:EH-D` — 10 pairs (END 0, INNER 10). Words: head, dead, lead, said.
20. `cmu:OW` — 10 pairs (END 0, INNER 10). Words: no, know, throw, though, go.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 20 pair sides, mostly spelling via spelling phonetic key, often with shit (5)
- gon — 9 pair sides, mostly spelling via spelling phonetic key, often with phone (2)
- imma — 8 pair sides, mostly spelling via spelling phonetic key, often with everything (3)
- fendy — 5 pair sides, mostly vowel via spelling phonetic key, often with quickly (1)
- tryna — 5 pair sides, mostly spelling via spelling phonetic key, often with even (1)
- drippie — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- ima — 4 pair sides, mostly vowel via vault phonetic_class, often with pronto (1)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- lames — 4 pair sides, mostly vowel via vault phonetic_class, often with keep (2)
- magneto — 3 pair sides, mostly vowel via spelling phonetic key, often with pronto (1)
- honchos — 3 pair sides, mostly vowel via spelling phonetic key, often with broncos (1)
- quickies — 2 pair sides, mostly spelling via spelling phonetic key, often with quickly (1)
- christion — 2 pair sides, mostly spelling via spelling phonetic key, often with missing (1)
- vickeys — 2 pair sides, mostly spelling via spelling phonetic key, often with quickly (1)
- blicky — 2 pair sides, mostly vowel via vault phonetic_class, often with feel (1)
- baddest — 2 pair sides, mostly vowel via spelling phonetic key, often with mattress (1)
- stroak — 2 pair sides, mostly spelling via spelling phonetic key, often with gon (1)
- drac — 2 pair sides, mostly spelling via spelling phonetic key, often with can (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with drippie (1)
- squeez — 1 pair sides, mostly spelling via spelling phonetic key, often with feel (1)
- calone — 1 pair sides, mostly spelling via spelling phonetic key, often with can (1)
- glizzy — 1 pair sides, mostly spelling via spelling phonetic key, often with things (1)
- glocks — 1 pair sides, mostly spelling via spelling phonetic key, often with blocks (1)
- fentanyl — 1 pair sides, mostly vowel via spelling phonetic key, often with ready (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Bandhunta Izzy | Fly Nigga | 37 | 27 | 125 | loose |
| Bandhunta Izzy | Have It All | 33 | 18 | 171 | loose |
| Bandhunta Izzy | Keeping Pace | 35 | 50 | 280 | loose |
| Bandhunta Izzy | Made Me | 33 | 41 | 232 | loose |
