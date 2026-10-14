import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import phase1_song_metrics as p  # noqa: E402

LEX = p.Lexicon(p.load_cmudict(p.DEFAULT_CMU))


def bars(lines):
    return [p.Bar(t, LEX) for t in lines]


class Phase1Tests(unittest.TestCase):
    def test_rap_spellings_resolve(self):
        self.assertIsNotNone(LEX.phones_for("tryin'"))
        self.assertIsNotNone(LEX.phones_for("'bout"))

    def test_adlib_stripped_from_end_word(self):
        b = p.Bar("911 Porsche and the trunk is a hood (Skrrt)", LEX)
        self.assertEqual(b.end_word, "hood")
        self.assertTrue(b.adlib)

    def test_couplet_end_rhyme_detected(self):
        lines = ["I stay on the grind all night", "Counting up the money by the light",
                 "She wanna ride in the new coupe", "Pull up with the whole crew",
                 "Hit the lights and then we gone", "Keep it moving all along",
                 "Never let the pressure break", "Made it out for my own sake"]
        m = p._end_rhyme(bars(lines))
        self.assertGreaterEqual(m["end_rhyme_pct"], 50)
        self.assertGreater(m["scheme_share"].get("couplet", 0), 50)

    def test_same_end_word_is_not_a_rhyme(self):
        lines = ["one more night", "two more night", "three more night", "four more night"]
        self.assertEqual(p._end_rhyme(bars(lines))["end_rhyme_pct"], 0.0)

    def test_internal_rhyme_found(self):
        lines = ["Cold flow told them go slow", "Fast cash last long past low", "Real deal feel steel heal",
                 "I walk the street and eat meat", "plain bar with nothing here"]
        m = p._internal_rhyme(bars(lines))
        self.assertGreaterEqual(m["internal_bar_pct"], 60)

    def test_duplicate_bars_collapse(self):
        self.assertEqual(p.norm_line("Yeah, it's lit (skrrt)"), p.norm_line("yeah its lit"[:0] + "Yeah, it's lit"))


if __name__ == "__main__":
    unittest.main()
