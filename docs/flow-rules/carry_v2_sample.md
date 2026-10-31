# Grammar-based carry v2 — spaCy POS, order-preserved subset

**Subset:** 593 order-preserved Gunna songs (25361 lines, 24768 adjacent pairs). spaCy `en_core_web_sm`. Decision tree in header comment of `scripts/17_carry_v2.py`.

**Sample 200 pairs — auto-carry: 18/200 = 9.0%**

| # | carry? | cur | next | cur_verb | nxt_verb | reasons |
| ---:| :-:| --- | --- | :-:| :-:| --- |
| 1 | no | 'I said the lights shine bright on the world, the worsts' | 'Tryna live it up and live' | ✓ | ✓ | — |
| 2 | no | 'Like oh (Skrrt), just put on my tab (My tab)' | "I don't see the prices, throw it in my bag (In my bag)" | ✓ | ✓ | — |
| 3 | no | 'When I met that bitch, I ain’t know she was layin’ up witchu' | 'When I met that bitch I ain’t even know she knew you' | ✓ | ✓ | — |
| 4 | no | 'Got her pregnant, had to buy her a Dodge' | 'Rent a million, this is not a facade' | ✓ | ✓ | — |
| 5 | no | "Tell the city 'bout my love, I even post her" | "Pourin' all this lean in my styrofoam cup" | ✓ | ✗ | — |
| 6 | no | 'They felt sunny days and they wish for a storm' | 'Fly in the sky, young nigga airborne' | ✓ | ✓ | — |
| 7 | no | 'I knew I would figure it out (I knew)' | 'I took the millionaire route (Run it up)' | ✓ | ✓ | — |
| 8 | no | 'I got RPs and pure codeine' | 'I get too high off memories' | ✓ | ✓ | — |
| 9 | no | 'Now I pull up outside and I park the Jag' | 'I can see you through the glass nigga digi-dash' | ✓ | ✓ | — |
| 10 | no | "All yo' friends want you to leave, but you know yo' love ain’t neglected" | "We some multi-millionaires, but we still thuggin' and reckless" | ✓ | ✓ | — |
| 11 | no | 'Catch your bitch and watch his bitch lush' | 'Drain the babies, baby, better not flush' | ✓ | ✓ | — |
| 12 | YES | 'G5 and not the propellers (G5 and not the propellers)' | "Told my niggas we never gon' let up (Gon' let up)" | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 13 | no | "I told my dogs we eatin', I do what they say" | "Shit ain't been the same ever since I met Ye, yeah" | ✓ | ✓ | — |
| 14 | YES | 'All this hi-tec and wockhardt on my back (-hardt on my back)' | "Shoppin' out of town, I got Phillipine" | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 15 | no | 'Memphis got the money, babes' | 'I popped a bean and I gave my bitch a Xanny (a Xanny)' | ✓ | ✓ | — |
| 16 | YES | 'Half of niggas really phony' | 'Finna wake these niggas' | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 17 | no | "I'll pull up with a pink toe, I'm whippin', she suckin' this dick (Ear Drummers)" | "I put some diamonds on her toes, let that ho know that I'm rich" | ✓ | ✓ | — |
| 18 | no | 'Big body whips, extended clip' | 'Codeine to sip, Glock on my hip' | ✓ | ✓ | — |
| 19 | no | "Adderall ('Rall), mary jane keepin' me geeked (Geeked)" | "This freaky girl (Girl), keep on askin' me for the D (D)" | ✓ | ✓ | — |
| 20 | no | "Strokin' it slow in her kitty (Stroke)" | 'Flew her to L.A. from Philly (Gone)' | ✓ | ✓ | — |
| 21 | no | 'Yeah, make that ho stay over there' | 'She traded on me, how it feel?' | ✓ | ✓ | — |
| 22 | no | 'If you not having no bag, then that mean that you are not working' | "I'm just not goin' out sad, you selling pussy for purchase" | ✓ | ✓ | — |
| 23 | YES | "Drinkin' promethazine, me and my slime" | 'Add a few shrooms, top of my tongue, I see black lines' | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 24 | no | "I ain't fine, niggas ‘round me came up ain't have nun" | 'Tryna step on the kid like a line' | ✓ | ✗ | — |
| 25 | no | 'I can only do it for a profit (Yeah)' | 'Only hit the bank for deposit (Oh)' | ✓ | ✓ | — |
| 26 | no | "How you want that Saint Laurent bag, you ain't suckin' no dick? (Ho)" | "My lil' LA bitch got jet-lag, she off that coke shit (Coke)" | ✓ | ✓ | — |
| 27 | no | 'A whole lotta cap ho, you lease the watch' | 'I told her she on me, she gave me her twat' | ✓ | ✓ | — |
| 28 | no | "Watch your niggas always till' you got it all" | 'I got some frienemies, a fake friend that envy me' | ✓ | ✓ | — |
| 29 | no | 'I can keep you warm (Warm)' | 'But my heart cold (Cold)' | ✓ | ✓ | — |
| 30 | YES | 'Rondo number nine (Nine, nine)' | "Hope you buster niggas never cross the line (Don't cross the line)" | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 31 | no | "Ain't work, what the word on me now when you fearless?" | "Me like the top I can fuck, but can't wife, but it's up when we linkin' (It's up)" | ✓ | ✓ | — |
| 32 | no | 'Now I spend a hundred thousand on clothes (On clothes)' | 'Fashion week, I did a video for Vogue (Yeah)' | ✓ | ✓ | — |
| 33 | no | "You wasn't loyal so you lost me (Hey)" | 'Deliver my diamonds I ordered these' | ✓ | ✓ | — |
| 34 | no | 'I had to finesse' | 'And got me a check' | ✓ | ✓ | — |
| 35 | no | "I'm kickin' you out like a tenant (Beat it)" | "They can't let you in, gotta barge in it (Barge)" | ✓ | ✓ | — |
| 36 | YES | 'Monday through Sunday, ooh (Yeah)' | 'Yung Carti be on it (All of the cash)' | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 37 | no | "I'm still taking S, I cannot sleep (S, I cannot sleep)" | 'I know mama want the best for me (Want the best for me)' | ✓ | ✓ | — |
| 38 | no | 'Got new drip, Mr. Porter' | 'I might splash, Patek water' | ✓ | ✓ | — |
| 39 | no | 'They finally gave me a chance (On God)' | 'Hood Baby, they understand' | ✓ | ✓ | — |
| 40 | no | "I'ma gon' fuck yo' bitch, send her back over there, yeah (Yeah yeah yeah)" | 'VVS on my wrist, it look like a solar flare, yeah (Yeah yeah yeah)' | ✓ | ✓ | — |
| 41 | no | "I'm off it, I'm tipsy, that lean got me jiggy" | "I'm known for that shit that I do in these lyrics" | ✓ | ✓ | — |
| 42 | no | "She wanna boast about it, make sure you're not bein' a ho about it (Ho)" | "Tiffany rose, exotic, this one they don't even show society (Tiffany)" | ✓ | ✓ | — |
| 43 | no | 'Went got it, I seen it, I knew they ain’t notice' | 'Young Wunna stay focused, these hoe niggas bogus' | ✓ | ✓ | — |
| 44 | no | 'Pop yo shit, pop it, anytime I can (Pop it)' | 'Chauffeur greet me at the clearport, evеry time I land' | ✓ | ✓ | — |
| 45 | no | "Our relationship too risky, I don't trust none of you bitches (No)" | 'You can never sell stingy, bought you diamonds and they twinkle (Twinkle)' | ✓ | ✓ | — |
| 46 | no | "I love we perform at The Garden, and no, I ain't talking 'bout Callaway" | "I flew her in for the first time on a Friday, I fucked that lil' bitch before Saturday" | ✓ | ✓ | — |
| 47 | no | "Bad bitches, they already know I'm him" | "Bad bitch with the kit, 'bout to break her hip" | ✓ | ✓ | — |
| 48 | no | "I think this nigga scared he gon' lose me" | "I'm the truth, make a dare" | ✓ | ✓ | — |
| 49 | YES | 'Woah, two hundred for brunch (What?)' | 'I eat two hundred for lunch (For lunch)' | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 50 | no | 'Pull up with two guns, three deep' | "I’m drippin' like I just got out the shower" | ✓ | ✓ | — |
| 51 | no | "You my bitch, don't lie to me, get an AP for my apology (For my apology)" | 'SVJ the Aventador (Slide), my Lambo slide like centipede (Slide)' | ✓ | ✗ | — |
| 52 | no | 'Heard them crackers tryna play with your life (Play with your life)' | "Get that dollar and don't drop a dime (Nah)" | ✓ | ✓ | — |
| 53 | no | "She want me raw dog but I'm not" | "I feel like a star when I'm walking out" | ✓ | ✓ | — |
| 54 | no | "Yo' Rollie tick-tock, you rappers gon' flop" | 'Pull cash outta crop, got a bag full of knots‚ okay' | ✓ | ✓ | — |
| 55 | no | "It's different when it's given to you" | 'All the money, I really earned it' | ✓ | ✓ | — |
| 56 | YES | "I just upped my opp list, there's so many guns in" | "Shoot (?), then we robbin'" | ✓ | ✓ | cur ends on hanging word 'in' |
| 57 | no | 'Got a Draco with the kick' | 'Glock .30, hollow tips' | ✓ | ✗ | — |
| 58 | no | 'Told my family that it’s all on me (Me)' | "Twelve hundred G's and it’s all on me (All on me)" | ✓ | ✓ | — |
| 59 | no | "Takin' trips to Barbados (Barbados)" | 'Lеt you tip on them pretty pink toes' | ✗ | ✗ | — |
| 60 | no | 'Hop in a Benz (What?)' | 'Hopped out a Porsche (Skrrt)' | ✓ | ✓ | — |
| 61 | no | 'Yeah, my girl she so foreign, what is "Cómo se llama?" Uh' | 'Yeah, she look like a model, uh, in The Matrix, Keanu, uh' | ✓ | ✓ | — |
| 62 | no | "Kickin' it, broke leg (Woah)" | 'I just went tycoon, White Porsche nine-eleven for the white folks (Woah)' | ✓ | ✓ | — |
| 63 | no | "Feel like Floyd, hit backends on the jet (What you doin'?)" | "Ballin' hard like I play for the Nets" | ✓ | ✓ | — |
| 64 | no | "They thought I would fail, didn’t believe 'till I tried (Nah)" | 'Shitted on they fam, left some fleas and some flies (Yeah)' | ✓ | ✓ | — |
| 65 | no | "VVS, my lil' bitch, how I'm in, she say I'm cold as ice (Cold as ice)" | 'Yeah, slime anaconda (Slime), came up off a pointer' | ✓ | ✓ | — |
| 66 | no | 'Okay, first, you go pop the seal (Pop the seal)' | "Then you gon' exotic pop it the best for real (Exotic pop)" | ✓ | ✓ | — |
| 67 | no | "Whatever they say, we don't trust 'em" | "Lust on a bitch, I don't love 'em" | ✓ | ✓ | — |
| 68 | no | 'Ayy, yeah, yeah, spend that cash through the week (Beep)' | "Goin' on shoppin' sprees (Bands)" | ✓ | ✓ | — |
| 69 | no | 'Lock on his head (Lock on)' | 'Icy watch with the date (Icy, icy)' | ✓ | ✓ | — |
| 70 | no | "They think they gon’ take it but I’m knowin'-" | "I’m knowin' not, copped this new Beamer, this shit a robot" | ✓ | ✓ | — |
| 71 | no | '"Is you Hefner?" That\'s the type of life that I live' | 'My big homie died with the sealed [?] on his brim' | ✓ | ✓ | — |
| 72 | no | 'I’m in a different mind state' | "I’m playin' for keeps like in the streets I want it my way" | ✓ | ✓ | — |
| 73 | no | "I'ma go free my slime, we ain't doin' time" | "Only us, ain't no love for the other side" | ✓ | ✓ | — |
| 74 | no | "We puttin' Ms in all the Mercedes" | 'Spend a whole M in the mall, boy you crazy' | ✓ | ✓ | — |
| 75 | no | "It's blood that's been shed, I want some revenge (Yeah)" | 'And I promise I try not to sin' | ✓ | ✓ | — |
| 76 | no | "I swear on my life that I've been a good girl (Oh)" | "Tonight, I don't wanna be her" | ✓ | ✓ | — |
| 77 | no | 'I can shoot this bitch like a veteran with precise (Grrah, grrah)' | '911 Porsche Cayenne, gray like a granny' | ✓ | ✗ | — |
| 78 | no | 'Money going up just like some shocks' | 'No lames in my picture bitch you gettin cropped' | ✓ | ✓ | — |
| 79 | no | 'Glock got a Curry, 30' | 'On the block like Herbert Curry' | ✓ | ✗ | — |
| 80 | no | "Steppin' on opp shit (Yeah), yeah" | 'All of my opps in the ground (Yeah)' | ✗ | ✗ | — |
| 81 | no | 'Had to buy that bitch an apartment, had to move her out my crib' | 'Ho look like you keeping a Maybach, Glocks out and catch a Lyft' | ✓ | ✓ | — |
| 82 | YES | 'Turn my savage on (On, let me take it)' | 'Ayy, your girl work out to my songs (Yeah)' | ✓ | ✓ | cur ends on hanging word 'on' |
| 83 | no | 'Shoot up the block, tear up turf (Yeah)' | "'Cause I'm knowin' you can fit in the hearse (Yeah)" | ✓ | ✓ | — |
| 84 | no | 'She keep the Gucci on fleek (Gucci)' | "I fuck her, it's nice to meet (Yeah)" | ✓ | ✓ | — |
| 85 | no | 'But Chanel got bigger dreams' | 'Oh, she wanna do anything' | ✓ | ✓ | — |
| 86 | no | "I don't want your feature (Nah, nah)" | "They listen, I'm the teacher" | ✓ | ✓ | — |
| 87 | no | "You ain't coaching the game, you just out of bounds (Just out of bounds)" | 'Throw some dirt on my name, get yo body found (Body found)' | ✓ | ✓ | — |
| 88 | no | 'Shake it (Yeah), I tip (Yeah)' | "I sip (Yeah, yeah), I dip (It's lit)" | ✓ | ✓ | — |
| 89 | no | "She a heavy stepper, keep her in Margiela, keep 'em jealous" | "She say I'm too enticed, you just don't know my life" | ✓ | ✓ | — |
| 90 | no | "Gotta treat you like the rest, I ain't fixin’ up no broken heart (Heart)" | 'Know you want a perfect picture like a Polaroid (Polaroid)' | ✓ | ✓ | — |
| 91 | no | "Many tell me I'm not qualified, I ball heavily, yeah ('ly, yeah)" | 'You can find me in the club every week, yeah (Week, yeah)' | ✓ | ✓ | — |
| 92 | no | 'Would you mind? Would you mind, baby?' | 'How you want it? How you want it?' | ✓ | ✓ | — |
| 93 | no | 'Niggas still tryna fit in, I rather stand out (Stand out)' | 'Never did it for the clout (Never)' | ✓ | ✓ | — |
| 94 | no | 'And I got reefer and I got Peeps and they all evil' | "Fuck memories, bitch, I'm a demon" | ✓ | ✓ | — |
| 95 | YES | "J'préfère une Kal', qu'une conne siliconnée (Qu'une conne siliconné, conne siliconné)" | "Et vu le prix du vol, je n'peux pas rater le vol, on est bre-som derrière la vitre sans teints" | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 96 | no | 'Pull a grip from the hip like that' | "Keep it around me, I can't never lack" | ✓ | ✓ | — |
| 97 | YES | "Pullin' up, my bumper hard body" | "Dark tint, you can't look inside, hoes wanna get inside" | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 98 | YES | 'Eliantte your finger ring' | 'Baby swallow my dingaling' | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 99 | no | "I love her 'cause she kept me with hope (With hope)" | "'Bout to run that shit up like Lil Boat (Up like Lil Boat)" | ✓ | ✓ | — |
| 100 | no | "We ain't ever playin'" | "I'm talkin' 'bout that groupie love" | ✓ | ✓ | — |
| 101 | no | 'I done bought every chain, but cuz still locked in chains (Ya)' | 'It’s not a game, it ain’t no ultimatum (Ya)' | ✓ | ✓ | — |
| 102 | no | 'Started a tour, so I parked my foreigns in the garage (Garage)' | "Less is more, I pick and choose, keep playin' it smart (Playin' it smart)" | ✓ | ✓ | — |
| 103 | no | "I'm always right here workin', looking down, lookin' at you likе you fell off" | "Always trap with the team I don't call the shots, they make sure my sins don't go up" | ✓ | ✓ | — |
| 104 | no | "Now I'm doing shows, rockin' New Zealand, me and Cordae" | 'Back in Australia, mate' | ✓ | ✗ | — |
| 105 | no | 'I heard that boy signed for a nice check' | "Tryna see this shit clear through the chrome spec's" | ✓ | ✓ | — |
| 106 | no | 'Superstars, so we shine (Shine)' | "Fuckin' you and your bitch (Bitch)" | ✓ | ✗ | — |
| 107 | no | "All my vehicles imported ('Ported)" | 'Nigga better not cross the margin (No)' | ✓ | ✓ | — |
| 108 | YES | "Heatin' up like last day in June (Ha)" | "Niggas stealin' my drip, that shit ain't cool" | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 109 | no | 'Damn my nigga, what happened to Virgil?' | "Talked to God, I don't wanna get murdered" | ✓ | ✓ | — |
| 110 | no | 'Bitch come hop in this ride' | 'Had to put my pride to the side' | ✓ | ✓ | — |
| 111 | no | "The cash got these niggas wildin' out (Wild)" | 'Rockstar, open up the circle, make a moshpit (Moshpit)' | ✓ | ✓ | — |
| 112 | no | 'Got the bitch from Maine, took her to Spain' | 'Do the same thing again (Again)' | ✓ | ✓ | — |
| 113 | no | "YSL, 1017, bitch, we still runnin' the town (Runnin' the town)" | "Yeah, I ain't seen better days, we float through the sky, blue" | ✓ | ✓ | — |
| 114 | no | 'Shit can get cold, ooh' | 'Stick to my vision, sail out on the road (Road)' | ✓ | ✓ | — |
| 115 | no | "I'ma jump in that Lamb, drive it fast, yeah" | "I can't lie I'm on it" | ✓ | ✓ | — |
| 116 | no | "I used to struggle 'til I started dealin'" | 'I gotta hustle to get me a million' | ✓ | ✓ | — |
| 117 | no | 'Keep me some racks in the dashboard (Hey)' | 'New window tint, left it fishbowl (Fishbowl)' | ✓ | ✓ | — |
| 118 | no | "I'ma count it and count it and count it and fuck a up brick" | 'May just see the night time, just buy me a new bitch' | ✓ | ✓ | — |
| 119 | no | "This ain't Hocus Pocus, we ain't fallin' for your stunts" | "I hope you keep it loaded 'cause these jackers on the hunt" | ✓ | ✓ | — |
| 120 | no | 'I wish my brother had made it out surgery' | "I be up thinkin', that shit do be hurtin' me" | ✓ | ✓ | — |
| 121 | no | "They love hearin’ me speak, like a deacon (Hearin' me speak, like a deacon)" | "More Amiri drip, it's the season (Amiri)" | ✓ | ✓ | — |
| 122 | no | "In heaven, they whippin' up yams (Yams)" | "Big truck drivin', RAM (RAM)" | ✓ | ✗ | — |
| 123 | no | 'I deserve more than you giving' | 'I deserve sex that’s so vivid' | ✓ | ✓ | — |
| 124 | no | 'I had to ice out the gold for me and me hoes just to go' | "I told 'em, my teeth, now they froze" | ✓ | ✓ | — |
| 125 | no | "Who you know thinkin' like this? (Who? Ooh, ooh)" | "Movin' on you like this (Who?)" | ✓ | ✗ | — |
| 126 | no | "I'm draped in designer" | "Ooh, I don't talk, my money speak for me (Yeah)" | ✓ | ✓ | — |
| 127 | no | 'None of this shit was luck, it’s wrote out, then read' | 'Crib eight thousand square feet, I came out the trench (trench)' | ✓ | ✓ | — |
| 128 | no | 'anytime I pop out (Pop out)' | 'Homies will take the charge if I gotta cop out (Yeah)' | ✓ | ✓ | — |
| 129 | no | "Yeah, yeah, you call, I'ma be there" | "[?] call when niggas wasn't nowhere, you call momma to pay bail" | ✓ | ✓ | — |
| 130 | no | 'I had to stack up my chips' | 'Stuck in the streets, came up off a lick' | ✓ | ✓ | — |
| 131 | no | "Bought her some shit 'cause she honest, ooh (Ooh)" | "Bought a C8, it don't come with a (Uh)" | ✓ | ✓ | — |
| 132 | no | "Make a wish, I'm a star in this movie (Okay)" | "Traumatized 'cause his old bitch a goofy (Haha)" | ✓ | ✗ | — |
| 133 | no | 'I was speed racing' | "But I'm tired of try-ry-rying" | ✓ | ✓ | — |
| 134 | no | 'You picture perfect girl' | "I could look and see you're worth it, ya" | ✓ | ✓ | — |
| 135 | no | "Opp in your ear and they gon' plot cause I'm richer (Slatt)" | "Your big homie blow, he ain't even got a Richard (Slatt)" | ✓ | ✓ | — |
| 136 | no | "Ain't nothin' to say to me" | "Okay, Amiri my 'fit, bet you're scared of me" | ✓ | ✓ | — |
| 137 | no | 'I run with locs, they can get it for the low, these young niggas gang bang (these young niggas gang bang)' | 'All a real street nigga wanna do is stack it up and maintain (stack it up and maintain)' | ✓ | ✓ | — |
| 138 | no | "Keep me a heater, that's my toaster, in my coat, you would never know" | "Streets don't love you, I don't either, I don't need ya, no, no, no" | ✓ | ✓ | — |
| 139 | no | "We been fuckin' for a year, they still don't know about it (Don't know about it)" | 'All the flights are private, got a personal pilot (Personal pilot)' | ✓ | ✓ | — |
| 140 | no | 'Bitch think she can show a nigga' | "Can't trust these bitches" | ✓ | ✓ | — |
| 141 | no | 'Smoke a lot of trees, need a weed plant (Weed plant)' | 'Addicted to codeine, where the lean at? (Where the lean at?)' | ✓ | ✓ | — |
| 142 | no | 'One of the best that you could find' | "My voice like a blessin' in disguise" | ✓ | ✗ | — |
| 143 | no | "Ain't no back and forth with you" | "Oh, I'm just blowin' up (blow up)" | ✓ | ✓ | — |
| 144 | no | 'Huh, I know how I get (Yeah)' | "I'ma break your spine, next spot, I'm gon' break your ribs (Break your ribs, ayy)" | ✓ | ✓ | — |
| 145 | no | 'I got homies chop shit like the Japanese (The Japanese)' | "Figure it out like it's geometry (Geometry)" | ✓ | ✓ | — |
| 146 | no | 'Had to cut my jeans, look like new Loewe jorts' | "Brought out fifty G's just to spend on my lil' shawty" | ✓ | ✓ | — |
| 147 | no | 'Lost a couple homies to the feds (To the feds)' | 'Man, this shit was all I read (All I read)' | ✓ | ✓ | — |
| 148 | no | "Yeah, I'm fucking a cutie, hugging her tight while I'm gripping her boobies" | "Smack on her ass, she gon wan' make a movie" | ✓ | ✓ | — |
| 149 | no | 'I paint a picture, I might need a frame (Frame)' | "I'm tryna free my cuz out the chain gang (Ah)" | ✓ | ✓ | — |
| 150 | no | "Pour up let's count up these riches (Pour it, pour it)" | 'Still flying bags through the city' | ✓ | ✓ | — |
| 151 | no | 'With this drip, bitch better catch me outside (bitch better catch me outside)' | 'I only want Forgiato rims when I ride (when I ride, yeah)' | ✓ | ✓ | — |
| 152 | no | "Nigga better not start playin' with us" | "We ain't ever playin'" | ✓ | ✓ | — |
| 153 | no | 'Anything you see, you can get it (Get it)' | 'Here go the keys to the Bentley' | ✓ | ✓ | — |
| 154 | no | "Goyard board, I'm bout to skate" | 'Keep me a four, I sip drank' | ✓ | ✓ | — |
| 155 | no | "They said that I flopped and that I'll never make it (Yeah)" | "Now they don't say shit" | ✓ | ✓ | — |
| 156 | no | "Show 'em it ain't over and baby, I'm back again" | 'I told my baby, "Let them talk," that\'s the caption' | ✓ | ✓ | — |
| 157 | YES | 'Audemars Piguet (Audemars Piguet)' | 'I put that water on my wrist (Water on my wrist)' | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 158 | no | "Baby mama textin' paragraphs, I ignore it" | 'And I ran a M up off a freestyle with no chorus' | ✓ | ✓ | — |
| 159 | no | "Ain't nobody pullin' you down on the road to a billion (Billion)" | 'Denim hold a whole hundred grand' | ✓ | ✓ | — |
| 160 | no | "Take off her chain and it's wet" | 'Keep on your reins when you hit' | ✓ | ✓ | — |
| 161 | no | "I been rockin' customized shit (Customized shit)" | "I been geeking, man, I'm high as a bitch (I'm high as a bitch)" | ✓ | ✓ | — |
| 162 | no | "I just had got that lil' bitch from my mans" | "So I was fuckin' that ho with my chain in my hand" | ✓ | ✓ | — |
| 163 | no | "I'm going number one this year (Okay)" | "Ride on this bitch, I'm in sixth gear (Oh, okay)" | ✓ | ✓ | — |
| 164 | no | '"How the hell it match the Rolex bezel?" She so flattered' | "Bitch walked out my door, you know I ain't even sweat her" | ✓ | ✓ | — |
| 165 | no | 'Money grown, I had to bring my Lamborghini out' | 'Rich on my own, I brought it home and now my family proud' | ✓ | ✓ | — |
| 166 | YES | 'New Ghost, Patrick Swayze, shady baby, loco, crazy (Loco)' | 'Southside, but not JD, pull up, AMG Mercedes (Mercedes)' | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 167 | no | 'Wait till a young nigga blow up (Blow up)' | "Thugga got Act', we gon' pour up (Act')" | ✓ | ✓ | — |
| 168 | no | "'Cause I drip like that (I drip like that)" | 'I drip like that (drip)' | ✓ | ✓ | — |
| 169 | YES | 'From the jungle like the lions and elephants' | "And I told you, I'm fly like a pelican" | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 170 | no | 'Thugger told me teach you stick, pour a deuce you ratchet' | "Bitch, I got lions, no tellin', bleu cheese, no salad" | ✓ | ✓ | — |
| 171 | no | 'I just want my brothers to stay low' | 'I know that this shit came with no love' | ✓ | ✓ | — |
| 172 | no | 'Got some new Cuban links, they was pavé' | 'Bought a Maybach, I never can drive it' | ✓ | ✓ | — |
| 173 | no | "My bankroll colossal, I'm rich" | 'Said how much you spent on your wrist?' | ✓ | ✓ | — |
| 174 | no | "They had 'em down, I got all aces (All ace)" | "Second nigga change gangs, Jason (Ja')" | ✓ | ✗ | — |
| 175 | no | 'Woop, cop a new foreign, no re-runs (cop a new foreign, no re-runs)' | "Woop, I'm gon' sell out the arena (I'm gon' sell out the arena)" | ✓ | ✓ | — |
| 176 | no | 'Murk him and let him sit down and just rot' | 'Shot up his coupe and we shot up the shop' | ✓ | ✓ | — |
| 177 | no | "Girl, you're so cute like a Barbie doll (Cute)" | 'Geeked off the Molly and Adderall (Geeked)' | ✓ | ✓ | — |
| 178 | no | 'Pill go straight to my hea-ea-ead (Woah)' | "Oh, don't know what I'm headed to (Headed to)" | ✓ | ✓ | — |
| 179 | no | 'Ask lawyers, I got mine (Shots, shots)' | "The security still gon' get touched" | ✓ | ✓ | — |
| 180 | no | 'Told you that I quit, but I still pop beans' | "Grindin' at night 'til I crack my teeth (Yeah)" | ✓ | ✓ | — |
| 181 | no | "You my ho, I'ma treat you to the best (Yeah, yeah)" | 'Marble floor, my house, it cost a check (Check)' | ✓ | ✓ | — |
| 182 | no | "Bl-blame it on the city how I'm ballin' (How I'm ballin')" | 'W-when we run through, yeah, yeah' | ✓ | ✓ | — |
| 183 | no | 'I set you up, get you whacked for the money' | "Oh no, can't turn my back on the bro (Can't turn your back on your bro)" | ✓ | ✓ | — |
| 184 | YES | 'Hedi Slimane with the walk (Alright)' | 'I got on Celine, Balenciaga' | ✗ | ✓ | cur has no VERB/AUX, next does (dangling) |
| 185 | no | 'I just came out to tell you I made it (Woo)' | "We shootin' at the coppers" | ✓ | ✓ | — |
| 186 | no | "Balls smell like powder, fuck it, take it to trial (Let's go, yeah, yeah)" | "Take this shit to motherfuckin' trial (Yeah, yeah)" | ✓ | ✓ | — |
| 187 | no | "They play with one of your partners, you gon' ride, ain't you? (You gon' ride, ain't you?)" | "We gon' take it over, this is our nation (Our nation)" | ✓ | ✓ | — |
| 188 | no | "And my cars so I went and bought another cat ('nother cat)" | 'Me and yo bitch had a lotta sex (Yeah)' | ✓ | ✓ | — |
| 189 | no | "Tell the bitch hit the road, Jack, like I'm Ray Charles (Bye)" | 'Ten car garage, I put ten in the loft (Ten)' | ✓ | ✓ | — |
| 190 | no | 'She want me and Lil Boat in her pics (her pics)' | "Aye, aye, aye (ayee), there's a few of us keepin' it real (real)" | ✓ | ✓ | — |
| 191 | no | 'Put that, put that in my girl (Straight up)' | "Makin' porno videos and takin' stills (Yeah)" | ✓ | ✗ | — |
| 192 | no | 'I got the cheese and I got me some broccoli' | 'All color money, this shit like monopoly' | ✓ | ✗ | — |
| 193 | no | "I'm a stoner, get used to it" | 'Laughing to the bank' | ✓ | ✓ | — |
| 194 | no | 'How many bars you tryna see? (Oh, woah)' | 'I use a sword to slash the key (Oh, woah)' | ✓ | ✓ | — |
| 195 | no | 'I get high like a Martian, nigga' | 'Leave that boy stiff like an action figure' | ✓ | ✓ | — |
| 196 | YES | "I'm with a chick and she bendin' it over" | "Spend a thousand on kicks, it don't matter, I'm loaded" | ✓ | ✓ | cur ends on hanging word 'over' |
| 197 | no | "I know a nigga going, hard, bout' and went gold off a leak" | 'I need twenty more for the Greek (Greek)' | ✓ | ✓ | — |
| 198 | no | "Kill 'em, not leaving a trace, yeah" | "Kill 'em, not leaving a trace (Brrt)" | ✓ | ✓ | — |
| 199 | no | "Rappin', made a name" | "Now I get paid for a stage, I keep a guitar with me ('Tar with me)" | ✓ | ✓ | — |
| 200 | no | 'Fuck your birthday, my presence is a present' | "What's a dollar to a nigga with a million?" | ✓ | ✓ | — |
