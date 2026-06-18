---
description: Regenerate the vault landing page — today, recent daily notes, recurring ideas, opportunities, digests by topic
---

Rebuild `_agent/Home.md`, my landing page. When I open the vault, this one
note should tell me where I am: what today holds, what I've been thinking,
what's recurring, and what's worth pursuing.

## Vault access

Prefer the Obsidian CLI (see the `obsidian-cli` skill); fall back to
Glob/Grep/Read over the vault folder if Obsidian isn't running. If no vault
can be located, ask me for the path first.

## Speed rule

This runs daily — stay cheap. Prefer *assembling from existing artifacts*
(briefings, digests, context files) over re-analyzing the vault. The only
fresh analysis allowed is the small recurring-ideas scan below.

## Build these sections

1. **Today** — date header. If `_agent/briefings/<today>-today.md` exists,
   pull its top priorities; otherwise summarize today's daily note
   (`obsidian daily:read`) and count open tasks. Link the daily note.
2. **This week** — `[[links]]` to the last 7 daily notes, one line each on
   what it contains (skim, don't deep-read).
3. **Recurring right now** — scan the last 14 days of daily notes for 3–5
   themes that keep coming back. One line each + links to where they
   appear. (Capped: this is a pulse-check, not /emerge.)
4. **Opportunities** — top items from the newest `_agent/briefings/*-ideas.md`
   and `*-drift.md`, with a link to the full briefing. If none exist yet,
   say "run /ideas" rather than improvising.
5. **Digests by topic** — link every `_agent/digests/*.md` with its
   `updated:` date, so I can jump straight into coding / business /
   creative mode. Note any clippings folder activity newer than the newest
   digest ("new clips since last digest — run /digest").
6. **Active projects** — one line per `*context*` file: project, current
   state, next step. Link each.
7. Footer — `generated: <timestamp>` and `source: agent` in frontmatter.

## Rules

- Writes are confined to `_agent/Home.md` (overwrite it fully — this file
  is agent-owned). Never modify anything else.
- Everything links: this page is for *navigating into* the vault, so every
  item should be a `[[wikilink]]` where one exists.
- Keep the whole page under ~80 lines — a lobby, not a report.

Finish with one line in chat: "Home refreshed" plus anything that needs my
attention today.
