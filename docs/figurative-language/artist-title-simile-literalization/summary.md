# Artist-title simile literalization

Separate from the simile literalization pass. This pass does not replace it.

Vault: `tools/bar-hits-catalog/BarHitsCatalog.sqlite`, table `bars`, opened with `sqlite3 -readonly` and `mode=ro&immutable=1`. Bar count at this write: 1,708,472.

Artists are the 81 vault artists with 20 or more songs, alphabetical, in phases of five. A simile is a line where like or as is a comparison. "I like" and "as soon as" are not counted. The literal half is the words after like or as. A candidate has to name a vault artist or a vault song title, and that name or title has to carry the joke. One short common word is not enough. LOW stays in the file.

## Phase 1

| Artist | Similes checked | Candidates | HIGH | MED | LOW |
| --- | ---: | ---: | ---: | ---: | ---: |
| 03 Greedo | 1378 | 0 | 0 | 0 | 0 |
| 21 Savage | 522 | 1 | 0 | 0 | 1 |
| Ballout | 59 | 0 | 0 | 0 | 0 |
| BashfortheWorld | 94 | 0 | 0 | 0 | 0 |
| BIA | 403 | 0 | 0 | 0 | 0 |
| Phase 1 total | 2456 | 1 | 0 | 0 | 1 |

Phase 1 LOW: 21 Savage, "Rider" — "All this ice on me, I look like a light show (Straight up)" — SPLIT of the vault artist Lightshow. Figurative half is not a Lightshow title.

## Phase 2

| Artist | Similes checked | Candidates | HIGH | MED | LOW |
| --- | ---: | ---: | ---: | ---: | ---: |
| Big Sean | 2633 | 2 | 0 | 0 | 2 |
| Blac Youngsta | 599 | 0 | 0 | 0 | 0 |
| BossMan Dlow | 357 | 0 | 0 | 0 | 0 |
| BSlime | 183 | 0 | 0 | 0 | 0 |
| Cardi B | 557 | 1 | 0 | 1 | 0 |
| Phase 2 total | 4329 | 3 | 0 | 1 | 2 |

Phase 2 LOW: Big Sean, "Say Ya Grace" — "the weekend" SOUNDALIKE of The Weeknd. Big Sean, "I Don’t Think They Want It" — "a light show" SPLIT of Lightshow.

Phase 2 MED: Cardi B, "Money" — "Sweet like a honey bun, spit like a Tommy gun." Exact vault titles Honey Bun and Tommy Gun, both by Quavo.

## Phase 3

| Artist | Similes checked | Candidates | HIGH | MED | LOW |
| --- | ---: | ---: | ---: | ---: | ---: |
| Cash Cobain | 1021 | 0 | 0 | 0 | 0 |
| Chance the Rapper | 1407 | 0 | 0 | 0 | 0 |
| Chief Keef | 2769 | 1 | 0 | 0 | 1 |
| DaBaby | 348 | 1 | 1 | 0 | 0 |
| Destroy Lonely | 1359 | 3 | 0 | 1 | 2 |
| Phase 3 total | 6904 | 5 | 1 | 1 | 3 |

Phase 3 HIGH: DaBaby, "Walker Texas Ranger" — "I'm in the rental truck sticked up like Walker Texas Ranger." Literal title is that song and the TV show. Figurative half is his song "STICKED UP."

Phase 3 MED: Destroy Lonely, "D4MG" — "Real rockstar, nigga, like Kurt Cobain." His songs "Real Rockstar*" and "Kurt Cobain*."

Phase 3 LOW: Chief Keef, "Back That Azz Up Remix*" — "the weekend" SOUNDALIKE of The Weeknd. Destroy Lonely, "GIVE YOU" — "battle of the bands," Lil Yachty's "Battle of the Bands (I'm Back)." Destroy Lonely, "Raver" — "a light show" SPLIT of Lightshow.

## Phase 4

| Artist | Similes checked | Candidates | HIGH | MED | LOW |
| --- | ---: | ---: | ---: | ---: | ---: |
| diamond* | 349 | 0 | 0 | 0 | 0 |
| Don Toliver | 753 | 0 | 0 | 0 | 0 |
| Drake | 3370 | 1 | 0 | 1 | 0 |
| Earl Sweatshirt | 1085 | 0 | 0 | 0 | 0 |
| EST Gee | 782 | 0 | 0 | 0 | 0 |
| Phase 4 total | 6339 | 1 | 0 | 1 | 0 |

Phase 4 MED: Drake, "Draft Day" — "And if I left this shit to chance I would've picked a name like Chance the Rapper." Exact artist Chance the Rapper. The everyday word is "chance" as luck, in the setup.

## Phase 5

| Artist | Similes checked | Candidates | HIGH | MED | LOW |
| --- | ---: | ---: | ---: | ---: | ---: |
| Fatt Smaxk | 111 | 1 | 0 | 1 | 0 |
| Fetty Wap | 1000 | 0 | 0 | 0 | 0 |
| Fivio Foreign | 561 | 0 | 0 | 0 | 0 |
| Frank Ocean | 512 | 1 | 0 | 0 | 1 |
| Fridayy | 86 | 1 | 0 | 1 | 0 |
| Phase 5 total | 2270 | 3 | 0 | 2 | 1 |

Phase 5 MED: Fatt Smaxk, "HOW WE COMING" — "On the paper route right now, bitch, I feel like Young Dolph, huh." Young Dolph's song "Paper Route." Fridayy, "You" — "Drip too hard like Gunna, fine like omotola." Gunna's song "Drip Too Hard."

Phase 5 LOW: Frank Ocean, "Reach For The Stars" — "party like the weekend," SOUNDALIKE of The Weeknd.

## Phase 6

| Artist | Similes checked | Candidates | HIGH | MED | LOW |
| --- | ---: | ---: | ---: | ---: | ---: |
| Future | 1888 | 0 | 0 | 0 | 0 |
| G Herbo | 1474 | 1 | 0 | 0 | 1 |
| GloRilla | 298 | 0 | 0 | 0 | 0 |
| Gucci Mane | 89 | 0 | 0 | 0 | 0 |
| Gunna | 2380 | 3 | 0 | 2 | 1 |
| Phase 6 total | 6129 | 4 | 0 | 2 | 2 |

Phase 6 MED: Gunna, "Gucci Gucci" — "Gucci gang like I'm Lil Pump." Lil Pump's "Gucci Gang." Gunna, "Back and Forth" — "I keep the blue hunnids with me like gang members (Blue hunnid)." Playboi Carti's "Blue Hunnids" and "GANG MEMBERS."

Phase 6 LOW: G Herbo, "Some Nights," and Gunna, "flooded" — "a light show," SPLIT of Lightshow.

Not opened yet: Homixide Gang through YUME (51 artists).
