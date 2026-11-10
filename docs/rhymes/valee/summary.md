# Valee rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Valee
- Songs: 1
- Bars kept (Valee lyric lines): 46
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Valee.
- Credit strings: Valee.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 385
- REPEAT pairs, recorded separately: 18
- END rhymes: 64
- INNER rhymes: 321

By match:

- PERFECT: 31 (END 5, INNER 26)
- SLANT: 137 (END 23, INNER 114)
- ASSONANCE: 204 (END 25, INNER 179)
- MULTI: 13 (END 11, INNER 2)

By confidence:

- HIGH: 39
- MED: 330
- LOW: 16

## Core

- Core Y: 378
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 156 (40.5%)
- vowel: 204 (53.0%)
- spelling: 12 (3.1%)
- multi: 13 (3.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 68 pairs (END 9, INNER 59). Words: know, don't, froze, told, flow, loaded, no, go.
2. `vow:IY` — 33 pairs (END 12, INNER 21). Words: legal, sneakers, t, c's, b, stealin, nobody, hear.
3. `vow:IH` — 23 pairs (END 1, INNER 22). Words: missin, rips, appearance, bitch, hit, steerin, pickin, bitches.
4. `vow:AE` — 21 pairs (END 3, INNER 18). Words: ran, bank, mattress, actress, average, matte, bag, slacks.
5. `vow:EY` — 16 pairs (END 0, INNER 16). Words: make, saint, play, always, day, takin, say, ain't.
6. `vow:AA` — 11 pairs (END 0, INNER 11). Words: projects, got, knots, pocket, rollin, rockin, not, cop.
7. `cmu:OW` — 10 pairs (END 0, INNER 10). Words: know, no, go, flow, ho, throw.
8. `multi:IY-T-ER` — 9 pairs (END 9, INNER 0). Words: beater, jeter, eater, liter.
9. `slant:IY:sib-stop` — 9 pairs (END 8, INNER 1). Words: lisa, beater, fiji, jeter, eater, need, visa, these.
10. `vow:AY` — 9 pairs (END 0, INNER 9). Words: like, pipes, minus, slide, hi, ninety, signs.
11. `cmu:AA-T` — 8 pairs (END 0, INNER 8). Words: got, not, bought, hot.
12. `vow:AH` — 8 pairs (END 0, INNER 8). Words: hundred, fuck, month, blunt, bucks.
13. `slant:AA:stop` — 7 pairs (END 0, INNER 7). Words: got, pocket, not, exotic, cop.
14. `slant:AE:stop` — 7 pairs (END 5, INNER 2). Words: act, hat, back, 'raq, matte, bag, had, strapped.
15. `slant:AA:sib-stop` — 6 pairs (END 0, INNER 6). Words: knots, got, not, watch, bought.
16. `slant:AY:stop` — 6 pairs (END 0, INNER 6). Words: like, slide, excited, side.
17. `vow:EH` — 6 pairs (END 0, INNER 6). Words: sellin, gettin, went, neck, let, whatever, necklace, where.
18. `vow:UW` — 6 pairs (END 0, INNER 6). Words: two, coupe, new, gucci, super.
19. `slant:AA:liq-stop` — 5 pairs (END 0, INNER 5). Words: got, car, far, hot.
20. `slant:IH:liq-sib` — 5 pairs (END 0, INNER 5). Words: bitch, chill, lil, still.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- raq — 3 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- bandola — 3 pair sides, mostly multi via spelling phonetic key, often with ebola (2)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with codeine (2)
- codeine — 3 pair sides, mostly spelling via spelling phonetic key, often with gon (2)
- vlone — 2 pair sides, mostly spelling via spelling phonetic key, often with mona (1)
- faygo — 2 pair sides, mostly vowel via spelling phonetic key, often with throw (1)
- herbo — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- percocet — 1 pair sides, mostly spelling via spelling phonetic key, often with pocket (1)
- valee — 1 pair sides, mostly vowel via spelling phonetic key, often with ninety (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with quit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Valee | Above Average | 46 | 64 | 321 | loose |
