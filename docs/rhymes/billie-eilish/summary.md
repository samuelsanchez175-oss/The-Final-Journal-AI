# Billie Eilish rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Billie Eilish
- Songs: 1
- Bars kept (Billie Eilish lyric lines): 27
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Billie Eilish.
- Credit strings: Billie Eilish.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 46
- REPEAT pairs, recorded separately: 5
- END rhymes: 11
- INNER rhymes: 35

By match:

- PERFECT: 0 (END 0, INNER 0)
- SLANT: 14 (END 5, INNER 9)
- ASSONANCE: 32 (END 6, INNER 26)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 0
- MED: 46
- LOW: 0

## Core

- Core Y: 46
- Core N among rhyme pairs: 0

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 14 (30.4%)
- vowel: 32 (69.6%)
- spelling: 0 (0.0%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 19 pairs (END 4, INNER 15). Words: know, lonely, supposedly, supposed, don't, home, focus, alone.
2. `vow:EH` — 7 pairs (END 0, INNER 7). Words: anybody, get, check, else, myself, complexion, reflection's.
3. `vow:AE` — 3 pairs (END 2, INNER 1). Words: unhappy, had, can't, answer, handsome.
4. `slant:AE:sib-stop` — 2 pairs (END 0, INNER 2). Words: can't, plans.
5. `slant:IY:liq-nas` — 2 pairs (END 0, INNER 2). Words: seem, here.
6. `slant:AA:nas-stop` — 1 pairs (END 0, INNER 1). Words: not, wanna.
7. `slant:AE:nas-sib` — 1 pairs (END 1, INNER 0). Words: answer, handsome.
8. `slant:AY:fric-stop` — 1 pairs (END 0, INNER 1). Words: drive, invite.
9. `slant:EH:fric-sib` — 1 pairs (END 1, INNER 0). Words: else, myself.
10. `slant:EH:nas-sib` — 1 pairs (END 0, INNER 1). Words: complexion, reflection's.
11. `slant:EH:nas-stop` — 1 pairs (END 1, INNER 0). Words: better, again.
12. `slant:IY:liq-stop` — 1 pairs (END 1, INNER 0). Words: hear, meet.
13. `slant:OW:liq-stop` — 1 pairs (END 0, INNER 1). Words: supposedly, supposed.
14. `slant:OW:nas` — 1 pairs (END 1, INNER 0). Words: alone, home.
15. `slant:OW:sib` — 1 pairs (END 0, INNER 1). Words: focus, notice.
16. `vow:AH` — 1 pairs (END 0, INNER 1). Words: comin, love.
17. `vow:EY` — 1 pairs (END 0, INNER 1). Words: changed, wait.
18. `vow:IY` — 1 pairs (END 0, INNER 1). Words: here, see.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- None.

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Billie Eilish | my future | 27 | 11 | 35 | loose |
