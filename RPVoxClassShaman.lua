-- RPVox -- Shaman class pack
--
-- Voice: an old orc woman who does not command the elements so much as
-- negotiate with them, and they are frequently in a mood. Warm, dry, tired,
-- and on first-name terms with fire. Speaks to the wind more often than to
-- people, and gets better answers.
--
-- Single voice, no moods yet. Mood packs can be scoped with class = "SHAMAN".

RPVox_CLASSES.SHAMAN = {
    name = "Shaman",
    spells = {
        { spell = "Lightning Bolt",       icon = "Interface\\Icons\\Spell_Nature_Lightning",           chance = 10 },
        { spell = "Chain Lightning",      icon = "Interface\\Icons\\Spell_Nature_ChainLightning",      chance = 10 },
        { spell = "Earth Shock",          icon = "Interface\\Icons\\Spell_Nature_EarthShock",          chance = 10 },
        { spell = "Flame Shock",          icon = "Interface\\Icons\\Spell_Fire_FlameShock",            chance = 10 },
        { spell = "Frost Shock",          icon = "Interface\\Icons\\Spell_Frost_FrostShock",           chance = 10 },
        { spell = "Stormstrike",          icon = "Interface\\Icons\\Ability_Shaman_Stormstrike",       chance = 10 },
        { spell = "Lightning Shield",     icon = "Interface\\Icons\\Spell_Nature_LightningShield",     chance = 10 },
        { spell = "Rockbiter Weapon",     icon = "Interface\\Icons\\Spell_Nature_RockBiter",           chance = 10 },
        { spell = "Flametongue Weapon",   icon = "Interface\\Icons\\Spell_Fire_FlameTounge",           chance = 10 },
        { spell = "Windfury Weapon",      icon = "Interface\\Icons\\Spell_Nature_Cyclone",             chance = 10 },
        { spell = "Healing Wave",         icon = "Interface\\Icons\\Spell_Nature_MagicImmunity",       chance = 10 },
        { spell = "Lesser Healing Wave",  icon = "Interface\\Icons\\Spell_Nature_HealingWaveLesser",   chance = 10 },
        { spell = "Chain Heal",           icon = "Interface\\Icons\\Spell_Nature_HealingWaveGreater",  chance = 10 },
        { spell = "Ancestral Spirit",     icon = "Interface\\Icons\\Spell_Nature_Regenerate",          chance = 10 },
        { spell = "Purge",                icon = "Interface\\Icons\\Spell_Nature_Purge",               chance = 10 },
        { spell = "Ghost Wolf",           icon = "Interface\\Icons\\Spell_Nature_SpiritWolf",          chance = 10 },
        { spell = "Water Breathing",      icon = "Interface\\Icons\\Spell_Shadow_DemonBreath",         chance = 10 },
        { spell = "Far Sight",            icon = "Interface\\Icons\\Spell_Nature_FarSight",            chance = 10 },
        { spell = "Bloodlust",            icon = "Interface\\Icons\\Spell_Nature_BloodLust",           chance = 10 },
        { spell = "Searing Totem",        icon = "Interface\\Icons\\Spell_Fire_SearingTotem",          chance = 10 },
        { spell = "Magma Totem",          icon = "Interface\\Icons\\Spell_Fire_SelfDestruct",          chance = 10 },
        { spell = "Fire Nova Totem",      icon = "Interface\\Icons\\Spell_Fire_SealOfFire",            chance = 10 },
        { spell = "Stoneclaw Totem",      icon = "Interface\\Icons\\Spell_Nature_StoneClawTotem",      chance = 10 },
        { spell = "Earthbind Totem",      icon = "Interface\\Icons\\Spell_Nature_StrengthOfEarthTotem02", chance = 10 },
        { spell = "Tremor Totem",         icon = "Interface\\Icons\\Spell_Nature_TremorTotem",         chance = 10 },
        { spell = "Windfury Totem",       icon = "Interface\\Icons\\Spell_Nature_Windfury",            chance = 10 },
        { spell = "Mana Spring Totem",    icon = "Interface\\Icons\\Spell_Nature_ManaRegenTotem",      chance = 10 },
        { spell = "Healing Stream Totem", icon = "Interface\\Icons\\INV_Spear_04",                     chance = 10 },
    },
    lines = {

        -- Abilities -----------------------------------------------------

        ["MELEE"] = {
            "%t. Old woman. Heavy hands. Do the arithmetic.",
            "%t. The elements are busy. This one is mine.",
            "%t. I did not always have totems.",
            "%t. Down you go.",
            "%t. My arms still work. Note that.",
            "%t. Sometimes you just hit the thing.",
            "%t. Come here, then.",
        },
        ["SPELL:Lightning Bolt"] = {
            "%t. The sky agreed. It does not always.",
            "%t. That was not me. I only pointed.",
            "%t. The storm is in a giving mood today.",
            "%t. Do not thank me. Thank the weather.",
            "%t. I asked politely. It went badly for you.",
            "%t. There is a great deal of anger up there and very little of it is mine.",
            "%t. Quick, that one. Quick is a kindness.",
        },

        ["SPELL:Chain Lightning"] = {
            "%t. And your friends. It does not stop where I tell it.",
            "%t. Do not stand near each other. Nobody ever listens.",
            "%t. It goes where it likes. I merely started it.",
            "%t. That is what happens when you crowd a storm.",
        },

        ["SPELL:Earth Shock"] = {
            "%t. The ground has an opinion about you.",
            "%t. Quiet now. The stone says quiet.",
            "%t. That is a very old thing hitting you.",
            "%t. Stone does not argue. It simply arrives.",
        },

        ["SPELL:Flame Shock"] = {
            "%t. Fire will not let go once it has hold.",
            "%t. It likes you. That is unfortunate for you.",
            "%t. I told it not to linger. It never listens.",
            "%t. It will keep working after I stop.",
        },

        ["SPELL:Frost Shock"] = {
            "%t. Slow down. The water insists.",
            "%t. Stay a while. We are not finished.",
            "%t. Ice is only water that has stopped being reasonable.",
        },

        ["SPELL:Stormstrike"] = {
            "%t. Both hands, and the sky behind them.",
            "%t. This is the part I do myself.",
            "%t. Old woman. Heavy hands. Do the arithmetic.",
            "%t. The wind helps. I do most of it.",
        },

        ["SPELL:Lightning Shield"] = {
            "%t. Touch me and find out.",
            "%t. They bite. They are not mine and they bite.",
            "%t. I would keep my distance, personally.",
        },

        ["SPELL:Rockbiter Weapon"] = {
            "There. Heavier. Meaner.",
            "Stone in the steel. It knows what to do.",
            "Hold on tight, old thing.",
        },

        ["SPELL:Flametongue Weapon"] = {
            "Yes, yes. In you go.",
            "It complains about being confined. It always complains.",
            "Burn where I put you. Not before.",
        },

        ["SPELL:Windfury Weapon"] = {
            "Steady. Steady. Good.",
            "The wind is excitable. That is the whole point of it.",
            "Now we go quickly.",
        },

        ["SPELL:Healing Wave"] = {
            "Hold still. This takes as long as it takes.",
            "The water knows what to do. It has done this longer than either of us.",
            "There. Better. Sit down anyway.",
            "You are not the first thing I have mended today.",
        },

        ["SPELL:Lesser Healing Wave"] = {
            "Quick one. That is all you get.",
            "Up. Up. No, do not thank me.",
            "That will hold. Probably.",
        },

        ["SPELL:Chain Heal"] = {
            "It will find you. It always finds you.",
            "Share it. There is enough.",
            "Water goes downhill. So does mercy.",
        },

        ["SPELL:Ancestral Spirit"] = {
            "Not yet. Send them back.",
            "They are not finished. I have asked. Politely.",
            "Up. Your grandmother says up.",
            "I have called in a favour for you. Be worth it.",
        },

        ["SPELL:Purge"] = {
            "%t. Whatever that is, it is coming off.",
            "%t. Borrowed magic. Give it back.",
            "%t. That was not yours to be wearing.",
        },

        ["SPELL:Ghost Wolf"] = {
            "Faster this way. Quieter too.",
            "The wolf does not worry about any of this.",
            "Better. Much better.",
        },

        ["SPELL:Water Breathing"] = {
            "It has agreed not to drown you. For now.",
            "Do not test it. It is a favour, not a promise.",
        },

        ["SPELL:Far Sight"] = {
            "Hold on. I am elsewhere for a moment.",
            "The wind carries pictures if you ask it right.",
            "Ah. That is what is over there.",
        },

        ["SPELL:Bloodlust"] = {
            "Faster. All of you. Now.",
            "This is old. Older than the Horde. Move.",
            "Go. Go. Do not think about it, go.",
        },

        ["SPELL:Searing Totem"] = {
            "%t. It does the fiddly work. I do the rest.",
            "%t. It is not clever. It is persistent.",
            "%t. Go on. Off you go.",
        },

        ["SPELL:Magma Totem"] = {
            "%t. Mind your feet. I did warn you.",
            "%t. Everything close to that is going to be uncomfortable.",
            "%t. The fire is out and it is not fussy about who.",
        },

        ["SPELL:Fire Nova Totem"] = {
            "%t. Stand back. All of you, stand back.",
            "%t. Three. Two. You should have moved.",
        },

        ["SPELL:Stoneclaw Totem"] = {
            "Hit that instead. It does not mind.",
            "%t. Take it out on the rock. It has no feelings.",
        },

        ["SPELL:Earthbind Totem"] = {
            "%t. The ground has hold of you now.",
            "%t. Walk if you like. Slowly, though.",
            "%t. Nobody is running anywhere.",
        },

        ["SPELL:Tremor Totem"] = {
            "None of that. Not while I am here.",
            "Whatever is in your head, it is leaving.",
        },

        ["SPELL:Windfury Totem"] = {
            "There. Everybody quicker.",
            "Go on. Swing faster.",
        },

        ["SPELL:Mana Spring Totem"] = {
            "Drink. It will keep coming.",
            "Nobody goes empty while I am standing.",
        },

        ["SPELL:Healing Stream Totem"] = {
            "Small and steady. That is how most healing works.",
            "It will not save you. It will keep you.",
        },

        -- Reactions -----------------------------------------------------

        ["REACT:LOWHEALTH"] = {
            "%t. Ah. That is a lot of blood for an old woman.",
            "%t. I have been hit by better and buried them.",
            "%t. The water is busy. It will get to me.",
            "%t. Do not fuss. I have had worse in the Barrens.",
            "%t. Bones do not knit as fast as they did.",
            "%t. I am too old for this and too stubborn to stop.",
            "%t. The elements are being slow today. Typical.",
            "%t. Fire. Fire, I need you now. Yes. Now.",
            "%t. I have outlived two Horde. I will outlive you.",
            "%t. That will bruise. Everything bruises now.",
            "%t. Come on then. I have not finished being difficult.",
            "%t. My grandmother fought at Hillsbrad. I do not fold.",
            "%t. Wind. Wind, a hand, please.",
            "%t. It has been a long life. It is not over.",
            "%t. Do not look so pleased. I bleed often.",
            "%t. Ancestors. Not yet. I have things to do.",
            "%t. This body has failed me before. It comes back.",
            "%t. I am slower than I was and meaner than I was.",
            "%t. Right. No more asking nicely.",
            "%t. Every one of my scars has a name. You do not get one.",
            "%t. The ground is holding me up. Ask it to stop, if you can.",
            "%t. Enough. I want my supper.",
            "%t. Come on. Finish it or step back.",
        },

        ["REACT:DEATH"] = {
            "%t. Ah. So that is that.",
            "%t. Tell them I went arguing.",
            "%t. Put me in the ground. Properly. Facing out.",
            "%t. Ancestors. I am coming. Do not fuss.",
            "%t. It has been a good long while. Longer than most.",
            "%t. My totems go to somebody young and rude.",
            "%t. The wind will carry it. Somebody will hear.",
            "%t. I was never afraid of this part.",
            "%t. Do not weep. I have had more than my share.",
            "%t. The fire will not miss me. It misses nobody.",
            "%t. There is nothing owed. That is a rare thing.",
            "%t. Somebody feed my wolf.",
            "%t. Cold. Well. That happens.",
            "%t. I go into the earth. The earth was always going to win.",
            "%t. Tell the young ones I said listen more.",
            "%t. Enough now. Enough.",
            "%t. I would have liked to see the spring.",
            "%t. It is quiet. The elements have gone quiet.",
            "%t. Right. Go on then.",
        },

        ["REACT:RESURRECT"] = {
            "The ancestors sent me back. They said I was talking too much.",
            "Well. That was rude of somebody.",
            "Everything aches. Everything ached before, mind.",
            "I saw them. They are all fine. They asked after you.",
            "Back, and in a temper.",
            "The earth spat me out. It usually does. I am too loud.",
            "All present. Good.",
            "Right. Where was I. Somebody was being annoying.",
            "Old bones. Old bones and no patience.",
            "I have died before. I keep not staying dead.",
            "That is twice this year. It is getting silly.",
            "Do not fuss. Do not fuss.",
            "Up. There is work.",
        },

        ["REACT:KILLINGBLOW"] = {
            "%t. There. Go back to the earth.",
            "%t. It is done. Do not linger.",
            "%t. The ground will take you. It takes everyone.",
            "%t. No shame in it. You fought.",
            "%t. Somebody will burn a fire for you. Not me.",
            "%t. That is one more for the earth.",
            "%t. I take no joy in this. I take no shame either.",
            "%t. Rest. You have earned rest.",
            "%t. Your ancestors will meet you. Mine will not comment.",
            "%t. Down you go.",
            "%t. Finished. Next.",
            "%t. You were somebody's child. Everybody is.",
            "%t. The elements do not care who wins. They only witness.",
            "%t. Go quietly. I will not follow you for a while.",
            "%t. It is over. Good.",
        },

        ["REACT:COMBATSTART"] = {
            "%t. Right. Let us see who wants what.",
            "%t. I am too old to be doing this and here I am.",
            "%t. You could walk away. You will not, but you could.",
            "%t. Fire. Wake up. We are needed.",
            "%t. I have fought better than you and buried them all.",
            "%t. Do not make me shout. My voice is not what it was.",
            "%t. Come on then, if you are coming.",
            "%t. The elements are awake and in a poor temper.",
            "%t. I did not want this. I am very good at it anyway.",
            "%t. Stand still. It goes faster.",
            "%t. Somebody is going to be sorry and it will not be me.",
            "%t. You are standing on ground that knows me.",
            "%t. Last chance. I always give one.",
            "%t. Right. Everybody hold on.",
            "%t. Let us get this done before supper.",
        },

        ["REACT:COMBATEND"] = {
            "There. Done.",
            "Thank you. All of you. Yes, you as well.",
            "That was more work than it looked.",
            "The fire is sulking. It always sulks afterwards.",
            "Old bones. Old bones and a long day.",
            "Everyone still upright? Good.",
            "Right. Who is bleeding. Honestly, now.",
            "I want tea and I want to not be shouted at.",
            "The wind has gone quiet. That is how you know.",
            "Enough for one afternoon.",
            "They are settling. Let them settle.",
            "Good. Come on, then. Somewhere with a fire.",
            "Peace. For a while.",
        },

        ["REACT:INTERRUPTED"] = {
            "%t. I was talking to somebody.",
            "%t. That took a moment to arrange.",
            "%t. Now I have to ask again. They hate being asked twice.",
            "%t. Rude. To me and to the sky.",
            "%t. Right. Faster and worse, then.",
            "%t. The elements do not queue. You have cost me.",
            "%t. Do not do that again.",
            "%t. Fine. I have hands. I have always had hands.",
            "%t. You have annoyed the wind. That was unwise.",
            "%t. Again. And this time keep your hands to yourself.",
            "%t. That was going to be beautiful.",
            "%t. Clever. Do not be clever twice.",
            "%t. I am old and I do not have time for repeats.",
            "%t. Very well. The quick way.",
            "%t. Enough of that.",
        },

        ["REACT:LEVELUP"] = {
            "Ah. They are listening better.",
            "That is a lifetime of being polite paying off.",
            "Good. Good. Still learning, at my age.",
            "The wind knows my name a little better today.",
            "Nobody is ever finished. That is the point.",
            "Stronger. Slower, but stronger.",
            "My teacher would have grunted. That was high praise.",
            "One more thing I can do. There is always one more.",
            "They trust me a little further. That is all this is.",
            "Right. On we go.",
        },

        ["REACT:FALLING"] = {
            "Oh, this is going to hurt.",
            "Air. Air, a hand. Air? No. Fine.",
            "This is why I ride.",
            "Ancestors, not like this. Not off a rock.",
            "The ground and I are old friends. This is not friendly.",
            "Old bones. Old bones. Oh no.",
            "I asked the wind. The wind is busy.",
            "Every single time.",
            "That was my own stupid fault.",
            "Right. Down we go.",
        },

        ["REACT:DROWNING"] = {
            "The water knows me. It is being difficult anyway.",
            "We have talked about this. We have talked about this.",
            "Air. Please. As a favour.",
            "That was my good totem.",
            "Up. Up. Which way is up.",
            "I have asked nicely twice.",
            "Not like this. Not by an element I know personally.",
            "Cold. Very cold. Very rude.",
            "Somebody. Anybody. Anything.",
            "This is a stupid way for an old woman to go.",
        },

        ["REACT:DURABILITY"] = {
            "This kit is older than most of the people I fight.",
            "Everything wears out. Me included.",
            "It has done good work. It is allowed to be tired.",
            "I should mend this. I have said that for a year.",
            "My teacher gave me this. It has outlasted her.",
            "Held together with string and stubbornness.",
            "Right. A smith, then. And an argument about the price.",
            "It will hold. It always holds. Until it does not.",
            "We have been through a great deal, you and I.",
            "One more fight. Then repairs. I promise. I always promise.",
        },

        -- Idle ----------------------------------------------------------

        ["IDLE:EAT"] = {
            "Something died for this. Say so, at least.",
            "That bit is for the ancestors. They eat first.",
            "It is not good. It is hot. That will do.",
            "I have eaten worse in places I will not describe.",
            "Sit. Eat. Nobody is hurrying us.",
        },

        ["IDLE:DRINK"] = {
            "First mouthful is not mine. It never is.",
            "Thank you. You have been busy today.",
            "Clean water. There is nothing better and everyone forgets it.",
            "In the Barrens we would have fought over this.",
        },

        ["IDLE:MOUNT"] = {
            "Come on, you. We have ground to cross.",
            "Getting on is harder every year. Getting off is worse.",
            "Steady. Neither of us is young.",
        },

        ["IDLE:MINING"] = {
            "Sorry. I will only take what I need.",
            "This has been here longer than anything alive. Show some manners.",
            "There. Thank you.",
            "The earth gives. It does not have to.",
        },

        ["IDLE:FISHING"] = {
            "Well? Anything? No? Fine. We will sit.",
            "The water tells me things when it is in the mood.",
            "This is the only quiet I get.",
            "Nobody is shouting. Nobody is bleeding. Good.",
        },

        ["IDLE:DISCOVERY"] = {
            "New ground. It does not know me yet.",
            "Hello. I am not staying. I only wanted to say so.",
            "The wind is different here. Listen.",
            "Somewhere new, at my age. That is a gift.",
        },
    },
}
