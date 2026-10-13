# Blocks completion audit

Verified 2026-10-11. This is not an all-work-complete declaration.

## Board

http://127.0.0.1:47321/ responds with HTTP 200. The Python listener is detached (parent PID 1). The five `/api/wordplay-tabs` counters respond. These counters merge the scripted index with manual v2 overrides; they are not counts of manually approved app blocks. The stale October 8 takeover status has been replaced with this audit's actual scope.

## App

The existing app had only the Play on Words category. It now has All plus Sound Flips & Homophones, Double Meanings, Split Names & Brands, Hidden References, and Punchline Setups. The picker and its entry button are named Blocks. Global search and recents remain available. Punchline membership can overlap a wordplay category.

Seven existing bundled entries have explicit reviewed memberships. Five use Samuel's approval records in wordplay-wiring-log.jsonl: James Harden, Andre 3000, Nike Air Max, Hilary Duff, and Nutty Buddy. All That and Nina Simone use saved Veeze community notes, annotations 27879469 and 31190411. Their source URLs were corrected in the bundle. Entries without explicit membership remain under All; they are not automatically classified from keyword rules.

## Remaining work

- Manual index: 125 reviewed (98 KEEP, 24 REJECT, 3 UNSURE), out of 17,024 queue records. 16,899 records still lack a manual v2 review. Existing scripted index: 8,887 verdicts; it is not a substitute for manual review.
- Bundled wordplay examples: 189 entries, with seven classified for the new filters. Broader membership and provenance need review, including blank URLs and repeated annotation 24874349 on unrelated entries.
- NounMarks: 4,095 image sets have nonempty image declarations and existing referenced files. This verifies file integrity, not image subject, resolution, or correctness for every chip.
- Picture ledger: 1,371 rows; 399 still have action `review`, and 62 have spot-check `held`. An empty new-image queue does not close this older ledger.
- Catalog literal asset names absent from the asset catalogs: noun-char-madea, noun-char-otis, noun-char-tommy. Check actual chip reachability and intended subjects before replacing them.
- Artist completion previously meant every artist was accounted for under the requested skip rules. It did not mean every Genius song was resolved.

The apparent malformed queue entry was an audit-reader issue: Python `splitlines()` treats the note's U+0085 character as a separator. JSONL must be read using physical newline boundaries. No note repair or meaning change is needed.

## Verification

Targeted NounBankSheetTests cover all five populated filters, overlapping punchlines, unknown membership, source URLs, and asset loading. Record the simulator result in chat-status/chat-blocks.md after the run completes.
