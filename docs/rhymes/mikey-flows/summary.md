# Mikey Flows rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Mikey Flows
- Songs: 1
- Bars kept (Mikey Flows lyric lines): 53
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Mikey Flows.
- Credit strings: Mikey Flows.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 341
- REPEAT pairs, recorded separately: 35
- END rhymes: 52
- INNER rhymes: 289

By match:

- PERFECT: 47 (END 15, INNER 32)
- SLANT: 119 (END 20, INNER 99)
- ASSONANCE: 170 (END 16, INNER 154)
- MULTI: 5 (END 1, INNER 4)

By confidence:

- HIGH: 45
- MED: 267
- LOW: 29

## Core

- Core Y: 339
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 132 (38.7%)
- vowel: 170 (49.9%)
- spelling: 34 (10.0%)
- multi: 5 (1.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 41 pairs (END 7, INNER 34). Words: ain't, vegas, play, hate, making, stayed, everyday, stay.
2. `vow:OW` — 41 pairs (END 0, INNER 41). Words: know, whole, dope, no, flow, cold, don't, gold.
3. `vow:AE` — 23 pairs (END 5, INNER 18). Words: hammers, have, savage, after, bags, lavish, manic, static.
4. `vow:IH` — 22 pairs (END 1, INNER 21). Words: big, pistol, figures, shit, think, limit, clearing, give.
5. `vow:AA` — 20 pairs (END 2, INNER 18). Words: got, box, cards, want, watch, large, lot, partners.
6. `slant:IH:stop` — 17 pairs (END 3, INNER 14). Words: big, nigga, sipper, dipper, flip, sip, limit, print.
7. `cmu:OW` — 15 pairs (END 0, INNER 15). Words: know, flow, bro, no, potato.
8. `slant:AA:stop` — 12 pairs (END 0, INNER 12). Words: got, drop, glock, want, lot, not, knock, patek.
9. `vow:EH` — 12 pairs (END 0, INNER 12). Words: get, tennis, mention, semi, spend, went, where, em.
10. `slant:EY:nas-sib` — 9 pairs (END 7, INNER 2). Words: change, range, chains, mane, cocaine, chain, brain, champagne.
11. `cmu:AE-NG` — 8 pairs (END 5, INNER 3). Words: thang, gang, bang.
12. `slant:EY:sib-stop` — 8 pairs (END 3, INNER 5). Words: plays, ain't, hate, range, haters, make, stayed, laid.
13. `slant:EY:stop` — 8 pairs (END 2, INNER 6). Words: make, hate, stayed, laid, paid, ain't, straight.
14. `slant:IH:nas-stop` — 7 pairs (END 0, INNER 7). Words: big, ima, bling, sip, limit, dipper, shit, anything.
15. `cmu:EY-N` — 6 pairs (END 6, INNER 0). Words: chain, cocaine, brain, balmain, mane.
16. `slant:AE:nas-stop` — 5 pairs (END 0, INNER 5). Words: back, can, thang, gang, bang, manic, panic.
17. `slant:AE:fric-sib` — 4 pairs (END 2, INNER 2). Words: have, lavish, savage.
18. `slant:EH:stop` — 4 pairs (END 0, INNER 4). Words: spent, better, disrespect, spend, get.
19. `slant:EY:nas-stop` — 4 pairs (END 1, INNER 3). Words: mane, hate, straight, came, making, make, brain, ain't.
20. `slant:OW:liq-nas` — 4 pairs (END 0, INNER 4). Words: whole, gon.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- sipper — 8 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- nigga — 8 pair sides, mostly spelling via spelling phonetic key, often with big (4)
- gon — 8 pair sides, mostly spelling via spelling phonetic key, often with whole (4)
- beamers — 3 pair sides, mostly spelling via spelling phonetic key, often with dream (1)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with big (1)
- bling — 3 pair sides, mostly spelling via spelling phonetic key, often with big (2)
- codeine — 2 pair sides, mostly spelling via spelling phonetic key, often with gon (2)
- balmain — 1 pair sides, mostly spelling via spelling phonetic key, often with mane (1)
- vmas — 1 pair sides, mostly spelling via spelling phonetic key, often with vegas (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Mikey Flows | Whole Thang | 53 | 52 | 289 | loose |
