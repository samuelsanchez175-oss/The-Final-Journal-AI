# Waka Flocka Flame rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Waka Flocka Flame
- Songs: 1
- Bars kept (Waka Flocka Flame lyric lines): 24
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Waka Flocka Flame.
- Credit strings: Waka Flocka Flame.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 242
- REPEAT pairs, recorded separately: 33
- END rhymes: 11
- INNER rhymes: 231

By match:

- PERFECT: 11 (END 1, INNER 10)
- SLANT: 115 (END 4, INNER 111)
- ASSONANCE: 114 (END 6, INNER 108)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 8
- MED: 207
- LOW: 27

## Core

- Core Y: 231
- Core N among rhyme pairs: 11

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 105 (43.4%)
- vowel: 114 (47.1%)
- spelling: 21 (8.7%)
- multi: 2 (0.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 34 pairs (END 0, INNER 34). Words: pistol, bitches, sips, tips, beer, really, shit, pistols.
2. `vow:AA` — 20 pairs (END 4, INNER 16). Words: bodies, starring, start, pocket, charlie, dropping, gonna, bottles.
3. `vow:IY` — 15 pairs (END 2, INNER 13). Words: nigga, froggy, weezy, here, charlie, pussy, wheezy, weed.
4. `vow:AH` — 12 pairs (END 0, INNER 12). Words: some, blunts, butts, fuckin, fuck, trunk, hundred, bunch.
5. `slant:AA:stop` — 11 pairs (END 1, INNER 10). Words: got, pocket, pop, chopper.
6. `vow:OW` — 11 pairs (END 0, INNER 11). Words: don't, over, co, know, no, sosa, tote, smoking.
7. `vow:AY` — 8 pairs (END 0, INNER 8). Words: high, diamond, like, buyin, die, mike, life, tonight.
8. `slant:AA:nas-stop` — 7 pairs (END 1, INNER 6). Words: gonna, pop, chopper, got, dropping, starring, start.
9. `slant:IH:liq-stop` — 7 pairs (END 1, INNER 6). Words: hit, beer, really, clip, shit, fear.
10. `slant:AH:nas-stop` — 6 pairs (END 0, INNER 6). Words: fuck, young, trunk, some, fuckin, fucking, buck.
11. `slant:IH:liq-nas` — 6 pairs (END 0, INNER 6). Words: him, beer, fear, lil, really.
12. `cmu:IH-NG` — 5 pairs (END 0, INNER 5). Words: mobbing, catching, wilding, starring, dropping, popping.
13. `slant:IH:fric-liq` — 5 pairs (END 0, INNER 5). Words: give, beer, really, fear.
14. `slant:IH:liq` — 5 pairs (END 0, INNER 5). Words: really, beer, fear.
15. `slant:IH:sib-stop` — 5 pairs (END 0, INNER 5). Words: clip, wish, niggas, nigga, shit, sips, tips.
16. `slant:EH:liq-stop` — 4 pairs (END 0, INNER 4). Words: air, set, let, check, red, l.
17. `slant:IH:liq-sib` — 4 pairs (END 0, INNER 4). Words: wish, really, fear, beer.
18. `slant:AE:nas-stop` — 3 pairs (END 0, INNER 3). Words: man, bad, phant, clack, can.
19. `slant:AH:nas` — 3 pairs (END 0, INNER 3). Words: young, some, fucking.
20. `slant:IH:stop` — 3 pairs (END 0, INNER 3). Words: nigga, clip, shit.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 10 pair sides, mostly vowel via vault phonetic_class, often with here (3)
- weezy — 7 pair sides, mostly vowel via spelling phonetic key, often with weed (1)
- froggy — 5 pair sides, mostly vowel via spelling phonetic key, often with flocka (1)
- mobbing — 5 pair sides, mostly spelling via spelling phonetic key, often with wilding (1)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with chiraq (2)
- flocka — 3 pair sides, mostly spelling via spelling phonetic key, often with blowin (1)
- wheezy — 3 pair sides, mostly vowel via spelling phonetic key, often with please (1)
- chiraq — 2 pair sides, mostly vowel via spelling phonetic key, often with niggas (2)
- rubbies — 1 pair sides, mostly spelling via spelling phonetic key, often with butts (1)
- phant — 1 pair sides, mostly spelling via spelling phonetic key, often with man (1)
- mobbin — 1 pair sides, mostly spelling via spelling phonetic key, often with smoking (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Waka Flocka Flame | Murder | 24 | 11 | 231 | loose |
