# Jose Guapo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Jose Guapo
- Songs: 1
- Bars kept (Jose Guapo lyric lines): 53
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Jose Guapo.
- Credit strings: Jose Guapo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 307
- REPEAT pairs, recorded separately: 48
- END rhymes: 31
- INNER rhymes: 276

By match:

- PERFECT: 37 (END 3, INNER 34)
- SLANT: 131 (END 11, INNER 120)
- ASSONANCE: 137 (END 15, INNER 122)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 33
- MED: 258
- LOW: 16

## Core

- Core Y: 300
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 153 (49.8%)
- vowel: 137 (44.6%)
- spelling: 15 (4.9%)
- multi: 2 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 44 pairs (END 10, INNER 34). Words: got, doctors, colossus, partners, problem, posture, departure, charts.
2. `slant:AE:stop` — 22 pairs (END 4, INNER 18). Words: adapt, dab, bag, pack, trap, cab, can't, bando.
3. `vow:EY` — 22 pairs (END 3, INNER 19). Words: chains, same, changed, ain't, fame, stay, name, straight.
4. `vow:AE` — 16 pairs (END 0, INNER 16). Words: can't, balenciaga, trap, gas, adapt, pack, trapping, had.
5. `vow:IH` — 16 pairs (END 1, INNER 15). Words: delinquent, shit, drink, hits, still, dizzy, sipping, tips.
6. `vow:EH` — 12 pairs (END 1, INNER 11). Words: independent, metal, bender, remember, selling, benjamin, left, when.
7. `cmu:EY-M` — 10 pairs (END 0, INNER 10). Words: same, lame, name, fame.
8. `slant:AE:sib-stop` — 10 pairs (END 0, INNER 10). Words: gas, trap, straps, dab, bag, adapt, pack, cab.
9. `slant:AH:nas` — 10 pairs (END 0, INNER 10). Words: some, money, young, done.
10. `vow:AY` — 9 pairs (END 0, INNER 9). Words: like, by, diamond, shining, fly, diamonds, private, designer.
11. `cmu:AA-T` — 8 pairs (END 0, INNER 8). Words: got, bought, not, lot, headshot.
12. `slant:EY:nas-stop` — 7 pairs (END 0, INNER 7). Words: made, straight, name, same, lame, fame.
13. `vow:AO` — 7 pairs (END 0, INNER 7). Words: all, talking, cautious, losses, cross, flawless, nauseous, call.
14. `slant:AE:liq-stop` — 5 pairs (END 0, INNER 5). Words: bal, bag, pack, cab, dab.
15. `slant:EH:liq-stop` — 5 pairs (END 0, INNER 5). Words: tell, get, step, swear, red, head.
16. `vow:AH` — 5 pairs (END 0, INNER 5). Words: guns, some, young, months.
17. `cmu:AH-M` — 4 pairs (END 0, INNER 4). Words: some, 'em.
18. `slant:AA:stop` — 4 pairs (END 0, INNER 4). Words: got, topped, pocket, bought.
19. `slant:AO:sib` — 4 pairs (END 2, INNER 2). Words: cautious, flawless, losses, nauseous.
20. `slant:IH:stop` — 4 pairs (END 0, INNER 4). Words: shit, nigga, hip.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- balenciaga — 5 pair sides, mostly vowel via spelling phonetic key, often with trap (2)
- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- bando — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- nashing — 2 pair sides, mostly spelling via spelling phonetic key, often with trapping (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with keep (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- jeweller — 1 pair sides, mostly vowel via spelling phonetic key, often with step (1)
- yas — 1 pair sides, mostly spelling via spelling phonetic key, often with gas (1)
- longway — 1 pair sides, mostly spelling via spelling phonetic key, often with throwin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Jose Guapo | Never Been A Lame | 53 | 31 | 276 | loose |
