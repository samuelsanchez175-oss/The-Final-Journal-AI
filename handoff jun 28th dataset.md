---
title: "Handoff — Jun 28th — Dataset / Model G"
date: 2026-06-28
tags:
  - handoff
  - dataset
  - model-g
  - mlx
  - rap-filter
source: cloud-claude-session
---

# Handoff — Jun 28th — Dataset / Model G

> **How to use this note:** paste the prompt in the code block below into a **local Claude** running on this Mac (open it in the repo folder, and give it access to the Obsidian "llm builder" vault). It catches the local session up on everything done so far and lays out what to do next.

## Paste this into local Claude

```text
You're taking over from a cloud Claude session. You're now running LOCALLY on my Mac (Apple Silicon), so you CAN do what the cloud version couldn't: read/write my local files (including my Obsidian vault), download datasets, and run Xcode / the iOS Simulator. Read all of this, confirm what you can see, then help me continue.

## PROJECT
- App: "The Final Journal AI" (source folder "XJournal AI"; I call it Pen Work Studio) — an iOS/macOS Swift app (Xcode project) for AI-assisted rap lyric writing.
- The rap-writing model is "Model G". I want it to write in the style of the melodic-trap artists I respect.
- GitHub repo: samuelsanchez175-oss/The-Final-Journal-AI. Everything below is already merged to `main` — run `git pull` first.

## WHAT'S ALREADY BUILT (in the repo, on main)
1) tools/rap_dataset/ — dataset builder
   - build_rap_dataset.py: filters a big "Spotify songs + audio features + lyrics" CSV down to my artists, annotates each bar (CMUdict phonetics: syllables/stress/rhyme), adds BPM + key, outputs the ground_truth_rap_bars format. Stdlib only. Has --strip-lyrics.
   - rap_filter.json: my ARTIST FILTER = 54 artists I listen to (Gunna, Young Thug, Drake, Key Glock, Young Dolph, FBG Duck, Jay-Z, DaBaby, The Weeknd, Tory Lanez, Swae Lee, YFN Lucci, Giveon, 03 Greedo, full YSL, etc.). This list decides which songs to keep. Read it for the full roster.
   - README.md, sample_input.csv.
2) tools/modelg_local/ — offline MLX (Apple Silicon) fine-tune tools
   - build_mlx_dataset.py (makes train.jsonl/valid.jsonl), mlx_lora_config.yaml (the knobs: model + training settings), Modelfile (Ollama), README.md (full run guide).
3) XJournal AI/RapSuggestionAPI.swift — the app can use a LOCAL model via two UserDefaults keys: "modelg_local_base_url" (e.g. http://localhost:1234/v1 for LM Studio) and "modelg_local_model".
4) XJournal AI/ground_truth_rap_bars_MODEL_G.csv — the lyrics I already have: ~9,430 real bars, BUT ~99% are Gunna / Young Thug / YSL. The other ~40 artists have NO lyrics yet.

## WHAT I WANT (priority order)
1) OBSIDIAN: I have an Obsidian vault called "llm builder" on this Mac. I want it populated with my 54 artists' lyrics, formatted to match how I already work — I use TAGS, REFERENCES, and LINKS between notes.
   - FIRST: find the vault (ask me for its path if you can't locate it). Open 3-5 of my existing notes and learn my conventions (frontmatter, #tags, [[wikilinks]], folder layout). Show me what you found and confirm the style BEFORE generating anything.
   - THEN: generate notes that match my style. (Most artists' lyrics don't exist yet — build them first, step 2. You can start with the Gunna/Young Thug bars already in the CSV.)
2) GET THE LYRICS for all 54 artists (the cloud couldn't — Kaggle was network-blocked there):
   - Download Kaggle dataset: bwandowando/spotify-songs-with-attributes-and-lyrics ("960K Spotify Songs With Lyrics").
   - Run: python3 tools/rap_dataset/build_rap_dataset.py --input <downloaded.csv> --output "XJournal AI/rap_bars_from_my_artists.csv" --cmudict "XJournal AI/cmudict.txt" --filter tools/rap_dataset/rap_filter.json
   - That filters the big set down to my 54 artists + annotates it. Use the result for the Obsidian notes and/or fine-tuning.
3) (Optional) FINE-TUNE Model G locally with MLX — follow tools/modelg_local/README.md:
   pip install -U mlx-lm
   python3 tools/modelg_local/build_mlx_dataset.py --from-csv "XJournal AI/rap_bars_from_my_artists.csv" --out-dir tools/modelg_local/data
   mlx_lm.lora --config tools/modelg_local/mlx_lora_config.yaml
   then mlx_lm.fuse and load the result in LM Studio.
4) (Optional) RUN THE APP in the iOS Simulator: open the .xcodeproj in Xcode, pick a simulator, press Run (Cmd+R). Our changes already passed GitHub's compile-check.
5) (Optional) Expand my artist list from my REAL Spotify favorites — the cloud's Spotify connector kept expiring; yours may work. If so, pull my top/followed artists and add them to rap_filter.json.

## KEY FACTS / DECISIONS
- There is NO Spotify inside the app. Spotify was only ever a lookup to pick artist names. The filter is just a plain text file.
- Copyright: verbatim lyrics are copyrighted. For my personal Obsidian vault that's my call, but for anything shipped in the app, prefer DERIVED FEATURES (syllables, rhyme classes, BPM, key) over verbatim lyrics (the builder's --strip-lyrics does this).
- Dataset tools are stdlib-only Python (no deps). The MLX fine-tune path needs Apple Silicon.

## HOW I LIKE TO COMMUNICATE
- Plain, simple language; minimal jargon.
- Use arrows (->) to show the path/reasoning.
- Give me clear A or B options when there's a decision — not open-ended ultimatums.

START BY: confirming you can see (a) the repo files tools/rap_dataset/ and tools/modelg_local/, and (b) my Obsidian vault "llm builder" (ask me for the path if needed). Then tell me what note conventions you found in my vault, and give me an A/B on how to proceed.
```

## Quick reference — where things live
- **Artist filter (54 artists):** `tools/rap_dataset/rap_filter.json`
- **Dataset builder:** `tools/rap_dataset/build_rap_dataset.py`
- **Offline MLX fine-tune tools:** `tools/modelg_local/`
- **App local-model hookup:** `XJournal AI/RapSuggestionAPI.swift`
- **Lyrics I already have (Gunna/Thug heavy):** `XJournal AI/ground_truth_rap_bars_MODEL_G.csv`
- **Big lyrics dataset (download on Mac):** Kaggle `bwandowando/spotify-songs-with-attributes-and-lyrics`
