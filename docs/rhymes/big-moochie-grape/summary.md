# Big Moochie Grape rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Big Moochie Grape
- Songs: 2
- Bars kept (Big Moochie Grape lyric lines): 91
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Big Moochie Grape.
- Credit strings: Big Moochie Grape.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 594
- REPEAT pairs, recorded separately: 26
- END rhymes: 148
- INNER rhymes: 446

By match:

- PERFECT: 59 (END 9, INNER 50)
- SLANT: 212 (END 36, INNER 176)
- ASSONANCE: 317 (END 97, INNER 220)
- MULTI: 6 (END 6, INNER 0)

By confidence:

- HIGH: 61
- MED: 500
- LOW: 33

## Core

- Core Y: 591
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 237 (39.9%)
- vowel: 317 (53.4%)
- spelling: 34 (5.7%)
- multi: 6 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 94 pairs (END 51, INNER 43). Words: made, mayor, slayer, staples, grape, traitors, able, k.
2. `vow:AA` — 61 pairs (END 13, INNER 48). Words: got, argue, monster, colony, not, sparkle, copying, hard.
3. `vow:AE` — 37 pairs (END 24, INNER 13). Words: have, traffic, pallet, padding, rapping, bad, balance, established.
4. `slant:AA:stop` — 28 pairs (END 2, INNER 26). Words: hopped, patek, got, glock, bought, pop, poverty, pottery.
5. `vow:IH` — 28 pairs (END 5, INNER 23). Words: hit, shit, sticks, killed, bitches, christmas, stick, filled.
6. `vow:OW` — 27 pairs (END 1, INNER 26). Words: don't, know, no, ho, gold, hole, dope, throwing.
7. `vow:EH` — 23 pairs (END 3, INNER 20). Words: sendin, fetish, message, trenches, help, l, veteran, best.
8. `vow:AH` — 22 pairs (END 0, INNER 22). Words: ugly, money, none, bustin, some, fuckin, duffel, young.
9. `slant:IH:sib-stop` — 17 pairs (END 6, INNER 11). Words: nigga, shit, niggas, wish, bitch, rich, hit, killers.
10. `slant:IH:stop` — 17 pairs (END 0, INNER 17). Words: nigga, shit, big, hit, hip, stick, lingo, brick.
11. `slant:EY:sib-stop` — 14 pairs (END 9, INNER 5). Words: paid, made, days, razor, hate, th, pager, traitors.
12. `vow:IY` — 14 pairs (END 0, INNER 14). Words: east, these, stealing, keep, g, key, tree, trampoline.
13. `slant:AH:nas-stop` — 12 pairs (END 0, INNER 12). Words: fuck, young, stuck, money, none, some, bumpin, jump.
14. `cmu:AA-T` — 11 pairs (END 0, INNER 11). Words: got, bought, not, hot, shot, spot.
15. `slant:AH:nas` — 11 pairs (END 0, INNER 11). Words: money, some, young, none, done, one, motherfuckin, fuckin.
16. `cmu:AO-R` — 9 pairs (END 0, INNER 9). Words: before, door, soar, aventador, more.
17. `slant:EH:liq-stop` — 9 pairs (END 0, INNER 9). Words: better, fell, let, yellow, kelly, smelly, said, hell.
18. `slant:IH:nas-stop` — 9 pairs (END 0, INNER 9). Words: i'ma, hit, shit, him, bring, lit, big, twin.
19. `cmu:IH-T` — 7 pairs (END 3, INNER 4). Words: shit, hit, lit.
20. `cmu:OW` — 7 pairs (END 0, INNER 7). Words: no, ho, know, throw, go, mow.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 18 pair sides, mostly spelling via spelling phonetic key, often with shit (5)
- ima — 6 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- aventador — 4 pair sides, mostly spelling via spelling phonetic key, often with lambo (1)
- lambo — 2 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- moochie — 2 pair sides, mostly spelling via spelling phonetic key, often with smooth (1)
- maybachs — 1 pair sides, mostly spelling via spelling phonetic key, often with traitors (1)
- niggasll — 1 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Big Moochie Grape | I Made It | 41 | 67 | 137 | loose |
| Big Moochie Grape | No Favors | 50 | 81 | 309 | loose |
