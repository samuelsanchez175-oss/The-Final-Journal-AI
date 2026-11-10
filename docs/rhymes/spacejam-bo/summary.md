# Spacejam Bo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Spacejam Bo
- Songs: 1
- Bars kept (Spacejam Bo lyric lines): 54
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Spacejam Bo.
- Credit strings: Spacejam Bo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 238
- REPEAT pairs, recorded separately: 25
- END rhymes: 85
- INNER rhymes: 153

By match:

- PERFECT: 18 (END 9, INNER 9)
- SLANT: 95 (END 33, INNER 62)
- ASSONANCE: 101 (END 19, INNER 82)
- MULTI: 24 (END 24, INNER 0)

By confidence:

- HIGH: 39
- MED: 189
- LOW: 10

## Core

- Core Y: 235
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 103 (43.3%)
- vowel: 101 (42.4%)
- spelling: 10 (4.2%)
- multi: 24 (10.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AY` — 27 pairs (END 11, INNER 16). Words: child, diamonds, mind, kind, lying, buying, ridin, life.
2. `multi:AY-IH-NG` — 24 pairs (END 24, INNER 0). Words: lying, buying, flying, spying, cryin, crying, trying.
3. `slant:AY:nas-stop` — 15 pairs (END 10, INNER 5). Words: quite, line, homicide, lying, cryin, buying, mind, hide.
4. `vow:EH` — 14 pairs (END 3, INNER 11). Words: remember, trenches, when, send, hell, twelve, get, getting.
5. `vow:IH` — 13 pairs (END 2, INNER 11). Words: shit, bitches, livin, explicit, slippin, mission, city, trippin.
6. `vow:OW` — 12 pairs (END 0, INNER 12). Words: don't, know, go, home, bro, old, going, blow.
7. `slant:AY:nas` — 10 pairs (END 10, INNER 0). Words: line, trying, buying, crying, flying, lying, spying, ridin.
8. `vow:EY` — 10 pairs (END 0, INNER 10). Words: ain't, stay, played, way, came, play, days, grade.
9. `vow:AH` — 8 pairs (END 3, INNER 5). Words: money, hundreds, run, papa, junkie, ca.
10. `slant:AH:nas-stop` — 7 pairs (END 2, INNER 5). Words: money, what, flunkie, some, gun.
11. `slant:EH:stop` — 7 pairs (END 0, INNER 7). Words: ready, get, check, head, send.
12. `slant:AH:nas` — 6 pairs (END 0, INNER 6). Words: money, some, gun, run.
13. `cmu:AY-D` — 5 pairs (END 5, INNER 0). Words: ride, slide, side, homicide.
14. `cmu:OW` — 5 pairs (END 0, INNER 5). Words: know, go, bro.
15. `slant:AY:stop` — 5 pairs (END 5, INNER 0). Words: behind, side, ride, slide, homicide, kind, hide.
16. `slant:EH:liq-stop` — 5 pairs (END 0, INNER 5). Words: where, ready, tell, head, check, get.
17. `vow:AA` — 5 pairs (END 0, INNER 5). Words: bars, locked, want, rock, star, god, not.
18. `slant:AA:stop` — 4 pairs (END 0, INNER 4). Words: god, not, locked, stop, gotta.
19. `slant:EH:nas-stop` — 4 pairs (END 0, INNER 4). Words: getting, get, em, ready, head.
20. `slant:IH:stop` — 4 pairs (END 0, INNER 4). Words: shit, nigga, city, explicit.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- flunkie — 3 pair sides, mostly spelling via spelling phonetic key, often with money (2)
- glizzy — 3 pair sides, mostly vowel via spelling phonetic key, often with city (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- bih — 1 pair sides, mostly spelling via spelling phonetic key, often with lil (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with pole (1)
- jocien — 1 pair sides, mostly spelling via spelling phonetic key, often with when (1)
- remeber — 1 pair sides, mostly vowel via spelling phonetic key, often with when (1)
- forein — 1 pair sides, mostly spelling via spelling phonetic key, often with pullin (1)
- swea — 1 pair sides, mostly vowel via spelling phonetic key, often with glizzy (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Spacejam Bo | New Money | 54 | 85 | 153 | loose |
