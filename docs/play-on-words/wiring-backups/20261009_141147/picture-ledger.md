# Picture ledger

Read at 2026-10-06 17:45 from the Play on Words list the other terminals are filing.
This file does not add chips, change partners, or make photos.

Sound flips: **1108**. Store and the section list are the same list.
Full rows: `docs/play-on-words/picture-ledger.tsv`.

## How a row is read

Akorn is the pattern.

| Field | Akorn |
|---|---|
| Heard word | Akorn |
| On the same line | squirrel |
| Picture | acorn |

The tile stays Akorn. The partner stays squirrel, because that is the other word on the bar. The photo is an acorn. `noun-squirrel` is the animal chip. Akorn uses `noun-acorn`.

## Counts

| | |
|---|---|
| Phonetic | 216 |
| Double meaning | 888 |
| Double entendre | 4 |
| Reuse an existing photo | 43 |
| Keep the chip photo | 2 |
| Generate a new photo | 271 |
| Keep the SF Symbol | 22 |
| Two senses, photo not chosen | 770 |
| Phonetic picture differs from the partner | 134 |
| Of those, the partner already has a photo | 18 |
| Chip name already has its own photo | 83 |
| That photo is the picture subject | 8 |
| No partner on the chip | 23 |
| Heard word already on another tab | 0 |

A sentence with two objects stays on “photo not chosen.” The tsv keeps both objects in `hidden_sense`.

83 chips already have a photo filed under the chip name. 8 of those files are the picture subject. The rest are a photo of the chip name. “gotta cancer” already shows a cigarette, and its sense is cancel. Those files stay until a later pass looks at them.

## Spot-check

These 18 are locked. The partner word stays for the bar. The picture is the other column. No photo was made.

| Chip | Picture | Decision | Leave this photo off the chip |
|---|---|---|---|
| by the night | Knight | symbol | noun-celeb-suge |
| I kneel | O'Neal | generate | noun-shaquille |
| texts | messages | keep: noun-texts | noun-tecs |
| tecs | guns | keep: noun-tecs | noun-texts |
| chief it | smoke and the Chiefs | review | noun-t-hill |
| Greek | Greek Freak | generate | noun-place-milwaukee |
| Glock-9 | GlokkNine | generate | noun-artist-kodak |
| assassinate him | the hit | symbol | noun-presidential |
| let it pan out | frying pan | generate | noun-gun-switch |
| get abused | the drugs | reuse: noun-lean | — |
| patience | patients | generate | noun-prod-dre |
| every twenty-four | the hours and the jersey 24 | review | noun-celeb-kobe |
| I'm a prodigy | Prada | reuse: noun-prada | noun-gucci |
| heart hardens | James Harden | generate | noun-adidas |
| write my endin' | the ghostwriter and the close | review | noun-place-philly |
| Chromazz | chrome | generate | noun-car-rolls |
| too much cheese | the money and the box | review | noun-celeb-kd |
| Akorn | acorn | generate | noun-squirrel |

Texts already shows a speech bubble, and tecs already shows bullets. Those two keep the photo they have. Get abused reuses the purple cup because the sentence says the chip is the drugs. I'm a prodigy reuses the Prada wordmark. Akorn uses the acorn file, and the squirrel photo stays on the animal chip.

Greek's sentence says the Bucks. The partner table says milwaukee. The picture is Giannis either way, and the partner was not changed.

## Second homes

Filed on 2026-10-06 in the artist and actor lists. The insert word is the same on every tab, and the photo already on that name follows it. Each name sits in one section of a tab. Play on Words is still 1108, and none of these eight strings are on that list. The store list matches the section list in all 55 tabs. Feelings 101, substances 44, apps 66, looks 36, and religion 34 are unchanged.

| Name | Tabs | Photo |
|---|---|---|
| Ice Cube | Artists / Los Angeles, Actors / Drama | noun-ice-cube |
| Ice-T | Artists / Los Angeles, Actors / Drama | noun-artist-ice-t |
| Will Smith | Artists / Rappers, Actors / Stars, Celebs / Film | noun-celeb-will-smith |
| Jamie Foxx | Artists / Singers, Actors / Drama, Celebs / Film | noun-celeb-jamie-foxx |
| Queen Latifah | Artists / Singers, Actors / Drama | noun-celeb-queen-latifah |
| LL Cool J | Artists / New York, Actors / Drama | noun-celeb-ll-cool-j |
| Ludacris | Artists / Atlanta, Actors / Action | noun-celeb-ludacris |
| Tyrese | Artists / Singers, Actors / Action | noun-celeb-tyrese |

A bar that names one of these people can light every tab that holds that name. No mention exclusion was added.

Still one tab: Drake on Artists, Wheelchair Jimmy on Celebs, Denzel on Celebs, Tony Montana on Characters, Scarface on Characters, The Rock on Wrestlers.

## Photos wired

Wired on 2026-10-06 in `wordplayPictureIcons`. The heard word is the key. The file is the hidden sense. Play on Words was 1,120 when this slice was checked, and the store list matches the Sound flips section. The ledger rows are still the earlier 1,108.

Chips filed after that ledger read, still outside the tsv: Kemba Walker, meal, Neighborhood chucking, Norbit, Pistol Pete, pull, Carlos Boozer, St. Lunatic, Boban, Die Lit, Brook and Robin, Neverland. In the map from outside the tsv: Kemba Walker, meal, Pistol Pete, Carlos Boozer, Boban.

New files: `noun-acorn`, `noun-frying-pan`, `noun-chrome`, `noun-patients`, `noun-glokknine`, `noun-attic`, `noun-cell`, `noun-slide`, `noun-colt`, `noun-presents`, `noun-sun`, `noun-icewear-vezzo`, `noun-stefon-diggs`, `noun-marcus-mariota`, `noun-kemba-walker`, `noun-celeb-faith-evans`. The GlokkNine file is the Wikimedia stage photo of 9lokkNine. The five people files are Wikipedia portraits.

Second slice, same map:

| Heard word | File |
|---|---|
| actin' like Book | noun-nba-booker |
| an addict | noun-attic |
| drake kickback | noun-gun-draco |
| Eggo | noun-waffles |
| on Rhude | noun-rhude |
| one coat | noun-colt |
| over Yao | noun-celeb-yao-ming |
| sale | noun-cell |
| Shaquille | noun-celeb-shaq |
| sliders | noun-slide |
| tan lines | noun-sun |
| wings | noun-robin-jeans |
| your presence | noun-presents |
| rock it | noun-rock-it, already the rocket |

The Robin jeans file spells the word JEAN. The Spinrilla file used for Music app spells the name with a doubled r. One coat uses the revolver. The Colts mark was not made. The hoop file `noun-over-yao` stays off Over Yao. The basketball file `noun-shaquille` stays off Shaquille. The sandwich file `noun-sliders` stays off Sliders. `noun-houston-rockets` stays off Rock it.

Left off the chip from the first slice: the squirrel on Akorn, the columns file `noun-greek`, the city block on Serge Ibaka, the Rolex on Monica Lewinsky, and the car engine on Like Thomas.

People slice, same map. Each file is a Wikipedia portrait of that person.

| Heard word | File |
|---|---|
| Vez | noun-icewear-vezzo |
| Hot dig | noun-stefon-diggs |
| Marcus | noun-marcus-mariota |
| Kemba Walker | noun-kemba-walker |
| Faith Evans | noun-celeb-faith-evans |

The dove file `noun-faith-evans` stays off Faith Evans. The Giants number 13 file `noun-marcus` stays off Marcus.

Gloss rows moved to the symbol: 134. Nine rows with two objects moved to review. Lean go stays generate. Its subject line is “lingo, the way he talks.”

Money and people slice, same map. Play on Words was 1,120. Store, sections, briefs, and tests were still the 18:18 save when the catalog was edited.

| Heard word | File |
|---|---|
| astronauts | noun-money-bands |
| Boban | noun-boban |
| Carlos Boozer | noun-carlos-boozer |
| cash comin' | noun-money-racks |
| meal | noun-money-millie |
| Pistol Pete | noun-pete-maravich |

`noun-money-bands` and `noun-money-racks` are the same stack of bills. Meal uses the taller millie stack. Pistol Pete is the Jazz 7 photo. The face finder missed that profile, so the square was set by hand. Carlos Boozer is the Bulls portrait with the beard. Boban is the tall center. Petey Pablo, Peter Pan, and Peter Parker stay off Pistol Pete. Nelly stays off St. Lunatic. Curry stays off pull.

Held, with no new file:

| Heard word | Why it stays open |
|---|---|
| Neighborhood chucking | the blue set |
| Norbit | the movie hug |
| pull | the three |
| St. Lunatic | Nelly's group |
| Die Lit | the Carti album |
| Brook and Robin | the Lopez brothers, two people |
| Neverland | the ranch |

Ledger after the money slice: reuse 65, keep 3, generate 100, symbol 156, review 784.

Object slice, same map. Play on Words was 1,120. Store, sections, briefs, and tests were still the 18:18 save.

| Heard word | File |
|---|---|
| bag with a pipe | noun-bagpipe |
| be my strudel | noun-strudel |
| broken necklace | noun-necklace |
| I baited | noun-fish-hook |
| in the ghost | noun-car-rolls |
| like 6:30 | noun-clock |
| like I'm Nixon | noun-peace-sign |
| like some vegetation | noun-plants |
| no flowers | noun-plants |
| Pluto | noun-pluto |
| stopwatch | noun-stopwatch |

The clock hands sit at 6:30. Like I'm Nixon uses the peace sign. The Rolls file is the car, so it stays off Illuminated angel. The chain file is the necklace. Pluto uses the planet. No flowers and Like some vegetation share the plants. Rose stays off No flowers. The file named noun-coke-bottle is a person, so it stays off Like a Coke. Dream Chaser stays open. That tape is the mixtape beside Meek. Through the Wire and Lean go moved to the symbol.

Ledger after the object slice: reuse 76, keep 3, generate 87, symbol 158, review 784. The tsv is still 1,108 rows. The map had 68 keys.

Ball and animal slice. The other terminal had grown Play on Words to 1,136, and the Sound flips section matches. The map still held the 68 keys. Store, sections, briefs, and tests were the 18:42 save.

| Heard word | File |
|---|---|
| Chuckie | noun-glasses |
| hundreds | noun-money-bands |
| Joe Burrow | noun-tabby |
| like a Coke | noun-soda |
| like Huskies | noun-husky |
| like it's a Spalding | noun-basketball |
| size-seven | noun-small-shoe |
| Tom Brady | noun-flat-ball |
| wire | noun-glasses |

Joe Burrow uses the striped cat. His face stays off. Chuckie and wire share the glasses. The cartoon stays off Chuckie. Cartier frames stay off wire. Like Huskies uses the dog. Huggies stays off. Tom Brady uses the flat ball. His face stays off. Like a Coke uses a plain soda bottle. The powder file and the person file named noun-coke-bottle stay off. Hundreds uses the bill stack.

Child is the backend name. No photo was made. Say my name, Pootie Tang, and Beanie Sigel stay on the symbol. They are a song, a movie, and a song. Eczema moved to the symbol. The itch stays there. Gilbert Arenas, Tote 30, Trigger fingers, Barrel was smoking, and Like a vaccination moved to review.

Still open from the new chips: Taylor Gang, twenty, Thottie breaking, Kelly, Michelle, DX, Naismith, Cracker Barrel, PrizePick, Red Bull.

Ledger after this slice: reuse 82, keep 3, generate 75, symbol 159, review 789. The tsv is still 1,108 rows. The map has 77 keys.

People slice. Play on Words is 1,147, and the Sound flips section matches. The other terminal added 11 chips after Red Bull while these files were being saved: bull, Uzi Made, Curtis, Poison, Raptors, Hut, blue, Earl Sweatshirt, Clinton Capella, second place, rainbow. Those 11 are outside the ledger. Store, sections, briefs, tests, and the catalog are the 19:02 save. The 83 picture keys are in that catalog save.

| Heard word | File |
|---|---|
| freed the slaves | noun-abraham-lincoln |
| like I'm Tyler | noun-tyler-herro |
| like NextSelection | noun-ryan-leslie |
| like Randolph | noun-zach-randolph |
| Ranned off | noun-zach-randolph |
| switch the beats | noun-swizz-beatz |

Like I'm Tyler uses Tyler Herro. Heat stays off. noun-celeb-tyler-perry stays off. Like Randolph and Ranned off share Zach Randolph. The other player and the jersey number stay off. Like NextSelection uses Ryan Leslie. Freed the slaves uses Lincoln. Switch the beats uses Swizz Beatz. Alicia stays off.

Held, with no new file: Fee on her is Fiona. Holiday eve is Eve beside Adam, so the rapper stays off. Like I'm Kris Kringle is Santa. Deadboy is Lucki, and the only file was a signature. William Wesley is Worldwide Wes, and the page had no portrait. Meet PARTY stayed open because the mic covered the face.

Ledger after this slice: reuse 88, keep 3, generate 64, symbol 159, review 794. The tsv is still 1,108 rows. The map has 83 keys. Xcode was not run.

Household slice. Play on Words is still 1,147, and the Sound flips section matches. Store, sections, briefs, and tests stayed the 19:02 save.

| Heard word | File |
|---|---|
| be cremated | noun-ash |
| hangin' with glue | noun-glue-sticks |
| like a squid | noun-ink |
| like game | noun-detergent |
| like some green tea | noun-green-tea |
| like the kitchen drawer | noun-kitchen-knife |
| peas and rice | noun-peas-rice |

Hangin' with glue uses the glue sticks. The branded pack stays off. Like game uses the detergent. Like some green tea uses the brew. The iced tea file stays off. Like the kitchen drawer uses the knife put away. The underwear file stays off. Like a squid uses the ink. noun-inked stays off. Be cremated uses the ash. Peas and rice uses the plate. The fried rice file stays off.

Pinky moved to review. The curved clip is the magazine. noun-clip, noun-pinky, and noun-pinky-ring stay off.

Ledger after this slice: reuse 95, keep 3, generate 56, symbol 159, review 795. The tsv is still 1,108 rows. The map has 90 keys. Xcode was not run.

Seats and rooms slice. Play on Words is still 1,147, and the Sound flips section matches. Store, sections, briefs, and tests stayed the 19:02 save. The catalog was the 19:07 save when these seven keys were added.

| Heard word | File |
|---|---|
| booster seat | noun-booster-seat |
| cards I'm dealt | noun-solitaire |
| Chef Curry | noun-kitchen |
| Gucci Row | noun-courtside |
| main cabin | noun-plane-seat |
| nosebleeds | noun-cheap-seat |
| see a ring | noun-ring-blingin |

Nosebleeds uses the cheap seat. The car seats stay off. Main cabin uses the plane seat. The jet stays off. Gucci Row uses the courtside seats. The logo stays off. Booster seat uses the empty child seat. Cards I'm dealt uses solitaire. The cell stays the partner. Chef Curry uses the kitchen. Steph stays off. See a ring uses the jewelry. Hardy stays off.

Ledger after this slice: reuse 102, keep 3, generate 49, symbol 159, review 795. The tsv is still 1,108 rows. The map has 97 keys. Xcode was not run.

Places slice. The other terminal saved all five Swift files at 19:17 while these photos were being made. Play on Words is 1,148, and the Sound flips section matches. The new chip is Titty, the Tity Boi hook. It stays outside the ledger, and no photo was made. Store, sections, briefs, and tests stayed that 19:17 save. The catalog map was still the 97 keys when these seven were added.

| Heard word | File |
|---|---|
| Cape Town | noun-cape-town |
| hell | noun-hell-michigan |
| in her organs | noun-oregon |
| like New Jersey | noun-new-jersey |
| napless | noun-indianapolis |
| rack up a tab | noun-iraq |
| the O2 | noun-o2-arena |

Cape Town uses the city. Hell uses the Michigan town. The shop stays off. In her organs uses the state. The flag stays off. Like New Jersey uses the cliffs. The shirt stays off. Napless uses the monument. The bank tower stays off. Rack up a tab uses the country. The wordmark stays off. The O2 uses the London arena. The model stays off.

Ledger after this slice: reuse 109, keep 3, generate 42, symbol 159, review 795. The tsv is still 1,108 rows. The map has 104 keys. Xcode was not run.

People and groups slice. The other terminal saved all five Swift files at 19:34 while these photos were being made. Play on Words is 1,155, and the Sound flips section matches. Seven chips were added after Titty: billy, Linwood, Jason brother, die, hundred, Otto Potter, and throwin' salt. Those seven stay outside the ledger, and no photo was made for them. Titty stays outside the ledger. Store, sections, briefs, and tests stayed that 19:34 save. The catalog map was still the 104 keys when these five were added.

| Heard word | File |
|---|---|
| Lohan | noun-lohan |
| like I'm jaggered | noun-jagged-edge |
| Grateful like Jerry | noun-grateful-dead |
| pack Bone | noun-bone-thugs |
| Paramore | noun-paramore |

Lohan uses the lenses. Her face stays off. Like I'm jaggered uses the group. Grateful like Jerry uses the band. The album ad stays off. Pack Bone uses the group. The backdrop brand stays off. Paramore uses the band. The drum name stays off.

Arnez moved to review. The character was a teenager on the show. No photo was made. Onyx stays open. The live file had a shirt wordmark. Young Lion stays open. Meet PARTY stays open. The mic covered the mouth. noun-lion stays off Young Lion. noun-grateful stays off Grateful like Jerry. noun-celeb-lindsay-lohan stays off Lohan.

The seven new chips, still outside the ledger: billy is the dad, Linwood is the house, Jason brother is the name, die is the dive, hundred is the score, Otto Potter is the Porter name, and throwin' salt is the shade.

Ledger after this slice: reuse 114, keep 3, generate 36, symbol 159, review 796. The tsv is still 1,108 rows. The map has 109 keys. Xcode was not run.

Places and toy slice. Play on Words is 1,155, and the Sound flips section was last confirmed matching at the 19:34 save. Store, sections, briefs, and tests stayed that 19:34 save. The catalog map was still the 109 keys when these seven were added.

| Heard word | File |
|---|---|
| leavin' a lot | noun-dealership-lot |
| brought my lawyer | noun-courtroom |
| water gun | noun-water-toy |
| from the ends | noun-neighborhood |
| like little leaguers | noun-outfield |
| hit JFK | noun-airport |
| Slauson or Watts | noun-swap-meet |

Leavin' a lot uses the lot. The parking sign stays off. Brought my lawyer uses the court. Jewelry stays the partner. Water gun uses the toy. From the ends uses the block. The corner model stays off. Like little leaguers uses the empty outfield. Hit JFK uses the terminal. The bridge mark stays off. Slauson or Watts uses the stalls.

noun-leavin-a-lot, the phrase wordmarks, and noun-place-hood stay off these chips. noun-plane stays off the airport.

Ledger after this slice: reuse 121, keep 3, generate 29, symbol 159, review 796. The tsv is still 1,108 rows. The map has 116 keys. Xcode was not run.

Sun, bill, ball, tape, calendar, number, and resort slice. Play on Words is 1,155. Store, sections, briefs, and tests stayed the 19:34 save. The catalog map was still the 116 keys when these seven were added.

| Heard word | File |
|---|---|
| my sons | noun-sun |
| blue in the safe | noun-money-hundred |
| Jr. Smith | noun-held-ball |
| Dream Chaser | noun-cassette |
| Jrue Holiday | noun-calendar |
| cloned Michael Jordan | noun-number-23 |
| Bulgari | noun-resort |

My sons uses the sun. Blue in the safe uses the blue bill. The closed safe stays off. The banded stack stays off. Jr. Smith uses the ball in the hand. The loose ball stays off. Dream Chaser uses the tape. The wordmarks stay off. Jrue Holiday uses the calendar. The player stays off. Cloned Michael Jordan uses the number. The face stays off. Bulgari uses the resort.

Ledger after this slice: reuse 128, keep 3, generate 22, symbol 159, review 796. The tsv is still 1,108 rows. The map has 123 keys. Xcode was not run.

Hotel, motel, formula, gold, marker, airliner, and dive slice. Play on Words is 1,163. The last word is all that. Store, sections, briefs, and tests are the 19:59 save. The catalog map was still the 123 keys when these seven were added. Eight chips were added after throwin' salt: Quasimodo, Ricky, edible arrangement, no more drama, moi, red dirt, blue strips, and all that. Those eight stay outside the ledger.

| Heard word | File |
|---|---|
| sharin' ten | noun-hotel |
| until my days end | noun-motel |
| like Similac | noun-formula |
| eighteen karats | noun-gold-bars |
| rippin' markers | noun-marker |
| Spirit | noun-airliner |
| die | noun-diving-board |

Die stays outside the ledger. The map line is the wire.

Sharin' ten uses the hotel. The sign stays off. Until my days end uses the motel. The sign stays off. Like Similac uses the formula. The label stays off. Eighteen karats uses the gold. The watch name stays off. Rippin' markers uses the marker. Spirit uses the airliner. The tail mark stays off. Die uses the empty board.

noun-plane stays off Spirit. noun-golds and noun-patek-gold stay off eighteen karats.

Ledger after this slice: reuse 134, keep 3, generate 16, symbol 159, review 796. The tsv is still 1,108 rows. The map has 130 keys. Xcode was not run.

Coins, hall, syrup, wings, duplex, score, and thread slice. The catalog map was still the 130 keys, and Play on Words was 1,163, when these seven were added. The other terminal then saved all five Swift files at 20:10. Play on Words is 1,169. The last word is wild out. The map kept these seven keys. Six chips were added after all that: high, white horns, doubled up, pip, chicken wing, and wild out. Those six stay outside the ledger.

| Heard word | File |
|---|---|
| twenty | noun-coins |
| Naismith | noun-basketball-hall |
| Cracker Barrel | noun-syrup |
| Red Bull | noun-wings |
| Linwood | noun-duplex |
| hundred | noun-score-100 |
| Android | noun-thread |

Twenty, Naismith, Cracker Barrel, Red Bull, Linwood, and hundred stay outside the ledger. Android is the ledger row.

Twenty uses the coins. The app stays off. Naismith uses the hall. The facade words stay off. Cracker Barrel uses the syrup. The restaurant mark stays off. Red Bull uses the wings. The can and the bulls stay off. Linwood uses the two-family house. Hundred uses the score. The banded stack stays off. Android uses the green thread. The robot stays off.

noun-coinbase, noun-chicken-wings, noun-robin-jeans, and noun-money-bands stay off these chips.

Ledger after this slice: reuse 135, keep 3, generate 15, symbol 159, review 796. The tsv is still 1,108 rows. The map has 137 keys. Xcode was not run.

Fruit, kiss, clay, the triple-double, lemon pepper, the blue bill, and the hunch. Play on Words is 1,169. The last word is wild out. These seven stay outside the ledger. The map went from 137 keys to 144.

| Heard word | File |
|---|---|
| edible arrangement | noun-fruit |
| moi | noun-kiss |
| red dirt | noun-clay |
| doubled up | noun-triple-double |
| chicken wing | noun-lemon-pepper |
| blue strips | noun-money-hundred |
| quasimodo | noun-hunch |

Edible arrangement uses the fruit. The bouquet mark stays off. Moi uses the kiss. Red dirt uses the clay. Doubled up uses the triple-double. Oscar's face stays off. Chicken wing uses the lemon pepper. The buffalo wings and the feathered wings stay off. Blue strips uses the blue bill. The banded stack stays off. Quasimodo uses the hunch.

noun-chicken-wings, noun-wings, and noun-money-bands stay off these chips.

Ledger after this slice: reuse 135, keep 3, generate 15, symbol 159, review 796. The tsv is still 1,108 rows. The map has 144 keys. Xcode was not run.

The medal, the flag, the football, the hoop, the department store, the gate, and the long hair. The other terminal saved at 20:22. Play on Words is 1,172. The last word is red beans and rice. The map kept the 144 keys, then these seven were added. Six stay outside the ledger. May see us is the ledger row.

| Heard word | File |
|---|---|
| second place | noun-pride |
| rainbow | noun-rainbow-flag |
| hut | noun-football |
| Clinton Capella | noun-alley-oop |
| may see us | noun-department-store |
| Uzi Made | noun-torii |
| Earl Sweatshirt | noun-curly-hair |

Second place uses the silver medal. The gold-medal wordmark stays off. Rainbow uses the flag. The medal file stays off this chip. Hut uses the football. Clinton Capella uses the hoop. The alley-oop wordmark and the plain ball stay off. May see us uses the department store. The name stays off. Uzi Made uses the gate. Earl Sweatshirt uses the long hair. The haircut stays off.

Ledger after this slice: reuse 136, keep 3, generate 14, symbol 159, review 796. The tsv is still 1,108 rows. The map has 151 keys. Xcode was not run.

The bill, the cash, the lumberjack, the long shot, the miss, and the ranch. Play on Words is 1,172. The last word is red beans and rice. These six stay outside the ledger. The map went from 151 keys to 157.

| Heard word | File |
|---|---|
| blue | noun-money-hundred |
| red beans and rice | noun-money-racks |
| Paul Bunyan | noun-lumberjack |
| pull | noun-three-pointer |
| Paul George | noun-missed-shot |
| Neverland | noun-ranch |

Blue uses the blue bill. Red beans and rice uses the cash. The rice and the beans stay off. The bank sack stays off. Paul Bunyan uses the lumberjack. The folded shirt stays off. Pull uses the long shot. The three-point wordmark stays off. Curry's face stays off. Paul George uses the miss. His face stays off. The car wheel stays off. Neverland uses the ranch.

Ledger after this slice: reuse 136, keep 3, generate 14, symbol 159, review 796. The tsv is still 1,108 rows. The map has 157 keys. Xcode was not run.

The dad, the brothers, the artist, the group, and the tape. The other terminal saved at 20:44. Play on Words is 1,177. The last word is thug life. Store, sections, briefs, and tests are that 20:44 save. The catalog map was still the 157 keys when these five were added. Brook and Robin, billy, and Thottie breaking stay outside the ledger. Onyx and meet PARTY are the ledger rows.

| Heard word | File |
|---|---|
| billy | noun-billy-ray |
| Brook and Robin | noun-lopez-brothers |
| meet PARTY | noun-party-next |
| Onyx | noun-onyx |
| Thottie breaking | noun-cassette |

Billy uses the dad. Hannah Montana stays off. Brook and Robin use the brothers. The school name stays off. Meet PARTY uses the artist. The concert mic stays off. Onyx uses the group. The shirt name stays off. Thottie breaking uses the tape. The album stays off.

Shameless, Maino, beef, Kyro, and thug life arrived with the 20:44 save. They stay outside this slice.

Ledger after this slice: reuse 138, keep 3, generate 12, symbol 159, review 796. The tsv is still 1,108 rows. The map has 162 keys. Xcode was not run.

The meat and the record. Play on Words is 1,177. The last word is thug life. Store, sections, briefs, and tests stayed the 20:44 save. The catalog map was still the 162 keys when these four were added. All four stay outside the ledger.

| Heard word | File |
|---|---|
| beef | noun-beef |
| Die Lit | noun-vinyl |
| Maino | noun-vinyl |
| no more drama | noun-vinyl |

Beef uses the steak. The can, the lobster, and the gyro stay off. Die Lit, Maino, and no more drama use the disc. The covers stay off. Blige and Carti stay off.

Shameless, Kyro, and thug life stay unwired. Shameless is the show. Kyro is the affiliate. Thug life is the pose.

Ledger after this slice: reuse 138, keep 3, generate 12, symbol 159, review 796. The tsv is still 1,108 rows. The map has 166 keys. Xcode was not run.

The name and the bar. Play on Words is 1,177. The last word is thug life. Store, sections, briefs, and tests stayed the 20:44 save. The catalog map was still the 166 keys when these five were added. All five were already ledger rows.

| Heard word | File |
|---|---|
| Kevin Gates | noun-celeb-kevin-gates |
| Jamie Fox | noun-jamie-foxx |
| Eric Reid | noun-celeb-eric-reid |
| Suge Knight | noun-suge-knight |
| Dial soap | noun-dial-soap |

Kevin Gates uses the name. The fence stays off. Jamie Fox uses the name. The animal stays off. Eric Reid uses the name. The whistle stays off. Suge Knight uses the name. By the night stays off. Dial soap uses the bar.

Ledger after this slice: reuse 138, keep 3, generate 12, symbol 159, review 796. The tsv is still 1,108 rows. The map has 171 keys. Xcode was not run.

The engine and the block. Play on Words is 1,177. The last word is thug life. Store, sections, briefs, and tests stayed the 20:44 save. The catalog map was still the 171 keys when these two were added. Both were already ledger rows.

| Heard word | File |
|---|---|
| like Thomas | noun-locomotive |
| Serge Ibaka | noun-blocked-shot |

Like Thomas uses the engine. The car engine stays off. Serge Ibaka uses the block. The place stays off. His face stays off.

Ledger after this slice: reuse 140, keep 3, generate 12, symbol 159, review 794. The tsv is still 1,108 rows. The map has 173 keys. Xcode was not run.

The number and the name. Play on Words is 1,181. The last word is Optimus. Store, sections, briefs, and tests are the 21:19:35 save. The catalog map was still the 173 keys when these five were added. All five were already ledger rows.

| Heard word | File |
|---|---|
| John Collins | noun-number-20 |
| Alvin Kamara | noun-celeb-alvin-kamara |
| Monica Lewinsky | noun-celeb-monica-lewinsky |
| with the Migos | noun-celeb-takeoff |
| like Offset | noun-celeb-takeoff |

John Collins uses the number. Alvin Kamara uses the name. The team mark stays off. Monica Lewinsky uses the name. The watch stays off. With the Migos and like Offset share the name. The takeoff stays the person.

Ariel, bae, Rey Mysterio, and Optimus arrived with the 21:19 save. They stay outside this slice.

Ledger after this slice: reuse 145, keep 3, generate 12, symbol 159, review 789. The tsv is still 1,108 rows. The map has 178 keys. Xcode was not run.

The mermaid, the bay, the number, and the robot. Play on Words is 1,181. The last word is Optimus. Store, sections, briefs, and tests stayed the 21:19:35 save. The catalog map was still the 178 keys when these four were added. All four stay outside the ledger.

| Heard word | File |
|---|---|
| Ariel | noun-mermaid |
| bae | noun-bay |
| Rey Mysterio | noun-number-619 |
| Optimus | noun-robot |

Ariel uses the mermaid. Bae uses the bay. The wordmarks stay off. Rey Mysterio uses the number. The mask stays off. Optimus uses the robot. The character stays off.

Ledger after this slice: reuse 145, keep 3, generate 12, symbol 159, review 789. The tsv is still 1,108 rows. The map has 182 keys. Xcode was not run.

The seat, the hotel, the hair, and the shot. Play on Words is 1,181. The last word is Optimus. Store, sections, briefs, and tests stayed the 21:19:35 save. The catalog map was still the 182 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| a ponytail | noun-ponytail |
| sit in coach | noun-plane-seat |
| pillow with a mint | noun-hotel |
| like a vaccination | noun-syringe |

A ponytail uses the hair. Sit in coach uses the seat. Pillow with a mint uses the hotel. Like a vaccination uses the shot. The label stays off.

Keyboard stays on the symbol. Cheap seat already shows the bleachers.

Ledger after this slice: reuse 149, keep 3, generate 12, symbol 159, review 785. The tsv is still 1,108 rows. The map has 186 keys. Xcode was not run.

The water, the cover, and the hangout. Play on Words is 1,181. The last word is Optimus. Store, sections, briefs, and tests stayed the 21:19:35 save. The catalog map was still the 186 keys when these three were added. All three were already ledger rows.

| Heard word | File |
|---|---|
| Olympic pools | noun-lap-pool |
| a canopy | noun-canopy |
| doughnut shops | noun-doughnut-shop |

Olympic pools uses the water. The rings stay off. A canopy uses the cover. Doughnut shops uses the hangout. The wordmark stays off.

Ledger after this slice: reuse 152, keep 3, generate 12, symbol 159, review 782. The tsv is still 1,108 rows. The map has 189 keys. Xcode was not run.

The tire, the jeans, and the hotel. Play on Words is 1,181. The last word is Optimus. Store, sections, briefs, and tests stayed the 21:19:35 save. The catalog map was still the 189 keys when these three were added. All three were already ledger rows.

| Heard word | File |
|---|---|
| like Yokohama | noun-tires |
| my true religion | noun-jeans |
| moved out the Ritz | noun-hotel |

Like Yokohama uses the tire. The brand stays off. My true religion uses the jeans. The horseshoe stays off. Moved out the Ritz uses the hotel. The wordmark stays off.

Ledger after this slice: reuse 155, keep 3, generate 12, symbol 159, review 779. The tsv is still 1,108 rows. The map has 192 keys. Xcode was not run.

The piano, the phone, the shot, and the sky. Play on Words is 1,181. The last word is Optimus. Store, sections, briefs, and tests stayed the 21:19:35 save. The catalog map was still the 192 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| no off notes | noun-piano |
| on the hotline | noun-phone |
| serve backhands | noun-tennis-shot |
| orange full moon | noun-full-moon |

No off notes uses the piano. On the hotline uses the phone. Serve backhands uses the shot. Orange full moon uses the sky. The brand marks stay off.

Ledger after this slice: reuse 159, keep 3, generate 12, symbol 159, review 775. The tsv is still 1,108 rows. The map has 196 keys. Xcode was not run.

The yard, the road, the bottle, and the stick. Play on Words is 1,181. The last word is Optimus. Store, sections, briefs, and tests stayed the 21:19:35 save. The catalog map was still the 196 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| Garden of Eden | noun-yard |
| know the road | noun-road |
| fountain of youth | noun-bottle |
| speed stick | noun-deodorant |

Garden of Eden uses the yard. Know the road uses the route. Fountain of youth uses the bottle. Speed stick uses the deodorant. The label stays off.

Ledger after this slice: reuse 163, keep 3, generate 12, symbol 159, review 771. The tsv is still 1,108 rows. The map has 200 keys. Xcode was not run.

The ink, the watch, the scent, and the wedding. Play on Words is 1,181. The last word is Optimus. Store, sections, briefs, and tests stayed the 21:19:35 save. The catalog map was still the 200 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| cover up | noun-ink |
| patty gang | noun-watch |
| less sense | noun-perfume |
| copying some vows | noun-wedding-bands |

Cover up uses the ink. The label stays off. Patty gang uses the watch. The crown stays off. Less sense uses the scent. The label stays off. Copying some vows uses the wedding.

Ledger after this slice: reuse 167, keep 3, generate 12, symbol 159, review 767. The tsv is still 1,108 rows. The map has 204 keys. Xcode was not run.

The cloud, the bubble, the metal, and the kick. Play on Words is 1,181. The last word is Optimus. Store, sections, briefs, and tests stayed the 21:19:35 save. The catalog map was still the 204 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| a lot of smoke | noun-cloud |
| end of a world | noun-bubble |
| not a stainless | noun-metal |
| kick a punt | noun-punt |

A lot of smoke uses the cloud. End of a world uses the bubble. Not a stainless uses the metal. Kick a punt uses the kick. The mark stays off.

Ledger after this slice: reuse 171, keep 3, generate 12, symbol 159, review 763. The tsv is still 1,108 rows. The map has 208 keys. Xcode was not run.

The arena, the tattoo, the step-back, and the shot. Play on Words is 1,183. The last word is Leo. Store, sections, briefs, and tests stayed the 21:50:22 save. The catalog map was still the 208 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| the garden | noun-arena |
| guns with the ink | noun-skin-ink |
| hit the Harden | noun-step-back |
| straight to the face | noun-shot-glass |

The garden uses the arena. The team mark stays off. Guns with the ink uses the tattoo. Hit the Harden uses the step-back. The mark stays off. Straight to the face uses the shot.

Ledger after this slice: reuse 175, keep 3, generate 12, symbol 159, review 759. The tsv is still 1,108 rows. The map has 212 keys. Xcode was not run.

The station, the sign, the letters, and the bills. Play on Words is 1,183. The last word is Leo. Store, sections, briefs, and tests stayed the 21:50:22 save. The catalog map was still the 212 keys when these four were added. Shell and Leo stay outside the ledger. The letters and the bills were already ledger rows.

| Heard word | File |
|---|---|
| Shell | noun-gas-station |
| Leo | noun-sign-leo |
| P-I-C | noun-letters-pic |
| throw your ones | noun-bills |

Shell uses the station. The mark stays off. Leo uses the sign. The lion file stays off. P-I-C uses the letters. Throw your ones uses the bills. The design stays off.

Ledger after this slice: reuse 177, keep 3, generate 12, symbol 159, review 757. The tsv is still 1,108 rows. The map has 216 keys. Xcode was not run.

The record, the cash, the payment, and the catch. Play on Words is 1,183. The last word is Leo. Store, sections, briefs, and tests stayed the 21:50:22 save. The catalog map was still the 216 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| a ghost town | noun-vinyl |
| that cream | noun-cash |
| checks cut | noun-payment |
| reach back | noun-catch |

A ghost town uses the record. That cream uses the cash. The design stays off. Checks cut uses the payment. The bank stays off. Reach back uses the catch.

Ledger after this slice: reuse 181, keep 3, generate 12, symbol 159, review 753. The tsv is still 1,108 rows. The map has 220 keys. Xcode was not run.

The city, the block, the height, and the office. Play on Words is 1,183. The last word is Leo. Store, sections, briefs, and tests stayed the 21:50:22 save. The catalog map was still the 220 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| back in the Six | noun-skyline |
| seedy | noun-city-block |
| I peak | noun-summit |
| we don't get impeached | noun-office |

Back in the Six uses the city. The team mark stays off. Seedy uses the block. The characters stay off. I peak uses the height. We don't get impeached uses the office. The seal stays off.

Ledger after this slice: reuse 185, keep 3, generate 12, symbol 159, review 749. The tsv is still 1,108 rows. The map has 224 keys. Xcode was not run.

The posture, the crowd, the rank, and the win. Play on Words is 1,188. The last word is GED. The 22:11:07 save kept these four picture keys. Store, sections, briefs, and tests are that save. The map was 224 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| standin' up | noun-posture |
| draw attention | noun-crowd |
| top three | noun-podium |
| comin' in first | noun-finish-tape |

Standin' up uses the posture. The face stays off. Draw attention uses the crowd. Faces stay off. Top three uses the rank. Numbers stay off. Comin' in first uses the win. Marks stay off.

Ledger after this slice: reuse 189, keep 3, generate 12, symbol 159, review 745. The tsv is still 1,108 rows. The map has 228 keys. Xcode was not run.

The llama, the bakery, the test, and the animal. Play on Words is 1,189. The last word is Poseidon. The 22:39:29 save kept these four picture keys. Store, sections, briefs, and tests are that save. The map was 228 keys when these four were added. Tina, Denise's, and GED stay outside the ledger. Shot a buffalo was already a ledger row.

| Heard word | File |
|---|---|
| Tina | noun-llama |
| Denise's | noun-bakery |
| GED | noun-exam |
| shot a buffalo | noun-buffalo |

Tina uses the llama. The celeb file stays off. Denise's uses the bakery. The cake stays off. GED uses the test. The letters stay off. Shot a buffalo uses the animal. The team mark stays off.

Ledger after this slice: reuse 190, keep 3, generate 12, symbol 159, review 744. The tsv is still 1,108 rows. The map has 232 keys. Xcode was not run.

The snake, the hat, the mouse, and the dog. Play on Words is 1,189. The last word is Poseidon. Store, sections, briefs, and tests stayed the 22:39:29 save. The catalog map was still the 232 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| black mamba | noun-snake |
| like Montana | noun-cowboy-hat |
| double click | noun-computer-mouse |
| I'm a pitbull | noun-pit-dog |

Black mamba uses the snake. The nickname stays off. Like Montana uses the hat. The names stay off. Double click uses the mouse. The animal stays off. I'm a pitbull uses the dog. The artist stays off.

Ledger after this slice: reuse 194, keep 3, generate 12, symbol 159, review 740. The tsv is still 1,108 rows. The map has 236 keys. Xcode was not run.

The snake, the fish, the milk, and the track. Play on Words is 1,189. The last word is Poseidon. Store, sections, briefs, and tests stayed the 22:39:29 save. The catalog map was still the 236 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| king cobra | noun-cobra |
| bigger fish | noun-fish |
| two percent | noun-milk |
| life's hurdles | noun-hurdle |

King cobra uses the snake. The sequel stays off. Bigger fish uses the seafood. The fry stays off. Two percent uses the milk. The share stays off. Life's hurdles uses the track. The athlete stays off.

Ledger after this slice: reuse 198, keep 3, generate 12, symbol 159, review 736. The tsv is still 1,108 rows. The map has 240 keys. Xcode was not run.

The seam, the foil, the sign, and the cake. Play on Words is 1,189. The last word is Poseidon. Store, sections, briefs, and tests stayed the 22:39:29 save. The catalog map was still the 240 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| how it seems | noun-seam |
| like wrappers | noun-foil |
| billboard | noun-painted-sign |
| pound cake | noun-pound-cake |

How it seems uses the seam. The look stays off. Like wrappers uses the foil. The rappers stay off. Billboard uses the sign. The charts stay off. Pound cake uses the cake. The money stays off.

Ledger after this slice: reuse 202, keep 3, generate 12, symbol 159, review 732. The tsv is still 1,108 rows. The map has 244 keys. Xcode was not run.

The animal, the speaker, the pizza, and the shirt. Play on Words is 1,189. The last word is Poseidon. Store, sections, briefs, and tests stayed the 22:39:29 save. The catalog map was still the 244 keys when these four were added. All four were already ledger rows. The files were already in the asset catalog.

| Heard word | File |
|---|---|
| cash cow | noun-cow |
| through a speaker | noun-speakers |
| pizza man | noun-pizza |
| no jersey | noun-jersey |

Cash cow uses the animal. The money stays off. Through a speaker uses the speaker. The patois stays off. Pizza man uses the pizza. The driver stays off. No jersey uses the shirt. The club stays off.

Ledger after this slice: reuse 206, keep 3, generate 12, symbol 159, review 728. The tsv is still 1,108 rows. The map has 248 keys. Xcode was not run.

The plant, the socks, the roof, and the cup. Play on Words is 1,189. The last word is Poseidon. Store, sections, briefs, and tests stayed the 22:39:29 save. The catalog map was still the 248 keys when these four were added. A flower would grow, the top is gone, and tea with the stars were already ledger rows. We sockin' stays outside the ledger. The files were already in the asset catalog.

| Heard word | File |
|---|---|
| a flower would grow | noun-flowers |
| we sockin' | noun-socks |
| the top is gone | noun-sunroof |
| tea with the stars | noun-green-tea |

A flower would grow uses the plant. The song stays off. We sockin' uses the socks. The punch stays off. The top is gone uses the roof. The car stays off. Tea with the stars uses the cup. The fame stays off.

Ledger after this slice: reuse 209, keep 3, generate 12, symbol 159, review 725. The tsv is still 1,108 rows. The map has 252 keys. Xcode was not run.

The dock, the shark, the wheel, and the seats. Play on Words is 1,191. The last word is cadera. Store, sections, briefs, and tests stayed the 22:59:21 save. The catalog map was still the 252 keys when these four were added. Fishing for some answers, heat seats, and will me to defeat were already ledger rows. Off a Quay stays outside the ledger. The files were already in the asset catalog.

| Heard word | File |
|---|---|
| off a quay | noun-dock |
| fishing for some answers | noun-shark |
| will me to defeat | noun-wheels |
| heat seats | noun-seats |

Off a Quay uses the dock. The pill stays off. Fishing for some answers uses the shark. The hunt stays off. Will me to defeat uses the wheel. The will and the feet stay off. Heat seats uses the seats. The heat stays off.

Ledger after this slice: reuse 212, keep 3, generate 12, symbol 159, review 722. The tsv is still 1,108 rows. The map has 256 keys. Xcode was not run.

The phone, the clock, the piano, and the airport. Play on Words is 1,191. The last word is cadera. Store, sections, briefs, and tests stayed the 22:59:21 save. The catalog map was still the 256 keys when these four were added. All four were already ledger rows. The files were already in the asset catalog.

| Heard word | File |
|---|---|
| block her | noun-phone |
| he might clock | noun-clock |
| talk keys | noun-piano |
| up in arrivals | noun-airport |

Block her uses the phone. The defense stays off. He might clock uses the clock. The hit stays off. Talk keys uses the piano. The cocaine stays off. Up in arrivals uses the airport. Making it stays off.

Ledger after this slice: reuse 216, keep 3, generate 12, symbol 159, review 718. The tsv is still 1,108 rows. The map has 260 keys. Xcode was not run.

The animal, the chain, the metal, and the dial. Play on Words is 1,191. The last word is cadera. Store, sections, briefs, and tests stayed the 22:59:21 save. The catalog map was still the 260 keys when these four were added. All four were already ledger rows. The files were already in the asset catalog.

| Heard word | File |
|---|---|
| Detroit Lions | noun-lions |
| necklace a Frank | noun-necklace |
| more Chrome | noun-metal |
| watch face | noun-watch |

Detroit Lions uses the animal. The team stays off. Necklace a Frank uses the chain. The character stays off. More Chrome uses the metal. The suits stay off. Watch face uses the dial. The expression stays off.

Ledger after this slice: reuse 220, keep 3, generate 12, symbol 159, review 714. The tsv is still 1,108 rows. The map has 264 keys. Xcode was not run.

The fish, the pizza, and the coins. Play on Words is 1,191. The last word is cadera. Store, sections, briefs, and tests stayed the 22:59:21 save. The catalog map was still the 264 keys when these four were added. All four were already ledger rows. The files were already in the asset catalog.

| Heard word | File |
|---|---|
| find me, Nemo | noun-fish |
| Nemo in the ocean | noun-fish |
| like Little Caesars | noun-pizza |
| two cents | noun-coins |

Find me, Nemo uses the fish. The character stays off. Nemo in the ocean uses the fish. The fry stays off. Like Little Caesars uses the pizza. The brand stays off. Two cents uses the coins. The opinion stays off.

Ledger after this slice: reuse 224, keep 3, generate 12, symbol 159, review 710. The tsv is still 1,108 rows. The map has 268 keys. Xcode was not run.

The fish, the coins, the crane, and the harp. Play on Words is 1,195. The last word is nerd. Store and sections stayed the 00:09:43 save. Briefs and tests stayed the 23:43:18 save. The catalog map was still the 268 keys when these four were added. Tuna in a bowl and the game needs change were already ledger rows. Origami and harp stay outside the ledger.

| Heard word | File |
|---|---|
| tuna in a bowl | noun-fish |
| the game needs change | noun-coins |
| origami | noun-origami |
| harp | noun-harp |

Tuna in a bowl uses the fish. The cash stays off. The game needs change uses the coins. The industry stays off. Origami uses the crane. The paper stays off. Harp uses the harp. The strings stay off.

Ledger after this slice: reuse 226, keep 3, generate 12, symbol 159, review 708. The tsv is still 1,108 rows. The map has 272 keys. Xcode was not run.

The door, the crown, the pins, and the wash. Play on Words is 1,195. The last word is nerd. Store and sections stayed the 00:09:43 save. Briefs and tests stayed the 23:43:18 save. The catalog map was still the 272 keys when these four were added. All four were already ledger rows.

| Heard word | File |
|---|---|
| anyone home | noun-door |
| reigning supreme | noun-crown |
| bowl a strike | noun-bowling-pins |
| airing laundry | noun-laundry |

Anyone home uses the door. The knockout stays off. Reigning supreme uses the crown. The rain stays off. Bowl a strike uses the pins. The body stays off. Airing laundry uses the wash. The gossip stays off.

Ledger after this slice: reuse 230, keep 3, generate 12, symbol 159, review 704. The tsv is still 1,108 rows. The map has 276 keys. Xcode was not run.

The gate, the ticket, the battery, and the tire. Play on Words is 1,199. The last word is Crawford. Store, sections, briefs, and tests stayed the 01:05:30 save. The catalog map was still the 276 keys when these four were added. All four were already ledger rows. The tire was already in the asset catalog.

| Heard word | File |
|---|---|
| short gate | noun-gate |
| season pass | noun-ticket |
| like a battery | noun-battery |
| big tired | noun-tires |

Short gate uses the gate. The fame stays off. Season pass uses the ticket. The stretch stays off. Like a battery uses the battery. The car stays off. Big tired uses the tire. The fatigue stays off.

Ledger after this slice: reuse 234, keep 3, generate 12, symbol 159, review 700. The tsv is still 1,108 rows. The map has 280 keys. Xcode was not run.

The door, the clock, the piano, and the plane. Play on Words is 1,199. The last word is Crawford. Store, sections, briefs, and tests stayed the 01:05:30 save. The catalog map was still the 280 keys when these four were added. All four were already ledger rows. The four files were already in the asset catalog.

| Heard word | File |
|---|---|
| under the mat | noun-door |
| buy time | noun-clock |
| off my keyboard | noun-piano |
| shoot down my flight | noun-plane |

Under the mat uses the door. The hide stays off. Buy time uses the clock. The cash stays off. Off my keyboard uses the piano. The nose stays off. Shoot down my flight uses the plane. The envy stays off.

Ledger after this slice: reuse 238, keep 3, generate 12, symbol 159, review 696. The tsv is still 1,108 rows. The map has 284 keys. Xcode was not run.

The circle, the chain, the coin, and the pen. Play on Words is 1,199. The last word is Crawford. Store, sections, briefs, and tests stayed the 01:05:30 save. The catalog map was still the 284 keys when these four were added. All four were already ledger rows. The four files were already in the asset catalog.

| Heard word | File |
|---|---|
| like a tire | noun-tires |
| diamondbacks | noun-necklace |
| made a nickel | noun-coins |
| the ink | noun-ink |

Like a tire uses the circle. The letter stays off. Diamondbacks uses the chain. The snake stays off. Made a nickel uses the coin. The sense stays off. The ink uses the pen. The label stays off.

Ledger after this slice: reuse 242, keep 3, generate 12, symbol 159, review 692. The tsv is still 1,108 rows. The map has 288 keys. Xcode was not run.

The shark, the crown, the pen, and the card. Play on Words is 1,199. The last word is Crawford. Store, sections, briefs, and tests stayed the 01:05:30 save. The catalog map was still the 288 keys when these four were added. All four were already ledger rows. The four files were already in the asset catalog.

| Heard word | File |
|---|---|
| swim with the sharks | noun-shark |
| take my crown | noun-crown |
| write my wrongs | noun-ink |
| take my credit card | noun-credit-card |

Swim with the sharks uses the shark. The water stays off. Take my crown uses the crown. The end stays off. Write my wrongs uses the pen. The fix stays off. Take my credit card uses the card. The spend stays off.

Ledger after this slice: reuse 246, keep 3, generate 12, symbol 159, review 688. The tsv is still 1,108 rows. The map has 292 keys. Xcode was not run.

The sheep, the rat, the key, and the street. Play on Words is 1,199. The last word is Crawford. Store, sections, briefs, and tests stayed the 01:05:30 save. The catalog map was still the 292 keys when these four were added. All four were already ledger rows. The four files were already in the asset catalog.

| Heard word | File |
|---|---|
| act like sheeps | noun-sheep |
| mall with a rat | noun-rat |
| caps lock | noun-keyboard |
| dodge the block | noun-city-block |

Act like sheeps uses the sheep. The title stays off. Mall with a rat uses the rat. The snitch stays off. Caps lock uses the key. The money stays off. Dodge the block uses the street. The defense stays off.

Ledger after this slice: reuse 250, keep 3, generate 12, symbol 159, review 684. The tsv is still 1,108 rows. The map has 296 keys. Xcode was not run.

The pen, the animal, the cat, and the dumpling. Play on Words is 1,200. The last word is Ambush. Store, sections, briefs, and tests stayed the 01:33:17 save. The catalog map was still the 296 keys when these four were added. All four were already ledger rows. The pen was already in the asset catalog. The animal, the cat, and the dumpling are new files.

| Heard word | File |
|---|---|
| dust a man | noun-ink |
| couple of beavers | noun-beaver |
| two cougars | noun-cougar |
| dim some | noun-dumpling |

Dust a man uses the pen. The series stays off. A couple of beavers uses the animal. The dam stays off. Two cougars uses the cat. The car stays off. Dim some uses the dumpling. The lights stay off.

Ledger after this slice: reuse 254, keep 3, generate 12, symbol 159, review 680. The tsv is still 1,108 rows. The map has 300 keys. Xcode was not run.

The spine, the hand, the eye, and the staple. Play on Words is 1,200. The last word is Ambush. Store, sections, briefs, and tests stayed the 01:33:17 save. The catalog map was still the 300 keys when these four were added. All four were already ledger rows. The spine, the hand, the eye, and the staple are new files.

| Heard word | File |
|---|---|
| bring the real back | noun-spine |
| bit the hand | noun-hand |
| no glaucoma | noun-eye |
| staple in the game | noun-staple |

Bring the real back uses the spine. The realness stays off. Bit the hand uses the hand. The bite stays off. No glaucoma uses the eye. The smoke stays off. Staple in the game uses the staple. The fixture stays off.

Ledger after this slice: reuse 258, keep 3, generate 12, symbol 159, review 676. The tsv is still 1,108 rows. The map has 304 keys. Xcode was not run.

The dog, the eye, the hand, and the ketchup. Play on Words is 1,200. The last word is Ambush. Store, sections, briefs, and tests stayed the 01:33:17 save. The catalog map was still the 304 keys when these four were added. All four were already ledger rows. The dog, the eye, and the hand were already in the asset catalog. The ketchup is a new file.

| Heard word | File |
|---|---|
| the bark | noun-pit-dog |
| need supervision | noun-eye |
| never get dirty | noun-hand |
| catch up to the slaps | noun-ketchup |

The bark uses the dog. The talk stays off. Need supervision uses the eye. The watches stay off. Never get dirty uses the hand. The trail stays off. Catch up to the slaps uses the ketchup. The hits stay off.

Ledger after this slice: reuse 262, keep 3, generate 12, symbol 159, review 672. The tsv is still 1,108 rows. The map has 308 keys. Xcode was not run.

The slot, the tie, the bagel, and the pie. Play on Words is 1,200. The last word is Ambush. Store, sections, briefs, and tests stayed the 01:33:17 save. The catalog map was still the 308 keys when these four were added. All four were already ledger rows. The slot, the tie, the bagel, and the pie are new files.

| Heard word | File |
|---|---|
| cup holder | noun-cup-holder |
| cut the tie | noun-necktie |
| like a bagel | noun-bagel |
| sell pies | noun-pie |

Cup holder uses the slot. The dimes stay off. Cut the tie uses the tie. The split stays off. Like a bagel uses the bagel. The letter stays off. Sell pies uses the pie. The name stays off.

Ledger after this slice: reuse 266, keep 3, generate 12, symbol 159, review 668. The tsv is still 1,108 rows. The map has 312 keys. Xcode was not run.

The cheese, the coat, the toe, and the stones. Play on Words is 1,200. The last word is Ambush. Store, sections, briefs, and tests stayed the 01:33:17 save. The catalog map was still the 312 keys when these four were added. All four were already ledger rows. The cheese, the coat, the toe, and the stones are new files.

| Heard word | File |
|---|---|
| cheesehead | noun-cheese |
| like a coat | noun-coat |
| boot toes | noun-steel-toe |
| eight karats | noun-gems |

Cheesehead uses the cheese. The fan stays off. Like a coat uses the coat. The season stays off. Boot toes uses the toe. The flows stay off. Eight karats uses the stones. The carrots stay off.

Ledger after this slice: reuse 270, keep 3, generate 12, symbol 159, review 664. The tsv is still 1,108 rows. The map has 316 keys. Xcode was not run.

The pad, the bench, the receipt, and the record. Play on Words is 1,200. The last word is Ambush. Store, sections, briefs, and tests stayed the 01:33:17 save. The catalog map was still the 316 keys when these four were added. All four were already ledger rows. The record was already in the asset catalog. The pad, the bench, and the receipt are new files.

| Heard word | File |
|---|---|
| pad the stats | noun-notepad |
| like a hockey coach | noun-bench |
| posted receipts | noun-receipt |
| doing donuts | noun-vinyl |

Pad the stats uses the pad. The numbers stay off. Like a hockey coach uses the bench. The sticks stay off. Posted receipts uses the receipt. The bag stays off. Doing donuts uses the record. The spin stays off.

Ledger after this slice: reuse 274, keep 3, generate 12, symbol 159, review 660. The tsv is still 1,108 rows. The map has 320 keys. Xcode was not run.

The courthouse, the lamp, the ball, and the cabinet. Play on Words is 1,200. The last word is Ambush. Store, sections, briefs, and tests stayed the 01:33:17 save. The catalog map was still the 320 keys when these four were added. All four were already ledger rows. The courthouse, the lamp, the ball, and the cabinet are new files.

| Heard word | File |
|---|---|
| back and forth to court | noun-courthouse |
| came with a bar | noun-minibar |
| like a brake light | noun-brake-light |
| tennis ball | noun-tennis-ball |

Back and forth to court uses the courthouse. The game stays off. Came with a bar uses the cabinet. The number stays off. Like a brake light uses the lamp. The read stays off. Tennis ball uses the ball. The score stays off.

Ledger after this slice: reuse 278, keep 3, generate 12, symbol 159, review 656. The tsv is still 1,108 rows. The map has 324 keys. Xcode was not run.

The umbrella, the bird, the plate, and the court. Play on Words is 1,202. The last word is finessed. Store, sections, briefs, and tests stayed the 02:04:54 save. The catalog map was still the 324 keys when these four were added. All four were already ledger rows. The court was already in the asset catalog. The umbrella, the bird, and the plate are new files.

| Heard word | File |
|---|---|
| umbrellaed up | noun-umbrella |
| feathers they pluck | noun-bird |
| went halal | noun-plate |
| caught the hands | noun-courtroom |

Umbrellaed up uses the umbrella. The weather stays off. Feathers they pluck uses the bird. The door stays off. Went halal uses the plate. The beef stays off. Caught the hands uses the court. The fight stays off.

Ledger after this slice: reuse 282, keep 3, generate 12, symbol 159, review 652. The tsv is still 1,108 rows. The map has 328 keys. Xcode was not run.

The opener, the button, the key, and the tape. Play on Words is 1,202. The last word is finessed. Store, sections, briefs, and tests stayed the 02:04:54 save. The catalog map was still the 328 keys when these four were added. All four were already ledger rows. The tape was already in the asset catalog. The opener, the button, and the key are new files.

| Heard word | File |
|---|---|
| let her open 'em | noun-letter-opener |
| red button | noun-red-button |
| key to the city | noun-city-key |
| like some premises | noun-cassette |

Let her open 'em uses the opener. The mail stays off. Red button uses the button. The gate stays off. Key to the city uses the key. The name stays off. Like some premises uses the tape. The lines stay off.

Ledger after this slice: reuse 286, keep 3, generate 12, symbol 159, review 648. The tsv is still 1,108 rows. The map has 332 keys. Xcode was not run.

The socks, the tire, the glass, and the trunk. Play on Words is 1,202. The last word is finessed. Store, sections, briefs, and tests stayed the 02:04:54 save. The catalog map was still the 332 keys when these four were recorded. The socks were already on the map. The tire, the glass, and the trunk were already in the asset catalog.

| Heard word | File |
|---|---|
| we sockin' | noun-socks |
| like Firestone | noun-tires |
| my windshield | noun-windshield |
| trunk is in my hood | noun-trunk |

We sockin' uses the socks. The shoe stays off. Like Firestone uses the tire. The brand stays off. My windshield uses the glass. The winter stays off. Trunk is in my hood uses the trunk. The block stays off.

Ledger after this slice: reuse 290, keep 3, generate 12, symbol 159, review 644. The tsv is still 1,108 rows. The map has 335 keys. Xcode was not run.

The salad, the ball, the house, and the glue. Play on Words is 1,202. The last word is finessed. Store and sections are the 02:30:02 save. Briefs and tests stayed the 02:04:54 save. The catalog map was still the 335 keys when the salad, the ball, and the house were added. The ball was already in the asset catalog. The salad, the house, and the glue are new files. The glue uses the chip name.

| Heard word | File |
|---|---|
| eatin' Caesar | noun-salad |
| hittin' swishes | noun-basketball |
| not a BNB | noun-house |
| glue stick | noun-glue-stick |

Eatin' Caesar uses the salad. The palace stays off. Hittin' swishes uses the ball. The cigar stays off. Not a BNB uses the house. The bed stays off. Glue stick uses the glue. The gun stays off.

Ledger after this slice: reuse 294, keep 3, generate 12, symbol 159, review 640. The tsv is still 1,108 rows. The map has 338 keys. Xcode was not run.

The wine, the room, the desk, and the house. Play on Words is 1,202. The last word is finessed. Store and sections are the 02:30:02 save. Briefs and tests stayed the 02:04:54 save. The catalog map was still the 338 keys when these four were added. The house was already in the asset catalog. The wine, the room, and the desk are new files.

| Heard word | File |
|---|---|
| Domina | noun-wine |
| shackin' together | noun-room |
| head office | noun-desk |
| place in Jamaica | noun-house |

Domina uses the wine. The lady stays off. Shackin' together uses the room. The name stays off. Head office uses the desk. The store stays off. Place in Jamaica uses the house. The destination stays off.

Ledger after this slice: reuse 298, keep 3, generate 12, symbol 159, review 636. The tsv is still 1,108 rows. The map has 342 keys. Xcode was not run.

The noodles, the goat, and the horse. Play on Words is 1,202. The last word is finessed. Store and sections are the 02:30:02 save. Briefs and tests stayed the 02:04:54 save. The catalog map was still the 342 keys when these four were added. The noodles, the goat, and the horse are new files.

| Heard word | File |
|---|---|
| your noodle | noun-noodle |
| hit your noodle | noun-noodle |
| eatin' a goat | noun-goat |
| Triple Crown | noun-horse |

Your noodle uses the noodles. The head stays off. Hit your noodle uses the noodles. The head stays off. Eatin' a goat uses the goat. The title stays off. Triple Crown uses the horse. The drink stays off.

Ledger after this slice: reuse 302, keep 3, generate 12, symbol 159, review 632. The tsv is still 1,108 rows. The map has 346 keys. Xcode was not run.

The train, the pyramid, the alarm, and the seat. Play on Words is 1,202. The last word is finessed. Store and sections are the 02:30:02 save. Briefs and tests stayed the 02:04:54 save. The catalog map was still the 346 keys when these four were added. The train, the pyramid, the alarm, and the seat are new files.

| Heard word | File |
|---|---|
| TTC metro | noun-train |
| Pyramids | noun-pyramid |
| alarm ya | noun-alarm |
| cheap seat | noun-seat |

TTC metro uses the train. The producer stays off. Pyramids uses the pyramid. The song stays off. Alarm ya uses the alarm. The name stays off. Cheap seat uses the seat. The view stays off.

Ledger after this slice: reuse 306, keep 3, generate 12, symbol 159, review 628. The tsv is still 1,108 rows. The map has 350 keys. Xcode was not run.

The vegetables, the skate, the candy, and the bottle. Play on Words is 1,202. The last word is finessed. Store and sections are the 02:30:02 save. Briefs and tests stayed the 02:04:54 save. The catalog map was still the 350 keys when these four were added. The vegetables, the skate, the candy, and the bottle are new files.

| Heard word | File |
|---|---|
| goin' vegan | noun-vegetables |
| Tony Hawk | noun-skateboard |
| a-la-la-lollipop | noun-lollipop |
| Champagne popper | noun-sparkling |

Goin' vegan uses the vegetables. The fight stays off. Tony Hawk uses the skate. The name stays off. A-la-la-lollipop uses the candy. The song stays off. Champagne popper uses the bottle. The name stays off.

Ledger after this slice: reuse 310, keep 3, generate 12, symbol 159, review 624. The tsv is still 1,108 rows. The map has 354 keys. Xcode was not run.

The record, the cloth, and the urn. Play on Words is 1,202. The last word is finessed. Store and sections are the 02:30:02 save. Briefs and tests stayed the 02:04:54 save. The catalog map was still the 354 keys when these four were added. The record was already in the asset catalog. The cloth and the urn are new files.

| Heard word | File |
|---|---|
| the V's | noun-vinyl |
| victory lap | noun-vinyl |
| no Kente | noun-kente |
| pallbearers | noun-urn |

The V's uses the record. The verses stay off. Victory lap uses the record. The lap stays off. No Kente uses the cloth. The name stays off. Pallbearers uses the urn. The casket stays off.

Ledger after this slice: reuse 314, keep 3, generate 12, symbol 159, review 620. The tsv is still 1,108 rows. The map has 358 keys. Xcode was not run.

The whistle, the mask, the curtains, and the swing. Play on Words is 1,202. The last word is finessed. Store and sections are the 02:30:02 save. Briefs and tests stayed the 02:04:54 save. The catalog map was still the 358 keys when these four were added. The whistle, the mask, the curtains, and the swing are new files.

| Heard word | File |
|---|---|
| all I need is a whistle | noun-whistle |
| cover they head | noun-mask |
| draped up | noun-curtain |
| just swangin' | noun-swing |

All I need is a whistle uses the whistle. The official stays off. Cover they head uses the mask. The quiet stays off. Draped up uses the curtains. The shine stays off. Just swangin' uses the swing. The drive stays off.

Ledger after this slice: reuse 318, keep 3, generate 12, symbol 159, review 616. The tsv is still 1,108 rows. The map has 362 keys. Xcode was not run.

The door, the bench, the cell, and the plug. Play on Words is 1,202. The last word is finessed. Store and sections are the 02:30:02 save. Briefs and tests stayed the 02:04:54 save. The catalog map was still the 362 keys when these four were added. The door, the bench, and the cell were already in the asset catalog. The plug is a new file.

| Heard word | File |
|---|---|
| pickin' a lock | noun-door |
| red-shirted | noun-bench |
| see no time | noun-cell |
| got the hookup | noun-plug |

Pickin' a lock uses the door. The work stays off. Red-shirted uses the bench. The color stays off. See no time uses the cell. The watch stays off. Got the hookup uses the plug. The label stays off.

Ledger after this slice: reuse 322, keep 3, generate 12, symbol 159, review 612. The tsv is still 1,108 rows. The map has 366 keys. Xcode was not run.

The bottle, the watch, the film, and the planet. Play on Words is 1,202. The last word is finessed. Store and sections are the 02:30:02 save. Briefs and tests stayed the 02:04:54 save. The catalog map was still the 366 keys when these four were added. The bottle and the watch were already in the asset catalog. The film and the planet are new files.

| Heard word | File |
|---|---|
| water for the D's | noun-bottle |
| bought my dawg a Rollie | noun-watch |
| B-roll | noun-film |
| from Jupiter | noun-jupiter |

Water for the D's uses the bottle. The drivers stay off. Bought my dawg a Rollie uses the watch. The loyalty stays off. B-roll uses the film. The blood stays off. From Jupiter uses the planet. The rhyme stays off.

Ledger after this slice: reuse 326, keep 3, generate 12, symbol 159, review 608. The tsv is still 1,108 rows. The map has 370 keys. Xcode was not run.

The vest, the pint, Venus, and the two-tone watch. Play on Words is 1,202. The last word is finessed. Store and sections are the 02:30:02 save. Briefs and tests stayed the 02:04:54 save. The catalog map was still the 370 keys when these four were added. The vest, the pint, Venus, and the two-tone watch are new files.

| Heard word | File |
|---|---|
| feelin' bulletproof | noun-vest |
| guzzle a Guinness | noun-pint |
| go to Venus | noun-venus |
| two-tones | noun-two-tone |

Feelin' bulletproof uses the vest. The shots stay off. Guzzle a Guinness uses the pint. The book stays off. Go to Venus uses the planet. The sister stays off. Two-tones uses the watch. The gift stays off.

Ledger after this slice: reuse 330, keep 3, generate 12, symbol 159, review 604. The tsv is still 1,108 rows. The map has 374 keys. Xcode was not run.

The chain, the candy, the truck, and the cereal. Play on Words is 1,202. The last word is finessed. Store and sections are the 02:30:02 save. Briefs and tests stayed the 02:04:54 save. The catalog map was still the 374 keys when these four were added. The candy, the truck, and the cereal are new files. The chain was already in the catalog.

| Heard word | File |
|---|---|
| Tiffany on you | noun-necklace |
| Don't be ridiculous | noun-candy |
| Breakin' a Brink's | noun-truck |
| not a serial killer | noun-cereal-bowl |

Tiffany on you uses the chain. The shine stays off. Don't be ridiculous uses the candy. The name stays off. Breakin' a Brink's uses the truck. The spend stays off. Not a serial killer uses the cereal. The voice stays off. Not a serial killer has no partner line.

Ledger after this slice: reuse 334, keep 3, generate 12, symbol 159, review 600. The tsv is still 1,108 rows. The map has 378 keys. Xcode was not run.

The jail, the clip, the card, and the bag. Play on Words is 1,204. The last word is Moonwalk. Store, sections, briefs, and tests are the 03:26:43 save. The catalog map was still the 378 keys when these four were added. The clip, the card, and the bag are new files. The jail was already in the catalog.

| Heard word | File |
|---|---|
| in the can | noun-cell |
| like a carabiner | noun-carabiner |
| American Expresser | noun-card |
| Birkin is croc | noun-tote |

In the can uses the jail. The tin stays off. Like a carabiner uses the clip. The loop stays off. American Expresser uses the card. The collector stays off. Birkin is croc uses the bag. The shoe stays off. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 338, keep 3, generate 12, symbol 159, review 596. The tsv is still 1,108 rows. The map has 382 keys. Xcode was not run.

The drop-top, the sun, the juice, and the cloud. Play on Words is 1,204. The last word is Moonwalk. Store, sections, briefs, and tests are the 03:26:43 save. The catalog map was still the 382 keys when these four were added. The drop-top and the juice are new files. The sun and the cloud were already in the catalog.

| Heard word | File |
|---|---|
| it's a vert | noun-convertible |
| Sonnin' them | noun-sun |
| This ain't Minute Maid | noun-juice |
| head in the clouds | noun-cloud |

It's a vert uses the drop-top. The name stays off. Sonnin' them uses the sun. The son stays off. This ain't Minute Maid uses the juice. The minutes stay off. Head in the clouds uses the cloud. The daydream stays off. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 342, keep 3, generate 12, symbol 159, review 592. The tsv is still 1,108 rows. The map has 386 keys. Xcode was not run.

The goat, the bubble, the watch, and the house. Play on Words is 1,204. The last word is Moonwalk. Store, sections, briefs, and tests are the 03:26:43 save. The catalog map was still the 386 keys when these four were added. All four were already in the catalog.

| Heard word | File |
|---|---|
| not a GOAT | noun-goat |
| burst a bubble | noun-bubble |
| Richard prior | noun-watch |
| in the crib | noun-house |

Not a GOAT uses the goat. The title stays off. Burst a bubble uses the bubble. The guard stays off. Richard prior uses the watch. The comic stays off. In the crib uses the house. The bed stays off. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 346, keep 3, generate 12, symbol 159, review 588. The tsv is still 1,108 rows. The map has 390 keys. Xcode was not run.

The water, the horse, the block, and the pen. Play on Words is 1,207. The last word is feta. Store, sections, briefs, and tests are the 03:47:54 save. The catalog map was still the 390 keys when these four were added. The water is a new file. The horse, the block, and the pen were already in the catalog.

| Heard word | File |
|---|---|
| like the seven seas | noun-sea |
| a Clydesdale | noun-horse |
| in your ends | noun-city-block |
| I'm a rider | noun-ink |

Like the seven seas uses the water. The sale stays off. A Clydesdale uses the horse. The ad stays off. In your ends uses the block. The feet stay off. I'm a rider uses the pen. The loyalty stays off. 'Port, World Peace, and feta stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 350, keep 3, generate 12, symbol 159, review 584. The tsv is still 1,108 rows. The map has 394 keys. Xcode was not run.

The block, the rope, the grill, and the snow. Play on Words is 1,207. The last word is feta. Store, sections, briefs, and tests are the 03:47:54 save. The catalog map was still the 394 keys when these four were added. The snow is a new file. The block, the rope, and the grill were already in the catalog.

| Heard word | File |
|---|---|
| on some street shit | noun-city-block |
| teach you the ropes | noun-a-knot |
| not one fronted | noun-gold-grill |
| from the snow | noun-snow |

On some street shit uses the block. The dance stays off. Teach you the ropes uses the rope. The lesson stays off. Not one fronted uses the grill. The honesty stays off. From the snow uses the snow. The crew stays off. 'Port, World Peace, and feta stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 354, keep 3, generate 12, symbol 159, review 580. The tsv is still 1,108 rows. The map has 398 keys. Xcode was not run.

The hurdle, the truck, the meal, and the flight. Play on Words is 1,207. The last word is feta. Store and sections are the 04:01:11 save. Briefs and tests are the 03:47:54 save. The catalog map was still the 398 keys when these four were added. All four were already in the catalog.

| Heard word | File |
|---|---|
| clipped the hurdle | noun-hurdle |
| like the truck | noun-truck |
| thirty-piece | noun-fried-chicken |
| spreadin' my wings | noun-wings |

Clipped the hurdle uses the hurdle. The fall stays off. Like the truck uses the truck. The date stays off. Thirty-piece uses the meal. The player stays off. Spreadin' my wings uses the flight. The change stays off. 'Port, World Peace, and feta stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 358, keep 3, generate 12, symbol 159, review 576. The tsv is still 1,108 rows. The map has 402 keys. Xcode was not run.

The wolf, the metal, the hair, and the pen. Play on Words is 1,207. The last word is feta. Store and sections are the 04:01:11 save. Briefs and tests are the 03:47:54 save. The catalog map was still the 402 keys when these four were added. All four were already in the catalog.

| Heard word | File |
|---|---|
| this is Gustavo | noun-wolf |
| turn to chrome | noun-metal |
| show the waves | noun-curly-hair |
| Cartier pen | noun-ink |

This is Gustavo uses the wolf. The boss stays off. Turn to chrome uses the metal. The brand stays off. Show the waves uses the hair. The trend stays off. Cartier pen uses the pen. The flex stays off. 'Port, World Peace, and feta stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 362, keep 3, generate 12, symbol 159, review 572. The tsv is still 1,108 rows. The map has 406 keys. Xcode was not run.

The wedding, the house, the bay, and the fabric. Play on Words is 1,210. The last word is 'Luminati. Store, sections, briefs, and tests are the 04:29:29 save. The catalog map was still the 406 keys when these four were added. The fabric is a new file. The wedding, the house, and the bay were already in the catalog.

| Heard word | File |
|---|---|
| a bride | noun-a-bride |
| stay slitherin | noun-house |
| than Biscayne | noun-bay |
| when it's silk | noun-silk |

A bride uses the wedding. The gun stays off. Stay slitherin uses the house. The snake stays off. Than Biscayne uses the bay. The distance stays off. When it's silk uses the fabric. The soft stays off. 'Port, World Peace, feta, roger, Dove bars, and 'Luminati stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 366, keep 3, generate 12, symbol 159, review 568. The tsv is still 1,108 rows. The map has 410 keys. Xcode was not run.

The office and the car. Play on Words is 1,210. The last word is 'Luminati. Store, sections, briefs, and tests are the 04:29:29 save. The catalog map was still the 410 keys when these four were added. The office and the car were already in the catalog.

| Heard word | File |
|---|---|
| off us | noun-office |
| my vice | noun-office |
| one accord | noun-honda |
| drive her crazy | noun-honda |

Off us uses the office. The cubicles stay off. My vice uses the office. The election stays off. One accord uses the car. The agreement stays off. Drive her crazy uses the car. The crash stays off. 'Port, World Peace, feta, roger, Dove bars, and 'Luminati stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 370, keep 3, generate 12, symbol 159, review 564. The tsv is still 1,108 rows. The map has 414 keys. Xcode was not run.

The car, the outfit, and the house. Play on Words is 1,211. The last word is die 'lone. Store, sections, briefs, and tests are the 04:47:05 save. The catalog map was still the 414 keys when these four were added. The car, the outfit, and the house were already in the catalog.

| Heard word | File |
|---|---|
| sittin sideways | noun-honda |
| like we dmc | noun-honda |
| fit off the mannequin | noun-gown |
| empty crib in my empty crib | noun-house |

Sittin' sideways uses the car. The look stays off. Like we DMC uses the car. The group stays off. Fit off the mannequin uses the outfit. The flight stays off. Empty crib in my empty crib uses the house. The bed stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, and die 'lone stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 374, keep 3, generate 12, symbol 159, review 560. The tsv is still 1,108 rows. The map has 418 keys. Xcode was not run.

The cash, the pen, the bubble, and the gifts. Play on Words is 1,211. The last word is die 'lone. Store, sections, briefs, and tests are the 04:47:05 save. The catalog map was still the 418 keys when these four were added. The cash, the pen, the bubble, and the gifts were already in the catalog.

| Heard word | File |
|---|---|
| money trees | noun-cash |
| right my wrongs | noun-ink |
| grey in our conversation | noun-bubble |
| spoiled rotten | noun-presents |

Money trees uses the cash. The song stays off. Right my wrongs uses the pen. The past stays off. Grey in our conversation uses the bubble. The unclear stays off. Spoiled rotten uses the gifts. The attitude stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, and die 'lone stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 378, keep 3, generate 12, symbol 159, review 556. The tsv is still 1,108 rows. The map has 422 keys. Xcode was not run.

The cash again. Play on Words is 1,212. The last word is Forest. Store, sections, briefs, and tests are the 05:03:07 save. The catalog map was still the 422 keys when these four were added. The cash was already in the catalog.

| Heard word | File |
|---|---|
| big benjamins | noun-cash |
| money is young | noun-cash |
| frito lays | noun-cash |
| my cues | noun-cash |

Big Benjamins uses the cash. The player stays off. Money is young uses the cash. The label stays off. Frito Lays uses the cash. The chips stay off. My cues uses the cash. The hint stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, and Forest stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 382, keep 3, generate 12, symbol 159, review 552. The tsv is still 1,108 rows. The map has 426 keys. Xcode was not run.

The knot, the hotel, the cereal, and the card. Play on Words is 1,212. The last word is Forest. Store, sections, briefs, and tests are the 05:03:07 save. The catalog map was still the 426 keys when these four were added. The knot, the hotel, the cereal, and the card were already in the catalog.

| Heard word | File |
|---|---|
| a knot | noun-knot |
| last resort | noun-hotel |
| a cheerio | noun-cereal-bowl |
| show id | noun-card |

A knot uses the cash knot. The bump stays off. Last resort uses the hotel. The end stays off. A Cheerio uses the cereal. The number stays off. Show ID uses the card. The rapper stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, and Forest stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 386, keep 3, generate 12, symbol 159, review 548. The tsv is still 1,108 rows. The map has 430 keys. Xcode was not run.

The lion, the rope knot, and the prayer. Play on Words is 1,212. The last word is Forest. Store, sections, briefs, and tests are the 05:03:07 save. The catalog map was still the 430 keys when these four were added. The lion, the rope knot, and the prayer were already in the catalog.

| Heard word | File |
|---|---|
| loose with the lyin | noun-lion |
| lie to even tie | noun-a-knot |
| baruch yitadel | noun-prayer |
| down on her knees | noun-prayer |

Loose with the lyin' uses the lion. The lies stay off. Lie to even tie uses the rope knot. The lie stays off. Baruch Yitadel uses the prayer. The name stays off. Down on her knees uses the prayer. The floor stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, and Forest stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 387, keep 3, generate 12, symbol 159, review 547. The tsv is still 1,108 rows. The map has 434 keys. Xcode was not run.

The tomb, the pour, the crowd, and the rat. Play on Words is 1,216. The last word is vent. Store, sections, briefs, and tests are the 05:33:24 save. The catalog map was still the 434 keys when these four were added. The tomb, the pour, the crowd, and the rat were already in the catalog.

| Heard word | File |
|---|---|
| pyramid schemes | noun-pyramid |
| pint of tech | noun-pint |
| backpack underground | noun-crowd |
| listen to rats | noun-rats |

Pyramid schemes uses the tomb. The scam stays off. Pint of Tech uses the pour. The piece stays off. Backpack underground uses the crowd. The skip stays off. Listen to rats uses the rat. The boy stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, and vent stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 391, keep 3, generate 12, symbol 159, review 543. The tsv is still 1,108 rows. The map has 438 keys. Xcode was not run.

The candy, the wings, the ink, and the reel. Play on Words is 1,216. The last word is vent. Store, sections, briefs, and tests are the 05:33:24 save. The catalog map was still the 438 keys when these four were added. The candy, the wings, the ink, and the reel were already in the catalog.

| Heard word | File |
|---|---|
| like a lollipop | noun-lollipop |
| wings of an angel | noun-wings |
| ink with a major | noun-ink |
| jenny and swayze | noun-film |

Like a lollipop uses the candy. The name stays off. Wings of an angel uses the wings. The car stays off. Ink with a major uses the ink. The deal stays off. Jenny and Swayze uses the reel. The name stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, and vent stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 395, keep 3, generate 12, symbol 159, review 539. The tsv is still 1,108 rows. The map has 442 keys. Xcode was not run.

The rings, the record, the check, and the peak. Play on Words is 1,222. The last word is IMAX. Store, sections, briefs, and tests are the 05:55:35 save. The catalog map was still the 442 keys when these four were added. The rings, the record, the check, and the peak were already in the catalog.

| Heard word | File |
|---|---|
| bended knee | noun-wedding-bands |
| seein a ghost | noun-vinyl |
| checks owed | noun-payment |
| mountain of truth | noun-summit |

Bended knee uses the rings. The floor stays off. Seein' a ghost uses the record. The spirit stays off. Checks owed uses the check. The people stay off. Mountain of truth uses the peak. Kush stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, and IMAX stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 399, keep 3, generate 12, symbol 159, review 535. The tsv is still 1,108 rows. The map has 446 keys. Xcode was not run.

The check, the stack, and the records. Play on Words is 1,223. The last word is Casper. Store, sections, briefs, and tests are the 06:11:30 save. The catalog map was still the 446 keys when these four were added. The check, the stack, and the record were already in the catalog.

| Heard word | File |
|---|---|
| checks bounced | noun-payment |
| money tree | noun-cash |
| for all the dogs | noun-vinyl |
| eric b for president | noun-vinyl |

Checks bounced uses the check. The comeback stays off. Money tree uses the stack. The saying stays off. 23 stays off. For all the dogs uses the record. The bark stays off. Eric B For President uses the record. The line stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, and Casper stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 403, keep 3, generate 12, symbol 159, review 531. The tsv is still 1,108 rows. The map has 450 keys. Xcode was not run.

Four albums. Play on Words is 1,223. The last word is Casper. Store, sections, briefs, and tests are the 06:11:30 save. The catalog map was still the 450 keys when these four were added. The record was already in the catalog.

| Heard word | File |
|---|---|
| nothing was the same | noun-vinyl |
| thank me later | noun-vinyl |
| loverboy | noun-vinyl |
| movin like dogs | noun-vinyl |

Nothing was the same uses the record. The change stays off. Thank-me-later uses the record. The thanks stay off. Loverboy uses the record. The mood stays off. Movin' like dogs uses the record. The behavior stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, and Casper stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 407, keep 3, generate 12, symbol 159, review 527. The tsv is still 1,108 rows. The map has 454 keys. Xcode was not run.

Four more albums. Play on Words is 1,223. The last word is Casper. Store, sections, briefs, and tests are the 06:11:30 save. The catalog map was still the 454 keys when these four were added. The record was already in the catalog.

| Heard word | File |
|---|---|
| summers did i run | noun-vinyl |
| not a graduation | noun-vinyl |
| all the care | noun-vinyl |
| just nevermind | noun-vinyl |

Summers did I run uses the record. The years stay off. Ten stays off. Not a graduation uses the record. The cap stays off. All the care uses the record. The effort stays off. Just nevermind uses the record. Honestly stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, and Casper stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 411, keep 3, generate 12, symbol 159, review 523. The tsv is still 1,108 rows. The map has 458 keys. Xcode was not run.

Four stacks. Play on Words is 1,224. The last word is Hostess. Store, sections, briefs, and tests are the 06:31:35 save. The catalog map was still the 458 keys when these four were added. The stack was already in the catalog.

| Heard word | File |
|---|---|
| racks like serena | noun-cash |
| after doe | noun-cash |
| richie like lionel | noun-cash |
| all my millions | noun-cash |

Racks like Serena uses the stack. The player stays off. Rings stay off. After Doe uses the stack. The pitch stays off. Richie like Lionel uses the stack. The singer stays off. All my millions uses the stack. The saying stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, and Hostess stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 415, keep 3, generate 12, symbol 159, review 519. The tsv is still 1,108 rows. The map has 462 keys. Xcode was not run.

Four more stacks. Play on Words is 1,224. The last word is Hostess. Store, sections, briefs, and tests are the 06:31:35 save. The catalog map was still the 462 keys when these four were added. The stack was already in the catalog.

| Heard word | File |
|---|---|
| rest of my commas | noun-cash |
| more ms | noun-cash |
| balled | noun-cash |
| dumb rich | noun-cash |

Rest of my commas uses the stack. The pause stays off. More M's uses the stack. The letter stays off. Balled uses the stack. The bald stays off. Dumb rich uses the stack. The insult stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, and Hostess stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 419, keep 3, generate 12, symbol 159, review 515. The tsv is still 1,108 rows. The map has 466 keys. Xcode was not run.

Four more stacks. Play on Words is 1,226. The last word is playin' hockey. Store, sections, briefs, and tests are the 07:49:11 save. The catalog map was still the 466 keys when these four were added. The stack was already in the catalog.

| Heard word | File |
|---|---|
| turnin papers | noun-cash |
| degrees and papers | noun-cash |
| big tymer | noun-cash |
| now im cheese | noun-cash |

Turnin' papers uses the stack. The homework stays off. Degrees and papers uses the stack. The school stays off. Big Tymer uses the stack. The duo stays off. Now I'm cheese uses the stack. The mood stays off. The wedge stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, Hostess, Geico, and playin' hockey stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 423, keep 3, generate 12, symbol 159, review 511. The tsv is still 1,108 rows. The map has 470 keys. Xcode was not run.

The keyboard, the clock, the dice, and the kitchen. Play on Words is 1,226. The last word is playin' hockey. The four files were already in the catalog.

| Heard word | File |
|---|---|
| plot a return | noun-keyboard |
| signs of the times | noun-clock |
| playing trouble | noun-playing-trouble |
| everything is kosher | noun-kitchen |

Plot a return uses the keyboard. The comeback stays off. Shift stays off. Signs of the times uses the clock. The era stays off. Time stays off. Playing Trouble uses the dice. The trouble stays off. Everything is kosher uses the kitchen. The word stays off. Complain stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, Hostess, Geico, and playin' hockey stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 427, keep 3, generate 12, symbol 159, review 507. The tsv is still 1,108 rows. The map has 474 keys. Xcode was not run.

The scantron and the road. Play on Words is 1,226. The last word is playin' hockey. Both files were already in the catalog.

| Heard word | File |
|---|---|
| exams for the boy | noun-exam |
| g check | noun-exam |
| cross your mind | noun-road |
| run fades | noun-road |

Exams for the boy uses the scantron. The look stays off. Body stays off. G check uses the scantron. Played stays off. Cross your mind uses the road. The thought stays off. Escape stays off. Run fades uses the road. The fight stays off. Stick stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, Hostess, Geico, and playin' hockey stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 431, keep 3, generate 12, symbol 159, review 503. The tsv is still 1,108 rows. The map has 478 keys. Xcode was not run.

The rings, the station, the courthouse, and the chicken. Play on Words is 1,226. The last word is playin' hockey. The four files were already in the catalog.

| Heard word | File |
|---|---|
| we engaged | noun-wedding-bands |
| get on e | noun-gas-station |
| dodge sentences | noun-courthouse |
| gettin ate | noun-fried-chicken |

We engaged uses the rings. The feud stays off. Married stays off. Get on E uses the station. The end stays off. Ride stays off. Dodge sentences uses the courthouse. The grammar stays off. Discuss stays off. Gettin' ate uses the chicken. The eight stays off. Cake stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, Hostess, Geico, and playin' hockey stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 435, keep 3, generate 12, symbol 159, review 499. The tsv is still 1,108 rows. The map has 482 keys. Xcode was not run.

The courtroom and the two planes. Play on Words is 1,226. The last word is playin' hockey. The three files were already in the catalog.

| Heard word | File |
|---|---|
| fightin cases | noun-courtroom |
| duckin indictments | noun-courtroom |
| air miles | noun-airliner |
| like im howard hughes | noun-plane |

Fightin' cases uses the courtroom. Ali stays off. Duckin' indictments uses the courtroom. The duck stays off. Stand stays off. Air miles uses the airliner. The points stay off. Mall stays off. Like I'm Howard Hughes uses the jet. The fortune stays off. Sky stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, Hostess, Geico, and playin' hockey stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 439, keep 3, generate 12, symbol 159, review 495. The tsv is still 1,108 rows. The map has 486 keys. Xcode was not run.

The gifts, the basket, the phone, and the clock. Play on Words is 1,226. The last word is playin' hockey. The four files were already in the catalog.

| Heard word | File |
|---|---|
| outta hand | noun-presents |
| when the hook drop | noun-missed-shot |
| the batphone | noun-phone |
| am to the pm | noun-clock |

Outta hand uses the gifts. The excess stays off. Handouts stays off. When the hook drop uses the basket. The chorus stays off. Buckin stays off. The Batphone uses the phone. Work stays off. AM to the PM uses the clock. The song stays off. Day stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, Hostess, Geico, and playin' hockey stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 443, keep 3, generate 12, symbol 159, review 491. The tsv is still 1,108 rows. The map has 490 keys. Xcode was not run.

The cards and the holidays. Play on Words is 1,226. The last word is playin' hockey. Both files were already in the catalog.

| Heard word | File |
|---|---|
| poker face | noun-solitaire |
| fathers day | noun-calendar |
| ho ho hoes | noun-calendar |
| octobers own | noun-calendar |

Poker face uses the cards. The face stays off. Jokers stays off. Father's day uses the calendar. The rank stays off. Sonned stays off. Ho-ho-hoes uses the calendar. The laugh stays off. Nick stays off. October's Own uses the calendar. The title stays off. July stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, Hostess, Geico, and playin' hockey stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 447, keep 3, generate 12, symbol 159, review 487. The tsv is still 1,108 rows. The map has 494 keys. Xcode was not run.

The bee, the cigar, the shot, and the hand. Play on Words is 1,226. The last word is playin' hockey. The four files were already in the catalog.

| Heard word | File |
|---|---|
| net a bey | noun-bee |
| talkin in dutch | noun-dutch |
| need vaccine | noun-syringe |
| other hand | noun-hand |

Net a Bey uses the bee. Beyoncé stays off. Apiarist stays off. Talkin' in Dutch uses the cigar. The language stays off. The band stays blank. Smoke stays off. Need vaccine uses the shot. The video stays off. Viral stays off. Other hand uses the hand. The song stays off. The watch stays off. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, Hostess, Geico, and playin' hockey stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 451, keep 3, generate 12, symbol 159, review 483. The tsv is still 1,108 rows. The map has 498 keys. Xcode was not run.

The shirt, the case, the drink, and the record. Play on Words is 1,226. The last word is playin' hockey. The four files were already in the catalog.

| Heard word | File |
|---|---|
| like im hulk hogan | noun-t-shirt |
| get ricod | noun-courtroom |
| mc hammered | noun-whiskey |
| aint single | noun-vinyl |

Like I'm Hulk Hogan uses the shirt. The wrestler stays off. Rip stays off. Get RICO'd uses the courtroom. The song stays off. Suave stays off. MC hammered uses the glass. The dancer stays off. Club stays off. Ain't single uses the record. The status stays off. Dropped stays off. The gift stays unwired. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, Hostess, Geico, and playin' hockey stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 455, keep 3, generate 12, symbol 159, review 479. The tsv is still 1,108 rows. The map has 502 keys. Xcode was not run.

The glue, the rocket, the messages, and the record. Play on Words is 1,226. The last word is playin' hockey. The four files were already in the catalog.

| Heard word | File |
|---|---|
| glue stick | noun-glue-stick |
| rock it | noun-rock-it |
| texts | noun-texts |
| the gift | noun-vinyl |

Glue stick uses the glue. The gun stays off. Blicky stays off. Rock it uses the rocket. Scientific stays off. The Houston missile stays off. Texts uses the speech bubble. The guns stay off. The gift uses the record. The talent stays off. Curse stays off. Tecs stays off the map. The file is bullets. On the Goose stays unwired. The vodka file is a Smirnoff bottle. Black wood stays unwired. The interior file is a car cockpit. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, Hostess, Geico, and playin' hockey stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 458, keep 1, generate 12, symbol 159, review 478. The tsv is still 1,108 rows. The map has 506 keys. Xcode was not run.

The records, the mixtape, the message, and the two clocks. Play on Words is 1,226. This slice is 21 chips. The files were already in the catalog.

| Heard word | File |
|---|---|
| big pimpin | noun-vinyl |
| bury me alive | noun-vinyl |
| can we kick it | noun-vinyl |
| cheaper to keep her | noun-vinyl |
| for life | noun-vinyl |
| free time | noun-clock |
| get across | noun-texts |
| got options | noun-vinyl |
| in my grave | noun-vinyl |
| its ecstasy | noun-vinyl |
| other men are practice | noun-vinyl |
| return of the mack | noun-vinyl |
| screw the fuckin world | noun-vinyl |
| sleepin pattern | noun-clock |
| so far gone | noun-cassette |
| still the motto | noun-vinyl |
| the last hope | noun-vinyl |
| the takeover | noun-vinyl |
| what a time | noun-vinyl |
| workin on it | noun-vinyl |
| youre mine | noun-vinyl |

The songs use the blank record. The singer, the director, and the other half stay off. So far gone uses the cassette. The exit stays off. Outta stays off. Get across uses the speech bubble. Overseas stays off. Free time and sleepin' pattern use the clock. Costing stays off. Still stays off. Symbol glosses stay off the map: through the wire, no type, swae lee, freekin on you, like jill scott, envy me, and on the 33rd. Tecs stays off the map. The file is bullets. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, Hostess, Geico, and playin' hockey stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 479, keep 1, generate 12, symbol 159, review 457. The tsv is still 1,108 rows. The map has 527 keys. The last key is youre mine. Xcode was not run.

The reel, three records, and one clock. Play on Words is 1,226. This slice is 12 chips. The files were already in the catalog.

| Heard word | File |
|---|---|
| brainwashed | noun-film |
| devil in a tight dress | noun-film |
| home alone | noun-film |
| im gunproof | noun-film |
| major payne | noun-film |
| sixth sense | noun-film |
| space jam | noun-film |
| tradin places | noun-film |
| like vert | noun-vinyl |
| more chune | noun-vinyl |
| scary hours | noun-vinyl |
| time on your hands | noun-clock |

The movies use the blank film reel. The actor, the woman, the alien, and Jordan stay off. Pain stays off. The mind stays off. The glow stays off. The swap stays off. Momma stays off. Scary Hours, like Vert, and more chune use the blank record. Fear stays off. Afraid stays off. The push stays off. Edge stays off. Headtop stays off. Time on your hands uses the clock. Side stays off. Shows stay unwired. The catalog has no plain television file. Symbol glosses stay off the map: through the wire, no type, swae lee, freekin on you, like jill scott, envy me, and on the 33rd. Tecs stays off the map. The file is bullets. 'Port, World Peace, feta, roger, Dove bars, 'Luminati, die 'lone, Forest, sequin, deep end, Stefan, vent, wildin' out, Phillip, bird, man, Clifford, Ragu, IMAX, Casper, Hostess, Geico, and playin' hockey stay outside the ledger. Cash and Moonwalk stay outside the ledger.

Ledger after this slice: reuse 491, keep 1, generate 12, symbol 159, review 445. The tsv is still 1,108 rows. The map has 539 keys. The last key is youre mine. Xcode was not run.

The hymn, the Shakira song, and the two skylines. Play on Words is 1,226. This slice is 4 chips. The files were already in the catalog. The investigators finished after the reel slice.

| Heard word | File |
|---|---|
| amazin grace | noun-vinyl |
| like shakira | noun-vinyl |
| six summers | noun-skyline |
| you and the six | noun-skyline |

Amazin' grace uses the blank record. The grace period stays off. Delayed stays off. Like Shakira uses the blank record. The singer stays off. Whenever stays off. Six summers and you and the six use the Toronto skyline already on back in the six. The years stay off. Run stays off. The mother stays off. Raised stays off. Franklin's face stays off the hundred. Coins stay off. Cash stacks stay off. Little lamb stays in the open car group. The Myers mask stays off. Say my name and Poison stay outside the ledger. The song-and-crew, song-and-account, and song-and-off-season rows stay open. Symbol glosses stay off the map: through the wire, no type, swae lee, freekin on you, like jill scott, envy me, and on the 33rd. Tecs stays off the map. The file is bullets.

Ledger after this slice: reuse 495, keep 1, generate 12, symbol 159, review 441. The tsv is still 1,108 rows. The map has 543 keys. The last key is youre mine. Xcode was not run.

The one skyline. Play on Words is 1,226. This slice is 1 chip. The file was already in the catalog.

| Heard word | File |
|---|---|
| 06er | noun-skyline |

06er uses the Toronto skyline already on back in the six. The old player stays off. Year stays off. 6 a.m. stays a symbol. The military tank stays off the one tankin. Pootie Tang stays outside the ledger. It's not one stays open. The remaining review rows name two objects, a brand, a gun, a drug, a person, a show, a generic city, a coin, or a cash stack. Sixty percent of 1,226 is 736 keys. This pass stops at 544. Symbol glosses stay off the map: through the wire, no type, swae lee, freekin on you, like jill scott, envy me, and on the 33rd. Tecs stays off the map. The file is bullets.

Ledger after this slice: reuse 496, keep 1, generate 12, symbol 159, review 440. The tsv is still 1,108 rows. The map has 544 keys. The first key is 06er. The last key is youre mine. Xcode was not run.

The shoe, the armor, the hip, the balm, the ring, the pool, the drawing, the roof, two letter tiles, one letter pair, the bubble, the hair, the screwdriver, the puck, the red hair, the magazine, the lights, and the toilet. Play on Words is 1,226. This slice is 19 chips. One file was already in the catalog. Eighteen files are new.

| Heard word | File |
|---|---|
| allen iverson | noun-court-shoe |
| armor all | noun-armor |
| cadera | noun-hip |
| chaps stick | noun-lip-balm |
| close friends | noun-green-ring |
| deep end | noun-lap-pool |
| drawin conclusions | noun-sketch |
| drop addiction | noun-roof |
| eighty one | noun-letters-ha |
| less ls | noun-letter-l |
| lime green | noun-green-bubble |
| more tracks | noun-hair-tracks |
| phillip | noun-screwdriver |
| playin hockey | noun-hockey-puck |
| red weave | noun-red-weave |
| shit is complex | noun-magazine |
| stayed up | noun-string-lights |
| toodaloo | noun-toilet |
| whole lot of ms | noun-letter-m |

Allen Iverson uses the court shoe. The player stays off. Doubt stays off. Armor All uses the breastplate. The knight stays off. The bottle stays off. Cadera uses the hip. Hugo stays off. Chap's stick uses the balm. The movie stays off. Close friends uses the green ring. The word stays off. Deep end uses the lap pool already on the catalog. Water stays off. The pool wordmark stays off. Drawin' conclusions uses the sketch. The school stays off. Drop addiction uses the roof. The habit stays off. Eighty-one uses the letters H and A. The party stays off. Less L's uses the letter L. The losses stay off. Lime green uses the green bubble. The robot stays off. The yellow message bubble stays off. More tracks uses the black hair. The songs stay off. Phillip uses the screwdriver. The name stays off. The loose screw stays off. Playin' hockey uses the puck. Icy stays off. Red weave uses the red hair. The name stays off. Shit is complex uses the magazine. The situation stays off. The wordmark stays off. Stayed up uses the string lights. The rank stays off. Toodaloo uses the toilet. Goodbye stays off. Whole lot of M's uses the letter M. The size stays off. Deep end, Phillip, playin' hockey, and cadera stay outside the tsv. Symbol glosses stay off the map: through the wire, no type, swae lee, freekin on you, like jill scott, envy me, and on the 33rd. Tecs stays off the map. The file is bullets.

Ledger after this slice: reuse 423, keep 3, generate 24, symbol 159, review 499. The tsv is still 1,108 rows. The map has 563 keys. The first key is 06er. The last key is youre mine. Xcode was not run.

The shampoo, the lamp, the camera, the letters, the book, the window, the band, and the coal. Play on Words is 1,226. This slice is 8 chips. The files are new.

| Heard word | File |
|---|---|
| burn a bridge | noun-lamp |
| clique about to blow | noun-camera |
| fuelband | noun-wristband |
| grays anatomy | noun-book |
| papi champu | noun-shampoo |
| the atf | noun-letters-atf |
| the shade room | noun-window |
| you and cole | noun-coal |

Burn a bridge uses the lamp. The break stays off. Clique about to blow uses the camera. The crew stays off. FuelBand uses the plain band. The run stays off. The logo stays off. Gray's Anatomy uses the blank book. The body stays off. Papi champú uses the blank bottle. The name stays off. The ATF uses the letters. The crew stays off. The Shade Room uses the window. The page stays off. The blinds stay off. You and Cole uses the coal. The name stays off. January stays off. Nine generate rows stay open: 4 holes, raid us, no Polo, Fifty Dub, lion is loose, illuminated angel, with a V in the middle, do no verses, and like a ghost. Those are wordmarks, a team, a label, a person, and the denim surprise. Jake stays unwired. The file on that name is a whistle. We packers stays unwired. The file is the magazine. Black wood stays unwired. The file is a car cockpit. On the Goose stays unwired. The vodka file is a Smirnoff bottle. Symbol glosses stay off the map. Guns, drugs, coins, and cash stay off. Two-object rows stay open. William Wesley, Deadboy, Bronny James, Santa, and holiday eve stay unwired. No portrait was made.

Ledger after this slice: reuse 423, keep 3, generate 32, symbol 158, review 492. The tsv is still 1,108 rows. The map has 571 keys. The first key is 06er. The last key is youre mine. Xcode was not run.

## Two-item slice

A chip with two senses now gets both objects in one icon when both are plain things. A chip with one plain object and an abstract half uses the object that was already on file.

| Heard | File | What is in the picture |
| --- | --- | --- |
| all my children | noun-soap-copies | the soap and the copies |
| bone to pick | noun-bones | the bones |
| deep seated | noun-seats | the seats |
| doin backflips | noun-watch | the watch |
| every twenty four | noun-clock-jersey | the clock and the jersey |
| go ham | noun-pig | the hog |
| like its wagyu | noun-steak-beef | the steak and the beef |
| little lamb | noun-car-ring | the car and the ring |
| pulling strings | noun-acoustic | the guitar |
| seize the day | noun-owl | the owl |
| six lives | noun-cat-house | the cat and the house |
| solely fit | noun-court-shoe | the shoe |
| the billis | noun-goat | the goat |
| the spill | noun-hot-sauce | the sauce |
| thousand islands | noun-dressing-island | the dressing and the island |
| who sewed the buttons | noun-jeans | the jeans |

Dove bars uses noun-dial-soap. Hostess uses noun-pound-cake. Those two sit on the map and outside the ledger.

Ledger after this slice: reuse 430, keep 3, generate 40, symbol 158, review 477. The map has 589 keys. The tsv is still 1,108 rows. First key 06er. Last key youre mine. Xcode was not run.

## Object slice

A later pass wired twelve more chips. Two of them, feta and ragu, sit on the map and outside the ledger.

| Heard | File | What is in the picture |
| --- | --- | --- |
| cinco de mayo | noun-fifth | the bottle |
| flirting with the thirty | noun-jersey | the jersey |
| like bajan | noun-drink-island | the drink and the island |
| like gretzky | noun-ice-block | the ice |
| like no hair | noun-basketball | the ball |
| reality checks | noun-bill-books | the bill and the book |
| sandras rose | noun-roses | the roses |
| terry fox | noun-prosthetic | the leg |
| the world is yours | noun-film-vinyl | the film and the record |
| we chucky somethin | noun-doll | the doll |

Feta uses noun-feta. Ragu uses noun-pasta-sauce.

Ledger after this slice: reuse 433, keep 3, generate 47, symbol 158, review 467. The map has 601 keys. The tsv is still 1,108 rows. First key 06er. Last key youre mine. Xcode was not run.

## Scan slice

Four scans named the next plain objects. Twelve of those chips are in the ledger. Clifford sits on the map and outside the ledger.

| Heard | File | What is in the picture |
| --- | --- | --- |
| break down ya ds | noun-shot-glass | the drink |
| buy the tires | noun-plain-car | the car |
| eat each other | noun-dinner | the meal |
| feel like dido | noun-rain-window | the rain |
| hang me out to dry | noun-clothesline | the line |
| like a villain | noun-villa | the villa |
| like snoopy | noun-dog-roof | the dog and the roof |
| on the goose | noun-clear-vodka | the vodka |
| take a shot for me | noun-shot-glass | the drink |
| to the vet | noun-car-cat | the car and the cat |
| we whoppin | noun-burger | the burger |
| ws and ms | noun-restroom-doors | the doors |

Clifford uses noun-pit-dog.

Ledger after this slice: reuse 436, keep 3, generate 56, symbol 158, review 455. The map has 614 keys. The tsv is still 1,108 rows. First key 06er. Last key youre mine. Xcode was not run.

## Stretch slice

The stretch on 2026-10-07 added 42 chips, from 614 to 656. Six wires that photographed the heard word, a person, or a proxy were taken back off. A tornado file was removed for the same reason. The photo is the hidden object. A person, a logo, a gun, or a drug stays out of the frame.

| Heard | File | What is in the picture |
| --- | --- | --- |
| gotta punt | noun-football | the kick |
| incomplete | noun-football | the pass |
| ambidex | noun-hand | the hand |
| bag out | noun-plain-car | the car |
| skirt on a whip | noun-plain-car | the car |
| if I'm lyin' | noun-plane | the flight |
| like I'm Kobe | noun-chain-ring | the jewelry |
| like the Philly Eagles | noun-paint-can | the paint |
| Kill Bill | noun-sword | the sword |
| MAC lipstick | noun-lipstick | the lipstick |
| curve me | noun-baseball | the pitch |
| double play | noun-baseball | the baseball |
| like Dell and Windows | noun-laptop | the computer |
| Boise state | noun-blue-turf | the blue field |
| love's locked down | noun-cuffs | the cuffs |
| from the rear | noun-car-rear | the rear end |
| got the cakes | noun-cakes | the cakes |
| hit the jackpot | noun-slot | the machine |
| like a campus | noun-school-house | the school and the house |
| the six upside down | noun-numeral-six | the digit |
| X and O | noun-letters-xo | the letters |
| roller coaster | noun-coaster | the ride |
| runneth over | noun-spill-cup | the cup |
| vacuum seals | noun-vacuum | the cleaner |
| two black cars | noun-two-cars | the cars |
| trays in both hands | noun-tray | the tray |
| take sand | noun-sand | the sand |
| hammers come out | noun-gavel | the gavel |
| like silos | noun-silo | the silo |
| never fade | noun-clippers | the clippers |
| makin' light of my situation | noun-clapper | the clapper |
| like Yahtzee | noun-dice-cup | the dice |
| call the bluff | noun-playing-cards | the cards |
| no stick in the ride | noun-shifter | the shifter |
| gettin' secondhand | noun-used-clothes | the clothes |
| four gunshot | noun-four-records | the records |
| away from the bars | noun-jail-bars | the bars |
| like I'm J. Cole | noun-loose-hair | the hair |
| exfoliate | noun-soap | the soap |
| lotta class | noun-car-lot | the cars |
| king in Jamaica | noun-soda-can | the drink |
| not Nintendo | noun-console | the console |

Ledger after this slice: reuse 443, keep 3, generate 91, symbol 148, review 423. The map has 656 keys, 53.5% of 1,226. The tsv is still 1,108 rows. Wired spot-check is 522. First key 06er. Last key youre mine. Xcode was not run.

## Hundred

On 2026-10-07 the map moved from 656 keys to 670. That is 54.6% of 1,226, and 14 chips were completed. A later merge had reached 807 by adding guns, drugs, coins, cash, cities, teams, films, and brands. Those 137 keys were removed. First key 06er. Last key youre mine. Xcode was not run.

The 14 chips are QuikTrip, Mer-Curry, nose bleedin', switched place, paid by the letter, real italics, gettin' bold, the two-three, a buzz, we droppin', patty cake, forward to me, speed up the visa, and Like MacGyver.

Ledger after this pass: reuse 444, keep 3, generate 103, symbol 146, review 412. The tsv is still 1,108 rows. Wired spot-check is 536.

## Plain objects

On 2026-10-08 the map moved from 695 keys to 698. That is 56.9% of 1,226, and 3 chips were completed. First key 06er. Last key youre mine. Xcode was not run.

The 3 chips are like the one-two, when I'm 70, and like I'm gettin' graded.

not the Messi and top two stay off the map. Ledger after this pass: reuse 459, keep 3, generate 114, symbol 133, review 399. The tsv is still 1,108 rows. Wired spot-check is 564.

## Next phase

Guns, drugs, brand marks, people's faces, shows, generic cities, coins, cash, and sexual products stay unwired. The map is 698 of 1,226 (56.9%). The open briefs are mostly names, shows, and slogans. One hundred percent of 1,226 needs those classes. The board check waits.

## Wordplay wiring Batch 1 (reused images)

On 2026-10-09, 20 confirmed wordplay flips were wired into Play on Words under Samuel's rule (reusing existing assets across tabs):

| Heard word | Reused Asset | Other Tabs |
|---|---|---|
| hippopotamus | noun-hippo | (none) |
| Audemars | noun-ap | (none) |
| Nissan | noun-nissan | cars |
| Michael Phelps | noun-celeb-phelps | sports |
| Joe Biden | noun-celeb-biden | (none) |
| Philadelphia | noun-place-philly | (none) |
| DeMar DeRozan | noun-nba-derozan | (none) |
| ketchup | noun-ketchup | (none) |
| Rick Owens | noun-rick-owens | brands |
| heroin | noun-heroin | substances |
| gorilla | noun-gorilla | animals |
| Dennis Rodman | noun-celeb-rodman | (none) |
| Cadillac | noun-car-cadillac | cars |
| Minute Maid | noun-minute-maid | food |
| Harriet Tubman | noun-celeb-harriet | (none) |
| Rugrats | noun-rugrats | characters |
| wine | noun-wine | (none) |
| Bill Cosby | noun-celeb-cosby | (none) |
| No Cap | noun-phrase-no-cap | phrases |
| Chris Tucker | noun-celeb-chris-tucker | celebs |

58 chips from lines 1-75 queued for photo acquisition in `wordplay-image-queue.md`.

## Wordplay wiring Batch 2 (reused images)

On 2026-10-09, 20 confirmed wordplay flips were wired into Play on Words under Samuel's rule (reusing existing assets across tabs):

| Heard word | Reused Asset | Other Tabs |
|---|---|---|
| Marcus Mariota | noun-marcus-mariota | (none) |
| IHOP | noun-ihop | (shared) |
| Iraq | noun-iraq | (none) |
| James Harden | noun-celeb-harden | (none) |
| Maybach | noun-car-maybach | (shared) |
| Lil Wayne | noun-artist-wayne | (none) |
| Kai Cenat | noun-kai-cenat | (shared) |
| tints | noun-tints | (shared) |
| lion | noun-lion | (shared) |
| Kraft Dinner | noun-dinner | (none) |
| Drake | noun-artist-drake | (shared) |
| eye | noun-eye | (none) |
| Prada | noun-prada | (shared) |
| acorn | noun-acorn | (none) |
| Kurt Angle | noun-kurt-angle | (shared) |
| plane | noun-plane | (none) |
| cell | noun-cell | (none) |
| Lex Luger | noun-prod-lex-luger | (shared) |
| Takeoff | noun-celeb-takeoff | (shared) |
| Coi Leray | noun-celeb-coi-leray | (shared) |

52 chips from lines 76-177 queued for photo acquisition in .

## Wordplay wiring Batch 3 (acquired / generated images)

On 2026-10-09, 20 queued wordplay flips had 1024x1024 images acquired or created and were wired into Play on Words:

| Heard word | Asset Name | Subject / Kind | Other Tabs |
|---|---|---|---|
| Chevrolet | noun-car-chevrolet | Chevrolet car photo | (none) |
| Altima | noun-car-altima | Nissan Altima photo | (none) |
| Dodge Durango | noun-car-durango | Dodge Durango SUV photo | (none) |
| paralyzed | noun-phrase-paralyzed | Phrase wordmark | (none) |
| Hawaii | noun-place-hawaii | Hawaii landscape photo | (shared) |
| Xbox | noun-game-xbox | Xbox console photo | (shared) |
| respect the game | noun-phrase-respect-the-game | Phrase wordmark | (none) |
| Ryan Tannehill | noun-nfl-tannehill | NFL quarterback photo | (none) |
| wrist taker | noun-phrase-wrist-taker | Phrase wordmark | (none) |
| Toronto | noun-place-toronto | Toronto skyline photo | (none) |
| Manhattan | noun-place-manhattan | Manhattan skyline photo | (none) |
| moose sayin' | noun-phrase-moose-sayin | Phrase wordmark | (none) |
| diarrhea | noun-phrase-diarrhea | Phrase wordmark | (none) |
| Cuba Gooding | noun-celeb-cuba-gooding | Actor photo | (none) |
| Hemi | noun-car-hemi | V8 Hemi engine photo | (none) |
| Russell Wilson | noun-nfl-russell-wilson | NFL quarterback photo | (none) |
| Nazi | noun-phrase-nazi | Phrase wordmark | (none) |
| nuclear bomb | noun-nuclear-bomb | Mushroom cloud photo | (none) |
| mustard | noun-food-mustard | Mustard bottle photo | (shared) |
| Raptor | noun-car-raptor | Ford Raptor truck photo | (none) |

## Wordplay wiring Batch 5 (recheck FIXes & newly confirmed lines)

On 2026-10-09, updated  ->  per recheck FIX, wired #169  (replacing Jose Cuervo), and wired 21 newly confirmed flips:

| Heard word | Asset Name | Decision | Other Tabs |
|---|---|---|---|
| eyeball | noun-eye | updated_fix | (none) |
| Quavo | noun-artist-quavo | reused | (shared) |
| Shaquille O'Neal | noun-celeb-shaq | reused | (none) |
| Gucci Mane | noun-artist-gucci-mane | reused | (shared) |
| helicopter | noun-aviation-helicopter | reused | (shared) |
| steak | noun-steak | reused | (shared) |
| Robin | noun-comic-robin | created | (none) |
| Playboi | noun-artist-carti | reused | (none) |
| cents | noun-coins | reused | (none) |
| Depp | noun-celeb-johnny-depp | reused | (none) |
| Cole | noun-artist-j-cole | reused | (none) |
| Dolce & Gabbana | noun-brand-dolce | created | (none) |
| Jalen Hurts | noun-nfl-jalen-hurts | created | (none) |
| Bonnie | noun-celeb-bonnie | created | (none) |
| Clyde | noun-celeb-clyde | created | (none) |
| Illinois | noun-place-illinois | created | (none) |
| saxophone | noun-instrument-saxophone | created | (none) |
| television | noun-appliance-television | created | (none) |
| Tracy Morgan | noun-celeb-tracy-morgan | created | (none) |
| Duke Dennis | noun-streamer-duke-dennis | created | (none) |
| Fanum | noun-streamer-fanum | created | (none) |
| Gotham | noun-place-gotham | created | (none) |
| ICU | noun-place-icu | created | (none) |

## Wordplay wiring Batch 6 (acquired images & wordmarks)

On 2026-10-09, 20 queued wordplay flips had 1024x1024 photos/wordmarks acquired and were wired into Play on Words:

| Heard word | Asset Name | Decision | Other Tabs |
|---|---|---|---|
| mow it | noun-phrase-mow-it | created | (none) |
| with achoo | noun-phrase-with-achoo | created | (none) |
| Colgate | noun-brand-colgate | created | (none) |
| fell on knees | noun-phrase-fell-on-knees | created | (none) |
| kneecap | noun-phrase-kneecap | created | (none) |
| nails-on | noun-phrase-nails-on | created | (none) |
| Aleve | noun-brand-aleve | created | (none) |
| Emmett Till | noun-celeb-emmett-till | created | (none) |
| Auburn | noun-college-auburn | created | (none) |
| Crimson Tide | noun-college-crimson-tide | created | (none) |
| Cam Robinson | noun-nfl-cam-robinson | created | (none) |
| Zach LaVine | noun-nba-zach-lavine | created | (none) |
| telescope | noun-science-telescope | created | (none) |
| Mar-jealous | noun-phrase-mar-jealous | created | (none) |
| Japan | noun-place-japan | created | (none) |
| Orlando Magic | noun-nba-orlando-magic | created | (none) |
| I ate | noun-phrase-i-ate | created | (none) |
| Washington | noun-place-washington | created | (shared) |
| insole | noun-phrase-insole | created | (none) |
| elbow pasta | noun-food-elbow-pasta | created | (none) |
| linguine | noun-food-linguine | created | wired |
| Dial | noun-dial-soap | reused | wired |
| Tone soaps | noun-brand-tone-soap | created | wired |
| bye-sexual | noun-phrase-bye-sexual | created | wired |
| Ben Roethlisberger | noun-nfl-ben-roethlisberger | created | wired |
| Leonard Fournette | noun-nfl-leonard-fournette | created | wired |
| Tahoe | noun-car-tahoe | created | wired |
| deaf / hear | noun-phrase-deaf-hear | created | wired |
| see | noun-phrase-see | created | wired |
| Dublin | noun-place-dublin | created | wired |
| Ellen DeGeneres | noun-celeb-ellen-degeneres | created | wired |
| C-3PO | noun-char-c-3po | created | wired |
| Amy / AIM me | noun-tech-aim | created | wired |
| Texas | noun-place-texas | created | wired |
| VW Passat | noun-car-passat | created | wired |
| Russian | noun-place-russia | created | wired |
| Mount Everest | noun-place-mount-everest | created | wired |
| I'm Baka | noun-serge-ibaka | reused | wired |
| Jan 1st | noun-phrase-jan-1st | created | wired |
| blasphemy | noun-phrase-blasphemy | created | wired |
