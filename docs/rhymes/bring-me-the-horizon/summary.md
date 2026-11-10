# Bring Me The Horizon rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Bring Me The Horizon
- Songs: 1
- Bars kept (Bring Me The Horizon lyric lines): 34
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Bring Me The Horizon.
- Credit strings: Bring Me The Horizon.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 82
- REPEAT pairs, recorded separately: 7
- END rhymes: 21
- INNER rhymes: 61

By match:

- PERFECT: 8 (END 3, INNER 5)
- SLANT: 23 (END 3, INNER 20)
- ASSONANCE: 48 (END 14, INNER 34)
- MULTI: 3 (END 1, INNER 2)

By confidence:

- HIGH: 11
- MED: 71
- LOW: 0

## Core

- Core Y: 82
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 31 (37.8%)
- vowel: 48 (58.5%)
- spelling: 0 (0.0%)
- multi: 3 (3.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 27 pairs (END 13, INNER 14). Words: exorcist, heretic, friends, tell, nex, amen, possessed, heresy.
2. `vow:IH` — 6 pairs (END 0, INNER 6). Words: will, wicked, kingdom, everything, till.
3. `vow:AH` — 5 pairs (END 1, INNER 4). Words: corrupted, come, done, judgment, suffer.
4. `vow:EY` — 5 pairs (END 0, INNER 5). Words: prey, patiently, hate, waiting.
5. `slant:EH:stop` — 4 pairs (END 0, INNER 4). Words: get, head, end, repent, possessed, let.
6. `multi:AH-F-AY` — 3 pairs (END 1, INNER 2). Words: sanctify, purify, will sanctify, sanctify purify.
7. `vow:IY` — 3 pairs (END 0, INNER 3). Words: feeling, bleed, centipede, breathe.
8. `cmu:IH-L` — 2 pairs (END 0, INNER 2). Words: will, till.
9. `slant:EH:nas-stop` — 2 pairs (END 0, INNER 2). Words: get, gen, amen.
10. `slant:IH:liq-nas` — 2 pairs (END 0, INNER 2). Words: will, everything, sing.
11. `slant:IY:sib-stop` — 2 pairs (END 2, INNER 0). Words: breathe, bleed, centipede.
12. `cmu:AO-L` — 1 pairs (END 0, INNER 1). Words: all, call.
13. `cmu:EH-L` — 1 pairs (END 1, INNER 0). Words: hell, infidel.
14. `cmu:EH-N` — 1 pairs (END 1, INNER 0). Words: gen, amen.
15. `cmu:EH-T` — 1 pairs (END 0, INNER 1). Words: get, let.
16. `cmu:EY` — 1 pairs (END 0, INNER 1). Words: stay, away.
17. `cmu:IY-D` — 1 pairs (END 1, INNER 0). Words: bleed, centipede.
18. `slant:AA:sib-stop` — 1 pairs (END 0, INNER 1). Words: watch, got.
19. `slant:AH:fric-nas` — 1 pairs (END 1, INNER 0). Words: suffer, come.
20. `slant:AH:fric-stop` — 1 pairs (END 0, INNER 1). Words: blood, suffer.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- None.

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Bring Me The Horizon | AmEN! | 34 | 21 | 61 | loose |
