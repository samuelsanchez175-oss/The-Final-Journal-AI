# Bandman Kevo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Bandman Kevo
- Songs: 1
- Bars kept (Bandman Kevo lyric lines): 35
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Bandman Kevo.
- Credit strings: Bandman Kevo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 197
- REPEAT pairs, recorded separately: 15
- END rhymes: 35
- INNER rhymes: 162

By match:

- PERFECT: 16 (END 7, INNER 9)
- SLANT: 80 (END 6, INNER 74)
- ASSONANCE: 88 (END 17, INNER 71)
- MULTI: 13 (END 5, INNER 8)

By confidence:

- HIGH: 25
- MED: 161
- LOW: 11

## Core

- Core Y: 194
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 85 (43.1%)
- vowel: 88 (44.7%)
- spelling: 11 (5.6%)
- multi: 13 (6.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AO` — 20 pairs (END 9, INNER 11). Words: order, spalding, baller, shorty, shorter, calling, lawyer, caller.
2. `vow:EY` — 11 pairs (END 0, INNER 11). Words: say, ain't, gave, everyday, made, stay, stain, chain.
3. `vow:AA` — 10 pairs (END 3, INNER 7). Words: garden, garbage, conscience, gonna, not, got, falling.
4. `vow:IY` — 10 pairs (END 4, INNER 6). Words: these, seats, see, stuntin, week, teeth, tree, means.
5. `vow:OW` — 10 pairs (END 0, INNER 10). Words: know, owe, thot, hoes, show, dope, smoke, don't.
6. `slant:AH:nas-sib` — 9 pairs (END 0, INNER 9). Words: much, money, gun, guns, some.
7. `vow:AH` — 9 pairs (END 1, INNER 8). Words: what, nothing, number, something, fuck, money, guns, gun.
8. `multi:AO-K-IH-NG` — 8 pairs (END 0, INNER 8). Words: boy walking, talking, walking, quit talking, get stalking, stalking, niggas talking.
9. `slant:AO:liq` — 8 pairs (END 0, INNER 8). Words: call, baller, caller, all, taller.
10. `cmu:EY-N` — 6 pairs (END 6, INNER 0). Words: 'caine, stain, chain, lane.
11. `slant:AH:nas` — 6 pairs (END 0, INNER 6). Words: money, gun, some.
12. `vow:IH` — 6 pairs (END 0, INNER 6). Words: missed, rims, bitches, give, bitch, think, bricks, dick.
13. `multi:AO-L-ER` — 5 pairs (END 5, INNER 0). Words: baller, caller, taller.
14. `vow:AE` — 5 pairs (END 0, INNER 5). Words: dance, ballin, can't, bank, mattress, trap, dash, fat.
15. `slant:AH:nas-stop` — 4 pairs (END 0, INNER 4). Words: what, money, fuck, gun.
16. `slant:AO:stop` — 4 pairs (END 4, INNER 0). Words: shorter, water, shorty, order.
17. `slant:EY:nas-stop` — 4 pairs (END 0, INNER 4). Words: paid, 'caine, stain, chain, lane, ain't.
18. `cmu:AY` — 3 pairs (END 0, INNER 3). Words: lie, fly, why.
19. `slant:AE:sib-stop` — 3 pairs (END 0, INNER 3). Words: dash, fat, trap, ass.
20. `slant:AH:sib-stop` — 3 pairs (END 0, INNER 3). Words: much, fuck, what.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- thot — 8 pair sides, mostly spelling via spelling phonetic key, often with hoes (2)
- stuntin — 4 pair sides, mostly vowel via vault phonetic_class, often with see (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with means (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with dick (1)
- forgi — 1 pair sides, mostly vowel via spelling phonetic key, often with spalding (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Bandman Kevo | Baller In Me (Remix) | 35 | 35 | 162 | loose |
