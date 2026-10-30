from __future__ import annotations

import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from taste.originality import bar_overlap, verse_originality, CATALOG


@unittest.skipUnless(CATALOG.exists(), "catalog DB missing")
class TestOriginality(unittest.TestCase):
    def test_short_bar_no_ngrams(self):
        r = bar_overlap("too short", n=5)
        self.assertEqual(r["ngram_total"], 0)
        self.assertEqual(r["ngram_overlap"], 0.0)

    def test_random_text_low_overlap(self):
        bars = [
            "The glacier whistles salt onto my sandwich tomorrow",
            "Carrier pigeons debate quantum entanglement at midnight",
        ]
        v = verse_originality(bars)
        self.assertLess(v["verse_overlap"], 0.5)

    def test_exact_catalog_hit_triggers_flag(self):
        # fetch a real catalog line to guarantee hit
        import sqlite3
        c = sqlite3.connect(f"file:{CATALOG}?mode=ro", uri=True)
        row = c.execute("SELECT line FROM bars WHERE length(line) > 25 LIMIT 1").fetchone()
        c.close()
        self.assertIsNotNone(row)
        bars = [row[0]]
        v = verse_originality(bars)
        self.assertTrue(v["too_copied"])
        self.assertTrue(any("exact" in r or "overlap" in r for r in v["reasons"]))

    def test_exact_hit_detected_normalized(self):
        import sqlite3
        from taste.originality import _exact_line_hit
        c = sqlite3.connect(f"file:{CATALOG}?mode=ro", uri=True)
        row = c.execute("SELECT line FROM bars WHERE length(line) > 25 LIMIT 1").fetchone()
        c.close()
        self.assertTrue(_exact_line_hit(row[0]))
        self.assertFalse(_exact_line_hit("absolutely nothing like a catalog line here folks"))


if __name__ == "__main__":
    unittest.main()
