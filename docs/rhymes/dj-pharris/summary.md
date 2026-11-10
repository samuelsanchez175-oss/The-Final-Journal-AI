# DJ Pharris rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DJ Pharris
- Songs: 3
- Bars kept (DJ Pharris lyric lines): 174
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: DJ Pharris.
- Credit strings: DJ Pharris.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1036
- REPEAT pairs, recorded separately: 134
- END rhymes: 244
- INNER rhymes: 792

By match:

- PERFECT: 109 (END 29, INNER 80)
- SLANT: 418 (END 104, INNER 314)
- ASSONANCE: 491 (END 101, INNER 390)
- MULTI: 18 (END 10, INNER 8)

By confidence:

- HIGH: 105
- MED: 872
- LOW: 59

## Core

- Core Y: 1016
- Core N among rhyme pairs: 20

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 467 (45.1%)
- vowel: 491 (47.4%)
- spelling: 60 (5.8%)
- multi: 18 (1.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 114 pairs (END 17, INNER 97). Words: bitch, him, millions, business, bitches, fifty, give, think.
2. `vow:AA` — 85 pairs (END 15, INNER 70). Words: got, problems, dogs, bottles, rocks, dollars, models, docks.
3. `vow:IY` — 67 pairs (END 18, INNER 49). Words: b, see, nobody, these, tv, scenes, key, even.
4. `vow:AY` — 52 pairs (END 28, INNER 24). Words: die, high, fire, why, drive, side, ride, slide.
5. `vow:EH` — 47 pairs (END 10, INNER 37). Words: paris, sent, rental, friends, forever, bezel, whenever, necklace.
6. `slant:AA:stop` — 32 pairs (END 5, INNER 27). Words: got, stop, chopper, pop, not, glock, doctor, somebody.
7. `vow:OW` — 32 pairs (END 1, INNER 31). Words: don't, no, hoes, bro, broke, know, go, folks.
8. `vow:AE` — 30 pairs (END 0, INNER 30). Words: masked, can't, ask, instagram, can, acting, trap, pack.
9. `vow:EY` — 30 pairs (END 1, INNER 29). Words: ain't, snakes, always, ain’t, take, came, make, change.
10. `slant:AY:stop` — 28 pairs (END 18, INNER 10). Words: like, outside, ride, light, right, bite, side, tired.
11. `vow:AH` — 25 pairs (END 10, INNER 15). Words: hundred, ugly, stuff, bustin, fuck, jump, cuff, cuffs.
12. `slant:AA:liq-stop` — 24 pairs (END 1, INNER 23). Words: got, collar, hollow, far, holler, scholar, dollar, chopper.
13. `slant:AA:sib-stop` — 17 pairs (END 6, INNER 11). Words: spots, watch, father, bother, got, glock, chopper, pop.
14. `slant:IH:liq-sib` — 16 pairs (END 3, INNER 13). Words: still, bitch, mils, 'til, rich, mil, pills, kill.
15. `slant:IH:sib-stop` — 16 pairs (END 0, INNER 16). Words: bitch, shit, rich, city, brib, hit, glitter, big.
16. `slant:AA:liq-sib` — 13 pairs (END 11, INNER 2). Words: collar, college, knowledge, dollar, scholar, dollars, father, far.
17. `cmu:OW` — 12 pairs (END 0, INNER 12). Words: go, know, ho, bro, no, though, show.
18. `slant:AY:sib-stop` — 12 pairs (END 10, INNER 2). Words: ride, surprised, fries, size, pies, eyes, slide.
19. `cmu:IY` — 11 pairs (END 2, INNER 9). Words: b, see, tv, probably, nobody, key, vip, chevy.
20. `slant:AE:nas-stop` — 11 pairs (END 0, INNER 11). Words: clappin, man, back, dap, slam, pack, 'raq, bap.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- slangin — 8 pair sides, mostly spelling via spelling phonetic key, often with robbin (4)
- nigga — 7 pair sides, mostly spelling via spelling phonetic key, often with finger (1)
- gon — 6 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- gangbangin — 5 pair sides, mostly spelling via spelling phonetic key, often with robbin (2)
- dap — 5 pair sides, mostly spelling via spelling phonetic key, often with raq (1)
- bap — 5 pair sides, mostly spelling via spelling phonetic key, often with trap (2)
- raq — 4 pair sides, mostly spelling via spelling phonetic key, often with back (2)
- bezel — 4 pair sides, mostly vowel via spelling phonetic key, often with forever (1)
- queso — 4 pair sides, mostly spelling via spelling phonetic key, often with whenever (1)
- brib — 3 pair sides, mostly spelling via spelling phonetic key, often with still (1)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with everything (1)
- pradas — 3 pair sides, mostly spelling via spelling phonetic key, often with gorillas (1)
- adriannas — 3 pair sides, mostly vowel via spelling phonetic key, often with pradas (1)
- foenem — 3 pair sides, mostly spelling via spelling phonetic key, often with gon (1)
- thot — 2 pair sides, mostly spelling via spelling phonetic key, often with hot (1)
- assll — 2 pair sides, mostly vowel via spelling phonetic key, often with slam (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with keep (1)
- lyin — 2 pair sides, mostly spelling via spelling phonetic key, often with street (1)
- benzo — 2 pair sides, mostly vowel via spelling phonetic key, often with queso (1)
- grra — 2 pair sides, mostly vowel via spelling phonetic key, often with adriannas (1)
- sherbs — 2 pair sides, mostly spelling via spelling phonetic key, often with herb (1)
- urus — 2 pair sides, mostly vowel via spelling phonetic key, often with fuck (1)
- nem — 2 pair sides, mostly spelling via spelling phonetic key, often with em (2)
- neckpiece — 2 pair sides, mostly vowel via spelling phonetic key, often with check (1)
- shelaty — 2 pair sides, mostly vowel via spelling phonetic key, often with hotty (1)
- prometh — 1 pair sides, mostly vowel via spelling phonetic key, often with codeine (1)
- codeine — 1 pair sides, mostly vowel via spelling phonetic key, often with prometh (1)
- maybach — 1 pair sides, mostly spelling via spelling phonetic key, often with baby (1)
- yappin — 1 pair sides, mostly spelling via spelling phonetic key, often with makin (1)
- subliminals — 1 pair sides, mostly spelling via spelling phonetic key, often with criminals (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DJ Pharris | BO$$ | 66 | 113 | 307 | loose |
| DJ Pharris | JUUG | 43 | 36 | 70 | loose |
| DJ Pharris | Knowledge | 65 | 95 | 415 | loose |
