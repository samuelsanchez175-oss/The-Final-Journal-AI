# Drake missing-url recovery

Started by Codex after taking over the stalled Grok terminal work.

The Drake click log has 1,204 song rows. After correcting the watcher to count `status: done` zero-note songs as resolved, the real open lane is 211 `status: missing` rows. These rows have no `genius_url`, so the job is URL recovery or confirmation that the page stays unresolved.

## Slice 1

Browser searched Genius for representative missing rows. No usable lyric result was returned for these probes:

| song | search |
| --- | --- |
| Hotline Bling (Live From Maida Vale) | Drake Hotline Bling Live From Maida Vale Genius |
| In My Feelings (Drake Remix) | Drake In My Feelings Drake Remix Genius |
| Back 2 Back (Yung Lambo Diss) | Drake Back 2 Back Yung Lambo Diss Genius |
| Loyalty (Remix) | Drake Loyalty Remix Genius |
| Vice Lord Poetry | Drake Vice Lord Poetry Genius |

Next pass should continue missing-url recovery in batches, not re-open Veeze. Veeze is verified complete: 96 of 96 song rows are `status: done`.

## Slice 2

Continued the Drake missing-url pass against the next unresolved songs. These were checked as recovery candidates, not left idle:

| song | result |
| --- | --- |
| Hotline Bling / party favor | No clean Drake Genius lyric URL surfaced. Treat as unresolved mashup/cover entry. |
| HOTLINE BLING X TEENAGE FEVER | No clean Drake Genius lyric URL surfaced. Treat as unresolved mashup entry. |
| Hold On, We're Going Home (BBC Radio 1 Live Lounge) | No clean Drake Genius lyric URL surfaced. Treat as unresolved live-cover entry. |
| Nice For What/Friends/No Scrubs | No clean Drake Genius lyric URL surfaced. Treat as unresolved medley entry. |

The active lane remains Drake URL recovery. The next useful batch should skip Veeze and continue Drake rows after `Nice For What/Friends/No Scrubs`, paying special attention to scraped image-title rows such as `Only`, `SICKO MODE`, `Poetic Justice`, `Work`, and `Fuckin' Problems`, because those may need artist/title cleanup before they can be marked resolved.

## Slice 3

Classified malformed Drake scrape rows that currently store an entire Genius result-card image tag in the `song` field. These should be searched and resolved by normalized title/artist, not by the raw stored string:

| log line | normalized target | raw scrape evidence |
| --- | --- | --- |
| 1062 | Nicki Minaj - Only | alt text `Only`; visible card text `OnlyNicki Minaj3.9M` |
| 1940 | Travis Scott - SICKO MODE | alt text `SICKO MODE`; visible card text `SICKO MODETravis Scott10.3M` |
| 2717 | Kendrick Lamar - Poetic Justice | alt text `Poetic Justice`; visible card text `Poetic JusticeKendrick Lamar5M` |
| 4280 | Rihanna - Work | alt text `Work`; visible card text `WorkRihanna8.4M` |
| 4532 | A$AP Rocky - Fuckin' Problems | alt text `Fuckin' Problems`; visible card text `Fuckin' ProblemsA$AP Rocky8.1M` |

Those five rows look like feature/collaboration pages involving Drake, so they are likely recoverable after cleanup. They should not be counted as normal missing Drake solo pages.

## Slice 4

Subagent Wegener continued the Drake missing-row triage after the malformed-card slice. No files were edited by the subagent. These rows are now classified for the next recovery pass:

| log line | cleaned song title | likely category | normalized search target |
| ---: | --- | --- | --- |
| 4610 | Splash Brothers | feature/collab page | French Montana - Splash Brothers feat. Drake |
| 4791 | Mute | likely nonrecoverable | Drake - Mute |
| 4833 | 2AM | likely nonrecoverable | Drake - 2AM |
| 4879 | Fuck da Bullshit | real Drake page | Drake - Fuck da Bullshit |
| 4933 | Unthinkable | feature/collab page | Alicia Keys - Un-Thinkable (I'm Ready) Remix feat. Drake |
| 5017 | Facts (Charlie Heat Version) | malformed scrape | Kanye West - Facts (Charlie Heat Version) |
| 5109 | SMOKED OUT | likely nonrecoverable | Drake - SMOKED OUT |
| 5127 | Tunechi's Room | cover/medley | Lil Wayne - Tunechi's Room |
| 5242 | SIRENS | malformed scrape | Travis Scott - SIRENS |
| 5305 | You da Baddest | malformed scrape | Future - You da Baddest |
| 5402 | Hittas | feature/collab page | Lil Wayne - Hittas feat. Drake |
| 5525 | Eurotrip 3 | likely nonrecoverable | Eurotrip 3 Drake |
| 5695 | Flawless / Feeling Myself (Homecoming Live) | cover/medley | Beyonce - Flawless / Feeling Myself Homecoming Live |
| 5698 | Nikki Beach | malformed scrape | Future / Metro Boomin - Nikki Beach |
| 5699 | See Bout It | likely nonrecoverable | Drake - See Bout It |
| 5801 | @Ppr0digy Disstrack | likely nonrecoverable | @Ppr0digy Disstrack |
| 5802 | All Good | likely nonrecoverable | Drake - All Good |
| 5858 | Love My Team | likely nonrecoverable | Drake - Love My Team |
| 5959 | DRUNK OFF U | likely nonrecoverable | Drake - DRUNK OFF U |
| 5993 | MORE LOVE | likely nonrecoverable | Drake - MORE LOVE |

## Slice 5

Subagent Nash completed the focused malformed-result-card pass. I reconciled the line numbers against the live `drake.jsonl`; the corrected rows are:

| log line | normalized target | Drake feature/collab page? | candidate Genius URL |
| ---: | --- | --- | --- |
| 1062 | Nicki Minaj - Only | Yes | `https://genius.com/Nicki-minaj-only-lyrics` |
| 1940 | Travis Scott - SICKO MODE | Yes | `https://genius.com/Travis-scott-sicko-mode-lyrics` |
| 2717 | Kendrick Lamar - Poetic Justice | Yes | `https://genius.com/Kendrick-lamar-poetic-justice-lyrics` |
| 4280 | Rihanna - Work | Yes | `https://genius.com/Rihanna-work-lyrics` |
| 4532 | A$AP Rocky - Fuckin' Problems | Yes | `https://genius.com/A-ap-rocky-fuckin-problems-lyrics` |

These are inferred candidate URLs from local title/artist evidence, not live-verified URLs. They should be treated as non-Drake lead-artist feature/collab pages involving Drake, not normal Drake solo missing pages.

## Slice 6

Subagent Popper continued Drake missing-row triage after line 5993. No files were edited by the subagent. These rows are now classified for the next recovery pass:

| log line | cleaned title | likely category | normalized search target |
| ---: | --- | --- | --- |
| 6090 | Born 2 Be Great | likely nonrecoverable/unreleased | Drake - Born 2 Be Great |
| 6091 | Buy a Heart | non-Drake lead/reference page | Nicki Minaj - Buy a Heart |
| 6179 | Heavens EP | non-Drake lead/reference page | J. Cole - Heaven's EP |
| 6301 | BZNS | likely nonrecoverable/unreleased | Drake - BZNS |
| 6302 | Days in the West | real Drake page | Drake - Days in the West |
| 6342 | Girls Love Rihanna | likely nonrecoverable/variant title | Drake - Girls Love Rihanna |
| 6346 | Jus Know (Demo) | demo/unreleased variant | Drake - Jus Know Demo |
| 6396 | Say Hello | likely nonrecoverable | Drake - Say Hello |
| 6397 | Terrible 2's | likely nonrecoverable | Drake - Terrible 2's |
| 6439 | Whiter Then Blow | likely nonrecoverable/typo title | Drake - Whiter Then Blow |
| 6440 | Yesterday | likely nonrecoverable/ambiguous title | Drake - Yesterday |
| 6561 | SON PALE$ | likely malformed/non-Drake page | SON PALE$ Drake |
| 6584 | Aripi | likely malformed/non-Drake page | Aripi Drake |
| 6626 | Keep Calm | feature/collab page | Busta Rhymes - Keep Calm feat. Drake |
| 6627 | Love You Like I Do | likely nonrecoverable/unreleased | Drake - Love You Like I Do |
| 6669 | Please Don't Fall In Love With Me | non-Drake lead/reference page | Khalid - Please Don't Fall In Love With Me |
| 6842 | Mi Gente (Homecoming Live) | cover/medley/live page | Beyonce - Mi Gente Homecoming Live |
| 6951 | FANCY BARBIE | likely nonrecoverable/variant title | Drake - FANCY BARBIE |
| 6952 | Haunted | likely nonrecoverable/ambiguous title | Drake - Haunted |
| 7035 | Bless ME | likely nonrecoverable | Drake - Bless ME |
| 7036 | Dawn Of A Young King | likely nonrecoverable | Drake - Dawn of a Young King |
| 7045 | Live Up to My Name | non-Drake lead/reference page | Baka Not Nice - Live Up to My Name |
| 7094 | Poetic Justice (Retrial) | derivative feature/collab page | Kendrick Lamar - Poetic Justice Retrial feat. Drake |
| 7130 | TABLE FOR ONE Episode 2 Tracklist | tracklist page | Drake - TABLE FOR ONE Episode 2 Tracklist |
| 7154 | 3AM in the Yams (Original) | unreleased/original variant | Drake - 3AM in the Yams Original |
