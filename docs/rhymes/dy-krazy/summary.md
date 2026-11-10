# DY Krazy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DY Krazy
- Songs: 1
- Bars kept (DY Krazy lyric lines): 66
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DY Krazy.
- Credit strings: DY Krazy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 387
- REPEAT pairs, recorded separately: 56
- END rhymes: 98
- INNER rhymes: 289

By match:

- PERFECT: 57 (END 33, INNER 24)
- SLANT: 179 (END 34, INNER 145)
- ASSONANCE: 140 (END 24, INNER 116)
- MULTI: 11 (END 7, INNER 4)

By confidence:

- HIGH: 68
- MED: 286
- LOW: 33

## Core

- Core Y: 377
- Core N among rhyme pairs: 10

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 213 (55.0%)
- vowel: 140 (36.2%)
- spelling: 23 (5.9%)
- multi: 11 (2.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `cmu:OW` — 46 pairs (END 27, INNER 19). Words: go, blow, no, know, throw, ho, show, mexico.
2. `vow:IH` — 40 pairs (END 9, INNER 31). Words: kidneys, bitch, mixin, fitted, amiri, city, sitchys, chicken.
3. `vow:EH` — 37 pairs (END 1, INNER 36). Words: gettin, texaco, 'member, extra, fresh, get, well, fendi.
4. `vow:OW` — 26 pairs (END 10, INNER 16). Words: hoes, don't, show, go, soul, rollie, over, poles.
5. `slant:IH:liq-stop` — 24 pairs (END 4, INNER 20). Words: still, city, really, sticky, lil, gritty, nitty, whip.
6. `slant:AH:nas-stop` — 16 pairs (END 0, INNER 16). Words: fuck, some, truck, young, club, motherfuckin, come, done.
7. `slant:EH:sib-stop` — 14 pairs (END 1, INNER 13). Words: get, bless, less, let's, stress, fendi, wendys, best.
8. `slant:IH:sib-stop` — 14 pairs (END 2, INNER 12). Words: bitch, dizzy, nigga, niggas, trick, city, rich, shit.
9. `slant:IH:stop` — 13 pairs (END 5, INNER 8). Words: nigga, fitted, kit, city, hit, sticky, whip, quick.
10. `slant:OW:sib` — 11 pairs (END 9, INNER 2). Words: hoes, poles, clothes, those, rolls.
11. `slant:ER:stop` — 8 pairs (END 8, INNER 0). Words: berserk, shirt, first, hurt, skirt.
12. `slant:IH:nas-stop` — 8 pairs (END 0, INNER 8). Words: inner, city, i'ma, hit, gritty, nitty, quick, chicken.
13. `multi:IH-T-IY` — 7 pairs (END 3, INNER 4). Words: city, gritty, nitty, when nitty, inner city, nitty gritty.
14. `slant:EH:nas-stop` — 7 pairs (END 0, INNER 7). Words: get, let, ten, gettin, when.
15. `slant:IH:liq-sib` — 7 pairs (END 1, INNER 6). Words: dizzy, still, bitch, lil, rich, amiri, really.
16. `slant:EH:stop` — 6 pairs (END 0, INNER 6). Words: get, best, fendi, said, elliot, went, blessed, tech.
17. `vow:AY` — 6 pairs (END 0, INNER 6). Words: high, pints, kind, ride, time, like, buy, hi.
18. `vow:AA` — 5 pairs (END 0, INNER 5). Words: got, icebox, nothin, gotta, hop.
19. `vow:AH` — 5 pairs (END 0, INNER 5). Words: fuck, somethin, some, motherfuckin, twerk, young.
20. `vow:EY` — 5 pairs (END 0, INNER 5). Words: ain't, safe, k, may, take, eights, say, make.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 9 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- sitchys — 5 pair sides, mostly vowel via spelling phonetic key, often with gritty (1)
- tryna — 5 pair sides, mostly spelling via spelling phonetic key, often with beach (2)
- niggas — 4 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- bhindi — 3 pair sides, mostly vowel via spelling phonetic key, often with fitted (1)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with city (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with foenem (1)
- twerk — 2 pair sides, mostly spelling via vault phonetic_class, often with berserk (1)
- wopskino — 2 pair sides, mostly vowel via spelling phonetic key, often with go (1)
- finna — 2 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)
- wendys — 1 pair sides, mostly spelling via spelling phonetic key, often with fendi (1)
- foenem — 1 pair sides, mostly spelling via spelling phonetic key, often with gon (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DY Krazy | Off Some Percs | 66 | 98 | 289 | loose |
