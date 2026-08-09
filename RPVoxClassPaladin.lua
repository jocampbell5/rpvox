-- RPVox -- Paladin class pack
--
-- Voice: a Blood Knight. He does not pray and he was never granted anything --
-- he takes the Light by force and resents needing it at all. Arrogant,
-- theologically furious, contemptuous of everyone who kneels. Underneath it,
-- the quiet knowledge that what he is holding was stolen and is screaming.
--
-- Single voice, no moods yet. Mood packs can be scoped with class = "PALADIN".

RPVox_CLASSES.PALADIN = {
    name = "Paladin",
    spells = {
        { spell = "Crusader Strike",        icon = "Interface\\Icons\\Spell_Holy_CrusaderStrike",      chance = 10 },
        { spell = "Judgement",              icon = "Interface\\Icons\\Spell_Holy_RighteousFury",       chance = 10 },
        { spell = "Seal of Righteousness",  icon = "Interface\\Icons\\Ability_ThunderBolt",            chance = 10 },
        { spell = "Seal of Command",        icon = "Interface\\Icons\\Ability_Warrior_InnerRage",      chance = 10 },
        { spell = "Seal of Blood",          icon = "Interface\\Icons\\Spell_Holy_SealOfBlood",         chance = 10 },
        { spell = "Consecration",           icon = "Interface\\Icons\\Spell_Holy_InnerFire",           chance = 10 },
        { spell = "Exorcism",               icon = "Interface\\Icons\\Spell_Holy_Excorcism_02",        chance = 10 },
        { spell = "Holy Wrath",             icon = "Interface\\Icons\\Spell_Holy_Excorcism",           chance = 10 },
        { spell = "Hammer of Justice",      icon = "Interface\\Icons\\Spell_Holy_SealOfMight",         chance = 10 },
        { spell = "Hammer of Wrath",        icon = "Interface\\Icons\\Ability_ThunderClap",            chance = 10 },
        { spell = "Avenging Wrath",         icon = "Interface\\Icons\\Spell_Holy_AvengingWrath",       chance = 10 },
        { spell = "Holy Shield",            icon = "Interface\\Icons\\Spell_Holy_BlessingOfProtection", chance = 10 },
        { spell = "Avenger's Shield",       icon = "Interface\\Icons\\Spell_Holy_AvengersShield",      chance = 10 },
        { spell = "Righteous Fury",         icon = "Interface\\Icons\\Spell_Holy_SealOfFury",          chance = 10 },
        { spell = "Holy Light",             icon = "Interface\\Icons\\Spell_Holy_HolyBolt",            chance = 10 },
        { spell = "Flash of Light",         icon = "Interface\\Icons\\Spell_Holy_FlashHeal",           chance = 10 },
        { spell = "Lay on Hands",           icon = "Interface\\Icons\\Spell_Holy_LayOnHands",          chance = 10 },
        { spell = "Cleanse",                icon = "Interface\\Icons\\Spell_Holy_Renew",               chance = 10 },
        { spell = "Redemption",             icon = "Interface\\Icons\\Spell_Holy_Resurrection",        chance = 10 },
        { spell = "Divine Shield",          icon = "Interface\\Icons\\Spell_Holy_DivineIntervention",  chance = 10 },
        { spell = "Divine Protection",      icon = "Interface\\Icons\\Spell_Holy_Restoration",         chance = 10 },
        { spell = "Blessing of Protection", icon = "Interface\\Icons\\Spell_Holy_SealOfProtection",    chance = 10 },
        { spell = "Blessing of Freedom",    icon = "Interface\\Icons\\Spell_Holy_SealOfValor",         chance = 10 },
        { spell = "Blessing of Might",      icon = "Interface\\Icons\\Spell_Holy_FistOfJustice",       chance = 10 },
        { spell = "Blessing of Kings",      icon = "Interface\\Icons\\Spell_Magic_MageArmor",          chance = 10 },
        { spell = "Devotion Aura",          icon = "Interface\\Icons\\Spell_Holy_DevotionAura",        chance = 10 },
        { spell = "Retribution Aura",       icon = "Interface\\Icons\\Spell_Holy_AuraOfLight",         chance = 10 },
    },
    lines = {

        -- Abilities -----------------------------------------------------

        ["MELEE"] = {
            "%t. Plain steel. It does not need blessing.",
            "%t. No Light in that one. Just the arm.",
            "%t. My people learned this before they learned the rest.",
            "%t. Down.",
            "%t. This part I do not have to borrow.",
            "%t. Steel is honest. That is why I keep it.",
            "%t. Again. And again, if I must.",
        },
        ["SPELL:Crusader Strike"] = {
            "%t. Plain work. I am capable of plain work.",
            "%t. No blessing on this one. Just the arm.",
            "%t. I do not need it to be holy to be effective.",
            "%t. There. Struck. No liturgy required.",
            "%t. My arm is mine. Only the rest is borrowed.",
            "%t. Simple. Direct. Honest, for once.",
        },

        ["SPELL:Judgement"] = {
            "%t. Judged. By me. Not by anything above me.",
            "%t. There is no court. There is only what I decide.",
            "%t. I do not ask permission to condemn.",
            "%t. Sentence, and execution, in the same motion.",
            "%t. The Light does not judge. I do. It merely obeys.",
            "%t. You have been weighed by somebody who does not care.",
            "%t. Guilty. Everyone is. Get on with it.",
        },

        ["SPELL:Seal of Righteousness"] = {
            "%t. Righteous. That is the word they use.",
            "%t. Hold still. This part is not for you.",
            "%t. It comes when it is called. It has no choice.",
        },

        ["SPELL:Seal of Command"] = {
            "%t. Command. Note the word. Not request.",
            "%t. I do not ask. I have never asked.",
            "%t. It obeys me. That is the entire arrangement.",
        },

        ["SPELL:Seal of Blood"] = {
            "%t. Yes. It costs me. Everything costs me.",
            "%t. I will bleed for this. Willingly.",
            "%t. My people paid more for less.",
            "%t. Blood is honest. The Light is not.",
        },

        ["SPELL:Consecration"] = {
            "%t. This ground is mine now. Stand on it and burn.",
            "%t. Consecrated. By me. Without ceremony.",
            "%t. Holy ground, and I made it holy myself.",
            "%t. Nothing about this was blessed. It was taken.",
        },

        ["SPELL:Exorcism"] = {
            "%t. Out. Whatever you are, out.",
            "%t. This is what it is actually for.",
            "%t. I have no quarrel with you. I have a function.",
        },

        ["SPELL:Holy Wrath"] = {
            "%t. Wrath. That much I supply myself.",
            "%t. All of it, outward, at once.",
            "%t. This is the only prayer I know.",
        },

        ["SPELL:Hammer of Justice"] = {
            "%t. Down. On your knees. Everyone kneels eventually.",
            "%t. Justice is a hammer. It was always a hammer.",
            "%t. Stay there. It suits you.",
            "%t. I have knelt. I did not enjoy it. Your turn.",
        },

        ["SPELL:Hammer of Wrath"] = {
            "%t. You are finished. This is only the paperwork.",
            "%t. Do not crawl. It is undignified for both of us.",
            "%t. The end, delivered from a distance.",
        },

        ["SPELL:Avenging Wrath"] = {
            "%t. All of it. Now. Everything I am holding.",
            "%t. This is what it looks like when I stop being careful.",
            "%t. Yes, it is screaming. Yes, I am using it anyway.",
            "%t. Look at me. This is what my people had to become.",
        },

        ["SPELL:Holy Shield"] = {
            "%t. Come on then. Break yourself on it.",
            "%t. Everything you spend, you spend for nothing.",
        },

        ["SPELL:Avenger's Shield"] = {
            "%t. And you. And you as well.",
            "%t. It goes where it likes. I merely aim it.",
            "%t. Three of you. It was not a difficult decision.",
        },

        ["SPELL:Righteous Fury"] = {
            "%t. Me. Look at me. Nobody else matters.",
            "%t. I am the loudest thing on this field.",
        },

        ["SPELL:Holy Light"] = {
            "Hold still. This is not gentle.",
            "You are welcome. Do not thank the Light. Thank me.",
            "It works. Whether it wants to or not.",
            "There. Mended. Do not waste it.",
        },

        ["SPELL:Flash of Light"] = {
            "Quickly. That is all I have time for.",
            "Up. Now.",
            "Do not make me do that twice.",
        },

        ["SPELL:Lay on Hands"] = {
            "Take it. All of it. Get up.",
            "This costs me more than you know.",
            "I will not do this again today. Be worth it.",
            "There. Now we are both in trouble.",
        },

        ["SPELL:Cleanse"] = {
            "Hold still. This will sting.",
            "Whatever that was, it is gone.",
            "Cleaner. Not clean. Cleaner.",
        },

        ["SPELL:Redemption"] = {
            "No. Get up. You do not get to leave.",
            "I did not permit that.",
            "Up. There is still work.",
            "Do not thank me. Thank whatever I took this from.",
        },

        ["SPELL:Divine Shield"] = {
            "%t. No. I do not think so.",
            "%t. Try. Go on. Try.",
            "%t. Nothing you have can reach me.",
        },

        ["SPELL:Divine Protection"] = {
            "%t. Not yet.",
            "%t. I decide when I am hurt.",
        },

        ["SPELL:Blessing of Protection"] = {
            "Nothing touches you. Move.",
            "Get out. I will hold this.",
        },

        ["SPELL:Blessing of Freedom"] = {
            "Go. Nothing holds you now.",
            "Run. That is the whole of the blessing.",
        },

        ["SPELL:Blessing of Might"] = {
            "Take it. Hit harder.",
            "There. Now you are worth having beside me.",
        },

        ["SPELL:Blessing of Kings"] = {
            "Kings. Yes. We had those, once.",
            "Everything about you, improved. You are welcome.",
        },

        ["SPELL:Devotion Aura"] = {
            "Stay near me. That is the only instruction.",
            "Devotion. There is a word I did not choose.",
        },

        ["SPELL:Retribution Aura"] = {
            "%t. Touch any of us. See what happens.",
            "%t. Retribution is automatic. I do not have to think about it.",
        },

        -- Reactions -----------------------------------------------------

        ["REACT:LOWHEALTH"] = {
            "%t. This is not how it goes. This is not how it goes.",
            "%t. I am bleeding. Light does not stop that. I have checked.",
            "%t. Do not mistake this for weakness. It is arithmetic.",
            "%t. I have been broken before. I was rebuilt worse.",
            "%t. I did not survive the fall of my city for this.",
            "%t. The Light is not helping. It never helps. It only obeys.",
            "%t. I will not kneel. Not to you. Not to anything.",
            "%t. Everything I have, I took. I can take more.",
            "%t. My people watched their sun go out. You are nothing.",
            "%t. Stop looking at me like that.",
            "%t. I have held worse than this together.",
            "%t. I am not permitted to fall. I have not permitted it.",
            "%t. Very well. Everything, then.",
            "%t. Do you know what I gave up to be able to do this?",
            "%t. Faith is for people who were given something.",
            "%t. I am still standing. Note that. Remember it.",
            "%t. This body has been dying for years. It can wait longer.",
            "%t. There is nothing above me to pray to.",
            "%t. Good. Now I am angry, and that is useful.",
            "%t. I take what I need. I will take this too.",
            "%t. Not here. Not to something like you.",
            "%t. I have bled for less and won.",
            "%t. Come on then. Finish it or fail.",
        },

        ["REACT:DEATH"] = {
            "%t. So it lets go at the end. Of course it does.",
            "%t. I took it and it was never mine.",
            "%t. Tell them I did not kneel.",
            "%t. Do not bury me facing the sun.",
            "%t. My city fell. Now so have I. It is symmetrical.",
            "%t. I regret none of it. Very little of it.",
            "%t. Somebody take my blade. Do not let it rust.",
            "%t. I was owed more time than this.",
            "%t. Was it screaming, all those years? I never asked.",
            "%t. Light. You could have. You simply did not.",
            "%t. Do not pray over me. I would find it insulting.",
            "%t. Silvermoon. I would have liked to see it whole.",
            "%t. Everything I held is going out at once.",
            "%t. There. It is free of me now.",
            "%t. I am not sorry. Write that down.",
            "%t. It was never a gift. It was a hostage.",
            "%t. Tell my order I did not disgrace it.",
            "%t. Cold. That is new.",
            "%t. Finish it, then. I will not ask twice.",
        },

        ["REACT:RESURRECT"] = {
            "Back. It did not want to. It rarely does.",
            "That was not death. That was a delay.",
            "Nobody speaks of that.",
            "I have been dead. It was quiet. I did not care for the quiet.",
            "It obeys. Still. Good.",
            "Right. Where was I.",
            "One does not stay down. Not from where I come from.",
            "My people came back from worse. Considerably worse.",
            "No prayer. No gratitude. Just up.",
            "That will not happen again.",
            "I am owed a great deal for that.",
            "Fine. Fine. Working.",
            "Nothing is finished.",
        },

        ["REACT:KILLINGBLOW"] = {
            "%t. Judged and answered.",
            "%t. There. Sentence carried out.",
            "%t. I did not enjoy that. I do not need to.",
            "%t. That is what the Light is for. Whatever they tell you.",
            "%t. Nobody is coming for your soul. I checked.",
            "%t. You had the chance to be elsewhere.",
            "%t. One fewer thing between me and morning.",
            "%t. Do not look for meaning in it. There is none.",
            "%t. My order does not pray over the dead. It moves on.",
            "%t. Rest. That is the closest to a blessing I have.",
            "%t. That was righteous. I have decided it was.",
            "%t. He believed something. It did not matter.",
            "%t. Finished. Next.",
            "%t. I take no pleasure. I take the field.",
            "%t. Consecrated ground. He is welcome to it.",
        },

        ["REACT:COMBATSTART"] = {
            "%t. Kneel or do not. It ends the same.",
            "%t. I am not here to convert you.",
            "%t. There will be no sermon. There is never a sermon.",
            "%t. You have picked a fight with something I stole.",
            "%t. I do not fight for anyone. I fight because I am able.",
            "%t. Come on. Let us find out what you believe.",
            "%t. My people were given nothing. We took this.",
            "%t. Every one of you thinks you are on the right side.",
            "%t. Judgement is not coming. Judgement is here.",
            "%t. I have no interest in your reasons.",
            "%t. Try. Genuinely. I would enjoy the surprise.",
            "%t. Nothing about this will be holy.",
            "%t. Stand still and it will be quicker.",
            "%t. Right. Let us be about it.",
            "%t. This is going to hurt one of us. Statistically, you.",
        },

        ["REACT:COMBATEND"] = {
            "Done.",
            "It goes quiet when it is finished. So do I.",
            "That was work. Nothing more.",
            "Nobody needs a prayer said over them. Move.",
            "There. It is free of me until the next time.",
            "I want to put this armour down for an hour.",
            "No hymn. No thanks. Simply over.",
            "My order taught me to feel nothing after. It worked.",
            "Enough of that for one day.",
            "Everything holds. Just.",
            "It is only ground again.",
            "Right. Onward.",
            "Quiet. Finally.",
        },

        ["REACT:INTERRUPTED"] = {
            "%t. You do not get to stop me.",
            "%t. That was mine. I had hold of it.",
            "%t. Do you know how hard that is to hold?",
            "%t. It slipped. Because of you.",
            "%t. Nothing interrupts me. Nothing.",
            "%t. Very well. The blunt way, then.",
            "%t. You have made this take longer and hurt more.",
            "%t. I do not have to cast to end you.",
            "%t. That was rude, and it was clever, and I will remember both.",
            "%t. Again. And do not touch my hands.",
            "%t. It fights me enough without your help.",
            "%t. One more. Try one more.",
            "%t. I am not a priest. You cannot silence me.",
            "%t. Fine. Steel, then.",
            "%t. Enough.",
        },

        ["REACT:LEVELUP"] = {
            "More. Good. I want more.",
            "It resists less each time. That is not comfort.",
            "Stronger. That is the only measure.",
            "My order would approve. I do not care.",
            "Another step away from what I was.",
            "I am getting very good at this.",
            "Good. There is a long way to go and a great deal owed.",
            "It obeys more readily now. I notice that.",
            "Capacity. That is all any of it is.",
            "Better. Not finished.",
        },

        ["REACT:FALLING"] = {
            "This armour was not designed for this.",
            "Oh, this is going to be loud.",
            "Plate. Plate and gravity. A poor combination.",
            "I am not built to do this.",
            "The ground. Yes. Obviously.",
            "Nothing about this is dignified.",
            "Light. Not for help. Just noting it.",
            "That will need a smith.",
            "Fine. Fine. Ow.",
            "I have survived worse landings.",
        },

        ["REACT:DROWNING"] = {
            "Armour. It is always the armour.",
            "This is the one thing plate cannot answer.",
            "Air. Now.",
            "Get it off. Get it off.",
            "Up. Up. Come on.",
            "Not like this. Not in the dark.",
            "I cannot burn my way out of water.",
            "Cold. Very cold.",
            "Somebody.",
            "This is a stupid way for anything to end.",
        },

        ["REACT:DURABILITY"] = {
            "This plate has been remade three times. It is tired.",
            "Everything I own has been broken and mended.",
            "So has my city. So have I.",
            "It will hold. It has held through worse.",
            "I need a smith. A good one. A patient one.",
            "Armour is faith you can actually measure.",
            "This has kept me alive for years. It deserves better than me.",
            "Cracked. Everything is cracked.",
            "One more fight in it. Perhaps.",
            "Repairs. Before anything else.",
        },

        -- Idle ----------------------------------------------------------

        ["IDLE:EAT"] = {
            "Fuel. Nothing more.",
            "No blessing. I do not thank anything for food.",
            "My people ate better. Everything was better.",
            "It is a body. It requires maintenance.",
        },

        ["IDLE:DRINK"] = {
            "This is not what we drank at home.",
            "To the ones who did not come back.",
            "Nothing tastes right since. Nothing at all.",
            "One does not sit down in armour if one intends to get up.",
        },

        ["IDLE:MOUNT"] = {
            "Come. There is ground to cover.",
            "A knight walks nowhere he can ride.",
            "Faster. I dislike being late to anything.",
        },

        ["IDLE:QUESTACCEPT"] = {
            "Very well. It will be done.",
            "I do not need to approve of it. I need to finish it.",
            "Consider it handled.",
            "You do not have to explain. I have heard worse reasons.",
            "Fine. But I do it my way.",
            "There is no such thing as a small duty.",
            "It will be done properly or not at all.",
        },

        ["IDLE:FISHING"] = {
            "This is the only thing I do that has no purpose.",
            "Nothing here needs judging. It is restful.",
            "I could put the armour down. I will not, but I could.",
            "Quiet. I had forgotten quiet.",
        },

        ["IDLE:DISCOVERY"] = {
            "It is beautiful. That still happens sometimes.",
            "Nothing here has burned. Nothing here has fallen.",
            "I would have liked to show somebody this.",
            "Good. Some of the world is still intact.",
        },
    },
}
