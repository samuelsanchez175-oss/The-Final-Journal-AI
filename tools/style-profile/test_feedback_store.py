import sys, unittest
sys.path.insert(0, __file__.rsplit("/", 1)[0])
from feedback_store import FeedbackStore


class T(unittest.TestCase):
    def setUp(self):
        self.s = FeedbackStore()
        self.gid = self.s.log_generation("Gunna", [
            {"text": "bar one", "topic": "money_flex", "sources": [{"kind": "block", "ref": "bands", "category": "money"},
                                                                    {"kind": "block", "ref": "cartier", "category": "jewelry"}]},
            {"text": "bar two", "topic": "drugs", "sources": [{"kind": "block", "ref": "perc", "category": "drugs"}]}])

    def test_no_evidence_is_neutral(self):
        self.assertEqual(self.s.weight("block", "bands", "money_flex", "Gunna"), 0.5)

    def test_block_votes_move_weight_in_context(self):
        for _ in range(6):
            self.s.vote(f"{self.gid}:0", 1, "block", "bands")
        up = self.s.weight("block", "bands", "money_flex", "Gunna")
        self.assertGreater(up, 0.65)
        self.assertEqual(self.s.weight("block", "bands", "drugs", "Gunna") > 0.5, True)  # inherits global signal, shrunk
        self.assertLess(self.s.weight("block", "bands", "drugs", "Gunna"), up)

    def test_bad_bar_with_good_blocks_blames_pairing(self):
        self.s.vote(f"{self.gid}:1", 1, "block", "perc")
        self.s.vote(f"{self.gid}:1", -1, "bar", reason="off_topic")
        blame = self.s.db.execute("SELECT blame FROM votes WHERE target_kind='bar'").fetchone()[0]
        self.assertEqual(blame, "pairing")

    def test_bad_reason_rejected(self):
        with self.assertRaises(ValueError):
            self.s.vote(f"{self.gid}:0", -1, "bar", reason="meh")


if __name__ == "__main__":
    unittest.main()
