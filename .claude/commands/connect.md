---
description: Bridge two domains using the vault's link graph — find the hidden connections between them
argument-hint: <domain A> <domain B>
---

Find the bridges between the two domains given in: $ARGUMENTS

Parse the two domains from the arguments (e.g. "filmmaking worldbuilding" or
"shawarma and startups"). If fewer than two are given, ask and stop.

## Vault access

Prefer the Obsidian CLI (see the `obsidian-cli` skill); fall back to
Glob/Grep/Read over the vault folder if Obsidian isn't running. If no vault
can be located, ask me for the path first.

## Method

1. **Map each neighborhood** — for each domain: find its core notes
   (`obsidian search`), then expand one or two hops via `obsidian backlinks`
   and `obsidian links` to collect the surrounding notes. Include each
   domain's vocabulary as I actually use it.
2. **Find the bridges** — look for:
   - **Shared neighbors** — notes linked from both neighborhoods.
   - **Conceptual rhymes** — the same structure or move described in both
     domains under different words (this is where the real finds live).
   - **Shared people, projects, or sources** appearing on both sides.
3. Rank bridges by surprise × support: prefer connections that are genuinely
   non-obvious but well-evidenced in my own writing. Discard generic
   connections that would be true of anyone's notes.

## Output

- **Notes in [domain A]'s neighborhood** — the relevant notes, one line each.
- **Notes in [domain B]'s neighborhood** — same.
- **Bridges** — 2–5, strongest first. For each:
  - A name for the bridge (one line).
  - The connection explained through *my own writing* — short quotes from
    both sides showing the two domains making the same move.
  - What it suggests: a note worth writing, a project angle, or a question.

**Read-only**: never create, edit, or delete vault files.
