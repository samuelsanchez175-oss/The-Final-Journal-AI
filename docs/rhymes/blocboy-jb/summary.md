# BlocBoy JB rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: BlocBoy JB
- Songs: 2
- Bars kept (BlocBoy JB lyric lines): 104
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: BlocBoy JB.
- Credit strings: BlocBoy JB.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 615
- REPEAT pairs, recorded separately: 55
- END rhymes: 108
- INNER rhymes: 507

By match:

- PERFECT: 61 (END 20, INNER 41)
- SLANT: 246 (END 31, INNER 215)
- ASSONANCE: 305 (END 57, INNER 248)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 56
- MED: 507
- LOW: 52

## Core

- Core Y: 606
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 257 (41.8%)
- vowel: 305 (49.6%)
- spelling: 50 (8.1%)
- multi: 3 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 76 pairs (END 27, INNER 49). Words: though, smokin, dope, know, melrose, hoe, rover, notes.
2. `vow:IH` — 68 pairs (END 15, INNER 53). Words: him, really, minute, business, figures, lil, bitch, killers.
3. `vow:EY` — 33 pairs (END 3, INNER 30). Words: ain't, stay, day, days, grapes, snails, playin, made.
4. `vow:UW` — 24 pairs (END 4, INNER 20). Words: through, boo, coupe, roof, poof, crew, shoot, blew.
5. `vow:EH` — 21 pairs (END 1, INNER 20). Words: when, trenches, independent, tell, stretched, let's, gettin, pepsi.
6. `slant:IH:stop` — 18 pairs (END 1, INNER 17). Words: nigga, shit, crip, pick, picked, cinco, mink, pink.
7. `vow:AY` — 16 pairs (END 0, INNER 16). Words: like, five, find, times, ridin, mind, die, type.
8. `vow:AH` — 15 pairs (END 0, INNER 15). Words: what, hundred, motherfucking, fuckin, hustle, some, motherfuckin, comin.
9. `cmu:UW` — 14 pairs (END 4, INNER 10). Words: through, boo, crew, thru, blew.
10. `vow:AE` — 14 pairs (END 0, INNER 14). Words: can't, plastic, gang, bagged, action, cash, gangster, had.
11. `cmu:OW` — 13 pairs (END 7, INNER 6). Words: though, hoe, scarecrow, no, go, bro.
12. `slant:IH:sib-stop` — 13 pairs (END 2, INNER 11). Words: bitch, big, shit, niggas, nigga, miss, fit, minute.
13. `slant:AA:stop` — 12 pairs (END 0, INNER 12). Words: chopper, got, lot, robbery, shot, pop, bloc, block.
14. `vow:AA` — 12 pairs (END 1, INNER 11). Words: talkin, got, pots, pop, hah, robbery, mops, shot.
15. `slant:EY:sib-stop` — 11 pairs (END 0, INNER 11). Words: made, days, plays, tape, playas, baby, laid, grapes.
16. `slant:IH:liq-sib` — 11 pairs (END 0, INNER 11). Words: lil, still, itchy, bitch, busy, miss, really, rich.
17. `vow:IY` — 11 pairs (END 1, INNER 10). Words: see, feeling, keith, lean, liter, real, police, seen.
18. `slant:AE:nas-stop` — 10 pairs (END 0, INNER 10). Words: gang, back, bagg, kickback, ran, bag, instagram, bang.
19. `vow:ER` — 10 pairs (END 5, INNER 5). Words: first, circle, purpose, heard, murk, turn.
20. `slant:IH:nas-sib` — 9 pairs (END 0, INNER 9). Words: him, bitch, sippin, itchy, i'ma, tipsy, nipsey, busy.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 14 pair sides, mostly spelling via spelling phonetic key, often with shit (5)
- niggas — 11 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- swervo — 9 pair sides, mostly vowel via spelling phonetic key, often with though (3)
- ima — 6 pair sides, mostly spelling via spelling phonetic key, often with lil (2)
- glizzy — 5 pair sides, mostly spelling via spelling phonetic key, often with busy (1)
- foenem — 3 pair sides, mostly spelling via spelling phonetic key, often with em (2)
- playas — 3 pair sides, mostly spelling via spelling phonetic key, often with mace (1)
- nipsey — 2 pair sides, mostly spelling via spelling phonetic key, often with tipsy (1)
- choppa — 2 pair sides, mostly spelling via spelling phonetic key, often with dope (2)
- gon — 2 pair sides, mostly spelling via spelling phonetic key, often with photos (1)
- dova — 2 pair sides, mostly spelling via spelling phonetic key, often with rover (1)
- cuz — 2 pair sides, mostly spelling via spelling phonetic key, often with what (1)
- jeepers — 1 pair sides, mostly multi via spelling phonetic key, often with creepers (1)
- creepers — 1 pair sides, mostly multi via spelling phonetic key, often with jeepers (1)
- choppas — 1 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- lambo — 1 pair sides, mostly spelling via spelling phonetic key, often with gangster (1)
- stoled — 1 pair sides, mostly spelling via spelling phonetic key, often with bread (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| BlocBoy JB | Money & Hoes | 51 | 59 | 250 | loose |
| BlocBoy JB | Rover 2.0 | 53 | 49 | 257 | loose |
