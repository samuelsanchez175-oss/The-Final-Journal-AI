# Guap Tarantino rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Guap Tarantino
- Songs: 4
- Bars kept (Guap Tarantino lyric lines): 132
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Guap Tarantino.
- Credit strings: Guap Tarantino.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 674
- REPEAT pairs, recorded separately: 111
- END rhymes: 211
- INNER rhymes: 463

By match:

- PERFECT: 71 (END 39, INNER 32)
- SLANT: 319 (END 87, INNER 232)
- ASSONANCE: 275 (END 77, INNER 198)
- MULTI: 9 (END 8, INNER 1)

By confidence:

- HIGH: 72
- MED: 568
- LOW: 34

## Core

- Core Y: 665
- Core N among rhyme pairs: 9

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 357 (53.0%)
- vowel: 275 (40.8%)
- spelling: 33 (4.9%)
- multi: 9 (1.3%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 4 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `vow:AE` — 92 pairs (END 52, INNER 40). Words: plastic, can't, having, passion, traffic, banks, extravagant, glasses.
2. `vow:AA` — 49 pairs (END 8, INNER 41). Words: got, want, lobster, bottom, problems, charger, larger, dodge.
3. `slant:AE:stop` — 30 pairs (END 25, INNER 5). Words: ratchet, can't, basket, last, mask, casket, past, nasty.
4. `vow:IH` — 25 pairs (END 3, INNER 22). Words: bitch, tint, glisten, business, give, wrist, stick, hits.
5. `vow:EH` — 22 pairs (END 0, INNER 22). Words: check, belt, embarrassed, carat, when, addressing, plenty, went.
6. `slant:AE:sib-stop` — 21 pairs (END 11, INNER 10). Words: bag, pass, had, match, daddy, caddy, baggy, attach.
7. `vow:OW` — 21 pairs (END 1, INNER 20). Words: no, don't, know, smoking, choppa, shottas, coast, forgiato.
8. `vow:EY` — 20 pairs (END 4, INNER 16). Words: ain't, anime, break, draco, k, say, mace, raid.
9. `vow:IY` — 19 pairs (END 7, INNER 12). Words: these, speakers, need, streets, cleanin, beach, see, key.
10. `cmu:AE-CH` — 18 pairs (END 18, INNER 0). Words: match, batch, latch, hatch, attach, catch.
11. `slant:AH:stop` — 15 pairs (END 0, INNER 15). Words: what, fucked, flooded, fuck, plug.
12. `vow:AH` — 15 pairs (END 0, INNER 15). Words: some, flooded, fucked, fuckin, money, hundreds, much, ups.
13. `cmu:AY-S` — 14 pairs (END 14, INNER 0). Words: twice, ice, lice, price, mice.
14. `slant:AH:nas-stop` — 13 pairs (END 0, INNER 13). Words: money, fuck, fuckin, plug, what, fucked, some, club.
15. `slant:AY:sib-stop` — 13 pairs (END 0, INNER 13). Words: like, ice, lice, twice, mice.
16. `slant:AA:stop` — 12 pairs (END 1, INNER 11). Words: want, got, bossed, top, not, lobster, glock, hop.
17. `slant:IY:sib-stop` — 11 pairs (END 5, INNER 6). Words: liters, these, beaters, meter, heater, beat, need, heat.
18. `vow:AY` — 11 pairs (END 2, INNER 9). Words: diamonds, by, like, line, rhymes, buy, tight, riding.
19. `slant:EH:stop` — 10 pairs (END 2, INNER 8). Words: get, ready, embarrassed, leg, spaghetti, plenty, rent, sent.
20. `slant:AE:sib` — 9 pairs (END 5, INNER 4). Words: pass, savage, average, cabbage, scratch, stats, ass, glasses.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- cuz — 9 pair sides, mostly spelling via spelling phonetic key, often with money (2)
- ima — 8 pair sides, mostly spelling via spelling phonetic key, often with bitch (4)
- fiending — 6 pair sides, mostly spelling via spelling phonetic key, often with cleaning (1)
- niggas — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (3)
- shottas — 4 pair sides, mostly vowel via spelling phonetic key, often with choppa (2)
- choppa — 3 pair sides, mostly vowel via spelling phonetic key, often with shottas (2)
- choppas — 3 pair sides, mostly spelling via spelling phonetic key, often with choppa (1)
- nigga — 3 pair sides, mostly spelling via spelling phonetic key, often with niggas (3)
- baddest — 2 pair sides, mostly vowel via spelling phonetic key, often with average (1)
- forgiato — 2 pair sides, mostly vowel via spelling phonetic key, often with no (2)
- ghini — 2 pair sides, mostly spelling via spelling phonetic key, often with shit (1)
- vvs — 1 pair sides, mostly cmu via vault phonetic_class, often with cvs (1)
- cvs — 1 pair sides, mostly cmu via vault phonetic_class, often with vvs (1)
- nage — 1 pair sides, mostly spelling via spelling phonetic key, often with have (1)
- attacted — 1 pair sides, mostly vowel via spelling phonetic key, often with basket (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Guap Tarantino | 100 Round Choppers | 46 | 44 | 181 | loose |
| Guap Tarantino | Born In It | 66 | 144 | 194 | loose |
| Guap Tarantino | Break Da Pot | 10 | 13 | 37 | loose |
| Guap Tarantino | Break Da Pot (Original) | 10 | 10 | 51 | loose |
