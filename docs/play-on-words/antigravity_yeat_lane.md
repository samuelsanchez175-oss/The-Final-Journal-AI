# Anti-Gravity job, chat 6: Yeat (Penwork wordplay pass)

You are chat **6 · Yeat** (formerly YoungBoy; Grok finished YoungBoy on its own computer). Your job is to work through **Yeat** (about 1,219 vault songs, no click log yet). Lil Yachty, Ty Dolla $ign and Rick Ross are claimed by Grok (box) — never touch them.
Project root: `/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync`. Work in `docs/play-on-words/`.

## Who else is running (do not collide)
- **1 · Main Run** (PID 99004) is on Juice WRLD. Its queue goes Juice WRLD, then Lil Uzi Vert, then everyone else by catalog size: Lil Wayne, then Quality Control, YoungBoy (done), Lil Yachty, Ty Dolla $ign, Rick Ross (all claimed by Grok), then **Yeat**. When it starts an artist, it reads that artist's `genius-clicks/<artist>.jsonl` once and skips every song already marked done there.
- **2 · Lil Uzi Vert** (claim `lane-claims/lil uzi vert.claim`) is working Uzi in reverse order. Don't touch Uzi.
- **5 · Lil Wayne** (claim `lane-claims/lil wayne.claim`) is working Lil Wayne. Don't touch Wayne.
- **3 · Lane 2** works the small artists from the bottom of the queue and skips any artist with a claim file.
- **4 · Wire Noun Bank** is editing Swift. Don't touch any Swift file, the Xcode project, or any wiring file.

## How to split Yeat with the main run
1. If `lane-claims/yeat.claim` (or `.done`) already exists, stop and report. Otherwise write it containing "chat6", your PID and a timestamp.
2. If `genius-clicks/yeat.jsonl` exists, back it up to `genius-clicks/yeat.jsonl.before-chat6-<YYYYMMDD_HHMM>.bak`.
3. Work through the vault song list **in reverse order (last song first)**, skipping songs already marked done. If the main run arrives, it goes front to back and the two of you meet in the middle.
4. Don't edit `run_all_artists.py`, `process_artist.py` or chat 2's `run_uzi_chat2.py` or chat 5's `run_wayne_chat5.py`. Write your own runner, `scratch/run_yeat_chat6.py`, in `/Users/samuel/.gemini/antigravity/brain/748a2ed1-dc92-4558-a71f-cd3bfb01a977/scratch/`. Import helpers from `process_artist.py` where you can, and only change the artist and the song order. Write rows in exactly the existing API shape (`type` song or line, status done or missing, click_status "api", clicked false), each appended as one whole line, then flushed.
5. **Stop rule:** before every song, check `all-artists-progress.md`. When a Rick Ross line appears there that is NOT tagged [box-ross], the main run is about to reach Yeat. Finish the song you're on, stop, rename the claim to `yeat.chat6-stopped`, and report. The main run picks up whatever is left. Also stop if `genius-clicks/yeat.jsonl` gets a write you didn't make.
6. If you finish every song first, rename the claim to `.done`.

## Per song (same rules as the main brief)
- Genius API search with `per_page=5`. Credit rule: Yeat must be `primary_artist` or listed in `featured_artists`. Never take a song from the wrong artist.
- Log unresolved songs with a reason in `yeat-unresolved.jsonl`.
- Pull referents. The Genius community note is the only source of meaning, and you reject hedged notes. A note that plainly says a word "sounds like" another is not hedged.

## Mining (required)
Mine `yeat-candidates.jsonl` with the halves classes AND `signal_type: "sound_flip"` whenever the note says a word or phrase sounds like, or splits into, another word, name, brand or place. Each sound_flip row needs `setup_spans`, `play_spans` (character offsets in the bar) and `heard_as`.
Samuel's model example is NoCap: "From a cell to a mansion like I'm Quagmire", where mansion is heard as "man chin". Tag them carefully. Watch the line alignment: attach each note to the line it annotates, not to the line next to it.

## Rate limits (SIX Genius users on one IP now)
- Use ONE worker and leave **at least 12 seconds between Genius requests**.
- On any HTTP 429, pause for 20 minutes. After two 429 pauses within an hour, stop and report.
- The main run comes first. If it shows 429s, pause too.

## Guardrails
- Don't touch BarHitsCatalog.sqlite (read-only queries are fine), `unwired-chips.md`, any NoCap file, Swift files, `~/.grok`, or the live-board files.
- Kill no process you didn't start.
- Don't commit or push.

## Progress and report
- Every 50 songs, add a progress line to `all-artists-progress.md` tagged `[chat6-yeat]`.
- When you stop, write `yeat-chat6-summary.md`: songs done, unresolved songs by reason, candidates by class, the sound_flip count, the 10 best flips written as setup → play = heard as, and why you stopped.
