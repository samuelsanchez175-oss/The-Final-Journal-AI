# HXLLYWOOD rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: HXLLYWOOD
- Songs: 1
- Bars kept (HXLLYWOOD lyric lines): 56
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: HXLLYWOOD.
- Credit strings: HXLLYWOOD.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 236
- REPEAT pairs, recorded separately: 55
- END rhymes: 37
- INNER rhymes: 199

By match:

- PERFECT: 29 (END 8, INNER 21)
- SLANT: 133 (END 25, INNER 108)
- ASSONANCE: 74 (END 4, INNER 70)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 27
- MED: 204
- LOW: 5

## Core

- Core Y: 235
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 154 (65.3%)
- vowel: 74 (31.4%)
- spelling: 8 (3.4%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:AE:stop` — 48 pairs (END 6, INNER 42). Words: act, back, cat, fat, tat, rat, had, pack.
2. `vow:EY` — 21 pairs (END 0, INNER 21). Words: ain’t, same, day, paying, say, make, h, play.
3. `vow:IH` — 13 pairs (END 1, INNER 12). Words: link, minimum, bitch, shit, fin, think, hitting, give.
4. `vow:AE` — 10 pairs (END 2, INNER 8). Words: attached, back, pants, can’t, plan, band, crack, track.
5. `vow:EH` — 7 pairs (END 0, INNER 7). Words: already, friends, spend, remember, beserk, let, bare, benz.
6. `cmu:AE-K` — 6 pairs (END 1, INNER 5). Words: back, crack, track, pack.
7. `cmu:AE-T` — 6 pairs (END 3, INNER 3). Words: fat, cat, tat, rat.
8. `slant:ER:stop` — 6 pairs (END 0, INNER 6). Words: hurt, squirt, twerk, work, jerk.
9. `vow:IY` — 6 pairs (END 0, INNER 6). Words: see, sneaky, b, street, freak, freaky, key.
10. `slant:AH:stop` — 5 pairs (END 0, INNER 5). Words: fuck, what, fucked.
11. `slant:IY:stop` — 5 pairs (END 1, INNER 4). Words: street, freak, freaky, sneaky.
12. `slant:UW:sib` — 5 pairs (END 3, INNER 2). Words: abuse, accuse, use, lose, choose, blues.
13. `slant:AH:nas-stop` — 4 pairs (END 0, INNER 4). Words: fuck, money, fucking.
14. `slant:AY:nas-stop` — 4 pairs (END 0, INNER 4). Words: trying, like, ion, nike, slide.
15. `slant:AY:stop` — 4 pairs (END 0, INNER 4). Words: slide, like, nike, kind.
16. `vow:AO` — 4 pairs (END 1, INNER 3). Words: exhausted, shorty, call, thought, fault.
17. `vow:AY` — 4 pairs (END 0, INNER 4). Words: kind, trying, like, nike.
18. `vow:OW` — 4 pairs (END 0, INNER 4). Words: going, no, know, don’t.
19. `cmu:ER-K` — 3 pairs (END 1, INNER 2). Words: twerk, work, jerk.
20. `slant:AA:sib-stop` — 3 pairs (END 1, INNER 2). Words: boss, got, cost, cause.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- twerk — 4 pair sides, mostly spelling via spelling phonetic key, often with hurt (1)
- suckas — 2 pair sides, mostly spelling via spelling phonetic key, often with fuck (1)
- rebrand — 1 pair sides, mostly spelling via spelling phonetic key, often with band (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with suckas (1)
- beserk — 1 pair sides, mostly vowel via spelling phonetic key, often with remember (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| HXLLYWOOD | Sneaky Link Chicago | 56 | 37 | 199 | loose |
