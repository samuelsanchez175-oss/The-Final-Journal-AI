# Healthy Chill rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Healthy Chill
- Songs: 1
- Bars kept (Healthy Chill lyric lines): 53
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Healthy Chill.
- Credit strings: Healthy Chill.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 418
- REPEAT pairs, recorded separately: 73
- END rhymes: 67
- INNER rhymes: 351

By match:

- PERFECT: 38 (END 24, INNER 14)
- SLANT: 196 (END 34, INNER 162)
- ASSONANCE: 182 (END 9, INNER 173)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 40
- MED: 350
- LOW: 28

## Core

- Core Y: 409
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 210 (50.2%)
- vowel: 182 (43.5%)
- spelling: 24 (5.7%)
- multi: 2 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 46 pairs (END 7, INNER 39). Words: sack, rappin, back, gangster, hands, rabbits, halfass, can't.
2. `slant:AE:stop` — 33 pairs (END 13, INNER 20). Words: sack, strap, back, bad, hat, rabbit, rap, can't.
3. `vow:IH` — 32 pairs (END 0, INNER 32). Words: give, wrist, bitch, big, sticks, think, fifty, sixty.
4. `slant:AA:stop` — 26 pairs (END 11, INNER 15). Words: popped, lot, chop, got, lock, rock, top, clock.
5. `vow:EY` — 25 pairs (END 0, INNER 25). Words: ain't, grenades, take, range, pay, baby, hatin, they'll.
6. `vow:OW` — 25 pairs (END 0, INNER 25). Words: know, don't, told, old, rovers, no, soda, explode.
7. `vow:AA` — 18 pairs (END 2, INNER 16). Words: bottom, talkin, honest, nothin, got, choppers, lot, robbery.
8. `vow:EH` — 16 pairs (END 0, INNER 16). Words: blessin, stressin, gettin, said, spent, fendi, bentley, get.
9. `slant:AE:sib-stop` — 13 pairs (END 6, INNER 7). Words: pass, sack, cash, back, hat, strap, bad, cats.
10. `slant:IH:stop` — 13 pairs (END 1, INNER 12). Words: nigga, chitter, quick, city, diddy, big, tick.
11. `cmu:AA-K` — 10 pairs (END 10, INNER 0). Words: lock, rock, tock, clock, glock.
12. `slant:AE:fric-stop` — 8 pairs (END 0, INNER 8). Words: half, have, sack, bad, back, pack.
13. `slant:IH:nas-stop` — 8 pairs (END 0, INNER 8). Words: i'ma, bring, chitter, city, twin, kiko, quick, diddy.
14. `vow:IY` — 8 pairs (END 0, INNER 8). Words: t, peewee, copperfield, three, need, nobody, feedin, clean.
15. `slant:AY:fric-sib` — 6 pairs (END 0, INNER 6). Words: life, twice, price.
16. `cmu:AE-K` — 5 pairs (END 1, INNER 4). Words: back, sack, crack, pack.
17. `slant:AA:nas-stop` — 5 pairs (END 1, INNER 4). Words: bottom, wanna, robbin, robbery, lot, got, not, lotta.
18. `slant:EH:stop` — 5 pairs (END 0, INNER 5). Words: get, said, fendi, spent, check, met, neck.
19. `slant:IH:sib-stop` — 5 pairs (END 0, INNER 5). Words: bitch, nigga, niggas, kiko, shit, big.
20. `cmu:AO-L` — 4 pairs (END 4, INNER 0). Words: all, wall.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with diddy (2)
- halfass — 7 pair sides, mostly vowel via spelling phonetic key, often with sack (1)
- sheetrock — 5 pair sides, mostly spelling via spelling phonetic key, often with tock (1)
- kiko — 5 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with quick (1)
- gasolina — 2 pair sides, mostly vowel via spelling phonetic key, often with crack (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with those (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Healthy Chill | Designer | 53 | 67 | 351 | loose |
