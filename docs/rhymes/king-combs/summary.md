# King Combs rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: King Combs
- Songs: 2
- Bars kept (King Combs lyric lines): 68
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: King Combs.
- Credit strings: King Combs.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 321
- REPEAT pairs, recorded separately: 59
- END rhymes: 35
- INNER rhymes: 286

By match:

- PERFECT: 28 (END 7, INNER 21)
- SLANT: 157 (END 12, INNER 145)
- ASSONANCE: 131 (END 15, INNER 116)
- MULTI: 5 (END 1, INNER 4)

By confidence:

- HIGH: 29
- MED: 272
- LOW: 20

## Core

- Core Y: 310
- Core N among rhyme pairs: 11

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 174 (54.2%)
- vowel: 131 (40.8%)
- spelling: 11 (3.4%)
- multi: 5 (1.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 33 pairs (END 4, INNER 29). Words: one, luxury, comfortably, blunts, brushin, fucked, some, done.
2. `vow:EY` — 28 pairs (END 0, INNER 28). Words: megan, haters, main, changed, same, always, ain't, baby.
3. `slant:AH:nas-stop` — 16 pairs (END 2, INNER 14). Words: one, what, suck, money, done, manhunt, come, fuck.
4. `vow:OW` — 15 pairs (END 6, INNER 9). Words: lambo, ho, don't, coke, rover, no, though, smoke.
5. `slant:IH:liq-sib` — 13 pairs (END 0, INNER 13). Words: bitch, lil, still, rich.
6. `vow:AE` — 13 pairs (END 0, INNER 13). Words: bad, can't, ask, stashed, montana, man, last, and1.
7. `vow:IH` — 12 pairs (END 2, INNER 10). Words: bitch, extinguished, killed, brinks, bricks, dick, rich, window.
8. `slant:EY:nas-sib` — 11 pairs (END 0, INNER 11). Words: th, same, main, always, playin, range, game.
9. `slant:AE:stop` — 10 pairs (END 0, INNER 10). Words: bad, can't, last, yak, throwback, fab, addy, ask.
10. `slant:AY:stop` — 10 pairs (END 0, INNER 10). Words: like, might, light, snipe, sniper, side.
11. `vow:AA` — 9 pairs (END 2, INNER 7). Words: problems, bottom, swallow, talkin, prada, not, want, car.
12. `vow:EH` — 9 pairs (END 0, INNER 9). Words: text, sent, remember, better, dele, where, n, bartender.
13. `slant:AH:stop` — 8 pairs (END 1, INNER 7). Words: fucked, truck, slut, what, sub, manhunt, suck.
14. `vow:AY` — 8 pairs (END 0, INNER 8). Words: silence, fire, like, might, sniper, eyes, drive, light.
15. `cmu:OW` — 6 pairs (END 3, INNER 3). Words: ho, rainbow, radio, know, no, though.
16. `slant:IH:sib-stop` — 6 pairs (END 0, INNER 6). Words: dick, bitch, rich, video, busy, big, chris, hit.
17. `slant:AE:nas-stop` — 5 pairs (END 0, INNER 5). Words: man, back, had, bad, montana, yak.
18. `slant:EH:fric-stop` — 5 pairs (END 0, INNER 5). Words: every, better, heavy, get, steady, let.
19. `slant:EY:nas-stop` — 5 pairs (END 0, INNER 5). Words: main, baby, haiti, chain, ain't.
20. `slant:IH:liq-stop` — 5 pairs (END 0, INNER 5). Words: lil, dick, killed, still.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- lambo — 6 pair sides, mostly vowel via spelling phonetic key, often with ho (2)
- dele — 5 pair sides, mostly spelling via spelling phonetic key, often with heavy (1)
- risha — 2 pair sides, mostly multi via spelling phonetic key, often with keisha (2)
- keisha — 2 pair sides, mostly multi via spelling phonetic key, often with risha (2)
- and1 — 2 pair sides, mostly spelling via spelling phonetic key, often with aint (1)
- guapanese — 2 pair sides, mostly vowel via spelling phonetic key, often with some (2)
- kyrie — 2 pair sides, mostly spelling via spelling phonetic key, often with week (1)
- yac — 2 pair sides, mostly spelling via spelling phonetic key, often with mean (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| King Combs | Can’t Stop Won’t Stop | 40 | 26 | 177 | loose |
| King Combs | Can’t Stop Won’t Stop (Remix) | 28 | 9 | 109 | loose |
