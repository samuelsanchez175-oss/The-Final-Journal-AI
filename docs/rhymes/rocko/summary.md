# Rocko rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Rocko
- Songs: 1
- Bars kept (Rocko lyric lines): 36
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Rocko.
- Credit strings: Rocko.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 148
- REPEAT pairs, recorded separately: 42
- END rhymes: 27
- INNER rhymes: 121

By match:

- PERFECT: 7 (END 0, INNER 7)
- SLANT: 76 (END 17, INNER 59)
- ASSONANCE: 60 (END 7, INNER 53)
- MULTI: 5 (END 3, INNER 2)

By confidence:

- HIGH: 11
- MED: 131
- LOW: 6

## Core

- Core Y: 148
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 76 (51.4%)
- vowel: 60 (40.5%)
- spelling: 7 (4.7%)
- multi: 5 (3.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AH` — 20 pairs (END 3, INNER 17). Words: budweiser, bugs, fumble, what’s, bunny, money, bud, much.
2. `slant:AE:nas` — 14 pairs (END 6, INNER 8). Words: bang, banger, man, miami, gang, hang, stacking.
3. `slant:AE:nas-stop` — 10 pairs (END 0, INNER 10). Words: banger, clack, grab, quarterback, bank, gang, hang, man.
4. `vow:AE` — 10 pairs (END 1, INNER 9). Words: bang, gangster, flats, actresses, mailman, hands, stacking, bank.
5. `vow:AY` — 10 pairs (END 1, INNER 9). Words: high, tire, riding, disguise, like, live, by.
6. `slant:AE:nas-sib` — 9 pairs (END 5, INNER 4). Words: bangers, bang, banger, smash, hanger.
7. `vow:AA` — 7 pairs (END 1, INNER 6). Words: models, got, motto, popped, dolphins, car, wanna.
8. `slant:AH:nas` — 5 pairs (END 2, INNER 3). Words: running, runner, money, some, hummer.
9. `vow:IH` — 5 pairs (END 0, INNER 5). Words: finger, business, singers, linger, kick, shit, bitch.
10. `slant:AH:nas-stop` — 4 pairs (END 0, INNER 4). Words: some, bud, money, fuck, rub, bunny.
11. `vow:OW` — 4 pairs (END 1, INNER 3). Words: low, dope, bowl, lotion, motion, throw.
12. `slant:AH:sib` — 3 pairs (END 0, INNER 3). Words: budweiser, bugs, what’s.
13. `slant:EY:stop` — 3 pairs (END 1, INNER 2). Words: remainder, ain’t, changed, straight.
14. `slant:IH:stop` — 3 pairs (END 0, INNER 3). Words: finger, nigga, kick, shit.
15. `cmu:UW` — 2 pairs (END 0, INNER 2). Words: few, new.
16. `multi:AH-N-IY` — 2 pairs (END 0, INNER 2). Words: bugs bunny, throw money, bunny, money.
17. `slant:AH:nas-sib` — 2 pairs (END 0, INNER 2). Words: much, some, bunny.
18. `slant:AH:sib-stop` — 2 pairs (END 0, INNER 2). Words: much, rub, bud.
19. `slant:AO:liq` — 2 pairs (END 0, INNER 2). Words: call, floor, all, before.
20. `slant:EY:nas-stop` — 2 pairs (END 0, INNER 2). Words: retainer, remainder, ain’t.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with float (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with finger (2)
- rocko — 1 pair sides, mostly spelling via spelling phonetic key, often with bowl (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Rocko | Fanga Banga | 36 | 27 | 121 | loose |
