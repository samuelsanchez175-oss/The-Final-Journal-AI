# Lil Reese rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Reese
- Songs: 8
- Bars kept (Lil Reese lyric lines): 303
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lil Reese.
- Credit strings: Lil Reese.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1697
- REPEAT pairs, recorded separately: 389
- END rhymes: 414
- INNER rhymes: 1283

By match:

- PERFECT: 125 (END 30, INNER 95)
- SLANT: 734 (END 147, INNER 587)
- ASSONANCE: 829 (END 235, INNER 594)
- MULTI: 9 (END 2, INNER 7)

By confidence:

- HIGH: 117
- MED: 1460
- LOW: 120

## Core

- Core Y: 1655
- Core N among rhyme pairs: 42

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 761 (44.8%)
- vowel: 829 (48.9%)
- spelling: 98 (5.8%)
- multi: 9 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 8 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 167 pairs (END 81, INNER 86). Words: traffic, savage, action, catch, have, can't, lappin, mavericks.
2. `vow:IH` — 126 pairs (END 35, INNER 91). Words: bitch, bitches, since, wrist, business, shits, shit, pistols.
3. `vow:OW` — 117 pairs (END 21, INNER 96). Words: don't, know, no, sosa, go, both, glo, gold.
4. `vow:EY` — 104 pairs (END 25, INNER 79). Words: say, ain't, play, crazy, baby, take, impatient, made.
5. `slant:IH:sib-stop` — 80 pairs (END 38, INNER 42). Words: shit, bitch, nigga, niggas, shits, snitch, grip, hit.
6. `vow:IY` — 70 pairs (END 25, INNER 45). Words: brazy, crazy, see, sea, shotties, need, g, v.
7. `vow:AY` — 63 pairs (END 17, INNER 46). Words: like, fire, why, by, try, diamonds, high, riding.
8. `vow:AA` — 53 pairs (END 0, INNER 53). Words: got, start, pockets, hard, wanna, chronic, robin's, popping.
9. `vow:EH` — 40 pairs (END 3, INNER 37). Words: get, where, dead, hectic, reckless, spelled, remember, when.
10. `vow:AW` — 34 pairs (END 10, INNER 24). Words: now, down, thousand, around, town, pound, clowns, about.
11. `slant:IH:stop` — 33 pairs (END 3, INNER 30). Words: shit, nigga, dick, whip, clip, thick, wrist, kicked.
12. `slant:AA:stop` — 31 pairs (END 0, INNER 31). Words: got, not, gotta, block, knock, start, forgot, squad.
13. `slant:IH:liq-sib` — 29 pairs (END 0, INNER 29). Words: bitch, really, lil, gear, will, fisher, still, kill.
14. `vow:AH` — 28 pairs (END 4, INNER 24). Words: fuckin, nothing, fuck, hunnids, what, what's, thunder, trump.
15. `slant:AY:stop` — 27 pairs (END 10, INNER 17). Words: like, white, night, light, midnight, tired, rider, hike.
16. `slant:IH:liq-stop` — 23 pairs (END 0, INNER 23). Words: shit, kill, lil, 'til, really, big, pretty, gear.
17. `slant:IH:sib` — 22 pairs (END 4, INNER 18). Words: bitches, bitch, niggas, cities, business, witness, busy, snitches.
18. `slant:EY:sib-stop` — 20 pairs (END 2, INNER 18). Words: face, baby, crazy, take, phase, made, plays, hate.
19. `vow:UW` — 20 pairs (END 14, INNER 6). Words: shooters, choose, lose, who, blue, tools, barbecue, two.
20. `slant:AH:nas-stop` — 19 pairs (END 2, INNER 17). Words: fuck, some, what, come, money, cut, blood, run.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 27 pair sides, mostly spelling via spelling phonetic key, often with niggas (12)
- brazy — 26 pair sides, mostly vowel via spelling phonetic key, often with crazy (17)
- niggas — 24 pair sides, mostly spelling via spelling phonetic key, often with nigga (12)
- gon — 11 pair sides, mostly spelling via spelling phonetic key, often with dont (5)
- ima — 9 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- spazzing — 6 pair sides, mostly spelling via spelling phonetic key, often with timing (1)
- killas — 6 pair sides, mostly spelling via spelling phonetic key, often with niggas (4)
- shotties — 6 pair sides, mostly vowel via vault phonetic_class, often with hear (3)
- youngin — 5 pair sides, mostly vowel via vault phonetic_class, often with mission (2)
- opps — 4 pair sides, mostly vowel via spelling phonetic key, often with dont (2)
- hunnids — 4 pair sides, mostly vowel via spelling phonetic key, often with fuckin (3)
- swole — 4 pair sides, mostly spelling via spelling phonetic key, often with fold (1)
- finna — 3 pair sides, mostly spelling via spelling phonetic key, often with since (2)
- reesy — 3 pair sides, mostly spelling via spelling phonetic key, often with see (1)
- shawty — 3 pair sides, mostly vowel via spelling phonetic key, often with money (1)
- snitches — 3 pair sides, mostly spelling via spelling phonetic key, often with business (1)
- whatcha — 2 pair sides, mostly vowel via spelling phonetic key, often with cant (1)
- flocka — 2 pair sides, mostly spelling via spelling phonetic key, often with rollie (1)
- eway — 2 pair sides, mostly spelling via spelling phonetic key, often with say (2)
- guap — 2 pair sides, mostly spelling via spelling phonetic key, often with fuck (1)
- thotties — 2 pair sides, mostly spelling via spelling phonetic key, often with parties (1)
- cdai — 2 pair sides, mostly vowel via spelling phonetic key, often with day (1)
- stuntin — 2 pair sides, mostly spelling via spelling phonetic key, often with fuckin (1)
- fufu — 1 pair sides, mostly spelling via spelling phonetic key, often with what (1)
- amiris — 1 pair sides, mostly spelling via spelling phonetic key, often with willis (1)
- tryna — 1 pair sides, mostly spelling via spelling phonetic key, often with seen (1)
- waka — 1 pair sides, mostly vowel via spelling phonetic key, often with hand (1)
- getback — 1 pair sides, mostly spelling via spelling phonetic key, often with back (1)
- getbackgang — 1 pair sides, mostly spelling via spelling phonetic key, often with gang (1)
- shottie — 1 pair sides, mostly spelling via spelling phonetic key, often with thotties (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Reese | BBQ | 39 | 47 | 134 | loose |
| Lil Reese | Brazy | 35 | 56 | 161 | loose |
| Lil Reese | Grindin’ | 46 | 64 | 160 | loose |
| Lil Reese | Mooliani | 50 | 43 | 242 | loose |
| Lil Reese | Rap Shit | 29 | 13 | 92 | loose |
| Lil Reese | Traffic | 34 | 92 | 195 | loose |
| Lil Reese | We Won’t Stop | 34 | 37 | 153 | loose |
| Lil Reese | What It Look Like | 36 | 62 | 146 | loose |
