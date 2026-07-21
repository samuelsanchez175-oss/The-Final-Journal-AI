#!/usr/bin/env bash
# Install launchd jobs for the Obsidian thinking-tool commands (macOS).
#
# Usage: ./install.sh /path/to/vault [job ...]
#   jobs: today closeday ideas drift graduate   (default: today ideas)
#
# What it does:
#   1. Writes ~/.config/obsidian-commands/config with your vault path
#   2. Copies the slash commands and the obsidian-cli skill to ~/.claude/
#      so headless runs find them from any working directory
#   3. Seeds <vault>/CLAUDE.md from the template (if missing) and creates
#      <vault>/_agent/briefings/
#   4. Generates + loads one launchd agent per job
set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
  echo "launchd is macOS-only. For Linux, add cron entries calling" >&2
  echo "run-command.sh directly — see README.md." >&2
  exit 1
fi

VAULT_ARG="${1:?usage: install.sh /path/to/vault [today ideas home closeday drift graduate digest]}"
shift
if [[ $# -gt 0 ]]; then JOBS=("$@"); else JOBS=(today ideas home); fi

VAULT="$(cd "$VAULT_ARG" && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNER="$SCRIPT_DIR/run-command.sh"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/obsidian-commands"
LOG_DIR="$HOME/Library/Logs/obsidian-commands"
AGENTS_DIR="$HOME/Library/LaunchAgents"

mkdir -p "$CONFIG_DIR" "$LOG_DIR" "$AGENTS_DIR"

# 1. Config (never clobber an existing one)
if [[ ! -f "$CONFIG_DIR/config" ]]; then
  cat > "$CONFIG_DIR/config" <<EOF
VAULT_PATH="$VAULT"
LAUNCH_OBSIDIAN=true
EOF
  echo "wrote $CONFIG_DIR/config"
else
  echo "config exists, leaving it alone: $CONFIG_DIR/config"
fi

# 2. Make commands + skill available machine-wide for headless runs
mkdir -p "$HOME/.claude/commands" "$HOME/.claude/skills"
cp "$REPO_ROOT/.claude/commands/"*.md "$HOME/.claude/commands/"
cp -R "$REPO_ROOT/.claude/skills/obsidian-cli" "$HOME/.claude/skills/"
echo "installed slash commands and obsidian-cli skill to ~/.claude/"

# 3. Vault scaffolding (never clobber)
if [[ ! -f "$VAULT/CLAUDE.md" ]]; then
  cp "$SCRIPT_DIR/vault-CLAUDE.md" "$VAULT/CLAUDE.md"
  echo "seeded $VAULT/CLAUDE.md — EDIT THE PLACEHOLDERS in it"
else
  echo "vault CLAUDE.md exists, leaving it alone"
fi
mkdir -p "$VAULT/_agent/briefings"

# 4. launchd agents
schedule_xml() {
  # launchd Weekday: 0 = Sunday
  case "$1" in
    today)    echo '<dict><key>Hour</key><integer>7</integer><key>Minute</key><integer>0</integer></dict>' ;;
    home)     echo '<dict><key>Hour</key><integer>7</integer><key>Minute</key><integer>15</integer></dict>' ;;
    closeday) echo '<dict><key>Hour</key><integer>21</integer><key>Minute</key><integer>30</integer></dict>' ;;
    ideas)    echo '<dict><key>Weekday</key><integer>0</integer><key>Hour</key><integer>17</integer><key>Minute</key><integer>0</integer></dict>' ;;
    drift)    echo '<dict><key>Weekday</key><integer>1</integer><key>Hour</key><integer>8</integer><key>Minute</key><integer>0</integer></dict>' ;;
    digest)   echo '<dict><key>Weekday</key><integer>5</integer><key>Hour</key><integer>16</integer><key>Minute</key><integer>0</integer></dict>' ;;
    graduate) echo '<dict><key>Weekday</key><integer>6</integer><key>Hour</key><integer>10</integer><key>Minute</key><integer>0</integer></dict>' ;;
    *) return 1 ;;
  esac
}

schedule_human() {
  case "$1" in
    today)    echo "daily 07:00" ;;
    home)     echo "daily 07:15 (after today)" ;;
    closeday) echo "daily 21:30" ;;
    ideas)    echo "Sundays 17:00" ;;
    drift)    echo "Mondays 08:00 (even ISO weeks only)" ;;
    digest)   echo "Fridays 16:00 (triage mode)" ;;
    graduate) echo "Saturdays 10:00 (report only)" ;;
  esac
}

for job in "${JOBS[@]}"; do
  if ! xml="$(schedule_xml "$job")"; then
    echo "unknown job: $job (valid: today home closeday ideas drift digest graduate)" >&2
    exit 2
  fi
  label="com.obsidian-commands.$job"
  plist="$AGENTS_DIR/$label.plist"
  cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key><string>$label</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$RUNNER</string>
    <string>$job</string>
  </array>
  <key>StartCalendarInterval</key>
  $xml
  <key>StandardOutPath</key><string>$LOG_DIR/$job.log</string>
  <key>StandardErrorPath</key><string>$LOG_DIR/$job.err.log</string>
  <key>RunAtLoad</key><false/>
</dict>
</plist>
EOF
  launchctl unload "$plist" 2>/dev/null || true
  launchctl load "$plist"
  echo "loaded $label — $(schedule_human "$job")"
done

echo
echo "Done. Test a run now with:"
echo "  $RUNNER today"
echo "Logs: $LOG_DIR/"
