# Fredo Santana rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Fredo Santana
- Songs: 14
- Bars kept (Fredo Santana lyric lines): 520
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 2
- Canonical name: Fredo Santana.
- Credit strings: Fredo Santana.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 3456
- REPEAT pairs, recorded separately: 402
- END rhymes: 679
- INNER rhymes: 2777

By match:

- PERFECT: 280 (END 71, INNER 209)
- SLANT: 1395 (END 290, INNER 1105)
- ASSONANCE: 1746 (END 306, INNER 1440)
- MULTI: 35 (END 12, INNER 23)

By confidence:

- HIGH: 264
- MED: 3016
- LOW: 176

## Core

- Core Y: 3408
- Core N among rhyme pairs: 48

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 1503 (43.5%)
- vowel: 1746 (50.5%)
- spelling: 172 (5.0%)
- multi: 35 (1.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 14 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 261 pairs (END 22, INNER 239). Words: don't, no, know, smoke, dope, posted, hoes, coke.
2. `vow:IH` — 236 pairs (END 21, INNER 215). Words: shit, bitches, bitch, hit, slipping, big, think, limit.
3. `vow:AE` — 218 pairs (END 47, INNER 171). Words: trap, savage, bands, can't, banging, damn, racks, man.
4. `vow:AA` — 202 pairs (END 38, INNER 164). Words: want, got, gotta, hard, squad, cars, glock, spark.
5. `vow:EH` — 197 pairs (END 24, INNER 173). Words: flexing, get, hectic, second, wet, send, flexin, weapon.
6. `vow:EY` — 179 pairs (END 54, INNER 125). Words: ain't, day, k, face, make, baby, take, always.
7. `vow:AH` — 132 pairs (END 27, INNER 105). Words: fuck, hundreds, hundred, guns, some, trust, money, nothing.
8. `slant:AA:stop` — 116 pairs (END 8, INNER 108). Words: gotta, got, want, squad, not, pocket, glock, opp.
9. `vow:IY` — 111 pairs (END 20, INNER 91). Words: see, beams, p, nobody, these, t, streets, beef.
10. `vow:AY` — 84 pairs (END 7, INNER 77). Words: like, high, why, life, pipes, die, find, by.
11. `slant:IH:sib-stop` — 62 pairs (END 15, INNER 47). Words: bitch, shit, nigga, niggas, kick, dick, wit, hit.
12. `slant:IH:stop` — 57 pairs (END 6, INNER 51). Words: shit, nigga, big, hit, clip, dick, wit, flip.
13. `vow:UW` — 52 pairs (END 9, INNER 43). Words: new, blue, two, shooters, shoot, jewelry, shooter, statue.
14. `slant:AE:nas-stop` — 45 pairs (END 3, INNER 42). Words: trap, man, gang, damn, bad, can, had, bang.
15. `vow:AW` — 45 pairs (END 21, INNER 24). Words: down, now, rounds, how, about, sound, pounds, bounds.
16. `slant:AH:nas-stop` — 44 pairs (END 1, INNER 43). Words: fuck, money, some, what, gun, suck, young, fucking.
17. `slant:AE:nas` — 43 pairs (END 12, INNER 31). Words: gang, man, banging, can, ramen, mansion, abandon, dancin.
18. `slant:EH:stop` — 43 pairs (END 4, INNER 39). Words: get, let, neck, went, dead, better, red, wet.
19. `slant:AE:stop` — 41 pairs (END 7, INNER 34). Words: trap, back, chat, slapped, pack, crab, bad, had.
20. `slant:AW:nas-stop` — 41 pairs (END 26, INNER 15). Words: down, around, sound, round, crowd, about, loud, 'round.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 29 pair sides, mostly spelling via spelling phonetic key, often with niggas (11)
- niggas — 29 pair sides, mostly spelling via spelling phonetic key, often with nigga (11)
- finessing — 17 pair sides, mostly spelling via spelling phonetic key, often with flexing (7)
- tryna — 16 pair sides, mostly spelling via spelling phonetic key, often with keep (3)
- gon — 14 pair sides, mostly spelling via spelling phonetic key, often with dont (3)
- ima — 11 pair sides, mostly spelling via spelling phonetic key, often with bitch (3)
- thangs — 8 pair sides, mostly spelling via spelling phonetic key, often with shoestrings (2)
- henny — 7 pair sides, mostly vowel via spelling phonetic key, often with kidney (1)
- sto — 6 pair sides, mostly vowel via spelling phonetic key, often with tho (1)
- codeine — 5 pair sides, mostly vowel via spelling phonetic key, often with woke (1)
- opps — 5 pair sides, mostly vowel via spelling phonetic key, often with dont (2)
- nem — 4 pair sides, mostly spelling via spelling phonetic key, often with when (1)
- stanking — 4 pair sides, mostly spelling via spelling phonetic key, often with plankton (1)
- ramen — 4 pair sides, mostly spelling via spelling phonetic key, often with stanking (1)
- doowop — 3 pair sides, mostly spelling via spelling phonetic key, often with top (1)
- gwap — 3 pair sides, mostly spelling via spelling phonetic key, often with catch (2)
- tecs — 3 pair sides, mostly vowel via spelling phonetic key, often with now (1)
- jocking — 3 pair sides, mostly spelling via spelling phonetic key, often with fussing (1)
- gunsll — 3 pair sides, mostly vowel via spelling phonetic key, often with fuck (2)
- wock — 3 pair sides, mostly spelling via spelling phonetic key, often with block (1)
- menage — 3 pair sides, mostly spelling via spelling phonetic key, often with minaj (1)
- ars — 3 pair sides, mostly spelling via spelling phonetic key, often with yard (1)
- odee — 3 pair sides, mostly vowel via spelling phonetic key, often with p (2)
- otf — 3 pair sides, mostly cmu via vault phonetic_class, often with man (1)
- karats — 3 pair sides, mostly vowel via spelling phonetic key, often with hand (2)
- tookie — 3 pair sides, mostly spelling via spelling phonetic key, often with shoot (1)
- zaytoven — 2 pair sides, mostly spelling via spelling phonetic key, often with frozen (1)
- dago — 2 pair sides, mostly vowel via spelling phonetic key, often with go (1)
- mothafuckin — 2 pair sides, mostly multi via spelling phonetic key, often with fuckin (2)
- imma — 2 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Fredo Santana | Always | 50 | 52 | 291 | loose |
| Fredo Santana | Bought a Big K | 32 | 79 | 115 | loose |
| Fredo Santana | Clockwork | 26 | 45 | 161 | loose |
| Fredo Santana | Dope Game | 32 | 23 | 156 | loose |
| Fredo Santana | Flexing Finessing | 43 | 58 | 421 | loose |
| Fredo Santana | Gun Violence | 34 | 48 | 141 | loose |
| Fredo Santana | High Off Gun Powder | 38 | 34 | 167 | loose |
| Fredo Santana | My Lil’ Niggaz | 35 | 67 | 144 | loose |
| Fredo Santana | My Pistol Make Ya Famous | 46 | 68 | 171 | loose |
| Fredo Santana | Never Had a Job | 38 | 57 | 217 | loose |
| Fredo Santana | On That | 40 | 25 | 211 | loose |
| Fredo Santana | Round ’Em Up | 29 | 21 | 170 | loose |
| Fredo Santana | Snatch His Chain | 36 | 67 | 229 | loose |
| Fredo Santana | Tell Nobody | 41 | 35 | 183 | loose |
