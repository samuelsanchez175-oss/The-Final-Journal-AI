# Skazz rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Skazz
- Songs: 1
- Bars kept (Skazz lyric lines): 87
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Skazz.
- Credit strings: Skazz.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 220
- REPEAT pairs, recorded separately: 23
- END rhymes: 55
- INNER rhymes: 165

By match:

- PERFECT: 24 (END 13, INNER 11)
- SLANT: 77 (END 14, INNER 63)
- ASSONANCE: 116 (END 28, INNER 88)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 26
- MED: 187
- LOW: 7

## Core

- Core Y: 219
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 93 (42.3%)
- vowel: 116 (52.7%)
- spelling: 8 (3.6%)
- multi: 3 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 26 pairs (END 7, INNER 19). Words: golf, want, partners, projects, boss, lotta, got, body.
2. `vow:EY` — 23 pairs (END 5, INNER 18). Words: today, ain’t, crazy, lately, patience, hated, stay, say.
3. `vow:IY` — 21 pairs (END 3, INNER 18). Words: free, keep, see, ni, 100s, real, lamborghini, even.
4. `vow:AY` — 18 pairs (END 1, INNER 17). Words: like, shining, lights, grinding, fight, ion, stylist, styling.
5. `slant:AY:stop` — 13 pairs (END 0, INNER 13). Words: like, type, fight, tonight, spider, light, white, night.
6. `vow:AH` — 12 pairs (END 7, INNER 5). Words: money, hustle, bugging, frontin, number, none, fuck, what.
7. `slant:AA:stop` — 11 pairs (END 1, INNER 10). Words: got, gotta, lotta, pocket, lot, hop, body, want.
8. `cmu:AY-T` — 8 pairs (END 6, INNER 2). Words: white, night, tonight, fight, light.
9. `slant:IH:stop` — 8 pairs (END 3, INNER 5). Words: ticket, big, shit, winter, mink, nigga, dick.
10. `slant:AA:sib-stop` — 5 pairs (END 0, INNER 5). Words: cause, boss, hop, drop, top, got, stop.
11. `vow:OW` — 5 pairs (END 0, INNER 5). Words: don’t, know, no, most, only.
12. `cmu:IY` — 4 pairs (END 1, INNER 3). Words: see, 100s, free.
13. `vow:AW` — 4 pairs (END 3, INNER 1). Words: now, down, round, how.
14. `cmu:EY` — 3 pairs (END 1, INNER 2). Words: play, say, way, stay.
15. `cmu:UW` — 3 pairs (END 3, INNER 0). Words: through, crew, finna.
16. `multi:EY-IH-NG` — 3 pairs (END 0, INNER 3). Words: laying, playing, ain’t laying, no playing.
17. `slant:AA:liq-stop` — 3 pairs (END 0, INNER 3). Words: maro, drop, top, got.
18. `slant:AA:nas-stop` — 3 pairs (END 0, INNER 3). Words: momma, fog, gotta, got.
19. `slant:AH:nas-stop` — 3 pairs (END 0, INNER 3). Words: none, what, fuck, some.
20. `slant:AY:sib-stop` — 3 pairs (END 3, INNER 0). Words: lights, night, tonight, fight.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- 100s — 5 pair sides, mostly vowel via vault phonetic_class, often with keep (3)
- finna — 2 pair sides, mostly cmu via vault phonetic_class, often with through (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with big (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with even (1)
- ebt — 1 pair sides, mostly spelling via spelling phonetic key, often with get (1)
- nigga — 1 pair sides, mostly spelling via spelling phonetic key, often with ticket (1)
- stunting — 1 pair sides, mostly spelling via spelling phonetic key, often with counting (1)
- shiesty — 1 pair sides, mostly vowel via spelling phonetic key, often with ni (1)
- skazz — 1 pair sides, mostly spelling via spelling phonetic key, often with shabazz (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Skazz | Play | 87 | 55 | 165 | loose |
