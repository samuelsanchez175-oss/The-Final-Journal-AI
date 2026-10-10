# Chip relationship audit

Started by Codex takeover from Hubble's read-only audit. These are strong play-on-words chips where the relationship needs to be prominent on the chip itself, not buried in surrounding context.

## Needs visual pairing

| chip | partner | why it needs prominence | references |
| --- | --- | --- | --- |
| gotta cancer | cancer that | The bank intentionally matches `cancer that`, `cancer her`, and `cancer this bitch`, not bare `cancer`; the joke depends on cancel/cancer plus the bald-head setup being visible. | `XJournal AI/NounBankCatalog.swift:176`; `The Final Journal AITests/NounBankSheetTests.swift:3889` |
| raid us | Derek | `Derek Carr` is also a normal NFL chip, while the playable bar is `raid us` beside `Derek`; Raiders/Derek needs to be visible. | `docs/play-on-words/unwired-chips.md:92`; `XJournal AI/NounBankCatalog.swift:348` |
| drake kickback | soccer | The recoil/kick relationship explains the flip; otherwise it can read as artist/brand noise. | `docs/play-on-words/unwired-chips.md:166`; `XJournal AI/NounBankCatalog.swift:357` |
| wearing a trojan | spartan | The joke is Trojan/Spartan opposition plus `300`; without both sides, it can read as condom branding. | `docs/play-on-words/unwired-chips.md:167`; `The Final Journal AITests/NounBankSheetTests.swift:2783` |
| shot a buffalo | bills | Needs the animal/team/money triad; otherwise the Bills/bills payoff is easy to miss. | `docs/play-on-words/unwired-chips.md:171`; `XJournal AI/NounBankCatalog.swift:362` |
| we packers | clips | The strength is team/weapon overlap; the Packers plus gun-clip relationship should be visible. | `docs/play-on-words/unwired-chips.md:172`; `XJournal AI/NounBankCatalog.swift:363` |
| vacuum seals | clean | Needs the packed-work/cleaner double image; `clean` is the partner that makes it wordplay. | `docs/play-on-words/unwired-chips.md:174`; `The Final Journal AITests/NounBankSheetTests.swift:2790` |
| the O2 | O3 | The title alone reads like a venue noun; O2-to-O3 transformation should be visible on-chip. | `docs/play-on-words/unwired-chips.md:250`; `XJournal AI/NounBankCatalog.swift:423` |
| trigger fingers | Twitter | Needs Twitter-fingers foregrounded; otherwise it collapses into generic gun imagery. | `docs/play-on-words/unwired-chips.md:255`; `XJournal AI/NounBankCatalog.swift:428` |
| Energizer | drum | Needs battery/bunny plus gun drum prominence; the partner makes the bar. | `docs/play-on-words/unwired-chips.md:257`; `XJournal AI/NounBankCatalog.swift:430` |
| girl's tour | world | The new chip is `girl's tour`, but `world tour` is the contrast that explains the promotion. | `docs/play-on-words/unwired-chips.md:244`; `XJournal AI/NounBankCatalog.swift:432` |

## Implementation note

These should feed a visual-treatment pass for chip tiles: paired subtitle, partner badge, split-label treatment, or a small relationship cue on the artwork itself. The goal is that a viewer can read the flip from the chip without opening notes.
