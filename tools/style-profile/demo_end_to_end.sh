#!/bin/bash
# End-to-end demo: rebuild topic blocks, generate bars, render footer.
# Run this once Phase 4 finishes labeling ~1,080 songs.

set -e

REPO="/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync"
cd "$REPO"

echo "=== Phase 5b: rebuild topic_blocks.json from Phase 4 labels ==="
python3 tools/style-profile/phase5_blocks_map.py map

echo ""
echo "=== Phase 6: generate 4 bars for Gunna ==="
GEN_ID=$(python3 tools/style-profile/phase6_generate.py --artist "Gunna" --bars 4 | jq -r '.generation_id')
echo "Generation ID: $GEN_ID"

echo ""
echo "=== Phase 6: render footer UI ==="
python3 tools/style-profile/phase6_footer.py "$GEN_ID" --html "/tmp/sparkler_footer_$GEN_ID.html"
echo "Footer HTML saved to /tmp/sparkler_footer_$GEN_ID.html"

echo ""
echo "=== Done ==="
echo "Next: Antigravity tempo lookup → merge_tempo_manual.py → Phase 3 resume (Oct 14 01:00 EDT)"
