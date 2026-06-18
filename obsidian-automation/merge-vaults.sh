#!/usr/bin/env bash
# Merge source vaults into subfolders of a target vault. Copy only — sources
# are never modified or deleted. Dry-run by default; pass --apply to copy.
#
# Usage:
#   merge-vaults.sh <target-vault> <source-vault>:<subfolder> [more sources...] [--apply]
# Example:
#   merge-vaults.sh ~/Vaults/Main ~/Vaults/OB:Projects ~/Vaults/Alamo:Clippings
#   merge-vaults.sh ~/Vaults/Main ~/Vaults/OB:Projects ~/Vaults/Alamo:Clippings --apply
#
# Notes:
#   - .obsidian/ and .trash/ in sources are not copied: the target keeps its
#     own settings; re-enable plugins there manually.
#   - Wikilinks resolve by file name, so same-named notes in two places make
#     links ambiguous. Collisions are listed — resolve (rename) before --apply.
set -euo pipefail

APPLY=false
ARGS=()
for a in "$@"; do
  if [[ "$a" == "--apply" ]]; then APPLY=true; else ARGS+=("$a"); fi
done

if [[ ${#ARGS[@]} -lt 2 ]]; then
  echo "usage: $(basename "$0") <target-vault> <source>:<subfolder> [...] [--apply]" >&2
  exit 2
fi

TARGET="${ARGS[0]}"
[[ -d "$TARGET" ]] || { echo "target vault not found: $TARGET" >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"

# markdown files, excluding Obsidian internals and the agent area
list_md() {
  find "$1" \( -name .obsidian -o -name .trash -o -name _agent \) -prune \
    -o -type f -name '*.md' -print
}

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
list_md "$TARGET" | awk -F/ '{print $NF}' | sort > "$TMP/target.names"
: > "$TMP/sources.names"

for spec in "${ARGS[@]:1}"; do
  src="${spec%:*}"
  sub="${spec##*:}"
  if [[ "$src" == "$spec" || -z "$sub" || -z "$src" ]]; then
    echo "bad source spec (need <source>:<subfolder>): $spec" >&2
    exit 2
  fi
  [[ -d "$src" ]] || { echo "source vault not found: $src" >&2; exit 1; }
  src="$(cd "$src" && pwd)"

  n="$(list_md "$src" | wc -l | tr -d ' ')"
  echo "── $src  →  $TARGET/$sub/   ($n markdown files)"
  list_md "$src" | awk -F/ '{print $NF}' | sort >> "$TMP/sources.names"

  if $APPLY; then
    mkdir -p "$TARGET/$sub"
    (cd "$src" && tar -cf - --exclude '.obsidian' --exclude '.trash' .) \
      | (cd "$TARGET/$sub" && tar -xf -)
  fi
done

# Collisions: duplicate names among the sources, plus source names already
# present in the target.
sort "$TMP/sources.names" | uniq -d > "$TMP/dups"
comm -12 "$TMP/target.names" <(sort -u "$TMP/sources.names") >> "$TMP/dups"
sort -u "$TMP/dups" > "$TMP/collisions"

if [[ -s "$TMP/collisions" ]]; then
  echo
  echo "⚠ name collisions (wikilinks to these become ambiguous):"
  sed 's/^/    /' "$TMP/collisions"
  echo "  Rename one of each pair, then re-run."
else
  echo
  echo "no name collisions."
fi

if ! $APPLY; then
  echo
  echo "dry run — nothing copied. Re-run with --apply to copy."
fi
