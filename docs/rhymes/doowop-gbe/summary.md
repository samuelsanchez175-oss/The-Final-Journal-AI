# DooWop (GBE) rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DooWop (GBE)
- Songs: 6
- Bars kept (DooWop (GBE) lyric lines): 317
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: DooWop (GBE).
- Credit strings: DooWop (GBE).
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 2371
- REPEAT pairs, recorded separately: 219
- END rhymes: 424
- INNER rhymes: 1947

By match:

- PERFECT: 179 (END 41, INNER 138)
- SLANT: 1071 (END 181, INNER 890)
- ASSONANCE: 1074 (END 190, INNER 884)
- MULTI: 47 (END 12, INNER 35)

By confidence:

- HIGH: 211
- MED: 1938
- LOW: 222

## Core

- Core Y: 2276
- Core N among rhyme pairs: 95

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 1112 (46.9%)
- vowel: 1074 (45.3%)
- spelling: 138 (5.8%)
- multi: 47 (2.0%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 6 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 211 pairs (END 41, INNER 170). Words: no, don't, though, know, folks, hoes, smoke, bowls.
2. `vow:IH` — 190 pairs (END 15, INNER 175). Words: bitch, bitches, pistol, wrist, chimney, hit, big, six.
3. `vow:IY` — 117 pairs (END 28, INNER 89). Words: free, chief, see, reason, streets, reekin, leave, wheely.
4. `vow:AE` — 115 pairs (END 33, INNER 82). Words: mathematics, spasms, traffic, average, savage, back, bag, can't.
5. `vow:EH` — 87 pairs (END 3, INNER 84). Words: telling, self, where, cigarettes, sendin, gettin, steady, barely.
6. `vow:AY` — 80 pairs (END 11, INNER 69). Words: like, triflin, licensed, high, ridin, guy, fightin, pint.
7. `vow:AA` — 67 pairs (END 6, INNER 61). Words: got, talkin, shots, la, wasn't, want, rocks, poppin.
8. `slant:IH:sib-stop` — 65 pairs (END 6, INNER 59). Words: bitch, big, nigga, niggas, lick, shit, busy, thick.
9. `slant:AE:stop` — 64 pairs (END 13, INNER 51). Words: capper, cap, back, 'matic, matter, fratter, bag, bladder.
10. `vow:EY` — 63 pairs (END 12, INNER 51). Words: play, ain't, say, games, spray, make, way, hatin.
11. `vow:UW` — 61 pairs (END 33, INNER 28). Words: new, through, mooster, who, lose, junior, luther, shootin.
12. `vow:AH` — 55 pairs (END 8, INNER 47). Words: hundred, fuckin, fuck, cousin, much, guns, bugs, one.
13. `slant:AA:stop` — 54 pairs (END 5, INNER 49). Words: got, drop, cock, tock, popped, stop, gotta, body.
14. `slant:IH:liq-stop` — 49 pairs (END 2, INNER 47). Words: hit, willy, big, still, shit, really, filled, lil.
15. `slant:IH:stop` — 42 pairs (END 1, INNER 41). Words: nigga, big, hit, shit, city, dick, picked, fifty.
16. `slant:AY:stop` — 39 pairs (END 2, INNER 37). Words: like, light, right, flight, ride, might, snipe, sniper.
17. `cmu:OW` — 35 pairs (END 4, INNER 31). Words: though, no, know, o, throw, go, puerto, hoe.
18. `slant:IH:sib` — 35 pairs (END 4, INNER 31). Words: bitch, busy, six, blickys, itchy, bitches, niggas, miss.
19. `slant:AH:nas-stop` — 34 pairs (END 0, INNER 34). Words: fuck, what, money, one, run, some, done, gun.
20. `slant:AE:nas-stop` — 29 pairs (END 0, INNER 29). Words: can, gang, cap, back, cappin, man, mac, can't.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 34 pair sides, mostly spelling via spelling phonetic key, often with niggas (11)
- niggas — 16 pair sides, mostly spelling via spelling phonetic key, often with nigga (11)
- pido — 10 pair sides, mostly spelling via spelling phonetic key, often with though (2)
- ceelo — 10 pair sides, mostly vowel via spelling phonetic key, often with though (2)
- ima — 10 pair sides, mostly spelling via spelling phonetic key, often with stick (1)
- fratter — 9 pair sides, mostly spelling via spelling phonetic key, often with capper (2)
- wheely — 9 pair sides, mostly vowel via spelling phonetic key, often with willy (2)
- lilo — 7 pair sides, mostly spelling via spelling phonetic key, often with nemo (1)
- krio — 7 pair sides, mostly vowel via spelling phonetic key, often with though (2)
- illmatic — 6 pair sides, mostly vowel via spelling phonetic key, often with still (3)
- zeko — 6 pair sides, mostly vowel via spelling phonetic key, often with though (2)
- exquizzy — 6 pair sides, mostly vowel via spelling phonetic key, often with busy (2)
- exstizzy — 6 pair sides, mostly vowel via spelling phonetic key, often with pretty (1)
- blickys — 6 pair sides, mostly spelling via spelling phonetic key, often with six (6)
- gon — 5 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- mooster — 5 pair sides, mostly vowel via spelling phonetic key, often with ruger (4)
- pissy — 5 pair sides, mostly vowel via spelling phonetic key, often with bitch (1)
- hoola — 5 pair sides, mostly spelling via spelling phonetic key, often with mula (1)
- wifin — 4 pair sides, mostly vowel via spelling phonetic key, often with bitch (2)
- lightskin — 4 pair sides, mostly vowel via spelling phonetic key, often with wifin (1)
- opps — 4 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- doa — 4 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- birkin — 4 pair sides, mostly vowel via spelling phonetic key, often with bitch (3)
- gen5 — 4 pair sides, mostly spelling via spelling phonetic key, often with ten (1)
- tryna — 4 pair sides, mostly spelling via spelling phonetic key, often with chief (1)
- bidness — 4 pair sides, mostly cmu via vault phonetic_class, often with rat (1)
- monos — 3 pair sides, mostly vowel via spelling phonetic key, often with most (1)
- spazzin — 3 pair sides, mostly vowel via spelling phonetic key, often with mathematics (1)
- glizzy — 3 pair sides, mostly vowel via spelling phonetic key, often with city (1)
- raq — 3 pair sides, mostly spelling via spelling phonetic key, often with have (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DooWop (GBE) | 19 | 55 | 78 | 455 | loose |
| DooWop (GBE) | 2026 | 48 | 55 | 357 | loose |
| DooWop (GBE) | 6 Blickys | 93 | 128 | 602 | loose |
| DooWop (GBE) | Cap Flow | 47 | 93 | 234 | loose |
| DooWop (GBE) | My Woes | 38 | 33 | 112 | loose |
| DooWop (GBE) | Send Em Back | 36 | 37 | 187 | loose |
