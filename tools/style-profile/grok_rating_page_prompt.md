Build me a single-file web app called **Sparkler Rater**. I use it to rate AI-written rap verses as fast as possible (thumbs up / thumbs down, keep moving) so my pipeline can learn what I like. Speed and zero friction matter more than anything else.

**Context:** the rest of this pipeline (verse generation, the vote database, the importer for your export) is maintained by Claude Code in my repo. Claude can't see this conversation, so you and Claude talk through a shared log file. You MUST follow the "Handoff protocol" section at the bottom of this message in every reply.

## Hard requirements

- ONE self-contained `index.html` (inline CSS + vanilla JS). No build step, no backend, no external API calls. Must work by double-clicking the file (file://) on Mac and on iPhone Safari.
- No frameworks required. If you use a library, load it from cdnjs.cloudflare.com with a pinned version.
- Everything the app stores lives in `localStorage` (autosave after every action), with a JSON export button. Never lose ratings on refresh.

## Input data

I load one or more `.json` files (file picker AND drag-and-drop onto the page). Each file looks like this (trimmed real example):

```json
{
  "schema": "phase6.v2",
  "prompt_version": "verse.v4",
  "artist": "Gunna",
  "topic": "money_flex",
  "topic_brief": "money: counting it, spending it, showing it off",
  "scheme": "aabb",
  "syl_range": [12, 15],
  "exemplars": [
    {"song": "Pink Sprite", "topic": null, "bars": ["Dior Homme and Dolce pinstripes", "I doubled up and got my kin right"]}
  ],
  "models": {
    "opus": {
      "model": "opus",
      "generation_id": "6b725d45ebbc431eb30a9cd133876dcf",
      "passed": true,
      "problems": [],
      "elapsed_s": 200.6,
      "bars": [
        {
          "text": "Sacks on the table, I'm countin' the twenties in racks",
          "halves": [{"text": "Sacks on the table", "syl": 5}, {"text": "I'm countin' the twenties in racks", "syl": 8}],
          "syllables": 13,
          "end_word": "racks",
          "rhyme_letter": "A",
          "internal": [["sacks", "racks"]],
          "borrowed": null,
          "meaning": "Money bags are on the table and he's counting the twenties into stacks.",
          "checks": {"one_comma": true, "setup_shorter": true, "syllables": true, "internal_rhyme": true, "not_a_copy": true}
        }
      ]
    },
    "sonnet": { "...same shape..." },
    "haiku": { "...same shape..." }
  }
}
```

Treat every `models[x]` entry with at least one bar as one **verse card**. A file with 3 models = 3 cards. Skip models whose `bars` array is empty. Dedupe by `generation_id` if the same file is loaded twice.

## The rating screen (the whole app is basically this)

- One verse card at a time, centered, big readable type (I read these out loud). Each bar on ONE line, never wrapped mid-bar on desktop.
- Shuffle card order across files and models so I don't see the same model back to back.
- **Blind by default:** do NOT show which model wrote the verse until after I vote. After voting, briefly flash the model name (e.g. "that was Opus") for ~800ms, then auto-advance.
- Header line above the card: artist · topic_brief · scheme (e.g. "Gunna · money: counting it, spending it, showing it off · AABB").
- For each bar show, small and muted next to it: the syllable count of each half (from `halves[].syl`) and the `rhyme_letter` as a small badge. Underline `end_word`; highlight words listed in `internal`. Keep these subtle; the lyric text is the hero.
- `meaning` and `checks` are hidden by default behind a "details" toggle (key `D`). I don't want them biasing me.
- A collapsible "Real lyrics used" drawer showing `exemplars` from that file (key `R`).

### Voting
- Big 👍 and 👎 buttons for the whole verse. On mobile they must be thumb-reachable at the bottom of the screen; swipe right = 👍, swipe left = 👎.
- 👍 saves and auto-advances immediately.
- 👎 shows a one-tap reason row (multi-select, optional): `no_sense` ("doesn't make sense"), `bad_rhyme`, `off_flow`, `off_topic`, `too_copied`, `cringe`. Then Enter / "Next" (or a 2.5s timeout with no tap) saves and advances. Reasons are optional; never block me.
- Per-bar voting (optional, for when one bar is great or terrible): tap a bar to cycle its state none → 👍 → 👎 → none. Also a ⭐ "keeper" toggle per bar (long-press on mobile, `S` + bar number on desktop) for standout lines.
- Optional free-text note per verse (key `N`), never required.
- Undo last action (`U` / Cmd+Z), and Back to the previous card (`←`) to change a vote.

### Keyboard (desktop)
- `↑` or `1` = 👍 verse · `↓` or `2` = 👎 verse
- `→` or `Space` = skip (no vote recorded) · `←` = back
- while the reason row is open: `Q W E A S D` toggle the six reasons in the order listed above, `Enter` = save
- `B` then `1-4` = cycle that bar's vote · `K` then `1-4` = toggle keeper star on that bar
- `D` details, `R` real lyrics, `N` note, `U` undo, `?` shows a shortcut cheat sheet overlay

Pick a clean, conflict-free mapping if mine collides; show it in the `?` overlay.

## Progress + stats

- Thin progress bar: "12 / 30 rated", plus a session timer.
- A Stats view (tab or key `T`) that shows, per model: verses rated, 👍 rate, most common 👎 reasons, keeper count. Also 👍 rate when `passed` was true vs false (tells me if the automatic checks agree with my ear). Simple bars/tables are fine.

## Export (must match exactly, my importer depends on it)

"Export ratings" downloads `sparkler_ratings_YYYY-MM-DD_HHMM.json`:

```json
{
  "schema": "sparkler.ratings.v1",
  "rater": "samuel",
  "exported_at": "2026-10-13T19:00:00Z",
  "ratings": [
    {
      "generation_id": "6b725d45ebbc431eb30a9cd133876dcf",
      "model": "opus",
      "artist": "Gunna",
      "topic": "money_flex",
      "prompt_version": "verse.v4",
      "passed_checks": true,
      "verse_vote": 1,
      "verse_reasons": [],
      "note": "",
      "bar_votes": [
        {"bar_index": 0, "bar_id": "6b725d45ebbc431eb30a9cd133876dcf:0", "text": "Sacks on the table, I'm countin' the twenties in racks", "vote": 1, "keeper": true, "reasons": []}
      ],
      "rated_at": "2026-10-13T18:59:12Z",
      "time_to_rate_ms": 4200
    }
  ]
}
```

Rules for the export:
- `verse_vote` is `1`, `-1`, or `null` (skipped cards are NOT exported).
- `bar_votes` only includes bars I actually voted on or starred. Never copy the verse vote onto bars.
- `bar_id` is always `"<generation_id>:<bar_index>"`, 0-based.
- `verse_reasons` / `reasons` only use these codes: `no_sense`, `bad_rhyme`, `off_flow`, `off_topic`, `too_copied`, `cringe`.
- "Import ratings" re-loads an export so I can continue on another device; cards already rated are marked as done.
- A "Clear all" button with a confirm dialog.

## Look and feel

- Dark by default with a light-mode toggle; respect `prefers-color-scheme`. Define colors as CSS variables.
- Feels like a tool for a producer in the studio, not a SaaS dashboard: minimal chrome, big lyric text (~22px desktop, ~18px phone), generous line height, one accent color.
- Works at 375px wide with no horizontal scroll; big tap targets (min 48px).
- Empty state: a big drop zone that says "Drop model_comparison.json files here".

## Quality bar

- Escape all text from the JSON before inserting into the DOM (no innerHTML with raw strings).
- No console errors. Test with: 0 files, 1 file, 3 files, the same file twice, a model with empty `bars`, a bar with no comma (`halves` has 1 item).
- Give me the complete `index.html` in one code block, then a short list of the keyboard shortcuts you chose.

## Handoff protocol (every reply, no exceptions)

I save your code to `tools/style-profile/rater/index.html` and paste your handoff entry into `tools/style-profile/rater/GROK_HANDOFF.md`, which Claude Code reads before touching anything on the pipeline side.

1. Whenever you change code, always send the COMPLETE `index.html` again, never a partial diff, so I can overwrite the file.
2. End EVERY reply with one fenced markdown block, exactly in this shape (fill every field; write "none" if empty):

````markdown
### HANDOFF ENTRY: <short title> (<YYYY-MM-DD>, Grok, page version vN)

**Status:** <working / partly working / broken: one line>
**What changed this round:** <bullets>
**Contract changes:** <any difference from the export schema, field names, reason codes, bar_id format, or input handling in the spec. "none" if fully compliant>
**Known bugs / not done yet:** <bullets>
**Questions for Claude:** <anything you need from the pipeline side: data fields you wish existed, ambiguities in the JSON>
**What Samuel asked for this round:** <one-line summary of my last message>
````

3. Bump the page version (v1, v2, …) every time you send new code, and show it in a small footer in the page itself so I can tell which version is saved.
4. If I paste a message that starts with `FROM CLAUDE:`, treat it as instructions from the pipeline maintainer: apply it, and answer it in the next handoff entry.
5. If I say `handoff`, reply with only a full-summary HANDOFF ENTRY covering the whole conversation so far.
