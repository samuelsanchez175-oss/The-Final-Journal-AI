# BabyTron rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: BabyTron
- Songs: 1
- Bars kept (BabyTron lyric lines): 61
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: BabyTron.
- Credit strings: BabyTron.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 633
- REPEAT pairs, recorded separately: 256
- END rhymes: 20
- INNER rhymes: 613

By match:

- PERFECT: 15 (END 2, INNER 13)
- SLANT: 384 (END 15, INNER 369)
- ASSONANCE: 215 (END 3, INNER 212)
- MULTI: 19 (END 0, INNER 19)

By confidence:

- HIGH: 31
- MED: 582
- LOW: 20

## Core

- Core Y: 631
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 380 (60.0%)
- vowel: 215 (34.0%)
- spelling: 19 (3.0%)
- multi: 19 (3.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:AH:nas-stop` — 88 pairs (END 5, INNER 83). Words: money, fuck, plug, cut, some, unky, stuck, motherfucker.
2. `vow:EY` — 47 pairs (END 0, INNER 47). Words: ain't, way, h, label, he'da, player, ranger, pray.
3. `vow:AH` — 46 pairs (END 0, INNER 46). Words: money, hundreds, jumped, some, must, touched, under, cut.
4. `slant:AH:nas` — 44 pairs (END 8, INNER 36). Words: money, some, dummy, done, cousin, run.
5. `slant:AA:stop` — 36 pairs (END 0, INNER 36). Words: got, gotta, start, knock, glock, park, knob, hop.
6. `vow:EH` — 33 pairs (END 0, INNER 33). Words: spend, get, gettin, jets, bench, flex, every, when.
7. `vow:AE` — 26 pairs (END 3, INNER 23). Words: cash, man's, back, flanked, shank, scams, trap, stash.
8. `vow:AA` — 23 pairs (END 0, INNER 23). Words: got, park, comments, darth, upon, started, nothin, knocked.
9. `slant:EH:nas-stop` — 20 pairs (END 0, INNER 20). Words: get, when, spend, gen5, n, head, gettin, ten.
10. `vow:IH` — 18 pairs (END 0, INNER 18). Words: bitch, wrist, it'd, strippers, think, sprint, ms, trigger.
11. `slant:EY:stop` — 17 pairs (END 0, INNER 17). Words: hater, laker, ain't, paid, undertaker, rape, fake, hate.
12. `slant:AA:nas-stop` — 15 pairs (END 0, INNER 15). Words: got, mama, comm, upon, knock, hop, gotta.
13. `slant:AA:liq-stop` — 11 pairs (END 0, INNER 11). Words: star, got, gotta, bol, not, start.
14. `slant:AH:stop` — 11 pairs (END 0, INNER 11). Words: cut, plug, fuck, stuck, must, touched, under, jumped.
15. `slant:AH:nas-sib` — 10 pairs (END 0, INNER 10). Words: money, once, 'nother, fuzz.
16. `slant:EY:sib-stop` — 10 pairs (END 0, INNER 10). Words: h, glacier, chase, hate, taper, hater, fake, laker.
17. `vow:OW` — 10 pairs (END 0, INNER 10). Words: don't, hoes, snow, no, owe, open, close, only.
18. `multi:AH-N-IY` — 9 pairs (END 0, INNER 9). Words: got sunny, money, sunny, kids money, real money, sunny money, got money, money money.
19. `slant:IH:sib-stop` — 8 pairs (END 0, INNER 8). Words: bitch, shit, counterfeit, switch, rich, big, rip, hip.
20. `vow:IY` — 8 pairs (END 0, INNER 8). Words: even, real, asleep, thirty, season, he'll, teachers, stealin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- unky — 13 pair sides, mostly spelling via spelling phonetic key, often with money (8)
- gen5 — 6 pair sides, mostly spelling via spelling phonetic key, often with spend (2)
- flunky — 5 pair sides, mostly spelling via spelling phonetic key, often with money (3)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with hit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| BabyTron | Chase The Money | 61 | 20 | 613 | loose |
