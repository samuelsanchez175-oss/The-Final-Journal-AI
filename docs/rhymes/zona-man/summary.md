# Zona Man rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Zona Man
- Songs: 1
- Bars kept (Zona Man lyric lines): 42
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Zona Man.
- Credit strings: Zona Man.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 445
- REPEAT pairs, recorded separately: 40
- END rhymes: 67
- INNER rhymes: 378

By match:

- PERFECT: 40 (END 14, INNER 26)
- SLANT: 218 (END 35, INNER 183)
- ASSONANCE: 184 (END 17, INNER 167)
- MULTI: 3 (END 1, INNER 2)

By confidence:

- HIGH: 40
- MED: 387
- LOW: 18

## Core

- Core Y: 439
- Core N among rhyme pairs: 6

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 243 (54.6%)
- vowel: 184 (41.3%)
- spelling: 15 (3.4%)
- multi: 3 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 59 pairs (END 9, INNER 50). Words: shit, think, decision, wrist, position, big, tuition, sister.
2. `vow:OW` — 31 pairs (END 3, INNER 28). Words: don't, gold, bro, rolls, know, rolling, no, hoes.
3. `slant:AY:stop` — 26 pairs (END 6, INNER 20). Words: like, tired, quiet, inside, right, light, night, excited.
4. `vow:EY` — 22 pairs (END 0, INNER 22). Words: pay, ain't, game, make, take, way, lay, wait.
5. `slant:IH:stop` — 20 pairs (END 3, INNER 17). Words: shit, wrist, whip, big, nigga, brick, split.
6. `vow:IY` — 20 pairs (END 5, INNER 15). Words: see, t, three, feet, ease, cheese, east, streets.
7. `vow:EH` — 16 pairs (END 0, INNER 16). Words: went, spend, legend, m's, everywhere, neck, care, never.
8. `cmu:AY-D` — 11 pairs (END 6, INNER 5). Words: inside, died, pride, side, ride.
9. `slant:AE:stop` — 11 pairs (END 0, INNER 11). Words: had, back, strapped, trap, trapped, wrapped, tractor, wrapper.
10. `slant:AY:fric-stop` — 9 pairs (END 2, INNER 7). Words: life, like, alive, pride, inside, light, night, right.
11. `slant:AY:nas-stop` — 9 pairs (END 3, INNER 6). Words: lying, pride, nine, inside, mine, spine, side, ride.
12. `slant:EH:nas-stop` — 9 pairs (END 0, INNER 9). Words: when, said, get, let, spent.
13. `vow:AY` — 9 pairs (END 0, INNER 9). Words: shy, life, excited, died, tired, inside, quiet, light.
14. `slant:IY:sib-stop` — 8 pairs (END 7, INNER 1). Words: cheese, heat, ease, feet, street, streets, cheap.
15. `slant:AY:sib-stop` — 7 pairs (END 6, INNER 1). Words: eyes, pride, inside, side, ride, died, tired, quiet.
16. `slant:EY:nas-stop` — 7 pairs (END 0, INNER 7). Words: game, make, plane, wait, take.
17. `cmu:AY-T` — 6 pairs (END 0, INNER 6). Words: night, light, right, write.
18. `slant:EY:fric-liq` — 6 pairs (END 0, INNER 6). Words: mail, trailer, save, safer, safe.
19. `slant:EY:fric-stop` — 6 pairs (END 0, INNER 6). Words: make, save, safer, safe, wait.
20. `vow:AA` — 6 pairs (END 0, INNER 6). Words: started, soft, oz, harder, dropped, momma, stop, block.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 8 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- bros — 5 pair sides, mostly spelling via spelling phonetic key, often with hoes (1)
- nigga — 4 pair sides, mostly spelling via spelling phonetic key, often with killa (1)
- blingin — 3 pair sides, mostly vowel via spelling phonetic key, often with flip (1)
- killa — 1 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Zona Man | How I Started | 42 | 67 | 378 | loose |
