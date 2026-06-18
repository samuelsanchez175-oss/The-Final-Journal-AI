# Obsidian Command Automation

Scheduled, headless runs of the thinking-tool commands
(see `docs/obsidian-commands.md`), with output saved into your vault.

## What you get

| Job | Schedule | Output |
|---|---|---|
| `today` | daily 07:00 | `_agent/briefings/YYYY-MM-DD-today.md` |
| `home` | daily 07:15 | `_agent/Home.md` — the landing page, rebuilt |
| `ideas` | Sundays 17:00 | `..-ideas.md` |
| `closeday` | daily 21:30 *(opt-in)* | `..-closeday.md` |
| `drift` | Mondays 08:00, even ISO weeks *(opt-in)* | `..-drift.md` |
| `digest` | Fridays 16:00, triage mode *(opt-in)* | `_agent/digests/<topic>.md` |
| `graduate` | Saturdays 10:00, report-only *(opt-in)* | `..-graduate.md` |

Default install enables `today` + `ideas` + `home` — start there; add the
rest once you're reliably reading those. The interactive commands (`/ghost`,
`/challenge`, `/trace`, `/connect`, `/context`, `/schedule`) are not
schedulable on purpose: they need you.

## The landing page

`/home` maintains `_agent/Home.md`: today's plan, the week's daily notes,
recurring ideas, opportunities from the latest briefings, digests by topic,
and active projects — all as wikilinks. To make it your "log in" screen,
install the community **Homepage** plugin and point it at `_agent/Home.md`
(or just pin the note). Run `/digest coding` (or `business`, `creative`, any
topic) to build the per-topic clipping digests it links to.

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
  `obsidian` CLI, calendar helpers). Only the `home` and `digest` jobs get
  write access, scoped to `_agent/**`.
- `/graduate` halts at its approval step in print mode, so the Saturday job
  produces a candidates report; promoting notes stays an interactive act.
- Agent output carries `source: agent` frontmatter and lives only in
  `_agent/`, keeping the human-written vault rule intact.

## Merging vaults

If you're consolidating several vaults into one (recommended for the
thinking commands — one vault, one link graph), `merge-vaults.sh` copies
source vaults into subfolders of a target vault and reports wikilink name
collisions first. Dry-run by default:

```bash
./merge-vaults.sh ~/Vaults/Main ~/Vaults/OB:Projects ~/Vaults/Alamo:Clippings
# review the collision report, rename as needed, then:
./merge-vaults.sh ~/Vaults/Main ~/Vaults/OB:Projects ~/Vaults/Alamo:Clippings --apply
```

Sources are never modified. `.obsidian/` settings are not copied — the
target vault's settings win.

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
