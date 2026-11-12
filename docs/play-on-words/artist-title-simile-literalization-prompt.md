JOB: Artist-title simile literalization, a new angle for the figurative speech box in Penwork Studios. This is separate from the existing simile literalization pass (simile-literalization-prompt.md) and does not replace it.

WHAT TO FIND: Bars where the literal half of a simile (the part after like/as) is, or sounds like, an artist's name or a song title. The comparison works twice: it reads as an everyday object, brand, place, or thing, and it also names a real artist or a real song. Often the figurative half is itself a song title by that same artist, so the bar pairs the song with the artist who made it. The name or title is the punchline, not decoration.

SAMUEL'S EXAMPLE (verbatim, do not re-report it):
- "I got her losing her mind like parking next door"
  ("Losing Her Mind" is a song by PARTYNEXTDOOR; "parking next door" sounds like PARTYNEXTDOOR.)

HOW TO CHECK EACH SIMILE:
1. Find like/as similes in the vault (tools/bar-hits-catalog/BarHitsCatalog.sqlite, table bars: artist, song, line). The vault is READ ONLY; open it with sqlite3 -readonly.
2. Take the literal half (the concrete object, brand, or everyday thing) and compare it against every artist name in the vault and against the song titles in the vault. Allow soundalikes and split spellings (parking next door = PARTYNEXTDOOR), not just exact matches.
3. Take the figurative half and check whether it matches a song title by that same artist. A bar where both halves line up (song title + its own artist) is the strongest kind of hit.
4. Save the bar as a wordplay candidate with: artist, song, line, the simile's literal half, the matched artist or title, the match type (EXACT, SOUNDALIKE, SPLIT), and whether the figurative half is a title by that artist (YES/NO).

ACCEPTANCE:
- The line must exist in the vault exactly as quoted. Never invent or reword a lyric.
- The match must be a real artist or a real song title found in the vault catalog. Name the matched artist/song for every candidate.
- Tiny echoes do not count (one short common word that happens to be a title, like "Up" or "Home"). The name or title has to carry the joke.
- Label confidence HIGH / MED / LOW and keep LOW ones labeled instead of dropping them.

EXPECTED VOLUME: This is probably rare in the vault lyrics. Treat it as a new detector and a new angle, not a high-volume pass. A short, real list is a good result; zero hits for an artist is a valid answer, so report it as zero rather than stretching weak matches to fill the list.

OUTPUT: docs/figurative-language/artist-title-simile-literalization/<artist>.md plus a summary with counts per artist (similes checked, candidates found, HIGH/MED/LOW).

SEARCH PHASES: Process artists in phases of five at a time, the same as the simile literalization pass. Finish one phase completely (all five artists searched, candidates saved, counts reported) before starting the next phase.

OUT OF SCOPE: No Swift or xcodeproj edits, no chip promotion, no commits to main, no pushes. Data only, then stop for Samuel's review.
