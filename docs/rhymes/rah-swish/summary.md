# Rah Swish rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Rah Swish
- Songs: 1
- Bars kept (Rah Swish lyric lines): 42
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Rah Swish.
- Credit strings: Rah Swish.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 255
- REPEAT pairs, recorded separately: 11
- END rhymes: 67
- INNER rhymes: 188

By match:

- PERFECT: 13 (END 4, INNER 9)
- SLANT: 126 (END 27, INNER 99)
- ASSONANCE: 115 (END 35, INNER 80)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 12
- MED: 219
- LOW: 24

## Core

- Core Y: 251
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 117 (45.9%)
- vowel: 115 (45.1%)
- spelling: 22 (8.6%)
- multi: 1 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 35 pairs (END 17, INNER 18). Words: cold, zoe, boats, dope, don't, know, hope, ghost.
2. `vow:AH` — 20 pairs (END 9, INNER 11). Words: fuck, disgusted, bussin, once, mustard, love, couple, hundred.
3. `vow:IY` — 20 pairs (END 3, INNER 17). Words: three, sleep, keepers, breathin, bleedin, free, schemin, speedin.
4. `vow:EY` — 13 pairs (END 0, INNER 13). Words: make, ain't, apes, changed, trey, always, tape, playin.
5. `slant:IY:nas` — 12 pairs (END 6, INNER 6). Words: tryna, seen, schemin, breathin, bleedin, season, speedin, cheatin.
6. `slant:AA:stop` — 11 pairs (END 1, INNER 10). Words: got, chop, knock, glock, opp, not, exotic, want.
7. `slant:IH:stop` — 9 pairs (END 0, INNER 9). Words: nigga, wit, big, dripped, shit, fifty.
8. `vow:AA` — 9 pairs (END 0, INNER 9). Words: shots, rah, stop, opp, cars, got, want, glock.
9. `vow:UW` — 8 pairs (END 6, INNER 2). Words: jewelry, shootin, movie, louis, shoot, through, shooter, two.
10. `slant:AH:fric-nas` — 6 pairs (END 0, INNER 6). Words: love, money, cuff, summer, suvy, dumb, gun.
11. `cmu:AA-P` — 5 pairs (END 0, INNER 5). Words: opp, chop, pop, stop.
12. `slant:EH:liq-stop` — 5 pairs (END 0, INNER 5). Words: get, fell, yellow, tell, said, let, head.
13. `slant:EY:stop` — 5 pairs (END 0, INNER 5). Words: ain't, changed.
14. `slant:IH:liq-stop` — 5 pairs (END 0, INNER 5). Words: still, wit, big, until.
15. `slant:IH:sib-stop` — 5 pairs (END 0, INNER 5). Words: wit, switch, bitch, swish, big, which, shit.
16. `slant:OW:sib-stop` — 5 pairs (END 4, INNER 1). Words: close, coat, most, ghost, hope, boats.
17. `slant:AH:nas-stop` — 4 pairs (END 0, INNER 4). Words: fuck, come, dub, money, summer.
18. `slant:OW:stop` — 4 pairs (END 2, INNER 2). Words: coat, ghost, don't, dope, hold, load.
19. `vow:IH` — 4 pairs (END 0, INNER 4). Words: fifty, still, big, everything.
20. `slant:AH:fric-stop` — 3 pairs (END 1, INNER 2). Words: love, dub, fuck, cuff.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 7 pair sides, mostly spelling via spelling phonetic key, often with seen (3)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with wit (3)
- toolie — 5 pair sides, mostly spelling via spelling phonetic key, often with movie (1)
- suvy — 4 pair sides, mostly vowel via spelling phonetic key, often with fifty (1)
- sleez — 3 pair sides, mostly spelling via spelling phonetic key, often with bs (1)
- treeshas — 1 pair sides, mostly vowel via spelling phonetic key, often with tryna (1)
- jawn — 1 pair sides, mostly spelling via spelling phonetic key, often with foreign (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Rah Swish | Load It (Original) | 42 | 67 | 188 | loose |
