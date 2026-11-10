# Tsunami J rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Tsunami J
- Songs: 1
- Bars kept (Tsunami J lyric lines): 73
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Tsunami J.
- Credit strings: Tsunami J.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 425
- REPEAT pairs, recorded separately: 53
- END rhymes: 62
- INNER rhymes: 363

By match:

- PERFECT: 44 (END 7, INNER 37)
- SLANT: 183 (END 28, INNER 155)
- ASSONANCE: 197 (END 26, INNER 171)
- MULTI: 1 (END 1, INNER 0)

By confidence:

- HIGH: 43
- MED: 359
- LOW: 23

## Core

- Core Y: 417
- Core N among rhyme pairs: 8

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 209 (49.2%)
- vowel: 197 (46.4%)
- spelling: 18 (4.2%)
- multi: 1 (0.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IY` — 44 pairs (END 18, INNER 26). Words: see, tweakin, peoples, freedom, breathin, lethal, heater, cheetahs.
2. `vow:EY` — 30 pairs (END 4, INNER 26). Words: ain't, j, situation, games, playin, game, obligation, patients.
3. `vow:AA` — 26 pairs (END 0, INNER 26). Words: nothin, da, got, yah, profits, hollows, rob, start.
4. `vow:OW` — 23 pairs (END 0, INNER 23). Words: don't, know, no, smoked, bro, cockroaches, home, gots.
5. `vow:IH` — 17 pairs (END 0, INNER 17). Words: really, middle, hits, think, lives, hit, give, niggas.
6. `vow:AE` — 14 pairs (END 2, INNER 12). Words: jams, bands, can't, can, ass, stackin, action, jam.
7. `vow:EH` — 14 pairs (END 0, INNER 14). Words: steppin, there's, eh, when, em, smell, gettin, obituaries.
8. `vow:AY` — 13 pairs (END 2, INNER 11). Words: signs, fire, time, find, by, like, pipes, try.
9. `slant:AA:nas-stop` — 12 pairs (END 3, INNER 9). Words: mics, non, got, tsunami, want, wanna, pop, gotta.
10. `slant:IY:nas` — 11 pairs (END 7, INNER 4). Words: dreamin, tweakin, seen, breathin, mean, beam, freedom, lean.
11. `vow:AH` — 10 pairs (END 0, INNER 10). Words: nuttin, some, couple, thunder, none, what, hundred, run.
12. `slant:AA:stop` — 9 pairs (END 0, INNER 9). Words: knock, pop, got, not, top, want, shot, doctor.
13. `slant:AY:sib-stop` — 8 pairs (END 2, INNER 6). Words: guys, pies, ride, like, lakeside, type.
14. `slant:EH:liq-nas` — 8 pairs (END 0, INNER 8). Words: when, n, err, there, smell, em, spare, tell.
15. `slant:EH:nas-stop` — 7 pairs (END 2, INNER 5). Words: get, n, better, em, when, red.
16. `slant:IY:nas-sib` — 7 pairs (END 2, INNER 5). Words: knees, neither, seen, nina, breathin, lean, scene, mean.
17. `cmu:IY-N` — 6 pairs (END 2, INNER 4). Words: seen, scene, mean, lean.
18. `slant:AY:nas-stop` — 6 pairs (END 1, INNER 5). Words: flyin, like, time, ride, lakeside, daytime, right.
19. `slant:IH:liq-stop` — 6 pairs (END 0, INNER 6). Words: really, wit, kill, still, shit, hit, spit.
20. `vow:UW` — 6 pairs (END 0, INNER 6). Words: shootin, fu, new, sooner, use, two, used.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- mics — 6 pair sides, mostly cmu via vault phonetic_class, often with pop (2)
- niggas — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- cuz — 3 pair sides, mostly spelling via spelling phonetic key, often with fuck (1)
- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with niggas (2)
- gots — 3 pair sides, mostly vowel via spelling phonetic key, often with amigos (1)
- witcho — 3 pair sides, mostly spelling via spelling phonetic key, often with really (2)
- yall — 2 pair sides, mostly spelling via spelling phonetic key, often with call (2)
- gangway — 1 pair sides, mostly vowel via spelling phonetic key, often with j (1)
- lames — 1 pair sides, mostly vowel via spelling phonetic key, often with have (1)
- extendo — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- opps — 1 pair sides, mostly vowel via spelling phonetic key, often with know (1)
- whachu — 1 pair sides, mostly spelling via spelling phonetic key, often with man (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Tsunami J | War Time (Remix) | 73 | 62 | 363 | loose |
