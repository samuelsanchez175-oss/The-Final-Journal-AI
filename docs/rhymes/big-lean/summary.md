# Big Lean rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Big Lean
- Songs: 1
- Bars kept (Big Lean lyric lines): 49
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Big Lean.
- Credit strings: Big Lean.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 263
- REPEAT pairs, recorded separately: 46
- END rhymes: 20
- INNER rhymes: 243

By match:

- PERFECT: 28 (END 1, INNER 27)
- SLANT: 92 (END 10, INNER 82)
- ASSONANCE: 143 (END 9, INNER 134)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 25
- MED: 212
- LOW: 26

## Core

- Core Y: 243
- Core N among rhyme pairs: 20

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 106 (40.3%)
- vowel: 143 (54.4%)
- spelling: 14 (5.3%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 65 pairs (END 4, INNER 61). Words: both, no, blow, know, don't, o'block, glocks, sosa.
2. `vow:AE` — 20 pairs (END 0, INNER 20). Words: can't, starin, rappers, ass, back, gangsta, sad, 2pac.
3. `slant:OW:sib-stop` — 13 pairs (END 2, INNER 11). Words: both, tote, soap, sosa, joker, overflowed, closer, flows.
4. `vow:EH` — 12 pairs (END 2, INNER 10). Words: bench, there's, send, tell, letting, dresser, pressure, when.
5. `cmu:OW` — 9 pairs (END 0, INNER 9). Words: no, o, know, blow, bro, dough, go.
6. `slant:IH:sib-stop` — 8 pairs (END 0, INNER 8). Words: shit, rich, snitch, tits, hit.
7. `vow:AY` — 8 pairs (END 0, INNER 8). Words: fly, try, lifestyle, might, ice, right, i'll, fine.
8. `vow:IH` — 8 pairs (END 0, INNER 8). Words: thinking, bitches, crib, tits, shit, give, rich, kill.
9. `slant:OW:sib` — 7 pairs (END 1, INNER 6). Words: sosa, both, glocks, closer, clothes, flows, opps.
10. `vow:IY` — 7 pairs (END 0, INNER 7). Words: see, keep, lean, field, gianni, t, degrees, here.
11. `vow:EY` — 6 pairs (END 0, INNER 6). Words: stay, came, related, raised, baby.
12. `spell:ocks` — 5 pairs (END 1, INNER 4). Words: blocks, glocks.
13. `vow:AW` — 5 pairs (END 1, INNER 4). Words: down, now.
14. `slant:AA:sib` — 4 pairs (END 2, INNER 2). Words: ops, blocks, gods.
15. `slant:AY:liq-sib` — 4 pairs (END 0, INNER 4). Words: lifestyle, ice.
16. `slant:AY:liq-stop` — 4 pairs (END 0, INNER 4). Words: might, lifestyle, i'll, like, right.
17. `vow:AA` — 4 pairs (END 2, INNER 2). Words: toronto, versace, follow, not, cars, hard, stop.
18. `slant:AE:stop` — 3 pairs (END 0, INNER 3). Words: back, strap, papi, sad, 2pac.
19. `slant:AY:sib-stop` — 3 pairs (END 0, INNER 3). Words: ice, like, might.
20. `slant:EH:liq-sib` — 3 pairs (END 0, INNER 3). Words: there, dresser, pressure, there's.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- glocks — 14 pair sides, mostly spelling via spelling phonetic key, often with blocks (5)
- oblock — 7 pair sides, mostly vowel via spelling phonetic key, often with both (3)
- opps — 7 pair sides, mostly vowel via spelling phonetic key, often with both (3)
- papi — 2 pair sides, mostly spelling via spelling phonetic key, often with can (1)
- 2pac — 2 pair sides, mostly spelling via spelling phonetic key, often with sad (1)
- holla — 1 pair sides, mostly spelling via spelling phonetic key, often with hold (1)
- jects — 1 pair sides, mostly vowel via spelling phonetic key, often with send (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Big Lean | My Lifestyle | 49 | 20 | 243 | loose |
