"""Run C1 through C5. A matching stamp skips the rewrite."""

from __future__ import annotations

import time
from pathlib import Path

from catalog_build.schema import SCHEMA_VERSION
from catalog_build.annotate import annotate
from catalog_build.enrich import enrich
from catalog_build.index import connect, current_stamp, index_lines
from catalog_build.ingest import default_plugins, ingest
from catalog_build.paths import DB_PATH, EVAL_PATH, GROUND_TRUTH_CSV, TRAIN_JSONL
from catalog_build.validate import write_report

DEFAULT_ARTISTS = ["Gunna", "Drake", "NoCap", "Lil Wayne", "Lil Baby", "Young Thug"]


def source_stamp(artists: list[str] | None, since: str | None, paths: list[Path] | None = None) -> str:
    files = paths if paths is not None else [TRAIN_JSONL, GROUND_TRUTH_CSV]
    names = ",".join(sorted(artist.lower() for artist in artists)) if artists else "*"
    parts = [SCHEMA_VERSION, names, since or ""]
    for path in files:
        if path.exists():
            stat = path.stat()
            parts.append(f"{path.name}:{stat.st_mtime_ns}:{stat.st_size}")
        else:
            parts.append(f"{path.name}:missing")
    return "|".join(parts)


def build(
    artists: list[str] | None = None,
    all_artists: bool = False,
    refresh_spotify: bool = False,
    refresh_genius: bool = False,
    since: str | None = None,
    db_path: Path = DB_PATH,
    report_path: Path = EVAL_PATH,
    plugins: list | None = None,
    spotify_limit: int | None = None,
) -> dict:
    chosen = None if all_artists else (artists if artists is not None else list(DEFAULT_ARTISTS))
    active = plugins if plugins is not None else default_plugins()
    plugin_paths = [path for path in (getattr(plugin, "path", None) for plugin in active) if isinstance(path, Path)]
    stamp = source_stamp(chosen, since, plugin_paths or None)
    if refresh_spotify or refresh_genius:
        stamp += "|refresh"
    started = time.perf_counter()
    db_path = Path(db_path)
    if db_path.exists() and not refresh_spotify:
        conn = connect(db_path)
        try:
            saved = current_stamp(conn)
        finally:
            conn.close()
        if saved and saved == stamp:
            warnings = write_report(db_path, report_path, chosen)
            return {
                "skipped": True,
                "lines": 0,
                "seconds": round(time.perf_counter() - started, 3),
                "warnings": warnings,
                "db": str(db_path),
            }
    raw = ingest(plugins=active, artists=chosen, since=since)
    annotated = annotate(raw)
    enriched = enrich(
        annotated,
        refresh_spotify=refresh_spotify,
        refresh_genius=refresh_genius,
        spotify_limit=spotify_limit,
    )
    written = index_lines(enriched, db_path, stamp, chosen)
    warnings = write_report(db_path, report_path, chosen)
    return {
        "skipped": bool(written.get("skipped")),
        "lines": len(raw),
        "indexed": int(written.get("rows") or 0),
        "seconds": round(time.perf_counter() - started, 3),
        "warnings": warnings,
        "db": str(db_path),
        "plugins": [plugin.name for plugin in active],
    }
