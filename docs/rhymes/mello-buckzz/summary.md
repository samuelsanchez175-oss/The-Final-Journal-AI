# Mello Buckzz rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Mello Buckzz
- Songs: 1
- Bars kept (Mello Buckzz lyric lines): 34
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Mello Buckzz.
- Credit strings: Mello Buckzz.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 431
- REPEAT pairs, recorded separately: 38
- END rhymes: 23
- INNER rhymes: 408

By match:

- PERFECT: 47 (END 4, INNER 43)
- SLANT: 178 (END 8, INNER 170)
- ASSONANCE: 202 (END 11, INNER 191)
- MULTI: 4 (END 0, INNER 4)

By confidence:

- HIGH: 50
- MED: 359
- LOW: 22

## Core

- Core Y: 420
- Core N among rhyme pairs: 11

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 213 (49.4%)
- vowel: 202 (46.9%)
- spelling: 12 (2.8%)
- multi: 4 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 53 pairs (END 1, INNER 52). Words: bringin, shit, bitch, filter, limp, pimp, sixty, bitches.
2. `vow:OW` — 46 pairs (END 3, INNER 43). Words: don't, no, ho, know, hoes, smoke, motion, lotion.
3. `vow:AH` — 25 pairs (END 0, INNER 25). Words: drunk, bucks, buckzz, ugly, fuck, club, bluff, stuff.
4. `vow:AE` — 20 pairs (END 3, INNER 17). Words: can't, damn, rappin, back, rap, tats, candy, trap.
5. `slant:AA:stop` — 18 pairs (END 0, INNER 18). Words: got, everybody, top, pop, gotta, body, art, block.
6. `slant:IH:liq-stop` — 17 pairs (END 0, INNER 17). Words: still, lick, lil, shit, hit, drip, filter.
7. `slant:AA:nas-stop` — 16 pairs (END 0, INNER 16). Words: wanna, got, gotta, top, want, block, everybody.
8. `slant:AH:fric-stop` — 13 pairs (END 0, INNER 13). Words: bluff, tough, stuff, club, fuck, suck, stuck, love.
9. `vow:EH` — 13 pairs (END 0, INNER 13). Words: get, drench, boyfriend, text, wet, drenched, bet, never.
10. `cmu:OW` — 12 pairs (END 0, INNER 12). Words: no, go, ho, know.
11. `vow:IY` — 12 pairs (END 3, INNER 9). Words: ac, vehicle, tv, cds, see, piece, we'll, weed.
12. `slant:IH:sib-stop` — 11 pairs (END 0, INNER 11). Words: bitch, shit, drip, switch, nigga, niggas, hit, rich.
13. `vow:AA` — 11 pairs (END 0, INNER 11). Words: problem, wanna, want, top, art, everybody, got, watch.
14. `slant:IH:stop` — 10 pairs (END 0, INNER 10). Words: nigga, drip, lick, hit, shit, limp, pimp, sixty.
15. `slant:AH:nas-stop` — 8 pairs (END 0, INNER 8). Words: fuck, none, money, stuck, run, club, suck.
16. `slant:IY:sib-stop` — 7 pairs (END 3, INNER 4). Words: cds, keep, beat, feature, leech, clique, feet, piece.
17. `slant:IH:liq-sib` — 6 pairs (END 0, INNER 6). Words: bitch, lil, still, switch.
18. `vow:AO` — 6 pairs (END 0, INNER 6). Words: born, all, forth, fall, because, foreign, talk.
19. `vow:AW` — 6 pairs (END 0, INNER 6). Words: now, 'round, towel, how, about.
20. `cmu:AE-K` — 5 pairs (END 2, INNER 3). Words: back, black, crack, 'raq.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 8 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- buckzz — 8 pair sides, mostly vowel via spelling phonetic key, often with drunk (1)
- tats — 3 pair sides, mostly vowel via spelling phonetic key, often with back (2)
- fimp — 3 pair sides, mostly spelling via vault phonetic_class, often with limp (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- raq — 1 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- turnt — 1 pair sides, mostly vowel via spelling phonetic key, often with fuck (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Mello Buckzz | hmm...BD | 34 | 23 | 408 | loose |
