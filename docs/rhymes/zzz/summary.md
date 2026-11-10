# Zzz. rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Zzz.
- Songs: 1
- Bars kept (Zzz. lyric lines): 17
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Zzz..
- Credit strings: Zzz..
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 161
- REPEAT pairs, recorded separately: 12
- END rhymes: 27
- INNER rhymes: 134

By match:

- PERFECT: 29 (END 16, INNER 13)
- SLANT: 48 (END 8, INNER 40)
- ASSONANCE: 84 (END 3, INNER 81)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 27
- MED: 132
- LOW: 2

## Core

- Core Y: 161
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 73 (45.3%)
- vowel: 84 (52.2%)
- spelling: 4 (2.5%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- AAAA: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 31 pairs (END 3, INNER 28). Words: ain't, takin, chasers, blazers, grade, major, way, safe.
2. `cmu:OW` — 24 pairs (END 14, INNER 10). Words: slow, know, low, hoe, snow, bro, though.
3. `vow:OW` — 17 pairs (END 0, INNER 17). Words: don't, throwin, told, slow, bro, know, hoe, low.
4. `vow:IH` — 12 pairs (END 0, INNER 12). Words: think, trippin, give, really, still, since, kid, scissors.
5. `slant:EY:sib-stop` — 7 pairs (END 3, INNER 4). Words: major, grade, razor, traitor, made, paper, hate.
6. `vow:EH` — 7 pairs (END 0, INNER 7). Words: left, m's, already, together, ready.
7. `slant:EY:stop` — 6 pairs (END 1, INNER 5). Words: traitor, hate, grade, ain't, paper.
8. `vow:IY` — 6 pairs (END 0, INNER 6). Words: tweakin, z, b's, g's, leave, sleep.
9. `vow:AY` — 5 pairs (END 0, INNER 5). Words: like, diamond, might, ride, lights, signed, try.
10. `slant:EY:fric-stop` — 4 pairs (END 0, INNER 4). Words: safe, paper, grade, hate, traitor.
11. `slant:EY:sib` — 4 pairs (END 4, INNER 0). Words: major, blazers, chasers.
12. `vow:AO` — 4 pairs (END 0, INNER 4). Words: draw, all, before, door.
13. `slant:AH:stop` — 3 pairs (END 0, INNER 3). Words: fuck, cut.
14. `slant:AO:liq` — 3 pairs (END 0, INNER 3). Words: all, before, door.
15. `cmu:ER-Z` — 2 pairs (END 2, INNER 0). Words: glazers, chasers, blazers.
16. `slant:AY:stop` — 2 pairs (END 0, INNER 2). Words: like, might, diamond, signed.
17. `slant:EH:nas-stop` — 2 pairs (END 0, INNER 2). Words: when, better, already.
18. `slant:EH:sib-stop` — 2 pairs (END 0, INNER 2). Words: together, already, ready.
19. `slant:EH:stop` — 2 pairs (END 0, INNER 2). Words: already, better, said.
20. `slant:IH:fric-liq` — 2 pairs (END 0, INNER 2). Words: give, really, still.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- glazers — 2 pair sides, mostly spelling via spelling phonetic key, often with chasers (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with kid (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with going (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Zzz. | Going Major | 17 | 27 | 134 | AAAA |
