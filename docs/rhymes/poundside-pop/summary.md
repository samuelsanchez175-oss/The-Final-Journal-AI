# Poundside Pop rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Poundside Pop
- Songs: 1
- Bars kept (Poundside Pop lyric lines): 43
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Poundside Pop.
- Credit strings: Poundside Pop.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 144
- REPEAT pairs, recorded separately: 10
- END rhymes: 36
- INNER rhymes: 108

By match:

- PERFECT: 13 (END 6, INNER 7)
- SLANT: 56 (END 14, INNER 42)
- ASSONANCE: 71 (END 16, INNER 55)
- MULTI: 4 (END 0, INNER 4)

By confidence:

- HIGH: 16
- MED: 122
- LOW: 6

## Core

- Core Y: 144
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 62 (43.1%)
- vowel: 71 (49.3%)
- spelling: 7 (4.9%)
- multi: 4 (2.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 19 pairs (END 5, INNER 14). Words: killers, bitch, wrist, little, him, rick, different, king.
2. `vow:AY` — 18 pairs (END 7, INNER 11). Words: mind, high, why, buy, miles, i'll, dime, signed.
3. `vow:EH` — 13 pairs (END 1, INNER 12). Words: respectful, heaven, send, there, let, adventure, best, ever.
4. `slant:IH:sib-stop` — 11 pairs (END 3, INNER 8). Words: bitch, shit, wit, rich, rick.
5. `vow:OW` — 9 pairs (END 0, INNER 9). Words: don't, old, though, hoe, no, only, show.
6. `slant:IH:stop` — 6 pairs (END 5, INNER 1). Words: shit, nigga, rick, kick, wrist.
7. `cmu:OW` — 4 pairs (END 0, INNER 4). Words: though, hoe, no, show, bro.
8. `slant:AY:nas-stop` — 4 pairs (END 0, INNER 4). Words: like, time, dime.
9. `vow:AA` — 4 pairs (END 3, INNER 1). Words: odds, wok, barter, got, cars, rock, roc.
10. `cmu:IH-CH` — 3 pairs (END 3, INNER 0). Words: rich, bitch.
11. `slant:AA:stop` — 3 pairs (END 0, INNER 3). Words: want, bought, roc, shot.
12. `slant:AE:sib-stop` — 3 pairs (END 0, INNER 3). Words: catch, rat, clap.
13. `slant:ER:sib-stop` — 3 pairs (END 1, INNER 2). Words: murderers, sturdy, heard, murder.
14. `slant:IH:nas-stop` — 3 pairs (END 0, INNER 3). Words: shit, him, king, rick.
15. `vow:IY` — 3 pairs (END 0, INNER 3). Words: even, belize, reason, three, feel, p.
16. `cmu:AY-M` — 2 pairs (END 2, INNER 0). Words: time, dime.
17. `multi:AO-R-T-IY` — 2 pairs (END 0, INNER 2). Words: forty, morty, thought forty, rick morty.
18. `multi:EH-V-ER` — 2 pairs (END 0, INNER 2). Words: ain't ever, ain't never, ever, never.
19. `slant:AA:nas-stop` — 2 pairs (END 1, INNER 1). Words: mom, roc, shot.
20. `slant:AE:stop` — 2 pairs (END 1, INNER 1). Words: hat, bad, rat, clap.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- fiv — 2 pair sides, mostly spelling via spelling phonetic key, often with lik (1)
- lik — 2 pair sides, mostly spelling via spelling phonetic key, often with fiv (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with dont (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Poundside Pop | Back To The Future* | 43 | 36 | 108 | loose |
