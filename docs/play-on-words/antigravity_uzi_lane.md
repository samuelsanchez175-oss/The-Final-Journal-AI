# Anti-Gravity job, chat 2: finish Lil Uzi Vert (Penwork wordplay pass)

You are chat **2 · Verify Possibles**. Your verify job is done (31/31). Your new job is to finish **Lil Uzi Vert**, the biggest unfinished artist: 287 of 1,886 songs done, about 15% of the remaining work.
Project root: `/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync`. Work in `docs/play-on-words/`.

## Who else is running (do not collide)
- **1 · Main Run** (PID 99004) is on Juice WRLD, and **Lil Uzi Vert is next in its queue**. When it starts an artist, it reads `genius-clicks/lil uzi vert.jsonl` once and skips every song already marked done there.
- **3 · Lane 2** works the small artists from the bottom of the queue. It skips any artist with a claim file.
- **4 · Wire Noun Bank** is editing Swift. Don't touch any Swift file, the Xcode project, or any wiring file.

## How to split Lil Uzi Vert with the main run
1. Write the claim file `lane-claims/lil uzi vert.claim` containing "chat2", your PID and a timestamp.
2. Back up `genius-clicks/lil uzi vert.jsonl` to `genius-clicks/lil uzi vert.jsonl.before-chat2-<YYYYMMDD_HHMM>.bak`.
3. Work through the vault song list **in reverse order (last song first)**, skipping songs already marked done. The main run goes front to back, so if it arrives, the two of you meet in the middle instead of repeating each other.
4. Don't edit `run_all_artists.py` or `process_artist.py`. Write your own runner, `scratch/run_uzi_chat2.py`, in the same scratch folder (`/Users/samuel/.gemini/antigravity/brain/748a2ed1-dc92-4558-a71f-cd3bfb01a977/scratch/`). Import the helpers from `process_artist.py` where you can, and only change the song order. Write rows in exactly the existing API shape (`type` song or line, status done or missing, click_status "api", clicked false), each appended as one whole line, then flushed.
5. **Stop rule:** before every song, check `all-artists-progress.md`. When a Juice WRLD line appears there, the main run is about to start Lil Uzi Vert. Finish the song you're on, stop, rename the claim to `lil uzi vert.chat2-stopped`, and report. The main run picks up whatever is left. Also stop if `genius-clicks/lil uzi vert.jsonl` gets a write you didn't make.
6. If you finish every song first, rename the claim to `.done`. The main run will then skip all of them.

## Per song (same rules as the main brief)
- Genius API search with `per_page=5`. Credit rule: the artist must be `primary_artist` or listed in `featured_artists`. Never take a song from the wrong artist.
- Log unresolved songs with a reason in `lil-uzi-vert-unresolved.jsonl`.
- Pull referents. The Genius community note is the only source of meaning, and you reject hedged notes. A note that plainly says a word "sounds like" another is not hedged.

## Mining (required, same as lane 2)
Mine `lil-uzi-vert-candidates.jsonl` with the halves classes AND `signal_type: "sound_flip"` whenever the note says a word or phrase sounds like, or splits into, another word, name, brand or place. Each sound_flip row needs `setup_spans`, `play_spans` (character offsets in the bar) and `heard_as`.
Samuel's model example is NoCap: "From a cell to a mansion like I'm Quagmire", where mansion is heard as "man chin". Watch the line alignment: attach each note to the line it annotates, not to the line next to it.

## Rate limits (now FOUR Genius users on one IP)
- Use ONE worker and leave **at least 8 seconds between Genius requests**.
- On any HTTP 429, pause for 20 minutes. After two 429 pauses within an hour, stop and report.
- The main run comes first. If it shows 429s, pause too.

## Guardrails
- Don't touch BarHitsCatalog.sqlite, `unwired-chips.md`, any NoCap file, Swift files, `~/.grok`, or the live-board files.
- Kill no process you didn't start.
- Don't commit or push.

## Progress and report
- Every 50 songs, add a progress line to `all-artists-progress.md` tagged `[chat2-uzi]`. The live board reads the jsonl automatically.
- When you stop, write `uzi-chat2-summary.md`: songs before and after, unresolved songs by reason, candidates by class, the sound_flip count, the 10 best flips written as setup → play = heard as, and why you stopped.
