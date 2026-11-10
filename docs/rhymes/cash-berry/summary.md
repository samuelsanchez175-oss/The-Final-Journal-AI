# Cash Berry rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Cash Berry
- Songs: 1
- Bars kept (Cash Berry lyric lines): 65
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Cash Berry.
- Credit strings: Cash Berry.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 505
- REPEAT pairs, recorded separately: 68
- END rhymes: 76
- INNER rhymes: 429

By match:

- PERFECT: 36 (END 9, INNER 27)
- SLANT: 235 (END 41, INNER 194)
- ASSONANCE: 232 (END 26, INNER 206)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 23
- MED: 459
- LOW: 23

## Core

- Core Y: 500
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 238 (47.1%)
- vowel: 232 (45.9%)
- spelling: 33 (6.5%)
- multi: 2 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 126 pairs (END 22, INNER 104). Words: assists, hit, assist, shit, killing, griffin, kitchen, whipping.
2. `slant:IH:stop` — 59 pairs (END 16, INNER 43). Words: shit, hit, dick, assist, kidd, nigga, lick, clip.
3. `slant:IH:sib-stop` — 48 pairs (END 7, INNER 41). Words: bitch, hit, dick, myth, shit, chris, lick, kidd.
4. `vow:AE` — 28 pairs (END 1, INNER 27). Words: traveling, packages, back, savage, trafficking, catching, average, man.
5. `vow:OW` — 18 pairs (END 0, INNER 18). Words: don't, load, know, told, whole, no, broken, ho.
6. `slant:IH:liq-stop` — 15 pairs (END 0, INNER 15). Words: lil, shit, till, clip, hit, flip, kill, dick.
7. `slant:EH:stop` — 13 pairs (END 10, INNER 3). Words: get, neck, enter, nest, set.
8. `vow:EH` — 13 pairs (END 3, INNER 10). Words: get, flexing, neck, myself, contend, scared, whoever, enter.
9. `vow:AH` — 12 pairs (END 0, INNER 12). Words: funds, must, come, money, fuck, love, justice, stumbling.
10. `cmu:IH-NG` — 11 pairs (END 0, INNER 11). Words: chiefing, bracking, repping, traveling, moving, trafficking, catching, sitting.
11. `vow:IY` — 11 pairs (END 0, INNER 11). Words: keep, means, evil, see, feel, b, need, titty.
12. `vow:EY` — 10 pairs (END 0, INNER 10). Words: graded, praise, waiting, conversations, jason, blake, kay, ain't.
13. `slant:EH:sib-stop` — 9 pairs (END 3, INNER 6). Words: finesse, progress, nest, set, neck, get, yes, said.
14. `slant:IH:nas-stop` — 9 pairs (END 0, INNER 9). Words: hit, everything, thing, shit, lip, him, chiefing, drift.
15. `cmu:IH-K` — 8 pairs (END 8, INNER 0). Words: dick, lick, brick.
16. `cmu:IH-T` — 7 pairs (END 0, INNER 7). Words: hit, shit, spit.
17. `slant:AH:nas-stop` — 7 pairs (END 1, INNER 6). Words: fuck, money, come.
18. `slant:AY:nas-stop` — 6 pairs (END 0, INNER 6). Words: trying, like, china, right, light, might.
19. `slant:AY:stop` — 6 pairs (END 0, INNER 6). Words: like, might, light, slide, right.
20. `slant:EH:liq-stop` — 5 pairs (END 1, INNER 4). Words: fair, get, tell, ready, scared, said.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- chiefing — 9 pair sides, mostly spelling via spelling phonetic key, often with trip (1)
- bracking — 5 pair sides, mostly spelling via spelling phonetic key, often with traveling (1)
- titty — 3 pair sides, mostly spelling via spelling phonetic key, often with liquor (1)
- repping — 2 pair sides, mostly spelling via spelling phonetic key, often with sitting (1)
- hella — 2 pair sides, mostly spelling via spelling phonetic key, often with fair (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- toucan — 2 pair sides, mostly spelling via spelling phonetic key, often with man (1)
- killuminati — 1 pair sides, mostly vowel via spelling phonetic key, often with still (1)
- homie — 1 pair sides, mostly spelling via spelling phonetic key, often with own (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Cash Berry | Assist | 65 | 76 | 429 | loose |
