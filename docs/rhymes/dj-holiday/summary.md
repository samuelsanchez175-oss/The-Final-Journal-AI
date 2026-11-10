# DJ Holiday rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: DJ Holiday
- Songs: 3
- Bars kept (DJ Holiday lyric lines): 151
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: DJ Holiday.
- Credit strings: DJ Holiday.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 705
- REPEAT pairs, recorded separately: 112
- END rhymes: 178
- INNER rhymes: 527

By match:

- PERFECT: 49 (END 16, INNER 33)
- SLANT: 308 (END 83, INNER 225)
- ASSONANCE: 339 (END 73, INNER 266)
- MULTI: 9 (END 6, INNER 3)

By confidence:

- HIGH: 58
- MED: 608
- LOW: 39

## Core

- Core Y: 696
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 327 (46.4%)
- vowel: 339 (48.1%)
- spelling: 30 (4.3%)
- multi: 9 (1.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 3 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:IH` — 55 pairs (END 11, INNER 44). Words: bitches, different, minute, riches, bitch, hits, fifty, really.
2. `vow:AE` — 46 pairs (END 14, INNER 32). Words: trap, phantom, assassins, fashion, hand, rambo, channel, plastic.
3. `vow:EY` — 35 pairs (END 4, INNER 31). Words: say, made, ain't, pay, make, scrapin, ain’t, amazin.
4. `vow:OW` — 32 pairs (END 2, INNER 30). Words: don't, no, know, ho, gold, bowl, go, don’t.
5. `vow:AY` — 31 pairs (END 5, INNER 26). Words: idol, like, trying, fire, require, fly, desire, mcgwire.
6. `vow:AA` — 27 pairs (END 1, INNER 26). Words: got, arms, coppin, lot, mark, robbers, august, started.
7. `vow:AW` — 26 pairs (END 14, INNER 12). Words: couch, house, now, ounce, pound, how, counts, amounts.
8. `vow:IY` — 24 pairs (END 9, INNER 15). Words: adidas, v, even, liter, see, these, speeding, peta.
9. `slant:AE:stop` — 21 pairs (END 4, INNER 17). Words: trap, papi, crack, bad, mad, bando, hand, jacket.
10. `vow:EH` — 20 pairs (END 5, INNER 15). Words: phelps, every, stretching, plenty, trenches, selling, empire, intentions.
11. `slant:IY:stop` — 18 pairs (END 16, INNER 2). Words: beeper, seater, peta, cheater, keep, beat, liter, bieber.
12. `slant:IH:stop` — 17 pairs (END 4, INNER 13). Words: minute, nigga, city, pick, different, shit.
13. `vow:AH` — 17 pairs (END 2, INNER 15). Words: months, drugs, love, come, punch, what, fucked, thumbs.
14. `vow:UW` — 17 pairs (END 6, INNER 11). Words: new, clue, wu, rules, dues, outta, school, deuce.
15. `slant:AE:nas-stop` — 13 pairs (END 0, INNER 13). Words: can, trap, bando, papi, hand, abandon, tang, crack.
16. `slant:AW:sib` — 12 pairs (END 8, INNER 4). Words: house, ounce, couch, nouns, amounts, bounce, counts.
17. `slant:AA:stop` — 11 pairs (END 0, INNER 11). Words: got, knob, job, glock, og, want, everybody, gotta.
18. `slant:AW:nas-sib` — 10 pairs (END 10, INNER 0). Words: nouns, clown, bounce, town, brown, ounce, down, couch.
19. `slant:EH:liq-stop` — 10 pairs (END 2, INNER 8). Words: said, hell, get, tell, bell, offset, help, cartel.
20. `slant:AW:nas-stop` — 9 pairs (END 0, INNER 9). Words: pound, down, 'round, brown, town, clown.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- nigga — 10 pair sides, mostly spelling via spelling phonetic key, often with pick (4)
- bando — 10 pair sides, mostly spelling via spelling phonetic key, often with can (4)
- papi — 8 pair sides, mostly spelling via spelling phonetic key, often with mad (2)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with rollie (2)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with nigga (2)
- bitchs — 2 pair sides, mostly vowel via spelling phonetic key, often with killin (1)
- jeezy — 2 pair sides, mostly spelling via spelling phonetic key, often with believe (1)
- codeine — 1 pair sides, mostly spelling via spelling phonetic key, often with alone (1)
- benjis — 1 pair sides, mostly spelling via spelling phonetic key, often with friends (1)
- imma — 1 pair sides, mostly vowel via spelling phonetic key, often with nigga (1)
- jingalin — 1 pair sides, mostly vowel via spelling phonetic key, often with bitch (1)
- ratchets — 1 pair sides, mostly vowel via spelling phonetic key, often with active (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| DJ Holiday | 2 Seater | 55 | 83 | 134 | loose |
| DJ Holiday | In A Minute | 29 | 34 | 129 | loose |
| DJ Holiday | Trap House | 67 | 61 | 264 | loose |
