#!/usr/bin/env python3
"""AI Sparkler feedback store (Phase 5b): what the lyric-generator footer logs and how votes become weights.

Tables
  generations      one generated lyric  (artist requested, model, prompt version)
  generation_bars  its bars, with the topic the generator was in
  bar_sources      for each bar: which catalog bars / Blocks it borrowed (shown in the footer)
  votes            thumbs up/down on a whole bar OR on one borrowed source (block chip / catalog bar)

Weights: Beta-smoothed approval, shrunk hierarchically so thin data falls back to broader data:
  (source, topic, artist) -> (source, topic) -> (source) -> 0.5 prior.
A 👎 on a bar whose block chips were all 👍 is recorded as a `pairing` failure (the combination was
wrong, not the blocks), so those blocks are not punished.
"""

from __future__ import annotations

import json
import sqlite3
import time
import uuid

SHRINK_K = 4.0

SCHEMA = """
CREATE TABLE IF NOT EXISTS generations (
  id TEXT PRIMARY KEY, created_at REAL, artist TEXT, request_json TEXT, model TEXT, prompt_version TEXT);
CREATE TABLE IF NOT EXISTS generation_bars (
  id TEXT PRIMARY KEY, generation_id TEXT REFERENCES generations(id), bar_index INTEGER, text TEXT, topic TEXT);
CREATE TABLE IF NOT EXISTS bar_sources (
  bar_id TEXT REFERENCES generation_bars(id), kind TEXT CHECK(kind IN ('block','catalog_bar')),
  ref TEXT, category TEXT);
CREATE TABLE IF NOT EXISTS votes (
  id INTEGER PRIMARY KEY AUTOINCREMENT, ts REAL, generation_id TEXT, bar_id TEXT,
  target_kind TEXT CHECK(target_kind IN ('bar','block','catalog_bar','verse')), target_ref TEXT,
  vote INTEGER, reason TEXT, topic TEXT, artist TEXT, blame TEXT,
  reasons TEXT, rater TEXT);
CREATE INDEX IF NOT EXISTS votes_target ON votes(target_kind, target_ref, topic, artist);
"""

REASONS = {"no_sense", "off_topic", "bad_rhyme", "off_flow", "too_copied", "cringe"}


class FeedbackStore:
    def __init__(self, path: str = ":memory:"):
        self.db = sqlite3.connect(path)
        self.db.executescript(SCHEMA)
        self._ensure_schema()

    def _ensure_schema(self) -> None:
        """Idempotent migration: add reasons, rater, and support verse target_kind."""
        cur = self.db.cursor()
        cur.execute("PRAGMA table_info(votes);")
        cols = {row[1] for row in cur.fetchall()}
        if not cols:
            return
        if "reasons" not in cols:
            self.db.execute("ALTER TABLE votes ADD COLUMN reasons TEXT;")
        if "rater" not in cols:
            self.db.execute("ALTER TABLE votes ADD COLUMN rater TEXT;")

        # Check if target_kind CHECK constraint allows 'verse'
        cur.execute("SELECT sql FROM sqlite_master WHERE type='table' AND name='votes';")
        res = cur.fetchone()
        if res and res[0] and "CHECK" in res[0] and "'verse'" not in res[0]:
            self.db.execute("PRAGMA foreign_keys=OFF;")
            self.db.execute("""
                CREATE TABLE votes_migrated (
                    id INTEGER PRIMARY KEY AUTOINCREMENT, ts REAL, generation_id TEXT, bar_id TEXT,
                    target_kind TEXT CHECK(target_kind IN ('bar','block','catalog_bar','verse')), target_ref TEXT,
                    vote INTEGER, reason TEXT, topic TEXT, artist TEXT, blame TEXT,
                    reasons TEXT, rater TEXT
                );
            """)
            self.db.execute("""
                INSERT INTO votes_migrated (id, ts, generation_id, bar_id, target_kind, target_ref, vote, reason, topic, artist, blame, reasons, rater)
                SELECT id, ts, generation_id, bar_id, target_kind, target_ref, vote, reason, topic, artist, blame,
                       COALESCE(reasons, ''), COALESCE(rater, '')
                FROM votes;
            """)
            self.db.execute("DROP TABLE votes;")
            self.db.execute("ALTER TABLE votes_migrated RENAME TO votes;")
            self.db.execute("CREATE INDEX IF NOT EXISTS votes_target ON votes(target_kind, target_ref, topic, artist);")
            self.db.execute("PRAGMA foreign_keys=ON;")
        self.db.commit()

    # ---- logging
    def log_generation(self, artist: str, bars: list[dict], request: dict | None = None,
                       model: str = "", prompt_version: str = "") -> str:
        """bars: [{text, topic, sources:[{kind:'block'|'catalog_bar', ref, category?}]}] -> generation id"""
        gid = uuid.uuid4().hex
        self.db.execute("INSERT INTO generations VALUES (?,?,?,?,?,?)",
                        (gid, time.time(), artist, json.dumps(request or {}), model, prompt_version))
        for i, b in enumerate(bars):
            bid = f"{gid}:{i}"
            self.db.execute("INSERT INTO generation_bars VALUES (?,?,?,?,?)", (bid, gid, i, b["text"], b.get("topic")))
            for s in b.get("sources", []):
                self.db.execute("INSERT INTO bar_sources VALUES (?,?,?,?)", (bid, s["kind"], s["ref"], s.get("category")))
        self.db.commit()
        return gid

    def vote(self, bar_id: str, vote: int, target_kind: str = "bar", target_ref: str | None = None,
             reason: str | None = None, rater: str | None = None, ts: float | None = None,
             reasons: list[str] | str | None = None) -> None:
        if reason and reason not in REASONS:
            raise ValueError(f"reason must be one of {sorted(REASONS)}")
        reasons_str = json.dumps(reasons) if isinstance(reasons, list) else (str(reasons) if reasons else None)
        ts_val = time.time() if ts is None else float(ts)

        row = self.db.execute("""SELECT b.generation_id, b.topic, g.artist FROM generation_bars b
                                 JOIN generations g ON g.id = b.generation_id WHERE b.id = ?""", (bar_id,)).fetchone()
        if row:
            gid, topic, artist = row
        else:
            gid = bar_id.split(":")[0] if ":" in bar_id else bar_id
            topic = None
            artist = None

        ref = target_ref if target_kind != "bar" else bar_id
        blame = None
        if target_kind == "bar" and vote == -1:
            blame = self._blame(bar_id)
        self.db.execute("INSERT INTO votes (ts,generation_id,bar_id,target_kind,target_ref,vote,reason,topic,artist,blame,reasons,rater)"
                        " VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
                        (ts_val, gid, bar_id, target_kind, ref, vote, reason, topic, artist, blame, reasons_str, rater))
        self.db.commit()

    def _blame(self, bar_id: str) -> str:
        """'pairing' when every block chip on the bar was already thumbed up; else 'unknown'."""
        refs = [r[0] for r in self.db.execute("SELECT ref FROM bar_sources WHERE bar_id=? AND kind='block'", (bar_id,))]
        if not refs:
            return "unknown"
        ups = {r[0] for r in self.db.execute(
            "SELECT target_ref FROM votes WHERE bar_id=? AND target_kind='block' AND vote=1", (bar_id,))}
        return "pairing" if set(refs) <= ups else "unknown"

    # ---- weights
    def _counts(self, kind: str, ref: str, topic: str | None, artist: str | None) -> tuple[int, int]:
        q, args = "SELECT COALESCE(SUM(vote=1),0), COALESCE(SUM(vote=-1),0) FROM votes WHERE target_kind=? AND target_ref=?", [kind, ref]
        if topic:
            q += " AND topic=?"
            args.append(topic)
        if artist:
            q += " AND artist=?"
            args.append(artist)
        # a bar-level 👎 caused by a pairing failure does not count against its blocks
        up, down = self.db.execute(q + " AND COALESCE(blame,'')<>'pairing'", args).fetchone()
        return up, down

    def weight(self, kind: str, ref: str, topic: str | None = None, artist: str | None = None) -> float:
        """0..1 approval for a block/catalog bar in this context; 0.5 = no evidence."""
        levels = [(None, None)]
        if topic:
            levels.append((topic, None))
            if artist:
                levels.append((topic, artist))
        score = 0.5
        for t, a in levels:
            up, down = self._counts(kind, ref, t, a)
            score = (up + SHRINK_K * score) / (up + down + SHRINK_K)
        return round(score, 3)
