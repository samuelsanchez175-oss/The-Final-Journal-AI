# The Game rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: The Game
- Songs: 3
- Bars kept (The Game lyric lines): 185
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: The Game.
- Credit strings: The Game.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1317
- REPEAT pairs, recorded separately: 121
- END rhymes: 196
- INNER rhymes: 1121

By match:

- PERFECT: 123 (END 38, INNER 85)
- SLANT: 600 (END 90, INNER 510)
- ASSONANCE: 588 (END 68, INNER 520)
- MULTI: 6 (END 0, INNER 6)

By confidence:

- HIGH: 116
- MED: 1114
- LOW: 87

## Core

- Core Y: 1299
- Core N among rhyme pairs: 18

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 643 (48.8%)
- vowel: 588 (44.6%)
- spelling: 80 (6.1%)
- multi: 6 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 116 pairs (END 27, INNER 89). Words: ask, back, had, classic, atlanta, savage, aftermath, album.
2. `vow:IH` — 89 pairs (END 0, INNER 89). Words: bitch, shit, years, extinct, give, big, killers, switches.
3. `vow:OW` — 78 pairs (END 16, INNER 62). Words: know, dope, don't, soldiers, homes, yolk, gold, told.
4. `vow:EH` — 72 pairs (END 3, INNER 69). Words: wear, enemies, get, extra, tell, bentley, twelve, went.
5. `vow:AH` — 59 pairs (END 11, INNER 48). Words: one, thugs, jumped, front, slump, brothers, none, humble.
6. `slant:AA:stop` — 55 pairs (END 6, INNER 49). Words: got, block, hop, glock, top, gotta, dot, sock.
7. `slant:IH:stop` — 47 pairs (END 4, INNER 43). Words: nigga, shit, pick, hip, hit, spit, extinct, dig.
8. `slant:AE:sib-stop` — 41 pairs (END 8, INNER 33). Words: had, black, ass, pass, aftermath, tallahassee, ask, back.
9. `vow:IY` — 39 pairs (END 1, INNER 38). Words: egypt, see, b, real, d, blicky, brazy, priest.
10. `vow:AA` — 38 pairs (END 3, INNER 35). Words: got, homage, glock, shots, start, hop, chopper, cops.
11. `slant:AH:nas-stop` — 32 pairs (END 2, INNER 30). Words: fuck, come, sun, blood, young, run, under, bloody.
12. `vow:AY` — 30 pairs (END 2, INNER 28). Words: die, fire, by, slide, i'll, try, tonight, nice.
13. `vow:UW` — 29 pairs (END 4, INNER 25). Words: new, coupes, two, vroom, moon, move, room, soon.
14. `slant:AE:stop` — 24 pairs (END 8, INNER 16). Words: back, ask, black, had, scat, dap, pack, hand.
15. `slant:IH:nas-stop` — 23 pairs (END 0, INNER 23). Words: hit, him, i'ma, shit, thing, pick, strip, everything.
16. `slant:EH:stop` — 21 pairs (END 2, INNER 19). Words: get, against, seatbelt, let, twenty, help, red, went.
17. `slant:IH:sib-stop` — 21 pairs (END 0, INNER 21). Words: nigga, niggas, bitch, miss, triggers, shit, big, fish.
18. `vow:AO` — 19 pairs (END 1, INNER 18). Words: all, passport, honda, fourth, normally, york, sean, force.
19. `slant:AH:nas` — 18 pairs (END 5, INNER 13). Words: come, become, gun, drum, run, some, done, son.
20. `slant:AA:nas-stop` — 17 pairs (END 0, INNER 17). Words: momma, got, pop, coppin, gonna, hop, john, glock.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 34 pair sides, mostly spelling via spelling phonetic key, often with niggas (6)
- ima — 12 pair sides, mostly spelling via spelling phonetic key, often with him (7)
- niggas — 10 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- blicky — 6 pair sides, mostly vowel via spelling phonetic key, often with give (2)
- thugged — 5 pair sides, mostly cmu via vault phonetic_class, often with thuggin (2)
- thuggin — 5 pair sides, mostly spelling via spelling phonetic key, often with thugged (2)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with bone (2)
- dap — 5 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- herbo — 4 pair sides, mostly vowel via spelling phonetic key, often with work (1)
- brazy — 4 pair sides, mostly vowel via spelling phonetic key, often with b (2)
- eazy — 4 pair sides, mostly vowel via spelling phonetic key, often with b (1)
- thuggish — 3 pair sides, mostly multi via spelling phonetic key, often with ruggish (2)
- ruggish — 3 pair sides, mostly multi via spelling phonetic key, often with thuggish (2)
- meds — 3 pair sides, mostly cmu via vault phonetic_class, often with charles (1)
- ovo — 3 pair sides, mostly vowel via spelling phonetic key, often with rodeo (1)
- nas — 3 pair sides, mostly spelling via spelling phonetic key, often with gas (1)
- drac — 2 pair sides, mostly vowel via spelling phonetic key, often with cant (1)
- snubnose — 1 pair sides, mostly vowel via spelling phonetic key, often with come (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with told (1)
- mobbin — 1 pair sides, mostly spelling via spelling phonetic key, often with thuggin (1)
- grillz — 1 pair sides, mostly vowel via spelling phonetic key, often with shit (1)
- ninas — 1 pair sides, mostly spelling via spelling phonetic key, often with twin (1)
- hunnid — 1 pair sides, mostly spelling via spelling phonetic key, often with pyramid (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| The Game | Chrome Slugs & Harmony | 77 | 98 | 447 | loose |
| The Game | Real Ni99as | 43 | 43 | 210 | loose |
| The Game | The Code | 65 | 55 | 464 | loose |
