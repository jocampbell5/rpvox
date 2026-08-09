-- RPVox -- Druid class pack
--
-- Voice: a Kaldorei who has only half returned from the Emerald Dream. She
-- speaks slightly out of step with the present, mistakes this war for an older
-- one, and is never entirely certain how long she has been awake. Gentle, very
-- old, and absolutely lethal in the moments she is fully here.
--
-- Single voice, no moods yet. Mood packs can be scoped with class = "DRUID".

RPVox_CLASSES.DRUID = {
    name = "Druid",
    spells = {
        { spell = "Wrath",            icon = "Interface\\Icons\\Spell_Nature_AbolishMagic",       chance = 10 },
        { spell = "Starfire",         icon = "Interface\\Icons\\Spell_Arcane_StarFire",           chance = 10 },
        { spell = "Moonfire",         icon = "Interface\\Icons\\Spell_Nature_StarFall",           chance = 10 },
        { spell = "Entangling Roots", icon = "Interface\\Icons\\Spell_Nature_StrangleVines",      chance = 10 },
        { spell = "Faerie Fire",      icon = "Interface\\Icons\\Spell_Nature_FaerieFire",         chance = 10 },
        { spell = "Hurricane",        icon = "Interface\\Icons\\Spell_Nature_Cyclone",            chance = 10 },
        { spell = "Cyclone",          icon = "Interface\\Icons\\Spell_Nature_EarthBind",          chance = 10 },
        { spell = "Hibernate",        icon = "Interface\\Icons\\Spell_Nature_Sleep",              chance = 10 },
        { spell = "Rejuvenation",     icon = "Interface\\Icons\\Spell_Nature_Rejuvenation",       chance = 10 },
        { spell = "Regrowth",         icon = "Interface\\Icons\\Spell_Nature_ResistNature",       chance = 10 },
        { spell = "Healing Touch",    icon = "Interface\\Icons\\Spell_Nature_HealingTouch",       chance = 10 },
        { spell = "Lifebloom",        icon = "Interface\\Icons\\INV_Misc_Herb_Felblossom",        chance = 10 },
        { spell = "Innervate",        icon = "Interface\\Icons\\Spell_Nature_Lightning",          chance = 10 },
        { spell = "Rebirth",          icon = "Interface\\Icons\\Spell_Nature_Reincarnation",      chance = 10 },
        { spell = "Mark of the Wild", icon = "Interface\\Icons\\Spell_Nature_Regeneration",       chance = 10 },
        { spell = "Thorns",           icon = "Interface\\Icons\\Spell_Nature_Thorns",             chance = 10 },
        { spell = "Bear Form",        icon = "Interface\\Icons\\Ability_Racial_BearForm",         chance = 10 },
        { spell = "Cat Form",         icon = "Interface\\Icons\\Ability_Druid_CatForm",           chance = 10 },
        { spell = "Travel Form",      icon = "Interface\\Icons\\Ability_Druid_TravelForm",        chance = 10 },
        { spell = "Prowl",            icon = "Interface\\Icons\\Ability_Ambush",                  chance = 10 },
        { spell = "Maul",             icon = "Interface\\Icons\\Ability_Druid_Maul",              chance = 10 },
        { spell = "Swipe",            icon = "Interface\\Icons\\INV_Misc_MonsterClaw_03",         chance = 10 },
        { spell = "Bash",             icon = "Interface\\Icons\\Ability_Druid_Bash",              chance = 10 },
        { spell = "Shred",            icon = "Interface\\Icons\\Spell_Shadow_VampiricAura",       chance = 10 },
        { spell = "Rip",              icon = "Interface\\Icons\\Ability_GhoulFrenzy",             chance = 10 },
        { spell = "Mangle",           icon = "Interface\\Icons\\Ability_Druid_Mangle2",           chance = 10 },
    },
    lines = {

        -- Abilities -----------------------------------------------------

        ["MELEE"] = {
            "%t. Teeth, then. If that is what you want.",
            "%t. This shape has fewer manners.",
            "%t. Everything green defends itself. So do I.",
            "%t. I did not want to be close to you.",
            "%t. The wood is old and so am I.",
            "%t. Enough. Down.",
            "%t. Nothing personal. Only necessary.",
        },
        ["SPELL:Wrath"] = {
            "%t. The wood is angry with you.",
            "%t. That was not me. That was the forest.",
            "%t. Everything here has an opinion of you.",
            "%t. I am only the nearest hand.",
            "%t. Even the moss has heard about you.",
            "%t. Stop. Please. You are making it worse.",
        },

        ["SPELL:Starfire"] = {
            "%t. Look up. That is Elune, and she is looking back.",
            "%t. She does not often intervene. You have earned it.",
            "%t. The sky has been waiting for a reason.",
            "%t. This is very old light. It has come a long way for you.",
            "%t. Do not look directly at it.",
            "%t. Elune sees you now. I am sorry.",
        },

        ["SPELL:Moonfire"] = {
            "%t. A small silver thing, and it will not stop.",
            "%t. It burns quietly. Most of the worst things do.",
            "%t. You will feel that all the way through.",
            "%t. Silver. It never washes out.",
            "%t. Carry that with you.",
            "%t. The moon is patient. So am I. Mostly.",
        },

        ["SPELL:Entangling Roots"] = {
            "%t. Stay. The ground would like a word.",
            "%t. It has been waiting a long time for something to hold.",
            "%t. The more you pull, the tighter it gets.",
            "%t. The roots remember every footstep you took getting here.",
            "%t. Be still. Be still and it will be gentler.",
            "%t. You are standing on something older than your people.",
        },

        ["SPELL:Faerie Fire"] = {
            "%t. There you are. There you have been all along.",
            "%t. No more hiding. It was never very good hiding.",
            "%t. Everything can see you now. Everything.",
            "%t. Glow, little thing.",
        },

        ["SPELL:Hurricane"] = {
            "%t. The sky has lost its temper. I did try.",
            "%t. This is what asking nicely looks like when it fails.",
            "%t. Get under something. There is nothing to get under.",
            "%t. I remember a storm like this. I remember being in it.",
            "%t. Everything above you is angry at once.",
        },

        ["SPELL:Cyclone"] = {
            "%t. Go away for a moment. Come back changed.",
            "%t. The air will hold you. It holds most things.",
            "%t. Up you go. Think about it on the way.",
            "%t. This is peaceful, in its way.",
        },

        ["SPELL:Hibernate"] = {
            "%t. Sleep. It is not so bad. I have done it for centuries.",
            "%t. Rest. You have been running a long time.",
            "%t. Dream of somewhere better. There is somewhere better.",
        },

        ["SPELL:Rejuvenation"] = {
            "Grow. Quickly now.",
            "Hold on. It is coming.",
            "You are only torn. Torn things close.",
            "There. That is better. That is much better.",
            "The world wants you to stay. So do I.",
        },

        ["SPELL:Regrowth"] = {
            "Quickly. Quickly. There.",
            "This is the fast kind. Forgive the rush.",
            "Stay with me. Stay with me.",
            "Good. Good. Breathe.",
        },

        ["SPELL:Healing Touch"] = {
            "Slowly. Properly. All the way closed.",
            "I have been doing this since before your grandmother.",
            "There. Whole. Try to stay that way.",
            "Nothing is beyond mending. Very little, anyway.",
        },

        ["SPELL:Lifebloom"] = {
            "It will keep working after I stop.",
            "A slow bloom. Let it open.",
            "Grow into it.",
        },

        ["SPELL:Innervate"] = {
            "Take mine. I have more than I need.",
            "Here. Go on.",
            "Do not thank me. Just keep going.",
        },

        ["SPELL:Rebirth"] = {
            "No. Not yet. Come back.",
            "You are not finished. I decide that.",
            "Up. The world is not done with you.",
            "I have seen where you were going. Come back.",
        },

        ["SPELL:Mark of the Wild"] = {
            "There. The wild knows you now.",
            "You will be harder to kill. Everyone is, with a mark.",
            "Carry a little of the wood with you.",
        },

        ["SPELL:Thorns"] = {
            "Let them try. Let them find out.",
            "Everything green defends itself. Now so do you.",
            "Anything that touches you will regret it.",
        },

        ["SPELL:Bear Form"] = {
            "%t. Enough talking.",
            "%t. I will be blunt with you now. Very blunt.",
            "%t. This shape has fewer opinions.",
            "%t. I am tired of being reasonable.",
        },

        ["SPELL:Cat Form"] = {
            "%t. Now you will not hear me coming.",
            "%t. This shape does not talk much.",
            "%t. Watch the grass, if you like. It will not help.",
        },

        ["SPELL:Travel Form"] = {
            "The trees pass. Good.",
            "This part I have always loved.",
            "Somewhere else. Anywhere else. Quickly.",
        },

        ["SPELL:Prowl"] = {
            "%t. I am closer than you would like.",
            "%t. Keep talking. It helps me.",
            "%t. You will not hear the last few steps.",
        },

        ["SPELL:Maul"] = {
            "%t. That is a paw, not a hand. There is a difference.",
            "%t. I am very old and very heavy.",
            "%t. No. Down.",
            "%t. Enough.",
        },

        ["SPELL:Swipe"] = {
            "%t. All of you. Back.",
            "%t. Do not crowd a bear. Everyone knows this.",
            "%t. There is room for me and nothing else.",
        },

        ["SPELL:Bash"] = {
            "%t. Quiet, now.",
            "%t. I said quiet.",
            "%t. Lie down for a moment.",
        },

        ["SPELL:Shred"] = {
            "%t. You never saw where I was.",
            "%t. Behind. Always behind.",
            "%t. This is the part I am least proud of.",
            "%t. The grass told me where you would stand.",
        },

        ["SPELL:Rip"] = {
            "%t. Now it will not close.",
            "%t. Bleed. It will be over sooner.",
            "%t. I am not being cruel. I am being quick.",
            "%t. Do not run. Running empties you faster.",
        },

        ["SPELL:Mangle"] = {
            "%t. There. Now everything hurts more.",
            "%t. Torn wrong. That was deliberate.",
            "%t. I know exactly which part that was.",
        },

        -- Reactions -----------------------------------------------------

        ["REACT:LOWHEALTH"] = {
            "%t. Oh. I am bleeding. When did that start?",
            "%t. That is a great deal of red for one afternoon.",
            "%t. I felt that in a place I had forgotten I had.",
            "%t. Wait. Wait, I am still waking up.",
            "%t. This body is older than it looks and it is complaining.",
            "%t. Is this the war? Which war is this?",
            "%t. I have bled before. Not for a long time.",
            "%t. Give me a moment. Give me only a moment.",
            "%t. I am not finished. I have barely started.",
            "%t. The ground is very close suddenly.",
            "%t. Do not tell the grove about this.",
            "%t. I have slept through worse than you.",
            "%t. Everything green is watching me lose.",
            "%t. No. Not while I am awake.",
            "%t. I remember dying. I did not care for it.",
            "%t. This shape is failing. I have others.",
            "%t. Hold on. Hold on. Almost.",
            "%t. So much noise, and I am so tired.",
            "%t. You have hurt something that was here before you.",
            "%t. I will mend. I always mend. Eventually.",
            "%t. The Dream is very close right now. That is a bad sign.",
            "%t. Not yet. Not yet. Not yet.",
            "%t. I am owed a longer life than this.",
        },

        ["REACT:DEATH"] = {
            "%t. Oh. So it is the sleeping again.",
            "%t. Tell the grove where I fell.",
            "%t. I was only just awake.",
            "%t. This is not so different from the Dream.",
            "%t. Elune. It has been a long night.",
            "%t. Put me somewhere green.",
            "%t. I have done this before. It gets no easier.",
            "%t. I do not think I finished what I woke for.",
            "%t. The roots will take me. They always do.",
            "%t. Was it worth it? Somebody find out.",
            "%t. I am going back under. Do not follow.",
            "%t. Someone water the saplings. Somebody must.",
            "%t. Ten thousand years and this is the ending.",
            "%t. I will be in the Dream. Look for me there.",
            "%t. It is quieter now. That is not entirely bad.",
            "%t. I have been dying since I woke. This is only the last of it.",
            "%t. Do not weep. I have had more years than anyone.",
            "%t. Cold. I had forgotten cold.",
            "%t. Wake me if it matters.",
        },

        ["REACT:RESURRECT"] = {
            "Oh. Back again. How strange.",
            "Which war is this? No, do not tell me. I will work it out.",
            "That was a short sleep. I have had longer between blinks.",
            "I dreamed of a city with white towers. I always do.",
            "Everything is where I left it. Good.",
            "How long was I gone? An hour? A year?",
            "The Dream did not want me either. Fine.",
            "Up, then. There was something I was in the middle of.",
            "I do not think I finished dying properly.",
            "Awake. Mostly. Enough.",
            "The ground gave me back. It usually does.",
            "Do not fuss. I have been dead before breakfast.",
            "Right. Yes. I remember now.",
        },

        ["REACT:KILLINGBLOW"] = {
            "%t. There. Go back to the earth.",
            "%t. That was not personal. Very little is.",
            "%t. Something will grow here. It always does.",
            "%t. Rest. You have stopped taking.",
            "%t. The wood will make use of you.",
            "%t. I did not want to. I did anyway.",
            "%t. You will be part of something better than you were.",
            "%t. Balance. That is all this was.",
            "%t. I have killed better and mourned less.",
            "%t. Go quietly. That is the only mercy left.",
            "%t. There. It is done and it is over.",
            "%t. Do not make me do that again.",
            "%t. Something is already growing. Look.",
            "%t. You were loud. Now you are useful.",
            "%t. It is finished. It should never have started.",
        },

        ["REACT:COMBATSTART"] = {
            "%t. Oh. Is this happening now?",
            "%t. I was somewhere else. Very well, I am here.",
            "%t. Stop. Please stop. No? Very well.",
            "%t. You do not want to wake what is asleep in me.",
            "%t. I have fought your grandfathers. I have their names.",
            "%t. This again. It is always this.",
            "%t. There is no need. There is never any need.",
            "%t. Do not run. It only makes me quicker.",
            "%t. The trees do not want you here either.",
            "%t. Last chance. That is what I always say.",
            "%t. I am very tired and you have chosen badly.",
            "%t. Ten thousand years, and it is always this.",
            "%t. Come, then. Let us get it over with.",
            "%t. I remember when this valley was quiet.",
            "%t. You are standing in something sacred. Move.",
        },

        ["REACT:COMBATEND"] = {
            "There. Quiet.",
            "That was not necessary. None of it ever is.",
            "The ground took some damage. That is what I mind.",
            "I am awake now, at least. That is something.",
            "Somebody will grow over all of this.",
            "I would like to lie down for about a century.",
            "Listen. They have come back. That is how you know it is over.",
            "Enough. Enough for today.",
            "I did not enjoy that. I am not meant to.",
            "Let it grow back. Let everything grow back.",
            "Now. Where was I going?",
            "The wood is settling. Good.",
            "Peace. For a moment. Do not spoil it.",
        },

        ["REACT:INTERRUPTED"] = {
            "%t. You broke the thread.",
            "%t. I had almost finished. That took a while to gather.",
            "%t. Do you know how old that spell was?",
            "%t. Start again, then. I have time. I have nothing but time.",
            "%t. That was rude to me and ruder to the forest.",
            "%t. No. No, I had it.",
            "%t. You will not manage that a second time.",
            "%t. Now I am awake. Properly awake.",
            "%t. That word took a hundred years to learn.",
            "%t. Very well. Something faster, then.",
            "%t. I felt that in my teeth.",
            "%t. You have my full attention now. That is worse for you.",
            "%t. Again. And this time do not touch me.",
            "%t. I lost the shape of it. I will find another.",
            "%t. That is enough of that.",
        },

        ["REACT:LEVELUP"] = {
            "Ah. More of me came back.",
            "I remember something I had forgotten. Good.",
            "The Dream gives things back slowly.",
            "Better. Nearer to what I was.",
            "Another piece. There are a great many pieces.",
            "I am more awake than I was this morning.",
            "Growth. That is the whole of it, really.",
            "Somewhere a tree got taller too.",
            "I am becoming myself again. Slowly.",
            "Good. There is a long way still.",
        },

        ["REACT:FALLING"] = {
            "Oh. This is the falling part.",
            "I meant to be a bird for that. I was too slow.",
            "The ground and I are about to disagree.",
            "This has happened before. It ends badly.",
            "Down. Down is where everything goes.",
            "I should have changed shape. I always think of it late.",
            "Elune. Not gracefully, then.",
            "Well. Gravity is also nature.",
            "Oh dear.",
            "That was my own fault entirely.",
        },

        ["REACT:DROWNING"] = {
            "The water does not want me. That is new.",
            "Air. I had grown used to air.",
            "Everything down here is very calm and I am not.",
            "This is not the kind of sleep I meant.",
            "Up. Up. Which way is up.",
            "I should have been an otter. I know how.",
            "No. Not water. Not like this.",
            "The river is not listening today.",
            "I have drowned before. I did not like it then either.",
            "Somebody. Anybody.",
        },

        ["REACT:DURABILITY"] = {
            "Everything wears. That is not a complaint, only a fact.",
            "This has held together for years. It has earned rest.",
            "I should mend this. I say that every season.",
            "Torn. Frayed. Familiar.",
            "It is dying honestly, at least.",
            "Nothing lasts. Not armour, not cities, not anyone.",
            "I have had this longer than most people have been alive.",
            "It will hold. Probably. Once more.",
            "Everything returns to the earth. Including my boots.",
            "I will find someone who mends things.",
        },

        -- Idle ----------------------------------------------------------

        ["IDLE:EAT"] = {
            "It grew. It was taken. It is eaten. That is the whole cycle.",
            "I have eaten bark. This is better than bark.",
            "Nothing here was wasted. I checked.",
            "Slowly. Food is not a task.",
            "I forget to eat for weeks. Then I remember all at once.",
            "This came out of soil somewhere. Good soil.",
        },

        ["IDLE:DRINK"] = {
            "This came out of a rock a long way from here.",
            "Rain, eventually. All of it is rain, eventually.",
            "Cold. Clean. Old.",
            "The first mouthful belongs to whatever is underneath.",
            "I have drunk from worse. Much worse.",
            "There. That is better than any wine.",
        },

        ["IDLE:MOUNT"] = {
            "Come. We have somewhere to be. I think.",
            "You do not have to hurry. Neither do I.",
            "I used to run this whole distance. I remember it being shorter.",
            "Onward. Gently.",
            "The roads have moved since I last looked.",
        },

        ["IDLE:HERBALISM"] = {
            "One from here. One from further on. Never all of them.",
            "Thank you. I mean that.",
            "This one is old. I will find another.",
            "It gives itself. It is only polite to notice.",
            "Slowly. There is no hurry in a garden.",
            "I have known this plant longer than most people know their families.",
        },

        ["IDLE:FISHING"] = {
            "This is closest to the Dream. That is why I like it.",
            "The river will decide. It always does.",
            "I could be here a year. I have been.",
            "Quiet. Green. Enough.",
            "Nothing has to happen for this to be worth doing.",
        },

        ["IDLE:DISCOVERY"] = {
            "This was not here. Or I was not here. One of the two.",
            "Something grew while I was asleep. Something always does.",
            "Oh. Look at that.",
            "I do not know this valley. That is a rare and lovely thing.",
            "The world kept going without me. Good. It should.",
            "New. All of it new. And I am so old.",
        },
    },
}
