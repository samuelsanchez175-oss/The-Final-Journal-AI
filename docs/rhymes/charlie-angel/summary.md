# Charlie Angel rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Charlie Angel
- Songs: 1
- Bars kept (Charlie Angel lyric lines): 52
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Charlie Angel.
- Credit strings: Charlie Angel.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 331
- REPEAT pairs, recorded separately: 20
- END rhymes: 68
- INNER rhymes: 263

By match:

- PERFECT: 38 (END 14, INNER 24)
- SLANT: 117 (END 16, INNER 101)
- ASSONANCE: 170 (END 33, INNER 137)
- MULTI: 6 (END 5, INNER 1)

By confidence:

- HIGH: 41
- MED: 280
- LOW: 10

## Core

- Core Y: 330
- Core N among rhyme pairs: 1

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 143 (43.2%)
- vowel: 170 (51.4%)
- spelling: 12 (3.6%)
- multi: 6 (1.8%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 47 pairs (END 14, INNER 33). Words: wanna, charge, talkin, hard, carton, stardom, hearted, pardon.
2. `vow:EY` — 31 pairs (END 1, INNER 30). Words: ain’t, play, making, always, james, frame, same, separate.
3. `vow:IY` — 28 pairs (END 6, INNER 22). Words: keep, see, deep, reason, streets, tryna, speak, dreams.
4. `vow:AY` — 19 pairs (END 8, INNER 11). Words: survive, tryin, lie, smiles, pie, fighter, vibes, high.
5. `vow:EH` — 15 pairs (END 1, INNER 14). Words: barely, energy, m, get, better, friends, forget, left.
6. `vow:OW` — 14 pairs (END 0, INNER 14). Words: no, don’t, ebro, goat, growth, broken, holding, go.
7. `vow:IH` — 12 pairs (END 3, INNER 9). Words: finish, pinnin, years, stability, experience, opinions, kinda, shit.
8. `cmu:AY` — 8 pairs (END 8, INNER 0). Words: pie, lie, cry, die, spy, eye.
9. `cmu:AO-L` — 7 pairs (END 1, INNER 6). Words: all, y’all, call, ball.
10. `cmu:IY` — 7 pairs (END 1, INNER 6). Words: tryna, free, nobody, see, p, b.
11. `slant:IY:nas-stop` — 7 pairs (END 3, INNER 4). Words: tryna, eat, seein, being, beat, feed, street.
12. `slant:IY:stop` — 7 pairs (END 2, INNER 5). Words: speak, keep, deep, leader, feed, street, beat.
13. `cmu:EY-M` — 6 pairs (END 3, INNER 3). Words: frame, same, shame, blame.
14. `slant:AA:nas` — 6 pairs (END 6, INNER 0). Words: stardom, carton, darden, pardon, harden.
15. `slant:AA:nas-stop` — 6 pairs (END 0, INNER 6). Words: hard, wanna, darden, stardom, pardon, got, everybody, gotta.
16. `slant:AO:liq-stop` — 6 pairs (END 0, INNER 6). Words: bawled, talk, all, y’all, call, ball.
17. `slant:EY:nas-sib` — 6 pairs (END 0, INNER 6). Words: always, game, james, airways, same, shame, blame.
18. `slant:EY:sib-stop` — 5 pairs (END 0, INNER 5). Words: days, make, separate, airways, trade.
19. `slant:EY:stop` — 5 pairs (END 0, INNER 5). Words: make, trade, drained, paint, escape, fake.
20. `slant:AO:liq-sib` — 4 pairs (END 1, INNER 3). Words: falls, all, call.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- tryna — 11 pair sides, mostly vowel via vault phonetic_class, often with eat (2)
- ating — 3 pair sides, mostly spelling via spelling phonetic key, often with pushin (1)
- onna — 2 pair sides, mostly spelling via spelling phonetic key, often with dont (1)
- cuz — 2 pair sides, mostly spelling via spelling phonetic key, often with what (1)
- niggas — 1 pair sides, mostly vowel via spelling phonetic key, often with kinda (1)
- ebt — 1 pair sides, mostly spelling via spelling phonetic key, often with bet (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Charlie Angel | How You Did That (Remix) | 52 | 68 | 263 | loose |
