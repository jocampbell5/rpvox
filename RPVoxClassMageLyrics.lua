-- RPVox -- Mage-Lyrics class pack
--
-- Voice: song-lyric puns. Every line bends a well-known rock, hip hop or
-- R&B hook into the spell being cast. Kept in the addon rather than in saved
-- variables so it survives reinstalls and can live in version control.

RPVox_CLASSES = RPVox_CLASSES or {}

RPVox_CLASSES.MAGE_LYRICS = {
    name = "Mage-Lyrics",
    class = "MAGE",
    spells = {
        { spell = "Frostbolt",                 icon = 135846,                                                  chance = 10 },
        { spell = "Ice Lance",                 icon = "Interface\\Icons\\Spell_Frost_FrostBlast",              chance = 10 },
        { spell = "Frost Nova",                icon = 135848,                                                  chance = 10 },
        { spell = "Blizzard",                  icon = "Interface\\Icons\\Spell_Frost_IceStorm",                chance = 10 },
        { spell = "Cone of Cold",              icon = "Interface\\Icons\\Spell_Frost_Glacier",                 chance = 10 },
        { spell = "Ice Barrier",               icon = "Interface\\Icons\\Spell_Ice_Lament",                    chance = 10 },
        { spell = "Ice Block",                 icon = "Interface\\Icons\\Spell_Frost_Frost",                   chance = 10 },
        { spell = "Icy Veins",                 icon = "Interface\\Icons\\Spell_Frost_ColdHearted",             chance = 10 },
        { spell = "Cold Snap",                 icon = "Interface\\Icons\\Spell_Frost_WizardMark",              chance = 10 },
        { spell = "Summon Water Elemental",    icon = "Interface\\Icons\\Spell_Frost_SummonWaterElemental",    chance = 10 },
        { spell = "Frost Ward",                icon = "Interface\\Icons\\Spell_Frost_FrostWard",               chance = 10 },
        { spell = "Frost Armor",               icon = 135843,                                                  chance = 10 },
        { spell = "Ice Armor",                 icon = "Interface\\Icons\\Spell_Frost_FrostArmor",              chance = 10 },
        { spell = "Fireball",                  icon = 135812,                                                  chance = 10 },
        { spell = "Fire Blast",                icon = 135807,                                                  chance = 10 },
        { spell = "Scorch",                    icon = "Interface\\Icons\\Spell_Fire_SoulBurn",                 chance = 10 },
        { spell = "Flamestrike",               icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",             chance = 10 },
        { spell = "Pyroblast",                 icon = "Interface\\Icons\\Spell_Fire_Fireball02",               chance = 10 },
        { spell = "Blast Wave",                icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",             chance = 10 },
        { spell = "Dragon's Breath",           icon = "Interface\\Icons\\INV_Misc_Head_Dragon_01",             chance = 10 },
        { spell = "Combustion",                icon = "Interface\\Icons\\Spell_Fire_SealOfFire",               chance = 10 },
        { spell = "Fire Ward",                 icon = "Interface\\Icons\\Spell_Fire_FireArmor",                chance = 10 },
        { spell = "Molten Armor",              icon = "Interface\\Icons\\Ability_Mage_MoltenArmor",            chance = 10 },
        { spell = "Arcane Missiles",           icon = 136096,                                                  chance = 10 },
        { spell = "Arcane Blast",              icon = "Interface\\Icons\\Spell_Arcane_Blast",                  chance = 10 },
        { spell = "Arcane Explosion",          icon = "Interface\\Icons\\Spell_Nature_WispSplode",             chance = 10 },
        { spell = "Counterspell",              icon = "Interface\\Icons\\Spell_Frost_IceShock",                chance = 10 },
        { spell = "Polymorph",                 icon = 136071,                                                  chance = 10 },
        { spell = "Blink",                     icon = "Interface\\Icons\\Spell_Arcane_Blink",                  chance = 10 },
        { spell = "Slow",                      icon = "Interface\\Icons\\Spell_Nature_Slow",                   chance = 10 },
        { spell = "Spellsteal",                icon = "Interface\\Icons\\Spell_Arcane_Arcane02",               chance = 10 },
        { spell = "Remove Lesser Curse",       icon = "Interface\\Icons\\Spell_Nature_RemoveCurse",            chance = 10 },
        { spell = "Mana Shield",               icon = "Interface\\Icons\\Spell_Shadow_DetectLesserInvisibility", chance = 10 },
        { spell = "Evocation",                 icon = "Interface\\Icons\\Spell_Nature_Purge",                  chance = 10 },
        { spell = "Arcane Power",              icon = "Interface\\Icons\\Spell_Nature_Lightning",              chance = 10 },
        { spell = "Presence of Mind",          icon = "Interface\\Icons\\Spell_Nature_EnchantArmor",           chance = 10 },
        { spell = "Invisibility",              icon = "Interface\\Icons\\Ability_Mage_Invisibility",           chance = 10 },
        { spell = "Arcane Intellect",          icon = 135932,                                                  chance = 10 },
        { spell = "Arcane Brilliance",         icon = "Interface\\Icons\\Spell_Holy_ArcaneIntellect",          chance = 10 },
        { spell = "Amplify Magic",             icon = "Interface\\Icons\\Spell_Holy_FlashHeal",                chance = 10 },
        { spell = "Dampen Magic",              icon = 136006,                                                  chance = 10 },
        { spell = "Mage Armor",                icon = "Interface\\Icons\\Spell_MageArmor",                     chance = 10 },
        { spell = "Slow Fall",                 icon = 135992,                                                  chance = 10 },
        { spell = "Detect Magic",              icon = "Interface\\Icons\\Spell_Holy_Dizzy",                    chance = 10 },
        { spell = "Conjure Water",             icon = 132794,                                                  chance = 10 },
        { spell = "Conjure Food",              icon = 133951,                                                  chance = 10 },
        { spell = "Conjure Mana Agate",        icon = "Interface\\Icons\\INV_Misc_Gem_Opal_01",                chance = 10 },
        { spell = "Conjure Mana Jade",         icon = "Interface\\Icons\\INV_Misc_Gem_Emerald_01",             chance = 10 },
        { spell = "Conjure Mana Citrine",      icon = "Interface\\Icons\\INV_Misc_Gem_Opal_02",                chance = 10 },
        { spell = "Conjure Mana Ruby",         icon = "Interface\\Icons\\INV_Misc_Gem_Ruby_01",                chance = 10 },
        { spell = "Conjure Mana Emerald",      icon = "Interface\\Icons\\INV_Misc_Gem_Emerald_02",             chance = 10 },
        { spell = "Ritual of Refreshment",     icon = "Interface\\Icons\\Spell_Arcane_MassDispel",             chance = 10 },
        { spell = "Shoot",                     icon = 135139,                                                  chance = 10 },
        { spell = "Teleport: Stormwind",       icon = "Interface\\Icons\\Spell_Arcane_TeleportStormWind",      chance = 10 },
        { spell = "Teleport: Ironforge",       icon = "Interface\\Icons\\Spell_Arcane_TeleportIronForge",      chance = 10 },
        { spell = "Teleport: Darnassus",       icon = "Interface\\Icons\\Spell_Arcane_TeleportDarnassus",      chance = 10 },
        { spell = "Teleport: Exodar",          icon = "Interface\\Icons\\Spell_Arcane_TeleportExodar",         chance = 10 },
        { spell = "Teleport: Theramore",       icon = "Interface\\Icons\\Spell_Arcane_TeleportTheramore",      chance = 10 },
        { spell = "Teleport: Orgrimmar",       icon = "Interface\\Icons\\Spell_Arcane_TeleportOrgrimmar",      chance = 10 },
        { spell = "Teleport: Undercity",       icon = "Interface\\Icons\\Spell_Arcane_TeleportUnderCity",      chance = 10 },
        { spell = "Teleport: Thunder Bluff",   icon = "Interface\\Icons\\Spell_Arcane_TeleportThunderBluff",   chance = 10 },
        { spell = "Teleport: Silvermoon",      icon = "Interface\\Icons\\Spell_Arcane_TeleportSilvermoon",     chance = 10 },
        { spell = "Teleport: Stonard",         icon = "Interface\\Icons\\Spell_Arcane_TeleportStonard",        chance = 10 },
        { spell = "Teleport: Shattrath",       icon = "Interface\\Icons\\Spell_Arcane_TeleportShattrath",      chance = 10 },
        { spell = "Portal: Stormwind",         icon = "Interface\\Icons\\Spell_Arcane_PortalStormWind",        chance = 10 },
        { spell = "Portal: Ironforge",         icon = "Interface\\Icons\\Spell_Arcane_PortalIronForge",        chance = 10 },
        { spell = "Portal: Darnassus",         icon = "Interface\\Icons\\Spell_Arcane_PortalDarnassus",        chance = 10 },
        { spell = "Portal: Exodar",            icon = "Interface\\Icons\\Spell_Arcane_PortalExodar",           chance = 10 },
        { spell = "Portal: Theramore",         icon = "Interface\\Icons\\Spell_Arcane_PortalTheramore",        chance = 10 },
        { spell = "Portal: Orgrimmar",         icon = "Interface\\Icons\\Spell_Arcane_PortalOrgrimmar",        chance = 10 },
        { spell = "Portal: Undercity",         icon = "Interface\\Icons\\Spell_Arcane_PortalUnderCity",        chance = 10 },
        { spell = "Portal: Thunder Bluff",     icon = "Interface\\Icons\\Spell_Arcane_PortalThunderBluff",     chance = 10 },
        { spell = "Portal: Silvermoon",        icon = "Interface\\Icons\\Spell_Arcane_PortalSilvermoon",       chance = 10 },
        { spell = "Portal: Stonard",           icon = "Interface\\Icons\\Spell_Arcane_PortalStonard",          chance = 10 },
        { spell = "Portal: Shattrath",         icon = "Interface\\Icons\\Spell_Arcane_PortalShattrath",        chance = 10 },
    },
    lines = {

        ["MELEE"] = {
            "Hit me with your best shot, %t. Then I hit back.",
            "Beat it. No. I am beating it, %t.",
            "Another one bites the staff, %t.",
            "Let's get physical, %t. Against my better judgement.",
            "I fought the law and the law was a stick, %t.",
            "Smack that, %t. Reluctantly.",
            "Can't touch this. I am touching it. That is the problem, %t.",
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
        },

        ["REACT:DEATH"] = {
            "Another one bites the dust. This one was me.",
            "Knockin' on heaven's door. Nobody is answering.",
            "Hello darkness, my old friend.",
            "Comfortably numb. Very numb.",
            "Highway to hell. Express lane.",
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
            "Ice cold, %t.",
            "Who's next, %t?",
            "Down goes another one, %t.",
            "Say my name, %t. You cannot. That is the issue.",
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
            "Stop. In the name of everything, %t.",
            "Killing me softly with that kick, %t.",
            "Rude, %t.",
            "Say it ain't so, %t.",
            "Don't stop the music, %t. Too late.",
            "You shook me, %t. Badly.",
            "Cry me a river, %t. I am casting it again.",
            "Every cast you take, %t. Every one you break.",
            "That was mid-verse, %t.",
            "Ain't that a shame, %t.",
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
            "Slow Fall would have been clever about four seconds ago.",
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
            "Stop. Hammer time.",
            "Bang a gong.",
            "We built this city on hammering.",
            "Beat it. Into shape.",
        },

        ["IDLE:CRAFT:Cooking"] = {
            "It's getting hot in here.",
            "Too hot in the kitchen.",
            "Cooking up something good.",
            "Burn, baby, burn. On purpose this time.",
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
            "Blame it on the boogie. Or the blast cap.",
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
            "Shine bright.",
            "Ice on ice.",
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

        ["SPELL:Frostbolt"] = {
            "Ice, ice, %t.",
            "Stop. Collaborate and freeze, %t.",
            "All right, stop. %t is about to get chilly.",
            "Cold as ice, %t. Well. You are now.",
            "Word to your mother. And to your kneecaps, %t.",
        },

        ["SPELL:Ice Lance"] = {
            "Too cold, %t. Way too cold.",
            "Icestruck, %t.",
            "Straight up, no chaser, %t.",
            "Cold as ice, and I am willing to sacrifice you, %t.",
            "Ice, ice, and one more, %t.",
        },

        ["SPELL:Frost Nova"] = {
            "Stop. Nova time, %t.",
            "You can't touch this, %t. You cannot even walk to it.",
            "Not to the left, not to the right. Nowhere, %t.",
            "Stand by me, %t. You have no choice.",
            "Freeze frame, %t.",
        },

        ["SPELL:Blizzard"] = {
            "It's raining ice. Hallelujah, %t.",
            "Who'll stop the ice, %t?",
            "November rain, but colder, %t.",
            "Snow. Blind. %t.",
            "Set fire to the rain? No, %t. I froze it.",
        },

        ["SPELL:Cone of Cold"] = {
            "Everybody in the front. Ice up, %t.",
            "Cold as ice, and you are paying the price, %t.",
            "Chill out, %t. That was not a suggestion.",
            "Ice, ice, everybody, %t.",
            "Cool it now, %t. All of you.",
        },

        ["SPELL:Ice Barrier"] = {
            "Another one bites the ice, %t.",
            "Hit me with your best shot, %t. It's a wall.",
            "Bulletproof. Ice proof. Whatever you have, %t.",
            "Nothing else matters, %t. Especially not your sword.",
            "Can't touch this, %t.",
        },

        ["SPELL:Ice Block"] = {
            "Can't touch this, %t.",
            "Hello darkness, my old cube.",
            "Freeze frame, %t.",
            "I will survive, %t. In here.",
            "Under pressure. Also under ice, %t.",
        },

        ["SPELL:Icy Veins"] = {
            "This is why I'm cold, %t.",
            "Harder. Better. Faster. Colder, %t.",
            "Speed of sound, %t. Coldplay, if you like.",
            "Ice in the veins, %t. Watch this.",
            "Gotta go fast, %t.",
        },

        ["SPELL:Cold Snap"] = {
            "Second verse, same as the first, %t.",
            "Let's do it again, %t.",
            "Rewind. Selecta, %t.",
            "Regulate, %t. Everything is back.",
            "If I could turn back time, %t. I just did.",
        },

        ["SPELL:Summon Water Elemental"] = {
            "Say hello to my little friend, %t. He is damp.",
            "Ain't no mountain high enough for the two of us, %t.",
            "Smooth as water, %t.",
            "It's raining. Personally, %t.",
            "Two against one now, %t.",
        },

        ["SPELL:Frost Ward"] = {
            "Freeze me, %t. I dare you.",
            "Cold as ice, and immune to it, %t.",
            "Ain't no sunshine, and ain't no frostbite, %t.",
            "Ice against ice, %t. I know how this ends.",
            "Bring the cold, %t. I brought a coat.",
        },

        ["SPELL:Frost Armor"] = {
            "Ice on my everything, %t.",
            "Blame it on the ice, %t.",
            "Sharp dressed man, but colder.",
            "Touch me and freeze, %t. Careful.",
            "Cold as ice. Wearing it, %t.",
        },

        ["SPELL:Ice Armor"] = {
            "New armour, who this, %t.",
            "Upgrade you, %t. No. Upgrade me.",
            "Ice on my shoulders, %t. Not jewellery.",
            "Bigger. Better. Colder.",
            "Frost Armor was fine. This is finer.",
        },

        ["SPELL:Fireball"] = {
            "Burn, baby, burn, %t.",
            "Come on baby, light my fire, %t.",
            "We didn't start the fire, %t. Actually, I did.",
            "Ring of fire, %t. Down, down, down.",
            "Great balls of fire, %t.",
        },

        ["SPELL:Fire Blast"] = {
            "Too hot, %t. Somebody call somebody.",
            "This girl is on fire. No, %t. You are.",
            "Light it up, %t.",
            "No cast. No wait. Straight fire, %t.",
            "Hot right now, %t.",
        },

        ["SPELL:Scorch"] = {
            "Slow burn, %t.",
            "Just a little bit, %t. Just a little bit.",
            "Feel the heat coming on, %t.",
            "Warming up, %t. Bear with me.",
            "One layer at a time, like a slow jam, %t.",
        },

        ["SPELL:Flamestrike"] = {
            "The floor is lava, %t.",
            "Disco inferno. Burn that floor down, %t.",
            "Dancing on the ceiling? Try the floor, %t.",
            "Stayin' alive is not an option down there, %t.",
            "Watch your step, %t. It's getting hot in here.",
        },

        ["SPELL:Pyroblast"] = {
            "It's getting hot in here, %t. That is not a figure of speech.",
            "Highway to hell, %t. You are the exit.",
            "Firestarter, %t.",
            "Boom. Shake the room, %t.",
            "Big things coming, %t. Look up.",
        },

        ["SPELL:Blast Wave"] = {
            "Bye bye bye, %t.",
            "Get back. Get back to where you once belonged, %t.",
            "Push it, %t. All of you, out.",
            "Bounce, %t.",
            "Boom, %t. That is the sound of a room clearing.",
        },

        ["SPELL:Dragon's Breath"] = {
            "Smoke on the water. Fire in the sky, %t.",
            "Dazed and confused, %t.",
            "Puff the magic dragon, %t.",
            "Breathe, %t. That is my job, not yours.",
            "Hot in the face, %t.",
        },

        ["SPELL:Combustion"] = {
            "Burning down the house, %t.",
            "Hotter than hell, %t.",
            "I'm on fire, %t.",
            "Light my fire, and then some, %t.",
            "Turn up the heat, %t.",
        },

        ["SPELL:Fire Ward"] = {
            "You can't burn me, %t. Nothing else matters.",
            "Play with fire, %t. See what happens.",
            "Burn, baby, burn. Not this baby, %t.",
            "Through the fire and out the other side, %t.",
            "Fireproof, %t.",
        },

        ["SPELL:Molten Armor"] = {
            "Careful, %t. I'm burning up.",
            "Too hot to handle, %t.",
            "Armour on fire, %t.",
            "Touch me and burn, %t.",
            "Hot in the shell, %t.",
        },

        ["SPELL:Arcane Missiles"] = {
            "Hit me, baby, four more times, %t.",
            "One, two, three, four. Nothing you can do, %t.",
            "Ain't no stopping them now, %t.",
            "Can't stop, won't stop, %t.",
            "Every little thing lands, %t.",
        },

        ["SPELL:Arcane Blast"] = {
            "Mo' mana, mo' problems, %t.",
            "Mana rules everything around me, %t.",
            "Bigger. Louder. More expensive, %t.",
            "Blast off, %t.",
            "Boom, %t. And the next one costs me more.",
        },

        ["SPELL:Arcane Explosion"] = {
            "Jump around, %t.",
            "Everybody in the club, %t. Get down.",
            "Boom, boom, %t.",
            "It's a party, %t. You are not invited.",
            "Shake it off, %t. You cannot.",
        },

        ["SPELL:Counterspell"] = {
            "No, no, no, %t.",
            "Say my name. Actually, say nothing, %t.",
            "Stop. In the name of the Kirin Tor, %t.",
            "The sound of silence, %t.",
            "Shut up and dance? No, %t. Just the first part.",
        },

        ["SPELL:Polymorph"] = {
            "Who let the sheep out, %t.",
            "Mary had a little lamb. Now I do, %t.",
            "Baa baa black sheep, %t.",
            "You had a bad day, %t. And now you have wool.",
            "Sheep to sleep, %t.",
        },

        ["SPELL:Blink"] = {
            "Now you see me. Now you don't, %t.",
            "Gone like a bat out of hell, %t.",
            "Catch me if you can, %t.",
            "Blink and you missed it, %t.",
            "Bye bye bye, %t.",
        },

        ["SPELL:Slow"] = {
            "Slow ride, %t. Take it easy.",
            "Slow and low, %t. That is the tempo.",
            "Time is on my side, %t. Not yours.",
            "Slow jam, %t.",
            "Ain't no hurry now, %t.",
        },

        ["SPELL:Spellsteal"] = {
            "Finders keepers, %t.",
            "Bills, bills, bills. All mine now, %t.",
            "Thank you. Next, %t.",
            "Gold digger, %t. Guilty.",
            "You had it, %t. Past tense.",
        },

        ["SPELL:Remove Lesser Curse"] = {
            "Shake it off, %t.",
            "Cleaning out my closet. And yours, %t.",
            "No more drama, %t.",
            "Free your mind, %t.",
            "That comes right off, %t.",
        },

        ["SPELL:Mana Shield"] = {
            "Hit me with your best shot, %t. I'll pay for it.",
            "Bulletproof, %t.",
            "Bills, bills, bills. Mine, %t.",
            "Take it out of the wrong account, %t.",
            "Every little thing comes out of the blue bar, %t.",
        },

        ["SPELL:Evocation"] = {
            "Running on empty, %t.",
            "Don't stop believin'. And don't stop guarding me, %t.",
            "Gimme a break. Four seconds, %t.",
            "Waiting on the world to change. And refilling, %t.",
            "Refill. Recharge. Rewind, %t.",
        },

        ["SPELL:Arcane Power"] = {
            "I've got the power, %t.",
            "Stronger, %t.",
            "Can't hold us, %t.",
            "Feel the power, %t.",
            "Turn it all the way up, %t.",
        },

        ["SPELL:Presence of Mind"] = {
            "Right now, %t. Not later.",
            "In a New York minute, %t.",
            "Skip to the good part, %t.",
            "Faster than you can say it, %t.",
            "No waiting. No cast, %t.",
        },

        ["SPELL:Invisibility"] = {
            "Now you don't, %t.",
            "Where'd you go, %t?",
            "I disappear, %t.",
            "Just a ghost, %t.",
            "Nobody knows where I am, %t.",
        },

        ["SPELL:Arcane Intellect"] = {
            "Use your brain, %t. I just gave you more of it.",
            "You're welcome, %t. Say my name.",
            "Big brain energy, %t.",
            "Think. Just a little bit harder, %t.",
            "Smooth, %t. And smarter.",
        },

        ["SPELL:Arcane Brilliance"] = {
            "We are family. Take the buff, %t.",
            "Everybody gets one. It's a family affair, %t.",
            "Everybody dance now. And think, %t.",
            "All the single mages, %t.",
            "One for all, %t. Stop asking.",
        },

        ["SPELL:Amplify Magic"] = {
            "Pump up the volume, %t.",
            "Turn it up, %t.",
            "Louder. Everything louder, %t.",
            "More is more, %t.",
            "Crank it, %t.",
        },

        ["SPELL:Dampen Magic"] = {
            "Turn it down, %t.",
            "Quiet storm, %t.",
            "Hush, %t.",
            "Keep it down. Sound of silence, %t.",
            "Lower the volume on all of that, %t.",
        },

        ["SPELL:Mage Armor"] = {
            "Money in the bank, %t.",
            "Mana back. Cash flow, %t.",
            "Ain't nothing gonna break my stride, %t.",
            "Light armour. Heavy wallet, %t.",
            "It keeps coming back, %t.",
        },

        ["SPELL:Slow Fall"] = {
            "Free fallin', %t. Gently.",
            "Gravity is working against you, %t. Not anymore.",
            "Don't stop me now. Actually, do, %t.",
            "Feather light, %t.",
            "Down, down, down. Softly, %t.",
        },

        ["SPELL:Detect Magic"] = {
            "I can see clearly now, %t.",
            "Somebody's watching you, %t. Me.",
            "Show me what you're working with, %t.",
            "Let me see what you've got, %t.",
            "Reading you. Every little thing, %t.",
        },

        ["SPELL:Conjure Water"] = {
            "Don't go chasing waterfalls. I made you one.",
            "Water from nothing. Splish splash.",
            "Free refills. Don't ask again.",
            "Everybody drink up.",
            "Cold water. Cold as ice, obviously.",
        },

        ["SPELL:Conjure Food"] = {
            "Eat it. Just eat it.",
            "Hungry like the wolf? Here.",
            "Bread from nothing. You're welcome.",
            "Nobody is getting seconds.",
            "Free food. Nothing in this world is free, except this.",
        },

        ["SPELL:Conjure Mana Agate"] = {
            "Shine bright. Sort of.",
            "Ice in the bag.",
            "Break glass in emergency.",
            "Gems on gems. Small ones.",
        },

        ["SPELL:Conjure Mana Jade"] = {
            "Shine bright.",
            "Ice in the bag. Greener now.",
            "Break glass in emergency.",
            "Gems on gems.",
        },

        ["SPELL:Conjure Mana Citrine"] = {
            "Shine bright.",
            "Ice in the bag. Better bag.",
            "Break glass in emergency.",
            "Gems on gems.",
        },

        ["SPELL:Conjure Mana Ruby"] = {
            "Rubies. Close enough to diamonds.",
            "Shine bright.",
            "Break glass in emergency.",
            "Gems on gems, and this one is serious.",
        },

        ["SPELL:Conjure Mana Emerald"] = {
            "Diamonds are forever. Emeralds are for later.",
            "Shine bright. Brightest yet.",
            "Break glass in emergency.",
            "The good stuff. Gems on gems.",
        },

        ["SPELL:Ritual of Refreshment"] = {
            "Come and get it.",
            "Celebrate good times. Come on.",
            "Table for everyone. It's a family affair.",
            "Two helpers. Don't make me ask twice.",
            "All you can eat. Dinner is served.",
        },

        ["SPELL:Shoot"] = {
            "Shot through the heart, %t.",
            "Bang bang, %t.",
            "Ain't too proud to beg. Or to use a stick, %t.",
            "Out of mana. Nothing but a bad time, %t.",
            "Pew. That's all I've got, %t.",
        },

        ["SPELL:Teleport: Stormwind"] = {
            "Sweet home Stormwind.",
            "Take me home. Country roads not required.",
            "Stormwind. Give me a moment.",
        },

        ["SPELL:Teleport: Ironforge"] = {
            "We built this city. On rock. Literally.",
            "Ironforge. Mind the lava.",
            "Deep in the mountain. Give me a moment.",
        },

        ["SPELL:Teleport: Darnassus"] = {
            "Purple rain. Purple trees.",
            "Up the big tree. Give me a moment.",
            "Darnassus. Mind the branches.",
        },

        ["SPELL:Teleport: Exodar"] = {
            "Space oddity. Purple crystal edition.",
            "The Exodar. It crashed. I still go there.",
            "Ground control, give me a moment.",
        },

        ["SPELL:Teleport: Theramore"] = {
            "Sittin' on the dock of the bay.",
            "Theramore. Bring a coat, it's damp.",
            "By the sea. Give me a moment.",
        },

        ["SPELL:Teleport: Orgrimmar"] = {
            "Welcome to the jungle. It's a valley, but still.",
            "Orgrimmar. Give me a moment.",
            "Straight outta the barrens.",
        },

        ["SPELL:Teleport: Undercity"] = {
            "Down under. Way under.",
            "The Undercity. Mind the smell.",
            "Basement business. Give me a moment.",
        },

        ["SPELL:Teleport: Thunder Bluff"] = {
            "Thunderstruck.",
            "Up on the mesa. Mind the lift.",
            "Thunder Bluff. Give me a moment.",
        },

        ["SPELL:Teleport: Silvermoon"] = {
            "Bad moon rising. Silver one.",
            "Silvermoon. Everything is red, oddly.",
            "Give me a moment. Picturing the spires.",
        },

        ["SPELL:Teleport: Stonard"] = {
            "Swamp thing.",
            "Stonard. Nobody goes there. That's the appeal.",
            "Give me a moment. It's a swamp.",
        },

        ["SPELL:Teleport: Shattrath"] = {
            "City of light. Sweet city.",
            "Shattrath. Give me a moment.",
            "Broken city, whole mage.",
        },

        ["SPELL:Portal: Stormwind"] = {
            "Sweet home Stormwind. Everyone through.",
            "Portal's open. Don't stop me now.",
            "Stormwind, straight ahead. It won't wait.",
        },

        ["SPELL:Portal: Ironforge"] = {
            "We built this portal on rock and roll.",
            "Ironforge, straight ahead. It won't wait.",
            "Everyone through. Mind the lava.",
        },

        ["SPELL:Portal: Darnassus"] = {
            "Purple rain, straight ahead.",
            "Darnassus. Everyone through, quickly.",
            "Up the tree. It won't wait.",
        },

        ["SPELL:Portal: Exodar"] = {
            "Space oddity, straight ahead.",
            "The Exodar. Everyone through, quickly.",
            "Ground control to everybody. Go.",
        },

        ["SPELL:Portal: Theramore"] = {
            "Dock of the bay, straight ahead.",
            "Theramore. Everyone through, quickly.",
            "It won't stay open. Move.",
        },

        ["SPELL:Portal: Orgrimmar"] = {
            "Welcome to the jungle. Everyone through.",
            "Orgrimmar, straight ahead. It won't wait.",
            "Go on. Straight outta here.",
        },

        ["SPELL:Portal: Undercity"] = {
            "Down under. Everyone through.",
            "The Undercity, straight ahead. Hold your nose.",
            "It won't stay open. Move.",
        },

        ["SPELL:Portal: Thunder Bluff"] = {
            "Thunderstruck. Everyone through.",
            "Thunder Bluff, straight ahead. It won't wait.",
            "Up the mesa. Go.",
        },

        ["SPELL:Portal: Silvermoon"] = {
            "Bad moon rising. Everyone through.",
            "Silvermoon, straight ahead. It won't wait.",
            "Go. Mind the sparkle.",
        },

        ["SPELL:Portal: Stonard"] = {
            "Swamp thing. Everyone through.",
            "Stonard, straight ahead. Nobody ever wants this one.",
            "It won't stay open. Move.",
        },

        ["SPELL:Portal: Shattrath"] = {
            "City of light. Everyone through.",
            "Shattrath, straight ahead. It won't wait.",
            "Go on. Mind the naaru.",
        },
    },
}
