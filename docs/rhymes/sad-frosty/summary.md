# Sad Frosty rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Sad Frosty
- Songs: 1
- Bars kept (Sad Frosty lyric lines): 61
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Sad Frosty.
- Credit strings: Sad Frosty.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 435
- REPEAT pairs, recorded separately: 89
- END rhymes: 49
- INNER rhymes: 386

By match:

- PERFECT: 34 (END 10, INNER 24)
- SLANT: 201 (END 25, INNER 176)
- ASSONANCE: 192 (END 13, INNER 179)
- MULTI: 8 (END 1, INNER 7)

By confidence:

- HIGH: 39
- MED: 355
- LOW: 41

## Core

- Core Y: 425
- Core N among rhyme pairs: 10

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 202 (46.4%)
- vowel: 192 (44.1%)
- spelling: 33 (7.6%)
- multi: 8 (1.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 47 pairs (END 9, INNER 38). Words: shit, appearing, forgiveness, licks, sizzlin, think, bitch, stick'll.
2. `vow:AA` — 25 pairs (END 0, INNER 25). Words: talkin, got, pop, pocket, watching, cause, poppin, wanna.
3. `slant:IH:sib-stop` — 23 pairs (END 11, INNER 12). Words: bitch, shit, hit, niggas, nigga.
4. `vow:EY` — 23 pairs (END 1, INNER 22). Words: angel, bathing, ain't, make, ape, gates, baby, th.
5. `vow:EH` — 20 pairs (END 0, INNER 20). Words: again, flex, left, tesla, best, neck, tell, heads.
6. `slant:IH:stop` — 16 pairs (END 0, INNER 16). Words: shit, nigga, hit, lid, missed.
7. `vow:AH` — 15 pairs (END 0, INNER 15). Words: some, coming, fuckin, something, hundred, funnel, crumble, tumble.
8. `slant:EY:stop` — 12 pairs (END 2, INNER 10). Words: make, baby, ape, meditate, levitate, ain't, accelerate, hate.
9. `vow:AE` — 12 pairs (END 1, INNER 11). Words: accurate, pants, had, gang, land, cash, can't, lag.
10. `vow:AW` — 12 pairs (END 0, INNER 12). Words: now, around, down, how, 'round.
11. `vow:OW` — 11 pairs (END 0, INNER 11). Words: don't, show, sosa, no, lambo, kobe, smokin, sold.
12. `slant:EY:sib-stop` — 10 pairs (END 4, INNER 6). Words: gates, th, levitate, accelerate, baby, always, hesitate, meditate.
13. `vow:IY` — 10 pairs (END 2, INNER 8). Words: stealin, streams, streets, here, keep, people, trees, scene.
14. `slant:AH:nas` — 8 pairs (END 0, INNER 8). Words: come, money, run, coming, done, fuckin, some.
15. `slant:IH:nas-stop` — 8 pairs (END 0, INNER 8). Words: shit, spin, hittin, hit.
16. `slant:IH:liq-stop` — 7 pairs (END 0, INNER 7). Words: shit, kill, fill, hit, near.
17. `slant:AW:nas-stop` — 6 pairs (END 3, INNER 3). Words: down, round, touchdown, around.
18. `slant:EH:liq-stop` — 6 pairs (END 0, INNER 6). Words: tesla, best, said, well, let, commissary, tell, bread.
19. `vow:UW` — 6 pairs (END 0, INNER 6). Words: music, who, gucci, move, coochie, school, hooligans, losin.
20. `cmu:EY-T` — 5 pairs (END 5, INNER 0). Words: levitate, hesitate, meditate, accelerate, hate.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 13 pair sides, mostly spelling via spelling phonetic key, often with shit (9)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- stickll — 5 pair sides, mostly vowel via spelling phonetic key, often with bitch (4)
- tryna — 4 pair sides, mostly spelling via spelling phonetic key, often with here (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with him (1)
- bape — 2 pair sides, mostly spelling via spelling phonetic key, often with had (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- hunnid — 2 pair sides, mostly vowel via spelling phonetic key, often with coming (1)
- lambo — 2 pair sides, mostly vowel via spelling phonetic key, often with no (1)
- hella — 1 pair sides, mostly spelling via spelling phonetic key, often with tesla (1)
- thuggin — 1 pair sides, mostly vowel via spelling phonetic key, often with ludacris (1)
- ludacris — 1 pair sides, mostly vowel via spelling phonetic key, often with thuggin (1)
- wakanda — 1 pair sides, mostly vowel via spelling phonetic key, often with bang (1)
- woop — 1 pair sides, mostly spelling via spelling phonetic key, often with shoot (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Sad Frosty | GENGAR | 61 | 49 | 386 | loose |
