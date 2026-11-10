# Bankroll Mafia rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Bankroll Mafia
- Songs: 1
- Bars kept (Bankroll Mafia lyric lines): 79
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Bankroll Mafia.
- Credit strings: Bankroll Mafia.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 464
- REPEAT pairs, recorded separately: 73
- END rhymes: 103
- INNER rhymes: 361

By match:

- PERFECT: 38 (END 13, INNER 25)
- SLANT: 193 (END 57, INNER 136)
- ASSONANCE: 233 (END 33, INNER 200)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 38
- MED: 394
- LOW: 32

## Core

- Core Y: 461
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 200 (43.1%)
- vowel: 233 (50.2%)
- spelling: 31 (6.7%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 74 pairs (END 13, INNER 61). Words: know, don't, go, ho, folks, ghost, gold, lotus.
2. `vow:IH` — 51 pairs (END 8, INNER 43). Words: shit, bitch, business, wrist, fishin, whippin, mils, different.
3. `vow:AA` — 30 pairs (END 8, INNER 22). Words: want, problems, rollin, mafia, raw, cause, nothin, got.
4. `vow:EH` — 28 pairs (END 3, INNER 25). Words: regrets, many, trenches, went, ready, spendin, texaco, next.
5. `slant:IH:sib-stop` — 25 pairs (END 4, INNER 21). Words: bitch, dick, nigga, niggas, rich, lick, shit, dig.
6. `vow:AE` — 20 pairs (END 0, INNER 20). Words: savage, randy, dragon, crack, actin, stands, havin, hangin.
7. `slant:IH:stop` — 17 pairs (END 6, INNER 11). Words: shit, nigga, dig, dick, wrist, stick, kick.
8. `slant:AA:nas-stop` — 15 pairs (END 14, INNER 1). Words: wanna, want, got.
9. `vow:AY` — 14 pairs (END 0, INNER 14). Words: like, diamonds, stripes, higher, why, nice, right, rice.
10. `slant:AA:sib-stop` — 11 pairs (END 0, INNER 11). Words: got, boss, cause, not.
11. `slant:IH:nas-sib` — 11 pairs (END 0, INNER 11). Words: bitch, i'ma, snitchin, kitchen, him.
12. `slant:OW:sib-stop` — 9 pairs (END 5, INNER 4). Words: joke, hoes, stroke, rose, throat, folks, strokes.
13. `slant:AY:sib-stop` — 8 pairs (END 3, INNER 5). Words: like, mice, rice, ice, kite, nice, right.
14. `slant:AH:nas-stop` — 7 pairs (END 0, INNER 7). Words: young, nut, suck, money, some, blunt, cut.
15. `vow:AH` — 7 pairs (END 0, INNER 7). Words: some, junkies, fuckin, hundreds, comin, blunt, cut, other.
16. `slant:EY:sib-stop` — 6 pairs (END 6, INNER 0). Words: raid, wade, lays, aids, ways.
17. `cmu:AO-L` — 5 pairs (END 0, INNER 5). Words: ball, call, stall.
18. `cmu:AY-S` — 5 pairs (END 5, INNER 0). Words: rice, ice, mice, nice.
19. `cmu:IH-T` — 5 pairs (END 0, INNER 5). Words: shit, hit, spit.
20. `cmu:OW` — 5 pairs (END 0, INNER 5). Words: know, go, ho, no, throw.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 15 pair sides, mostly spelling via spelling phonetic key, often with niggas (5)
- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with bitch (6)
- niggas — 7 pair sides, mostly spelling via spelling phonetic key, often with nigga (5)
- ignant — 4 pair sides, mostly spelling via spelling phonetic key, often with want (2)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with note (1)
- mothafucka — 1 pair sides, mostly spelling via spelling phonetic key, often with mothafuckin (1)
- mothafuckin — 1 pair sides, mostly spelling via spelling phonetic key, often with mothafucka (1)
- gangbangin — 1 pair sides, mostly vowel via spelling phonetic key, often with hangin (1)
- sucka — 1 pair sides, mostly spelling via spelling phonetic key, often with cuff (1)
- hunna — 1 pair sides, mostly spelling via spelling phonetic key, often with money (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Bankroll Mafia | I Want Her | 79 | 103 | 361 | loose |
