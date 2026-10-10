# Anti-Gravity job, lane 2: a second worker for the all-artists wordplay pass (Penwork)

Run this in its OWN new chat. It's the second worker on the same job as the main all-artists run, which is already running as `run_all_artists.py`, PID 99004. Your job is to take a separate chunk of artists so the job finishes sooner. You must never work on an artist the main run is on or will reach soon.

Project root (quote it, the path has spaces): "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync"
Main run's code (reuse it, don't edit it): /Users/samuel/.gemini/antigravity/brain/748a2ed1-dc92-4558-a71f-cd3bfb01a977/scratch/run_all_artists.py and process_artist.py (it has `process_one_artist(artist)`).
Original brief, which has the rules and the credit rule: the same rules as the all-artists job. Accept a Genius song only when the artist is its primary_artist or in featured_artists, the title matches after normalizing, and a line with no note never gets an invented note.

## How the work is split (so the two workers never collide)
The main run builds its queue once: Juice WRLD, then Lil Uzi Vert, then every other artist in `bars` from the largest catalog down (`select artist, count(distinct song) from bars group by artist order by 2 desc`), skipping NoCap, Drake and Veeze. It works top-down.

**Lane 2 works the same queue from the BOTTOM UP**, smallest catalog first, moving toward the middle. The two workers meet somewhere in the middle and stop there.

Before you start EACH artist:
1. Rebuild the main queue exactly as above, read only (`file:...?mode=ro`).
2. Work out where the main run is: the artist whose `genius-clicks/<artist lowercase>.jsonl` changed most recently, or the last line in `docs/play-on-words/all-artists-progress.md`, whichever is further along. Call its position M.
3. Only take an artist if its position in the queue is more than M + 3. That leaves a buffer of 3 artists.
4. Skip any artist whose genius-clicks jsonl already exists and changed in the last 30 minutes, or that has a claim file from another worker.
5. Claim it: write `docs/play-on-words/lane-claims/<artist lowercase>.claim` with "lane2", the PID and a timestamp. When the artist is done, rename it to `.done`.
6. **STOP the whole lane** when the next artist you'd take is at position M + 3 or lower, because the two workers have met. Write in your report that the main run will reach lane-2 artists from then on. When that happens, Samuel has to stop the main run, because it would re-search lane 2's unresolved songs and add duplicate "missing" rows. Say this plainly in your stop report.

Skip producers and labels quickly. Names like Quality Control, Young Stoner Life, Metro Boomin, Zaytoven and DP Beats usually come back `not_<artist>_credit`. Log them and move on.

## Per artist
Same steps as the main brief: back up the jsonl if one exists, then do the API search under the credit rule (per_page=5), pull the referents, write rows in the existing API shape (click_status "api", clicked false), log unresolved songs with a reason in `<artist>-unresolved.jsonl`, run `render(<artist>)`, mine `<artist>-candidates.jsonl`, and add one progress line to `all-artists-progress.md` tagged with `[lane2]`. The simplest safe way is a small runner of your own that imports `process_one_artist` from the main scratch folder and feeds it the lane-2 queue with the claim checks above. Don't change the main scripts.

### New mining class, required
Samuel's top target is the **sound flip**. The model bar is NoCap's "From a cell to a ***mansion*** like I'm **Quagmire**", where mansion is heard as "man chin". Another is "Me and Lil ***Joe*** … couldn't ***buy 'den***", where the setup is "presidents" and it's heard as Joe Biden.
In every candidate row, add these fields:
- `signal_type: "sound_flip"` when the note says a word or phrase sounds like, or splits into, another word, name, brand or place
- `setup_spans` and `play_spans` as exact substrings of the vault bar, with start and end offsets
- `heard_as`
Two fixes to the current miner:
- A note that plainly states the sound ("never felt (Phelps)", "pronounces mansion as man-chin") is not hedged just because it uses the word "sounds". Only real uncertainty words count as hedging (maybe, might, possibly, could be, probably, perhaps, I think).
- Attach each note to its exact bar. The current data sometimes gives the line before or after the right one. Match the note's fragment against the vault lines, and take the line that contains it.

## Rate limits (THREE Anti-Gravity jobs share one Genius IP)
Use ONE worker in this lane and keep at least 6 seconds between Genius requests. On any HTTP 429, stop all Genius requests for 20 minutes. After two 429 stops within an hour, stop the lane and report. If the main run's log or progress shows it's hitting 429s, pause this lane for 20 minutes too, because the main run comes first.

## Guardrails
- Never edit Swift files, BarHitsCatalog.sqlite, unwired-chips.md, the noun or chip bank, the live-board server.py, wordplay-highlights.jsonl, or the possible-wordplay-verify/ folder.
- Never touch NoCap, Drake, Veeze, Juice WRLD or Lil Uzi Vert files, or any artist the main run has started.
- Don't kill or restart any process you didn't start. Leave the main run (PID 99004) and the board on port 47321 alone.
- Nothing gets promoted to chips; Samuel reviews first.

## Report
After each artist, add its progress line. When you stop, write `docs/play-on-words/lane2-summary.md` covering: the artists completed, with before and after counts; unresolved songs by reason; candidates by halves class plus the number of sound_flip candidates; the 10 best sound flips in the format setup → play = heard as; the artist where you stopped and why; and whether the main run now needs to be stopped.
