# Gunna listen audit

Source: 13 titles from the first paste, plus Spotify Recents. The Recents page showed the weekday and the date and no year and no clock time. The year is 2026. Album and last played are filled only where the Recents page named them. Play count is blank. Nov 6 albums were not on that page and are blank.

Vault: `tools/bar-hits-catalog/BarHitsCatalog.sqlite`, opened `mode=ro`. `bars` count 1708472 at the start of this write and 1708472 after it. The vault was not edited.

## Counts

- Songs listened to: 24
- Songs matched: 23
- Songs not in the vault: 1 (pop it)
- Vault bars on the matched rows: 917
- Lines not counted as Gunna: 75 (Pop Smoke 40, Asake 22, cover-art and preview lines 13)
- Gunna lyric bars proofed: 842
- Location rows: 38
- Unique locations: 33
- Special-word rows: 342
- Unique special words: 256
- Unique words not in the chip bank: 190
- Missed sheet rows: 228
- Vault issue rows: 25

Chip bank checked: quoted word rows in `NounBankStore.swift` and `NounBankSections.swift`. A word is Y only when that string, or its simple singular or plural, is in one of those lists. `docs/play-on-words/unwired-chips.md` and `gunna-candidates.jsonl` were used for the missed sheet, not as a yes in the bank column.

Genius notes are `type: line` rows in `docs/play-on-words/genius-clicks/gunna.jsonl` for the vault title. The `type: song` row is not a note. The click log was not edited. Lemonade's genius count is 0 on the matched collab. Notes on Gunna | Lemonade were not copied onto Internet Money, Gunna & Don Toliver | Lemonade.

## What changed on the second pass

- paybach, idk nomore, and back to the moon: album a Gift & a Curse, last played 2026-10-28.
- alright: album a Gift & a Curse, last played 2026-10-29.
- Nov 6 session, last played 2026-11-06, album blank: forever be mine (feat. Wizkid), hakuna matata, Happiness (feat. Asake, Gunna), made for this shit, P power (feat. Drake), Different Species (feat. Gunna), Who You Foolin, pop it, Lemonade (feat. NAV), fukumean, one of wun.
- Dior (Remix) lines 1-40 are Pop Smoke and are off the location, special-word, and missed sheets. Lines 41-61 stay. Ricky Owens on line 51 is an alias note for Rick Owens. The vault was not edited.
- Happiness lines 1-22 are Asake and are not counted as Gunna. Lines 23-30 are.
- pop it has no Gunna-credited title. Pop Out Again and Pop Tags were not used.

## Flags

The listens sheet flags column and the vault_issues sheet hold the per-song notes. Cover-art and preview lines are on the missed sheet as malformed bars.

## Files

- `docs/gunna-listen-audit/gunna_listens.csv`
- `docs/gunna-listen-audit/gunna_listens.xlsx` sheets: listens, locations, special_words, missed, vault_issues
- `docs/gunna-listen-audit/new-words-review.md`
- `docs/gunna-listen-audit/summary.md`
