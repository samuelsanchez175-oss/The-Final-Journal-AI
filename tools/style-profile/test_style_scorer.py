#!/usr/bin/env python3
"""Unit tests for Task C — Learned Style Scorer."""

from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

import style_scorer as ss


class TestStyleScorer(unittest.TestCase):
    def setUp(self):
        # Synthetic dataset with clear separation
        self.pos_verses = [
            ["Coupe with the drip on the seat tonight", "Hundred racks cash in the middle of night",
             "Diamonds dancing bright on the vintage chain", "Swervin' through the city in the fast car lane"],
            ["Bottega bags when we fly out to Spain", "Woke up in the penthouse ignoring the rain",
             "Big bankroll never slip never slide", "Got the whole team with me enjoying the ride"],
            ["Trappin' out the kitchen till the winter was cold", "Every single brick by the morning got sold",
             "Bought a new Richard Mille, timepiece froze", "Foreign whip clean from the head to the toes"],
        ]
        self.neg_verses = [
            ["The professor delivered a lecture on history", "Solving the ancient political mystery",
             "Students sat quietly taking their notes", "Reviewing the constitution and its quotes"],
            ["Thermodynamic equations describe heat flow", "Entropy measures how particles go",
             "Laboratory experiments verify the speed", "Checking the data that scientists need"],
            ["The administrative council held their debate", "Discussing the budget and fiscal tax rate",
             "Committees submitted their annual report", "Reviewing decisions made by the court"],
        ]

    def test_synthetic_separation_and_auc(self):
        """Classifier must achieve high AUC on synthetic separation."""
        clf = ss.StyleClassifier(alpha=1.0, min_df=1, top_k=500, artist="TestArtist")
        clf.fit(self.pos_verses, self.neg_verses)

        test_pos = [
            "Coupe with the diamonds and hundred racks cash",
            "Swervin' the whip with the drip on the dash",
        ]
        test_neg = [
            "The university council debated the lecture today",
            "Students took notes on thermodynamic theory away",
        ]

        score_pos = clf.score(test_pos)
        score_neg = clf.score(test_neg)

        self.assertGreater(score_pos, score_neg)
        self.assertGreater(score_pos, 0.6)
        self.assertLess(score_neg, 0.4)

        # Check AUC
        auc = ss.compute_auc([score_pos], [score_neg])
        self.assertEqual(auc, 1.0)

    def test_feature_extraction(self):
        """Feature extraction must yield character 3-5, word 1-2, and function word features."""
        lines = ["Coupe with the drip tonight", "Hundred racks in the flight"]
        feats = ss.extract_features(lines)

        # Check character n-grams
        has_c3 = any(k.startswith("c3:") for k in feats)
        has_c4 = any(k.startswith("c4:") for k in feats)
        has_c5 = any(k.startswith("c5:") for k in feats)
        self.assertTrue(has_c3, "Missing character trigrams")
        self.assertTrue(has_c4, "Missing character 4-grams")
        self.assertTrue(has_c5, "Missing character 5-grams")

        # Check word unigrams and bigrams
        has_w1 = any(k.startswith("w1:") for k in feats)
        has_w2 = any(k.startswith("w2:") for k in feats)
        self.assertTrue(has_w1, "Missing word unigrams")
        self.assertTrue(has_w2, "Missing word bigrams")

        # Check function words and density
        has_fw = any(k.startswith("fw:") for k in feats)
        has_ratio = any(k.startswith("fw_ratio:") for k in feats)
        self.assertTrue(has_fw, "Missing function words")
        self.assertTrue(has_ratio, "Missing function word ratio")

    def test_spearman_correlation(self):
        """Spearman correlation must accurately compute monotonic rank relationship."""
        # Perfect positive
        self.assertAlmostEqual(ss.spearman_correlation([1, 2, 3, 4, 5], [10, 20, 30, 40, 50]), 1.0)
        # Perfect negative
        self.assertAlmostEqual(ss.spearman_correlation([1, 2, 3, 4, 5], [50, 40, 30, 20, 10]), -1.0)
        # Ties
        self.assertAlmostEqual(ss.spearman_correlation([1, 2, 2, 3], [10, 20, 20, 30]), 1.0)
        # Edge cases
        self.assertEqual(ss.spearman_correlation([], []), 0.0)
        self.assertEqual(ss.spearman_correlation([1], [1]), 0.0)

    def test_model_serialization(self):
        """Model must serialize to dict and deserialize back with identical scoring."""
        clf = ss.StyleClassifier(alpha=1.0, min_df=1, top_k=200, artist="Gunna")
        clf.fit(self.pos_verses, self.neg_verses)

        data = clf.to_dict()
        self.assertEqual(data["schema"], ss.SCHEMA_VERSION)
        self.assertEqual(data["artist"], "Gunna")
        self.assertIn("weights", data)

        clf_restored = ss.StyleClassifier.from_dict(data)
        verse = ["Coupe with the drip, diamonds so bright"]

        score1 = clf.score(verse)
        score2 = clf_restored.score(verse)
        self.assertAlmostEqual(score1, score2, places=6)

    def test_passes_gate(self):
        """passes_gate must strictly enforce AUC >= 0.75 and Spearman > 0."""
        passing_report = {
            "gates": {
                "all_gates_cleared": True,
                "gate_1_heldout_vs_peers_auc_ge_0_75": {"passed": True, "achieved": 0.78},
                "gate_2_heldout_vs_random_auc_ge_0_75": {"passed": True, "achieved": 0.77},
                "gate_3_spearman_vs_verse_score_gt_0": {"passed": True, "achieved": 0.06},
            }
        }
        failing_report_auc = {
            "gates": {
                "all_gates_cleared": False,
                "gate_1_heldout_vs_peers_auc_ge_0_75": {"passed": False, "achieved": 0.71},
                "gate_2_heldout_vs_random_auc_ge_0_75": {"passed": True, "achieved": 0.76},
                "gate_3_spearman_vs_verse_score_gt_0": {"passed": True, "achieved": 0.05},
            }
        }
        failing_report_spearman = {
            "gates": {
                "all_gates_cleared": False,
                "gate_1_heldout_vs_peers_auc_ge_0_75": {"passed": True, "achieved": 0.78},
                "gate_2_heldout_vs_random_auc_ge_0_75": {"passed": True, "achieved": 0.76},
                "gate_3_spearman_vs_verse_score_gt_0": {"passed": False, "achieved": -0.02},
            }
        }

        self.assertTrue(ss.passes_gate(passing_report))
        self.assertFalse(ss.passes_gate(failing_report_auc))
        self.assertFalse(ss.passes_gate(failing_report_spearman))

    def test_live_gunna_model_passes_gate(self):
        """The trained Gunna model report must clear all gates."""
        if ss.DEFAULT_REPORT.exists():
            self.assertTrue(ss.passes_gate(ss.DEFAULT_REPORT))


if __name__ == "__main__":
    unittest.main()
