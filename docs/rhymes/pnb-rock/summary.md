# PnB Rock rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: PnB Rock
- Songs: 6
- Bars kept (PnB Rock lyric lines): 197
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: PnB Rock.
- Credit strings: PnB Rock.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 1199
- REPEAT pairs, recorded separately: 165
- END rhymes: 165
- INNER rhymes: 1034

By match:

- PERFECT: 96 (END 24, INNER 72)
- SLANT: 538 (END 66, INNER 472)
- ASSONANCE: 539 (END 71, INNER 468)
- MULTI: 26 (END 4, INNER 22)

By confidence:

- HIGH: 116
- MED: 1022
- LOW: 61

## Core

- Core Y: 1182
- Core N among rhyme pairs: 17

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 583 (48.6%)
- vowel: 539 (45.0%)
- spelling: 51 (4.3%)
- multi: 26 (2.2%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 6 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:OW` — 146 pairs (END 9, INNER 137). Words: don't, know, no, old, hoes, won't, emotions, only.
2. `vow:IH` — 77 pairs (END 10, INNER 67). Words: shit, thinkin, missed, switching, killin, hit, think, lips.
3. `vow:AE` — 63 pairs (END 13, INNER 50). Words: rappers, fast, magic, tragic, had, dash, crash, makin.
4. `vow:EY` — 59 pairs (END 6, INNER 53). Words: ain't, say, paid, play, take, they'll, percolated, sophisticated.
5. `slant:IH:stop` — 48 pairs (END 9, INNER 39). Words: hit, shit, nigga, pick, city, fit, drip, clip.
6. `vow:AY` — 47 pairs (END 2, INNER 45). Words: by, like, time, vibes, driving, eyes, behind, ride.
7. `vow:EH` — 45 pairs (END 10, INNER 35). Words: get, westin, friends, friend, help, message, tell, when.
8. `vow:IY` — 36 pairs (END 8, INNER 28). Words: shawty, see, even, fee, three, every, key, these.
9. `slant:EH:fric-liq` — 26 pairs (END 2, INNER 24). Words: there, every, never, tell, ever, forever.
10. `slant:EH:stop` — 26 pairs (END 0, INNER 26). Words: get, head, red, dead, wetter, wreck, bet, send.
11. `slant:EH:liq-stop` — 23 pairs (END 3, INNER 20). Words: there, head, square, tell, get, red, dead, teddy.
12. `vow:AA` — 23 pairs (END 2, INNER 21). Words: wanna, cost, got, bodies, bottoms, want, card, charles.
13. `slant:AA:stop` — 21 pairs (END 2, INNER 19). Words: got, lock, top, hop, want, heart, shot, gotta.
14. `slant:IH:sib-stop` — 20 pairs (END 5, INNER 15). Words: bitch, clips, hit, strip, miss, drip, stick, rip.
15. `multi:EH-V-ER` — 19 pairs (END 0, INNER 19). Words: never, ever, never ever, she'll never, i'll never, forever, forever ever, love forever.
16. `vow:AH` — 19 pairs (END 1, INNER 18). Words: jump, rush, what's, upped, some, runnin, fuckin, tug.
17. `slant:AE:nas-stop` — 16 pairs (END 0, INNER 16). Words: had, damn, bang, goddamn, lap, pack, ackin, sack.
18. `slant:IH:nas-stop` — 16 pairs (END 0, INNER 16). Words: thing, him, shit, spin, kick, city, fit, whip.
19. `cmu:OW` — 15 pairs (END 3, INNER 12). Words: no, know, go, show, kilo, hoe, throw.
20. `vow:AW` — 15 pairs (END 9, INNER 6). Words: now, down, sound, handouts, how, around, bout, 'bout.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- shawty — 20 pair sides, mostly vowel via spelling phonetic key, often with every (4)
- nigga — 9 pair sides, mostly spelling via spelling phonetic key, often with shit (3)
- gon — 4 pair sides, mostly spelling via spelling phonetic key, often with knows (1)
- rari — 4 pair sides, mostly spelling via spelling phonetic key, often with kodak (1)
- ackin — 3 pair sides, mostly spelling via spelling phonetic key, often with sack (1)
- opps — 3 pair sides, mostly vowel via spelling phonetic key, often with know (2)
- tryna — 3 pair sides, mostly spelling via spelling phonetic key, often with beam (1)
- vlone — 3 pair sides, mostly spelling via spelling phonetic key, often with dont (2)
- brukshot — 2 pair sides, mostly spelling via spelling phonetic key, often with shot (1)
- niggas — 2 pair sides, mostly spelling via spelling phonetic key, often with clips (2)
- choppa — 2 pair sides, mostly spelling via spelling phonetic key, often with smoke (1)
- touchback — 1 pair sides, mostly spelling via spelling phonetic key, often with pack (1)
- hella — 1 pair sides, mostly spelling via spelling phonetic key, often with tell (1)
- glizzy — 1 pair sides, mostly spelling via spelling phonetic key, often with bitch (1)
- choppas — 1 pair sides, mostly spelling via spelling phonetic key, often with hittas (1)
- hittas — 1 pair sides, mostly spelling via spelling phonetic key, often with choppas (1)
- lollygaggin — 1 pair sides, mostly vowel via spelling phonetic key, often with smokin (1)
- bleh — 1 pair sides, mostly spelling via spelling phonetic key, often with when (1)
- tekken — 1 pair sides, mostly vowel via spelling phonetic key, often with message (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| PnB Rock | Cold War | 8 | 4 | 35 | loose |
| PnB Rock | Fifty | 20 | 11 | 106 | loose |
| PnB Rock | Horses | 46 | 47 | 271 | loose |
| PnB Rock | Ordinary | 36 | 24 | 256 | loose |
| PnB Rock | Play With Me | 43 | 45 | 148 | loose |
| PnB Rock | There She Go | 44 | 34 | 218 | loose |
