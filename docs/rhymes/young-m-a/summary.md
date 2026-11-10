# Young M.A rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Young M.A
- Songs: 1
- Bars kept (Young M.A lyric lines): 47
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Young M.A.
- Credit strings: Young M.A.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 442
- REPEAT pairs, recorded separately: 37
- END rhymes: 60
- INNER rhymes: 382

By match:

- PERFECT: 53 (END 20, INNER 33)
- SLANT: 132 (END 18, INNER 114)
- ASSONANCE: 253 (END 22, INNER 231)
- MULTI: 4 (END 0, INNER 4)

By confidence:

- HIGH: 52
- MED: 365
- LOW: 25

## Core

- Core Y: 431
- Core N among rhyme pairs: 11

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 166 (37.6%)
- vowel: 253 (57.2%)
- spelling: 19 (4.3%)
- multi: 4 (0.9%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 106 pairs (END 12, INNER 94). Words: no, most, know, pole, hoe, go, folks, owning.
2. `vow:EH` — 41 pairs (END 0, INNER 41). Words: checks, against, getting, ten, twelve, already, defense, spending.
3. `cmu:OW` — 28 pairs (END 7, INNER 21). Words: no, go, know, bro, slow, hoe, ceo.
4. `vow:AE` — 28 pairs (END 6, INNER 22). Words: lambs, bands, mansions, cash, man, plan, catch, romance.
5. `vow:IH` — 24 pairs (END 0, INNER 24). Words: bitch, business, listen, little, thing, tints, since, six.
6. `vow:IY` — 21 pairs (END 4, INNER 17). Words: even, degree, antisocially, hoing, need, deep, peep, keep.
7. `vow:EY` — 17 pairs (END 0, INNER 17). Words: ain't, pray, say, chase, mail, prevail, occasion, gave.
8. `slant:AH:nas-stop` — 8 pairs (END 0, INNER 8). Words: what, one, run, some, cut, fuck, come, money.
9. `slant:AE:nas-stop` — 7 pairs (END 3, INNER 4). Words: man, land, brand, plan, can't, can, caddy.
10. `slant:AE:sib-stop` — 7 pairs (END 1, INNER 6). Words: bands, brand, land, romance, back, ass.
11. `slant:AE:nas-sib` — 6 pairs (END 0, INNER 6). Words: man, catch, romance, cash, plan.
12. `slant:AE:sib` — 6 pairs (END 1, INNER 5). Words: bands, lambs, romance, mansions.
13. `slant:IH:liq-stop` — 6 pairs (END 0, INNER 6). Words: shit, lil, big, still, really, dick.
14. `vow:AY` — 6 pairs (END 0, INNER 6). Words: try, why, everytime, like, anytime, ice.
15. `slant:AA:stop` — 5 pairs (END 0, INNER 5). Words: glock, got, caught.
16. `slant:EH:fric-liq` — 5 pairs (END 2, INNER 3). Words: whenever, twelve, hell, l, shell.
17. `slant:IH:sib-stop` — 5 pairs (END 0, INNER 5). Words: bitch, shit, dick, big, ms.
18. `slant:OW:sib-stop` — 5 pairs (END 2, INNER 3). Words: bros, most, hoes, 'posed, hope, road.
19. `slant:OW:stop` — 5 pairs (END 0, INNER 5). Words: smoke, dope, tote, goat.
20. `vow:AH` — 5 pairs (END 0, INNER 5). Words: function, trucks, some, cut.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- bros — 7 pair sides, mostly spelling via spelling phonetic key, often with most (2)
- hoing — 5 pair sides, mostly vowel via vault phonetic_class, often with degree (1)
- antisocially — 5 pair sides, mostly vowel via spelling phonetic key, often with really (1)
- wifey — 3 pair sides, mostly spelling via spelling phonetic key, often with really (1)
- opps — 3 pair sides, mostly vowel via spelling phonetic key, often with know (3)
- ima — 3 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- denims — 2 pair sides, mostly vowel via spelling phonetic key, often with getting (1)
- thugging — 2 pair sides, mostly spelling via spelling phonetic key, often with getting (1)
- parol — 1 pair sides, mostly spelling via spelling phonetic key, often with pole (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with ass (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Young M.A | Pressure | 47 | 60 | 382 | loose |
