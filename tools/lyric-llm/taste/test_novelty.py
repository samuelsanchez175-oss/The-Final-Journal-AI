from __future__ import annotations

import sqlite3
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from taste.novelty import (
    bar_novelty, verse_novelty, _longest_shared_run,
    _jaccard, _tokens, CATALOG,
)


class TestHelpers(unittest.TestCase):
    def test_longest_run(self):
        self.assertEqual(_longest_shared_run(
            "the quick brown fox jumps over".split(),
            "a quick brown fox darts past".split()), 3)
        self.assertEqual(_longest_shared_run([], ["a"]), 0)

    def test_jaccard(self):
        self.assertAlmostEqual(_jaccard({"a", "b", "c"}, {"b", "c", "d"}), 0.5)
        self.assertEqual(_jaccard(set(), set()), 0.0)


@unittest.skipUnless(CATALOG.exists(), "catalog DB missing")
class TestVaultDetection(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        import sqlite3
        c = sqlite3.connect(f"file:{CATALOG}?mode=ro", uri=True)
        row = c.execute("SELECT line FROM bars WHERE length(line) BETWEEN 40 AND 80 LIMIT 1").fetchone()
        c.close()
        cls.vault_line = row[0]

    def test_verbatim_rejected(self):
        r = bar_novelty(self.vault_line)
        self.assertTrue(r["is_near_dup"])

    def test_light_paraphrase_caught(self):
        # keep the vault line's internal 6-run intact; swap only one filler
        bar = self.vault_line + " yeah"
        r = bar_novelty(bar)
        self.assertTrue(r["is_near_dup"])

    def test_new_line_passes(self):
        # a completely different line
        r = bar_novelty("silk gardens whisper to the dark asphalt tonight")
        self.assertFalse(r["is_near_dup"])

    def test_shared_chip_alone_passes(self):
        # share only a chip word; longest shared run should be 1
        r = bar_novelty("Henny splash on my fresh pair of sneakers today",
                        chip_words=["Henny"])
        self.assertFalse(r["is_near_dup"])


class TestShownExamples(unittest.TestCase):
    def test_shown_verbatim_quoted_is_rejected(self):
        example = "pockets heavy with the hundreds and the honey"
        r = bar_novelty(example, shown_examples=[example])
        self.assertTrue(r["is_near_dup"])
        self.assertEqual(r["best_match"]["song"], "shown-example")


class TestVerse(unittest.TestCase):
    def test_verse_near_dup_indexes(self):
        bars = [
            "silk gardens whisper to the dark asphalt tonight",
            "another totally new line nobody has written",
        ]
        v = verse_novelty(bars)
        self.assertEqual(v["near_dup_bar_indexes"], [])
        self.assertFalse(v["is_near_dup"])


class TestFailClosed(unittest.TestCase):
    """If the catalog is unreachable, the novelty check must FAIL CLOSED
    (treat every bar as a near-dup) so the hard gate rejects it instead of
    silently passing a potential copy."""

    def test_fail_closed_on_missing_catalog(self):
        import taste.novelty as nv
        # swap the module-level CATALOG path to a bogus one, reset the cached
        # connection, run, then restore.
        orig_catalog = nv.CATALOG
        orig_conn = nv._CONN
        nv._CONN = None
        from pathlib import Path
        nv.CATALOG = Path("/tmp/__does_not_exist_%%.sqlite")
        try:
            r = nv.bar_novelty("I ride the city with my crown held high today")
            self.assertTrue(r["is_near_dup"])
            self.assertTrue(r.get("catalog_unavailable"))
            self.assertTrue(any("unavailable" in reason.lower()
                                for reason in r["reasons"]))
        finally:
            nv.CATALOG = orig_catalog
            nv._CONN = orig_conn


if __name__ == "__main__":
    unittest.main()
