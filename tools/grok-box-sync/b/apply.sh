#!/bin/bash
# Runs on the Mac from the extracted bundle dir (grok-box artist runs). Backs up any pre-existing Mac file before first overwrite.
P="/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/docs/play-on-words"
cd "$(dirname "$0")" || exit 1
TS=$(date +%Y%m%d-%H%M)
OWNED="/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync/tools/grok-box-sync/owned.txt"; touch "$OWNED"
skip=""
for f in pow/genius-clicks/*.jsonl; do
  [ -e "$f" ] || continue
  b=$(basename "$f"); new=$(stat -f%z "$f"); old=$(stat -f%z "$P/genius-clicks/$b" 2>/dev/null || echo 0)
  if [ "$old" -gt "$new" ]; then echo "SKIP ${b%.jsonl}: Mac file larger ($old > $new)"; skip="$skip|${b%.jsonl}|"; fi
done
find pow -type f | while IFS= read -r f; do
  a=$(basename "$f"); a=${a%.jsonl}; a=${a%.md}
  case "$skip" in *"|$a|"*) continue;; esac
  dst="$P/${f#pow/}"
  if [ -e "$dst" ] && ! grep -qxF "$dst" "$OWNED" && ! ls "$dst".bak-pre-grokbox-* >/dev/null 2>&1; then cp -p "$dst" "$dst.bak-pre-grokbox-$TS" && echo "BACKUP $dst"; fi
  [ -e "$dst" ] || echo "$dst" >> "$OWNED"
  mv -f "$f" "$dst"
done
for c in claims/*.claim; do a=$(basename "$c" .claim); case "$skip" in *"|$a|"*) continue;; esac
  if [ -e "$P/lane-claims/$a.claim" ] && head -1 "$P/lane-claims/$a.claim" | grep -q grok-box; then cp "$c" "$P/lane-claims/$a.claim.tmp" && mv -f "$P/lane-claims/$a.claim.tmp" "$P/lane-claims/$a.claim"; fi; done
if [ -s progress_new.txt ]; then [ -n "$(tail -c1 "$P/all-artists-progress.md")" ] && echo >> "$P/all-artists-progress.md"; cat progress_new.txt >> "$P/all-artists-progress.md"; fi
for m in done/*; do [ -e "$m" ] || continue; a=$(basename "$m"); [ -e "$P/lane-claims/$a.claim" ] && mv "$P/lane-claims/$a.claim" "$P/lane-claims/$a.done" && echo "DONE $a"; done
cp grok-box.md "$P/chat-status/.grok-box.md.tmp" && mv -f "$P/chat-status/.grok-box.md.tmp" "$P/chat-status/grok-box.md"
echo "APPLIED progress_lines=$(wc -l < progress_new.txt | tr -d ' ') skip=[$skip]"
