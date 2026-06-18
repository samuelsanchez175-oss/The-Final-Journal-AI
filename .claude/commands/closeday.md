---
description: End-of-day processing — progress, learnings, action items, vault connections, hypothesis check
---

Process the end of my day against the vault. The counterpart to /today.

## Vault access

Prefer the Obsidian CLI (see the `obsidian-cli` skill); fall back to
Glob/Grep/Read over the vault folder if Obsidian isn't running. If no vault
can be located, ask me for the path first.

## Gather

1. **Today's daily note** — `obsidian daily:read`. This is the primary source.
2. **Anything touched today** — `obsidian recents` if available, otherwise
   files modified today (`find <vault> -name "*.md" -mtime 0`).
3. **Hypotheses / confidence markers** — search the vault for notes where I
   state hypotheses with confidence levels (look for "hypothesis",
   "confidence", "I believe", "I'm not sure", and any rating conventions you
   find in context files).

## Produce

- **Progress** — what I actually worked on and moved forward today, in a few
  lines. Note anything I finished outright.
- **What surfaced** — new ideas, learnings, or observations that came up in
  today's writing and deserve to be remembered.
- **Action items** — every commitment, todo, or "I should" buried in today's
  notes, as a clean checklist I can paste into tomorrow's note. Distinguish
  *explicit* tasks from *implied* ones, and mark which are carry-overs from
  earlier days.
- **Connections surfaced** — for the main things I wrote about today, what
  existing vault notes relate (`obsidian search` + `obsidian backlinks`)?
  Name 2–4 connections worth making, each with the note it would link to and
  why. Suggest the `[[wikilink]]` — but do not add it yourself.
- **Confidence check** — which hypotheses did today's events bear on? For
  each: the hypothesis, its current stated confidence, what today added
  (supporting or contradicting, with the evidence), and whether the marker
  needs updating up or down.
- **Loose thread** — one open question from today worth sleeping on, stated
  in a single sentence.

**Read-only**: never create, edit, or delete vault files. Everything above is
delivered in chat for me to carry into the vault myself.
