# The Plug rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: The Plug
- Songs: 1
- Bars kept (The Plug lyric lines): 40
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: The Plug.
- Credit strings: The Plug.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 405
- REPEAT pairs, recorded separately: 24
- END rhymes: 63
- INNER rhymes: 342

By match:

- PERFECT: 33 (END 5, INNER 28)
- SLANT: 153 (END 20, INNER 133)
- ASSONANCE: 216 (END 38, INNER 178)
- MULTI: 3 (END 0, INNER 3)

By confidence:

- HIGH: 29
- MED: 358
- LOW: 18

## Core

- Core Y: 402
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 164 (40.5%)
- vowel: 216 (53.3%)
- spelling: 22 (5.4%)
- multi: 3 (0.7%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AA` — 82 pairs (END 34, INNER 48). Words: father, dollars, postures, robbin, start, pardon, bargaining, bicarbonate.
2. `vow:EH` — 28 pairs (END 0, INNER 28). Words: mention, spreading, telling, trench, legit, s, next, respect.
3. `vow:AY` — 26 pairs (END 3, INNER 23). Words: like, pipes, life, white, purify, surprise, by, glorify.
4. `vow:EY` — 25 pairs (END 0, INNER 25). Words: ain't, say, came, make, mistakes, same, chains, uk.
5. `vow:IH` — 16 pairs (END 0, INNER 16). Words: think, gripping, mix, shit, him, tricks, still, bring.
6. `slant:AA:stop` — 11 pairs (END 4, INNER 7). Words: got, deposit, top, pocket, block, pharmacist, bicarbonate, sparked.
7. `vow:OW` — 11 pairs (END 0, INNER 11). Words: don't, know, home, goes, low, whole, close, poles.
8. `slant:AA:nas` — 10 pairs (END 9, INNER 1). Words: starvin, gardenin, marvin, cardigan, bargaining, harden, arguing, gardening.
9. `slant:IH:nas-stop` — 10 pairs (END 0, INNER 10). Words: bring, sing, hit, thing, shit, lick, quick, trigger.
10. `vow:AO` — 10 pairs (END 0, INNER 10). Words: saw, thought, all, walked, warm, forty, transform, wrong.
11. `slant:IH:stop` — 9 pairs (END 1, INNER 8). Words: hit, trigger, stick, lick, quick, slick, nigga, shit.
12. `slant:IH:sib-stop` — 8 pairs (END 0, INNER 8). Words: bitch, mix, lick, quick, trigger, hit, slick, niggas.
13. `slant:EH:nas-stop` — 7 pairs (END 2, INNER 5). Words: when, spreading, dead, again, ahead, neck, said, better.
14. `slant:EH:stop` — 7 pairs (END 0, INNER 7). Words: 'net, respect, said, better, twenty, went, check, neck.
15. `slant:IH:liq-nas` — 7 pairs (END 0, INNER 7). Words: still, sing, drill, i'ma, bring, thing, clear, killin.
16. `cmu:IH-N` — 6 pairs (END 2, INNER 4). Words: mobbin, youngin, marvin, pullin, robbin.
17. `slant:IH:liq-stop` — 6 pairs (END 0, INNER 6). Words: shit, drill, stick, still, slick, clear, kill.
18. `cmu:AY` — 5 pairs (END 0, INNER 5). Words: try, by, glorify, purify.
19. `slant:EY:nas-sib` — 5 pairs (END 0, INNER 5). Words: came, names, james, flame, place.
20. `vow:AE` — 5 pairs (END 0, INNER 5). Words: can't, back, trap, family, thang, facts, had.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- mobbin — 4 pair sides, mostly spelling via spelling phonetic key, often with marvin (1)
- niggas — 4 pair sides, mostly cmu via vault phonetic_class, often with got (2)
- tryna — 4 pair sides, mostly spelling via spelling phonetic key, often with these (2)
- fam — 3 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- youngin — 3 pair sides, mostly spelling via spelling phonetic key, often with mobbin (1)
- nigga — 2 pair sides, mostly spelling via spelling phonetic key, often with stick (1)
- ima — 2 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- yute — 2 pair sides, mostly spelling via spelling phonetic key, often with real (1)
- skengs — 2 pair sides, mostly vowel via spelling phonetic key, often with when (1)
- freebase — 1 pair sides, mostly vowel via spelling phonetic key, often with these (1)
- glizzy — 1 pair sides, mostly vowel via spelling phonetic key, often with forty (1)
- remix — 1 pair sides, mostly spelling via spelling phonetic key, often with skengs (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| The Plug | Father Figure | 40 | 63 | 342 | loose |
