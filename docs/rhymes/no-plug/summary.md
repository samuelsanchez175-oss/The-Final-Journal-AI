# No Plug rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: No Plug
- Songs: 3
- Bars kept (No Plug lyric lines): 114
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: No Plug.
- Credit strings: No Plug.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 565
- REPEAT pairs, recorded separately: 116
- END rhymes: 141
- INNER rhymes: 424

By match:

- PERFECT: 49 (END 14, INNER 35)
- SLANT: 250 (END 58, INNER 192)
- ASSONANCE: 261 (END 64, INNER 197)
- MULTI: 5 (END 5, INNER 0)

By confidence:

- HIGH: 49
- MED: 470
- LOW: 46

## Core

- Core Y: 553
- Core N among rhyme pairs: 12

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 259 (45.8%)
- vowel: 261 (46.2%)
- spelling: 40 (7.1%)
- multi: 5 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 42 pairs (END 3, INNER 39). Words: got, arm, charm, shot, watch, partner, cops, dollars.
2. `vow:OW` — 42 pairs (END 5, INNER 37). Words: don't, know, no, cold, zone, stone, home, clothes.
3. `vow:IH` — 41 pairs (END 3, INNER 38). Words: bitch, i'mma, kissin, nigga, missin, pity, livin, wit.
4. `vow:AE` — 35 pairs (END 24, INNER 11). Words: aston, traffic, fashion, have, passenger, mavericks, average, clap.
5. `vow:EH` — 29 pairs (END 13, INNER 16). Words: went, carats, texas, giuseppe, section, stretchin, sellin, unless.
6. `vow:AO` — 21 pairs (END 6, INNER 15). Words: flawless, austin, ward, walking, warnings, songs, swore, morning.
7. `vow:EY` — 18 pairs (END 0, INNER 18). Words: play, games, came, favourite, blake, runway, draco, clay.
8. `slant:IH:stop` — 17 pairs (END 0, INNER 17). Words: nigga, dick, wit, pity, shit, drip, hit.
9. `slant:IH:sib-stop` — 16 pairs (END 0, INNER 16). Words: nigga, niggas, bitch, hit, dick, wit, pity, drip.
10. `cmu:AA-T` — 14 pairs (END 0, INNER 14). Words: got, lot, not.
11. `slant:EH:liq-stop` — 14 pairs (END 2, INNER 12). Words: get, sell, there, jerry, check, air, tell, spread.
12. `vow:AH` — 14 pairs (END 4, INNER 10). Words: ups, love, jumpin, rugs, come, fuckin, what, coming.
13. `slant:EH:stop` — 13 pairs (END 4, INNER 9). Words: get, better, said, buried, head, neck, set, wet.
14. `slant:EH:liq-nas` — 11 pairs (END 2, INNER 9). Words: em, when, tell, sellin, sell, jelly, any, air.
15. `cmu:OW` — 9 pairs (END 0, INNER 9). Words: no, grow, show, blow, doe, co.
16. `slant:AE:sib-stop` — 9 pairs (END 1, INNER 8). Words: back, packs, racks, stack, gas, pack, had, ass.
17. `slant:IH:liq-sib` — 9 pairs (END 0, INNER 9). Words: lil, bitch, diss.
18. `slant:OW:sib-stop` — 8 pairs (END 8, INNER 0). Words: coat, dose, close, boat, hoes, truckload.
19. `slant:AA:liq-stop` — 7 pairs (END 1, INNER 6). Words: shot, swallow, collar, chopper, bottle, got.
20. `slant:IH:nas` — 7 pairs (END 3, INNER 4). Words: kitchen, earring, thing, kissin, missin, million, livin, griffin.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 30 pair sides, mostly spelling via spelling phonetic key, often with niggas (10)
- niggas — 14 pair sides, mostly spelling via spelling phonetic key, often with nigga (10)
- imma — 7 pair sides, mostly vowel via spelling phonetic key, often with nigga (6)
- vvsin — 3 pair sides, mostly spelling via spelling phonetic key, often with lil (1)
- oneway — 2 pair sides, mostly spelling via spelling phonetic key, often with runway (1)
- scatpack — 2 pair sides, mostly vowel via spelling phonetic key, often with antrax (1)
- antrax — 2 pair sides, mostly vowel via spelling phonetic key, often with scatpack (1)
- dickin — 2 pair sides, mostly vowel via spelling phonetic key, often with shit (2)
- choppa — 1 pair sides, mostly spelling via spelling phonetic key, often with dope (1)
- droped — 1 pair sides, mostly spelling via spelling phonetic key, often with dead (1)
- extendo — 1 pair sides, mostly cmu via vault phonetic_class, often with yopper (1)
- yopper — 1 pair sides, mostly cmu via vault phonetic_class, often with extendo (1)
- moncler — 1 pair sides, mostly vowel via spelling phonetic key, often with dose (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with bowl (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| No Plug | A Savage | 35 | 40 | 124 | loose |
| No Plug | Don’t Play | 32 | 39 | 135 | loose |
| No Plug | Lil Ni$$a | 47 | 62 | 165 | loose |
