# King Louie rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: King Louie
- Songs: 3
- Bars kept (King Louie lyric lines): 110
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: King Louie.
- Credit strings: King Louie.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 947
- REPEAT pairs, recorded separately: 99
- END rhymes: 130
- INNER rhymes: 817

By match:

- PERFECT: 97 (END 21, INNER 76)
- SLANT: 403 (END 48, INNER 355)
- ASSONANCE: 442 (END 60, INNER 382)
- MULTI: 5 (END 1, INNER 4)

By confidence:

- HIGH: 58
- MED: 825
- LOW: 64

## Core

- Core Y: 927
- Core N among rhyme pairs: 20

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 413 (43.6%)
- vowel: 442 (46.7%)
- spelling: 87 (9.2%)
- multi: 5 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 135 pairs (END 31, INNER 104). Words: pivot, christmas, kitchen, him, shit, bitches, sister, snitching.
2. `vow:OW` — 109 pairs (END 1, INNER 108). Words: don't, smoking, no, know, dope, blow, roll, poles.
3. `vow:AH` — 82 pairs (END 15, INNER 67). Words: money, bluffing, fuck, drugs, monday, bust, dumping, london.
4. `slant:AH:nas-stop` — 40 pairs (END 2, INNER 38). Words: fuck, money, what, some, young, summer, butt, monday.
5. `vow:AE` — 33 pairs (END 2, INNER 31). Words: bad, blast, hand, ass, catch, stash, flats, action.
6. `slant:IH:sib-stop` — 27 pairs (END 6, INNER 21). Words: bitch, lick, shit, dick, six, niggas, nigga, bricks.
7. `slant:IH:stop` — 27 pairs (END 1, INNER 26). Words: lick, nigga, hit, wit, mid, pivot, shit, kick.
8. `cmu:AE-S` — 24 pairs (END 6, INNER 18). Words: niggas, killas, hittas, ass, gettas, drillas, dissas.
9. `slant:IH:sib` — 23 pairs (END 4, INNER 19). Words: niggas, bitches, clips, figures, christmas, bitch, ridiculous, swishers.
10. `slant:AH:nas` — 18 pairs (END 6, INNER 12). Words: money, come, dumping, london, pumpkin, something, gun, young.
11. `vow:EY` — 18 pairs (END 5, INNER 13). Words: danger, take, range, flame, change, jamaica, face, ain't.
12. `vow:IY` — 18 pairs (END 4, INNER 14). Words: even, louie, fiji, bp, deep, these, feelings, see.
13. `slant:AE:sib-stop` — 16 pairs (END 6, INNER 10). Words: ass, blast, fast, act, bad, bag, jag, stash.
14. `slant:EH:nas-stop` — 15 pairs (END 0, INNER 15). Words: get, when, let, better, getting, trunked, em, head.
15. `vow:EH` — 15 pairs (END 0, INNER 15). Words: getting, irrelevant, em, when, left, every, head, america.
16. `slant:IH:nas-stop` — 14 pairs (END 0, INNER 14). Words: him, shit, dick, lick, wit, hit, king, tip.
17. `slant:AA:stop` — 12 pairs (END 0, INNER 12). Words: got, gotta, squad, body, drop, pocket, shot, opp.
18. `slant:AE:nas` — 11 pairs (END 6, INNER 5). Words: bang, man, action, gang, banger, can, cracking, lacking.
19. `slant:AH:stop` — 11 pairs (END 0, INNER 11). Words: fuck, what, nut, butt, bust, plug.
20. `slant:EH:stop` — 11 pairs (END 0, INNER 11). Words: get, left, head, better, let, already.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- niggas — 30 pair sides, mostly spelling via spelling phonetic key, often with killas (6)
- nigga — 16 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- killas — 14 pair sides, mostly spelling via spelling phonetic key, often with niggas (6)
- dont — 10 pair sides, mostly vowel via spelling phonetic key, often with most (2)
- hittas — 8 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- trunked — 8 pair sides, mostly cmu via vault phonetic_class, often with well (3)
- gettas — 7 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- drillas — 6 pair sides, mostly spelling via spelling phonetic key, often with ass (2)
- finessing — 6 pair sides, mostly spelling via spelling phonetic key, often with lick (2)
- imma — 6 pair sides, mostly vowel via spelling phonetic key, often with nigga (2)
- swishers — 5 pair sides, mostly spelling via spelling phonetic key, often with sister (1)
- dolo — 4 pair sides, mostly spelling via spelling phonetic key, often with rolling (1)
- stuntin — 3 pair sides, mostly vowel via spelling phonetic key, often with bluffing (2)
- finna — 3 pair sides, mostly spelling via spelling phonetic key, often with him (2)
- slayers — 3 pair sides, mostly spelling via spelling phonetic key, often with drillers (1)
- jag — 2 pair sides, mostly spelling via spelling phonetic key, often with stash (1)
- foenem — 2 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- boujee — 2 pair sides, mostly vowel via spelling phonetic key, often with only (1)
- dissas — 1 pair sides, mostly spelling via spelling phonetic key, often with ass (1)
- chainz — 1 pair sides, mostly spelling via spelling phonetic key, often with stain (1)
- stunting — 1 pair sides, mostly spelling via spelling phonetic key, often with thing (1)
- wrestlemania — 1 pair sides, mostly spelling via spelling phonetic key, often with romania (1)
- smackdown — 1 pair sides, mostly spelling via spelling phonetic key, often with clown (1)
- chiefin — 1 pair sides, mostly vowel via spelling phonetic key, often with chillin (1)
- omarion — 1 pair sides, mostly spelling via spelling phonetic key, often with known (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| King Louie | Eastside Shit | 35 | 69 | 503 | loose |
| King Louie | Hit a Lick | 46 | 42 | 249 | loose |
| King Louie | Wrestlemania | 29 | 19 | 65 | loose |
