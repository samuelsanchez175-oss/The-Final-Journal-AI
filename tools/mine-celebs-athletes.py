#!/usr/bin/env python3
"""Count actor / celeb / NBA / NFL name hits in the full 1.7M-bar catalog."""

from __future__ import annotations

import json
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DB = ROOT / "tools/bar-hits-catalog/BarHitsCatalog.sqlite"
OUT = ROOT / "docs/noun-bank-celebs.json"

# (chip, fts query, wiki title)
SEEDS: list[tuple[str, str, str, str]] = [
    # NBA
    ("Kobe", "kobe", "Kobe Bryant", "nba"),
    ("LeBron", "lebron OR \"le bron\"", "LeBron James", "nba"),
    ("Shaq", "shaq OR shaquille", "Shaquille O'Neal", "nba"),
    ("KD", "\"kd\" OR durant", "Kevin Durant", "nba"),
    ("Curry", "curry OR steph", "Stephen Curry", "nba"),
    ("Iverson", "iverson OR \"ai\"", "Allen Iverson", "nba"),
    ("Wade", "\"d wade\" OR dwade OR wade", "Dwyane Wade", "nba"),
    ("Melo", "melo OR anthony", "Carmelo Anthony", "nba"),
    ("Westbrook", "westbrook OR russ", "Russell Westbrook", "nba"),
    ("Harden", "harden OR \"the beard\"", "James Harden", "nba"),
    ("Giannis", "giannis", "Giannis Antetokounmpo", "nba"),
    ("Luka", "luka", "Luka Dončić", "nba"),
    ("Kawhi", "kawhi", "Kawhi Leonard", "nba"),
    ("Klay", "klay", "Klay Thompson", "nba"),
    ("Pippen", "pippen", "Scottie Pippen", "nba"),
    ("Magic", "\"magic johnson\"", "Magic Johnson", "nba"),
    ("Bird", "\"larry bird\"", "Larry Bird", "nba"),
    ("Kareem", "kareem", "Kareem Abdul-Jabbar", "nba"),
    ("Duncan", "\"tim duncan\"", "Tim Duncan", "nba"),
    ("Dirk", "dirk", "Dirk Nowitzki", "nba"),
    ("KG", "\"kg\" OR garnett", "Kevin Garnett", "nba"),
    ("T-Mac", "tmac OR \"t-mac\" OR mcgrady", "Tracy McGrady", "nba"),
    ("Vince Carter", "\"vince carter\"", "Vince Carter", "nba"),
    ("CP3", "cp3 OR \"chris paul\"", "Chris Paul", "nba"),
    ("Dame", "lillard OR dame", "Damian Lillard", "nba"),
    ("AD", "\"anthony davis\" OR \"ad\"", "Anthony Davis", "nba"),
    ("Ja", "\"ja morant\"", "Ja Morant", "nba"),
    ("Zion", "zion", "Zion Williamson", "nba"),
    ("Tatum", "tatum", "Jayson Tatum", "nba"),
    ("Jokic", "jokic", "Nikola Jokić", "nba"),
    ("Embiid", "embiid", "Joel Embiid", "nba"),
    ("Booker", "\"devin booker\" OR booker", "Devin Booker", "nba"),
    ("MJ", "\"michael jordan\" OR \"mj\"", "Michael Jordan", "nba"),
    # NFL
    ("Brady", "brady", "Tom Brady", "nfl"),
    ("Mahomes", "mahomes", "Patrick Mahomes", "nfl"),
    ("Odell", "odell OR obj OR beckham", "Odell Beckham Jr.", "nfl"),
    ("Randy Moss", "\"randy moss\" OR moss", "Randy Moss", "nfl"),
    ("Deion", "deion OR primetime OR \"prime time\"", "Deion Sanders", "nfl"),
    ("Jerry Rice", "\"jerry rice\"", "Jerry Rice", "nfl"),
    ("Vick", "\"michael vick\" OR vick", "Michael Vick", "nfl"),
    ("Cam", "\"cam newton\"", "Cam Newton", "nfl"),
    ("Lamar", "\"lamar jackson\"", "Lamar Jackson", "nfl"),
    ("Tyreek", "tyreek", "Tyreek Hill", "nfl"),
    ("Julio", "\"julio jones\"", "Julio Jones", "nfl"),
    ("Megatron", "megatron OR \"calvin johnson\"", "Calvin Johnson", "nfl"),
    ("TO", "\"terrell owens\" OR \"t.o.\"", "Terrell Owens", "nfl"),
    ("Saquon", "saquon", "Saquon Barkley", "nfl"),
    ("CMC", "\"christian mccaffrey\" OR cmc", "Christian McCaffrey", "nfl"),
    ("Burrow", "burrow OR \"joe burrow\"", "Joe Burrow", "nfl"),
    ("Jefferson", "\"justin jefferson\"", "Justin Jefferson", "nfl"),
    ("Rice", "\"jerry rice\"", "Jerry Rice", "nfl"),
    # Actors / celebs
    ("Denzel", "denzel", "Denzel Washington", "actor"),
    ("Will Smith", "\"will smith\"", "Will Smith", "actor"),
    ("Pacino", "pacino", "Al Pacino", "actor"),
    ("De Niro", "\"de niro\" OR deniro", "Robert De Niro", "actor"),
    ("Scarface", "scarface", "Al Pacino", "actor"),
    ("Leonardo", "dicaprio OR leonardo", "Leonardo DiCaprio", "actor"),
    ("Brad Pitt", "\"brad pitt\"", "Brad Pitt", "actor"),
    ("Jamie Foxx", "\"jamie foxx\"", "Jamie Foxx", "actor"),
    ("Samuel Jackson", "\"samuel l\" OR \"samuel jackson\"", "Samuel L. Jackson", "actor"),
    ("The Rock", "\"the rock\" OR \"dwayne johnson\"", "Dwayne Johnson", "actor"),
    ("Vin Diesel", "\"vin diesel\"", "Vin Diesel", "actor"),
    ("Tom Cruise", "\"tom cruise\"", "Tom Cruise", "actor"),
    ("Zendaya", "zendaya", "Zendaya", "celeb"),
    ("Beyonce", "beyonce OR beyoncé", "Beyoncé", "celeb"),
    ("Rihanna", "rihanna OR rih", "Rihanna", "celeb"),
    ("Kim K", "\"kim k\" OR kardashian", "Kim Kardashian", "celeb"),
    ("Kylie", "kylie", "Kylie Jenner", "celeb"),
    ("Kendall", "kendall", "Kendall Jenner", "celeb"),
    ("Halle", "\"halle berry\"", "Halle Berry", "celeb"),
    ("JLo", "jlo OR \"jennifer lopez\"", "Jennifer Lopez", "celeb"),
    ("Oprah", "oprah", "Oprah Winfrey", "celeb"),
    ("Obama", "obama", "Barack Obama", "celeb"),
    ("Tyler Perry", "\"tyler perry\"", "Tyler Perry", "actor"),
    ("Eddie Murphy", "\"eddie murphy\"", "Eddie Murphy", "actor"),
    ("Chris Rock", "\"chris rock\"", "Chris Rock", "celeb"),
    ("Dave Chappelle", "chappelle", "Dave Chappelle", "celeb"),
    ("Kevin Hart", "\"kevin hart\"", "Kevin Hart", "celeb"),
    ("Michael Jackson", "\"michael jackson\" OR \"mj\"", "Michael Jackson", "celeb"),
    ("Prince", "prince", "Prince (musician)", "celeb"),
    ("Elvis", "elvis", "Elvis Presley", "celeb"),
    ("Marilyn", "marilyn", "Marilyn Monroe", "celeb"),
    ("Iman", "iman", "Iman (model)", "celeb"),
    ("Naomi", "\"naomi campbell\"", "Naomi Campbell", "celeb"),
    ("Angelina", "angelina OR jolie", "Angelina Jolie", "celeb"),
    ("Megan Fox", "\"megan fox\"", "Megan Fox", "celeb"),
    ("Jada", "\"jada\"", "Jada Pinkett Smith", "celeb"),
    ("Selena", "selena", "Selena Quintanilla", "celeb"),
    ("Adele", "adele", "Adele", "celeb"),
    ("Taylor Swift", "\"taylor swift\"", "Taylor Swift", "celeb"),
]


def main() -> None:
    con = sqlite3.connect(f"file:{DB}?mode=ro", uri=True)
    rows = []
    for chip, query, wiki, kind in SEEDS:
        try:
            n = con.execute(
                "SELECT COUNT(*) FROM bars_fts WHERE bars_fts MATCH ?", (query,)
            ).fetchone()[0]
        except sqlite3.OperationalError:
            n = 0
        rows.append({"chip": chip, "bars": n, "wiki": wiki, "kind": kind, "query": query})
        print(f"{n:6}  {chip:20}  {kind}")
    rows.sort(key=lambda r: -r["bars"])
    keep = [r for r in rows if r["bars"] >= 8]
    OUT.write_text(json.dumps({"keep": keep, "all": rows}, indent=2) + "\n")
    print(f"wrote {OUT} keep={len(keep)}")


if __name__ == "__main__":
    main()
