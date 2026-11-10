# Bizzy Banks rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Bizzy Banks
- Songs: 1
- Bars kept (Bizzy Banks lyric lines): 99
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Bizzy Banks.
- Credit strings: Bizzy Banks.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 455
- REPEAT pairs, recorded separately: 50
- END rhymes: 120
- INNER rhymes: 335

By match:

- PERFECT: 46 (END 22, INNER 24)
- SLANT: 190 (END 37, INNER 153)
- ASSONANCE: 218 (END 60, INNER 158)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 43
- MED: 379
- LOW: 33

## Core

- Core Y: 446
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 208 (45.7%)
- vowel: 218 (47.9%)
- spelling: 28 (6.2%)
- multi: 1 (0.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 43 pairs (END 17, INNER 26). Words: can't, cappin, reactions, facts, tactic, mack, jack, trappin.
2. `vow:UW` — 32 pairs (END 6, INNER 26). Words: movin, shooters, choo, u, boom, lose, music, who.
3. `vow:AA` — 25 pairs (END 6, INNER 19). Words: lobsters, shots, wanna, options, start, droppin, shot, vodka.
4. `vow:OW` — 24 pairs (END 2, INNER 22). Words: don't, know, go, over, broke, told, owe, no.
5. `vow:AY` — 19 pairs (END 9, INNER 10). Words: like, giant, defiant, flyer, fire, lion, liar, wire.
6. `vow:EH` — 19 pairs (END 1, INNER 18). Words: tell, gettin, chest, head, mento, remember, disrespect, seven.
7. `vow:IH` — 19 pairs (END 0, INNER 19). Words: spinnin, different, bitches, since, give, hit, kick, six.
8. `slant:AE:stop` — 17 pairs (END 12, INNER 5). Words: bag, cap, jack, jacket, back, can't, track, pack.
9. `vow:EY` — 17 pairs (END 14, INNER 3). Words: today, play, rakes, place, laser, state, ain't, hesitate.
10. `slant:AA:stop` — 16 pairs (END 5, INNER 11). Words: got, copper, shot, vodka, soccer, hop, want, spot.
11. `vow:AH` — 13 pairs (END 3, INNER 10). Words: one, tucked, bumping, what's, must, love, fuck, some.
12. `slant:IH:stop` — 10 pairs (END 2, INNER 8). Words: stick, shit, biggie, pick, rip, split, nigga, victor.
13. `slant:AY:fric-stop` — 9 pairs (END 0, INNER 9). Words: life, like, five, pride, ride, side.
14. `slant:IH:sib-stop` — 9 pairs (END 0, INNER 9). Words: niggas, nigga, diss, pick, stick, bitch, rip, six.
15. `slant:AH:nas-stop` — 7 pairs (END 3, INNER 4). Words: fuck, one, what, done, some, sun.
16. `slant:AY:nas-stop` — 7 pairs (END 5, INNER 2). Words: line, lion, like, ride, pride, side, giant, defiant.
17. `slant:EH:stop` — 7 pairs (END 1, INNER 6). Words: respect, plenty, head, pep, bread, disrespect, ebk, chest.
18. `cmu:AE-K` — 6 pairs (END 5, INNER 1). Words: back, pack, track, jack, mack.
19. `slant:AH:stop` — 6 pairs (END 2, INNER 4). Words: fuck, guap, what, plug, tucked.
20. `slant:EH:nas-stop` — 6 pairs (END 1, INNER 5). Words: when, plenty, henny, get, jet, head, mento, pep.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- niggas — 9 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- henny — 5 pair sides, mostly spelling via spelling phonetic key, often with ciggy (1)
- ciggy — 3 pair sides, mostly vowel via spelling phonetic key, often with plenty (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- ninas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- kimbo — 2 pair sides, mostly vowel via spelling phonetic key, often with go (1)
- jbans — 2 pair sides, mostly spelling via spelling phonetic key, often with can (1)
- bando — 2 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- choppa — 2 pair sides, mostly spelling via spelling phonetic key, often with unload (1)
- guap — 2 pair sides, mostly spelling via spelling phonetic key, often with fuck (2)
- hol — 2 pair sides, mostly spelling via spelling phonetic key, often with gon (1)
- finna — 1 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)
- ebk — 1 pair sides, mostly spelling via spelling phonetic key, often with respect (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with here (1)
- dafi — 1 pair sides, mostly spelling via spelling phonetic key, often with pass (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Bizzy Banks | Don’t Start, Pt. 2 (Original) | 99 | 120 | 335 | loose |
