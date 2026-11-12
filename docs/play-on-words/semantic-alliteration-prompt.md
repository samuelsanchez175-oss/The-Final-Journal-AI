JOB: Semantic alliteration pass, a new angle for Penwork Studios and the next generation of the rap generator. This is separate from the simile literalization and artist-title simile literalization passes.

WHAT TO FIND: Bars where alliteration (words close together starting with the same consonant sound) is paired with meaning: the alliterating words also belong to the same topic, brand family, or idea, so the sound and the sense reinforce each other. Alliteration alone is not enough. The repeated sound has to land on words that are related in meaning, or that line up into a list of the same kind of thing.

EXAMPLES OF THE PATTERN (vault/Genius-noted bars, do not re-report these):
- "Pucci posse (Yah) Louis league (Yah), Fendi fam" (Gucci Gang (Mega Remix); luxury brands, each one alliterating with a crew word)
- "Purple pint, pussy pink, bitch, I'm pushin' P" (Gunna, pushin P; P words tied to the P theme)
- "Big body Benzes while the bitch niggas starve" (Rick Ross, High Definition)
- "Rich nigga rituals, Rolls Royces and residuals" (Rick Ross, I Don't Play About My Paper; wealth words on R)
- "I roll over rodents in Rovers with rims on 'em" (Big Dog Status (Remix); rats/Rovers/rims)
- "Boston Bruins" after "Blood gang, bitch, big Bs" (Throwed; B for Bloods, Bruins worn as Blood colors)

HOW TO CHECK EACH BAR:
1. Read bars from the vault (tools/bar-hits-catalog/BarHitsCatalog.sqlite, table bars: artist, song, line). The vault is READ ONLY; open it with sqlite3 -readonly and confirm 1,708,472 bars before and after.
2. Find runs of 3 or more content words (skip filler like the/a/I/my) in one bar, or across a bar and the next, that share the same onset consonant sound. Use sound, not spelling: "Phantom" and "Fendi" match, "Chanel" and "chain" do not.
3. Score how related those words are in meaning (same category, same brand family, same scene, or one idea). Use a semantic similarity check (word embeddings or a category list) and keep the score.
4. Keep a bar only when the alliteration and the meaning both hold. Record: artist, song, line, the alliterating words, the shared sound, the shared meaning or category, the similarity score, and confidence HIGH / MED / LOW.
5. Use the Genius line notes in docs/play-on-words/genius-clicks/<artist>.jsonl as a cross-check: a note that already calls the bar alliteration is a strong signal. Never invent a note.

ACCEPTANCE:
- The line must exist in the vault exactly as quoted. Never invent or reword a lyric.
- Pure tongue-twisters with no shared meaning are LOW, not HIGH. Repeated words (the same word twice) do not count as alliteration.
- Keep LOW items labeled instead of dropping them.

APP DISPLAY: Results appear under the FOS (figures of speech) section, organized by artist in alphabetical order, as a semantic alliteration subcategory next to antonyms, similes, and simile literalization.

OUTPUT: docs/figurative-language/semantic-alliteration/<artist>.md plus a summary with counts per artist (bars checked, candidates, HIGH/MED/LOW).

SEARCH PHASES: Process artists in phases of five at a time. Finish one phase completely (all five artists searched, candidates saved, counts reported) before starting the next.

OUT OF SCOPE: No Swift or xcodeproj edits, no chip promotion, no commits to main, no pushes. Data only, then stop for Samuel's review of 25 HIGH items.
