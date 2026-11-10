# Wave Chapelle rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Wave Chapelle
- Songs: 1
- Bars kept (Wave Chapelle lyric lines): 43
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Wave Chapelle.
- Credit strings: Wave Chapelle.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 222
- REPEAT pairs, recorded separately: 21
- END rhymes: 48
- INNER rhymes: 174

By match:

- PERFECT: 28 (END 7, INNER 21)
- SLANT: 87 (END 23, INNER 64)
- ASSONANCE: 107 (END 18, INNER 89)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 13
- MED: 188
- LOW: 21

## Core

- Core Y: 217
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 84 (37.8%)
- vowel: 107 (48.2%)
- spelling: 31 (14.0%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 23 pairs (END 6, INNER 17). Words: actors, damage, family, happen, atlanta, man, back, makin.
2. `vow:IH` — 20 pairs (END 6, INNER 14). Words: millions, city, kitchen, bitches, living, building, decisions, winning.
3. `vow:AH` — 17 pairs (END 3, INNER 14). Words: one, number, nothing, uncomfortable, fucking, young, punching, hustling.
4. `slant:AE:nas` — 16 pairs (END 5, INNER 11). Words: happen, clappin, mackin, captain, hapnin, xanny, makin, lackin.
5. `vow:EH` — 11 pairs (END 0, INNER 11). Words: get, myself, went, swear, scared, never, eversince, gettin.
6. `vow:EY` — 10 pairs (END 0, INNER 10). Words: takin, away, pain, ain't, paid, say, way, take.
7. `cmu:IH-NG` — 9 pairs (END 0, INNER 9). Words: stunting, cuffing, hustling, fucking, punching, crushing, gettin, riding.
8. `slant:AA:sib-stop` — 8 pairs (END 5, INNER 3). Words: boss, not, shots, got, clock, block, cost.
9. `slant:AA:stop` — 7 pairs (END 4, INNER 3). Words: block, not, clock, got, pot.
10. `slant:AE:nas-stop` — 6 pairs (END 0, INNER 6). Words: pac, man, back, atlanta, stacking, lackin, mackin, plan.
11. `slant:AH:nas-stop` — 6 pairs (END 5, INNER 1). Words: one, what, fun, fuck, young, guap.
12. `slant:IH:stop` — 6 pairs (END 0, INNER 6). Words: nigga, city, kick, shit, clip.
13. `vow:OW` — 6 pairs (END 0, INNER 6). Words: know, don't, own, no, thots, go, open.
14. `vow:IY` — 5 pairs (END 0, INNER 5). Words: feeling, xanny, see, real, need, keep, uzi, city.
15. `slant:EY:nas-stop` — 4 pairs (END 0, INNER 4). Words: take, takin, taking, make, pain.
16. `vow:AY` — 4 pairs (END 0, INNER 4). Words: riding, like, time, grinding, try, right.
17. `cmu:AH-N` — 3 pairs (END 2, INNER 1). Words: one, fun.
18. `slant:EH:liq-stop` — 3 pairs (END 0, INNER 3). Words: get, where, rep, swear.
19. `slant:IH:liq-stop` — 3 pairs (END 0, INNER 3). Words: lil, city, clip, pill.
20. `slant:IH:sib-stop` — 3 pairs (END 0, INNER 3). Words: niggas, nigga, kick, busy.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 8 pair sides, mostly spelling via spelling phonetic key, often with city (3)
- stunting — 7 pair sides, mostly spelling via spelling phonetic key, often with punching (1)
- xanny — 5 pair sides, mostly spelling via spelling phonetic key, often with uzi (1)
- hapnin — 4 pair sides, mostly spelling via spelling phonetic key, often with clappin (1)
- wavey — 3 pair sides, mostly spelling via spelling phonetic key, often with casey (1)
- cuffing — 3 pair sides, mostly spelling via spelling phonetic key, often with stunting (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- eversince — 2 pair sides, mostly vowel via spelling phonetic key, often with never (1)
- guap — 1 pair sides, mostly spelling via spelling phonetic key, often with young (1)
- thots — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- sliders — 1 pair sides, mostly spelling via spelling phonetic key, often with actors (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Wave Chapelle | Boss Up | 43 | 48 | 174 | loose |
