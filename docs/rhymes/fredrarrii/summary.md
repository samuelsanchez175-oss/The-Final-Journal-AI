# FredRarrii rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: FredRarrii
- Songs: 3
- Bars kept (FredRarrii lyric lines): 87
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: FredRarrii.
- Credit strings: FredRarrii.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 430
- REPEAT pairs, recorded separately: 93
- END rhymes: 93
- INNER rhymes: 337

By match:

- PERFECT: 39 (END 8, INNER 31)
- SLANT: 161 (END 38, INNER 123)
- ASSONANCE: 230 (END 47, INNER 183)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 31
- MED: 369
- LOW: 30

## Core

- Core Y: 415
- Core N among rhyme pairs: 15

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 177 (41.2%)
- vowel: 230 (53.5%)
- spelling: 23 (5.3%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 52 pairs (END 0, INNER 52). Words: ain't, pain, lay, places, take, stay, came, changed.
2. `vow:AW` — 49 pairs (END 41, INNER 8). Words: now, down, rounds, house, how, around.
3. `vow:AA` — 29 pairs (END 0, INNER 29). Words: want, dada, bottles, problems, dollar, robbing, starving, got.
4. `vow:IH` — 22 pairs (END 0, INNER 22). Words: bitches, give, million, nigga, finna, since, him, city.
5. `vow:OW` — 22 pairs (END 0, INNER 22). Words: know, don't, no, gold, extendo, glocks, cold, won't.
6. `vow:AE` — 16 pairs (END 1, INNER 15). Words: fast, can't, dash, gang, balenciaga, back, had, have.
7. `vow:IY` — 15 pairs (END 2, INNER 13). Words: evening, people, season, need, see, teen, eating, scene.
8. `slant:IH:sib-stop` — 12 pairs (END 4, INNER 8). Words: shit, bitch, nigga, niggas.
9. `slant:AE:sib-stop` — 11 pairs (END 0, INNER 11). Words: ass, dash, had, back, fast, can't, fans, tab.
10. `vow:AH` — 11 pairs (END 3, INNER 8). Words: hundreds, dub, hugs, club, double, son, plug, muscle.
11. `slant:EY:stop` — 10 pairs (END 1, INNER 9). Words: take, state, baby, changed, ain't, make, naked.
12. `vow:EH` — 10 pairs (END 0, INNER 10). Words: prayers, best, let, head, never, remember, get, step.
13. `slant:AH:fric-stop` — 9 pairs (END 9, INNER 0). Words: love, dub, blood, plug, club.
14. `cmu:OW` — 7 pairs (END 0, INNER 7). Words: know, no, go, ho.
15. `slant:EY:nas-stop` — 7 pairs (END 0, INNER 7). Words: ain't, pain, make, rain, praying, main.
16. `slant:IH:liq-sib` — 7 pairs (END 1, INNER 6). Words: lil, bitch, hills, phil, really.
17. `cmu:IY-L` — 6 pairs (END 4, INNER 2). Words: real, squeel, feel.
18. `slant:IH:stop` — 6 pairs (END 0, INNER 6). Words: shit, nigga, hip, crib, big.
19. `slant:AE:stop` — 5 pairs (END 0, INNER 5). Words: stack, bad, dap, back, had, fast, mask.
20. `slant:AH:stop` — 5 pairs (END 5, INNER 0). Words: plug, dub, blood, club.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with finna (3)
- squeel — 5 pair sides, mostly spelling via spelling phonetic key, often with real (5)
- geeni — 4 pair sides, mostly spelling via spelling phonetic key, often with evening (1)
- extendo — 4 pair sides, mostly vowel via spelling phonetic key, often with know (3)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- finna — 3 pair sides, mostly vowel via spelling phonetic key, often with nigga (3)
- meechi — 3 pair sides, mostly spelling via spelling phonetic key, often with leeshes (1)
- glocks — 3 pair sides, mostly vowel via spelling phonetic key, often with know (3)
- balenciaga — 2 pair sides, mostly vowel via spelling phonetic key, often with back (1)
- dap — 2 pair sides, mostly spelling via spelling phonetic key, often with stack (1)
- swerving — 2 pair sides, mostly spelling via spelling phonetic key, often with praying (1)
- leeshes — 2 pair sides, mostly spelling via spelling phonetic key, often with meechi (1)
- leeses — 2 pair sides, mostly spelling via spelling phonetic key, often with meechi (1)
- silant — 2 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)
- cieling — 1 pair sides, mostly spelling via spelling phonetic key, often with million (1)
- yfn — 1 pair sides, mostly spelling via spelling phonetic key, often with seen (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| FredRarrii | Balenciaga | 31 | 33 | 117 | loose |
| FredRarrii | Lay It Down | 28 | 47 | 110 | loose |
| FredRarrii | Project Baby | 28 | 13 | 110 | loose |
