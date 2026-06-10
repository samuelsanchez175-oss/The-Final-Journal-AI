# Obsidian Thinking-Tool Commands

Slash commands (in `.claude/commands/`) for using Claude Code + an Obsidian
vault as a thinking partner — Internet Vin's workflow from The Startup Ideas
Podcast episode "How I Use Obsidian + Claude Code to Run My Life"
(https://www.youtube.com/watch?v=6MBq1paspVU).

Definitions follow the episode's official codebook ("The Obsidian + Claude
Code Codebook — 12 commands to build for your second brain", from the show
notes) plus the richer behavior Vin demonstrated live on screen. Vin never
published his actual command files; the codebook provides one-line prompts
and these implementations expand them into full commands.

## Prerequisites

- An Obsidian vault (a folder of markdown files, ideally with `[[wikilinks]]`).
- Best with the **Obsidian CLI** (Obsidian v1.12+, CLI enabled in Settings)
  and the `obsidian-cli` skill in `.claude/skills/` — this gives the commands
  the vault's *link graph* (backlinks, orphans, unresolved links), not just
  file contents. Every command degrades gracefully to plain filesystem reads
  when the CLI isn't available.
- Run Claude Code inside (or pointed at) the vault. If no vault is found, the
  commands ask for its path.

## The 12 commands

| Command | What it does |
|---|---|
| `/context` | Loads your full life and work state before a session — projects, priorities, current focus |
| `/today` | Morning review — calendar, tasks, recent daily notes → prioritized plan |
| `/trace <idea>` | Tracks how one idea evolved over time: first appearance, phases, pivots, current edge |
| `/connect <A> <B>` | Bridges two domains using the vault's link graph |
| `/ghost <question>` | Answers a question the way *you* would, in your voice, then rates its own fidelity |
| `/challenge <belief>` | Pressure-tests a belief with your own history: contradictions, counter-evidence, assumptions |
| `/ideas` | Deep vault scan + graph analysis → idea report (tools to build, people to meet, things to write...) |
| `/graduate` | Promotes ideas buried in daily notes into standalone notes — with your approval per note |
| `/closeday` | End-of-day processing — progress, learnings, action items, connections, hypothesis check |
| `/drift` | Stated intentions vs. actual behavior over 30–60 days — what you're avoiding and drifting toward |
| `/emerge` | Surfaces what the vault implies but never states; clusters ready to become projects |
| `/schedule [request]` | Evaluates a meeting request — or plans the week — against calendar *and* vault priorities |

## The rules these commands follow

1. **The vault is human-written.** Vin's strict separation: the agent reads
   the vault but never writes into it. Every command is read-only and
   delivers output in chat — except `/graduate`, which creates new standalone
   notes only after you approve each one (marked `source: graduate` in
   frontmatter), and never edits existing notes.
2. **Quote, don't paraphrase.** Findings are grounded in your actual writing,
   with file names and dates, so you can verify every claim.
3. **Slow is expected.** These commands read a lot of files. That's the point
   — the quality of context determines the quality of output.

## Notes

- Claude Code has a built-in `/context` command (context-window usage). If it
  shadows the project command in your version, pick the `(project)` variant
  from the command picker or rename `context.md` (e.g. to `prime.md`).
- `/today` and `/schedule` read your calendar best-effort (`icalBuddy`,
  `gcalcli`, or a calendar MCP tool) and degrade gracefully without one.
