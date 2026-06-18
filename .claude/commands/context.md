---
description: Load full context about my life, work, and current state from the Obsidian vault
argument-hint: [optional focus area]
---

Load a complete picture of who I am and where I currently stand, so the rest of
this session needs no re-explaining. Focus area (optional): $ARGUMENTS

## Vault access

Prefer the Obsidian CLI (see the `obsidian-cli` skill: `obsidian read`,
`obsidian search`, `obsidian backlinks`, `obsidian daily:read`, ...) — it sees
the link graph, not just files. If the CLI is unavailable (Obsidian not
running), fall back to Glob/Grep/Read over the vault folder. If you cannot
locate a vault at all (no `.obsidian/` directory in or near the working
directory, and `obsidian vaults` fails), ask me for the vault path before
doing anything else.

## What to read

1. **Core context files** — look for a vault README/Index, `CLAUDE.md`, and any
   files whose names contain `context` (e.g. project working-context files,
   personal workflow context). Read them fully.
2. **Recent daily notes** — the last 7 days (`obsidian daily:read` for today;
   date-named files like `YYYY-MM-DD.md` for prior days).
3. **One hop of backlinks** — for each core context file, follow its links and
   backlinks (`obsidian backlinks path="..."`) and skim the connected notes
   for anything that changes the current picture.
4. If a focus area was given, additionally `obsidian search` for it and read
   the top matches.

## What to produce

A compact briefing, then stand by for whatever I ask next:

- **Current state** — what's actively in motion right now, in one paragraph.
- **Projects** — each active project: one line on where it stands and what's next.
- **Open questions / hypotheses** — anything I'm explicitly weighing, with my
  stated confidence where noted.
- **Recent signal** — what the last week of daily notes says I'm actually
  thinking about (which may differ from the project list).
- **Gaps** — context files that look stale (old dates, contradicted by recent
  daily notes), so I know what to update.

**Read-only**: never create, edit, or delete vault files. Keep the briefing
under a page — this is preload, not the task itself.
