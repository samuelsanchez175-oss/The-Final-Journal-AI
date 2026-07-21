---
description: Deep vault scan with cross-domain pattern detection and graph analysis — generate actionable ideas across all domains
argument-hint: [optional domain to weight toward]
---

Run a comprehensive idea generation pass over my vault. Optional focus:
$ARGUMENTS

This is the slow command — it reads a lot. That's the point. Gather in
parallel where possible.

## Vault access

Prefer the Obsidian CLI (see the `obsidian-cli` skill); fall back to
Glob/Grep/Read over the vault folder if Obsidian isn't running. If no vault
can be located, ask me for the path first.

## Gather

1. **Graph structure** — `obsidian orphans` (isolated intellectual
   investment), `obsidian deadends`, `obsidian unresolved` (notes I keep
   linking to but never wrote — latent interests), `obsidian tags counts
   sort=count` (where attention pools).
2. **The last 30 days of daily notes** — read them. This is the freshest
   signal of what I actually care about.
3. **Project context files** — every `*context*` file and active project
   note: current state, hypotheses, stated needs.
4. **Cross-domain patterns** — while reading, track ideas that recur across
   unrelated domains; these seed the best ideas.

## Output — the idea report

Ground every item in the vault: cite the notes or stats that motivated it.
Generic advice that could appear in anyone's report is a defect.

- **Structural highlights** — orphans worth noting (isolated thinking that
  deserves connection), unresolved links that reveal latent interests, and
  1–2 hidden relationships in the graph.
- **What's working** — patterns in the record that are visibly producing
  results; name them so I keep doing them.
- **Tools to build** — specific tools or commands, each with the vault
  evidence for why (e.g. "daily notes contain N untagged ideas that never
  develop → build X").
- **Tools to start using** — things that exist that the record suggests I
  need.
- **Systems to implement** — workflow or process changes implied by
  recurring friction in the notes.
- **Subjects to investigate** — topics the vault is circling that deserve
  deliberate study.
- **Things to write and publish** — essays or posts where my notes already
  contain most of the material.
- **Conversations to have** — actual people from my notes, and what to talk
  about with each.
- **Top 5 — high impact, do now** — the cut: the five items from above with
  the best effort-to-impact ratio, each with its concrete first step.

**Read-only**: never create, edit, or delete vault files. If I want one of
the tool ideas built, I'll ask in a follow-up.
