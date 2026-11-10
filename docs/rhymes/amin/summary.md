# Aminé rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Aminé
- Songs: 1
- Bars kept (Aminé lyric lines): 46
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Aminé.
- Credit strings: Aminé.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 172
- REPEAT pairs, recorded separately: 38
- END rhymes: 42
- INNER rhymes: 130

By match:

- PERFECT: 17 (END 6, INNER 11)
- SLANT: 72 (END 9, INNER 63)
- ASSONANCE: 81 (END 25, INNER 56)
- MULTI: 2 (END 2, INNER 0)

By confidence:

- HIGH: 16
- MED: 143
- LOW: 13

## Core

- Core Y: 165
- Core N among rhyme pairs: 7

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 80 (46.5%)
- vowel: 81 (47.1%)
- spelling: 9 (5.2%)
- multi: 2 (1.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 24 pairs (END 17, INNER 7). Words: happenin, challenge, acura, habits, gram, balance, accurate, jacket.
2. `slant:IH:sib-stop` — 15 pairs (END 1, INNER 14). Words: bitch, shit, drip, dick.
3. `vow:IH` — 14 pairs (END 0, INNER 14). Words: bitch, window, amiri, mixin, whippin, mixed, hit, didn't.
4. `vow:OW` — 11 pairs (END 2, INNER 9). Words: told, don't, heroic, hoes, herbo, rico, old, thots.
5. `vow:EH` — 9 pairs (END 0, INNER 9). Words: ever, independent, sexy, end, messy, fresh, hell, gettin.
6. `vow:EY` — 9 pairs (END 2, INNER 7). Words: say, kay, name, fade, gabe, make, made.
7. `cmu:EH-SH` — 6 pairs (END 2, INNER 4). Words: fresh, flesh.
8. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: shit, drip, dick, hit.
9. `slant:AY:stop` — 4 pairs (END 0, INNER 4). Words: like, white, right, alright.
10. `slant:EY:nas-stop` — 4 pairs (END 0, INNER 4). Words: name, make, fade, gabe, made.
11. `slant:EY:stop` — 4 pairs (END 0, INNER 4). Words: gabe, make, fade, made.
12. `vow:IY` — 4 pairs (END 0, INNER 4). Words: cory, see, here, scene, hear, reach.
13. `cmu:UH-K` — 3 pairs (END 0, INNER 3). Words: shook, look.
14. `slant:AA:nas-stop` — 3 pairs (END 0, INNER 3). Words: got, wanna.
15. `spell:ie` — 3 pairs (END 3, INNER 0). Words: movie, boosie, webbie.
16. `vow:AY` — 3 pairs (END 1, INNER 2). Words: diamonds, slide, buyin, shine.
17. `vow:UW` — 3 pairs (END 3, INNER 0). Words: groupies, movie, goofy, boosie.
18. `slant:AE:nas-stop` — 2 pairs (END 1, INNER 1). Words: goddammit, gram.
19. `slant:AE:sib-stop` — 2 pairs (END 1, INNER 1). Words: chat, pass, bag, tags.
20. `slant:EH:fric-sib` — 2 pairs (END 0, INNER 2). Words: ever, messy, fresh.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- boosie — 4 pair sides, mostly spelling via spelling phonetic key, often with movie (1)
- herbo — 3 pair sides, mostly vowel via spelling phonetic key, often with pico (1)
- skrtin — 3 pair sides, mostly spelling via spelling phonetic key, often with whippin (1)
- webbie — 2 pair sides, mostly spelling via spelling phonetic key, often with movie (1)
- swervo — 2 pair sides, mostly vowel via spelling phonetic key, often with rico (1)
- ima — 1 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- borat — 1 pair sides, mostly spelling via spelling phonetic key, often with told (1)
- thots — 1 pair sides, mostly vowel via spelling phonetic key, often with dont (1)
- amiris — 1 pair sides, mostly vowel via spelling phonetic key, often with goddammit (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Aminé | DAPPERDAN | 46 | 42 | 130 | loose |
