# MobSquad Nard rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: MobSquad Nard
- Songs: 1
- Bars kept (MobSquad Nard lyric lines): 43
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: MobSquad Nard.
- Credit strings: MobSquad Nard.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 195
- REPEAT pairs, recorded separately: 52
- END rhymes: 30
- INNER rhymes: 165

By match:

- PERFECT: 15 (END 8, INNER 7)
- SLANT: 112 (END 18, INNER 94)
- ASSONANCE: 67 (END 3, INNER 64)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 16
- MED: 159
- LOW: 20

## Core

- Core Y: 194
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 108 (55.4%)
- vowel: 67 (34.4%)
- spelling: 19 (9.7%)
- multi: 1 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 15 pairs (END 0, INNER 15). Words: day, ain't, came, hatin, shake, dey, fakin, main.
2. `slant:IH:sib-stop` — 14 pairs (END 1, INNER 13). Words: bitch, niggas, nigga, wig, shit, hit, nick, crib.
3. `vow:IH` — 14 pairs (END 1, INNER 13). Words: killed, bitch, fitted, nickels, kitchen, shit, wig, nick.
4. `vow:AY` — 10 pairs (END 2, INNER 8). Words: like, hi, stripes, why, flying, dimes, time, supplying.
5. `slant:AE:nas-stop` — 9 pairs (END 4, INNER 5). Words: dat, man, gang, cap, hann, back, damn, nigga.
6. `vow:AE` — 9 pairs (END 0, INNER 9). Words: dat, ask, savage, datz, hann, cap, damn.
7. `slant:AE:stop` — 8 pairs (END 6, INNER 2). Words: dat, back, cap, nigga, trap.
8. `slant:IH:stop` — 6 pairs (END 0, INNER 6). Words: click, hit, wig, fitted, nigga, crib, shit, wit.
9. `vow:AH` — 5 pairs (END 0, INNER 5). Words: slums, love, young, stuck, bussed, fuckem, fucked, running.
10. `vow:AW` — 5 pairs (END 0, INNER 5). Words: how, bout, round, town, down, drought.
11. `cmu:IY-N` — 4 pairs (END 4, INNER 0). Words: mean, green, clean.
12. `slant:AE:sib-stop` — 4 pairs (END 0, INNER 4). Words: dat, watchu, datz.
13. `slant:AH:nas-stop` — 4 pairs (END 0, INNER 4). Words: money, mud, fuck, young, stuck, fucking, fucked.
14. `slant:AY:stop` — 4 pairs (END 0, INNER 4). Words: like, right, side.
15. `slant:EH:fric-liq` — 4 pairs (END 0, INNER 4). Words: where, chef, every, there.
16. `slant:EY:nas-stop` — 4 pairs (END 0, INNER 4). Words: shake, came, fakin, hate, baby, main.
17. `vow:AA` — 4 pairs (END 0, INNER 4). Words: da, got, hollin.
18. `slant:AY:nas` — 3 pairs (END 2, INNER 1). Words: time, supplying, flying, ridin.
19. `slant:EH:liq-nas` — 3 pairs (END 0, INNER 3). Words: tell, dem, when, n, where.
20. `slant:EH:nas` — 3 pairs (END 0, INNER 3). Words: when, dem, heaven.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 8 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- niggas — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- trurn — 4 pair sides, mostly spelling via vault phonetic_class, often with turn (3)
- dem — 4 pair sides, mostly spelling via spelling phonetic key, often with when (2)
- watchu — 3 pair sides, mostly spelling via spelling phonetic key, often with dat (3)
- fuckem — 2 pair sides, mostly vowel via spelling phonetic key, often with bussed (1)
- cuz — 2 pair sides, mostly spelling via spelling phonetic key, often with young (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| MobSquad Nard | Did Dat | 43 | 30 | 165 | loose |
