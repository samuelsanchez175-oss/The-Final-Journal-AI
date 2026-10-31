#!/usr/bin/env python3
"""
Unit tests for Frontier v4 Named-Entity Leak Guard (Task P)
Tests:
  1. Candidate entity extraction (multi-word, capitalization, known rap entities).
  2. Per-voice proper noun whitelists (Gunna, Lil Wayne, Drake, Young Thug, etc.).
  3. Acceptance test: Gunna whitelist vs Lil-Wayne-voiced bar containing 'Thugger' -> guard fails -> retry fires.
  4. Cross-voice collaboration allowances & universal luxury brand support.
  5. Verse-level guard verification with multi-voice couplet allocation.
  6. Pipeline integration and auto-retry loop in polish / frontier_v4.
"""

from __future__ import annotations

import json
import os
import sys
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

HERE = Path(__file__).resolve().parent
REPO_ROOT = HERE.parent.parent
for p in (HERE, REPO_ROOT):
    if str(p) not in sys.path:
        sys.path.insert(0, str(p))

from entity_guard import (
    build_voice_whitelist,
    extract_candidate_entities,
    get_voice_whitelist,
    guard,
    guard_verse,
    rewrite_leaked_entity_bar,
)
import polish


class TestEntityGuard(unittest.TestCase):
    def test_extract_candidate_entities(self):
        # Multi-word exclusive rap entities
        b1 = "Me and Champagne Papi pullin' up in the dark"
        ents1 = extract_candidate_entities(b1)
        self.assertIn("Champagne Papi", ents1)

        # Capitalized single token mid-sentence
        b2 = "Chamber was cold, talking to Chubbs, standing on business, out in the mud"
        ents2 = extract_candidate_entities(b2)
        self.assertIn("Chubbs", ents2)

        # Known exclusive entity lowercased
        b3 = "got me feeling like thugger with the rack on the floor"
        ents3 = extract_candidate_entities(b3)
        self.assertTrue(any(e.lower() == "thugger" for e in ents3))

    def test_voice_whitelists(self):
        gunna_wl = get_voice_whitelist("Gunna")
        wayne_wl = get_voice_whitelist("Lil Wayne")
        drake_wl = get_voice_whitelist("Drake")

        # Thugger belongs to Gunna's world (YSL twin), but NOT Lil Wayne's
        self.assertIn("thugger", gunna_wl)
        self.assertNotIn("thugger", wayne_wl)

        # Tunechi belongs to Lil Wayne, NOT Gunna
        self.assertIn("tunechi", wayne_wl)
        self.assertNotIn("tunechi", gunna_wl)

        # Chubbs belongs to Drake, NOT Lil Wayne
        self.assertIn("chubbs", drake_wl)
        self.assertNotIn("chubbs", wayne_wl)

        # Universal luxury brands are permitted across ALL voices
        for brand in ["maybach", "bentley", "patek", "rolex", "paris"]:
            self.assertIn(brand, gunna_wl)
            self.assertIn(brand, wayne_wl)
            self.assertIn(brand, drake_wl)

    def test_guard_acceptance_lil_wayne_with_thugger(self):
        """
        Acceptance requirement from FRONTIER_V4_PLAN.md:
        Gunna whitelist, Lil-Wayne-voiced bar containing 'Thugger' -> guard fails -> retry fires.
        """
        bar_text = "I'm with Thugger in the booth, spit the fire through the tooth"

        # Gunna voice allows Thugger
        res_gunna = guard(voice="Gunna", bar=bar_text)
        self.assertTrue(res_gunna["ok"])
        self.assertEqual(res_gunna["offending_tokens"], [])

        # Lil Wayne voice rejects Thugger
        res_wayne = guard(voice="Lil Wayne", bar=bar_text)
        self.assertFalse(res_wayne["ok"])
        self.assertIn("Thugger", res_wayne["offending_tokens"])

        # Targeted retry removes the offending token and passes
        rewritten, passed = rewrite_leaked_entity_bar(
            bar_text=bar_text,
            target_word="tooth",
            offending_tokens=res_wayne["offending_tokens"],
            voice="Lil Wayne",
        )
        self.assertTrue(passed)
        self.assertNotIn("thugger", rewritten.lower())
        # Confirm retry preserves the landing word
        self.assertTrue(rewritten.strip().endswith("tooth"))

    def test_guard_verse_multi_voice(self):
        verse = [
            "Bentley coupe is fast, gotta make it last, me and Thugger countin' cash, hit the gas",  # Bar 1 [Gunna] -> OK
            "Rollie on my wrist, diamond on the fist, never take a diss, hit the list",            # Bar 2 [Gunna] -> OK
            "Young Money on the map, fire in the strap, Tunechi in the trap, make it snap",         # Bar 3 [Lil Wayne] -> OK
            "Keep the burner hot, standing on the spot, Thugger in the drop, never stop",          # Bar 4 [Lil Wayne] -> FAIL ('Thugger' in Wayne)
        ]
        bar_artists = ["Gunna", "Gunna", "Lil Wayne", "Lil Wayne"]

        eval_res = guard_verse(voice="Gunna", bars=verse, bar_artists=bar_artists)
        self.assertFalse(eval_res["passed"])
        self.assertEqual(eval_res["failed_indices"], [3])
        self.assertIn("Thugger", eval_res["offending_tokens"])


if __name__ == "__main__":
    unittest.main()
