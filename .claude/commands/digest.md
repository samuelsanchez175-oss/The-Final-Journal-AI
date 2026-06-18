---
description: Digest clippings by topic — cluster what I've saved, connect it to active projects, tell me what to bite down on
argument-hint: [topic, e.g. coding | business | creative — omit to triage all new clippings]
---

Turn my clippings into a digest I can actually act on. Topic: $ARGUMENTS

Two modes:

- **With a topic** — rebuild/update that topic's digest (e.g. coding,
  business, creative/art, or anything I name).
- **Without a topic** — triage mode: find clippings not yet covered by any
  digest, group them by topic, and update each affected topic digest.

## Vault access

Prefer the Obsidian CLI (see the `obsidian-cli` skill); fall back to
Glob/Grep/Read over the vault folder if Obsidian isn't running. If no vault
can be located, ask me for the path first. Check the vault's `CLAUDE.md` for
where clippings live (default: `Clippings/`, plus `Ideas/`); notes with
`source: clip` frontmatter count regardless of folder.

## Gather

1. **The clippings** for the topic (or all undigested ones in triage mode).
   A clip is *other people's writing* — my one-line annotation and any
   `[[links]]` on it are the part that's mine; weight those heavily.
2. **Existing digests** — `_agent/digests/*.md`. Each digest ends with an
   "Already digested" index; anything not listed there is new.
3. **My current state** — `*context*` files and the last two weeks of daily
   notes, so relevance means *relevant to what I'm doing now*, not generic.

## Write the digest

Maintain **one rolling file per topic**: `_agent/digests/<topic>.md`
(lowercase, hyphenated). This command owns these files — create or update
them freely, with frontmatter `source: agent` and `updated: <date>`.

Structure:

- **New since last digest** — the freshly added clips, one line each: what
  it is, why I saved it (my annotation if present, inferred otherwise —
  marked as inferred), `[[link]]` to the clip.
- **The threads** — cluster the topic's clips into 2–5 named threads. For
  each: what the cluster is circling, which active project or stated goal
  it feeds (cite the context file or daily note), and the single best clip
  to start from.
- **Bite down next** — the top 3 items across the topic, ranked by
  relevance to current projects × how often I keep clipping the same idea.
  Each with a concrete first action (read X, prototype Y, write a note
  naming Z).
- **Going stale** — clips saved long ago, never linked, never re-touched:
  candidates to act on or consciously drop.
- **Already digested** — the full index: every clip this digest covers, as
  `[[links]]`. This doubles as state for the next run.

## Rules

- Writes are confined to `_agent/digests/`. Never modify the clippings
  themselves, daily notes, or anything else.
- Clips are interest-signal, not my thinking — never treat clipped text as
  my opinion (that distinction matters to /ghost, /drift, /emerge).
- End with a one-line summary in chat per digest updated.
