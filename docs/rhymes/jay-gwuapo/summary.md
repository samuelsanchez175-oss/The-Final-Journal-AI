# Jay Gwuapo rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Jay Gwuapo
- Songs: 4
- Bars kept (Jay Gwuapo lyric lines): 92
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Jay Gwuapo.
- Credit strings: Jay Gwuapo.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 578
- REPEAT pairs, recorded separately: 58
- END rhymes: 108
- INNER rhymes: 470

By match:

- PERFECT: 56 (END 19, INNER 37)
- SLANT: 259 (END 55, INNER 204)
- ASSONANCE: 262 (END 33, INNER 229)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 54
- MED: 483
- LOW: 41

## Core

- Core Y: 567
- Core N among rhyme pairs: 11

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 283 (49.0%)
- vowel: 262 (45.3%)
- spelling: 32 (5.5%)
- multi: 1 (0.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 4 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 48 pairs (END 10, INNER 38). Words: mention, blessings, get, trenches, let, sentence, weapon, section.
2. `vow:IH` — 45 pairs (END 2, INNER 43). Words: different, really, dripped, clifton, fifty, chillin, mixed, amiri.
3. `vow:OW` — 40 pairs (END 0, INNER 40). Words: know, showin, don't, emotions, older, toe, shows, won't.
4. `vow:EY` — 39 pairs (END 4, INNER 35). Words: ain't, play, say, straight, name, away, made, playin.
5. `vow:AE` — 28 pairs (END 7, INNER 21). Words: stash, mansion, past, dancing, tag, blast, panic, vanish.
6. `slant:IH:stop` — 25 pairs (END 7, INNER 18). Words: hit, big, clip, nigga, equipped, thick, rip, lift.
7. `slant:AE:stop` — 19 pairs (END 12, INNER 7). Words: panic, stand, granted, damaged, black, tag, throwback, mask.
8. `vow:IY` — 17 pairs (END 6, INNER 11). Words: see, suvy, tooly, party, keep, seen, cooly, v.
9. `vow:UW` — 16 pairs (END 0, INNER 16). Words: who, shooters, use, music, fool, cool, mood, shoes.
10. `vow:AA` — 13 pairs (END 2, INNER 11). Words: shots, opp, pop, got, cost, stars, hop, hottest.
11. `slant:EH:stop` — 12 pairs (END 3, INNER 9). Words: get, left, check, vet, neck, let, spent, ready.
12. `slant:AH:nas-sib` — 11 pairs (END 0, INNER 11). Words: other, some, done, brother, another, come, gun, run.
13. `slant:EH:liq-stop` — 11 pairs (END 3, INNER 8). Words: fell, get, neck, air, check, where, let, vet.
14. `slant:AE:sib-stop` — 10 pairs (END 2, INNER 8). Words: ass, vanish, tag, panic, bag, throwback, past, blast.
15. `vow:AH` — 10 pairs (END 2, INNER 8). Words: purg, comfortable, once, love, another, some, fuck, public.
16. `cmu:OW` — 9 pairs (END 0, INNER 9). Words: know, bro, toe, go, show.
17. `slant:AO:liq-stop` — 9 pairs (END 2, INNER 7). Words: small, walk, fall, talk, bald.
18. `slant:AH:fric-nas` — 8 pairs (END 0, INNER 8). Words: enough, some, tough, done, come.
19. `slant:EY:nas-stop` — 8 pairs (END 3, INNER 5). Words: rain, ain't, straight, name, lane, make, state, hate.
20. `cmu:AA-T` — 7 pairs (END 0, INNER 7). Words: got, lot, caught, not.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 11 pair sides, mostly spelling via spelling phonetic key, often with turn (3)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with big (3)
- tooly — 5 pair sides, mostly vowel via spelling phonetic key, often with movie (1)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- suvy — 4 pair sides, mostly vowel via spelling phonetic key, often with movie (1)
- cooly — 4 pair sides, mostly vowel via spelling phonetic key, often with movie (1)
- purg — 4 pair sides, mostly vowel via vault phonetic_class, often with another (1)
- opps — 3 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with hitters (1)
- gwuap — 2 pair sides, mostly spelling via spelling phonetic key, often with run (1)
- goyard — 1 pair sides, mostly spelling via spelling phonetic key, often with yard (1)
- alhamdulillah — 1 pair sides, mostly vowel via spelling phonetic key, often with flags (1)
- cartiers — 1 pair sides, mostly spelling via spelling phonetic key, often with party (1)
- younging — 1 pair sides, mostly spelling via spelling phonetic key, often with playin (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with shit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Jay Gwuapo | Black Mask | 26 | 27 | 187 | loose |
| Jay Gwuapo | Lefty | 29 | 42 | 99 | loose |
| Jay Gwuapo | Paved The Way (Straight To The Top)* | 11 | 9 | 25 | loose |
| Jay Gwuapo | Pop & Panic (Small Talk) | 26 | 30 | 159 | loose |
