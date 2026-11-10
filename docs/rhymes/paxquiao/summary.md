# Paxquiao rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Paxquiao
- Songs: 2
- Bars kept (Paxquiao lyric lines): 76
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Paxquiao.
- Credit strings: Paxquiao.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 405
- REPEAT pairs, recorded separately: 44
- END rhymes: 71
- INNER rhymes: 334

By match:

- PERFECT: 34 (END 5, INNER 29)
- SLANT: 192 (END 36, INNER 156)
- ASSONANCE: 174 (END 28, INNER 146)
- MULTI: 5 (END 2, INNER 3)

By confidence:

- HIGH: 39
- MED: 338
- LOW: 28

## Core

- Core Y: 397
- Core N among rhyme pairs: 8

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 206 (50.9%)
- vowel: 174 (43.0%)
- spelling: 20 (4.9%)
- multi: 5 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 44 pairs (END 5, INNER 39). Words: bitch, livin, linen, digits, tinted, windows, chinchilla, big.
2. `vow:OW` — 33 pairs (END 11, INNER 22). Words: told, don't, no, know, phony, focus, rose, showed.
3. `slant:AY:sib-stop` — 23 pairs (END 4, INNER 19). Words: price, right, ice, like, dice, bright, sprite, tonight.
4. `vow:EH` — 22 pairs (END 1, INNER 21). Words: get, expensive, spend, benefits, hell, rented, gettin, trenches.
5. `vow:AA` — 21 pairs (END 5, INNER 16). Words: nothin, darkness, arson, block, helicopter, chopper, doctor, got.
6. `vow:EY` — 18 pairs (END 0, INNER 18). Words: ain't, make, patience, day, stay, faith, strangers, neighbors.
7. `slant:AA:stop` — 12 pairs (END 1, INNER 11). Words: block, chopper, helicopter, lot, doctor, stop, popped, gotta.
8. `vow:AE` — 12 pairs (END 6, INNER 6). Words: bag, can't, fast, fallin, ballin, catchin, brackin, traffic.
9. `vow:AY` — 11 pairs (END 0, INNER 11). Words: popeye, find, like, slidin, by, time, dyke, ice.
10. `slant:EH:liq-stop` — 10 pairs (END 0, INNER 10). Words: get, forget, hell, canary, solitaire, dare, better, cherry.
11. `slant:EH:stop` — 10 pairs (END 3, INNER 7). Words: plenty, spend, rented, get, bend, better, perfect.
12. `slant:IH:sib-stop` — 10 pairs (END 3, INNER 7). Words: niggas, nigga, bitch, big, miss, switch, hit, shit.
13. `slant:AY:stop` — 9 pairs (END 1, INNER 8). Words: like, right, bright, light, sprite, tonight.
14. `vow:AH` — 9 pairs (END 0, INNER 9). Words: brother, ones, fuckin, double, oven, fuck, runnin, tucked.
15. `cmu:AY-T` — 7 pairs (END 1, INNER 6). Words: right, tonight, sprite, bright.
16. `slant:EY:stop` — 7 pairs (END 0, INNER 7). Words: hate, ain't, wait, snake, fake, fade, eight, baby.
17. `slant:AH:nas-stop` — 6 pairs (END 0, INNER 6). Words: fuck, money, what, done, some.
18. `slant:IH:stop` — 6 pairs (END 0, INNER 6). Words: nigga, sip, pick, hit, shit, big, think.
19. `slant:AA:sib-stop` — 5 pairs (END 1, INNER 4). Words: knots, cops, got, stop, popped, lot.
20. `slant:AH:nas` — 5 pairs (END 0, INNER 5). Words: run, runnin, fuckin, oven, done, money.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 8 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- niggas — 6 pair sides, mostly vowel via spelling phonetic key, often with chinchilla (3)
- homie — 5 pair sides, mostly spelling via spelling phonetic key, often with showed (2)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with turn (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- partment — 2 pair sides, mostly vowel via spelling phonetic key, often with pocket (1)
- thot — 1 pair sides, mostly vowel via spelling phonetic key, often with told (1)
- juggs — 1 pair sides, mostly vowel via spelling phonetic key, often with much (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Paxquiao | In Hell with a Chinchilla | 45 | 43 | 137 | loose |
| Paxquiao | Neva Fallin | 31 | 28 | 197 | loose |
