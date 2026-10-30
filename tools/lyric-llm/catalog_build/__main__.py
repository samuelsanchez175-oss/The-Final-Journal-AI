"""python3 -m catalog_build build --artists Gunna \"Lil Baby\""""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from catalog_build.build import DEFAULT_ARTISTS, build
from catalog_build.paths import DB_PATH, EVAL_PATH


def _parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(prog="catalog_build", description="Build the lyric catalog index.")
    sub = parser.add_subparsers(dest="command", required=True)

    build_cmd = sub.add_parser("build", help="Run C1 through C5.")
    build_cmd.add_argument("--artists", nargs="+", default=None)
    build_cmd.add_argument("--all", action="store_true", dest="all_artists")
    build_cmd.add_argument("--refresh-spotify", action="store_true")
    build_cmd.add_argument("--refresh-genius", action="store_true")
    build_cmd.add_argument("--since", default=None, help="YYYY-MM-DD. Applied to ground-truth years.")
    build_cmd.add_argument("--db", type=Path, default=DB_PATH)
    build_cmd.add_argument("--report", type=Path, default=EVAL_PATH)

    onboard = sub.add_parser("onboard", help="Build one new voice and report whether it is retrieval-ready.")
    onboard.add_argument("--artist", required=True)
    onboard.add_argument("--sources", default="train.jsonl,ground_truth.csv")
    onboard.add_argument("--refresh-spotify", action="store_true")
    onboard.add_argument("--since", default=None)
    onboard.add_argument("--db", type=Path, default=DB_PATH)
    onboard.add_argument("--report", type=Path, default=EVAL_PATH)
    return parser


def main(argv: list[str] | None = None) -> int:
    if argv is None:
        argv = sys.argv[1:]
    argv = list(argv)
    if not argv or argv[0] not in ("build", "onboard", "-h", "--help"):
        argv = ["build", *argv]
    args = _parser().parse_args(argv)
    if args.command == "onboard":
        known = {"train.jsonl", "ground_truth.csv", "genius_api"}
        asked = [piece.strip() for piece in args.sources.split(",") if piece.strip()]
        unknown = [name for name in asked if name not in known]
        if unknown:
            print(f"[catalog] Unknown sources: {', '.join(unknown)}", file=sys.stderr)
            return 2
        if "genius_api" in asked:
            print("[catalog] genius_api reads the local genius-clicks dump during enrich. It does not download lyrics.")
        result = build(
            artists=[args.artist],
            refresh_spotify=args.refresh_spotify,
            refresh_genius="genius_api" in asked,
            since=args.since,
            db_path=args.db,
            report_path=args.report,
        )
    else:
        artists = args.artists
        if artists is None and not args.all_artists:
            artists = list(DEFAULT_ARTISTS)
        if args.since:
            print("[catalog] --since filters ground-truth rows by year. train.jsonl has no date, so those lines stay.")
        result = build(
            artists=artists,
            all_artists=args.all_artists,
            refresh_spotify=args.refresh_spotify,
            refresh_genius=args.refresh_genius,
            since=args.since,
            db_path=args.db,
            report_path=args.report,
        )
    print(
        f"[catalog] lines {result.get('lines', 0)} indexed {result.get('indexed', 0)} "
        f"skipped {result.get('skipped')} in {result.get('seconds')}s"
    )
    print(f"[catalog] report {args.report}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
