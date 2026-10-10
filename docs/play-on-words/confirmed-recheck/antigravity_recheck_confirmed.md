# Anti-Gravity job: second pass on the CONFIRMED wordplay lines (Penwork)

Samuel reviewed the board's confirmed list and found misreads. Your job is to recheck every confirmed line, plus every mined sound-flip candidate waiting as "unconfirmed", and decide KEEP, FIX or REJECT for each.
Project root: `/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync`. Work in `docs/play-on-words/confirmed-recheck/`.

## What a real flip looks like (Samuel's format)
Every real line has three parts:
- **SETUP:** the cue word(s) that point at the hidden meaning (shown in blue). Example: "presidents".
- **PLAY:** the exact words in the bar that carry the double meaning (shown in yellow). Example: "Joe … buy 'den".
- **HEARD AS:** what those words become (shown in green). Example: Joe Biden.

The gold example is NoCap: "From a cell to a mansion like I'm Quagmire". The play is "mansion", heard as "man chin", and the setup is Quagmire (his chin).
A plain reference, a simile, slang, a name-drop or a brand mention is **not** wordplay unless the words also sound like, or split into, something else.

## Samuel's calls (already in recheck.jsonl, use them as calibration)
- REJECT: Uzi, "Niggas rattin', they get hit with the MAC today", heard as "Yeah". This is a gun reference, not wordplay.
- REJECT: Uzi, "All black like it's Kray", heard as "also Sickboyrari". This is a name-drop, not wordplay.
- FIX: Diddy/French, "Coi Leray in L.A., no more parties". It was backwards: the wordplay IS the name Coi Leray. Work out the exact flip (e.g. "Coi Leray" sounding like "…in L.A.") and correct the setup, play and heard-as.
- FIX: The Game, "And I'm sippin' Quavo like a Migo". The wordplay is on Migos member names (Quavo of the Migos), not "Jose Cuervo". Confirm the exact setup, play and heard-as.

## Input: what to check
Get the full list from `http://127.0.0.1:47321/api/highlights` (the confirmed rows plus the unconfirmed/possible rows). Check in this order:
1. Every mined candidate now shown as unconfirmed (all were wrongly auto-confirmed earlier). That includes the lines numbered #170 and #174–#177 (Central Cee Mitch/Azie, Uzi iPod/Zune, Uzi Daytona, Uzi "red drop", Juicy J XXL), plus any new sound_flip candidates the runs add while you work.
2. Lines #169 down to #1, newest first.

## How to judge each line
- Read the Genius annotation for that exact line (the URL is on the row). Use the WebFetch tool or the Genius API at **12+ seconds between Genius requests**, because the other jobs share the same IP. On an HTTP 429, wait 20 minutes.
- Confirm the bar text matches the line the note is attached to. Earlier mining attached notes to the wrong line, off by one.
- **KEEP** only if the line really has a setup plus play words with a second reading, and the stored setup, play and heard-as are right.
- **FIX** if it's real wordplay but the spans or heard-as are wrong. Give the corrected setup_spans and play_spans (character offsets into the bar) and the heard_as.
- **REJECT** if it's a plain reference, simile, slang, name-drop or brand mention with no double reading, or if the note doesn't support a flip.
- If you're truly unsure, use FIX with `needs_samuel: true` and explain why in one sentence. Don't guess KEEP.

## Output
- Append one row per line to `confirmed-recheck/recheck.jsonl`, using exactly this shape (the live board reads it and applies it immediately):
  `{"key_artist": "...", "key_song": "...", "key_bar": "<exact bar text from the row>", "verdict": "KEEP|FIX|REJECT", "setup_spans": [[start,end]], "play_spans": [[start,end]], "heard_as": "...", "reason": "<one sentence>", "source_url": "...", "by": "antigravity-recheck", "ts": "<ISO time>"}`
- Write each row as one whole line, then flush. Never edit or delete Samuel's rows (`"by": "samuel"`).
- Every 25 lines, update `confirmed-recheck/recheck-summary.md` with counts of KEEP, FIX and REJECT, the FIXes as setup → play = heard as, and the lines flagged `needs_samuel`.

## Guardrails
- Don't edit `wordplay-highlights.jsonl`, `verified.jsonl`, any `*-candidates.jsonl`, `confirmed-seq.json`, the live-board files, Swift files, BarHitsCatalog.sqlite, `unwired-chips.md`, NoCap's source files or `~/.grok`.
- Kill no process.
- Don't commit or push.
- Chat 4 (noun-bank wiring) reads the confirmed list. If a line you REJECT was already wired into the app, note it in `recheck-summary.md` under "wired but rejected", so it can be removed later with Samuel's OK. Don't remove it yourself.
