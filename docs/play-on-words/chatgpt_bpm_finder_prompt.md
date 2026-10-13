# ChatGPT BPM/Key Finder Prompt

You are helping find BPM, key, and mode data for 1,062 hip-hop songs that automated tools couldn't match.

## Task

Search for **BPM, key (e.g., "C# minor"), and mode (major/minor)** for the songs listed below. These are mostly unreleased, leaked, or oddly-titled tracks that don't appear in Spotify/ReccoBeats.

## Where to Look (in order)

1. **GetSongBPM** (getsongbpm.com): Search `artist + song title`
2. **Tunebat** (tunebat.com): Search `artist + song title`
3. **SongBPM** (songbpm.com): Search or browse
4. **YouTube comments**: Search `artist song BPM` on YouTube; producers often post it in comments
5. **Producer/artist social media**: Twitter, Instagram, TikTok (search `artist song BPM`)
6. **Reddit**: r/trapproduction, r/makinghiphop (search for the song title)
7. **BeatStars, Splice, Soundtrap**: If the song is a beat or sample, it may list BPM

## Rules

- **ONLY record BPM if you read it off a page/post** — never guess or estimate by ear
- **Record the exact BPM** from the source (e.g., 142, 71.5, etc.)
- **Record key as letter + major/minor** (e.g., "F# minor", "C major")
- **Include the source URL** for verification
- **Mark confidence level**:
  - `exact`: page is for this exact song by this artist
  - `variant`: same song, different version (clean, sped-up, remaster)
  - `not_found`: searched everywhere, found nothing

## Output Format

For each song found, output as JSON (one line per song):

```json
{"artist": "Gunna", "song": "In My Ways", "bpm": 142, "key": "F# minor", "source": "getsongbpm", "url": "https://...", "confidence": "exact", "notes": ""}
```

For songs NOT found after searching all sources:

```json
{"artist": "Gunna", "song": "In My Ways", "bpm": null, "confidence": "not_found", "source": "manual"}
```

## Songs to Search

Start with **highest bar count first** (each song shows bars count). Work artist by artist.

### 03 Greedo (6 songs, ~400 bars total)
1. AGGRESSIVELY FLEXIN' (70 bars)
2. Ain't No Fightin' (67 bars)
3. Airbnb (66 bars)
4. ALL YOU (62 bars)
5. 10 Purple Summers (57 bars)
6. Act Like You Know (58 bars)

### 21 Savage (8 songs, ~320 bars)
1. A Lot (65 bars)
2. Bank Account (59 bars)
3. Cash (57 bars)
4. Crabs in a Bucket (55 bars)
5. Ghost (54 bars)
6. Go Crazy (53 bars)
7. I'm So Groovy (52 bars)
8. Mad (51 bars)

### Gunna (12 songs, ~480 bars)
1. Drip Season 3 (61 bars)
2. Drip Too Hard (60 bars)
3. Dirty Mouth (59 bars)
4. Eat Before You Sleep (58 bars)
5. Finesse (57 bars)
6. Good Dope (56 bars)
7. Heavy Chevy (55 bars)
8. I'm So Blessed (54 bars)
9. Island (53 bars)
10. Jumped In (52 bars)
11. Keep It Real (51 bars)
12. Lick Back (50 bars)

[... additional artists listed ...]

## Pace

- 1 song search per 2–3 minutes (don't hammer sites)
- If a site blocks you (CAPTCHA, rate limit), skip it and try another source
- If you find one, post it; if not, move to next song
- Post results incrementally (don't wait for all 1,062)

## Submission

Post results in this thread as JSON (one line per song). Format:

```
03 Greedo - AGGRESSIVELY FLEXIN': {"artist": "03 Greedo", "song": "AGGRESSIVELY FLEXIN'", "bpm": 142, ...}
```

Or paste all results as a block at the end.

---

## Full Worklist (1,062 songs)

[Data from: tools/style-profile/out/tempo_worklist.jsonl]

Work artist by artist, biggest bars first. If you complete an artist, post "DONE: [artist name]" and move to the next. If sites block you or you run out of time, stop at artist boundary and note where you left off.

**Current Status**: 
- 03 Greedo: 0/6 found (blocked by sites earlier)
- Ready for: 21 Savage, Gunna, J. Cole, Chief Keef, Lil Wayne, etc.

---

## Expected Hit Rate

- **Catalog songs**: 40–60% (songs on Spotify/YouTube will have BPM listed somewhere)
- **Unreleased/leaks**: 5–15% (hard to find; try producer social media)
- **Overall target**: ~30–40% for 1,062 songs = ~320–425 songs found

Final results will be merged into the main pipeline: `python3 phase3_tempo_key.py --merge-manual`

---

Good luck! Post results in replies below.
