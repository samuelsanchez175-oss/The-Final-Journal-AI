"""Run C1 through C5 for a chosen set of sources. Tests call this."""

from __future__ import annotations

from pathlib import Path

from catalog_build.annotate import annotate
from catalog_build.build import source_stamp
from catalog_build.enrich import enrich
from catalog_build.index import index_lines
from catalog_build.ingest import default_plugins, ingest
from catalog_build.paths import DB_PATH, EVAL_PATH, GROUND_TRUTH_CSV, TRAIN_JSONL
from catalog_build.validate import write_report


def run(
    artists: list[str],
    refresh_spotify: bool = False,
    db_path: Path = DB_PATH,
    jsonl_path: Path = TRAIN_JSONL,
    csv_path: Path = GROUND_TRUTH_CSV,
    report_path: Path | None = None,
    cmu: dict | None = None,
) -> dict:
    plugins = default_plugins(jsonl_path, csv_path, titles={})
    raw = ingest(plugins=plugins, artists=artists)
    annotated = annotate(raw, cmu)
    enriched = enrich(annotated, refresh_spotify=refresh_spotify)
    stamp = source_stamp(artists, None, [plugin.path for plugin in plugins])
    written = index_lines(enriched, db_path, stamp, artists)
    dest = report_path or EVAL_PATH
    warnings = write_report(db_path, dest, artists)
    report = dest.read_text(encoding="utf-8") if dest.exists() else ""
    return {
        "lines": len(raw),
        "indexed": int(written.get("rows") or 0),
        "skipped": bool(written.get("skipped")),
        "report_path": str(dest),
        "report": report,
        "warnings": warnings,
    }
