"""Turn retrieve hits into highlight spans for the scorecard."""

from __future__ import annotations

import re

from metaphors import imagery_words
from retrieve import Hit

WORD_RE = re.compile(r"[A-Za-z0-9']+", re.I)


def _span_for(line: str, word: str, kind: str, pair: str = "") -> dict | None:
    if not word:
        return None
    m = re.search(rf"\b{re.escape(word)}\b", line, re.I)
    if not m:
        m = re.search(re.escape(word), line, re.I)
    if not m:
        return None
    return {
        "text": m.group(0),
        "start": m.start(),
        "end": m.end(),
        "kind": kind,
        "pair": pair,
    }


def annotate_hit(hit: Hit) -> Hit:
    spans: list[dict] = []
    if hit.end_word and hit.rhyme:
        kind = "rhyme.perfect" if hit.rhyme == "perfect" else "rhyme.slant"
        sp = _span_for(hit.line, hit.end_word, kind, hit.rhyme_pair)
        if sp:
            spans.append(sp)
    covered = {(s["start"], s["end"]) for s in spans}
    for img in imagery_words(hit.line):
        if hit.end_word and img.lower() == hit.end_word.lower():
            continue
        sp = _span_for(hit.line, img, "imagery")
        if sp and (sp["start"], sp["end"]) not in covered:
            spans.append(sp)
            covered.add((sp["start"], sp["end"]))
    for word in hit.stress_words:
        if hit.end_word and word.lower() == hit.end_word.lower():
            continue
        sp = _span_for(hit.line, word, "stress")
        if sp and (sp["start"], sp["end"]) not in covered:
            spans.append(sp)
            covered.add((sp["start"], sp["end"]))
    hit.spans = spans
    return hit


def annotate_query(line: str, end_word: str, stress_words: list[str] | None = None) -> list[dict]:
    spans: list[dict] = []
    if end_word:
        sp = _span_for(line, end_word, "rhyme.perfect", end_word)
        if sp:
            spans.append(sp)
    covered = {(s["start"], s["end"]) for s in spans}
    for img in imagery_words(line):
        if end_word and img.lower() == end_word.lower():
            continue
        sp = _span_for(line, img, "imagery")
        if sp and (sp["start"], sp["end"]) not in covered:
            spans.append(sp)
            covered.add((sp["start"], sp["end"]))
    for word in stress_words or []:
        if end_word and word.lower() == end_word.lower():
            continue
        sp = _span_for(line, word, "stress")
        if sp and (sp["start"], sp["end"]) not in covered:
            spans.append(sp)
            covered.add((sp["start"], sp["end"]))
    return spans


def annotate_bundle(bundle: dict) -> dict:
    q = bundle["query"]
    q["spans"] = annotate_query(q["line"], q.get("end_word") or "", q.get("stress_words") or [])
    for key in ("wrap", "replace", "next", "nearby", "picture", "roster", "gen_replace", "gen_next"):
        if key in bundle:
            bundle[key] = [annotate_hit(h) for h in bundle[key]]
    return bundle
