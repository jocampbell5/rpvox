-- RPVox -- Priest-Dirge class pack
--
-- Voice: a priest who speaks only in verse, and only ever grimly. Every line
-- is a self-contained rhyming couplet -- lines fire independently and in any
-- order, so a rhyme can never depend on the next one arriving.
--
-- Written for the moment triggers, not for a spell list. There is no `spells`
-- table: one set of lines covers the whole spellbook, and keeps covering it
-- for spells this character has not learned yet.
--
-- Two rules this voice lives or dies by:
--
--   %t never sits at a rhyme. A player's name cannot be rhymed with, and a
--   couplet that tries reads as broken verse the moment somebody called
--   Bruxxlefarg walks past. It always sits mid-line.
--
--   Most lines carry no %t at all. A line needing a target is skipped when
--   there is none, so a set written entirely around one goes silent the
--   moment nothing is selected.

RPVox_CLASSES = RPVox_CLASSES or {}

RPVox_CLASSES.PRIEST_DIRGE = {
    name = "Priest-Dirge",
    class = "PRIEST",
    lines = {

        -- Moments ---------------------------------------------------------

        ["MELEE"] = {
            "The prayer is finished, %t. The mace is not. A blunt amen for everything you brought.",
            "I swing the rod I once was told to bless. The Light forgave me. I forgave it less.",
            "Bone gives its answer, flesh gives its consent, and neither asks me what the striking meant.",
            "Come close, %t. The staff has learned to bite. Nothing that walks stays vertical all night.",
            "I did not train for this. I only stayed. That is how most of my mistakes are made.",
            "<crit> That was the marrow, %t. I felt it go. The body keeps no secrets from a blow.",
            "<crit> Something inside gave up and came apart. I have heard cleaner endings from a heart.",
            "<miss> The air is bruised, %t, and nothing else is worse. Even the missing is part of the curse.",
            "<miss> I struck the dark and left the dark alone. It is a patient thing. So is the bone.",
        },

        ["COMBAT:SPELL:HIT"] = {
            "The word goes out and finds the place it meant, and what it finds is what the shadow spent.",
            "I said a name that never should be said. It went into you. Now it makes its bed.",
            "Shadow does not argue, %t. It arrives. It takes no interest in how long one lives.",
            "{shadow}~The dark I keep~{/} has gone and found your skin. It knows the door. It always gets let in.",
            "This is not cruelty. This is only true. The Light asked nothing, so the dark asked you.",
            "One syllable. One ending. Nothing more. I have said worse and closed a heavier door.",
            "It lands, %t, and the landing does not ask. The mercy was the speed. That was the task.",
        },

        ["COMBAT:SPELL:CRIT"] = {
            "{shadow}#That went all the way down#{/}, %t, and stayed. Whatever held you shut has been unmade.",
            "The word came out of me with all its weight. I do not think that you will keep your gait.",
            "Something in you has folded, %t, and shut. I felt the seam. I felt the sudden cut.",
            "{shadow}*THE DARK HAS TEETH*{/} and it has used them all. There will be nothing left of you to call.",
            "That was not a warning. That was the whole. Address complaints to whatever took your soul.",
            "I meant that one. That is why it went so deep. The Light is gentler. The dark does not sleep.",
        },

        ["COMBAT:SPELL:MISS"] = {
            "The word went past you, %t, into the ground. The ground has never once complained of sound.",
            "It missed. The dark is old and sometimes slow. It will remember where you chose to go.",
            "Nothing. The air took what was meant for you. The air has taken heavier things. It grew.",
            "A resisted prayer, %t, is still a prayer. It waits. It is in no great hurry there.",
            "I said the word. The word declined to land. Even the shadow will not hold my hand.",
            "That one went wide and buried itself deep. The things I miss with are the things I keep.",
        },

        ["COMBAT:HEAL"] = {
            "The grave will keep. The grave has time to spare, so stand up, %t, while I am standing there.",
            "I close the wound. I do not close the debt. You will be asked for it. You are not asked yet.",
            "Breathe. I have argued with the dark for you. It let me win. It does not often do.",
            "The Light still answers when I say its name, though neither of us says it quite the same.",
            "Up. I have wasted better words than these on people who were slower to their knees.",
            "<crit> Everything torn in you has been made whole. Do not mistake the mending for a soul.",
            "<crit> I gave you all of it, %t, in one breath. That is the closest thing I have to faith.",
        },

        ["COMBAT:BUFF"] = {
            "I put a word around you, %t, like a coat. It will not warm you. It will keep you afloat.",
            "Carry this. It is small and it is grim. It has kept worse than you alive on whim.",
            "A shield of nothing, shaped by what I said. It holds. It has been tested on the dead.",
            "Take it and be quiet. Words are cheap, but this one cost me something I still keep.",
            "I bless you, %t, the only way I can: with something borrowed from a darker plan.",
            "Go on. You are marked now, and marked things last. The dark has learned to walk politely past.",
        },

        ["COMBAT:CC"] = {
            "Be still, %t. Be nothing. Be a stone. The quiet suits you better than your own.",
            "I have taken your voice and put it in a jar. You will not need it, wherever you are.",
            "Sleep. It is not mercy, but it looks the same, and I have stopped apologising for the name.",
            "Hold there, %t. Do not test the thread. It has been strung with something that is dead.",
            "Down, and stay down, and let the dark attest that stillness is the only thing that's blessed.",
            "<miss> The binding slipped. You have a moment more. Spend it. I will be waiting at the door.",
            "<miss> It did not hold, %t. So few things do. I will find something colder to use on you.",
        },

        ["REACT:INTERRUPTED"] = {
            "You broke the verse, %t. You did not break me. A silence is a sentence. Wait and see.",
            "The word died in my mouth and I will grieve. Then I will say it slower. Do not leave.",
            "Cut off mid-prayer. How very brave of you. The dark heard half. Half is enough to do.",
            "You stopped the sound. You did not stop the thing. It is already in you, listening.",
            "Rude, %t. The dead have better manners here. They wait until the rite has left the air.",
        },

        -- Reactions -------------------------------------------------------

        ["REACT:LOWHEALTH"] = {
            "There is not much of me left standing here, and what is left has stopped believing fear.",
            "I have been closer to the ground than this. I climbed back up. I did not climb for bliss.",
            "The wound is honest. That is all I ask. Blood keeps no secrets and performs no task.",
            "Something of mine is leaving through the seam. I will not miss it. It was never clean.",
            "%t, I am not dead. I am adjacent. The dark and I are neighbours. We are patient.",
            "I have read this rite aloud for other men. I did not think I'd need the words again.",
        },

        ["REACT:DEATH"] = {
            "So this is it. The dark did not once lie. It named the day. It never said goodbye.",
            "I go down like a candle in a draught. I always thought that ending rather daft.",
            "Well. I have said this rite for other men. I did not think I'd need to hear it then.",
            "The Light steps back. The Shadow steps ahead. They have agreed on little. This they said.",
            "Down. And the ground is colder than the prayer. I will be back. I always end up there.",
            "The body stops. The verse does not. It stays, and finishes itself some other days.",
        },

        ["REACT:RESURRECT"] = {
            "Back. The dark unclenched and let me through. It rarely does. I wonder what it knew.",
            "I have returned, and something came with me. I will not name it. Naming makes it free.",
            "Alive again, and none the gentler for it. The grave is a poor teacher. I still bore it.",
            "Up from the cold. The cold was almost kind. I left a little of myself behind.",
        },

        ["REACT:KILLINGBLOW"] = {
            "That is the end of %t, and the end is plain. There will be nothing standing here again.",
            "Down, and the debt is settled where it stood. I did not want it. But the dark said good.",
            "It is finished. I say that far too well. A priest should not be practised at farewell.",
            "One less thing upright. One less thing that lied. The ground accepts them all. The ground is wide.",
            "Ash. And a name I will not say aloud. Names are for the living, and the proud.",
        },

        ["REACT:COMBATSTART"] = {
            "Come, then, %t. The verse has been rehearsed. Whatever happens now, you asked it first.",
            "The book is open at the darker page. I have been patient. Patience turns to rage.",
            "Something begins. It will not end in light. Take what you have. I will be here all night.",
            "You made a choice you are not going to unmake. I would advise a prayer, for your own sake.",
        },

        ["REACT:COMBATEND"] = {
            "It is over. The dark folds itself away, the way it always does, and does not stay.",
            "Quiet. And the quiet costs me more than any of the noise there was before.",
            "Done. I will count the dead and then the cost. I keep both lists. I have not one of them lost.",
            "The rite concludes. It always does conclude. That is the only mercy in the feud.",
        },

        ["REACT:LEVELUP"] = {
            "I am worse than I was, and better at it too. The dark has taught me one more thing to do.",
            "Something in me has deepened, not improved. The difference is a line I have not moved.",
            "Stronger. That word has never once meant well. It only means I have more left to tell.",
        },

        ["REACT:FALLING"] = {
            "The ground arrives with all its usual haste. I have not once enjoyed the way it tastes.",
            "Down. And the air declined to intervene. It is the emptiest thing I have ever seen.",
            "Gravity keeps no rite and says no prayer. It only ever finds you in the air.",
        },

        ["REACT:DROWNING"] = {
            "The water wants a word and I have none. I should have learned to swim. I should have run.",
            "It fills the place the prayer was meant to go. The dark at least is dry. I did not know.",
            "Down and down, and the light gets very thin. I have been drowning since before I sinned.",
        },

        ["REACT:DURABILITY"] = {
            "My robes are ruined and the seams have split. The man inside them matches, bit for bit.",
            "This armour has stopped arguing with the world. I sympathise. I also came unfurled.",
            "Everything I wear is coming apart. It is a slow rehearsal for the heart.",
        },

        ["IDLE:EAT"] = {
            "Bread. It is grey and it is mostly air. So am I, most mornings. We're a pair.",
            "I eat because the body makes me do it. The soul has never once been grateful to it.",
            "A meal. A small delay. A little stay. The dark is patient. It can wait a day.",
        },

        ["IDLE:DRINK"] = {
            "Water, and the taste of somewhere cold. I drink it slowly. I am getting old.",
            "Something to fill the place the prayer has been. It is not holy. Nor is it unclean.",
            "I drink, and something rises with the rest. I have stopped asking it to be a guest.",
        },

        ["IDLE:MOUNT"] = {
            "Up, and away from ground that knows my name. It will remember. Ground is always the same.",
            "I ride because the walking gives me time, and time is when the darker thoughts can climb.",
            "Carry me somewhere colder, if you please. I have grown tired of temperate disease.",
        },

        ["IDLE:QUESTACCEPT"] = {
            "Another errand for another man. I will do it badly, as I always can.",
            "Yes. I will go. I always say I will. The saying is the easy part. Be still.",
            "Give me the task and keep your gratitude. It spoils. The dark prefers a plainer mood.",
        },

        ["IDLE:QUEST"] = {
            "It is done. It is not good, but it is done. That is the only ending I have won.",
            "Here. Take it. I have done the thing you said. Do not ask what it cost, or who is dead.",
            "Finished. Pay me in silence, if you can. It is the only coin that helps a man.",
        },

        ["IDLE:DISCOVERY"] = {
            "A new place, and it is already grey. They always are. They always look this way.",
            "I have not been here. It has been here long. It does not care. That is its only song.",
            "Somewhere I have not ruined yet. Give me time. I ruin slowly. That is not a crime.",
        },

        -- Idle ------------------------------------------------------------

        ["IDLE:HEALTHSTONE"] = {
            "A stone of borrowed blood. I take it whole. It mends the body. It ignores the soul.",
            "Warmth from a thing that should not be so warm. I do not ask. I only weather storm.",
        },

        ["IDLE:MANAPOTION"] = {
            "Blue and bitter, and it does the trick. Everything useful tastes a little sick.",
            "I drink the light back into empty hands. They fill. They do not ask me their demands.",
        },

        ["IDLE:FISHING"] = {
            "The water keeps its dead and shows me none. I sit regardless, waiting on the sun.",
            "A line, a hook, a patience I have earned. Everything else I wanted, I have burned.",
        },

        ["IDLE:MINING"] = {
            "The rock gives up its metal, grain by grain. So do we all, eventually, in pain.",
            "I break the stone. The stone does not object. I like it more than most things I have wrecked.",
        },

        ["IDLE:HERBALISM"] = {
            "I take the leaf and leave the root to grieve. It will grow back. That is what roots believe.",
            "Something green, and I have use for green. It will be grey before the day has been.",
        },

        ["IDLE:SKINNING"] = {
            "The hide comes free. The body does not mind. It stopped objecting some way back behind.",
            "I take what the dead have no more use to keep. They do not stir. The dead are very deep.",
        },

        ["IDLE:CRAFT:Alchemy"] = {
            "Bottle the dark and cork it while it sleeps. Everything useful is a thing that creeps.",
            "Measure. Pour. Do not enquire too near. The best of my recipes end in fear.",
            "It bubbles. That is either good or grim. I have stopped drawing lines between the twin.",
        },

        ["IDLE:CRAFT:Blacksmithing"] = {
            "The iron softens when I ask it twice. Most things do. That is the whole device.",
            "Hammer and heat and the honest smell of char. It is the cleanest work there is, by far.",
        },

        ["IDLE:CRAFT:Cooking"] = {
            "I feed the living. It is what I do when there is nothing darker to pursue.",
            "Salt, and a fire, and something that was meat. The dead do not object to what we eat.",
        },

        ["IDLE:CRAFT:Enchanting"] = {
            "I take a thing apart to find its word, then say it back. The same, but this time heard.",
            "Dust of a sword that somebody once swung. He does not need it now. He has no tongue.",
        },

        ["IDLE:CRAFT:Engineering"] = {
            "It will explode. That is the general plan. I build them faster than I bury man.",
            "Cogs, and a fuse, and a very poor idea. Stand further back than that. Stand nowhere near.",
        },

        ["IDLE:CRAFT:First Aid"] = {
            "Cloth on a wound is honest, if it's slight. It does not promise. It just holds on tight.",
            "I bind it. I have bound so many now that binding is the only thing I vow.",
        },

        ["IDLE:CRAFT:Jewelcrafting"] = {
            "A stone that shines because it never grew. Cold things keep better. That is nothing new.",
            "I cut it small and let it hold the light. It will outlast the hand that wears it. Right.",
        },

        ["IDLE:CRAFT:Leatherworking"] = {
            "The hide remembers what it used to be. I stitch it into something it can't see.",
            "Thread through the dead. It is a decent trade. Everything useful is a thing unmade.",
        },

        ["IDLE:CRAFT:Tailoring"] = {
            "Cloth. And a needle. And a steady hand. I sew the way I pray: to no demand.",
            "A robe for someone who will die in it. They always do. I make them well to fit.",
        },

        ["IDLE:CRAFT:Smelting"] = {
            "Ore into metal. Rock into a blade. Everything gets simpler when it's made.",
            "The fire takes the stone and keeps the worth. It is the honest half of what's on earth.",
        },
    },
}
