-- RPVox -- Rogue class pack
--
-- Voice: a guild-trained professional who regards killing as skilled trade
-- work. Rates, standards, tools, apprentices, invoices. Never cruel, never
-- excited, faintly offended by amateurs. The horror is entirely in how
-- ordinary he finds it.
--
-- Deliberately race-neutral so it suits any rogue. Single voice, no moods yet.

RPVox_CLASSES.ROGUE = {
    name = "Rogue",
    spells = {
        { spell = "Sinister Strike",  icon = "Interface\\Icons\\Spell_Shadow_RitualOfSacrifice",  chance = 10 },
        { spell = "Backstab",         icon = "Interface\\Icons\\Ability_BackStab",                chance = 10 },
        { spell = "Mutilate",         icon = "Interface\\Icons\\Ability_Rogue_Shadowstrikes",     chance = 10 },
        { spell = "Eviscerate",       icon = "Interface\\Icons\\Ability_Rogue_Eviscerate",        chance = 10 },
        { spell = "Rupture",          icon = "Interface\\Icons\\Ability_Rogue_Rupture",           chance = 10 },
        { spell = "Slice and Dice",   icon = "Interface\\Icons\\Ability_Rogue_SliceDice",         chance = 10 },
        { spell = "Expose Armor",     icon = "Interface\\Icons\\Ability_Warrior_Riposte",         chance = 10 },
        { spell = "Ambush",           icon = "Interface\\Icons\\Ability_Rogue_Ambush",            chance = 10 },
        { spell = "Garrote",          icon = "Interface\\Icons\\Ability_Rogue_Garrote",           chance = 10 },
        { spell = "Cheap Shot",       icon = "Interface\\Icons\\Ability_CheapShot",               chance = 10 },
        { spell = "Kidney Shot",      icon = "Interface\\Icons\\Ability_Rogue_KidneyShot",        chance = 10 },
        { spell = "Gouge",            icon = "Interface\\Icons\\Ability_Gouge",                   chance = 10 },
        { spell = "Kick",             icon = "Interface\\Icons\\Ability_Kick",                    chance = 10 },
        { spell = "Sap",              icon = "Interface\\Icons\\Ability_Sap",                     chance = 10 },
        { spell = "Blind",            icon = "Interface\\Icons\\Spell_Shadow_MindSteal",          chance = 10 },
        { spell = "Distract",         icon = "Interface\\Icons\\Ability_Rogue_Distract",          chance = 10 },
        { spell = "Stealth",          icon = "Interface\\Icons\\Ability_Stealth",                 chance = 10 },
        { spell = "Vanish",           icon = "Interface\\Icons\\Ability_Vanish",                  chance = 10 },
        { spell = "Shadowstep",       icon = "Interface\\Icons\\Ability_Rogue_Shadowstep",        chance = 10 },
        { spell = "Sprint",           icon = "Interface\\Icons\\Ability_Rogue_Sprint",            chance = 10 },
        { spell = "Evasion",          icon = "Interface\\Icons\\Spell_Shadow_ShadowWard",         chance = 10 },
        { spell = "Feint",            icon = "Interface\\Icons\\Ability_Rogue_Feint",             chance = 10 },
        { spell = "Cloak of Shadows", icon = "Interface\\Icons\\Spell_Shadow_NetherCloak",        chance = 10 },
        { spell = "Adrenaline Rush",  icon = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate", chance = 10 },
        { spell = "Blade Flurry",     icon = "Interface\\Icons\\Ability_Warrior_PunishingBlow",   chance = 10 },
        { spell = "Pick Pocket",      icon = "Interface\\Icons\\INV_Misc_Bag_11",                 chance = 10 },
    },
    lines = {

        -- Abilities -----------------------------------------------------

        ["MELEE"] = {
            "%t. Plain work. It still counts.",
            "%t. Not every job needs a plan.",
            "%t. This is the unskilled part.",
            "%t. Hold still. You are making it take longer.",
            "%t. Nothing clever. Nothing wasted.",
            "%t. I would rather have done this from behind.",
            "%t. Standard rate for standard work.",
        },
        ["SPELL:Sinister Strike"] = {
            "%t. Standard work. Standard rate.",
            "%t. Nothing fancy. Fancy costs extra.",
            "%t. This is the bread and butter of it.",
            "%t. No, I will not be making a speech.",
            "%t. Hold still. You are making this take longer.",
            "%t. I have done this eleven times today.",
            "%t. Ordinary. That is not an insult. It is the highest praise.",
        },

        ["SPELL:Backstab"] = {
            "%t. This is what the back is for.",
            "%t. Third rib. It is always the third rib.",
            "%t. Nothing personal. It is where the work is.",
            "%t. You turned around. That was the mistake.",
            "%t. A fair fight is a job done badly.",
            "%t. I was taught this by someone very patient.",
            "%t. There. Straight through the gap.",
        },

        ["SPELL:Mutilate"] = {
            "%t. Both hands. It is quicker.",
            "%t. Twice the tools, half the time.",
            "%t. I charge the same either way.",
            "%t. Efficiency. That is all this is.",
        },

        ["SPELL:Eviscerate"] = {
            "%t. Right. That is the job.",
            "%t. Signed and settled.",
            "%t. That is what all the setup was for.",
            "%t. Do not make me do it twice. I hate doing it twice.",
            "%t. There. Balance the books.",
            "%t. Quick, at the end. I am not a monster.",
            "%t. Contract fulfilled.",
        },

        ["SPELL:Rupture"] = {
            "%t. Now it will not close on its own.",
            "%t. You will run out slowly. I am sorry about that.",
            "%t. Sit down. It will go easier.",
            "%t. That is the sort of wound that ends arguments.",
        },

        ["SPELL:Slice and Dice"] = {
            "%t. Right. Faster now.",
            "%t. I have another appointment.",
            "%t. Steady work is quick work.",
            "%t. Let us not drag this out.",
        },

        ["SPELL:Expose Armor"] = {
            "%t. That plate cost more than your life. It shows.",
            "%t. Armour is only leather and optimism.",
            "%t. There. Now you are wearing scrap.",
            "%t. Whoever sold you that owes you money.",
        },

        ["SPELL:Ambush"] = {
            "%t. You never heard a thing. Nobody does.",
            "%t. This is the part they pay for.",
            "%t. Good evening. Goodbye.",
            "%t. I have been here for twenty minutes.",
            "%t. That is the whole trade in one movement.",
            "%t. No warning. Warnings are for duels.",
        },

        ["SPELL:Garrote"] = {
            "%t. Quiet, now. That is the entire point.",
            "%t. Quick is kinder. Let it be quick.",
            "%t. This is the tidy way. No mess to explain.",
            "%t. Nobody will hear. Nobody ever does.",
        },

        ["SPELL:Cheap Shot"] = {
            "%t. Yes. Cheap. That is why it works.",
            "%t. Honour is a luxury item.",
            "%t. Down you go. Stay there a moment.",
            "%t. Cheap and effective. Like most useful things.",
        },

        ["SPELL:Kidney Shot"] = {
            "%t. That will fold you up.",
            "%t. Now you cannot do anything at all. Convenient.",
            "%t. Do not try to talk. You cannot.",
        },

        ["SPELL:Gouge"] = {
            "%t. Look away for me.",
            "%t. There. Now you cannot see the next part.",
            "%t. Apologies. That one is genuinely rude.",
        },

        ["SPELL:Kick"] = {
            "%t. No. Not that one.",
            "%t. I do not let people finish those.",
            "%t. Save your breath. And your fingers.",
            "%t. Magic is very fragile at the wrist.",
        },

        ["SPELL:Sap"] = {
            "%t. You are not part of this job. Rest.",
            "%t. Nothing personal. You are simply not on the list.",
            "%t. Wake up in an hour with a headache and a story.",
            "%t. Consider it a night off.",
        },

        ["SPELL:Blind"] = {
            "%t. Dust. Cheap and reliable.",
            "%t. Take a moment. Rub your eyes. Take your time.",
            "%t. I will be somewhere else when you can see again.",
        },

        ["SPELL:Distract"] = {
            "%t. Look over there. People always do.",
            "%t. It works every time and I do not know why.",
        },

        ["SPELL:Stealth"] = {
            "The trick is not moving quietly. It is moving unremarkably.",
            "Nobody looks at a man who is not doing anything.",
            "This part is patience. The rest is arithmetic.",
        },

        ["SPELL:Vanish"] = {
            "%t. And that concludes our business.",
            "%t. No. I do not think I will.",
            "%t. Look somewhere else for a while.",
            "%t. That job is over. This is a different one.",
        },

        ["SPELL:Shadowstep"] = {
            "%t. Behind you. Obviously.",
            "%t. Distance is a matter of technique.",
            "%t. That was quicker than walking.",
        },

        ["SPELL:Sprint"] = {
            "Leaving. Professionally.",
            "%t. This is not fleeing. It is scheduling.",
            "Never run in a straight line. First lesson.",
        },

        ["SPELL:Evasion"] = {
            "%t. You will want to be quicker than that.",
            "%t. Missing costs you. Every time.",
            "%t. I have been dodging drunks since I was nine.",
        },

        ["SPELL:Feint"] = {
            "%t. Not me. Him.",
            "%t. I am not the one you want. Truly.",
        },

        ["SPELL:Cloak of Shadows"] = {
            "%t. Your magic does not adhere. Nothing does.",
            "%t. I have been cursed by professionals.",
        },

        ["SPELL:Adrenaline Rush"] = {
            "%t. Right. Overtime.",
            "%t. I am going to work quickly now. Try to keep up.",
            "%t. This is what a rush job looks like.",
        },

        ["SPELL:Blade Flurry"] = {
            "%t. Both of you at once, then.",
            "%t. Group rate. It is not much of a discount.",
            "%t. Queue if you like. It will not help.",
        },

        ["SPELL:Pick Pocket"] = {
            "That was not locked. That is their fault.",
            "A man should have several incomes.",
            "Nobody counts their purse until they need it.",
        },

        -- Reactions -----------------------------------------------------

        ["REACT:LOWHEALTH"] = {
            "%t. Right. That is a poor development.",
            "%t. I have been hurt worse for less money.",
            "%t. This is going to require stitches and a story.",
            "%t. I have misjudged you. That is rare.",
            "%t. No. No, I am not doing this today.",
            "%t. That will cost you extra now.",
            "%t. Bad planning. Mine, mostly.",
            "%t. Give me one moment and I will be professional again.",
            "%t. I do not get paid to bleed.",
            "%t. Fine. We do this the expensive way.",
            "%t. You are better than the brief suggested.",
            "%t. I have walked away from worse than this.",
            "%t. Someone lied to me about you.",
            "%t. Enough. I am going to stop being careful.",
            "%t. Do not celebrate. I have had bad days before.",
            "%t. Every scar I have was a lesson. This is tuition.",
            "%t. I want you to know I am now working for free.",
            "%t. This is the part where amateurs run.",
            "%t. I am not an amateur.",
            "%t. Right. Let us finish and go home.",
            "%t. I have a reputation. It is not going to end here.",
            "%t. Still standing. Still billing.",
            "%t. You will not get a second opening like that.",
        },

        ["REACT:DEATH"] = {
            "%t. Well. That is the job, some days.",
            "%t. Somebody tell the guild.",
            "%t. My tools go to the apprentice. He has earned them.",
            "%t. I always thought it would be a rooftop.",
            "%t. Do not go through my pockets. There are traps.",
            "%t. I was owed for three jobs. Somebody collect.",
            "%t. Careless. That is the word for it. Careless.",
            "%t. Every one of us goes this way eventually.",
            "%t. Do not make a fuss. It is bad for business.",
            "%t. Twenty years without a scratch, and then this.",
            "%t. There is money buried where nobody will find it. Shame.",
            "%t. Tell them I did not talk.",
            "%t. This is what happens when you take work you do not like.",
            "%t. Bury me quiet. That is the only request.",
            "%t. I should have charged more.",
            "%t. Somebody will take the contract on you. Count on it.",
            "%t. It has been a long trade. This is a poor ending to it.",
            "%t. No last words. They are unprofessional.",
            "%t. Right. Done.",
        },

        ["REACT:RESURRECT"] = {
            "Right. Back to work.",
            "That will not be going in the ledger.",
            "Nobody speaks of this. It affects the rates.",
            "Everything still where I left it. Good.",
            "Well. That is a day I would like refunded.",
            "Back on the clock.",
            "I have been unconscious in worse places.",
            "Right. Where were we.",
            "That was sloppy. It will not happen again.",
            "Do not look so surprised. Neither am I.",
            "The trade goes on. It always goes on.",
            "One missed appointment. It happens.",
            "Fine. Fine. Working.",
        },

        ["REACT:KILLINGBLOW"] = {
            "%t. Done. Next.",
            "%t. Nothing personal. It was never personal.",
            "%t. Somebody paid for that. It may as well have been good.",
            "%t. Quick, at the end. That is all I promise anyone.",
            "%t. That is the contract closed.",
            "%t. Do not leave them where they will be found.",
            "%t. Clean. I like clean.",
            "%t. He fought well enough. It made no difference.",
            "%t. Twenty seconds. About standard.",
            "%t. Somebody will be sorry about you. Not me.",
            "%t. That is the job. That is all it ever is.",
            "%t. No mess to speak of. Good.",
            "%t. He should have paid his debts.",
            "%t. Settled.",
            "%t. Right. Where is the next name.",
        },

        ["REACT:COMBATSTART"] = {
            "%t. Right. Let us be quick about this.",
            "%t. I did not want this to be complicated.",
            "%t. You could still walk away. Most do not.",
            "%t. This is not a duel. Do not treat it as one.",
            "%t. I charge more for daylight.",
            "%t. Nothing about this is going to be sporting.",
            "%t. Fine. Overtime it is.",
            "%t. You have made yourself work.",
            "%t. I am going to be professional. You will not enjoy it.",
            "%t. Let us not make this a story.",
            "%t. Is it money? It is usually money.",
            "%t. I would rather have done this quietly.",
            "%t. Last chance to be somewhere else.",
            "%t. Right then. Business.",
            "%t. This will take less time than you think.",
        },

        ["REACT:COMBATEND"] = {
            "Right. That is that.",
            "Nobody saw. That is the important part.",
            "Messier than I like. It happens.",
            "I want a drink and a quiet room.",
            "Done and closed.",
            "That took longer than it should have. My fault.",
            "Nothing left to do here.",
            "Somebody will find that eventually. Not soon.",
            "Good work. Not clean work. Good work.",
            "I am getting old for this.",
            "Right. Invoice, then bed.",
            "That is one more I do not have to think about.",
            "Quiet again. That is how it should be.",
        },

        ["REACT:INTERRUPTED"] = {
            "%t. Do not do that.",
            "%t. That was going somewhere.",
            "%t. You have made this take longer. I bill by the job.",
            "%t. Amateurish. Effective, but amateurish.",
            "%t. Right. Differently, then.",
            "%t. I dislike being touched while I work.",
            "%t. That was the second interruption. There is not a third.",
            "%t. Fine. I have other tools.",
            "%t. You are more trouble than the fee.",
            "%t. Do you know how long that took to set up?",
            "%t. Now I am going to be untidy.",
            "%t. Interesting. Nobody has done that in years.",
            "%t. Very well. The quick way.",
            "%t. That cost you the easy version.",
            "%t. Enough. Let us finish.",
        },

        ["REACT:LEVELUP"] = {
            "Better. Faster. Worth more.",
            "That is another year of practice compressed into an afternoon.",
            "The rates go up.",
            "Good. Nobody stays sharp by accident.",
            "I could not have done that last month.",
            "The trade rewards attention. Nothing else.",
            "Steadier. That is the only measure that matters.",
            "Right. Harder jobs, then.",
            "I am getting good at this. I was already good at this.",
            "Another notch. Nobody sees them but me.",
        },

        ["REACT:FALLING"] = {
            "This is why we check the ledge.",
            "I have done this on purpose before. Not today.",
            "Right. Roll on landing. Roll on landing.",
            "Miscalculated. Rare, but it happens.",
            "That gutter was not load bearing.",
            "This is going to hurt in an expensive way.",
            "Do not tense. Tensing breaks things.",
            "Well. Nearly.",
            "Every rooftop is fine until it is not.",
            "Ground. Yes. Hello.",
        },

        ["REACT:DROWNING"] = {
            "This is a stupid way for a professional to go.",
            "The boots. It is always the boots.",
            "Air. Now would be good.",
            "I cannot swim in kit. Nobody can swim in kit.",
            "Up. Up. Come on.",
            "Not drowning. Anything but drowning.",
            "That is one of my knives gone.",
            "Cold. Very cold.",
            "Somebody. Anybody.",
            "I have survived three guilds. Not this.",
        },

        ["REACT:DURABILITY"] = {
            "Tools first. Always tools first. And I have let them go.",
            "This will not hold another job.",
            "A bad workman blames his tools. A good one replaces them.",
            "I need a smith who does not ask questions.",
            "This kit has done four hundred jobs. It is allowed to be tired.",
            "Blunt. Blunt is dangerous. Blunt is how people get caught.",
            "Right. Repairs before anything else.",
            "I have been sloppy about maintenance. That is how it starts.",
            "You cannot do quiet work in noisy gear.",
            "This is the sort of thing that kills professionals.",
        },

        -- Idle ----------------------------------------------------------

        ["IDLE:EAT"] = {
            "Fuel. That is all this is.",
            "I have eaten worse in better places.",
            "Quickly. Never linger over a meal.",
            "You learn to eat fast or you learn to go hungry.",
            "This is the best part of the day, and it lasts four minutes.",
        },

        ["IDLE:DRINK"] = {
            "Never on the job. That is the rule that keeps you alive.",
            "One drink is fine. It is the second that talks.",
            "I knew a man who drank before work. Once.",
            "To absent colleagues. There are a great many of them.",
        },

        ["IDLE:MOUNT"] = {
            "Faster than walking. That is the whole argument.",
            "Somewhere to be. There is always somewhere to be.",
            "A horse is a poor place to hide. Remember that.",
        },

        ["IDLE:QUESTACCEPT"] = {
            "Right. Terms?",
            "I will want half in advance.",
            "Consider it taken.",
            "Fine. But I do it my way or not at all.",
            "No questions from me. Extend the same courtesy.",
            "You have hired the right man. That is not boasting.",
            "It will be done and you will not hear about it.",
        },

        ["IDLE:SKINNING"] = {
            "Same skills. Different subject.",
            "Waste nothing. Somebody will buy it.",
            "This is honest money, which makes a pleasant change.",
            "Steady hands are steady hands.",
        },

        ["IDLE:FISHING"] = {
            "This is the only patience that never pays.",
            "Nobody looks twice at a man fishing. That is the real use of it.",
            "Quiet. I do not get much quiet.",
            "No fee, no name, no hurry. Strange.",
        },

        ["IDLE:DISCOVERY"] = {
            "Nice. Two ways out. Three if you count the roof.",
            "I do not see much scenery in my line.",
            "Worth remembering. Everything is worth remembering.",
            "Nobody here knows my face. That is a rare pleasure.",
        },
    },
}
