# Lil Durk rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Lil Durk
- Songs: 14
- Bars kept (Lil Durk lyric lines): 766
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Lil Durk.
- Credit strings: Lil Durk.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 4746
- REPEAT pairs, recorded separately: 648
- END rhymes: 734
- INNER rhymes: 4012

By match:

- PERFECT: 438 (END 102, INNER 336)
- SLANT: 2136 (END 339, INNER 1797)
- ASSONANCE: 2146 (END 285, INNER 1861)
- MULTI: 26 (END 8, INNER 18)

By confidence:

- HIGH: 397
- MED: 3929
- LOW: 420

## Core

- Core Y: 4654
- Core N among rhyme pairs: 92

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 2175 (45.8%)
- vowel: 2146 (45.2%)
- spelling: 399 (8.4%)
- multi: 26 (0.5%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 14 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EY` — 345 pairs (END 66, INNER 279). Words: ain't, way, say, day, play, make, take, baby.
2. `vow:OW` — 301 pairs (END 21, INNER 280). Words: don't, no, know, go, told, hoes, won't, old.
3. `vow:IH` — 295 pairs (END 48, INNER 247). Words: shit, bitches, lil, bitch, bricks, him, nigga, niggas.
4. `vow:AE` — 210 pairs (END 13, INNER 197). Words: can't, back, gang, ask, had, ass, niggas, man.
5. `vow:AH` — 201 pairs (END 28, INNER 173). Words: hundred, fuck, couple, trust, money, guns, some, double.
6. `vow:AA` — 181 pairs (END 20, INNER 161). Words: got, nothin, want, shots, top, wasn't, block, opp.
7. `vow:EH` — 179 pairs (END 25, INNER 154). Words: get, never, tellin, tell, drenched, went, every, rest.
8. `slant:AA:stop` — 153 pairs (END 2, INNER 151). Words: got, gotta, want, glock, top, block, opp, body.
9. `vow:IY` — 151 pairs (END 11, INNER 140). Words: keep, secret, free, even, need, eatin, these, feelin.
10. `vow:AY` — 126 pairs (END 9, INNER 117). Words: like, die, ridin, time, ninety, pipes, died, why.
11. `slant:IH:stop` — 113 pairs (END 15, INNER 98). Words: nigga, shit, city, hit, stick, brick, gripped, sip.
12. `slant:IH:sib-stop` — 91 pairs (END 22, INNER 69). Words: niggas, nigga, bitch, shit, stick, switch, rich, grip.
13. `slant:AY:stop` — 84 pairs (END 20, INNER 64). Words: like, might, right, type, night, ride, friday, pipe.
14. `slant:AE:nas-stop` — 75 pairs (END 12, INNER 63). Words: man, can, can't, back, gang, brag, had, gwap.
15. `cmu:OW` — 74 pairs (END 1, INNER 73). Words: no, know, go, ho, bro, glo, fargo, dough.
16. `slant:AH:nas-stop` — 69 pairs (END 12, INNER 57). Words: fuck, some, what, money, one, summer, done, truck.
17. `slant:AE:stop` — 68 pairs (END 5, INNER 63). Words: back, act, ask, can't, 'raq, daddy, had, trap.
18. `slant:EH:stop` — 67 pairs (END 4, INNER 63). Words: get, better, let, dead, red, wetter, respect, said.
19. `slant:IH:liq-stop` — 53 pairs (END 3, INNER 50). Words: shit, lil, really, killed, killer, will, still, 'til.
20. `vow:AW` — 52 pairs (END 20, INNER 32). Words: now, 'bout, thousand, about, down, power, how, ours.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 124 pair sides, mostly spelling via spelling phonetic key, often with niggas (38)
- niggas — 83 pair sides, mostly spelling via spelling phonetic key, often with nigga (38)
- gon — 32 pair sides, mostly spelling via spelling phonetic key, often with dont (4)
- raq — 23 pair sides, mostly spelling via spelling phonetic key, often with track (2)
- ima — 19 pair sides, mostly spelling via spelling phonetic key, often with shit (4)
- chiraq — 15 pair sides, mostly vowel via spelling phonetic key, often with nigga (5)
- tryna — 14 pair sides, mostly spelling via spelling phonetic key, often with even (2)
- opps — 11 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- boonie — 11 pair sides, mostly spelling via spelling phonetic key, often with goofy (2)
- durk — 10 pair sides, mostly spelling via spelling phonetic key, often with track (3)
- blam — 10 pair sides, mostly spelling via spelling phonetic key, often with lamb (3)
- imma — 9 pair sides, mostly vowel via spelling phonetic key, often with nigga (5)
- gwap — 8 pair sides, mostly spelling via spelling phonetic key, often with man (4)
- shawty — 7 pair sides, mostly spelling via spelling phonetic key, often with gone (3)
- tyga — 7 pair sides, mostly spelling via spelling phonetic key, often with wheelie (2)
- ralo — 7 pair sides, mostly vowel via spelling phonetic key, often with man (3)
- bling — 7 pair sides, mostly spelling via spelling phonetic key, often with lil (2)
- dawg — 6 pair sides, mostly spelling via spelling phonetic key, often with yall (4)
- killa — 6 pair sides, mostly vowel via spelling phonetic key, often with nigga (3)
- fadaway — 6 pair sides, mostly spelling via spelling phonetic key, often with day (2)
- homie — 5 pair sides, mostly vowel via vault phonetic_class, often with patch (1)
- teyana — 5 pair sides, mostly spelling via spelling phonetic key, often with take (2)
- wheelie — 5 pair sides, mostly spelling via spelling phonetic key, often with tyga (2)
- thot — 5 pair sides, mostly spelling via spelling phonetic key, often with got (2)
- gelatto — 5 pair sides, mostly vowel via spelling phonetic key, often with auto (1)
- dyin — 5 pair sides, mostly spelling via spelling phonetic key, often with keep (1)
- smoothie — 5 pair sides, mostly spelling via spelling phonetic key, often with zooties (1)
- jiggers — 5 pair sides, mostly vowel via vault phonetic_class, often with niggas (2)
- milds — 5 pair sides, mostly vowel via spelling phonetic key, often with king (1)
- fistfight — 4 pair sides, mostly vowel via spelling phonetic key, often with snitching (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Lil Durk | Benihana | 40 | 32 | 179 | loose |
| Lil Durk | Chiraq (Remix) | 163 | 186 | 795 | loose |
| Lil Durk | Chiraq Demons | 43 | 43 | 381 | loose |
| Lil Durk | Decline | 53 | 41 | 192 | loose |
| Lil Durk | Die Slow | 38 | 29 | 245 | loose |
| Lil Durk | Feel Good | 50 | 61 | 194 | loose |
| Lil Durk | Gang Gang | 45 | 40 | 177 | loose |
| Lil Durk | Grandson | 44 | 39 | 303 | loose |
| Lil Durk | Mood I’m In | 35 | 35 | 170 | loose |
| Lil Durk | Rich Forever | 42 | 17 | 196 | loose |
| Lil Durk | Shooter2x | 46 | 30 | 113 | loose |
| Lil Durk | Trenches Flexin | 67 | 53 | 569 | loose |
| Lil Durk | War Bout It | 42 | 60 | 303 | loose |
| Lil Durk | Watch Out | 58 | 68 | 195 | loose |
