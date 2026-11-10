# J. Stone rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: J. Stone
- Songs: 1
- Bars kept (J. Stone lyric lines): 43
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: J. Stone.
- Credit strings: J. Stone.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 349
- REPEAT pairs, recorded separately: 35
- END rhymes: 69
- INNER rhymes: 280

By match:

- PERFECT: 11 (END 3, INNER 8)
- SLANT: 129 (END 25, INNER 104)
- ASSONANCE: 199 (END 36, INNER 163)
- MULTI: 10 (END 5, INNER 5)

By confidence:

- HIGH: 20
- MED: 310
- LOW: 19

## Core

- Core Y: 345
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 124 (35.5%)
- vowel: 199 (57.0%)
- spelling: 16 (4.6%)
- multi: 10 (2.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 56 pairs (END 6, INNER 50). Words: shit, living, risk, sippin, beginning, different, continue, business.
2. `vow:EY` — 42 pairs (END 22, INNER 20). Words: ain't, celebration, elevation, paper, favors, meditating, segregated, nathan.
3. `vow:EH` — 36 pairs (END 0, INNER 36). Words: mention, never, trenches, necklace, central, rest, tell, hell.
4. `vow:AA` — 16 pairs (END 0, INNER 16). Words: revolver, hoppin, target, got, mama, shot, block, not.
5. `slant:IH:stop` — 15 pairs (END 0, INNER 15). Words: shit, big, bigger, nip, spit.
6. `vow:UW` — 11 pairs (END 8, INNER 3). Words: view, rules, proof, dudes, room, through, new, poor.
7. `slant:IH:sib-stop` — 10 pairs (END 7, INNER 3). Words: nigga, niggas, shit, piss.
8. `vow:AE` — 9 pairs (END 0, INNER 9). Words: asked, dash, after, gangster, had, last, ass.
9. `vow:AY` — 9 pairs (END 0, INNER 9). Words: nights, i'll, die, cry, life, time, high, mind.
10. `slant:EH:sib-stop` — 7 pairs (END 2, INNER 5). Words: mess, wet, check, guess, fence, bend, tec, said.
11. `slant:EY:stop` — 7 pairs (END 6, INNER 1). Words: hated, labor, segregated, paper, scraper, take.
12. `vow:IY` — 7 pairs (END 0, INNER 7). Words: see, real, people, fifteen, dream, team.
13. `multi:EY-SH-AH-N` — 6 pairs (END 4, INNER 2). Words: dedication, celebration, elevation, separation, hesitation.
14. `slant:AA:sib-stop` — 6 pairs (END 0, INNER 6). Words: dodge, father, block, not, pot, god, got, shot.
15. `vow:AO` — 6 pairs (END 0, INNER 6). Words: offer, fought, record, smallest, tallest.
16. `slant:AA:nas-stop` — 5 pairs (END 0, INNER 5). Words: mama, got, hop, shot, marathon, hopping.
17. `slant:EH:fric-stop` — 5 pairs (END 0, INNER 5). Words: never, get, neck, tec, said.
18. `slant:EY:nas` — 5 pairs (END 4, INNER 1). Words: nathan, hesitation, dedication, celebration, elevation, separation.
19. `slant:IY:liq` — 5 pairs (END 0, INNER 5). Words: real, people.
20. `slant:EH:liq-stop` — 4 pairs (END 0, INNER 4). Words: there, tell, neck, wet, check.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- niggas — 10 pair sides, mostly spelling via spelling phonetic key, often with nigga (9)
- nigga — 9 pair sides, mostly spelling via spelling phonetic key, often with niggas (9)
- spirt — 4 pair sides, mostly vowel via spelling phonetic key, often with living (3)
- nipsey — 3 pair sides, mostly spelling via spelling phonetic key, often with piss (2)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with both (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| J. Stone | Real Shit | 43 | 69 | 280 | loose |
