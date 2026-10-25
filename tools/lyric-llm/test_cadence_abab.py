"""test_cadence_abab.py
===================
Unit tests for 4-comma cadence pockets, syllable uniformity, and ABAB inner rhyme detection.
"""

import unittest
import cadence_analyzer


class TestCadenceABAB(unittest.TestCase):

    def test_normalize_slang_word(self):
        self.assertEqual(cadence_analyzer.normalize_slang_word("mornin'"), "morning")
        self.assertEqual(cadence_analyzer.normalize_slang_word("rollin'"), "rolling")
        self.assertEqual(cadence_analyzer.normalize_slang_word("CASH!"), "cash")
        self.assertEqual(cadence_analyzer.normalize_slang_word("'wave'"), "wave")

    def test_is_hiphop_rhyme(self):
        # Pure rhymes
        self.assertTrue(cadence_analyzer.is_hiphop_rhyme("wave", "grave"))
        self.assertTrue(cadence_analyzer.is_hiphop_rhyme("city", "pretty"))
        self.assertTrue(cadence_analyzer.is_hiphop_rhyme("phone", "throne"))
        self.assertTrue(cadence_analyzer.is_hiphop_rhyme("spark", "shark"))
        self.assertTrue(cadence_analyzer.is_hiphop_rhyme("night", "light"))
        self.assertTrue(cadence_analyzer.is_hiphop_rhyme("green", "Celine"))
        self.assertTrue(cadence_analyzer.is_hiphop_rhyme("whip", "clip"))

        # Slant / hip-hop assonance
        self.assertTrue(cadence_analyzer.is_hiphop_rhyme("cash", "bag"))
        self.assertTrue(cadence_analyzer.is_hiphop_rhyme("foreign", "mornin'"))

        # Non-rhymes
        self.assertFalse(cadence_analyzer.is_hiphop_rhyme("cash", "phone"))
        self.assertFalse(cadence_analyzer.is_hiphop_rhyme("car", "bottle"))

    def test_gunna_abab_cadence(self):
        line = "Stackin' the cash, ridin' the wave, grabbin' the bag, diggin' the grave"
        res = cadence_analyzer.analyze_bar_cadence(line)

        self.assertEqual(res["comma_count"], 3)
        self.assertEqual(len(res["segments"]), 4)
        self.assertTrue(res["is_isochronous"])
        self.assertTrue(res["abab_detected"])
        self.assertEqual(res["rhyme_type"], "ABAB")
        self.assertEqual(res["syl_pattern"], "4+4+4+4")
        self.assertEqual(res["total_syllables"], 16)
        self.assertIn(["cash", "bag"], res["internal_pairs"])
        self.assertIn(["wave", "grave"], res["internal_pairs"])
        self.assertGreaterEqual(res["cadence_score"], 0.90)

    def test_wayne_abab_cadence(self):
        line = "Fire in the spark, swirvin' in the night, swimmin' with the shark, lookin' for the light"
        res = cadence_analyzer.analyze_bar_cadence(line)

        self.assertEqual(res["comma_count"], 3)
        self.assertEqual(len(res["segments"]), 4)
        self.assertTrue(res["is_isochronous"])
        self.assertTrue(res["abab_detected"])
        self.assertEqual(res["rhyme_type"], "ABAB")
        self.assertEqual(res["syl_pattern"], "5+5+5+5")
        self.assertEqual(res["total_syllables"], 20)
        self.assertIn(["spark", "shark"], res["internal_pairs"])
        self.assertIn(["night", "light"], res["internal_pairs"])

    def test_drake_abab_cadence(self):
        line = "Late night in the city, called up on the phone, pity for the pretty, sittin' on the throne"
        res = cadence_analyzer.analyze_bar_cadence(line)

        self.assertEqual(res["comma_count"], 3)
        self.assertEqual(len(res["segments"]), 4)
        self.assertTrue(res["is_isochronous"])
        self.assertTrue(res["abab_detected"])
        self.assertEqual(res["rhyme_type"], "ABAB")
        self.assertIn(["city", "pretty"], res["internal_pairs"])
        self.assertIn(["phone", "throne"], res["internal_pairs"])

    def test_thug_abab_cadence(self):
        line = "Drippin' in the green, ridin' in the whip, ice on my Celine, let the thirty clip"
        res = cadence_analyzer.analyze_bar_cadence(line)

        self.assertEqual(res["comma_count"], 3)
        self.assertEqual(len(res["segments"]), 4)
        self.assertTrue(res["is_isochronous"])
        self.assertTrue(res["abab_detected"])
        self.assertEqual(res["syl_pattern"], "5+5+5+5")
        self.assertEqual(res["total_syllables"], 20)
        self.assertIn(["green", "Celine"], res["internal_pairs"])
        self.assertIn(["whip", "clip"], res["internal_pairs"])

    def test_five_segment_cadence(self):
        line = "Stackin' the cash, ridin' the wave, grabbin' the bag, diggin' the grave, makin' it save"
        res = cadence_analyzer.analyze_bar_cadence(line)

        self.assertEqual(res["comma_count"], 4)
        self.assertEqual(len(res["segments"]), 5)
        self.assertTrue(res["is_isochronous"])
        self.assertTrue(res["abab_detected"])
        self.assertEqual(res["syl_pattern"], "4+4+4+4+4")
        self.assertEqual(res["total_syllables"], 20)

    def test_run_on_line_repartition(self):
        line = "Stackin' the cash and ridin' the wave grabbin' the bag and diggin' the grave"
        res = cadence_analyzer.analyze_bar_cadence(line)

        self.assertGreaterEqual(res["comma_count"], 3)
        self.assertEqual(len(res["segments"]), 4)
        self.assertTrue(res["is_isochronous"])
        self.assertTrue(res["abab_detected"])


if __name__ == "__main__":
    unittest.main()
