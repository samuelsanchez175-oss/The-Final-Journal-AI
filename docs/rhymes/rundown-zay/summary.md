# Rundown Zay rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Rundown Zay
- Songs: 3
- Bars kept (Rundown Zay lyric lines): 153
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Rundown Zay.
- Credit strings: Rundown Zay.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1055
- REPEAT pairs, recorded separately: 91
- END rhymes: 129
- INNER rhymes: 926

By match:

- PERFECT: 82 (END 16, INNER 66)
- SLANT: 479 (END 55, INNER 424)
- ASSONANCE: 481 (END 56, INNER 425)
- MULTI: 13 (END 2, INNER 11)

By confidence:

- HIGH: 91
- MED: 888
- LOW: 76

## Core

- Core Y: 1031
- Core N among rhyme pairs: 24

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 506 (48.0%)
- vowel: 481 (45.6%)
- spelling: 55 (5.2%)
- multi: 13 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 93 pairs (END 4, INNER 89). Words: don't, know, go, told, no, ho, going, stone.
2. `vow:IH` — 85 pairs (END 8, INNER 77). Words: shit, bitch, figures, period, lil, spin, picked, killer.
3. `vow:AY` — 60 pairs (END 15, INNER 45). Words: like, fly, why, fbi, tie, lie, friday, lighter.
4. `vow:AE` — 53 pairs (END 0, INNER 53). Words: graduate, have, bank, tank, back, can, had, can't.
5. `vow:EH` — 47 pairs (END 12, INNER 35). Words: sex, nephew, rex, breast, next, rebel, 'vette, let.
6. `slant:AA:stop` — 41 pairs (END 2, INNER 39). Words: got, want, drop, charter, carti, rock, cropped, not.
7. `vow:AH` — 36 pairs (END 8, INNER 28). Words: trust, front, hundred, cuffs, fuck, love, young, something.
8. `vow:AA` — 33 pairs (END 5, INNER 28). Words: want, robbin, barbie, got, wash, hopped, nothin, ferrari.
9. `vow:EY` — 33 pairs (END 0, INNER 33). Words: ain't, say, make, raisin, way, made, wakin, pain.
10. `slant:IH:liq-stop` — 24 pairs (END 1, INNER 23). Words: shit, lil, killer, kill, pick, city, really, killed.
11. `cmu:OW` — 22 pairs (END 3, INNER 19). Words: know, go, no, ho, show, blow, throw.
12. `slant:IH:liq-sib` — 22 pairs (END 3, INNER 19). Words: killers, lil, kill, bitch, really, killer, still, pills.
13. `slant:EH:stop` — 21 pairs (END 4, INNER 17). Words: get, check, neck, upset, jet, header, red, dead.
14. `slant:IH:liq-nas` — 21 pairs (END 0, INNER 21). Words: kill, spin, lil, killin, still, him, mini, killer.
15. `vow:IY` — 20 pairs (END 2, INNER 18). Words: see, pee, shawty, fiend, keep, these, need, ninety.
16. `slant:AY:stop` — 19 pairs (END 4, INNER 15). Words: might, like, inside, fried, right, friday, lighter, fight.
17. `vow:AO` — 18 pairs (END 2, INNER 16). Words: lord, morgues, callin, all, quarter, walk, call, floor.
18. `slant:EH:sib-stop` — 17 pairs (END 10, INNER 7). Words: neck, less, flesh, dresser, header, check, breast, head.
19. `slant:IH:sib-stop` — 13 pairs (END 1, INNER 12). Words: bitch, shit, niggas, nigga, richer, kick, click, kid.
20. `slant:AA:nas-stop` — 12 pairs (END 0, INNER 12). Words: wanna, want, lockin, talkin, rocket, pocket, rock, got.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 15 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- shawty — 10 pair sides, mostly vowel via spelling phonetic key, often with naughty (2)
- finna — 6 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with dont (3)
- swag — 5 pair sides, mostly spelling via spelling phonetic key, often with bvlgari (2)
- insid — 5 pair sides, mostly vowel via spelling phonetic key, often with think (1)
- carti — 4 pair sides, mostly spelling via spelling phonetic key, often with barbie (1)
- lipo — 4 pair sides, mostly spelling via spelling phonetic key, often with trippin (1)
- bvlgari — 4 pair sides, mostly spelling via spelling phonetic key, often with swag (2)
- toretto — 3 pair sides, mostly vowel via spelling phonetic key, often with yellow (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- skrilla — 3 pair sides, mostly spelling via spelling phonetic key, often with lil (1)
- shitll — 3 pair sides, mostly vowel via spelling phonetic key, often with still (1)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with killer (1)
- nem — 3 pair sides, mostly spelling via spelling phonetic key, often with red (1)
- fiendin — 2 pair sides, mostly spelling via spelling phonetic key, often with finna (1)
- drac — 2 pair sides, mostly spelling via spelling phonetic key, often with damn (1)
- dawgs — 1 pair sides, mostly spelling via spelling phonetic key, often with dog (1)
- audemar — 1 pair sides, mostly vowel via spelling phonetic key, often with walk (1)
- keyholder — 1 pair sides, mostly vowel via spelling phonetic key, often with make (1)
- elliante — 1 pair sides, mostly vowel via spelling phonetic key, often with neck (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- rari — 1 pair sides, mostly spelling via spelling phonetic key, often with bad (1)
- dawg — 1 pair sides, mostly spelling via spelling phonetic key, often with all (1)
- doin — 1 pair sides, mostly spelling via spelling phonetic key, often with goin (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Rundown Zay | Bvlgari | 94 | 89 | 559 | loose |
| Rundown Zay | Crocodile Skin | 29 | 15 | 146 | loose |
| Rundown Zay | Ønly Øway | 30 | 25 | 221 | loose |
