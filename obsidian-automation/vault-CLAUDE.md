# Vault conventions

<!-- This file lives in the vault root as CLAUDE.md. The thinking-tool
     commands (/today, /ideas, /trace, ...) read it before anything else.
     Replace every [bracketed placeholder] with your reality — a wrong
     convention here is worse than none. Delete sections that don't apply. -->

## Layout

- **Daily notes**: `[Daily/]YYYY-MM-DD.md` <!-- match Settings → Daily notes -->
- **Projects**: `[Projects/]` — one note per active project
- **People**: `[People/]` — one note per person
- **Context files**: files matching `*context*` describe the current state of
  my life and projects; treat them as the freshest summary of intent.
- **Clippings**: `[Clippings/]` — saved external content; my one-line
  annotation and links on a clip are the part that's mine.
- **Agent area**: `_agent/` — the only place agents may write (see rules).
  Known artifacts: `_agent/Home.md` (landing page, rebuilt by /home),
  `_agent/briefings/` (scheduled command output), `_agent/digests/`
  (per-topic clipping digests from /digest).

## Rules for agents

1. **This vault is human-written.** Never create, edit, or delete notes
   outside `_agent/` unless I explicitly approve it in the conversation
   (the `/graduate` command's approval step counts). Never modify daily
   notes or this file.
2. **Output goes to chat, or to `_agent/briefings/`** when running
   headlessly. Anything you write must carry `source: agent` frontmatter.
3. **Quote me, cite the file and date.** Findings grounded in my actual
   writing; no paraphrase-only claims.
4. Notes inside `_agent/` are *your* writing, not mine — when analyzing my
   thinking (/ghost, /drift, /trace, /emerge...), exclude `_agent/` so you
   don't detect patterns in your own output.

## My conventions

<!-- Keep only what's true, add your own. -->

- Every note carries `source:` frontmatter when it isn't my own writing:
  `me` (default — my thinking), `agent` (AI-written or AI-conversation
  derived), `clip` (saved external content). Pattern analysis (/ghost,
  /drift, /emerge, /trace) reads `me` as my thinking, treats `clip` as
  interest-signal only, and uses `agent` for project state only.
- Ideas worth developing get tagged `#idea` in daily notes.
- Hypotheses are written with a confidence marker, e.g.
  `hypothesis: ... (confidence: 6/10)`.
- Recurring themes get their own note and are linked as `[[theme name]]`
  rather than left as plain text.
- Tasks use `- [ ]` checkboxes; unfinished tasks carry over to the next
  daily note.

## This machine

- Calendar access: `[icalBuddy eventsToday | gcalcli agenda | none]`
- Obsidian CLI: enabled in Settings → Command line interface; the app must
  be running for `obsidian` commands to work.
