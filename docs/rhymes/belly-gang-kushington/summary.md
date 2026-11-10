# Belly Gang Kushington rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Belly Gang Kushington
- Songs: 1
- Bars kept (Belly Gang Kushington lyric lines): 39
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Belly Gang Kushington.
- Credit strings: Belly Gang Kushington.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 312
- REPEAT pairs, recorded separately: 30
- END rhymes: 26
- INNER rhymes: 286

By match:

- PERFECT: 19 (END 6, INNER 13)
- SLANT: 167 (END 13, INNER 154)
- ASSONANCE: 126 (END 7, INNER 119)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 18
- MED: 274
- LOW: 20

## Core

- Core Y: 304
- Core N among rhyme pairs: 8

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 169 (54.2%)
- vowel: 126 (40.4%)
- spelling: 17 (5.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 49 pairs (END 6, INNER 43). Words: bitch, nipples, piercing, beneficial, pistol, gristle, period, nigga.
2. `vow:EH` — 34 pairs (END 0, INNER 34). Words: gettin, weekend, tellin, president, lemon, where, stepped, belt.
3. `slant:AH:nas-stop` — 12 pairs (END 0, INNER 12). Words: fuck, some, money, what, suckin, club, young, done.
4. `slant:IH:liq-stop` — 12 pairs (END 2, INNER 10). Words: still, shit, lil, brick, still'll, dick, sister, build.
5. `slant:IH:sib-stop` — 12 pairs (END 0, INNER 12). Words: bitch, nigga, niggas, drip, dick, shit, thick, lips.
6. `vow:AE` — 11 pairs (END 0, INNER 11). Words: ass, magic, can't, rappers, rapper, pallet, savage, strap.
7. `slant:AH:fric-stop` — 10 pairs (END 2, INNER 8). Words: stuff, fuck, what, bluff, club, love.
8. `slant:EH:stop` — 9 pairs (END 3, INNER 6). Words: president, stepped, belt, get, ghetto, let, pepper, slept.
9. `slant:IH:liq-sib` — 9 pairs (END 0, INNER 9). Words: bitch, lil, still, richer.
10. `vow:AY` — 9 pairs (END 0, INNER 9). Words: buy, times, right, might, like, tried, fine.
11. `slant:AE:sib-stop` — 8 pairs (END 0, INNER 8). Words: ass, cap, smack, crash, black, rapper, rappers.
12. `slant:IH:stop` — 8 pairs (END 0, INNER 8). Words: nigga, shit, drip, dick, city, brick, thick.
13. `vow:AH` — 8 pairs (END 0, INNER 8). Words: w, suckin, hundred, fuck, bluff, stuff, club, love.
14. `slant:AH:stop` — 7 pairs (END 0, INNER 7). Words: fuck, what, club, truck.
15. `slant:EH:liq-stop` — 6 pairs (END 0, INNER 6). Words: hair, ghetto, where, get, let, pepper, sell.
16. `slant:IH:liq` — 5 pairs (END 4, INNER 1). Words: beneficial, gristle, pistol, lil, still.
17. `vow:AO` — 5 pairs (END 1, INNER 4). Words: yawnin, all, morning, walk, afford.
18. `vow:UW` — 5 pairs (END 0, INNER 5). Words: shooters, who, threw, use.
19. `cmu:OY-N` — 4 pairs (END 2, INNER 2). Words: goin, ho'in, doin.
20. `slant:AE:stop` — 4 pairs (END 0, INNER 4). Words: magic, smack, black, can't, pallet, cap.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 14 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- niggas — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- finna — 4 pair sides, mostly vowel via spelling phonetic key, often with nigga (2)
- hoin — 3 pair sides, mostly spelling via spelling phonetic key, often with goin (2)
- doin — 2 pair sides, mostly spelling via spelling phonetic key, often with goin (1)
- shawty — 2 pair sides, mostly spelling via spelling phonetic key, often with fore (1)
- lamelo — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Belly Gang Kushington | WTF GOIN | 39 | 26 | 286 | loose |
