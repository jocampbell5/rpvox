-- RPVox -- Mage-Animated class pack
--
-- Voice: song-lyric puns. Every line bends a well-known rock, hip hop or
-- R&B hook into the spell being cast. Kept in the addon rather than in saved
-- variables so it survives reinstalls and can live in version control.

RPVox_CLASSES = RPVox_CLASSES or {}

RPVox_CLASSES.MAGE_ANIMATED = {
    name = "Mage-Animated",
    class = "MAGE",
    -- No spells table. This pack used to declare 75 abilities, which meant 75
    -- triggers all saying "I pressed a button" -- the same moment written out
    -- once per spell. The five combat moments below cover every one of them,
    -- and keep covering them when Blizzard adds another. A spell can still be
    -- given its own lines from the settings window when it earns them.
    lines = {

        ["MELEE"] = {
            "Hit me with your best shot, %t. Then I hit back.",
            "Beat it. No. I am beating it.",
            "Another one bites the staff, %t.",
            "Let's get physical. Against my better judgement.",
            "I fought the law and the law was a stick.",
            "Smack that, %t. Reluctantly.",
            "{arcane}*CAN'T TOUCH THIS*{/}. I am touching it. That is the problem.",
            "<crit> {arcane}#SMACK THAT#{/}. Ooh, %t. Even I felt that one.",
            "<crit> Another one bites the staff. That one bit properly.",
            "<miss> Oops, I did it again. I missed.",
            "<miss> I fought the law and the law _ducked_, %t.",
        },

        -- The four moments that replaced the spell list. Deliberately written
        -- for no particular school: one set has to cover Frostbolt, Fireball
        -- and Arcane Blast alike now, so the puns lean on the character rather
        -- than on the element. What varies is the outcome, not the spell.
        ["COMBAT:SPELL:HIT"] = {
            "{arcane}*CAN'T TOUCH THIS*{/}, %t.",
            "Hit me baby one more time? No. My turn.",
            "Every little thing I do lands.",
            "You're the one that I want. To hit, %t.",
            "Sweet dreams are made of this.",
            "Under pressure, %t. Yours, not mine.",
            "That's the way, uh huh, I like it.",
            "Can't stop, won't stop, %t.",
            "Beat it. Just beat it, %t.",
            "Another one for the collection.",
            "Oh, %t. What a feeling.",
            "Straight up, no chaser.",
        },

        ["COMBAT:SPELL:CRIT"] = {
            "{arcane}#BOOOOM#{/}. Shake the room, %t.",
            "That one hit different.",
            "Ooh, that is the good stuff. Say my name, %t.",
            "Somebody call somebody. That was a big one.",
            "Hit me with your best -- no. That one was mine, %t.",
            "{fire}#DYNAMITE#{/}. I threw my hands up.",
            "Bang bang, %t.",
            "That is what you get. Ask anyone.",
            "Simply the best. That one, anyway.",
            "Woo. Say it again, %t.",
        },

        ["COMBAT:SPELL:MISS"] = {
            "Oops, I did it again, %t.",
            "Missed you. Literally missed you.",
            "Whoops. That one went straight to voicemail.",
            "You shook it off, %t. Nobody shakes that off.",
            "Ain't no stopping them -- apparently there is.",
            "Can't touch this. Neither can I, it turns out.",
            "Should have been a wizard. I am. That is the tragedy, %t.",
            "Well. That was embarrassing.",
            "Every little thing I do -- not that one, %t.",
            "Close. Close does not count.",
            "Sorry. Not sorry. Actually, sorry, %t.",
        },

        ["COMBAT:HEAL"] = {
            "I will always love you. Now get up, %t.",
            "Lean on me.",
            "Bridge over troubled water. That would be me.",
            "Ain't no mountain high enough. Stand up, %t.",
            "Everybody hurts. Sometimes I fix it.",
            "You're welcome, %t.",
            "<crit> That is the good stuff. All of it at once.",
        },

        ["COMBAT:BUFF"] = {
            "You've got a friend in me, %t. Briefly.",
            "Sharing the wealth. Intellect division.",
            "Simply the best. Now marginally better, %t.",
            "Under my umbrella.",
            "Stronger. You're welcome, %t.",
            "Ain't no mountain high enough now.",
            "Lean on me. Academically.",
            "That's what friends are for, %t.",
        },

        ["COMBAT:CC"] = {
            "Who let the sheep out, %t.",
            "Baa baa black sheep.",
            "Mary had a little lamb. Now I do, %t.",
            "{arcane}*STOP*{/}. In the name of the arcane.",
            "Can't touch this. Can't move either, %t.",
            "You had a bad day. And now you have wool.",
            "Sit down. Be humble, %t.",
            "<miss> Baa baa -- no. %t said no.",
            "<miss> Ain't no stopping them now. Unfortunately.",
            "<miss> Somebody said no.",
        },

        ["REACT:LOWHEALTH"] = {
            "I get knocked down, %t. Then I get up again.",
            "Still standing, %t. Ask me again in a second.",
            "Livin' on a prayer and about four health, %t.",
            "Ain't no sunshine down here, %t.",
            "Hurts so good, %t. No it does not.",
            "Bleeding love, %t. Mostly bleeding.",
            "I will survive, %t. Probably.",
            "Under pressure, %t.",
            "Somebody save me, %t. Anybody.",
            "Stayin' alive, %t. Barely.",
            "Bridge over troubled water would be lovely right now, %t.",
            "Hit me one more time and find out, %t.",
            "Ain't no mountain high enough to keep me from that healer, %t.",
            "Tubthumping over here, %t.",
            "Every breath I take is getting shorter, %t.",
            "Bridge over troubled water would be lovely right now.",
            "Ain't no mountain high enough to keep me from that healer.",
        },

        ["REACT:DEATH"] = {
            "Another one bites the dust. This one was me.",
            "Knockin' on heaven's door. Nobody is answering.",
            "Hello darkness, my old friend.",
            "Comfortably numb. Very numb.",
            "{fire}#HIGHWAY TO HELL#{/}. Express lane.",
            "Dust in the wind. All I am.",
            "Goodbye yellow brick road.",
            "Don't fear the reaper. He is remarkably punctual.",
            "Fade to black.",
            "It was a good day. Right up until it was not.",
            "The show must go on. Without me.",
            "See you again. Probably at the graveyard.",
            "Free fallin'. Straight down.",
            "Tears in heaven. Mostly mine.",
            "That's all she wrote.",
        },

        ["REACT:RESURRECT"] = {
            "Back in black.",
            "Return of the mack.",
            "I will always love you, whoever cast that.",
            "Back in the saddle.",
            "Reunited and it feels so good.",
            "Started from the bottom. Literally the floor.",
            "Ain't no stopping me now.",
            "Alive. Staying that way this time.",
            "Thank you. Next.",
            "Livin' on a prayer. Turns out it worked.",
            "I get knocked down. See previous.",
        },

        ["REACT:KILLINGBLOW"] = {
            "Another one bites the dust, %t.",
            "Bye bye bye, %t.",
            "Hit the road, %t. And don't you come back.",
            "It was a good day, %t. For me.",
            "Sorry. Not sorry, %t.",
            "Ashes to ashes, %t.",
            "Killing me softly. That was not soft, %t.",
            "That's the way, uh huh, I like it, %t.",
            "Bad boys, %t. Whatcha gonna do.",
            "Beat it, %t. Too late.",
            "Dust in the wind, %t.",
            "~Ice~ cold, %t.",
            "Who's next, %t?",
            "Down goes another one, %t.",
            "{arcane}*SAY MY NAME*{/}, %t. You cannot. That is the issue.",
            "Hit the road. And don't you come back.",
            "{arcane}*SAY MY NAME*{/}. You cannot. That is the issue.",
        },

        ["REACT:COMBATSTART"] = {
            "It's the final countdown, %t.",
            "Welcome to the jungle, %t.",
            "Eye of the tiger, %t.",
            "Enter sandman, %t.",
            "Thunderstruck, %t.",
            "Lose yourself, %t. I intend to.",
            "Bring the noise, %t.",
            "You picked the wrong mage, %t.",
            "Let's get ready to rumble, %t.",
            "Here we go again, %t.",
            "Cry me a river afterwards, %t.",
            "It's about to go down, %t.",
            "Started at the bottom. So will you, %t.",
            "Let's get ready to rumble.",
            "Started at the bottom. So will you.",
        },

        ["REACT:COMBATEND"] = {
            "We are the champions.",
            "Celebrate good times. Come on.",
            "Another one down.",
            "Take it easy.",
            "Free at last.",
            "Good times. Bad times. Mostly good.",
            "Let's stay together. Nobody die again.",
            "Cool it now.",
            "The party's over.",
            "Walk it off.",
            "That's the way it is.",
        },

        ["REACT:INTERRUPTED"] = {
            "You interrupted my song, %t.",
            "*STOP*. In the name of everything, %t.",
            "Killing me softly with that kick, %t.",
            "Rude, %t.",
            "Say it ain't so, %t.",
            "Don't *STOP* the music, %t. Too late.",
            "You shook me, %t. Badly.",
            "Cry me a river, %t. I am casting it again.",
            "Every cast you take, %t. Every one you break.",
            "That was mid-verse, %t.",
            "Ain't that a shame, %t.",
            "Killing me softly with that kick.",
            "Every cast you take. Every one you break.",
        },

        ["REACT:LEVELUP"] = {
            "Movin' on up.",
            "Stronger. Every single time.",
            "Higher and higher.",
            "Level up.",
            "The only way is up.",
            "Started at the bottom. Making progress.",
            "Ain't no stopping me now.",
            "Bigger. Better. More expensive robes.",
            "I get up. And I keep going.",
        },

        ["REACT:FALLING"] = {
            "Free fallin'.",
            "Gravity is working against me.",
            "Jump. Go ahead and jump. Regret it.",
            "Down, down, down.",
            "Rocket man. Bad landing.",
            "I'm falling and I cannot get up.",
            "_Slow_ Fall would have been clever about four seconds ago.",
            "Bad to the bone. And to the ankles.",
            "Catch me now or explain it later.",
        },

        ["REACT:DROWNING"] = {
            "Under the sea. Not by choice.",
            "I went chasing waterfalls. Bad idea.",
            "Rolling in the deep. Far too deep.",
            "Bridge over troubled water. Any bridge.",
            "Smoke on the water. Under it, actually.",
            "Air. Just a little bit of air.",
            "Swim. Just swim.",
            "Nobody's watching me drown out here.",
            "I am not a fish. Confirmed.",
        },

        ["REACT:DURABILITY"] = {
            "Sharp dressed man. Formerly.",
            "Torn.",
            "Rags to rags.",
            "Material girl needs a repair vendor.",
            "Every seam, every stitch, coming apart.",
            "Smells like teen spirit and burnt cloth.",
            "Dressed for considerably less.",
            "Shabby. Not chic.",
            "Wear and tear. Mostly tear.",
        },

        ["IDLE:EAT"] = {
            "Eat it. Just eat it.",
            "Hungry like the wolf.",
            "Cheeseburger in paradise.",
            "Just a little bit. Just a little bit.",
            "Conjured. Glorious. Free.",
            "Feed me.",
        },

        ["IDLE:DRINK"] = {
            "Sip sip. Pass it along.",
            "Tequila. No. Water.",
            "Red red wine? Blue blue water.",
            "Cheers to that.",
            "One more sip and I am back.",
            "Drinking alone again.",
        },

        ["IDLE:HEALTHSTONE"] = {
            "I want a new drug. This one works.",
            "Sweet emotion. Sweet health.",
            "Feeling good.",
            "Better now.",
            "That's the good stuff.",
        },

        ["IDLE:MANAPOTION"] = {
            "Blue. Da ba dee.",
            "Down the hatch. Blue magic.",
            "Purple rain? Blue potion.",
            "Mana on demand.",
            "One blue, coming up.",
        },

        ["IDLE:FISHING"] = {
            "Nothing but a good time.",
            "Sittin' on the dock of the bay.",
            "Under the sea. Voluntarily this time.",
            "Wasting away again.",
            "Patience. Sweet, sweet patience.",
            "Nothing biting. Still beats questing.",
        },

        ["IDLE:MINING"] = {
            "I've been working on the mine.",
            "Take this pick and shove it.",
            "Rock and roll. Mostly rock.",
            "Digging in the dirt.",
            "Diamonds in the rough. Mostly rough.",
        },

        ["IDLE:HERBALISM"] = {
            "Flower power.",
            "Every rose has its thorn.",
            "Bed of roses. Taking it apart.",
            "Kiss from a rose.",
            "Build me up, buttercup.",
            "Wild thing. Wild flowers.",
        },

        ["IDLE:SKINNING"] = {
            "Leather and lace. Mostly leather.",
            "Bad to the bone. And the hide.",
            "Working for the weekend. And the pelt.",
            "Sorry, wolf.",
            "Comfortably numb. Hopefully it was.",
        },

        ["IDLE:MOUNT"] = {
            "Born to be wild.",
            "Life is a highway.",
            "Ride on.",
            "Wild horses. One, technically.",
            "Fast car.",
            "Hit the road.",
            "Take it easy. But faster.",
        },

        ["IDLE:QUESTACCEPT"] = {
            "I'm on my way.",
            "Say the word. It's done.",
            "Ain't no mountain high enough.",
            "I'll do it my way.",
            "Sign me up.",
            "Ain't too proud to beg. But you asked nicely.",
            "Whatever you want. Whatever you need.",
        },

        ["IDLE:QUEST"] = {
            "Job done. Pay the man.",
            "We are the champions.",
            "Done and dusted.",
            "Time to get paid. Bills, bills, bills.",
            "That's all, folks. And the gold, please.",
            "Mission accomplished.",
        },

        ["IDLE:DISCOVERY"] = {
            "I still haven't found what I'm looking for. But this is nice.",
            "What a wonderful view.",
            "Wide open spaces.",
            "On the road again.",
            "New place, who this.",
            "Ain't no place like a place you have never been.",
            "Somewhere over the hill.",
        },

        ["IDLE:CRAFT:Alchemy"] = {
            "Shaken. Not stirred.",
            "Witchy woman with a cauldron.",
            "Bubble, bubble. Mostly trouble.",
            "Mixing it up.",
        },

        ["IDLE:CRAFT:Blacksmithing"] = {
            "*STOP*. Hammer time.",
            "Bang a gong.",
            "We built this city on hammering.",
            "Beat it. Into shape.",
        },

        ["IDLE:CRAFT:Cooking"] = {
            "It's getting hot in here.",
            "Too hot in the kitchen.",
            "Cooking up something good.",
            "{fire}#BURN, BABY, BURN#{/}. On purpose this time.",
        },

        ["IDLE:CRAFT:Enchanting"] = {
            "Abracadabra.",
            "You put a spell on it. No. I did.",
            "Under my spell.",
            "Sprinkle a little magic dust.",
        },

        ["IDLE:CRAFT:Engineering"] = {
            "She blinded me with science.",
            "It might explode. It usually explodes.",
            "Blame it on the boogie. Or the #BLAST# cap.",
            "Bang. That was supposed to happen.",
        },

        ["IDLE:CRAFT:First Aid"] = {
            "Doctor, doctor, give me the news.",
            "Fix you.",
            "Wrap it up.",
            "Bandage on. Walk it off.",
        },

        ["IDLE:CRAFT:Jewelcrafting"] = {
            "Diamonds are forever.",
            "^Shine^ bright.",
            "~Ice~ on ice.",
            "Cut it. Polish it. Sell it.",
        },

        ["IDLE:CRAFT:Leatherworking"] = {
            "Leather and lace.",
            "Working the hide. Working the weekend.",
            "Born to be wild. Also to be a belt.",
            "Tough as leather.",
        },

        ["IDLE:CRAFT:Tailoring"] = {
            "Sharp dressed man.",
            "Material girl. Material mage.",
            "Stitched up.",
            "Every thread in its place.",
        },

        ["IDLE:CRAFT:Smelting"] = {
            "Feel the heat.",
            "I melt with you.",
            "Burning down the ore.",
            "Turn up the furnace.",
        },

    },
}
