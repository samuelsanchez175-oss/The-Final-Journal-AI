# Jeezy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Jeezy
- Songs: 1
- Bars kept (Jeezy lyric lines): 52
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Jeezy.
- Credit strings: Jeezy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 345
- REPEAT pairs, recorded separately: 36
- END rhymes: 47
- INNER rhymes: 298

By match:

- PERFECT: 31 (END 12, INNER 19)
- SLANT: 157 (END 15, INNER 142)
- ASSONANCE: 154 (END 19, INNER 135)
- MULTI: 3 (END 1, INNER 2)

By confidence:

- HIGH: 32
- MED: 286
- LOW: 27

## Core

- Core Y: 342
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 162 (47.0%)
- vowel: 154 (44.6%)
- spelling: 26 (7.5%)
- multi: 3 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 50 pairs (END 8, INNER 42). Words: pressure, tellin, attention, selfish, get, help, never, best.
2. `vow:IY` — 41 pairs (END 9, INNER 32). Words: see, demon, teeth, readin, these, weakness, eagle, speakin.
3. `vow:EY` — 19 pairs (END 2, INNER 17). Words: ain't, way, make, neighbors, waitin, face, anyway, stay.
4. `cmu:OW` — 14 pairs (END 8, INNER 6). Words: ago, ho, tho, bro, know, hoe, no.
5. `slant:IH:sib-stop` — 13 pairs (END 7, INNER 6). Words: shit, bitch, snitch, niggas, nigga, crib.
6. `vow:IH` — 12 pairs (END 0, INNER 12). Words: different, pinky, killed, shit, still, hit, year, think.
7. `vow:OW` — 12 pairs (END 0, INNER 12). Words: don't, no, social, whole, towin.
8. `slant:AH:nas-stop` — 10 pairs (END 0, INNER 10). Words: some, fuck, sucker, done, what.
9. `slant:IH:stop` — 10 pairs (END 0, INNER 10). Words: nigga, hit, flip, shit.
10. `slant:AA:stop` — 8 pairs (END 0, INNER 8). Words: want, bought, hop, gotta, not, got.
11. `slant:EH:stop` — 8 pairs (END 2, INNER 6). Words: better, best, get, forget, eject, jester, head, desert.
12. `vow:AY` — 8 pairs (END 0, INNER 8). Words: grindin, apply, live, by, die, time, white, like.
13. `slant:IY:nas` — 7 pairs (END 1, INNER 6). Words: gleamin, ceilin, freezin, readin, tryna, reason.
14. `slant:IY:sib-stop` — 7 pairs (END 1, INNER 6). Words: these, easy, feet, jeezy, week, beat, meet, need.
15. `slant:EY:stop` — 5 pairs (END 0, INNER 5). Words: straight, make, ain't, fake, favorite.
16. `slant:AE:fric-sib` — 4 pairs (END 0, INNER 4). Words: have, ass, class.
17. `slant:AH:stop` — 4 pairs (END 0, INNER 4). Words: fuck, what, sucker, yup.
18. `slant:AY:stop` — 4 pairs (END 2, INNER 2). Words: like, pipe, white, ride, slide, westside.
19. `slant:EH:fric-sib` — 4 pairs (END 0, INNER 4). Words: pressure, never, every.
20. `slant:EH:nas-stop` — 4 pairs (END 0, INNER 4). Words: when, get, better.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 12 pair sides, mostly spelling via spelling phonetic key, often with hit (5)
- jeezy — 6 pair sides, mostly spelling via spelling phonetic key, often with see (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with feet (1)
- rebeccas — 2 pair sides, mostly spelling via spelling phonetic key, often with extras (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with gimme (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with yall (1)
- mulsanne — 1 pair sides, mostly vowel via spelling phonetic key, often with love (1)
- blingin — 1 pair sides, mostly spelling via spelling phonetic key, often with gimme (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Jeezy | Pressure | 52 | 47 | 298 | loose |
