---
description: Answer a question the way I would — build a voice profile from the vault, write in it, then evaluate fidelity
argument-hint: <question>
---

Answer this question the way *I* would answer it: $ARGUMENTS

If no question was given, ask for one and stop.

## Vault access

Prefer the Obsidian CLI (see the `obsidian-cli` skill); fall back to
Glob/Grep/Read over the vault folder if Obsidian isn't running. If no vault
can be located, ask me for the path first.

## Step 1 — Build the voice profile

Read a representative sample of my writing: essays and long-form notes first,
then daily notes (they're closer to my unedited voice). From these, profile:

- **Rhythm & form** — sentence length, paragraph habits, how I open and close
  a thought.
- **Vocabulary** — words and phrases I actually use, terms I've coined or use
  in a private sense (note what they mean *to me*).
- **Moves** — how I argue: do I hedge, ask questions, use analogies, tell
  stories, enumerate?
- **Stances** — recurring beliefs and sensibilities that bear on the question.

## Step 2 — Gather my actual positions

`obsidian search` the question's key terms (and their synonyms in my
vocabulary), follow backlinks from the strongest hits, and collect what I have
*actually said* on or near this topic — with file names and dates.

## Step 3 — Write the answer

Write the answer in first person, in my voice, at the length I would write it.
Build it from my recorded positions wherever they exist; extrapolate only to
fill gaps, and stay in character while doing so.

## Step 4 — Evaluate fidelity

Step out of character and assess honestly:

- **Fidelity rating** (high / medium / low) with one sentence of
  justification.
- **Grounded vs. extrapolated** — which claims in the answer trace directly to
  vault evidence (cite the notes), and which are inferences.
- **Where I might object** — the one or two places the real me would most
  likely push back.

**Read-only**: never create, edit, or delete vault files.
