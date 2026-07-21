#!/usr/bin/env bash
# Run one Obsidian thinking-tool slash command headlessly and save the
# briefing into the vault's _agent/briefings/ folder. The home and digest
# commands write their own files under _agent/ instead of a briefing.
#
# Usage: run-command.sh <today|closeday|ideas|drift|graduate|home|digest> [--dry-run]
#
# Config: ~/.config/obsidian-commands/config (created by install.sh)
#   VAULT_PATH=/path/to/vault     required
#   LAUNCH_OBSIDIAN=true          start Obsidian (background) if not running
#   CLAUDE_BIN=claude             override the claude binary
#   CLAUDE_EXTRA_ARGS=            extra flags, e.g. "--model haiku" for cheap runs
set -euo pipefail

# launchd starts jobs with a minimal PATH; include the usual install locations.
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.local/bin:$HOME/bin:$PATH"

CMD="${1:-}"
DRY_RUN=false
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=true

case "$CMD" in
  today|closeday|ideas|drift|graduate) WRITES_OWN_FILES=false ;;
  home|digest)                         WRITES_OWN_FILES=true ;;
  *) echo "usage: $(basename "$0") <today|closeday|ideas|drift|graduate|home|digest> [--dry-run]" >&2; exit 2 ;;
esac

CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian-commands/config"
# shellcheck source=/dev/null
[[ -f "$CONFIG" ]] && source "$CONFIG"
: "${VAULT_PATH:?Set VAULT_PATH in $CONFIG}"
: "${LAUNCH_OBSIDIAN:=true}"
: "${CLAUDE_BIN:=claude}"

[[ -d "$VAULT_PATH" ]] || { echo "vault not found: $VAULT_PATH" >&2; exit 1; }

# /drift compares 30-60 day windows; every other ISO week is enough.
if [[ "$CMD" == "drift" ]] && (( 10#$(date +%V) % 2 == 1 )); then
  echo "drift: odd ISO week $(date +%V), skipping (runs on even weeks)"
  exit 0
fi

OUT_DIR="$VAULT_PATH/_agent/briefings"
OUT_FILE="$OUT_DIR/$(date +%F)-$CMD.md"

# Read-only allowlist: vault reads, the obsidian CLI, calendar helpers, and
# the Skill tool so the obsidian-cli skill can load. /graduate stops at its
# approval step in print mode, so it stays a report and never writes.
ALLOWED_TOOLS=(
  "Read" "Glob" "Grep" "Skill"
  "Bash(obsidian:*)"
  "Bash(icalBuddy:*)" "Bash(gcalcli:*)"
  "Bash(find:*)" "Bash(ls:*)" "Bash(date:*)"
  "Bash(grep:*)" "Bash(cat:*)" "Bash(head:*)" "Bash(tail:*)" "Bash(wc:*)"
)

# /home and /digest maintain their own files; writes stay inside _agent/.
if $WRITES_OWN_FILES; then
  ALLOWED_TOOLS+=("Write(_agent/**)" "Edit(_agent/**)" "Bash(mkdir:*)")
fi

if $DRY_RUN; then
  echo "would cd:    $VAULT_PATH"
  echo "would run:   $CLAUDE_BIN -p \"/$CMD\" --allowedTools ${ALLOWED_TOOLS[*]} ${CLAUDE_EXTRA_ARGS:-}"
  if $WRITES_OWN_FILES; then
    echo "would write: files under $VAULT_PATH/_agent/ (command-managed)"
  else
    echo "would write: $OUT_FILE"
  fi
  exit 0
fi

# The link-graph features need the Obsidian app running (the CLI talks to it
# over IPC). Launch it in the background without stealing focus.
if [[ "$LAUNCH_OBSIDIAN" == "true" && "$(uname)" == "Darwin" ]] \
   && ! pgrep -x Obsidian >/dev/null 2>&1; then
  open -gja Obsidian || true
  sleep 8
fi

cd "$VAULT_PATH"

if $WRITES_OWN_FILES; then
  mkdir -p "$VAULT_PATH/_agent"
  # shellcheck disable=SC2086  # CLAUDE_EXTRA_ARGS is intentionally word-split
  "$CLAUDE_BIN" -p "/$CMD" --allowedTools "${ALLOWED_TOOLS[@]}" ${CLAUDE_EXTRA_ARGS:-}
  echo "refreshed $CMD (see $VAULT_PATH/_agent/)"
else
  mkdir -p "$OUT_DIR"
  # shellcheck disable=SC2086  # CLAUDE_EXTRA_ARGS is intentionally word-split
  {
    echo "---"
    echo "command: /$CMD"
    echo "generated: $(date '+%Y-%m-%d %H:%M')"
    echo "source: agent"
    echo "---"
    echo
    "$CLAUDE_BIN" -p "/$CMD" --allowedTools "${ALLOWED_TOOLS[@]}" ${CLAUDE_EXTRA_ARGS:-}
  } > "$OUT_FILE.tmp" && mv "$OUT_FILE.tmp" "$OUT_FILE"
  echo "wrote $OUT_FILE"
fi
