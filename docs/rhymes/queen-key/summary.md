# Queen Key rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Queen Key
- Songs: 1
- Bars kept (Queen Key lyric lines): 41
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Queen Key.
- Credit strings: Queen Key.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 331
- REPEAT pairs, recorded separately: 37
- END rhymes: 46
- INNER rhymes: 285

By match:

- PERFECT: 70 (END 26, INNER 44)
- SLANT: 138 (END 13, INNER 125)
- ASSONANCE: 123 (END 7, INNER 116)
- MULTI: 0 (END 0, INNER 0)

By confidence:

- HIGH: 69
- MED: 246
- LOW: 16

## Core

- Core Y: 329
- Core N among rhyme pairs: 2

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 192 (58.0%)
- vowel: 123 (37.2%)
- spelling: 16 (4.8%)
- multi: 0 (0.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 31 pairs (END 2, INNER 29). Words: hoes, don't, gold, know, don’t, code, joe, throws.
2. `slant:IH:sib` — 29 pairs (END 9, INNER 20). Words: bitch, chris, bitches, miss, kiss, rich.
3. `vow:IY` — 28 pairs (END 0, INNER 28). Words: g, dreams, free, see, seen, sleep, greet, weak.
4. `vow:IH` — 25 pairs (END 0, INNER 25). Words: shit, think, bitch, bitches, kiss, link, pinky, little.
5. `cmu:OW` — 18 pairs (END 6, INNER 12). Words: joe, know, dough, show, go, though, puerto.
6. `cmu:OW-Z` — 16 pairs (END 7, INNER 9). Words: hoes, rose, nose, shows, toes, throws, those.
7. `vow:EH` — 16 pairs (END 3, INNER 13). Words: best, when, ex, hex, never, sex, seconds, temple.
8. `slant:IH:stop` — 14 pairs (END 0, INNER 14). Words: pimp, minute, dick, shit, think, nigga, mink, hit.
9. `slant:IH:sib-stop` — 13 pairs (END 0, INNER 13). Words: bitch, hit, big, dick, shit, chris, rich.
10. `cmu:IH-NG-K` — 10 pairs (END 7, INNER 3). Words: sink, shrink, mink, pink, blink, think.
11. `vow:AH` — 9 pairs (END 1, INNER 8). Words: under, love, husband, cousin, trust, come, another, fuck.
12. `slant:IH:nas-stop` — 8 pairs (END 1, INNER 7). Words: i’ma, shit, him, dick, ring, link, pinky, pimp.
13. `cmu:IH-S` — 7 pairs (END 3, INNER 4). Words: chris, kiss, miss.
14. `vow:EY` — 7 pairs (END 1, INNER 6). Words: tails, name, ain't, stale, take, always, named, playing.
15. `slant:IY:sib-stop` — 6 pairs (END 0, INNER 6). Words: these, sneaky, easy, sleep, greet, weak.
16. `slant:IY:stop` — 6 pairs (END 0, INNER 6). Words: sneaky, sleep, freek, leek, weak, greet.
17. `slant:AH:fric-stop` — 5 pairs (END 0, INNER 5). Words: love, suck, fuck.
18. `slant:IY:nas-stop` — 5 pairs (END 0, INNER 5). Words: seen, eating, sweet, freek, leek, sneaky, sleep.
19. `cmu:EH-L` — 4 pairs (END 0, INNER 4). Words: tell, well.
20. `cmu:IH-CH` — 4 pairs (END 0, INNER 4). Words: bitch, rich.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 6 pair sides, mostly spelling via spelling phonetic key, often with shit (2)
- freek — 4 pair sides, mostly spelling via spelling phonetic key, often with leek (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- brazy — 2 pair sides, mostly spelling via spelling phonetic key, often with man (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with these (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with ass (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with throws (1)
- grenadine — 1 pair sides, mostly vowel via spelling phonetic key, often with temple (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Queen Key | Sneakey Talez | 41 | 46 | 285 | loose |
