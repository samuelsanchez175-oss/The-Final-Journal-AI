# Paul Wall rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Paul Wall
- Songs: 1
- Bars kept (Paul Wall lyric lines): 52
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Paul Wall.
- Credit strings: Paul Wall.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 323
- REPEAT pairs, recorded separately: 45
- END rhymes: 32
- INNER rhymes: 291

By match:

- PERFECT: 23 (END 2, INNER 21)
- SLANT: 147 (END 20, INNER 127)
- ASSONANCE: 152 (END 9, INNER 143)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 21
- MED: 263
- LOW: 39

## Core

- Core Y: 314
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 138 (42.7%)
- vowel: 152 (47.1%)
- spelling: 32 (9.9%)
- multi: 1 (0.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 35 pairs (END 1, INNER 34). Words: diamonds, like, why, chi, ride, shine, fire, satellite.
2. `vow:OW` — 25 pairs (END 1, INNER 24). Words: don't, no, glo, only, coat, lobes, loaded, know.
3. `vow:IY` — 21 pairs (END 1, INNER 20). Words: beat, free, screamin, ramy, hearses, g, ear, party.
4. `vow:AA` — 20 pairs (END 2, INNER 18). Words: boxing, bodies, hot, car, palms, got, pockets, start.
5. `slant:AA:liq-stop` — 17 pairs (END 1, INNER 16). Words: car, hot, hop, gotta, god.
6. `slant:IH:liq-stop` — 13 pairs (END 1, INNER 12). Words: grill, quicker, pig, icey, shit, hilary, chill, kill.
7. `slant:AA:stop` — 12 pairs (END 1, INNER 11). Words: hot, gotta, hop, party, bugatti, god, got, glock.
8. `vow:AE` — 12 pairs (END 3, INNER 9). Words: candy, bang, starin, pants, dancin, cash, bands, can.
9. `slant:IH:sib-stop` — 11 pairs (END 3, INNER 8). Words: niggas, nigga, bitch, flicker, swisher, icey, mississippi.
10. `slant:IH:stop` — 11 pairs (END 5, INNER 6). Words: nigga, big, cricket, mississippi, sip, flip, clip, rick.
11. `vow:IH` — 10 pairs (END 0, INNER 10). Words: itchin, shit, swishahouse, billin, killin, big, earrings, chill.
12. `slant:AA:nas-stop` — 9 pairs (END 1, INNER 8). Words: mama, johnny, hot, gotta, got, stock, hop, god.
13. `vow:AH` — 9 pairs (END 1, INNER 8). Words: bust, what's, fuck, comin, money, ducati, punani, duff.
14. `vow:EY` — 8 pairs (END 0, INNER 8). Words: ain't, stay, name, waking, say, hatin, k, blazer.
15. `slant:AY:stop` — 7 pairs (END 0, INNER 7). Words: like, ride, satellite, supplied.
16. `slant:IY:fric-sib` — 7 pairs (END 0, INNER 7). Words: keef, these, keith, chief, she's, leaf.
17. `cmu:OW` — 6 pairs (END 0, INNER 6). Words: go, no, chicago, know, ho, sergio.
18. `vow:UW` — 6 pairs (END 0, INNER 6). Words: two, pool, jewels, ruler, sooner, uber, new, jewelry.
19. `slant:OW:stop` — 5 pairs (END 1, INNER 4). Words: shotta, code, poker, don't, gold, loaded, promoted.
20. `slant:IH:liq-nas` — 4 pairs (END 0, INNER 4). Words: hilary, billin, killin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 12 pair sides, mostly spelling via spelling phonetic key, often with niggas (8)
- niggas — 8 pair sides, mostly spelling via spelling phonetic key, often with nigga (8)
- ciara — 5 pair sides, mostly spelling via spelling phonetic key, often with sip (1)
- squealer — 4 pair sides, mostly spelling via spelling phonetic key, often with feel (1)
- icey — 4 pair sides, mostly spelling via spelling phonetic key, often with ciara (1)
- ramy — 3 pair sides, mostly vowel via spelling phonetic key, often with party (2)
- hearses — 3 pair sides, mostly vowel via spelling phonetic key, often with these (2)
- shotta — 3 pair sides, mostly spelling via spelling phonetic key, often with poker (1)
- punani — 2 pair sides, mostly vowel via spelling phonetic key, often with ducati (1)
- swishahouse — 2 pair sides, mostly vowel via spelling phonetic key, often with flicker (1)
- ducati — 1 pair sides, mostly vowel via spelling phonetic key, often with punani (1)
- twerk — 1 pair sides, mostly spelling via spelling phonetic key, often with perc (1)
- cuz — 1 pair sides, mostly spelling via spelling phonetic key, often with duff (1)
- twerkin — 1 pair sides, mostly spelling via spelling phonetic key, often with starin (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with turn (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Paul Wall | Bust | 52 | 32 | 291 | loose |
