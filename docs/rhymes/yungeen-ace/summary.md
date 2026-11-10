# Yungeen Ace rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Yungeen Ace
- Songs: 3
- Bars kept (Yungeen Ace lyric lines): 127
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Yungeen Ace.
- Credit strings: Yungeen Ace.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1072
- REPEAT pairs, recorded separately: 112
- END rhymes: 126
- INNER rhymes: 946

By match:

- PERFECT: 102 (END 29, INNER 73)
- SLANT: 446 (END 50, INNER 396)
- ASSONANCE: 518 (END 47, INNER 471)
- MULTI: 6 (END 0, INNER 6)

By confidence:

- HIGH: 99
- MED: 892
- LOW: 81

## Core

- Core Y: 1044
- Core N among rhyme pairs: 28

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 487 (45.4%)
- vowel: 518 (48.3%)
- spelling: 61 (5.7%)
- multi: 6 (0.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 133 pairs (END 21, INNER 112). Words: enemies, dead, em, remember, already, stretched, revenge, ever.
2. `vow:EY` — 78 pairs (END 12, INNER 66). Words: ain't, say, way, day, away, case, debatin, place.
3. `vow:IH` — 64 pairs (END 1, INNER 63). Words: bitch, business, tinted, windows, kill, shit, spittin, hit.
4. `vow:OW` — 51 pairs (END 0, INNER 51). Words: opps, know, no, don't, go, open, poles, whole.
5. `vow:AA` — 41 pairs (END 1, INNER 40). Words: want, got, bodies, wanna, dark, harder, deposits, droppin.
6. `vow:AY` — 38 pairs (END 2, INNER 36). Words: diamonds, shining, time, fightin, y, slidin, like, by.
7. `slant:EY:stop` — 33 pairs (END 4, INNER 29). Words: ain't, wait, hate, baby, fade, gate, estate, state.
8. `vow:IY` — 33 pairs (END 1, INNER 32). Words: nobody, tweets, see, real, g, seen, shawty, increased.
9. `slant:EH:stop` — 27 pairs (END 4, INNER 23). Words: dead, already, get, kept, friend, went, bet, ged.
10. `slant:AA:stop` — 25 pairs (END 0, INNER 25). Words: got, want, gotta, hop, drop, block, body, not.
11. `vow:AH` — 25 pairs (END 1, INNER 24). Words: comin, w, trust, untouchable, fuck, brother, another, jumpin.
12. `vow:AE` — 23 pairs (END 0, INNER 23). Words: family, have, had, hand, stabbed, ass, grams, fallin.
13. `slant:IH:stop` — 21 pairs (END 0, INNER 21). Words: nigga, hit, slick, pity, shit, wit, think, stick.
14. `slant:AA:nas-stop` — 18 pairs (END 0, INNER 18). Words: got, wanna, momma, don, body, robbery, drop, mama.
15. `cmu:OW` — 16 pairs (END 0, INNER 16). Words: no, know, hoe, go.
16. `slant:IY:liq-stop` — 16 pairs (END 2, INNER 14). Words: real, sweet, deep, feel, feet, street, creep, eat.
17. `vow:AO` — 16 pairs (END 1, INNER 15). Words: wanted, blogs, ball, awards, forbes, handball, war, long.
18. `slant:EY:sib-stop` — 15 pairs (END 11, INNER 4). Words: place, face, hate, ate, gate, case, baby, wait.
19. `cmu:EY-T` — 14 pairs (END 5, INNER 9). Words: hate, wait, ate, gate, elevate, plate, estate.
20. `slant:IH:sib-stop` — 14 pairs (END 0, INNER 14). Words: bitch, nigga, niggas, shit, hit, slick, wit, licks.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- opps — 27 pair sides, mostly vowel via spelling phonetic key, often with know (13)
- nigga — 19 pair sides, mostly spelling via spelling phonetic key, often with hit (5)
- niggas — 11 pair sides, mostly spelling via spelling phonetic key, often with nigga (4)
- tryna — 10 pair sides, mostly spelling via spelling phonetic key, often with seen (1)
- choppa — 8 pair sides, mostly spelling via spelling phonetic key, often with opps (7)
- choppas — 4 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- killas — 4 pair sides, mostly spelling via spelling phonetic key, often with niggas (1)
- shawty — 3 pair sides, mostly vowel via spelling phonetic key, often with sorry (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with only (2)
- laneisha — 3 pair sides, mostly spelling via spelling phonetic key, often with cant (2)
- chiraq — 3 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)
- niggasll — 2 pair sides, mostly vowel via spelling phonetic key, often with niggas (1)
- covid — 1 pair sides, mostly spelling via spelling phonetic key, often with wanted (1)
- turbulance — 1 pair sides, mostly vowel via spelling phonetic key, often with brother (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Yungeen Ace | B.A.M | 44 | 58 | 283 | loose |
| Yungeen Ace | Choppas 4 My Enemies | 45 | 47 | 462 | loose |
| Yungeen Ace | Deserve It | 38 | 21 | 201 | loose |
