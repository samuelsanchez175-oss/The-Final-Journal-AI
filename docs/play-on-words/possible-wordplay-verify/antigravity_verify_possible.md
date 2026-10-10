# Anti-Gravity job: second-hand verification of 31 "possible" wordplay bars (Penwork)

Run this in its OWN chat, separate from the all-artists run. Don't touch that run or its files.

## Why this job exists
Penwork collects rap wordplay in a fixed format. Each bar has a SETUP (the words that cue the hidden meaning), the PLAY (the exact words he plays on), and HEARD AS (what it becomes). Example: NoCap, "Pain Show": "Remember dreamin' 'bout them **presidents** / Me and Lil ***Joe*** talkin' 'bout shit we couldn't ***buy 'den***". The setup is "presidents", the play is "Joe … buy 'den", and it's heard as **Joe Biden**. The gold standard is NoCap's "From a cell to a ***mansion*** like I'm **Quagmire**", where mansion is heard as "man chin".

The 31 bars below each LOOK like a flip, but the Genius community note doesn't confirm it. It's silent, only repeats the lyric, hedges, or corrects the lyric. Samuel can see the possibility in each one but can't confirm it either. Your job is to confirm or reject each one using outside evidence. Never decide one is right because it sounds right.

Project root (quote it, the path has spaces): "/Users/samuel/Music/all xcode projects files/pennworkstudios.nosync"
Input: docs/play-on-words/possible-wordplay-verify/possible-wordplay.jsonl (31 rows: id, artist, song, bar, setup_spans, play_spans, heard_as, pair, why_unconfirmed, note_excerpt, genius_annotation_url, votes)

## The 31 bars
| ID | Artist | Song | Bar | Proposed flip |
|---|---|---|---|---|
| P01 | NoCap | By Tonight | And I'm like Shaquille, I bow my head and I kneel | Shaquille → kneel = O'Neal  ⇒ Shaquille O'Neal |
| P02 | NoCap | Time Will Tell | Went and seen Johnny soon as I got up out the cage | Johnny → cage = Cage  ⇒ Johnny Cage |
| P03 | NoCap | Time Will Tell | Niggas crossed it like Paul, I was stuck in that box I ain't talkin' 'bout Jake | crossed it like Paul + box → Jake = Jake  ⇒ Jake Paul |
| P04 | NoCap | Ain’t Right | I'm fuckin' snow bunnies in these carats | snow bunnies → carats = carrots  ⇒ carrots |
| P05 | NoCap | Rogerville | Yeah, bad lil' bitch from Pittsburgh, she was all Ben ( She was all Ben ) Yeah, bad lil' bitch from Pittsburgh, she was all ten ( Yeah, yeah ) | Pittsburgh → all Ben = Ben  ⇒ Ben Roethlisberger |
| P06 | NoCap | FreeStyle | My outfit Gucci, I’m just tryna maintain | (no setup) maintain = mane-tain  ⇒ mane-tain |
| P07 | NoCap | House Bigger | Bad bitch, she hell, but I copped her like the Lakers | Lakers → she hell = heli- + copped her = -copter  ⇒ helicopter |
| P08 | NoCap | So Lost / No Promises | I try to run away from pain, I just can't avoid it | (no setup) pain = paying + avoid = afford  ⇒ paying / afford |
| P09 | NoCap | Judge the Jury | Girl, can you give me the same feeling as this Wockhardt? 'Cause if you can, then maybe that would solve the problem | same feeling → Wockhardt = heart  ⇒ heart |
| P10 | NoCap | Mistake | I ain't talking food, I just fucked two bitches by mistake But I don't go on dinner dates, bitches come from different ways Got AK's on the interstate, bustdown on my timeframe | food + dinner dates → mistake = steak + ways = Waze  ⇒ steak / Waze |
| P11 | NoCap | Casino | The fеar gon' roll in when he tired I called him too (Roll tide) | (no setup) roll = Roll + tired = Tide + called him too = Tua  ⇒ Roll Tide / Tua |
| P12 | NoCap | Planet Out | I can’t plan it out ’cause I’m always on the go | (no setup) plan it = planet + on the go = globe  ⇒ planet / globe |
| P13 | Drake | The Grind | You know me if you had a job at 16 and under yup | (no setup) job = child  ⇒ child |
| P14 | Drake | Diced Pineapples | Hate when they be too anxious though, hate when they be too dull | (no setup) dull = Dole  ⇒ Dole |
| P15 | Drake | SOMETHING ABOUT YOU | You're babysittin' that rosé (Come on, bitch) | (no setup) rosé = Rozay  ⇒ Rozay (Rick Ross) |
| P16 | Drake | Stuntin | The supplement I've taken got me feelin' mighty | (no setup) mighty = My Tee  ⇒ My Tee |
| P17 | Drake | No Brakes | And my diamonds offset like a Migo | (no setup) offset = Offset  ⇒ Offset (Cuervo/Quavo not in this bar) |
| P18 | Drake | Cannonball Remix | Tryna make my money stretch like the city at home | (no setup) the city at home = Santonio Holmes  ⇒ Santonio Holmes |
| P19 | Drake | Mine | You the one they hate, this come with that (Yeah) | (no setup)  |
| P20 | Veeze | Get Lucki | I'm gettin' too hot, man, fan me (They know) | (no setup) man, fan me = Fanum  ⇒ Fanum |
| P21 | Veeze | This That One | Bill, but I’m not Bradley | Bradley → Bill = Beal  ⇒ Bradley Beal |
| P22 | Veeze | GAIG | I wanna take you to France and kiss you in French (Moi, moi) | France + French → Moi, moi = muah  ⇒ muah |
| P23 | Veeze | Luv the Tour | She up first like Dub E | (no setup) Dub E = Doug E  ⇒ Doug E. Fresh |
| P24 | Veeze | Millions | All these drugs, they make my heart beat fast, I’m damn near carried out | heart beat fast → carried out = Curry'd out  ⇒ Curry'd out |
| P25 | Veeze | Get Lucki | Stuff twenty thou' in skinny pants, I call that a Harriet Tubman (Frrt, beep) | (no setup) Harriet Tubman = $20 bill  ⇒ Harriet Tubman ($20) |
| P26 | Veeze | Still Tippin | My momma done told me tricks for kids | (no setup) tricks for kids = Trix  ⇒ Trix |
| P27 | Veeze | Get Lucki | He wanted a split of good, I pulled up and served him half Oprah | (no setup) half Oprah = ovary  ⇒ ovary |
| P28 | Veeze | Choppas In Hawaii | Pint of the TEC, I took the red to the neck, feel just like a whitey | (no setup) whitey = Whitney  ⇒ Whitney Houston |
| P29 | Juice WRLD | Autograph V2 (Stem) | I always use a rubber, bitch I need the tire (Bitch I need the tire) | rubber → tire = tie her  ⇒ tie her |
| P30 | Juice WRLD | Barry Bonds (Lock On) | My eyes got big off the molly, raw | (no setup) molly, raw = Maaly Raw  ⇒ Maaly Raw |
| P31 | Juice WRLD | 100 Band Jugg Freestyle | I’m like a UCLA Bruin But I keep them Trojans, mm | UCLA Bruin → Trojans = Trojans (condoms)  ⇒ Trojan condoms |

## How to verify each one
1. **Check the lyric is right.** Compare the bar against the full Genius lyrics and at least one other lyric source (Musixmatch, or Apple Music or Spotify synced lyrics through a web search). If the transcription is wrong in a way that kills the flip, the verdict is REJECTED with `lyric_wrong`. Record the correct line.
2. **Look for a second source that states the flip plainly, with no hedging.** Accept any one of these:
   - another Genius annotation, or the song's About or Q&A section, on the same song that states it plainly
   - a verified-artist annotation, or the artist explaining it themselves (an interview, social post or video)
   - a breakdown from a reputable outlet (Genius verified or news, Complex, XXL, HotNewHipHop or similar) that states it plainly
   - two independent fan sources that each state the same flip plainly (for example a Reddit thread and a YouTube breakdown). One fan source alone is not enough.
   Hedged wording ("maybe", "could be", "sounds like he might", "possibly", "I think") doesn't count as confirmation.
3. **Sound check, as supporting evidence only.** Say whether the heard word is a real near-homophone of the play span, with a short phonetic note (for example kneel /niːl/ vs O'Neal /oʊˈniːl/). A sound match alone can never confirm a bar.
4. **Context check.** Does the setup word actually point to the flip, using the same subject on the same bar or the next one? A flip with no supporting context leans toward rejection.

## Verdicts (one per bar)
- `CONFIRMED`: step 2 found a qualifying source. Give the URL and quote it (300 characters or less).
- `REJECTED`: the lyric is wrong, a source contradicts the flip, the sound doesn't work, or the context points somewhere else. Give the reason code: `lyric_wrong`, `contradicted`, `sound_mismatch`, `no_context` or `different_flip`.
- `STILL_UNSURE`: you found no qualifying source either way. Say what you searched.
- If the real flip turns out to be different from the one proposed (for example the Drake "No Brakes" bar is about Quavo/Cuervo, not just Offset), use `different_flip`. Give the corrected setup, play and heard_as, plus the source, and mark it CONFIRMED only if that corrected flip has a qualifying source.

Fix the setup and play spans if your evidence shows they're marked wrong. Spans must be exact substrings of the bar, with character offsets.

## Output
Write `docs/play-on-words/possible-wordplay-verify/verified.jsonl` with one row per id and these fields: id, artist, song, bar (corrected if needed), verdict, reason_code, heard_as, setup_spans, play_spans, sources [{url, quote, kind}], sound_note, notes.
Write `docs/play-on-words/possible-wordplay-verify/verified.md` as a summary table with columns: ID, bar, flip, verdict, best source. Put counts by verdict at the top.

## Guardrails
- The all-artists Anti-Gravity run (run_all_artists.py) is using Genius right now. Use ONE worker, keep at least 8 seconds between Genius requests, and use per_page=5 on searches. On any HTTP 429, stop all Genius requests for 15 minutes. After a second 429, finish what you can from non-Genius sources and stop. Other sites: be polite, one request at a time.
- READ ONLY everywhere except the possible-wordplay-verify/ folder. Don't edit Swift files, BarHitsCatalog.sqlite, unwired-chips.md, the noun or chip bank, genius-clicks/*, wordplay-highlights.jsonl or live-board/server.py. Don't promote anything into the app; Samuel reviews first.
- Don't kill or disturb any process you didn't start.
- Never invent a source, quote or URL. If you can't find one, the verdict is STILL_UNSURE.

## Stop point
When all 31 rows have a verdict, stop. Post Samuel a summary with the counts by verdict, every CONFIRMED bar with its source, every different_flip correction, and the bars still unsure.
