# Skrilla rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Skrilla
- Songs: 2
- Bars kept (Skrilla lyric lines): 115
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 1
- Canonical name: Skrilla.
- Credit strings: Skrilla.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 934
- REPEAT pairs, recorded separately: 90
- END rhymes: 163
- INNER rhymes: 771

By match:

- PERFECT: 146 (END 62, INNER 84)
- SLANT: 372 (END 51, INNER 321)
- ASSONANCE: 403 (END 47, INNER 356)
- MULTI: 13 (END 3, INNER 10)

By confidence:

- HIGH: 153
- MED: 725
- LOW: 56

## Core

- Core Y: 913
- Core N among rhyme pairs: 21

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 473 (50.6%)
- vowel: 403 (43.1%)
- spelling: 45 (4.8%)
- multi: 13 (1.4%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 2 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 87 pairs (END 30, INNER 57). Words: ain't, face, play, pay, k, safe, hatin, blazin.
2. `cmu:EY` — 53 pairs (END 28, INNER 25). Words: day, play, way, holiday, stay, say, spray, k.
3. `vow:AE` — 53 pairs (END 7, INNER 46). Words: can't, catch, have, savage, fast, had, gas, havin.
4. `vow:AA` — 51 pairs (END 0, INNER 51). Words: start, poppin, got, arps, everybody's, drop, dogs, tom.
5. `vow:IH` — 42 pairs (END 0, INNER 42). Words: spinnin, ticket, hit, bitch, killin, shit, think, killers.
6. `vow:EH` — 40 pairs (END 0, INNER 40). Words: left, when, get, send, seconds, already, gettin, devin.
7. `slant:AA:stop` — 37 pairs (END 0, INNER 37). Words: got, block, drop, start, gotta, opp, spot, hot.
8. `vow:OW` — 34 pairs (END 1, INNER 33). Words: don't, know, go, opps, bro, no, micro, brodie.
9. `slant:AY:stop` — 31 pairs (END 13, INNER 18). Words: like, spiked, sight, ike, light, bright, kite, strike.
10. `vow:AY` — 29 pairs (END 4, INNER 25). Words: ridin, like, nikes, right, i'll, sight, michael, miles.
11. `vow:IY` — 27 pairs (END 4, INNER 23). Words: racky, even, nobody, fee, ski, he'll, tee, clean.
12. `slant:EY:sib-stop` — 20 pairs (END 9, INNER 11). Words: state, always, face, brake, chase, mercedes, ain't, range.
13. `cmu:AY-T` — 19 pairs (END 19, INNER 0). Words: sight, light, fight, tonight, right, height, kite, bright.
14. `vow:AH` — 18 pairs (END 0, INNER 18). Words: hundred, one, bust, custom, some, what, done, puttin.
15. `slant:AE:stop` — 17 pairs (END 3, INNER 14). Words: back, matte, splat, can't, yack, scat, wrapped, racked.
16. `slant:IH:stop` — 16 pairs (END 0, INNER 16). Words: nigga, hit, shit, ticket, blick, brick, clicked, drip.
17. `slant:AE:nas-stop` — 15 pairs (END 0, INNER 15). Words: had, makin, ran, can't, can, taliban, mann, fan.
18. `cmu:OW` — 14 pairs (END 0, INNER 14). Words: know, go, bro, low, lo, micro, no.
19. `slant:EY:stop` — 14 pairs (END 3, INNER 11). Words: raised, made, mcgrady, shady, eight, brady, ain't, late.
20. `slant:IH:sib-stop` — 14 pairs (END 0, INNER 14). Words: hit, rich, bitch, drip, chris, clips, shit, blitz.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- gon — 9 pair sides, mostly spelling via spelling phonetic key, often with whole (2)
- nigga — 9 pair sides, mostly spelling via spelling phonetic key, often with ticket (4)
- racky — 8 pair sides, mostly vowel via spelling phonetic key, often with early (1)
- swervo — 5 pair sides, mostly spelling via spelling phonetic key, often with swerve (2)
- xans — 5 pair sides, mostly spelling via spelling phonetic key, often with fan (1)
- custys — 4 pair sides, mostly cmu via vault phonetic_class, often with doo (3)
- opps — 4 pair sides, mostly vowel via spelling phonetic key, often with dont (2)
- ima — 4 pair sides, mostly spelling via spelling phonetic key, often with switch (1)
- dracs — 3 pair sides, mostly vowel via spelling phonetic key, often with cant (1)
- bippin — 2 pair sides, mostly vowel via spelling phonetic key, often with think (1)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with seen (1)
- warzon — 2 pair sides, mostly spelling via spelling phonetic key, often with gon (2)
- dyin — 1 pair sides, mostly spelling via spelling phonetic key, often with need (1)
- nyoom — 1 pair sides, mostly spelling via spelling phonetic key, often with ds (1)
- homi — 1 pair sides, mostly spelling via spelling phonetic key, often with whole (1)
- shanked — 1 pair sides, mostly vowel via spelling phonetic key, often with crackpipe (1)
- crackpipe — 1 pair sides, mostly vowel via spelling phonetic key, often with shanked (1)
- skrilla — 1 pair sides, mostly spelling via spelling phonetic key, often with really (1)
- sade — 1 pair sides, mostly spelling via spelling phonetic key, often with crash (1)
- ndale — 1 pair sides, mostly vowel via spelling phonetic key, often with backdoored (1)
- backdoored — 1 pair sides, mostly vowel via spelling phonetic key, often with ndale (1)
- mainski — 1 pair sides, mostly vowel via spelling phonetic key, often with hatin (1)
- congratulates — 1 pair sides, mostly vowel via spelling phonetic key, often with broke (1)
- ie — 1 pair sides, mostly spelling via spelling only, often with brodie (1)
- rackies — 1 pair sides, mostly spelling via spelling phonetic key, often with racky (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Skrilla | Doot Doot (6 7) [Remix] | 67 | 96 | 387 | loose |
| Skrilla | Swerve | 48 | 67 | 384 | loose |
