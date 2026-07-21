---
description: Track how an idea has evolved over time across the vault — first appearance, phases, pivots, current edge
argument-hint: <topic or idea>
---

Trace how this idea has evolved across my vault: $ARGUMENTS

If no topic was given, ask for one and stop.

## Vault access

Prefer the Obsidian CLI (see the `obsidian-cli` skill); fall back to
Glob/Grep/Read over the vault folder if Obsidian isn't running. If no vault
can be located, ask me for the path first.

## Method

1. **Build a vocabulary map** — the idea won't always appear under one name.
   From an initial search, collect the synonyms, related terms, project
   names, and private vocabulary I use around this idea. Search all of them.
2. **Sweep the vault** — `obsidian search` each term; follow backlinks from
   the strongest hits (`obsidian backlinks`) to find related notes that don't
   use the words at all. Include daily notes, essays, and project files.
3. **Order chronologically** — date each mention from daily-note dates,
   frontmatter, or file metadata. Note anything *pre-dating* the vault that
   the record references (essays, older systems) as baseline.

## Output — the full evolution

- **Header** — when the idea first appeared, total time span, number of
  notes involved.
- **Phases** — segment the history into named phases (e.g. "baseline",
  "discovery and skepticism", "the pivotal realization", "explosive
  building"), each with a date range and 2–4 short *quotes from my own
  writing* that capture where my head was. Let the quotes carry the story;
  connect them with minimal narration.
- **Pivots** — the specific notes where the thinking visibly turned, and
  what changed.
- **Where it stands now** — the current state of the idea and what it's
  connected to today (current backlink neighborhood).
- **The edge** — one paragraph: where the thinking is pushing next, and the
  current friction. What is the record straining toward?

**Read-only**: never create, edit, or delete vault files.
