# Charlie Sloth rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Charlie Sloth
- Songs: 1
- Bars kept (Charlie Sloth lyric lines): 26
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Charlie Sloth.
- Credit strings: Charlie Sloth.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 278
- REPEAT pairs, recorded separately: 18
- END rhymes: 48
- INNER rhymes: 230

By match:

- PERFECT: 31 (END 10, INNER 21)
- SLANT: 137 (END 28, INNER 109)
- ASSONANCE: 110 (END 10, INNER 100)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 31
- MED: 231
- LOW: 16

## Core

- Core Y: 276
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 154 (55.4%)
- vowel: 110 (39.6%)
- spelling: 14 (5.0%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 28 pairs (END 0, INNER 28). Words: million, whips, chillin, bitch, stick, rim, city, drip.
2. `vow:AE` — 21 pairs (END 1, INNER 20). Words: back, actin, example, pacman, can, bang, sack, rappin.
3. `vow:AH` — 21 pairs (END 9, INNER 12). Words: somethin, hundred, hustlers, fun, hunt, comin, gun, run.
4. `vow:EY` — 18 pairs (END 0, INNER 18). Words: play, change, stay, dake, decade, lame, made, range.
5. `slant:IH:stop` — 14 pairs (END 2, INNER 12). Words: big, nigga, bigger, stick, drip, city, whip, chip.
6. `slant:EY:nas-stop` — 13 pairs (END 0, INNER 13). Words: made, hate, brain, lame, exaggerate, fame, lane, came.
7. `slant:IH:liq-stop` — 11 pairs (END 0, INNER 11). Words: lil, big, bigger, chill, still, drip, stick, whip.
8. `slant:IH:nas-stop` — 10 pairs (END 8, INNER 2). Words: rim, slip, stick, whip, chip.
9. `slant:IH:sib-stop` — 10 pairs (END 2, INNER 8). Words: bitch, drip, whips, whip, chip, slip, city, stick.
10. `slant:EY:nas` — 9 pairs (END 6, INNER 3). Words: lane, game, pain, brain, lame, fame, came.
11. `vow:AA` — 9 pairs (END 0, INNER 9). Words: watchin, nothin, glock, rock, block, got, lot.
12. `vow:IY` — 9 pairs (END 0, INNER 9). Words: probably, beefin, real, feel, deal, need, steal.
13. `slant:AH:nas` — 8 pairs (END 8, INNER 0). Words: comin, somethin, runnin, fun.
14. `cmu:EY-M` — 6 pairs (END 4, INNER 2). Words: came, lame, game, fame.
15. `cmu:IY-L` — 6 pairs (END 0, INNER 6). Words: real, steal, feel, deal.
16. `slant:EY:nas-sib` — 6 pairs (END 0, INNER 6). Words: chase, brain, change, lame, fame, lane, came.
17. `slant:EY:stop` — 5 pairs (END 0, INNER 5). Words: exaggerate, dake, decade, made, hate.
18. `slant:IH:liq-nas` — 5 pairs (END 0, INNER 5). Words: chill, him, still, rim, chillin.
19. `slant:AA:stop` — 4 pairs (END 0, INNER 4). Words: got, heart, lot, glock, rock, block.
20. `slant:IY:liq-nas` — 4 pairs (END 0, INNER 4). Words: tryna, real, steal, feel.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with big (5)
- tryna — 5 pair sides, mostly spelling via spelling phonetic key, often with real (2)
- bulletproofed — 2 pair sides, mostly vowel via spelling phonetic key, often with some (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Charlie Sloth | Fire in the Booth, Pt. 1 | 26 | 48 | 230 | loose |
