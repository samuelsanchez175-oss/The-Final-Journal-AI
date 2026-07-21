#!/usr/bin/env bash
# Unload and remove all obsidian-commands launchd agents.
# Leaves your config, vault CLAUDE.md, and _agent/briefings/ untouched.
set -euo pipefail

AGENTS_DIR="$HOME/Library/LaunchAgents"
found=false

for plist in "$AGENTS_DIR"/com.obsidian-commands.*.plist; do
  [[ -e "$plist" ]] || continue
  found=true
  launchctl unload "$plist" 2>/dev/null || true
  rm "$plist"
  echo "removed $(basename "$plist")"
done

$found || echo "no obsidian-commands agents installed"
