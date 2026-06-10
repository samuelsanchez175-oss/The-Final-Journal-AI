# Obsidian Command Automation

Scheduled, headless runs of the thinking-tool commands
(see `docs/obsidian-commands.md`), with briefings saved into your vault.

## What you get

| Job | Schedule | Output |
|---|---|---|
| `today` | daily 07:00 | `_agent/briefings/YYYY-MM-DD-today.md` |
| `ideas` | Sundays 17:00 | `..-ideas.md` |
| `closeday` | daily 21:30 *(opt-in)* | `..-closeday.md` |
| `drift` | Mondays 08:00, even ISO weeks *(opt-in)* | `..-drift.md` |
| `graduate` | Saturdays 10:00, report-only *(opt-in)* | `..-graduate.md` |

Default install enables only `today` + `ideas` — start there; add the rest
once you're reliably reading those two. The interactive commands (`/ghost`,
`/challenge`, `/trace`, `/connect`, `/context`, `/schedule`) are not
schedulable on purpose: they need you.

## Prerequisites

- macOS (uses launchd; Linux: call `run-command.sh` from cron, see below)
- Claude Code CLI installed and authenticated (`claude` on PATH)
- Obsidian v1.12+ with the CLI enabled (Settings → Command line interface).
  The runner starts Obsidian in the background if it isn't running; without
  it, commands fall back to plain file reads (no link graph).

## Install

```bash
cd obsidian-automation
./install.sh ~/path/to/your-vault            # enables today + ideas
# or pick jobs explicitly:
./install.sh ~/path/to/your-vault today ideas closeday drift graduate
```

The installer also:

- writes `~/.config/obsidian-commands/config` (vault path + options)
- copies the slash commands and the `obsidian-cli` skill to `~/.claude/` so
  headless runs find them from any directory
- seeds `<vault>/CLAUDE.md` from `vault-CLAUDE.md` if missing —
  **edit its placeholders**, the commands trust what it says
- creates `<vault>/_agent/briefings/`

Test immediately without waiting for the schedule:

```bash
./run-command.sh today            # real run
./run-command.sh today --dry-run  # show what would happen
```

## How it stays safe

- Headless runs use a **read-only tool allowlist** (vault reads, the
  `obsidian` CLI, calendar helpers). No write tools are granted.
- `/graduate` halts at its approval step in print mode, so the Saturday job
  produces a candidates report; promoting notes stays an interactive act.
- Briefings carry `source: agent` frontmatter and live only in `_agent/`,
  keeping the human-written vault rule intact.

## Cost & tuning

Every run spends tokens; `/ideas` is deliberately the heavy one. To run the
dailies on a cheaper model, add to `~/.config/obsidian-commands/config`:

```bash
CLAUDE_EXTRA_ARGS="--model haiku"
```

Reschedule by editing the times in `install.sh` and re-running it (it
reloads existing jobs safely). Logs: `~/Library/Logs/obsidian-commands/`.

## Uninstall

```bash
./uninstall.sh   # removes the launchd jobs; config and briefings remain
```

## Linux / cron equivalent

```cron
0 7 * * *  /path/to/repo/obsidian-automation/run-command.sh today
0 17 * * 0 /path/to/repo/obsidian-automation/run-command.sh ideas
```
