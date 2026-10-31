# Narrowed missing-comma recount

Report only. The lyric vault was opened read-only. No app change.

The comma is the breath in a bar. This pass only suggests a missing comma. A bar is flagged when all of these are true:

- `bars.syllables` is 10 or more.
- The clause starter is `cuz` (also `coz`), `but`, `when`, `so`, `'cause` (also bare `cause`), `while`, or `till` (also `til` and `'til`).
- That starter is not the first word.
- The starter sits at 30% through 60% of the bar. The percent is the starter's character index divided by the length of the line, rounded to one decimal, same measure as the first pass.
- The first-pass blocks still apply: `nothing but`, `X but X`, cousin `cuz`, `love`/`like`/`hate`/`know when`, `a while`, `wait 'til`, and `so` plus a degree word.
- Words inside `()` or `[]` are skipped. A breath comma already sitting on the starter is skipped.

Subject-verb splits, mid-phrase splits, and a second `I` are not in this flag set. `flags.jsonl` in this folder is this set only. `comma-prompt-for-grok.md` is unchanged.

## Count

Opened `BarHitsCatalog.sqlite` with `mode=ro&immutable=1`. `COUNT(*)` from `bars` was 1,708,472. The file was 563,433,472 bytes, mtime 2026-10-31 11:56:52 EDT, and those two figures were the same after the read.

| | |
|---|---|
| Bars in the vault | 1,708,472 |
| Bars with 10 or more syllables | 1,108,252 |
| Missing-comma flags | 45,202 |

Flags are rows. One bar can carry more than one starter.

| Rule | Flags |
|---|---|
| before when | 14,102 |
| before 'cause | 12,117 |
| before but | 10,277 |
| before so | 3,503 |
| before till | 2,844 |
| before while | 2,095 |
| before cuz | 264 |
| Total | 45,202 |

## Hand-check

50 new flags. Seed `20261032`. Reservoir draw over the 45,190 flags whose line was not in the earlier missing-comma hand-check. Twelve lines from that earlier 33 still matched this rule and stayed out of the draw.

A hit is a breath before a new clause. A borderline call is a miss.

**45 of 50. Precision 90%.**

Misses:

- 27. Travis Scott, "Feel It". "Shawty, I won't stop 'til you feel it (Feel it)". `won't stop 'til` is one span, the same class as `wait 'til`.
- 37. YFN Lucci, "Trap". "Intolerant to the fuck shit when you fuck with this bloodline". `the fuck shit when` can be the thing itself, and `intolerant ... when` is one claim.
- 39. Lil Uzi Vert, "Red Wraith". "I ain't even knew it but two hours later". `but` does not open a clause.
- 45. Juice WRLD, "Lifestyle Urgent". "You got the basic one, I got the one when the roof leave (Leave)". `the one when` is a relative.
- 49. EST Gee, "Is Heaven For A Gangsta". "Uh, for all the niggas who meant well but fell 'cause ain't nobody tryna hear 'em". `meant well but fell` is one subject and two verbs.

## The 50

1. Hit. BashfortheWorld, "Super Pussy". "Still riding with my folks till my folks hit a billion". before till, 50.0%, 13 syllables.
2. Hit. Destroy Lonely, "ok / what i do". "Okay, they aight, they cool but they can't do what we do". before but, 50.0%, 13 syllables.
3. Hit. Moneybagg Yo, "Black Feet". "Just moved in the spot so I had to fuck her on the pallet (ugh)". before so, 36.5%, 17 syllables.
4. Hit. Chief Keef, "What Can I Say". "She want me to stick her 'cause I'm sharp like an arrow". before 'cause, 45.5%, 13 syllables.
5. Hit. J. Cole, "Back 2 The Topic". "Turnin’ on a beat but yall ready for no violencе". before but, 37.5%, 13 syllables.
6. Hit. Fetty Wap, "Before I Blew". "DJ play my shit when I walk in (walk in)". before when, 40.0%, 10 syllables.
7. Hit. Money Man, "Poverty". "She give me that cat when I pop an Amex". before when, 53.8%, 11 syllables.
8. Hit. Chief Keef, "Medicine". "I'ma spend that money 'cause I get that, ayy". before 'cause, 50.0%, 11 syllables.
9. Hit. Veeze, "Law N Order". "Mask on in the kitchen while I'm whipping, scraping the glass". before while, 37.7%, 14 syllables.
10. Hit. Lil Uzi Vert, "Go Off". "Drive at night, I chop my top so I can relate to the stars". before so, 51.7%, 15 syllables.
11. Hit. Quality Control, "Hunnits Trynna Run". "Fuck 12, I'm out this bitch trappin' 'til they come and get me (Fuck 'em)". before till, 50.7%, 15 syllables.
12. Hit. YFN Lucci, "Talk That Shit". "You know I had change when I came don't front". before when, 48.9%, 10 syllables.
13. Hit. Meek Mill, "Don’t Follow The Heathens Freestyle". "And I had to be ready when them killers confront you". before when, 42.3%, 14 syllables.
14. Hit. Quality Control, "Bad Bad Bad". "Niggas stealin' drip but it don't matter, they don't wear it right". before but, 31.8%, 15 syllables.
15. Hit. Ty Dolla $ign, "Over". "With my niggas niggas when I'm rolling rolling". before when, 47.8%, 12 syllables.
16. Hit. Trippie Redd, "Everything Ok". "They ain't got no lives so they wanna take my life". before so, 48.0%, 13 syllables.
17. Hit. JAY-Z, "11 Minute Freestyle on Hot 97". "I could do the time but I ain't tryna' get a case man". before but, 37.7%, 14 syllables.
18. Hit. Chief Keef, "I Thought I Had One". "Set the Lambo' when that bitch on bed rest". before when, 35.7%, 10 syllables.
19. Hit. Rick Ross, "GUMMO (Remix)". "Thank God Lil Koly rappin' 'cause he used to be a robber". before 'cause, 48.2%, 16 syllables.
20. Hit. Veeze, "Idols". "When the bitch you love the most leave while you broke, that life changing". before while, 52.7%, 15 syllables.
21. Hit. Lil Uzi Vert, "Skin Crawl (I Got The Vision)". "Save her number as "Percocet" 'cause this girl a ten". before 'cause, 57.7%, 13 syllables.
22. Hit. NAV, "Frequently". "Yeah, all my pockets full but I feel like I’m on E". before but, 52.0%, 14 syllables.
23. Hit. Tyler, the Creator, "Goblin". "I mean, I'm not that great of a rapper but as a whole, I'm pretty cool, right?". before but, 50.0%, 19 syllables.
24. Hit. Yeat, "Appear". "I want my diamonds dancing so I bought that bitch from Eliantte". before so, 42.9%, 15 syllables.
25. Hit. Lil Uzi Vert, "Iced Out My Wrist". "My bitch keep her money but she think she getting off (Ayy, ayy, ayy)". before but, 34.8%, 16 syllables.
26. Hit. Drake, "Summer jam". "And my team by my side so they might fish in". before so, 52.3%, 11 syllables.
27. Miss. Travis Scott, "Feel It". "Shawty, I won't stop 'til you feel it (Feel it)". before till, 44.7%, 11 syllables.
28. Hit. Rick Ross, "Quarter Brick". "Do this for the dope boys 'til the day they kill us all". before till, 47.3%, 13 syllables.
29. Hit. Lil Uzi Vert, "Blue Tips". "Never saw that 'cause it got the blue tips, uh". before 'cause, 32.6%, 11 syllables.
30. Hit. Justin Bieber, "I Would". "I would build the love of river wide so that it never runs dry, yeah". before so, 54.4%, 17 syllables.
31. Hit. Offset, "New Year". "She was callin' too much so the bitch got blocked". before so, 51.0%, 12 syllables.
32. Hit. Lil Uzi Vert, "Try Me (Molly)". "Nowadays I ain't high, I swear I ain't fly so I mind my business (Let's go)". before so, 57.3%, 20 syllables.
33. Hit. Yo Gotti, "H.O.E. (Heaven on Earth)". "Why you hard on your niggas but you soft on a ho?". before but, 57.1%, 13 syllables.
34. Hit. YoungBoy Never Broke Again, "Steady Calling*". "Brother, he scrapin' so he could take care of me (Care of me, yeah)". before so, 31.3%, 16 syllables.
35. Hit. Justin Bieber, "Thinking About You". "Man I heard some things but I don't know what's true". before but, 46.2%, 11 syllables.
36. Hit. Ken Carson, "Celebrate". "My bitch ass fat but I don't need no cake". before but, 41.5%, 10 syllables.
37. Miss. YFN Lucci, "Trap". "Intolerant to the fuck shit when you fuck with this bloodline". before when, 45.9%, 15 syllables.
38. Hit. Kodak Black, "Inside I Suffer". "Follow every rainbow 'til you find your place". before till, 46.7%, 12 syllables.
39. Miss. Lil Uzi Vert, "Red Wraith". "I ain't even knew it but two hours later". before but, 52.5%, 11 syllables.
40. Hit. JAY-Z, "Good Girls Gone Bad". "Now you wanna fuck me 'cause you know I got my bands up, yeah". before 'cause, 36.1%, 15 syllables.
41. Hit. Young Dolph, "Really". "I'ma call you back when I get to handle business (Yeah)". before when, 34.5%, 14 syllables.
42. Hit. Don Toliver, "Kush Coma". "I know we cooling off but I need that pie, girl". before but, 46.8%, 12 syllables.
43. Hit. Lil Wayne, "HUNCHO DREAMS". "Pullin' on yo' weave, 'cross the room when I pipe that ass (Pipe it)". before when, 55.9%, 15 syllables.
44. Hit. Destroy Lonely, "Mud Baby". "Huh, I got a Rick Owens shade so I can’t see a lame bitch". before so, 52.6%, 16 syllables.
45. Miss. Juice WRLD, "Lifestyle Urgent". "You got the basic one, I got the one when the roof leave (Leave)". before when, 57.8%, 15 syllables.
46. Hit. Moneybagg Yo, "Trap Or What". "I can't make this shit up 'cause I really did it". before 'cause, 54.2%, 12 syllables.
47. Hit. Destroy Lonely, "Been Knew". "And she gon' drop her pants when I link up with her". before when, 54.9%, 12 syllables.
48. Hit. Quality Control, "Ain’t Mine". "Wipe the gloss off your lip when you suck the dick". before when, 56.0%, 11 syllables.
49. Miss. EST Gee, "Is Heaven For A Gangsta". "Uh, for all the niggas who meant well but fell 'cause ain't nobody tryna hear 'em". before but, 46.9%, 20 syllables.
50. Hit. Lil Uzi Vert, "I Don’t Need You (Get Through)". "Take pictures, we show our shoes 'cause we don't show our face". before 'cause, 53.2%, 14 syllables.

Paths: `docs/flow-rules/comma-pass/report.md`, `flags.jsonl` (45,202 lines), `examples.md`.
