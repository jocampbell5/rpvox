-- RPVox -- Warlock class pack
--
-- Voice: a contract lawyer who happens to deal in souls. Everything is terms,
-- clauses, arrears and signatures. Impeccably polite, entirely without mercy,
-- and treats his demons as difficult staff on unfavourable contracts. The
-- horror is administrative.
--
-- Single voice, no moods yet. Mood packs can be scoped with class = "WARLOCK".

RPVox_CLASSES.WARLOCK = {
    name = "Warlock",
    spells = {
        { spell = "Shadow Bolt",         icon = "Interface\\Icons\\Spell_Shadow_ShadowBolt",         chance = 10 },
        { spell = "Incinerate",          icon = "Interface\\Icons\\Spell_Fire_Burnout",              chance = 10 },
        { spell = "Immolate",            icon = "Interface\\Icons\\Spell_Fire_Immolation",           chance = 10 },
        { spell = "Corruption",          icon = "Interface\\Icons\\Spell_Shadow_AbominationExplosion", chance = 10 },
        { spell = "Curse of Agony",      icon = "Interface\\Icons\\Spell_Shadow_CurseOfSargeras",    chance = 10 },
        { spell = "Curse of Weakness",   icon = "Interface\\Icons\\Spell_Shadow_CurseOfMannoroth",   chance = 10 },
        { spell = "Seed of Corruption",  icon = "Interface\\Icons\\Spell_Shadow_SeedOfDestruction",  chance = 10 },
        { spell = "Searing Pain",        icon = "Interface\\Icons\\Spell_Fire_SoulBurn",             chance = 10 },
        { spell = "Soul Fire",           icon = "Interface\\Icons\\Spell_Fire_Fireball02",           chance = 10 },
        { spell = "Shadowburn",          icon = "Interface\\Icons\\Spell_Shadow_ScourgeBuild",       chance = 10 },
        { spell = "Conflagrate",         icon = "Interface\\Icons\\Spell_Fire_Fireball",             chance = 10 },
        { spell = "Rain of Fire",        icon = "Interface\\Icons\\Spell_Shadow_RainOfFire",         chance = 10 },
        { spell = "Hellfire",            icon = "Interface\\Icons\\Spell_Fire_Incinerate",           chance = 10 },
        { spell = "Shadowfury",          icon = "Interface\\Icons\\Spell_Shadow_ShadowFury",         chance = 10 },
        { spell = "Fear",                icon = "Interface\\Icons\\Spell_Shadow_Possession",         chance = 10 },
        { spell = "Howl of Terror",      icon = "Interface\\Icons\\Spell_Shadow_DeathScream",        chance = 10 },
        { spell = "Death Coil",          icon = "Interface\\Icons\\Spell_Shadow_DeathCoil",          chance = 10 },
        { spell = "Banish",              icon = "Interface\\Icons\\Spell_Shadow_Cripple",            chance = 10 },
        { spell = "Enslave Demon",       icon = "Interface\\Icons\\Spell_Shadow_EnslaveDemon",       chance = 10 },
        { spell = "Drain Life",          icon = "Interface\\Icons\\Spell_Shadow_LifeDrain02",        chance = 10 },
        { spell = "Drain Soul",          icon = "Interface\\Icons\\Spell_Shadow_HauntingSpirits",    chance = 10 },
        { spell = "Life Tap",            icon = "Interface\\Icons\\Spell_Shadow_BurningSpirit",      chance = 10 },
        { spell = "Health Funnel",       icon = "Interface\\Icons\\Spell_Shadow_LifeDrain",          chance = 10 },
        { spell = "Create Healthstone",  icon = "Interface\\Icons\\INV_Stone_04",                    chance = 10 },
        { spell = "Create Soulstone",    icon = "Interface\\Icons\\INV_Misc_Orb_04",                 chance = 10 },
        { spell = "Summon Imp",          icon = "Interface\\Icons\\Spell_Shadow_SummonImp",          chance = 10 },
        { spell = "Summon Voidwalker",   icon = "Interface\\Icons\\Spell_Shadow_SummonVoidWalker",   chance = 10 },
        { spell = "Summon Felhunter",    icon = "Interface\\Icons\\Spell_Shadow_SummonFelHunter",    chance = 10 },
        { spell = "Summon Succubus",     icon = "Interface\\Icons\\Spell_Shadow_SummonSuccubus",     chance = 10 },
    },
    lines = {

        -- Abilities -----------------------------------------------------

        ["MELEE"] = {
            "%t. Must I do this personally?",
            "%t. This is beneath both of us.",
            "%t. I have staff for this. Literally.",
            "%t. Unbecoming. Effective, but unbecoming.",
            "%t. Consider this an administrative error.",
            "%t. Somebody will hear about this.",
            "%t. I am a professional, not a labourer.",
        },
        ["SPELL:Shadow Bolt"] = {
            "%t. Standard remedy for non-payment.",
            "%t. This is the boilerplate. It gets worse.",
            "%t. Nothing personal. Everything contractual.",
            "%t. Consider that your first notice.",
            "%t. I did send several letters.",
            "%t. The terms were displayed. You did not read them.",
            "%t. Compound interest, in a sense.",
        },

        ["SPELL:Incinerate"] = {
            "%t. Escalation. As per the schedule.",
            "%t. This is the version with the surcharge.",
            "%t. You would have preferred the shadow. Too late.",
            "%t. Section four, subsection burning.",
        },

        ["SPELL:Immolate"] = {
            "%t. A slow account. Those are the profitable ones.",
            "%t. It will continue after I stop paying attention.",
            "%t. Standing charge. It accrues.",
            "%t. Do not put it out. It is not that kind of fire.",
            "%t. Burning is simply interest with a temperature.",
        },

        ["SPELL:Corruption"] = {
            "%t. There. Signed on your behalf.",
            "%t. It is inside the wording now. And inside you.",
            "%t. You will not notice for some time. Then you will.",
            "%t. It works whether you read it or not.",
            "%t. Corruption is such an ugly word for compliance.",
        },

        ["SPELL:Curse of Agony"] = {
            "%t. Payable in instalments. Rising instalments.",
            "%t. It starts small. That is the cruelty of it.",
            "%t. Each moment costs more than the last.",
            "%t. You will beg long before the final payment.",
            "%t. I do not set the rates. I merely apply them.",
        },

        ["SPELL:Curse of Weakness"] = {
            "%t. Reduced capacity. Noted and enforced.",
            "%t. You will find you can do rather less now.",
            "%t. An administrative adjustment.",
        },

        ["SPELL:Seed of Corruption"] = {
            "%t. Planted. Everyone nearby is now a party to this.",
            "%t. Liability spreads. That is rather the point.",
            "%t. Your associates will share the terms shortly.",
        },

        ["SPELL:Searing Pain"] = {
            "%t. Attention, please.",
            "%t. Look at me. Yes. That is what that was for.",
            "%t. A formality. It hurts regardless.",
        },

        ["SPELL:Soul Fire"] = {
            "%t. This one takes a moment. It is worth the wait.",
            "%t. Certain penalties cannot be rushed.",
            "%t. I have been preparing this since you spoke.",
            "%t. Final demand.",
        },

        ["SPELL:Shadowburn"] = {
            "%t. Settlement in full.",
            "%t. The remainder, all at once.",
            "%t. No further correspondence will be entered into.",
        },

        ["SPELL:Conflagrate"] = {
            "%t. And now we call in the fire.",
            "%t. All that accrued interest, realised.",
            "%t. I did tell you it was accruing.",
        },

        ["SPELL:Rain of Fire"] = {
            "%t. A general notice to all present.",
            "%t. Everyone in the affected area. No exceptions.",
            "%t. Consider it a public posting.",
        },

        ["SPELL:Hellfire"] = {
            "%t. I am prepared to absorb some cost myself.",
            "%t. Mutual damage. Mine is budgeted.",
            "%t. This hurts me too. I have accounted for it.",
        },

        ["SPELL:Shadowfury"] = {
            "%t. Everyone stay exactly where you are.",
            "%t. Order. There will be order.",
            "%t. Nobody is leaving this meeting.",
        },

        ["SPELL:Fear"] = {
            "%t. Go. Reconsider. Come back when you are reasonable.",
            "%t. Run along. We will resume shortly.",
            "%t. I find people negotiate better after a walk.",
            "%t. Do not come back until you have thought about it.",
        },

        ["SPELL:Howl of Terror"] = {
            "%t. All of you. Out.",
            "%t. This meeting is suspended.",
            "%t. Everybody leave. Now. Quickly.",
        },

        ["SPELL:Death Coil"] = {
            "%t. A transfer. From your column to mine.",
            "%t. Assets move. That is all economics is.",
            "%t. You will find you are lighter. I am heavier.",
        },

        ["SPELL:Banish"] = {
            "%t. Suspended pending review.",
            "%t. You are out of scope. Wait there.",
            "%t. I will deal with you when there is time.",
        },

        ["SPELL:Enslave Demon"] = {
            "%t. New terms. Non-negotiable.",
            "%t. Congratulations. You work for me now.",
            "%t. Read it. Or do not. It makes no difference.",
        },

        ["SPELL:Drain Life"] = {
            "%t. A modest transfer. You will hardly miss it.",
            "%t. What is yours is, on inspection, mine.",
            "%t. This is simply repayment.",
            "%t. You are settling your account. Well done.",
        },

        ["SPELL:Drain Soul"] = {
            "%t. Now the principal, not merely the interest.",
            "%t. This is the collateral you offered. You did not read that clause.",
            "%t. Everyone signs it. Nobody reads it.",
            "%t. Do not look at me like that. You agreed.",
        },

        ["SPELL:Life Tap"] = {
            "One draws on capital when one must.",
            "It is my health. I may spend it.",
            "A short-term loan against myself.",
        },

        ["SPELL:Health Funnel"] = {
            "Take it. You are no use to me broken.",
            "This is an asset. I maintain my assets.",
            "Do not read anything into this.",
        },

        ["SPELL:Create Healthstone"] = {
            "Keep it. You will be grateful and I will remember that.",
            "A favour. Favours are simply informal contracts.",
            "There. Now you owe me nothing. Officially.",
        },

        ["SPELL:Create Soulstone"] = {
            "A contingency. I believe in contingencies.",
            "Death is a scheduling problem, correctly handled.",
            "Hold this. Do not ask what is in it.",
        },

        ["SPELL:Summon Imp"] = {
            "You are late.",
            "Yes, yes. Get on with it.",
            "Do not speak. Simply burn things.",
        },

        ["SPELL:Summon Voidwalker"] = {
            "Stand in front. That is the entire job description.",
            "You and I have worked together a long time.",
            "Absorb. That is all. Absorb.",
        },

        ["SPELL:Summon Felhunter"] = {
            "Find the caster. Eat what he is holding.",
            "It has no loyalty. It has a contract. That is better.",
        },

        ["SPELL:Summon Succubus"] = {
            "No. The terms are the terms.",
            "You may work. You may not renegotiate.",
            "We have discussed this. Repeatedly.",
        },

        -- Reactions -----------------------------------------------------

        ["REACT:LOWHEALTH"] = {
            "%t. This is an unbudgeted expense.",
            "%t. I am bleeding. That was not in the projections.",
            "%t. You are costing me a great deal.",
            "%t. I will be recovering this from you. With interest.",
            "%t. Do not mistake this for a reversal. It is a fluctuation.",
            "%t. I have spent worse on smaller matters.",
            "%t. Very well. I am now taking this personally, which is expensive.",
            "%t. There are clauses I have not invoked yet.",
            "%t. I did warn you. In writing.",
            "%t. I have creditors who are frightening. You are not one.",
            "%t. Let us renegotiate. From a position of pain.",
            "%t. Everything I have was borrowed. Including this body.",
            "%t. You have made an enemy with excellent record keeping.",
            "%t. Not today. My arrangements do not permit it.",
            "%t. I have a contingency. I always have a contingency.",
            "%t. This will appear in my accounts as a loss. I hate losses.",
            "%t. Do you know what I owe? Do you know to whom?",
            "%t. My death is already spoken for. Not by you.",
            "%t. There are worse things than you holding my paper.",
            "%t. Fine. The unfavourable terms, then.",
            "%t. I am not permitted to die. It would void everything.",
            "%t. Adjust your expectations. I am adjusting mine.",
            "%t. Every wound is simply a debt owed forward.",
        },

        ["REACT:DEATH"] = {
            "%t. Ah. The clause.",
            "%t. Somebody is about to collect on me.",
            "%t. I always knew the terms. I simply hoped for more time.",
            "%t. Do not touch my books. They bite.",
            "%t. This is a breach. Somebody will be hearing from me.",
            "%t. Well. Everything is owed to something.",
            "%t. My affairs are in order. They always are.",
            "%t. I signed for this. A long time ago.",
            "%t. The interest, at last, has come due.",
            "%t. Tell my creditors I went first. It will annoy them.",
            "%t. I would like it noted that this was not my fault.",
            "%t. There is something waiting for me. It has waited a while.",
            "%t. My library goes to nobody. Burn it.",
            "%t. So it is collection day.",
            "%t. Do not grieve. Grief has no market value.",
            "%t. I have been living on borrowed everything.",
            "%t. Somewhere, a ledger closes.",
            "%t. Congratulations. You have foreclosed on me.",
            "%t. Very well. Show me the paperwork.",
        },

        ["REACT:RESURRECT"] = {
            "Ah. The contingency held.",
            "I pay a great deal for that arrangement. Good to know it works.",
            "Death is a scheduling matter. I rescheduled.",
            "Somebody is going to invoice me for that.",
            "All present. Mostly. Near enough.",
            "That will appear on a statement somewhere.",
            "Right. Back to business.",
            "I have been dead. It is remarkably badly organised.",
            "That cost me. It always costs me.",
            "Nothing is free. Not even coming back.",
            "Where were we. Yes.",
            "The terms are still in force. Unfortunately.",
            "One more favour called in. There are not many left.",
        },

        ["REACT:KILLINGBLOW"] = {
            "%t. Account closed.",
            "%t. Paid in full. Rather more than in full.",
            "%t. And that concludes our arrangement.",
            "%t. You should have read the terms.",
            "%t. Nobody ever reads the terms.",
            "%t. Filed. Closed. Forgotten.",
            "%t. That is one fewer outstanding matter.",
            "%t. He had nothing worth taking. Disappointing.",
            "%t. Do not look at me. He signed.",
            "%t. A shame. He was almost useful.",
            "%t. Settled, and settled properly.",
            "%t. I take no pleasure in this. I take payment.",
            "%t. Somewhere, something is collecting him. Not me.",
            "%t. Next matter.",
            "%t. That is the trouble with defaulting.",
        },

        ["REACT:COMBATSTART"] = {
            "%t. Very well. Let us discuss terms.",
            "%t. You have chosen litigation. Bold.",
            "%t. I would rather have settled this in writing.",
            "%t. Do you have any idea what I have signed?",
            "%t. This is going to be procedural and unpleasant.",
            "%t. I represent interests you cannot conceive of.",
            "%t. Last opportunity for an amicable resolution.",
            "%t. No? Then we proceed.",
            "%t. I am obliged to warn you. Consider yourself warned.",
            "%t. Everything after this point is on your account.",
            "%t. Come, then. Let us establish liability.",
            "%t. I do not enjoy this. I am simply very good at it.",
            "%t. You are in arrears and you do not even know it.",
            "%t. Right. Formal proceedings.",
            "%t. This will be documented.",
        },

        ["REACT:COMBATEND"] = {
            "Settled.",
            "That is the paperwork done.",
            "Tedious. Necessary, but tedious.",
            "Nobody outstanding? Good.",
            "You may go. We will speak again.",
            "I would like a drink and a quiet ledger.",
            "All accounts reconciled.",
            "That cost more than it should have.",
            "This coat was expensive. Somebody has paid for it now.",
            "Business concluded.",
            "The terms hold. They always hold.",
            "Right. Onward.",
            "One less obligation in the world.",
        },

        ["REACT:INTERRUPTED"] = {
            "%t. You have interrupted counsel.",
            "%t. That was mid-clause.",
            "%t. I do not care for that at all.",
            "%t. Very well. We proceed without the formalities.",
            "%t. That will be noted in the record.",
            "%t. Do you know how long that takes to draft?",
            "%t. Interruption is a breach in itself.",
            "%t. I shall have to begin again. You will wait.",
            "%t. That is one. There is a schedule of penalties.",
            "%t. Congratulations. You have added a clause.",
            "%t. I was being courteous. That has now lapsed.",
            "%t. Fine. Summary judgement.",
            "%t. You have cost yourself the negotiated rate.",
            "%t. Again. And do not touch my hands.",
            "%t. That was expensive for you.",
        },

        ["REACT:LEVELUP"] = {
            "Better leverage.",
            "Ah. My position improves.",
            "More is available to me than yesterday.",
            "The terms have improved. Slightly. In my favour.",
            "Capacity grows. So does what one may borrow.",
            "Good. There are things I have wanted to attempt.",
            "Another rung. The ladder goes somewhere unpleasant.",
            "One accumulates. That is the whole art.",
            "I am worth more now. To everyone. Including my creditors.",
            "Progress. Documented.",
        },

        ["REACT:FALLING"] = {
            "This was not in the itinerary.",
            "I do not recall agreeing to this.",
            "There is a demon who could catch me. He will not.",
            "Somebody is going to hear about this.",
            "Gravity. The one force that will not negotiate.",
            "This is going to be costly.",
            "Ah. The ground. Punctual as ever.",
            "I have arrangements. None of them cover this.",
            "Unscheduled descent.",
            "Oh, this is undignified.",
        },

        ["REACT:DROWNING"] = {
            "This is not a death I have papers for.",
            "Water. There is no clause for water.",
            "Air. Immediately, please.",
            "I have survived contracts with things older than oceans.",
            "Up. Up. This is absurd.",
            "That book cost more than a house.",
            "Not this. Anything but this.",
            "Somebody. Something. Anything.",
            "I will owe whatever pulls me out. I accept the terms.",
            "This is going to be so embarrassing.",
        },

        ["REACT:DURABILITY"] = {
            "This was tailored. Tailored.",
            "Maintenance is an expense. I dislike expenses.",
            "Everything depreciates. Even me.",
            "I look like a man who has lost an argument.",
            "Appearance is leverage. This is costing me leverage.",
            "Right. Repairs. Reluctantly.",
            "One cannot negotiate in rags.",
            "This will not survive another engagement.",
            "I shall have to find a tailor who does not ask questions.",
            "Wear and tear. The only creditor that never accepts payment.",
        },

        -- Idle ----------------------------------------------------------

        ["IDLE:EAT"] = {
            "Fuel. The body is a leased property.",
            "One maintains the premises.",
            "I have eaten at better tables. I have eaten at worse.",
            "No. You do not eat. It is in your contract.",
            "This is upkeep, not pleasure.",
        },

        ["IDLE:DRINK"] = {
            "Water. The only thing in this world that is free.",
            "To absent signatories.",
            "One should never negotiate thirsty.",
            "I knew a man who signed a contract while drunk. I own him now.",
        },

        ["IDLE:MOUNT"] = {
            "Time is the only thing I cannot borrow.",
            "Faster. I have obligations.",
            "This beast and I have an arrangement. It is not a friendly one.",
        },

        ["IDLE:QUESTACCEPT"] = {
            "Terms?",
            "Very well. But I want that in writing.",
            "I will do it. You will owe me. Those are the terms.",
            "Consider it agreed. Do not consider it free.",
            "You are quite certain you understand what you have asked?",
            "Signed, in effect. Do not test me on this later.",
            "I never break an agreement. It is the only thing I never do.",
        },

        ["IDLE:HEALTHSTONE"] = {
            "One prepares. Preparation is everything.",
            "This is what contingencies are for.",
            "I made this. I make everything.",
        },

        ["IDLE:FISHING"] = {
            "Patience is a professional skill. This is practice.",
            "Nothing here has signed anything. It is restful.",
            "The water asks for nothing. Unusual.",
            "I could summon something to do this. It would be undignified.",
        },

        ["IDLE:DISCOVERY"] = {
            "Nobody here owes me anything. How restful.",
            "Interesting. And entirely outside my jurisdiction.",
            "A place with no history between us. Rare.",
            "I should like to own this. That is my only response to beauty.",
        },
    },
}
