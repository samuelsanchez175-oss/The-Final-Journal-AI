# JNR CHOI rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: JNR CHOI
- Songs: 1
- Bars kept (JNR CHOI lyric lines): 77
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: JNR CHOI.
- Credit strings: JNR CHOI.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 326
- REPEAT pairs, recorded separately: 73
- END rhymes: 50
- INNER rhymes: 276

By match:

- PERFECT: 22 (END 7, INNER 15)
- SLANT: 143 (END 19, INNER 124)
- ASSONANCE: 151 (END 20, INNER 131)
- MULTI: 10 (END 4, INNER 6)

By confidence:

- HIGH: 29
- MED: 281
- LOW: 16

## Core

- Core Y: 322
- Core N among rhyme pairs: 4

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 149 (45.7%)
- vowel: 151 (46.3%)
- spelling: 16 (4.9%)
- multi: 10 (3.1%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:EH` — 30 pairs (END 7, INNER 23). Words: friends, when, jealousy, airing, m, tellin, enemies, energy.
2. `vow:AE` — 25 pairs (END 8, INNER 17). Words: stand, hands, back, can't, gang, cash, racks, smack.
3. `slant:AA:stop` — 18 pairs (END 2, INNER 16). Words: got, pocket, profit, spot, want, drop, cop, gotta.
4. `vow:IH` — 18 pairs (END 0, INNER 18). Words: everything's, given, city, him, wishin, gift, pity, litty.
5. `vow:OW` — 18 pairs (END 0, INNER 18). Words: don't, know, no, smoke, only, toting, whole, swervo.
6. `vow:AY` — 15 pairs (END 0, INNER 15). Words: like, why, try, mind, might, live, upside.
7. `vow:IY` — 15 pairs (END 0, INNER 15). Words: ski, beats, keep, teach, tea, demon, nobody, easy.
8. `slant:AE:sib-stop` — 12 pairs (END 6, INNER 6). Words: back, crash, plaques, cash, smack, stand, hands, flat.
9. `vow:AA` — 12 pairs (END 2, INNER 10). Words: shoppin, profit, hah, not, party, got, want, innies.
10. `slant:AE:stop` — 10 pairs (END 2, INNER 8). Words: flat, back, bad, track, had, smack, black, 'raq.
11. `multi:IH-T-IY` — 8 pairs (END 4, INNER 4). Words: city, pity, litty, whole city, need pity, not litty.
12. `slant:AE:nas-stop` — 8 pairs (END 0, INNER 8). Words: gang, back, track, smack, flat, bad, can't, man.
13. `cmu:AE-K` — 7 pairs (END 4, INNER 3). Words: back, track, mac, smack, black, 'raq.
14. `vow:UW` — 7 pairs (END 0, INNER 7). Words: google, hooligans, lose, two, move, moon, tune, shoot.
15. `slant:IH:liq-stop` — 6 pairs (END 1, INNER 5). Words: really, lit, litty, spill, fill, big, chill, liquor.
16. `slant:IH:stop` — 5 pairs (END 0, INNER 5). Words: gift, city, pity, drink, liquor.
17. `vow:ER` — 5 pairs (END 3, INNER 2). Words: curtains, girl, burners, burger, werner.
18. `slant:AA:nas-stop` — 4 pairs (END 0, INNER 4). Words: gonna, shoppin, got, lock, cop, drop.
19. `slant:EY:nas-stop` — 4 pairs (END 0, INNER 4). Words: playin, name, take, celebrate, came, cake, make.
20. `slant:IH:nas-stop` — 4 pairs (END 0, INNER 4). Words: city, him, ting.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- raq — 4 pair sides, mostly spelling via spelling phonetic key, often with track (1)
- gats — 4 pair sides, mostly vowel via spelling phonetic key, often with back (1)
- fivi — 4 pair sides, mostly spelling via spelling phonetic key, often with him (3)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with keep (1)
- innies — 2 pair sides, mostly spelling via vault phonetic_class, often with bitties (1)
- bitties — 1 pair sides, mostly spelling via spelling phonetic key, often with innies (1)
- gon — 1 pair sides, mostly spelling via spelling phonetic key, often with whole (1)
- swervo — 1 pair sides, mostly vowel via spelling phonetic key, often with no (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| JNR CHOI | TO THE MOON (Drill Remix) | 77 | 50 | 276 | loose |
