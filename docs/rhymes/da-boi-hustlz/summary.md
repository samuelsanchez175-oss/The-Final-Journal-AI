# Da Boi Hustlz rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Da Boi Hustlz
- Songs: 1
- Bars kept (Da Boi Hustlz lyric lines): 34
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Da Boi Hustlz.
- Credit strings: Da Boi Hustlz.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 187
- REPEAT pairs, recorded separately: 34
- END rhymes: 40
- INNER rhymes: 147

By match:

- PERFECT: 24 (END 4, INNER 20)
- SLANT: 67 (END 21, INNER 46)
- ASSONANCE: 96 (END 15, INNER 81)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 23
- MED: 160
- LOW: 4

## Core

- Core Y: 186
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 87 (46.5%)
- vowel: 96 (51.3%)
- spelling: 4 (2.1%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AW` — 21 pairs (END 4, INNER 17). Words: now, down, around, about, how, ounces, thousand, round.
2. `vow:IH` — 15 pairs (END 8, INNER 7). Words: still, kitchen, fifty, ambition, minute, figure, shit, rich.
3. `vow:OW` — 14 pairs (END 0, INNER 14). Words: don’t, know, hoe, own, broke, go.
4. `vow:EH` — 12 pairs (END 1, INNER 11). Words: givenchy, em, feds, remember, bentley, wearing, get, never.
5. `vow:AH` — 11 pairs (END 0, INNER 11). Words: couple, come, fuck, hundred, hustling, nothing, one, touching.
6. `vow:IY` — 11 pairs (END 1, INNER 10). Words: breathing, keep, fees, key, probably, jeans, believe, feet.
7. `slant:AA:sib-stop` — 9 pairs (END 6, INNER 3). Words: spot, spots, watch, cause, caught, shot, got.
8. `slant:AW:nas-stop` — 9 pairs (END 8, INNER 1). Words: down, around, clown, about, round.
9. `cmu:AA-T` — 7 pairs (END 2, INNER 5). Words: spot, got, shot.
10. `slant:AE:stop` — 7 pairs (END 6, INNER 1). Words: bag, bad, had.
11. `vow:AY` — 6 pairs (END 0, INNER 6). Words: grinding, buy, might, try, buying.
12. `cmu:OW` — 5 pairs (END 0, INNER 5). Words: know, hoe.
13. `vow:EY` — 5 pairs (END 0, INNER 5). Words: cases, game, came, stayed, lately, take, play.
14. `slant:EH:liq-nas` — 4 pairs (END 0, INNER 4). Words: wear, wearing, swear, em, when.
15. `slant:IH:stop` — 4 pairs (END 0, INNER 4). Words: nigga, shit, hit, fifty.
16. `slant:AH:nas-stop` — 3 pairs (END 0, INNER 3). Words: fuck, come.
17. `slant:EH:liq-stop` — 3 pairs (END 0, INNER 3). Words: air, get, head, dead.
18. `cmu:AE-D` — 2 pairs (END 1, INNER 1). Words: had, bad.
19. `cmu:IY` — 2 pairs (END 0, INNER 2). Words: niggas, t, probably, key.
20. `slant:AH:nas` — 2 pairs (END 0, INNER 2). Words: hustling, touching, nothing.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- niggas — 2 pair sides, mostly vowel via vault phonetic_class, often with tryna (1)
- tryna — 1 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Da Boi Hustlz | Keep Hustling (feat. YFN Lucci) | 34 | 40 | 147 | loose |
