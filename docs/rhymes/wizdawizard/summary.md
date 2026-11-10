# WizDaWizard rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: WizDaWizard
- Songs: 1
- Bars kept (WizDaWizard lyric lines): 33
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: WizDaWizard.
- Credit strings: WizDaWizard.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 247
- REPEAT pairs, recorded separately: 22
- END rhymes: 39
- INNER rhymes: 208

By match:

- PERFECT: 29 (END 12, INNER 17)
- SLANT: 111 (END 23, INNER 88)
- ASSONANCE: 106 (END 4, INNER 102)
- MULTI: 1 (END 0, INNER 1)

By confidence:

- HIGH: 20
- MED: 203
- LOW: 24

## Core

- Core Y: 244
- Core N among rhyme pairs: 3

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 110 (44.5%)
- vowel: 106 (42.9%)
- spelling: 30 (12.1%)
- multi: 1 (0.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 26 pairs (END 1, INNER 25). Words: myself, bentley, bending, went, bend, del, skeletons, heavy.
2. `vow:OW` — 25 pairs (END 2, INNER 23). Words: no, only, know, close, won't, open, don't, tote.
3. `vow:EY` — 24 pairs (END 0, INNER 24). Words: stay, angels, praying, way, ain't, prayed, lowkey, scale.
4. `vow:IH` — 16 pairs (END 1, INNER 15). Words: bitches, hitting, itchin, missions, spinning, ms, kill, politicking.
5. `slant:EH:liq` — 13 pairs (END 12, INNER 1). Words: there, tell, nfl, bare, rare, shell, bury, sell.
6. `slant:EH:liq-stop` — 13 pairs (END 0, INNER 13). Words: get, there, let, bury, rare, shell, sell, bentley.
7. `cmu:IH-NG` — 7 pairs (END 0, INNER 7). Words: geeking, sliding, kutthroating, getting, nding, toting.
8. `slant:IH:stop` — 6 pairs (END 0, INNER 6). Words: nigga, shit, big.
9. `vow:AA` — 6 pairs (END 0, INNER 6). Words: chops, got, som, closet, knock, blocks, top, revolver.
10. `cmu:EY` — 5 pairs (END 0, INNER 5). Words: way, play, stay, say.
11. `slant:AA:stop` — 5 pairs (END 0, INNER 5). Words: got, chopper, closet, gotta, job, knock.
12. `slant:EH:fric-liq` — 5 pairs (END 3, INNER 2). Words: myself, never, bury, sell, del, tell, nfl.
13. `slant:IH:nas-sib` — 5 pairs (END 0, INNER 5). Words: bitch, spin, miss, i'ma, itchin.
14. `cmu:EH-R` — 4 pairs (END 4, INNER 0). Words: rare, there, bare.
15. `slant:ER:sib-stop` — 4 pairs (END 2, INNER 2). Words: worth, dirty, work, perc, thirties, jersey.
16. `slant:IH:sib-stop` — 4 pairs (END 0, INNER 4). Words: nigga, niggas, ms, shit.
17. `cmu:EH-L` — 3 pairs (END 3, INNER 0). Words: tell, nfl, del, shell.
18. `cmu:UW-Z` — 3 pairs (END 3, INNER 0). Words: news, blues, shoes.
19. `slant:AA:nas-stop` — 3 pairs (END 0, INNER 3). Words: mama, gotta, chopper, som, got.
20. `slant:AE:nas-stop` — 3 pairs (END 0, INNER 3). Words: can, mac, wam, can't, add.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 9 pair sides, mostly spelling via spelling phonetic key, often with shit (5)
- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with spin (1)
- geeking — 4 pair sides, mostly spelling via spelling phonetic key, often with toting (1)
- kutthroating — 4 pair sides, mostly spelling via spelling phonetic key, often with geeking (1)
- lowkey — 3 pair sides, mostly vowel via spelling phonetic key, often with stay (3)
- nding — 3 pair sides, mostly spelling via spelling phonetic key, often with kill (1)
- niggas — 3 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- syk — 2 pair sides, mostly spelling via spelling phonetic key, often with need (1)
- drac — 1 pair sides, mostly spelling via spelling phonetic key, often with had (1)
- wam — 1 pair sides, mostly spelling via spelling phonetic key, often with mac (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| WizDaWizard | No Attempt | 33 | 39 | 208 | loose |
