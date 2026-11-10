# Doe Boy rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Doe Boy
- Songs: 5
- Bars kept (Doe Boy lyric lines): 289
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Doe Boy.
- Credit strings: Doe Boy.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 2409
- REPEAT pairs, recorded separately: 233
- END rhymes: 399
- INNER rhymes: 2010

By match:

- PERFECT: 180 (END 39, INNER 141)
- SLANT: 1073 (END 170, INNER 903)
- ASSONANCE: 1142 (END 183, INNER 959)
- MULTI: 14 (END 7, INNER 7)

By confidence:

- HIGH: 172
- MED: 2086
- LOW: 151

## Core

- Core Y: 2366
- Core N among rhyme pairs: 43

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 1124 (46.7%)
- vowel: 1142 (47.4%)
- spelling: 129 (5.4%)
- multi: 14 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 5 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 264 pairs (END 78, INNER 186). Words: don't, know, ho, told, clothes, no, broke, go.
2. `vow:IH` — 150 pairs (END 4, INNER 146). Words: bitch, think, shit, bitches, him, fifty, pills, sippin.
3. `vow:IY` — 122 pairs (END 9, INNER 113). Words: keep, demon, see, real, beefing, g, secret, beezy.
4. `vow:AE` — 116 pairs (END 18, INNER 98). Words: can't, traffic, ass, casket, basket, have, catch, havin.
5. `vow:AH` — 115 pairs (END 30, INNER 85). Words: fuck, somethin, money, puppies, stomach, mustard, done, sucked.
6. `vow:EY` — 107 pairs (END 4, INNER 103). Words: ain't, play, baby, lately, came, changed, same, flames.
7. `vow:AA` — 100 pairs (END 12, INNER 88). Words: nothin, got, rocks, shots, lot, talkin, pop, want.
8. `slant:AA:stop` — 82 pairs (END 15, INNER 67). Words: got, block, lot, dropped, gotta, vomit, hot, chop.
9. `vow:EH` — 64 pairs (END 8, INNER 56). Words: gettin, get, neck, check, twenty, wealth, tennis, said.
10. `slant:IH:stop` — 59 pairs (END 0, INNER 59). Words: nigga, shit, hit, big, fifty, dig, whip, crib.
11. `slant:EH:stop` — 57 pairs (END 12, INNER 45). Words: get, check, better, let, said, already, step, yet.
12. `cmu:OW` — 42 pairs (END 12, INNER 30). Words: know, ho, though, no, go, blow, bro, doe.
13. `vow:AY` — 40 pairs (END 2, INNER 38). Words: like, fly, try, diamonds, hi, assignment, buy, shinin.
14. `slant:AH:nas-stop` — 39 pairs (END 5, INNER 34). Words: fuck, money, some, what, funny, drug, run, young.
15. `slant:IH:sib-stop` — 37 pairs (END 0, INNER 37). Words: bitch, hit, nigga, niggas, shit, crib, rich, chris.
16. `slant:IH:nas-stop` — 33 pairs (END 0, INNER 33). Words: him, hit, bring, everything, crib, thing, wit, hitter.
17. `slant:OW:sib-stop` — 30 pairs (END 24, INNER 6). Words: closer, post, woke, rolls, closed, toes, sosa, dope.
18. `vow:ER` — 30 pairs (END 18, INNER 12). Words: virgin, purging, words, nerves, fergie, purpose, herb, first.
19. `slant:EH:nas-stop` — 27 pairs (END 0, INNER 27). Words: when, get, let, better, gettin, n, dead, ready.
20. `slant:IH:liq-stop` — 24 pairs (END 0, INNER 24). Words: lil, really, hit, big, still, clip, drill, crib.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 36 pair sides, mostly spelling via spelling phonetic key, often with shit (6)
- gon — 26 pair sides, mostly spelling via spelling phonetic key, often with dont (8)
- niggas — 12 pair sides, mostly spelling via spelling phonetic key, often with nigga (6)
- beezy — 9 pair sides, mostly vowel via spelling phonetic key, often with baby (2)
- opps — 7 pair sides, mostly vowel via spelling phonetic key, often with glocks (2)
- glocks — 7 pair sides, mostly vowel via spelling phonetic key, often with hold (2)
- blicky — 6 pair sides, mostly spelling via spelling phonetic key, often with give (2)
- ratted — 5 pair sides, mostly spelling via spelling phonetic key, often with basket (1)
- birkin — 5 pair sides, mostly vowel via spelling phonetic key, often with think (1)
- triss — 5 pair sides, mostly vowel via spelling phonetic key, often with sticks (1)
- tatted — 4 pair sides, mostly spelling via spelling phonetic key, often with dramatic (1)
- lambo — 4 pair sides, mostly vowel via spelling phonetic key, often with doe (1)
- geekin — 3 pair sides, mostly spelling via spelling phonetic key, often with peon (1)
- youngin — 3 pair sides, mostly spelling via spelling phonetic key, often with ballin (1)
- cheeto — 3 pair sides, mostly spelling via spelling phonetic key, often with need (1)
- coked — 3 pair sides, mostly vowel via vault phonetic_class, often with vulture (1)
- prolly — 3 pair sides, mostly vowel via spelling phonetic key, often with money (1)
- raq — 3 pair sides, mostly spelling via spelling phonetic key, often with static (1)
- ason — 3 pair sides, mostly spelling via spelling phonetic key, often with demon (2)
- guap — 2 pair sides, mostly spelling via spelling phonetic key, often with drug (1)
- swerv — 2 pair sides, mostly spelling via spelling phonetic key, often with heard (1)
- thot — 2 pair sides, mostly vowel via vault phonetic_class, often with these (1)
- finna — 2 pair sides, mostly spelling via spelling phonetic key, often with spin (1)
- foenem — 2 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- wifey — 2 pair sides, mostly spelling via spelling phonetic key, often with money (1)
- fentanyl — 2 pair sides, mostly spelling via spelling phonetic key, often with real (2)
- drankin — 2 pair sides, mostly spelling via spelling phonetic key, often with drinkin (1)
- wock — 2 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- atake — 1 pair sides, mostly spelling via spelling phonetic key, often with black (1)
- marni — 1 pair sides, mostly spelling via spelling phonetic key, often with arch (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Doe Boy | Bussin | 78 | 155 | 515 | loose |
| Doe Boy | Neva Froze | 50 | 65 | 231 | loose |
| Doe Boy | OPP PARTY | 52 | 32 | 351 | loose |
| Doe Boy | SET IT OFF | 50 | 69 | 521 | loose |
| Doe Boy | TRY & SEE | 59 | 78 | 392 | loose |
