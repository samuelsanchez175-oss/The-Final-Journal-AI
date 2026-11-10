# Just Rich Gates rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Just Rich Gates
- Songs: 1
- Bars kept (Just Rich Gates lyric lines): 36
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Just Rich Gates.
- Credit strings: Just Rich Gates.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 222
- REPEAT pairs, recorded separately: 18
- END rhymes: 31
- INNER rhymes: 191

By match:

- PERFECT: 25 (END 11, INNER 14)
- SLANT: 108 (END 14, INNER 94)
- ASSONANCE: 89 (END 6, INNER 83)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 21
- MED: 181
- LOW: 20

## Core

- Core Y: 214
- Core N among rhyme pairs: 8

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 117 (52.7%)
- vowel: 89 (40.1%)
- spelling: 16 (7.2%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 25 pairs (END 3, INNER 22). Words: bitch, six, shit, finessing, sipping, sniffing, literally, spill.
2. `slant:AH:stop` — 20 pairs (END 5, INNER 15). Words: fuck, what, fucked, cup, tucked, club, starstruck, plug.
3. `vow:AE` — 13 pairs (END 0, INNER 13). Words: dancing, grams, trap, bands, splashing, man, crack, grab.
4. `vow:AH` — 12 pairs (END 0, INNER 12). Words: double, coming, starbucks, money, suck, cup, run, dunk.
5. `slant:IH:stop` — 11 pairs (END 0, INNER 11). Words: nigga, shit, hip, brick, sick.
6. `slant:AE:nas-stop` — 10 pairs (END 0, INNER 10). Words: trap, man, rap, black, slam, batman, van, tarzan.
7. `vow:OW` — 10 pairs (END 0, INNER 10). Words: don't, know, whole, blow, smoke, zoe, going, zone.
8. `vow:AO` — 9 pairs (END 1, INNER 8). Words: forth, seesaw, gone, long, t'd.
9. `slant:IH:sib-stop` — 8 pairs (END 3, INNER 5). Words: bitch, sick, shit, sticks, brick, tricks, six, dick.
10. `slant:AH:sib-stop` — 7 pairs (END 2, INNER 5). Words: starbucks, cus, lucked, starstruck, fucked, suck, club, fuck.
11. `vow:AY` — 7 pairs (END 1, INNER 6). Words: high, diamonds, like, excited, island, side, why, night.
12. `slant:AH:nas` — 6 pairs (END 0, INNER 6). Words: run, money, coming, young, dummy.
13. `slant:AH:nas-stop` — 6 pairs (END 0, INNER 6). Words: run, money, cup, fuck, suck, what.
14. `vow:IY` — 5 pairs (END 1, INNER 4). Words: brazy, green, see, sea, dummy, pussy, ski, queen.
15. `cmu:IH-K-S` — 4 pairs (END 3, INNER 1). Words: six, sticks, tricks.
16. `slant:IH:sib` — 4 pairs (END 4, INNER 0). Words: piss, bitch, six, rich.
17. `cmu:AA-T` — 3 pairs (END 0, INNER 3). Words: got, pot, lot.
18. `cmu:AE-N` — 3 pairs (END 3, INNER 0). Words: batman, van, tarzan.
19. `cmu:IH-NG` — 3 pairs (END 0, INNER 3). Words: finessing, splashing, dancing, moving.
20. `vow:AA` — 3 pairs (END 0, INNER 3). Words: got, bahamas, squad, want.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 9 pair sides, mostly spelling via spelling phonetic key, often with shit (5)
- finessing — 8 pair sides, mostly vowel via spelling phonetic key, often with sticks (1)
- td — 4 pair sides, mostly vowel via vault phonetic_class, often with seesaw (1)
- brazy — 4 pair sides, mostly vowel via spelling phonetic key, often with sea (1)
- lockjaw — 1 pair sides, mostly spelling via spelling phonetic key, often with seesaw (1)
- keyon — 1 pair sides, mostly spelling via spelling phonetic key, often with main (1)
- yop — 1 pair sides, mostly spelling via spelling phonetic key, often with knees (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Just Rich Gates | 21 Gates | 36 | 31 | 191 | loose |
