---
description: Morning review — pull calendar, tasks, and the past week of daily notes into a prioritized plan
argument-hint: [optional constraints, e.g. "only until 2pm"]
---

Build my prioritized plan for today. Constraints (optional): $ARGUMENTS

## Vault access

Prefer the Obsidian CLI (see the `obsidian-cli` skill); fall back to
Glob/Grep/Read over the vault folder if Obsidian isn't running. If no vault
can be located, ask me for the path first.

## Gather (in parallel where possible)

1. **Today's daily note** — `obsidian daily:read` (it may already contain a
   plan or carried-over items).
2. **Open tasks** — `obsidian tasks | grep "\[ \]"`, plus tasks in the last 7
   daily notes that were never checked off.
3. **The past week of daily notes** — what themes, worries, and threads
   actually dominated my writing.
4. **Calendar** — best effort: try `icalBuddy eventsToday` (macOS), `gcalcli
   agenda`, or a calendar MCP tool if one is available. If none work, say so
   in one line and continue without it.
5. **Current project context files** — skim any `*context*` files for stated
   priorities.

## The cross-examination

Don't just merge lists — compare them. Does my calendar reflect what my daily
notes say I actually care about right now? If today's schedule is full of
things my writing never mentions, or my writing keeps circling something the
calendar has no room for, name that mismatch explicitly.

## Output

- **Top 3 priorities** — each with *why now*, grounded in a task, commitment,
  or daily-note thread (cite the note/date).
- **Time-sensitive** — meetings and deadlines, with any prep each needs.
- **Quick wins** — small items (< 15 min) worth batching.
- **Defer or drop** — what I should consciously *not* do today, and why.
- **Mismatch check** — one honest sentence: where today's calendar and my
  actual current thinking disagree.

**Read-only**: never create, edit, or delete vault files. Present the plan in
chat; I'll move what I want into the daily note myself.
