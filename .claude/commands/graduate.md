---
description: Extract undeveloped ideas from recent daily notes and promote the best into standalone notes
argument-hint: [days to scan, default 14]
---

Ideas, insights, and original thinking accumulate in my daily notes but
rarely graduate into standalone notes where they can compound through
backlinks. Scan recent daily notes, surface the best candidates, and help me
promote them. Days to scan (default 14): $ARGUMENTS

This is the one command in this suite allowed to write into the vault — but
only new standalone notes, only after I approve each one. Never edit
existing notes, and never alter the daily notes themselves.

## Vault access

Use the Obsidian CLI (see the `obsidian-cli` skill); fall back to
Glob/Grep/Read plus direct file writes to the vault folder if Obsidian isn't
running. If no vault can be located, ask me for the path first.

## Step 1 — Scan

Read the daily notes from the scan window. Collect candidate ideas: anything
tagged `#idea`, plus untagged original thinking — claims, theories, named
patterns, "what if" passages — that goes beyond logging events.

## Step 2 — Cross-reference

For each candidate, check the existing vault (`obsidian search`,
`obsidian unresolved`): Does a note on this already exist? Would the idea
extend an existing note rather than start a new one? Is it an unresolved
link I've already been pointing at — named but never written?

## Step 3 — Present candidates

Show the candidates, best first, each with:

- The idea in one sentence.
- Where it appeared (daily note dates; quote the key passage).
- Recommendation: **create standalone note** / **belongs in existing note
  [[X]]** (say what to add) / **dismiss** (say why — duplicate, logging, not
  load-bearing).

Then **stop and wait** for me to choose which to graduate.

## Step 4 — Graduate the approved ones

For each idea I approve for a standalone note, create the note in the vault
root (`obsidian create` or direct write):

- Title: the idea's name.
- Body: a working document that captures the **core claim or question** in
  the first lines, the **context** from the daily note(s) where it
  originated (with dates), and **connections** — `[[wikilinks]]` to the
  related existing notes found in step 2, each with a phrase on the
  relationship.
- Frontmatter: `created` date and `source: graduate`, so agent-written notes
  remain distinguishable from mine.

For ideas marked "belongs in existing note", give me the exact text to add —
but let me add it myself.

Finish with a one-line summary per created note.
