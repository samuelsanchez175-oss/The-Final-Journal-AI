---
description: Map my stated priorities to actual time — plan the week, or evaluate a specific meeting request against calendar and vault
argument-hint: [meeting request, e.g. "call with Alex Thursday 2pm" — omit to plan the week]
---

Help me allocate my time in line with what the vault says actually matters.
Request: $ARGUMENTS

Two modes:

- **With arguments** — evaluate that specific scheduling request (a meeting,
  a call, a block).
- **Without arguments** — suggest how to allocate the coming week.

## Vault access

Prefer the Obsidian CLI (see the `obsidian-cli` skill); fall back to
Glob/Grep/Read over the vault folder if Obsidian isn't running. If no vault
can be located, ask me for the path first.

## Gather

1. **Calendar** — best effort: `icalBuddy` (macOS), `gcalcli`, or a calendar
   MCP tool. If unavailable, say so in one line and work from the vault's
   record of commitments.
2. **Current priorities** — project context files and the last two weeks of
   daily notes: what I've said matters right now.
3. **Scheduling conventions** — any structure the vault reveals (e.g. a
   day-per-domain rule, protected deep-work blocks, energy patterns I've
   written about). Honor these in recommendations.
4. **For a specific request** — also read the vault's notes on the person or
   topic (`obsidian search` + backlinks): existing relationship, open
   threads, and whether we already have a touchpoint coming.

## Mode A — evaluate a request

Weigh the request against the day's existing load, my conventions, and the
vault context, then give a clear verdict:

- **The verdict** — yes / no / alternative, in one sentence.
- **The reasoning** — what the day already holds, what the vault says about
  this person or topic, and whether the meeting is needed at all (an
  existing touchpoint may already cover it — say so).
- **The alternative** — if declining or deferring: a better slot, or a
  no-meeting path (async note, agenda addition to an existing session).

## Mode B — plan the week

- **The week's shape** — proposed allocation of available time across
  current priorities, respecting my conventions.
- **Conflicts flagged** — where existing commitments contradict stated
  priorities: name each mismatch plainly ("you say X is the priority;
  the calendar gives it 0 hours").
- **One protection** — the single block most worth defending this week, and
  from what.

**Read-only**: never create, edit, or delete vault files, and never modify
the calendar — recommendations only.
