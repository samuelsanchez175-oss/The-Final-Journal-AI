"""Confirmed-wordplay loader + retrieval index.

Loads only Samuel-approved entries (verdict == KEEP) from:
  - docs/play-on-words/wordplay-index/index.jsonl
  - docs/play-on-words/wordplay-index/index-v2.jsonl
  - docs/play-on-words/confirmed-recheck/recheck.jsonl rows with `by` starting
    with "samuel"

Applies Samuel's rules per tab:
  - sound_flips: needs a real second word/name (heard_as filled, not a tiny echo)
  - double_meanings: both readings live (play field must mention two senses)
  - hidden_references (acronyms etc.): needs a payoff mentioned in play/reason
  - split_names / split_names_brands: brand flips land here

Retrieval index: by (tab, end_rime, artist_lower). Pulls 3–5 examples for a
given prompt (artist, topic, target end-rime).

Reject-rerun-v2.jsonl is NEVER loaded as training examples (count only).
"""
from __future__ import annotations

import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Iterable, Iterator

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent.parent
INDEX = REPO / "docs" / "play-on-words" / "wordplay-index" / "index.jsonl"
INDEX_V2 = REPO / "docs" / "play-on-words" / "wordplay-index" / "index-v2.jsonl"
RECHECK = REPO / "docs" / "play-on-words" / "confirmed-recheck" / "recheck.jsonl"

TABS = ("sound_flips", "double_meanings", "hidden_references",
        "split_names", "punchline_setups")

import sys
sys.path.insert(0, str(HERE.parent))
from lyriclib import load_cmudict, end_rime  # type: ignore

_CMU_PATH = REPO / "XJournal AI" / "cmudict.txt"
_CMU: dict | None = None


def _cmu() -> dict:
    global _CMU
    if _CMU is None:
        _CMU = load_cmudict(_CMU_PATH) if _CMU_PATH.exists() else {}
    return _CMU


_WORD_RE = re.compile(r"[A-Za-z']+")


def _last_word(line: str) -> str:
    words = _WORD_RE.findall(line)
    return words[-1].lower() if words else ""


def _rime(word: str) -> tuple[str, ...]:
    r = end_rime(word, _cmu()) if word else None
    return r or ()


# ---------- Samuel's per-tab rules ----------
def _tab_rules_ok(entry: dict) -> bool:
    """Both wordplay-index schemas supported.
      index.jsonl (older): fields are `bar`, `setup_spans`, `play_spans`,
        `heard_as` (one word), `play_spans[].heard` (full heard phrase).
      index-v2.jsonl (newer): fields are `line`, `setup`, `play`, `heard_as`.
    recheck.jsonl rows look like the older schema plus a `by` provenance.
    """
    tab = (entry.get("tab") or "").lower()
    play = (entry.get("play") or "").lower()
    heard = (entry.get("heard_as") or "").lower().strip()
    setup = (entry.get("setup") or "").lower()
    setup_spans = entry.get("setup_spans") or []
    play_spans = entry.get("play_spans") or []
    play_heard = ""
    if play_spans and isinstance(play_spans, list) and isinstance(play_spans[0], dict):
        play_heard = (play_spans[0].get("heard") or "").lower().strip()

    def _two_senses_from_play() -> bool:
        return any(k in play for k in (" and ", " also ", "both", "double",
                                       " or ", ";"))

    if tab == "sound_flips":
        hint = heard or play_heard
        if not hint:
            return False
        if len(hint) < 2:
            return False
        if setup and hint == setup:
            return False
        return True
    if tab == "double_meanings":
        # index-v2: play field describes two senses explicitly
        if _two_senses_from_play():
            return True
        # index.jsonl: setup_spans AND play_spans both populated, with a heard
        if setup_spans and play_spans and (heard or play_heard):
            return True
        # index.jsonl common case: heard_as names a specific alternate word
        # (not a meta-label like "dual meaning"). Must be short and concrete.
        meta = {"dual meaning", "double meaning", "double entendre",
                "wordplay", "n/a", "none", "two meanings"}
        if heard and heard not in meta and len(heard.split()) <= 4:
            return True
        return False
    if tab == "hidden_references":
        # acronyms etc. — needs a payoff (play field, or heard_as text)
        return bool(play) or bool(heard) or bool(play_heard) or bool((entry.get("reason") or "").strip())
    if tab in ("split_names", "split_names_brands"):
        return bool(play or heard or play_heard)
    if tab == "punchline_setups":
        return bool(play)
    return bool(play) or bool(heard) or bool(play_heard)


# ---------- Loader ----------
def iter_confirmed() -> Iterator[dict]:
    """Yield entries with normalized shape: {artist, song, line, tab, setup,
    play, heard_as, reason, end_word, end_rime, source}."""
    seen_keys = set()

    def push(entry: dict, source: str) -> Iterator[dict]:
        if (entry.get("verdict") or "").upper() != "KEEP":
            return
        if not _tab_rules_ok(entry):
            return
        # support three source schemas
        line = (entry.get("line") or entry.get("bar") or entry.get("key_bar") or "").strip()
        artist = entry.get("artist") or entry.get("key_artist") or ""
        song = entry.get("song") or entry.get("key_song") or ""
        tab = entry.get("tab") or ""
        if not line:
            return
        key = (artist.lower(), song.lower(), line.lower(), tab)
        if key in seen_keys:
            return
        seen_keys.add(key)
        ew = _last_word(line)
        # setup text: fall back to setup_spans text concatenation
        setup = entry.get("setup") or ""
        if not setup and entry.get("setup_spans"):
            setup = " ".join(s.get("text", "") for s in entry["setup_spans"] if isinstance(s, dict))
        # play text: fall back to play_spans heard field
        play = entry.get("play") or ""
        if not play and entry.get("play_spans"):
            heard = " ".join(s.get("heard", "") for s in entry["play_spans"] if isinstance(s, dict))
            flip = " ".join(s.get("text", "") for s in entry["play_spans"] if isinstance(s, dict))
            if heard and flip:
                play = f"{flip} heard as {heard}"
            else:
                play = heard or flip
        yield {
            "artist": artist, "song": song, "line": line,
            "tab": tab, "setup": setup,
            "play": play,
            "heard_as": entry.get("heard_as") or "",
            "reason": entry.get("reason") or "",
            "end_word": ew, "end_rime": _rime(ew),
            "source": source,
        }

    for p, label in ((INDEX, "index"), (INDEX_V2, "index-v2")):
        if not p.exists():
            continue
        for raw in p.read_text().splitlines():
            if not raw.strip():
                continue
            try:
                entry = json.loads(raw)
            except json.JSONDecodeError:
                continue
            yield from push(entry, label)

    if RECHECK.exists():
        for raw in RECHECK.read_text().splitlines():
            if not raw.strip():
                continue
            try:
                entry = json.loads(raw)
            except json.JSONDecodeError:
                continue
            by = (entry.get("by") or "").lower()
            if not by.startswith("samuel"):
                continue
            yield from push(entry, "recheck-samuel")


# ---------- Retrieval index ----------
class WordplayIndex:
    def __init__(self):
        self.entries: list[dict] = []
        self.by_rime: dict[tuple[str, ...], list[int]] = defaultdict(list)
        self.by_tab: dict[str, list[int]] = defaultdict(list)
        self.by_artist: dict[str, list[int]] = defaultdict(list)

    @classmethod
    def build(cls) -> "WordplayIndex":
        idx = cls()
        for e in iter_confirmed():
            i = len(idx.entries)
            idx.entries.append(e)
            if e["end_rime"]:
                idx.by_rime[e["end_rime"]].append(i)
            idx.by_tab[e["tab"]].append(i)
            idx.by_artist[e["artist"].lower()].append(i)
        return idx

    def __len__(self):
        return len(self.entries)

    def retrieve(self, artist: str | None = None,
                 end_word: str | None = None,
                 tabs: Iterable[str] | None = None,
                 k: int = 5) -> list[dict]:
        """Pull up to k confirmed examples, preferring:
          1. same artist + same end-rime
          2. same end-rime, any artist
          3. same tab + same artist
          4. same tab, any artist
          5. same artist
        """
        picks: list[int] = []
        seen: set[int] = set()
        tab_set = set(t.lower() for t in tabs) if tabs else None

        def take(indexes: list[int]):
            for i in indexes:
                if i in seen:
                    continue
                if tab_set and self.entries[i]["tab"].lower() not in tab_set:
                    continue
                picks.append(i); seen.add(i)
                if len(picks) >= k:
                    return True
            return False

        rime = _rime(end_word or "")
        art = (artist or "").lower()

        if rime:
            rime_hits = self.by_rime.get(rime, [])
            if art:
                same = [i for i in rime_hits if self.entries[i]["artist"].lower() == art]
                if take(same): return [self.entries[i] for i in picks]
            if take(rime_hits): return [self.entries[i] for i in picks]

        if tab_set:
            for t in tab_set:
                if art:
                    same = [i for i in self.by_tab.get(t, []) if self.entries[i]["artist"].lower() == art]
                    if take(same): return [self.entries[i] for i in picks]
                if take(self.by_tab.get(t, [])): return [self.entries[i] for i in picks]

        if art:
            if take(self.by_artist.get(art, [])): return [self.entries[i] for i in picks]

        return [self.entries[i] for i in picks]
