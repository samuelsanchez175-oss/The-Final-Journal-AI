# Bret “Epic” Mazur rhyme extraction

Vault `tools/bar-hits-catalog/BarHitsCatalog.sqlite` was opened read-only. Count before the run: 1708472. Count after the run: 1708472.

## Coverage

- Artist credits opened: Bret “Epic” Mazur
- Songs: 1
- Bars kept (Bret “Epic” Mazur lyric lines): 12
- Section headers dropped, not counted as bars: 0
- Genius page chrome dropped, not counted as bars: 0. These vault rows are a leading `|`, an `aria-label`, or the words "You might also like". They are not lyric bars and they are not rhyme examples. Songs that had them: none
- Lines skipped because a section header named another artist: 0
- Kept bars that are only an ad-lib or filler after the parenthetical is stripped: 0
- Canonical name: Bret “Epic” Mazur.
- Credit strings: Bret “Epic” Mazur.
- Collab credits are included because this artist is the first name. Section headers that name someone else are not counted as his bars.

A bar index is the 1-based position of the line in that song after section headers and Genius chrome are removed. END rhymes compare line endings within 4 of those lines. INNER rhymes compare a word that is not the last word, inside the same line or against a word in the next one or two lines. The same normalized word is REPEAT, not a rhyme. REPEAT rows are in `rhyme_pairs.csv` and the All sheet. They are not in the End, Inner, Multi-syllable, or Low confidence sheets, and they are not in the layer share. `core` is Y when the match is PERFECT, SLANT, or MULTI, or the confidence is HIGH or MED. `core` is N for a LOW-confidence ASSONANCE and for REPEAT. The Core sheet is core Y only. Nothing is dropped from the csv.

Parenthetical ad-libs are ignored when the rhyme word is chosen. The quoted bar is the vault line.

## Pair counts

- Rhyme pairs, excluding REPEAT: 128
- REPEAT pairs, recorded separately: 7
- END rhymes: 7
- INNER rhymes: 121

By match:

- PERFECT: 10 (END 0, INNER 10)
- SLANT: 75 (END 3, INNER 72)
- ASSONANCE: 41 (END 4, INNER 37)
- MULTI: 2 (END 0, INNER 2)

By confidence:

- HIGH: 7
- MED: 92
- LOW: 29

## Core

- Core Y: 123
- Core N among rhyme pairs: 5

## Layer share

Share of rhyme pairs (REPEAT excluded). CMU is `pronouncing` / cmudict, plus the vault `phonetic_class` tail when the end word is not in the dictionary. Vowel is assonance. Spelling is the normalized ending plus Metaphone (`jellyfish.metaphone`; that package has no Double Metaphone). Multi is the last 2–3 syllables, including a phrase at the end of the line.

- cmu: 56 (43.8%)
- vowel: 41 (32.0%)
- spelling: 29 (22.7%)
- multi: 2 (1.6%)

## Schemes

A scheme uses END pairs scored PERFECT, SLANT, or MULTI inside 4 lines. Assonance and REPEAT do not set the letter. A known pattern is kept when it covers at least 40% of the 4-line windows. Otherwise the song is loose.

- loose: 1 songs

## Alphabetical vault order

These songs are still A-to-Z after section headers and Genius chrome are removed. The window follows that vault lyric order. Performance order was not reconstructed.

- None with 5 or more lines.

## Top 20 families

1. `slant:IH:sib-stop` — 14 pairs (END 0, INNER 14). Words: bitch, hit, stick, whip, scissor, swisher, tips, nigga.
2. `vow:IH` — 13 pairs (END 3, INNER 10). Words: victim, bitch, tips, swisher, liver, kill, scissor, hit.
3. `slant:IH:stop` — 11 pairs (END 0, INNER 11). Words: nigga, hit, stick, flipp, whip, riko.
4. `slant:IH:liq-sib` — 6 pairs (END 0, INNER 6). Words: bitch, kill, lil, millie, scissor, swisher.
5. `vow:EH` — 6 pairs (END 0, INNER 6). Words: self, member, tearin, when.
6. `vow:IY` — 6 pairs (END 0, INNER 6). Words: reekee, d, haiti, millie, zoe, backseat, sweet, these.
7. `slant:IH:sib` — 5 pairs (END 1, INNER 4). Words: bitch, scissor, swisher.
8. `vow:OW` — 5 pairs (END 0, INNER 5). Words: know, zoe, don't, riko, phone, smoke, parole.
9. `cmu:IH-N` — 4 pairs (END 0, INNER 4). Words: oppin, spin, twin, fuckin.
10. `slant:AA:nas-stop` — 4 pairs (END 0, INNER 4). Words: pop, droppin, stoppin, top.
11. `slant:IH:liq-nas` — 4 pairs (END 0, INNER 4). Words: millie, i'ma, spin, twin, kill.
12. `slant:IH:liq-stop` — 4 pairs (END 0, INNER 4). Words: kill, riko, millie, hit, stick, whip, lil.
13. `slant:IH:nas-stop` — 4 pairs (END 0, INNER 4). Words: riko, i'ma, spin, twin, hit, stick.
14. `vow:AA` — 4 pairs (END 1, INNER 3). Words: skyrocket, nothin, stoppin, droppin, r, hollow.
15. `slant:IH:fric-sib` — 3 pairs (END 2, INNER 1). Words: liver, scissor, swisher, bitch.
16. `slant:IH:nas-sib` — 3 pairs (END 0, INNER 3). Words: i'ma, bitch, scissor.
17. `slant:IY:nas-stop` — 3 pairs (END 0, INNER 3). Words: tryna, speakin, reekee, backseat, sweet.
18. `vow:AH` — 3 pairs (END 0, INNER 3). Words: fuckin, come, love, what.
19. `vow:EY` — 3 pairs (END 0, INNER 3). Words: ain't, claim, stay, way.
20. `cmu:OW-N` — 2 pairs (END 0, INNER 2). Words: gon, phone.

## Out of dictionary

Top 30 normalized words that are not in cmudict and still landed in a pair. Count is pair sides, so a word in two pairs counts twice.

- ima — 7 pair sides, mostly spelling via spelling phonetic key, often with bitch (2)
- nigga — 6 pair sides, mostly spelling via spelling phonetic key, often with riko (1)
- flipp — 6 pair sides, mostly spelling via spelling phonetic key, often with stick (1)
- riko — 5 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)
- reekee — 4 pair sides, mostly vowel via spelling phonetic key, often with haiti (1)
- oppin — 3 pair sides, mostly spelling via spelling phonetic key, often with fuckin (1)
- gon — 3 pair sides, mostly spelling via spelling phonetic key, often with phone (2)
- tryna — 2 pair sides, mostly spelling via spelling phonetic key, often with sweet (1)
- niggas — 1 pair sides, mostly spelling via spelling phonetic key, often with nigga (1)

## Songs

| Artist | Song | Bars | End rhymes | Inner rhymes | Scheme |
| --- | --- | --- | --- | --- | --- |
| Bret “Epic” Mazur | Kodak black - anthem #MAGA MIX [DJ EPIC BOOTLEG] | 12 | 7 | 121 | loose |
