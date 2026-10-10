# Anti-Gravity job, chat 6: JAY-Z (Penwork wordplay pass)

You are chat **6 · JAY-Z** (formerly Yeat; Chat 6 completed Yeat). Your job is to work through **JAY-Z** (about 1,023 vault songs).
If JAY-Z is claimed or done, proceed down the queue: Meek Mill, Destroy Lonely, Future, Yo Gotti, Young Dolph.
Project root: `/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync`. Work in `docs/play-on-words/`.

## Queue & Claims
1. Check `lane-claims/<artist lowercase>.claim` or `.done`. If already claimed/done, take the next unclaimed artist from: JAY-Z, Meek Mill, Destroy Lonely, Future, Yo Gotti, Young Dolph.
2. Write `lane-claims/<artist lowercase>.claim` containing "chat6", PID and start timestamp.
3. Work through the vault song list in reverse order (last song first), skipping songs already marked done.
4. Spacing: at least 10 seconds between Genius requests.
5. 20-minute pause on HTTP 429. Stop if >= 2 pauses in an hour.
6. Stop rule: before every song, check `all-artists-progress.md`. If the main run reaches this artist, finish current song and stop. Also stop if external writes appear in `genius-clicks/<artist>.jsonl`.
7. Chat status: write `chat-status/chat-6.md` at least every 15 minutes.
8. Every 50 songs: append progress row to `all-artists-progress.md` tagged `[chat6-<slug>]`.
9. When the artist is finished: rename claim to `.done`, write `<slug>-chat6-summary.md`, and move to the next artist on the list.
