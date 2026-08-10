-- RPVox -- core
-- Roleplay lines fired from combat, personal reactions, and idle activity.
--
-- Settings live in named profiles. Each character remembers which profile it
-- uses, so an Undead priest and a Gnome warrior can carry different voices.

local ADDON = "RPVox"

RPVox = {}                       -- shared namespace (core <-> UI)
RPVox.MELEE_KEY = "MELEE"

-- Tabs, in the order they appear. SPELL comes first because it is the only
-- one you can add to or remove from, and keeping the editable list apart from
-- the fixed ones is what stops the window reading as a single long soup.
RPVox.CATEGORIES = { "SPELL", "MOMENT", "REACTION", "IDLE" }
RPVox.CATEGORY_NAME = {
    SPELL    = "Spells Override",
    MOMENT   = "Moments",
    REACTION = "Reactions",
    IDLE     = "Idle",
}

-- Combat log subevents grouped by trigger type ----------------------------
-- Melee is read straight off SWING_DAMAGE and SWING_MISSED, in the handler:
-- a swing is resolved the moment it is reported, so one row is both the
-- trigger and the outcome and there is nothing to group.
--
-- Casts are handled by UNIT_SPELLCAST_SUCCEEDED, which fires only once a cast
-- has actually gone off. UNIT_SPELLCAST_SENT fires on the keypress instead,
-- before the server has ruled on it, so it also fires when you are out of
-- range, have no target, are facing the wrong way or the target is immune --
-- and the character narrated a spell that never happened.
--
-- SENT was originally chosen because SendChatMessage requires a hardware
-- event, and the keypress was the only moment one existed. Lines have gone out
-- as addon messages since 4.4, and those carry no such rule, so the reason to
-- prefer speed over accuracy is gone. A cast with a cast time now speaks as it
-- lands rather than as it begins, which is also when the words make sense.
--
-- The combat log is still used for wand shots, which repeat on their own and
-- never send a fresh cast, and for the outcome of any cast that has lines
-- written for one. See the Outcomes section.
local SPELL_EVENTS = {
    RANGE_DAMAGE = true,
    RANGE_MISSED = true,
}

-- A single spell can produce several of these for one cast. Only the first
-- one inside this window counts, so a cast never fires two rolls.
local DEDUPE_WINDOW = 0.6

-- At most one chance roll per this many seconds, whatever caused it.
--
-- This was written against key mashing: presses used to speak directly, so a
-- key tapped while the ability was still on cooldown bought another roll, and
-- a 20% trigger fired nearly every time for anyone quick with their hands.
-- Nothing reaches a roll from a press any more -- every path into Fire is an
-- event the server has already confirmed -- so that is not what it is for.
--
-- What it does now is even out swing rate. Melee is rolled per swing, so a
-- dual-wielder with fast weapons would otherwise roll about twice as often as
-- someone holding a two-hander and be twice as talkative for the same setting.
local ROLL_THROTTLE = 1.5

-- Group content is not the place for this. A raid gets nothing at all, and a
-- five-man is capped hard however high the trigger is set, because people are
-- reading the chat for pulls and marks. Deliberately not a setting: the point
-- is that nobody has to remember to turn it down before going in.
local DUNGEON_MAX_CHANCE = 1     -- per cent, absolute ceiling in a 5-man

local SEED_VERSION   = 17 -- bump to offer a fresh set of stock lines
local LINE_VERSION   = 2   -- bump to rewrite saved lines in place

-- Bump to hand every existing profile the outcome lines written since the last
-- bump. Append-only and safe, unlike SEED_VERSION -- see AddOutcomeLines.
local OUTCOME_LINE_VERSION = 1

-- Bump to sweep near-duplicate lines out of every saved profile once. See
-- TrimNearDuplicates for what counts as a duplicate and what is kept.
local TRIM_VERSION = 1

-- Saved lines you have edited are never reseeded, so syntax changes have to be
-- applied to them directly. Runs once per bump of LINE_VERSION.
local LINE_REPAIRS = {
    ["%h percent of a body I did not want anyway."] =
        "Barely a body left, and I did not want it anyway.",
    ["Down to %h percent. Still standing."] =
        "Down to the last of it. Still standing.",
    ["Back at %h percent and unimpressed."] =
        "Back on my feet and unimpressed.",
}

-- Is this saved line an emote? Both the "/em ..." form and the older "*..."
-- marker count. Emotes were removed from every pack in 4.2.1, but a profile
-- seeded before that still had hundreds sitting in saved variables, where no
-- amount of reseeding would reach the ones you had edited.
local function IsEmote(line)
    return line:sub(1, 1) == "*"
        or line:match("^/em%s") ~= nil
        or line:match("^/emote%s") ~= nil
end

local function RepairLines(profile)
    for _, t in ipairs(profile.triggers or {}) do
        local out = {}
        for _, w in ipairs(t.words or {}) do
            local fixed = LINE_REPAIRS[w] or w

            -- %h never worked; drop any line still carrying it.
            -- Emotes are gone from the addon entirely.
            if not fixed:find("%%h") and not IsEmote(fixed) then
                table.insert(out, fixed)
            end
        end
        t.words = out
    end
end

-- Built-in triggers -------------------------------------------------------
-- Metadata only; the sayings themselves live in RPVoxLines.lua.

local BUILTIN = {
    -- Combat -------------------------------------------------------------
    -- Five moments, not one per spell. What varies inside them -- crit, miss,
    -- resist -- is written as an outcome tag on the line, so a class needs one
    -- set of lines here rather than seventy-five.
    { key = "MELEE", category = "MOMENT", name = "Melee attacks",
      icon = "Interface\Icons\INV_Sword_04", weight = 1 },
    -- Hit, crit and miss are three entries rather than one entry with tagged
    -- lines inside it. The tag mechanism still exists and still works, but for
    -- the moment people write the most lines for, three rows you can see beats
    -- markup you have to know about.
    --
    -- Weight stays 1 on all three: OUTCOME_WEIGHT already makes a crit speak
    -- three times as readily as a routine hit, and putting that in both places
    -- would multiply it twice.
    { key = "COMBAT:SPELL:HIT", category = "MOMENT", name = "A spell hits",
      icon = "Interface\Icons\Spell_Fire_FlameBolt", weight = 1 },
    { key = "COMBAT:SPELL:CRIT", category = "MOMENT", name = "A spell crits",
      icon = "Interface\Icons\Spell_Fire_Fireball02", weight = 1 },
    { key = "COMBAT:SPELL:MISS", category = "MOMENT", name = "A spell misses",
      icon = "Interface\Icons\Ability_Rogue_FeignDeath", weight = 1 },
    { key = "COMBAT:HEAL", category = "MOMENT", name = "You heal someone",
      icon = "Interface\Icons\Spell_Holy_Heal", weight = 1 },
    { key = "COMBAT:BUFF", category = "MOMENT", name = "You buff or shield someone",
      icon = "Interface\Icons\Spell_Holy_PowerWordShield", weight = 4 },
    { key = "COMBAT:CC", category = "MOMENT", name = "You control something",
      icon = "Interface\Icons\Spell_Nature_Polymorph", weight = 3 },

    -- Reactions ---------------------------------------------------------
    { key = "REACT:LOWHEALTH", category = "REACTION", name = "Badly wounded (below 25%)",
      icon = "Interface\Icons\Ability_Creature_Cursed_02", weight = 0.3 },
    { key = "REACT:DEATH", category = "REACTION", name = "You die",
      icon = "Interface\Icons\Ability_Rogue_FeignDeath", weight = 0.5 },
    { key = "REACT:RESURRECT", category = "REACTION", name = "You return to life",
      icon = "Interface\Icons\Spell_Holy_Resurrection", weight = 0.3 },
    { key = "REACT:KILLINGBLOW", category = "REACTION", name = "You land a killing blow",
      icon = "Interface\Icons\Ability_Warrior_Riposte", weight = 0.05 },
    { key = "REACT:COMBATSTART", category = "REACTION", name = "You enter combat",
      icon = "Interface\Icons\Ability_DualWield", weight = 0.05 },
    { key = "REACT:COMBATEND", category = "REACTION", name = "You leave combat",
      icon = "Interface\Icons\Spell_Nature_Sleep", weight = 0.05 },
    { key = "REACT:INTERRUPTED", category = "MOMENT", name = "Your cast is interrupted",
      icon = "Interface\Icons\Spell_Frost_IceShock", weight = 0.2 },
    { key = "REACT:LEVELUP", category = "REACTION", name = "You gain a level",
      icon = "Interface\Icons\Spell_Nature_EnchantArmor", weight = 5 },
    { key = "REACT:FALLING", category = "REACTION", name = "You take falling damage",
      icon = "Interface\Icons\Ability_Rogue_Sprint", weight = 1.5 },
    { key = "REACT:DROWNING", category = "REACTION", name = "You are drowning",
      icon = "Interface\Icons\Spell_Shadow_DemonBreath", weight = 2 },
    { key = "REACT:DURABILITY", category = "REACTION", name = "Your gear is nearly broken",
      icon = "Interface\Icons\INV_Hammer_20", weight = 2.5 },

    -- Idle --------------------------------------------------------------
    { key = "IDLE:EAT", category = "REACTION", name = "Eating",
      icon = "Interface\Icons\INV_Misc_Food_15", weight = 0.2 },
    { key = "IDLE:DRINK", category = "REACTION", name = "Drinking",
      icon = "Interface\Icons\INV_Drink_07", weight = 0.2 },
    { key = "IDLE:HEALTHSTONE", category = "IDLE", name = "Healthstone / healing potion",
      icon = "Interface\Icons\INV_Stone_04", weight = 0.3 },
    { key = "IDLE:MANAPOTION", category = "IDLE", name = "Mana potion",
      icon = "Interface\Icons\INV_Potion_76", weight = 0.2 },
    { key = "IDLE:FISHING", category = "IDLE", name = "Fishing",
      icon = "Interface\Icons\Trade_Fishing", weight = 0.05 },
    { key = "IDLE:MINING", category = "IDLE", name = "Mining",
      icon = "Interface\Icons\Trade_Mining", weight = 0.05 },
    { key = "IDLE:HERBALISM", category = "IDLE", name = "Herb gathering",
      icon = "Interface\Icons\Trade_Herbalism", weight = 0.05 },
    { key = "IDLE:SKINNING", category = "IDLE", name = "Skinning",
      icon = "Interface\Icons\INV_Misc_Pelt_Wolf_01", weight = 0.05 },
    { key = "IDLE:MOUNT", category = "REACTION", name = "Mounting up",
      icon = "Interface\Icons\Ability_Mount_RidingHorse", weight = 0.3 },
    { key = "IDLE:QUESTACCEPT", category = "REACTION", name = "Accepting a quest",
      icon = "Interface\Icons\INV_Misc_Note_02", weight = 0.5 },
    { key = "IDLE:QUEST", category = "REACTION", name = "Turning in a quest",
      icon = "Interface\Icons\INV_Misc_Note_01", weight = 0.5 },
    { key = "IDLE:DISCOVERY", category = "REACTION", name = "Discovering a new place",
      icon = "Interface\Icons\INV_Misc_Map_01", weight = 2.5 },
}

local PROFESSIONS = {
    { "Alchemy",        "Interface\\Icons\\Trade_Alchemy" },
    { "Blacksmithing",  "Interface\\Icons\\Trade_BlackSmithing" },
    { "Cooking",        "Interface\\Icons\\INV_Misc_Food_15" },
    { "Enchanting",     "Interface\\Icons\\Trade_Engraving" },
    { "Engineering",    "Interface\\Icons\\Trade_Engineering" },
    { "First Aid",      "Interface\\Icons\\Spell_Holy_SealOfSacrifice" },
    { "Jewelcrafting",  "Interface\\Icons\\INV_Misc_Gem_01" },
    { "Leatherworking", "Interface\\Icons\\Trade_LeatherWorking" },
    { "Tailoring",      "Interface\\Icons\\Trade_Tailoring" },
    { "Smelting",       "Interface\\Icons\\Spell_Fire_FlameBlades" },
}

for _, p in ipairs(PROFESSIONS) do
    table.insert(BUILTIN, {
        key = "IDLE:CRAFT:" .. p[1], category = "IDLE",
        name = p[1], icon = p[2], weight = 0.1, craftLine = p[1],
    })
end

-- Class packs -------------------------------------------------------------
-- RPVox_CLASSES (see RPVoxClasses.lua) supplies each class its own
-- abilities and its own voice. A profile remembers which pack it was built
-- from, so its lines and its spell list both follow that class.

local function ClassPack(profile)
    local key = profile and profile.class
    return key and RPVox_CLASSES and RPVox_CLASSES[key] or nil
end

-- Which of the game's classes a pack is written for. Usually that is the key
-- itself, but a pack can serve a class under a different key -- PRIEST_RHYMING
-- is still for priests -- and says so with its own `class` field. Only the
-- "is this profile on the right character" checks use this; mood packs still
-- scope on profile.class, so an alternate pack stays clear of the stock moods.
local function PackClass(key)
    local pack = key and RPVox_CLASSES and RPVox_CLASSES[key]
    return (pack and pack.class) or key
end

-- Assigned further down, after the tag parser it depends on. Declared here so
-- StockLines below can close over it: the value is read when StockLines runs,
-- which is long after this file has finished loading.
local TrimNearDuplicates

-- Stock lines for a trigger = the class's own set (or the generic one), plus
-- every mood pack that applies, each line tagged with its mood as it is added.
-- Mood packs therefore stay plain text on disk and cost nothing to maintain.
local function StockLines(profile, key)
    local pack = ClassPack(profile)
    local base = (pack and pack.lines and pack.lines[key])
              or (RPVox_LINES and RPVox_LINES[key])

    local out = {}
    if base then
        for _, w in ipairs(base) do table.insert(out, w) end
    end

    if RPVox_MOOD_LINES then
        for moodKey, set in pairs(RPVox_MOOD_LINES) do
            local list = set[key]
            local applies = (set.class == nil) or (set.class == profile.class)
            if applies and type(list) == "table" then
                local tag = "[" .. (set.name or moodKey:lower()) .. "] "
                for _, w in ipairs(list) do table.insert(out, tag .. w) end
            end
        end
    end

    if #out == 0 then return nil end
    return (TrimNearDuplicates(out))
end

local function DefsFor(profile)
    local defs = {}
    for _, d in ipairs(BUILTIN) do table.insert(defs, d) end

    local pack = ClassPack(profile)
    if pack and pack.spells then
        for _, s in ipairs(pack.spells) do
            table.insert(defs, {
                key       = "SPELL:" .. s.spell,
                category  = "SPELL",
                name      = s.name or s.spell,
                spellName = s.spell,
                icon      = s.icon or "Interface\\Icons\\INV_Misc_QuestionMark",
                chance    = s.chance or 0.3,
            })
        end
    end
    return defs
end

function RPVox:ClassKeys()
    local out = {}
    if RPVox_CLASSES then
        for key in pairs(RPVox_CLASSES) do table.insert(out, key) end
    end
    table.sort(out, function(a, b)
        return (RPVox_CLASSES[a].name or a) < (RPVox_CLASSES[b].name or b)
    end)
    return out
end

function RPVox:ClassName(key)
    return RPVox_CLASSES and RPVox_CLASSES[key] and RPVox_CLASSES[key].name or key
end

-- Item-name matching for consumable triggers.
local ITEM_PATTERNS = {
    ["IDLE:HEALTHSTONE"] = { "healthstone", "healing potion", "health potion",
                             "rejuvenation potion", "bandage" },
    ["IDLE:MANAPOTION"]  = { "mana potion", "restore mana" },
}

local SPELLNAME_TRIGGERS = {
    ["fishing"]        = "IDLE:FISHING",
    ["mining"]         = "IDLE:MINING",
    ["herb gathering"] = "IDLE:HERBALISM",
    ["skinning"]       = "IDLE:SKINNING",
}

-- How talkative the character is, as one number for the whole profile. Per
-- trigger chances are gone: with seventy-five spell triggers competing for one
-- quiet gap, a spell set to 100% still did not speak on every cast, because
-- melee and every other spell were taking the window first. A number that
-- cannot keep its promise is worse than no number.
--
-- Below 1% is not offered either. The old scale ran to 0.01%, which is one line
-- in ten thousand swings -- indistinguishable from switched off, and several
-- triggers shipped down there by default.
local MIN_CHANCE     = 1
local MAX_CHANCE     = 100
local DEFAULT_CHANCE = 10
local DEFAULT_GLOBALCD = 5


-- State -------------------------------------------------------------------

local P                 -- active profile table
local playerGUID
local lastAnyCry = 0
local lastSeen   = {}   -- [spellName]  = GetTime()  (cast dedupe)
local lastRollAt = 0    -- GetTime() of the last chance roll, any trigger
local spellIndex = {}   -- [lowercase spell name] = trigger
local keyIndex   = {}   -- [trigger key]          = trigger
local meleeTrigger
local lowHealthArmed  = true
local durabilityArmed = true
local wasMounted      = false

local function Debug(...)
    if RPVoxDB and RPVoxDB.debug then
        print("|cff888888[RPVox]|r", ...)
    end
end
RPVox.Debug = Debug

-- Profiles ----------------------------------------------------------------

local function CharKey()
    local name  = UnitName("player") or "?"
    local realm = GetRealmName() or "?"
    return name .. " - " .. realm
end
RPVox.CharKey = function() return CharKey() end

function RPVox:Profile()
    return P
end

function RPVox:ProfileName()
    return RPVoxDB and RPVoxDB.activeProfile
end

function RPVox:ProfileNames()
    local out = {}
    for name in pairs(RPVoxDB.profiles) do table.insert(out, name) end
    table.sort(out)
    return out
end

-- Index -------------------------------------------------------------------

function RPVox:RebuildIndex()
    wipe(spellIndex)
    wipe(keyIndex)
    meleeTrigger = nil
    if not P then return end
    for _, t in ipairs(P.triggers) do
        keyIndex[t.key] = t
        if t.key == RPVox.MELEE_KEY then
            meleeTrigger = t
        elseif t.spellName then
            spellIndex[t.spellName:lower()] = t
        end
    end
end

function RPVox:GetTrigger(key)
    return keyIndex[key]
end

function RPVox:TriggersInCategory(category)
    local out = {}
    if not P then return out end
    for _, t in ipairs(P.triggers) do
        if (t.category or "MOMENT") == category then
            table.insert(out, t)
        end
    end
    return out
end

function RPVox:NewTrigger(spellName, icon)
    local t = {
        key       = "SPELL:" .. spellName,
        category  = "SPELL",
        name      = spellName,
        spellName = spellName,
        icon      = icon or "Interface\\Icons\\INV_Misc_QuestionMark",
        weight    = 1,
        channel   = "SAY",
        enabled   = true,
        words     = {},
    }
    table.insert(P.triggers, t)
    self:RebuildIndex()
    return t
end

function RPVox:FindTrigger(spellName)
    return spellIndex[spellName:lower()]
end

function RPVox:IsRemovable(trigger)
    return trigger and trigger.builtin ~= true
end

function RPVox:DeleteTrigger(trigger)
    if not self:IsRemovable(trigger) then return false end
    for i, t in ipairs(P.triggers) do
        if t == trigger then
            table.remove(P.triggers, i)
            break
        end
    end
    self:RebuildIndex()
    return true
end

-- Sending -----------------------------------------------------------------
-- Every line leaves as an addon message, and addon messages carry no
-- hardware-event rule. A line can be sent from wherever it was decided -- a
-- combat log event, a timer, anything -- and it goes out immediately.
--
-- This used to be a queue with an input gate in front of it. SendChatMessage
-- to a public channel is refused unless the call happens while the client is
-- processing real input, and the refusal is silent, so a line was held until
-- the next key, gamepad button or mouse press could carry it. That went when
-- public chat did: ForOutput has produced only VOXSAY and VOXEMOTE since 4.4,
-- so nothing RPVox says can be refused, and there was nothing left for the
-- gate to do but hook the keyboard. Restoring a public-chat mode means
-- restoring the gate with it.

-- Line syntax -------------------------------------------------------------
-- Say and emote are the only channels this addon will ever use. Yelling
-- carries across a zone and reads as spam to everyone who did not ask for it.
--
-- A line may start with a marker that overrides its channel:
--     *smiles thinly       -> sent as an emote
-- and may contain tokens that are filled in when it fires:
--     %t  your target's name      %s  your own name      %h  your health %
--
-- A line needing %t is skipped when you have no target, so nothing ever goes
-- out addressed to nobody.

RPVox.CHANNELS = { "SAY", "EMOTE" }

local function SafeChannel(channel)
    return (channel == "EMOTE") and "EMOTE" or "SAY"
end
RPVox.SafeChannel = function(_, c) return SafeChannel(c) end

-- Moods -------------------------------------------------------------------
-- A line may be tagged for a mood:  [grim] Nothing lasts.
-- Untagged lines always fit. Tagged ones are only eligible when that mood is
-- set, so one profile can carry several voices. Mood "Any" allows everything.

local function SplitMood(line)
    local mood, rest = line:match("^%[(%a[%w_ ]*)%]%s*(.*)$")
    if mood then return mood:lower(), rest end
    return nil, line
end
RPVox.SplitMood = function(_, line) return SplitMood(line) end

-- The other tag a line can carry is its outcome, "<crit>" and friends. The
-- rules for those are in the Outcomes section below; the parsing lives up here
-- because a mood tag and an outcome tag may be written in either order, so
-- anything reading one has to be able to step over the other.
local function SplitOutcome(line)
    local tag, rest = line:match("^<(%a+)>%s*(.*)$")
    if tag then return tag:lower(), rest end
    return nil, line
end

-- Take both tags off the front of a line and hand back what is left to say.
local function StripTags(line)
    local mood, rest = SplitMood(line)
    local outcome
    outcome, rest = SplitOutcome(rest)
    if not mood then mood, rest = SplitMood(rest) end
    return mood, outcome, rest
end
RPVox.StripTags = function(_, line) return StripTags(line) end

-- Near-duplicate lines -----------------------------------------------------
-- A line needing %t is skipped when you have no target, so every set was given
-- target-free variants -- and they were made by copying a line and deleting the
-- name off the end. Two lines that read identically apart from "Kobold" is what
-- a set full of them looks like from the editor, and it wastes half the list.
--
-- Two lines count as the same when they are the same with the target's name,
-- the colour tags and the emphasis markers taken out. The one that survives is
-- whichever came first, which in every pack is the version with the name in it.
--
-- A couple of target-free lines are kept regardless, because a set with none of
-- them goes silent whenever you have nothing selected -- which was the whole
-- reason the copies were made. Two is enough to never be silent and few enough
-- to never look repetitive.
local KEEP_TARGETLESS = 2

local function LineFingerprint(line)
    local _, _, body = StripTags(line)
    body = body:gsub("%b{}", "")            -- {fire} ... {/}
    body = body:gsub("[%*_~#%^]", "")       -- emphasis markers
    body = body:gsub("%%[ts]", "")          -- the names themselves
    body = body:gsub("[%p]", "")            -- punctuation left behind
    body = body:gsub("%s+", " ")
    return (body:lower():gsub("^%s+", ""):gsub("%s+$", ""))
end

function TrimNearDuplicates(words)
    if type(words) ~= "table" then return words, 0 end
    local seen, out, targetless, dropped = {}, {}, 0, 0
    for _, w in ipairs(words) do
        local key  = LineFingerprint(w)
        local bare = not w:find("%%t")
        if not seen[key] then
            seen[key] = true
            table.insert(out, w)
            if bare then targetless = targetless + 1 end
        elseif bare and targetless < KEEP_TARGETLESS then
            -- Same words, but this is the copy that works with no target and
            -- the set does not have enough of those yet.
            targetless = targetless + 1
            table.insert(out, w)
        else
            dropped = dropped + 1
        end
    end
    return out, dropped
end
RPVox.TrimNearDuplicates = function(_, words) return TrimNearDuplicates(words) end


-- Moods offered for this profile: every tag actually present in its lines,
-- plus any the player has declared. Declaring one matters because of the
-- chicken and egg -- a mood you have not tagged anything with yet would never
-- appear in the list, so you could never select it to write lines for it.
function RPVox:MoodsInProfile(profile)
    profile = profile or P
    local seen, out = {}, {}
    if not profile then return out end
    for _, name in ipairs(profile.customMoods or {}) do
        local m = name:lower()
        if not seen[m] then seen[m] = true; table.insert(out, m) end
    end
    for _, t in ipairs(profile.triggers or {}) do
        for _, w in ipairs(t.words or {}) do
            local mood = StripTags(w)
            if mood and not seen[mood] then
                seen[mood] = true
                table.insert(out, mood)
            end
        end
    end
    table.sort(out)
    return out
end

-- A mood name has to survive being written as "[name] " in front of a line,
-- so it matches what SplitMood will accept back out again.
function RPVox:AddMood(profile, name)
    name = tostring(name or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then return nil, "Give the mood a name." end
    if not name:match("^%a[%w_ ]*$") then
        return nil, "Letters, numbers, spaces and underscores only, starting with a letter."
    end
    profile = profile or P
    profile.customMoods = profile.customMoods or {}
    for _, m in ipairs(profile.customMoods) do
        if m == name then return name end
    end
    table.insert(profile.customMoods, name)
    return name
end

function RPVox:RemoveMood(profile, name)
    profile = profile or P
    name = tostring(name or ""):lower()
    for i, m in ipairs(profile.customMoods or {}) do
        if m == name then table.remove(profile.customMoods, i) return true end
    end
    return false
end

function RPVox:SetMood(mood)
    if not P then return false end
    P.mood = (mood and mood ~= "" and mood:lower()) or nil
    return true
end

function RPVox:GetChance()
    return (P and P.chance) or DEFAULT_CHANCE
end

function RPVox:SetChance(v)
    if not P then return end
    v = tonumber(v) or DEFAULT_CHANCE
    P.chance = math.max(MIN_CHANCE, math.min(MAX_CHANCE, math.floor(v + 0.5)))
    return P.chance
end

RPVox.MIN_CHANCE = MIN_CHANCE
RPVox.MAX_CHANCE = MAX_CHANCE

function RPVox:GetMood()
    return P and P.mood
end

local function MoodFits(mood)
    if not mood then return true end          -- untagged: always fine
    local active = P and P.mood
    if not active then return true end        -- "Any": everything is eligible
    return mood == active
end

-- Outcomes ----------------------------------------------------------------
-- A line may also be tagged for how the blow landed:
--     <crit> Ash. Nothing but ash of you.
--     <miss> ... and it goes wide, as usual.
-- Untagged lines fit any outcome, so nothing written before this existed
-- changed meaning.
--
-- Where a trigger has lines written for what actually happened, those are the
-- only ones eligible. A crit line that merely joined the pile would come up
-- once in fifty and never read as a reaction to the crit.
--
-- Both tags may be used at once, in either order:
--     [grim] <miss> Even the fire has stopped listening.

-- What each outcome will accept, most specific first. An outcome always takes
-- its own tag; the rest are near misses that read the same way, so one <miss>
-- set covers dodges and parries unless you write for those separately.
local OUTCOME_ACCEPTS = {
    hit     = { "hit" },
    crit    = { "crit", "hit" },
    miss    = { "miss" },
    dodge   = { "dodge", "miss" },
    parry   = { "parry", "miss" },
    block   = { "block", "hit" },
    resist  = { "resist", "miss" },
    immune  = { "immune", "resist", "miss" },
    absorb  = { "absorb", "resist", "miss" },
    reflect = { "reflect", "miss" },
}
local NO_OUTCOME = {}   -- nil outcome accepts no tag at all, only plain lines

-- Not every landing is equally worth remarking on. A crit is the moment the
-- character would actually say something, so it is three times likelier to be
-- spoken than a routine hit -- which is the judgement the old per-spell chance
-- numbers were being used to approximate, made once and in one place.
local OUTCOME_WEIGHT = {
    hit = 1, crit = 3, miss = 1.5, dodge = 1.5, parry = 1.5,
    block = 1, resist = 2, immune = 2, absorb = 1.5, reflect = 3,
}
local function OutcomeWeight(outcome)
    return (outcome and OUTCOME_WEIGHT[outcome]) or 1
end

-- Which of the three spell moments a combat log row belongs to. A block still
-- landed, so it counts as a hit; everything else that did not connect -- a
-- dodge, a resist, an immunity -- is a miss, because nobody wants to write
-- three sets of lines for three ways of not hitting something.
local SPELL_MOMENT = {
    hit = "COMBAT:SPELL:HIT", block = "COMBAT:SPELL:HIT",
    crit = "COMBAT:SPELL:CRIT",
}
local function SpellMoment(outcome)
    return SPELL_MOMENT[outcome or "hit"] or "COMBAT:SPELL:MISS"
end

-- The combat log's missType is upper case and splits hairs finer than anyone
-- wants to write lines for.
local MISS_OUTCOMES = {
    MISS    = "miss",   DODGE  = "dodge",  PARRY  = "parry",
    BLOCK   = "block",  DEFLECT = "miss",  EVADE  = "miss",
    RESIST  = "resist", IMMUNE = "immune", ABSORB = "absorb",
    REFLECT = "reflect",
}

-- Does this trigger have anything written for a specific outcome? That alone
-- decides whether it waits for one: a spell with only untagged lines speaks
-- the moment the cast lands, exactly as it did before any of this existed.
local function HasOutcomeLines(trigger)
    for _, w in ipairs(trigger and trigger.words or {}) do
        -- The plain find first: this runs on every cast, over lists that reach
        -- a few hundred lines, and almost none of them have a tag to parse.
        if w:find("<", 1, true) and select(2, StripTags(w)) then return true end
    end
    return false
end
RPVox.HasOutcomeLines = function(_, trigger) return HasOutcomeLines(trigger) end

-- The line decides for itself: "/em ..." is an emote, anything else is said.
-- "*..." is still honoured for lines written before this rule existed.
local function SplitChannel(line)
    local body = line:match("^/em%s+(.*)$") or line:match("^/emote%s+(.*)$")
    if body then return body, "EMOTE" end

    if line:sub(1, 1) == "*" then
        return (line:sub(2):gsub("^%s+", "")), "EMOTE"
    end
    return line, "SAY"
end

-- The name that goes into %t, or nil if there is nobody worth naming.
-- You do not count: healing, shielding or buffing yourself leaves you
-- self-targeted, and a line addressed to your own character reads as nonsense.
-- Returning nil here makes every %t line ineligible, so the untargeted
-- fallbacks in each set are used instead.
local function TargetName()
    if not UnitExists("target") then return nil end
    if UnitIsUnit("target", "player") then return nil end
    return UnitName("target")
end

local function Expand(text)
    if not text:find("%%") then return text end
    text = text:gsub("%%t", TargetName() or "")
    text = text:gsub("%%s", UnitName("player") or "")
    return text
end

-- No-repeat memory: a line will not come up again until a good portion of the
-- list has been used. Keeps 100-line sets feeling as varied as they are.
local recent = {}   -- [trigger key] = { index, index, ... } most recent first

local function RememberedCount(total)
    if total <= 2 then return 0 end
    return math.min(10, math.floor(total / 2))
end

local function PickLine(trigger, outcome)
    local words = trigger.words
    local hasTarget = TargetName() ~= nil

    -- Everything that fits the current mood and has a target if it needs one,
    -- sorted by the outcome it was written for. `plain` is the untagged set:
    -- what gets used when nothing was written for what just happened.
    local plain, tagged = {}, {}
    for i, w in ipairs(words) do
        local mood, tag, body = StripTags(w)
        if MoodFits(mood) and (hasTarget or not body:find("%%t")) then
            if tag then
                tagged[tag] = tagged[tag] or {}
                table.insert(tagged[tag], i)
            else
                table.insert(plain, i)
            end
        end
    end

    -- Lines for this exact outcome first, then anything near enough to read
    -- the same way, then the untagged set. A line tagged for an outcome that
    -- did not happen is never eligible: <miss> must not fire on a hit.
    -- `usedTag` comes back with the line so /rpvox trace can say whether the
    -- crit lines were drawn from or it fell through to the untagged set.
    local eligible, usedTag
    for _, tag in ipairs(OUTCOME_ACCEPTS[outcome] or NO_OUTCOME) do
        if tagged[tag] and #tagged[tag] > 0 then
            eligible, usedTag = tagged[tag], tag
            break
        end
    end
    eligible = eligible or plain
    if #eligible == 0 then return nil end

    local seen = recent[trigger.key]
    if not seen then
        seen = {}
        recent[trigger.key] = seen
    end

    local keep = RememberedCount(#eligible)
    local fresh = {}
    for _, i in ipairs(eligible) do
        local stale = false
        for n = 1, math.min(keep, #seen) do
            if seen[n] == i then stale = true break end
        end
        if not stale then table.insert(fresh, i) end
    end
    if #fresh == 0 then fresh = eligible end   -- everything is stale; reset

    local index = fresh[math.random(#fresh)]
    table.insert(seen, 1, index)
    while #seen > keep do table.remove(seen) end

    return words[index], usedTag
end

-- Everything RPVox says goes to other RPVox users and nothing else. There is
-- no public-chat mode: it existed briefly, and having two answers to "who can
-- hear me" was worse than having one. This only decides whether the receiving
-- side renders the line as speech or as an action.
local function ForOutput(msg, channel)
    return msg, (channel == "EMOTE") and "VOXEMOTE" or "VOXSAY"
end

-- Used by the Test line button so a preview matches what would really be said.
function RPVox:PreviewLine(trigger)
    local raw = PickLine(trigger)
    if not raw then return nil end
    local _, _, body = StripTags(raw)
    local msg, channel = SplitChannel(body)
    return ForOutput(Expand(msg), channel)
end

-- Output mode --------------------------------------------------------------
-- output = "VOX" sends each line as an addon message with SAY distribution.
-- The server range-limits that exactly as it does /say, so only players who
-- are actually nearby receive it -- and because it is an addon message it
-- never appears in public chat. Their copy of RPVox prints it locally.
--
-- The trade is that only people running RPVox see anything at all. A custom
-- chat channel was tried first and abandoned: channels are realm-wide and
-- have no concept of distance, which is the opposite of what roleplay needs.
--
-- output = "PUBLIC" is the original behaviour: real /say and /em, which
-- everybody nearby can read whether they run the addon or not.
RPVox.VOX_CHANNEL = "nearby"
local ADDON_PREFIX = "RPVox"

do
    local reg = (C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix)
             or RegisterAddonMessagePrefix
    if reg then pcall(reg, ADDON_PREFIX) end
end

-- Addon messages are not subject to the hardware-event rule that governs
-- SendChatMessage, so this path cannot be silently refused.
local function SendAddonRaw(payload, dist)
    local send = (C_ChatInfo and C_ChatInfo.SendAddonMessage) or SendAddonMessage
    if not send then return false end
    return pcall(send, ADDON_PREFIX, payload, dist)
end

local function SendAddon(payload)
    return SendAddonRaw(payload, "SAY")
end

RPVox.SendAddonRaw = function(_, payload, dist) return SendAddonRaw(payload, dist) end
RPVox.AddonPrefix  = ADDON_PREFIX

-- A hard ceiling on outgoing addon messages, below every setting in the UI.
--
-- The chance slider and the global gap are the player's to set, and a player
-- who sets 100% and a 0s gap and then mashes a spell can push roughly one
-- message every ROLL_THROTTLE seconds indefinitely. The server treats sustained
-- addon chatter as flooding and disconnects for it. No configuration should be
-- able to get someone kicked, so sends are limited here, where the sliders
-- cannot reach: never two within MIN_SEND_GAP, and never more than BURST_MAX
-- inside BURST_WINDOW.
local MIN_SEND_GAP = 1.5
local BURST_WINDOW = 10
local BURST_MAX    = 4
local sendTimes    = {}

local function MaySend()
    local now = GetTime()
    for i = #sendTimes, 1, -1 do
        if now - sendTimes[i] > BURST_WINDOW then table.remove(sendTimes, i) end
    end
    if #sendTimes > 0 and now - sendTimes[#sendTimes] < MIN_SEND_GAP then
        return false, "too soon after the last line"
    end
    if #sendTimes >= BURST_MAX then
        return false, ("%d lines in %ds already"):format(BURST_MAX, BURST_WINDOW)
    end
    sendTimes[#sendTimes + 1] = now
    return true
end

-- Every line leaves through here.
local function RawSend(msg, channel)
    if channel == "VOXSAY" or channel == "VOXEMOTE" then
        local allowed, why = MaySend()
        if not allowed then
            Debug("rate limit: dropped line --", why)
            return false
        end
        local kind = (channel == "VOXEMOTE") and "E" or "S"
        local ok, err = SendAddon(kind .. "|" .. msg)
        -- Your own bubble is raised here rather than on receipt, so it does
        -- not depend on the client echoing our own addon messages back to us.
        --
        -- pcall, and not for tidiness: this is the one function every line
        -- passes through. An error raised in the bubble would unwind out of
        -- here and the line would never be spoken -- and WoW hides Lua errors
        -- by default, so it would look like the addon had simply gone quiet.
        -- Speech is the product; the bubble is decoration and must never be
        -- able to take speech down with it.
        if ok and RPVox.Bubble then
            local shown, bubbleErr = pcall(RPVox.Bubble.Show, RPVox.Bubble, msg)
            if not shown then
                Debug("bubble failed:", tostring(bubbleErr))
            end
        end
        return ok, err
    end
    return pcall(SendChatMessage, msg, channel)
end

-- Receiving. Tagged so it is never mistaken for real /say: this is a line an
-- addon chose, not something the player typed, and readers should be able to
-- tell at a glance.
-- The whole line is coloured, not just the tag. White text reading
-- "Name says: ..." is indistinguishable from real /say at a glance.
-- Parchment, because it reads as speech rather than as a system notice. Cyan
-- was distinct but cold and the eye skipped it. A near-white cream failed for
-- the opposite reason: on a dark chat background luminance, not hue, is what
-- separates colours, so anything that bright reads as /say however warm its
-- tint. Hence brightness pulled down as well as blue. Still clear of the rest
-- of default chat: yell red, whisper pink, party lavender, raid orange,
-- guild green, emote orange, channels and system yellow.
local RP_TAG   = "|cffedd994[RP]|r "
local RP_R, RP_G, RP_B = 0.93, 0.85, 0.58     -- parchment
local EM_R, EM_G, EM_B = 0.76, 0.69, 0.46     -- the same hue, dimmer

-- Emphasis markers (*loud* _quiet_ ~wavy~ #shaky# ^tall^) mean something to the
-- bubble and nothing to the chat frame, which renders colour and no more.
-- Strip them on the way to chat so the punctuation never shows up raw.
local function Plain(text)
    if RPVox.StripMarkup then return RPVox:StripMarkup(text) end
    text = text:gsub("^{%a+}%s*", "")
    return (text:gsub("[%*_~#%^]", ""))
end

local rx = CreateFrame("Frame")
rx:RegisterEvent("CHAT_MSG_ADDON")
rx:SetScript("OnEvent", function(_, _, prefix, payload, dist, sender)
    if prefix ~= ADDON_PREFIX or type(payload) ~= "string" then return end
    local kind, text = payload:match("^(%a)|(.*)$")
    if not kind or text == "" then return end
    -- The realm suffix stays on: this is the bubble's key, and the plate
    -- side builds the same shape from UnitName's two returns. Stripping it
    -- here is why a cross-realm speaker's bubble could never find their
    -- nameplate -- and on a pooled anniversary cluster, most of the people
    -- around you are cross-realm. Chat still shows the bare name.
    local name  = (Ambiguate and Ambiguate(sender, "none")) or sender
    local short = name:match("^[^-]+") or name

    -- Diagnostic pings always print, whatever the debug setting.
    if kind == "T" then
        local sentOver, who = text:match("^([^|]+)|(.*)$")
        print(("|cff00ff00RPVox nettest:|r got a ping from |cffffff00%s|r"
            .. " sent over %s, arrived as %s")
            :format(who or name, sentOver or "?", tostring(dist)))
        return
    end
    Debug("received", kind, "from", name, "over", tostring(dist))

    -- A bubble for whoever said it, alongside the chat line. The chat frame is
    -- the durable record and works when they are behind you; the bubble is
    -- what makes it feel like somebody talking.
    --
    -- Not for your own lines. Yours is raised at send time, and the server
    -- hands your own SAY addon messages back to you, so without this test
    -- every line you spoke would appear twice.
    --
    -- pcall for the same reason as at the send end: the bubble is decoration
    -- and must never be able to take the chat line down with it.
    --
    -- `text` still has its markup. That belongs to the speaker and is most of
    -- what makes the line sound like them, so it is passed on untouched -- it
    -- is only the chat frame, which renders colour and nothing else, that
    -- needs Plain().
    if name ~= UnitName("player") and RPVox.Bubble then
        local shown, err = pcall(RPVox.Bubble.ShowFrom, RPVox.Bubble, name, text)
        if not shown then Debug("bubble from", name, "failed:", tostring(err)) end
    end

    if kind == "E" then
        -- Stock lines carry no emotes any more, but a player can still write
        -- one in the line editor, so the path stays.
        DEFAULT_CHAT_FRAME:AddMessage(RP_TAG .. short .. " " .. Plain(text),
                                      EM_R, EM_G, EM_B)
    else
        DEFAULT_CHAT_FRAME:AddMessage(RP_TAG .. short .. " says: " .. Plain(text),
                                      RP_R, RP_G, RP_B)
    end
end)

-- Say it now. There is nothing to wait for: an addon message cannot be
-- refused, so a line either goes out here or was stopped by the rate limiter
-- inside RawSend, which says so in the debug log.
local function Say(msg, channel)
    local ok, err = RawSend(msg, channel)
    if ok then
        Debug("sent:", msg)
    elseif err then
        print("|cffff0000RPVox:|r could not send -- " .. tostring(err))
    end
    return ok
end

-- Watching the button press -----------------------------------------------
-- These hooks used to speak. They existed because SendChatMessage needs a
-- hardware event, and code running inside UseAction is still within the input
-- the client accepts -- so the press was the only moment a line could go out.
--
-- That is no longer true, and keeping it was a bug: a button press is not a
-- cast. UseAction fires with no target, out of range, facing the wrong way,
-- while the spell is on cooldown, and when the cast is refused outright, so
-- the character narrated spells that never happened. Lines have travelled as
-- addon messages since 4.4, which carry no hardware-event rule, and
-- UNIT_SPELLCAST_SUCCEEDED tells us the cast actually landed.
--
-- The hooks stay as a debug trace only: seeing the press and the landing as
-- two separate lines is what makes a missing cast obvious.
--
-- Declared here as a forward local; the hooks are installed after Fire exists.
local InstallActionHooks

do
    local function TriggerForSpellID(spellID)
        local name = GetSpellInfo(spellID)
        if type(name) ~= "string" then return nil end
        return spellIndex[name:lower()], name
    end

    local function TriggerForSpellName(name)
        if type(name) ~= "string" then return nil end
        -- strip any rank suffix, e.g. "Fireball(Rank 4)"
        name = name:match("^([^%(]+)") or name
        name = name:gsub("%s+$", "")
        return spellIndex[name:lower()], name
    end

    InstallActionHooks = function(fire)
        -- Deliberately does not call `fire`. See the note above: a press is
        -- not a cast, and speaking here is what made lines go out for casts
        -- that never happened. The trace is kept so /rpvox debug shows the
        -- press and the landing separately.
        local function attempt(trigger, name)
            if not trigger or not name then return end
            Debug("action used |", name, "-- press seen, waiting for the cast")
        end

        hooksecurefunc("UseAction", function(slot)
            local kind, id = GetActionInfo(slot)
            if kind == "spell" and id then
                attempt(TriggerForSpellID(id))
            elseif kind == "macro" and id then
                -- macros resolve to whatever spell they are about to cast
                local spellName = GetMacroSpell and GetMacroSpell(id)
                if spellName then attempt(TriggerForSpellName(spellName)) end
            end
        end)

        if CastSpellByName then
            hooksecurefunc("CastSpellByName", function(name)
                attempt(TriggerForSpellName(name))
            end)
        end
        if CastSpellByID then
            hooksecurefunc("CastSpellByID", function(id)
                attempt(TriggerForSpellID(id))
            end)
        end
    end
end

-- There is no input gate here any more. It watched the keyboard, gamepad
-- buttons, WorldFrame and every global mouse press purely to find a hardware
-- event to send a held line from, and no line needs one. See the note above
-- Sending.

-- Firing ------------------------------------------------------------------
-- Moments do not happen at the same rate, so one flat number cannot govern
-- them all: melee swings arrive twenty-five times a minute and a level-up once
-- in an evening. Each trigger carries a weight, shipped with the addon rather
-- than exposed as forty-five sliders, and the profile's one number is scaled by
-- it. Weight 1 means "as often as the slider says".
local function WeightedChance(trigger, outcome)
    local base = math.max(MIN_CHANCE, math.min(MAX_CHANCE, (P and P.chance) or DEFAULT_CHANCE))
    return base * (trigger.weight or 1) * OutcomeWeight(outcome)
end


-- `outcome` is how the blow landed -- "crit", "miss", "resist" and so on, or
-- nil when the trigger has no such thing (a buff, a level-up, a quest turn-in).
-- It only decides which lines are eligible; everything else here is the same
-- whatever happened. See the Outcomes section.
-- Why a trigger did or did not speak ---------------------------------------
-- Every chance in this addon sits behind three other limits, and when a
-- trigger set to 100% still goes quiet the question is always which one caught
-- it. Reading that off the debug stream means catching the moment it happens;
-- this counts instead, so /rpvox why can answer afterwards.
local stats = {}

local REASON_TEXT = {
    spoke    = "spoke",
    quiet    = "inside the quiet gap since the last line",
    throttle = "another roll had just happened",
    roll     = "lost the chance roll",
    nothing  = "no line was eligible (target, mood or outcome)",
    ceiling  = "stopped by the flood ceiling below the settings",
    group    = "raid or dungeon rules",
    off      = "switched off or unticked",
    nolines  = "no lines written for it",
}

local function Note(trigger, reason)
    if not trigger or not trigger.key then return end
    local s = stats[trigger.key]
    if not s then
        s = { name = trigger.name or trigger.key, tried = 0 }
        stats[trigger.key] = s
    end
    s.name  = trigger.name or s.name
    s.tried = s.tried + 1
    s[reason] = (s[reason] or 0) + 1
end

function RPVox:Why(arg)
    if arg == "reset" then
        stats = {}
        print("|cff00ff00RPVox:|r counts cleared.")
        return
    end

    local rows = {}
    for _, s in pairs(stats) do table.insert(rows, s) end
    table.sort(rows, function(a, b) return a.tried > b.tried end)

    if #rows == 0 then
        print("|cff00ff00RPVox:|r nothing has tried to speak yet. Go and "
            .. "fight something, then ask again.")
        return
    end

    print("|cff00ff00RPVox|r -- what happened to each trigger "
        .. "|cff888888(quiet gap is " .. tostring(P and P.globalCooldown or "?")
        .. "s)|r")
    for i = 1, math.min(#rows, 8) do
        local s = rows[i]
        print(("  |cffffd100%s|r  %d attempts, |cff00ff00%d spoke|r")
            :format(tostring(s.name), s.tried, s.spoke or 0))
        for reason, text in pairs(REASON_TEXT) do
            if reason ~= "spoke" and s[reason] then
                print(("      %d  %s"):format(s[reason], text))
            end
        end
    end
    print("  |cffffd100/rpvox why reset|r to start counting again.")
end

local function Fire(trigger, outcome)
    -- In trace the point is to account for every action, so the reasons that
    -- normally only whisper to the debug log are said out loud. Silence in a
    -- trace should mean the event never happened, never that it was dropped.
    local tracing = RPVoxDB and RPVoxDB.trace
    local function TraceSkip(what, why)
        if tracing then
            print(("|cff888888[trace]|r %s |cffff8800skipped|r -- %s")
                :format(tostring(what), why))
        end
    end

    if not P or not P.enabled then
        Debug("skip: profile disabled")
        TraceSkip("everything", "this profile is switched off (/rpvox on)")
        return
    end
    if not trigger then return end
    if trigger.enabled == false then
        Debug("skip:", trigger.name, "is unticked")
        TraceSkip(trigger.name, "unticked in the settings window")
        Note(trigger, "off")
        return
    end

    local words = trigger.words
    if not words or #words == 0 then
        Debug("skip:", trigger.name, "has no lines")
        TraceSkip(trigger.name, "no lines written for it")
        Note(trigger, "nolines")
        return
    end

    local now = GetTime()

    -- Trace mode, /rpvox trace. Everything below that exists to make RPVox
    -- speak rarely is skipped, and the line is printed to your own chat frame
    -- instead of being sent. At a 0.3% chance behind a 5s gap you could play
    -- for an hour without seeing whether a <crit> line works; this shows the
    -- decision for every swing and every cast, and nobody else hears a word.

    -- One gap to rule them all: nothing may be said until this has elapsed
    -- since the last line, whichever trigger produced it.
    local wait = (P.globalCooldown or 0) - (now - lastAnyCry)
    if wait > 0 and not tracing then
        Debug(("skip: still quiet for %.0fs"):format(wait))
        Note(trigger, "quiet")
        return
    end

    -- Where you are outranks what the slider says. See DUNGEON_MAX_CHANCE.
    local chance = WeightedChance(trigger, outcome)
    if not tracing then
        if IsInRaid and IsInRaid() then
            Debug("skip: in a raid group -- RPVox stays quiet")
            Note(trigger, "group")
            return
        end
        local inInstance, kind = IsInInstance()
        if inInstance then
            if kind == "raid" then
                Debug("skip: inside a raid -- RPVox stays quiet")
                Note(trigger, "group")
                return
            elseif kind == "party" and chance > DUNGEON_MAX_CHANCE then
                Debug(("dungeon: chance capped %.2f -> %.2f")
                    :format(chance, DUNGEON_MAX_CHANCE))
                chance = DUNGEON_MAX_CHANCE
            end
        end

        -- One roll per swing rate. See ROLL_THROTTLE.
        if now - lastRollAt < ROLL_THROTTLE then
            Debug("skip: already rolled within", ROLL_THROTTLE, "seconds")
            Note(trigger, "throttle")
            return
        end
        lastRollAt = now

        local roll = math.random() * 100
        if roll >= chance then
            Debug(("skip: %s rolled %.2f, needed under %.2f")
                :format(trigger.name, roll, chance))
            Note(trigger, "roll")
            return
        end
    end

    local raw, usedTag = PickLine(trigger, outcome)
    if not raw then
        if tracing then
            -- tostring, because this is 5.1: string.format("%s", nil) is an
            -- error here, not the word "nil", and an unnamed trigger would
            -- take the whole handler down mid-fight.
            print(("|cff888888[trace]|r %s |cffff8800%s|r -- nothing eligible")
                :format(tostring(trigger.name), outcome or "no outcome"))
        end
        Debug("skip:", trigger.name,
              "-- nothing eligible (needs a target you do not have, or the",
              "mood or outcome rules out every line)")
        if not tracing then Note(trigger, "nothing") end
        return
    end

    local _, _, body = StripTags(raw)
    -- The line decides whether it is speech or an action; the profile decides
    -- where it goes and how an action is marked once it gets there.
    local msg, channel = SplitChannel(body)
    msg, channel = ForOutput(Expand(msg), channel)

    if tracing then
        -- The set drawn from is the point of the whole exercise: "crit" here
        -- means your <crit> lines were used, "untagged" means the outcome had
        -- nothing written for it and it fell back.
        print(("|cff888888[trace]|r %s |cffffff00%s|r from |cff00ff00%s|r: %s")
            :format(tostring(trigger.name), outcome or "no outcome",
                    usedTag and ("<" .. usedTag .. ">") or "untagged",
                    tostring(msg)))
        return
    end

    lastAnyCry = now
    Debug("FIRE:", trigger.name, outcome and ("(" .. outcome .. ")") or "",
          "->", channel, "->", msg)

    -- The flood ceiling lives below every setting and can still swallow a line
    -- that passed everything above it, so the two outcomes are counted apart.
    Note(trigger, Say(msg, channel) and "spoke" or "ceiling")
end

local function FireKey(key)
    Fire(keyIndex[key])
end

-- Waiting for an outcome ---------------------------------------------------
-- A spell with outcome lines does not speak when the cast lands. It speaks
-- when the combat log says what the spell did to whoever it was aimed at,
-- which for anything with travel time is a moment later -- and can still turn
-- out to be a miss, a resist or an immunity that the cast itself could not
-- have known about.
--
-- The cast arms; the first damage or miss row for that spell disarms it and
-- speaks. Every later row from the same cast -- the other four targets of a
-- Flamestrike, each tick of a channel -- finds nothing armed and is ignored,
-- so one cast is still one line however much it writes to the log.
--
-- Periodic rows are deliberately not watched at all. A DoT would otherwise
-- speak on every tick for the rest of its duration.
local OUTCOME_WINDOW = 3   -- seconds a cast waits before giving up
local armed  = {}          -- [spellName] = { trigger = t or nil, id = n }
local armSeq = 0

-- A cast arms and then waits to be told what it was.
--
-- The cast itself cannot say which moment it belongs to: "Frostbolt succeeded"
-- is true of a bolt that lands, one that is resisted, and one whose target died
-- in flight. The combat log knows, so the row that follows picks both the
-- trigger and the outcome -- damage means COMBAT:SPELL, a heal means
-- COMBAT:HEAL, a buff landing means COMBAT:BUFF, a debuff means COMBAT:CC.
--
-- `trigger` on the arm record is the per-spell override when one exists. When
-- it is nil the moment is whatever the row turns out to say.
--
-- Every later row from the same cast -- the other four targets of a
-- Flamestrike, each tick of a channel -- finds nothing armed and is ignored,
-- so one cast is still one line however much it writes to the log. Periodic
-- rows are not watched at all, or a DoT would talk through its whole duration.
local function ArmCast(spellName, trigger)
    armSeq = armSeq + 1
    local id = armSeq
    armed[spellName] = { trigger = trigger, id = id }
    Debug("armed |", spellName, trigger and "(override)" or "(moment)")

    -- C_Timer.After cannot be cancelled, so the timer checks that the cast it
    -- was started for is still the armed one. Without that, recasting inside
    -- the window would have the first cast's timer speak for the second.
    C_Timer.After(OUTCOME_WINDOW, function()
        local a = armed[spellName]
        if not a or a.id ~= id then return end
        armed[spellName] = nil
        if not a.trigger then
            -- No row ever came and there is no override to fall back on, so
            -- there is no moment to speak for. Blink and Evocation land here:
            -- they are casts, but they are not one of the five things this
            -- character has anything to say about.
            Debug("no outcome |", spellName, "-- not a moment, staying quiet")
            return
        end
        -- An override with no row: the target died in flight, or the spell
        -- does something the log does not report this way. Speak from its
        -- untagged lines rather than go silent over it.
        Debug("no outcome |", spellName, "-- speaking untagged")
        Fire(a.trigger, nil)
    end)
end

-- True if this row belonged to a cast that was waiting for it, in which case
-- it has now spoken. False means nothing was armed and the caller still owns
-- the row. `momentKey` is the trigger to use when the cast had no override.
local function ResolveOutcome(spellName, outcome, momentKey)
    local a = armed[spellName]
    if not a then return false end
    armed[spellName] = nil

    local trigger = a.trigger or (momentKey and keyIndex[momentKey])
    if not trigger then
        Debug("outcome |", spellName, "-- nothing to speak for it")
        return true
    end
    Debug("outcome |", spellName, "->", momentKey or trigger.key, outcome)
    Fire(trigger, outcome)
    return true
end

-- An aura is the weakest evidence of what a spell did, so it never resolves
-- straight away.
--
-- TBC Fireball is the case that forces this: it deals its damage *and* applies
-- a burn, so one cast writes both a SPELL_DAMAGE row and a SPELL_AURA_APPLIED
-- row at the same moment. Resolving on whichever landed first meant a crit was
-- routinely reported as a plain hit -- the aura row carries no critical flag,
-- so the crit lines could be skipped entirely for every spell that leaves a
-- mark. Pyroblast and Scorch have the same shape.
--
-- The aura therefore books a resolution a quarter second out and lets a damage
-- or miss row overtake it. Nothing is lost: Polymorph and the buffs, which
-- produce no damage row at all, still speak -- a quarter second later than
-- they used to, which is not perceptible against a line that takes a second to
-- type itself out.
local AURA_GRACE = 0.25

local function ResolveOnAura(spellName, momentKey)
    local a = armed[spellName]
    if not a or a.auraPending then return end
    a.auraPending = true
    local id = a.id
    Debug("aura |", spellName, "-- holding", AURA_GRACE, "s for a damage row")
    C_Timer.After(AURA_GRACE, function()
        local still = armed[spellName]
        if still and still.id == id then
            ResolveOutcome(spellName, "hit", momentKey)
        end
    end)
end

-- Now that Fire exists, let the action hooks call it.
InstallActionHooks(Fire)

RPVox.Fire = function(_, trigger) Fire(trigger) end

-- Matching helpers --------------------------------------------------------

local function MatchItemTrigger(name)
    if not name then return nil end
    name = name:lower()
    for key, patterns in pairs(ITEM_PATTERNS) do
        for _, p in ipairs(patterns) do
            if name:find(p, 1, true) then return key end
        end
    end
    return nil
end

-- Which profession window is open right now?
local function CurrentCraftLine()
    if TradeSkillFrame and TradeSkillFrame:IsShown() and GetTradeSkillLine then
        local line = GetTradeSkillLine()
        if line and line ~= "UNKNOWN" then return line end
    end
    -- TBC keeps Enchanting (and beast training) in the separate Craft frame
    if CraftFrame and CraftFrame:IsShown() and GetCraftName then
        local line = GetCraftName()
        if line and line ~= "" then return line end
    end
    return nil
end

-- Profile contents --------------------------------------------------------

local function EnsureBuiltins(profile, seeding, rebalancing)
    profile.triggers = profile.triggers or {}

    local have = {}
    for _, t in ipairs(profile.triggers) do
        have[t.key] = t
        t.seen = nil    -- cleared here, set below for anything still defined
    end

    for _, def in ipairs(DefsFor(profile)) do
        local stock = StockLines(profile, def.key)
        local t = have[def.key]
        if not t then
            t = {
                key     = def.key,
                words   = stock and CopyTable(stock) or {},
                weight  = def.weight,
                channel = "SAY",
                enabled = true,
            }
            table.insert(profile.triggers, t)
        end

        -- definition fields are code-owned; refresh them every load
        t.category  = def.category
        t.name      = def.name
        t.icon      = def.icon
        t.craftLine = def.craftLine
        t.spellName = def.spellName
        t.builtin   = true
        t.seen      = true
        t.weight = def.weight or 1     -- code owned, like name and icon
        if t.channel == nil then t.channel = "SAY"      end
        if t.words   == nil then t.words   = {}         end
        t.cooldown = nil   -- per-trigger gaps are gone; one global gap now

        -- Refresh stock lines on a seed bump, but never touch a list you have
        -- edited yourself (the UI stamps t.custom the moment you type in it).
        if seeding and stock and not t.custom then
            t.words = CopyTable(stock)
        end

        -- Per trigger chance is gone; the profile carries one number now.
        t.chance, t.chanceCustom = nil, nil
    end

    -- Drop stock triggers the addon no longer defines for this class. Without
    -- this a profile keeps every trigger it was ever seeded with -- spells from
    -- old builds, triggers that moved to another class -- and they sit there
    -- for ever, full of lines nothing will ever refresh. Triggers you made
    -- yourself are not builtin and are always kept.
    local kept, dropped = {}, 0
    for _, t in ipairs(profile.triggers) do
        if t.builtin and not t.seen then
            dropped = dropped + 1
        else
            t.seen = nil
            table.insert(kept, t)
        end
    end
    if dropped > 0 then
        profile.triggers = kept
        Debug("removed", dropped, "triggers this class no longer has")
    end

    for _, t in ipairs(profile.triggers) do
        -- "COMBAT" was one tab; it is now Moments and Spells Override. A
        -- built-in has already had its category refreshed from the definition
        -- above, so anything still saying COMBAT here is a spell somebody added
        -- themselves -- which belongs in the tab that can add and remove them.
        if t.category == nil or t.category == "COMBAT" then
            t.category = (t.key or ""):find("^SPELL:") and "SPELL" or "MOMENT"
        end
        t.cooldown = nil
        -- anything saved from an older build (YELL, PARTY) comes back to SAY
        t.channel = SafeChannel(t.channel)
        t.chance, t.chanceCustom = nil, nil
        if t.weight == nil then t.weight = 1 end
    end
end

-- Offering new stock lines to a profile that already exists ----------------
-- Seeding only ever fills a trigger a profile has never seen, and SEED_VERSION
-- cannot be bumped to push content: EnsureBuiltins seeds every profile in one
-- pass, so it would overwrite the stock voices as well. That left no way at all
-- to get a newly written line to anyone already playing.
--
-- This is that way, and it is deliberately narrow. It only ever **appends**,
-- and only lines carrying an outcome tag. Appending cannot destroy an edit, and
-- restricting it to outcome lines means it cannot resurrect a line somebody
-- deliberately deleted -- nobody has ever deleted a <crit> line, because until
-- now there were none to delete. `custom` is not consulted for the same reason:
-- there is nothing here to overwrite.
--
-- If this is ever widened past outcome lines, that reasoning stops holding.
local function AddOutcomeLines(profile)
    local added = 0
    for _, t in ipairs(profile.triggers or {}) do
        local stock = StockLines(profile, t.key)
        if stock then
            local have = {}
            for _, w in ipairs(t.words or {}) do have[w] = true end
            for _, w in ipairs(stock) do
                if not have[w] and w:find("<", 1, true)
                   and select(2, StripTags(w)) then
                    table.insert(t.words, w)
                    have[w] = true
                    added = added + 1
                end
            end
        end
    end
    if added > 0 then Debug("added", added, "outcome lines") end
    return added
end

-- Exposed so /rpvox rebuild can force a clean reseed of one profile.
function RPVox:Reseed(profile)
    EnsureBuiltins(profile, true, false)
    RepairLines(profile)
end

local function NewProfileTable()
    return {
        enabled       = true,
        chance        = DEFAULT_CHANCE,
        globalCooldown = DEFAULT_GLOBALCD,
        output        = "VOX",
        triggers      = {},
    }
end

function RPVox:CreateProfile(name, copyFrom, classKey)
    if not name or name == "" then return nil, "Name cannot be empty." end
    if RPVoxDB.profiles[name] then return nil, "That name is taken." end

    local p
    if copyFrom and RPVoxDB.profiles[copyFrom] then
        p = CopyTable(RPVoxDB.profiles[copyFrom])
    else
        p = NewProfileTable()
        p.class = classKey
        EnsureBuiltins(p, true, false)
    end
    RPVoxDB.profiles[name] = p
    return p
end

-- Build a profile straight from a class pack, named after the class unless
-- that name is taken.
function RPVox:CreateClassProfile(classKey)
    local base = self:ClassName(classKey)
    local name, n = base, 2
    while RPVoxDB.profiles[name] do
        name = base .. " " .. n
        n = n + 1
    end
    local p = self:CreateProfile(name, nil, classKey)
    return p and name or nil
end

function RPVox:DeleteProfile(name)
    if not RPVoxDB.profiles[name] then return false end
    local names = self:ProfileNames()
    if #names <= 1 then return false, "You need at least one profile." end

    RPVoxDB.profiles[name] = nil
    for char, prof in pairs(RPVoxDB.characters) do
        if prof == name then RPVoxDB.characters[char] = nil end
    end
    if RPVoxDB.activeProfile == name then
        self:UseProfile(self:ProfileNames()[1])
    end
    return true
end

function RPVox:RenameProfile(old, new)
    if not RPVoxDB.profiles[old] then return false end
    if not new or new == "" then return false, "Name cannot be empty." end
    if RPVoxDB.profiles[new] then return false, "That name is taken." end

    RPVoxDB.profiles[new] = RPVoxDB.profiles[old]
    RPVoxDB.profiles[old] = nil
    for char, prof in pairs(RPVoxDB.characters) do
        if prof == old then RPVoxDB.characters[char] = new end
    end
    if RPVoxDB.activeProfile == old then
        RPVoxDB.activeProfile = new
    end
    return true
end

-- Switching also binds this character to the profile, which is the whole
-- point: log in on the gnome, get the gnome's voice.
function RPVox:UseProfile(name)
    local p = RPVoxDB.profiles[name]
    if not p then return false end

    P = p
    RPVoxDB.activeProfile   = name
    RPVoxDB.characters[CharKey()] = name
    EnsureBuiltins(P, false, false)
    self:RebuildIndex()
    lastAnyCry = 0
    Debug("profile:", name)
    return true
end

-- Database ----------------------------------------------------------------

local function InitDB()
    RPVoxDB = RPVoxDB or {}
    local db = RPVoxDB

    db.profiles   = db.profiles   or {}
    db.characters = db.characters or {}

    -- v1: flat word list. v2/v3: flat trigger list. Both become a profile.
    if db.words and not db.triggers then
        db.triggers = {
            { key = "MELEE", category = "MOMENT", name = "Melee attacks",
              chance = (db.chance or 0.02) * 100, channel = db.channel or "SAY",
              enabled = true, words = db.words },
        }
        db.words, db.chance, db.cooldown, db.channel = nil, nil, nil, nil
    end

    if db.triggers then
        local p = NewProfileTable()
        p.enabled        = (db.enabled ~= false)
        p.globalCooldown = db.globalCooldown or DEFAULT_GLOBALCD
        p.triggers       = db.triggers
        -- everything built before class packs existed was priest-flavoured
        p.class = "PRIEST"
        db.profiles["Default"] = p
        db.activeProfile = db.activeProfile or "Default"
        db.triggers, db.enabled, db.globalCooldown = nil, nil, nil
    end

    if not next(db.profiles) then
        local p = NewProfileTable()
        p.class = select(2, UnitClass("player"))
        db.profiles["Default"] = p
    end

    local seeding     = (db.seedVersion   or 0) < SEED_VERSION
    local rebalancing = false   -- kept as a parameter; nothing rebalances now
    db.seedVersion   = SEED_VERSION

    local repairing = (db.lineVersion or 0) < LINE_VERSION
    db.lineVersion = LINE_VERSION

    -- The bubble had audio; it does not now. Drop what it saved rather than
    -- leave keys in everyone's saved variables that nothing will ever read.
    db.bubbleSound, db.voices = nil, nil

    -- Append-only, outcome lines only. See AddOutcomeLines.
    local offering = (db.outcomeVersion or 0) < OUTCOME_LINE_VERSION
    db.outcomeVersion = OUTCOME_LINE_VERSION

    -- Sets seeded before the copies were noticed are full of them, and pack
    -- changes never reach a trigger a profile already has. Once per bump.
    local trimming = (db.trimVersion or 0) < TRIM_VERSION
    db.trimVersion = TRIM_VERSION

    -- Carry each profile onto the single chance number. The old per trigger
    -- values are averaged across the combat entries, so a profile that was
    -- turned up stays turned up and one that was turned down stays down --
    -- rather than everybody being reset to the default on the update.
    for _, p in pairs(db.profiles) do
        if p.chance == nil then
            local total, n = 0, 0
            for _, t in ipairs(p.triggers or {}) do
                -- Reads the categories as they were *saved*, before
                -- EnsureBuiltins refreshes them, so "COMBAT" is right here.
                if t.category == "COMBAT" and type(t.chance) == "number" then
                    total, n = total + t.chance, n + 1
                end
            end
            p.chance = (n > 0) and (total / n) or DEFAULT_CHANCE
        end
        p.chance = math.max(MIN_CHANCE, math.min(MAX_CHANCE,
                            math.floor(p.chance + 0.5)))
    end

    local trimmedTotal = 0
    for _, p in pairs(db.profiles) do
        EnsureBuiltins(p, seeding, rebalancing)
        if repairing then RepairLines(p) end
        if offering then AddOutcomeLines(p) end
        if trimming then
            local total = 0
            for _, t in ipairs(p.triggers or {}) do
                local kept, dropped = TrimNearDuplicates(t.words)
                t.words, total = kept, total + dropped
            end
            if total > 0 then
                Debug("trimmed", total, "near-duplicate lines")
                trimmedTotal = (trimmedTotal or 0) + total
            end
        end
        if p.globalCooldown == nil then p.globalCooldown = DEFAULT_GLOBALCD end
        if p.enabled        == nil then p.enabled        = true             end
        if p.output         == nil then p.output         = "VOX"            end
    end

    -- Said out loud rather than only in the debug log: this edits saved lines,
    -- and anybody watching their set shrink deserves to know why.
    if trimmedTotal > 0 then
        print(("|cff00ff00RPVox:|r tidied %d repeated lines -- the same line "
            .. "written twice, once with the target's name and once without.")
            :format(trimmedTotal))
    end
end

-- Events ------------------------------------------------------------------

local frame = CreateFrame("Frame")
local EVENTS = {
    "ADDON_LOADED", "PLAYER_LOGIN", "COMBAT_LOG_EVENT_UNFILTERED",
    "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_UNGHOST",
    "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
    "ADDON_ACTION_BLOCKED", "ADDON_ACTION_FORBIDDEN",
    "UNIT_HEALTH", "UNIT_SPELLCAST_SUCCEEDED", "UNIT_SPELLCAST_INTERRUPTED",
    "UNIT_SPELLCAST_SENT",
    "PLAYER_LEVEL_UP", "CHAT_MSG_SYSTEM", "UPDATE_INVENTORY_DURABILITY",
    "QUEST_TURNED_IN", "QUEST_FINISHED", "QUEST_ACCEPTED",
    "PLAYER_MOUNT_DISPLAY_CHANGED",
}
for _, e in ipairs(EVENTS) do pcall(frame.RegisterEvent, frame, e) end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name ~= ADDON then return end
        InitDB()

    elseif event == "PLAYER_LOGIN" then
        -- World mode is remembered across sessions; remembering it does not
        -- apply the settings it needs. Put them back.
        if RPVox.Bubble and RPVox.Bubble.Reapply then
            pcall(RPVox.Bubble.Reapply, RPVox.Bubble)
        end
        playerGUID = UnitGUID("player")
        local db = RPVoxDB
        local myClass = select(2, UnitClass("player"))

        -- This character's own choice wins. Failing that, prefer a profile
        -- built for this character's class -- falling through to "whatever was
        -- used last" silently loads a profile meant for someone else.
        local wanted = db.characters[CharKey()]
        if not wanted or not db.profiles[wanted] then
            for _, name in ipairs(RPVox:ProfileNames()) do
                if PackClass(db.profiles[name].class) == myClass then wanted = name break end
            end
        end
        if not wanted or not db.profiles[wanted] then
            wanted = db.activeProfile
        end
        if not wanted or not db.profiles[wanted] then
            wanted = RPVox:ProfileNames()[1]
        end
        RPVox:UseProfile(wanted)


        -- Say which profile is in use, and complain if it does not match.
        local pclass = P and P.class
        if pclass and myClass and PackClass(pclass) ~= myClass then
            print(("|cffff8800RPVox:|r using profile '%s' (%s) on a %s. "
                .. "Its spells will never fire -- pick another in /rpvox.")
                :format(tostring(db.activeProfile), RPVox:ClassName(pclass),
                        RPVox:ClassName(myClass)))
        else
            print(("|cff00ff00RPVox:|r profile '%s' loaded for %s.")
                :format(tostring(db.activeProfile), CharKey()))
        end

    -- Nothing RPVox sends can be blocked any more, so this no longer feeds
    -- anything. It stays as a debug trace: the addon hooks secure functions,
    -- and seeing our name here is how a taint problem would first show up.
    elseif event == "ADDON_ACTION_BLOCKED" or event == "ADDON_ACTION_FORBIDDEN" then
        if RPVoxDB and RPVoxDB.debug then
            local addon, func = ...
            print(("|cffff8800[RPVox]|r %s -- '%s' tried '%s'")
                :format(event, tostring(addon), tostring(func)))
        end

    -- Reactions ---------------------------------------------------------
    elseif event == "PLAYER_DEAD" then
        FireKey("REACT:DEATH")

    elseif event == "PLAYER_ALIVE" or event == "PLAYER_UNGHOST" then
        if not UnitIsDeadOrGhost("player") then
            FireKey("REACT:RESURRECT")
        end

    elseif event == "PLAYER_REGEN_DISABLED" then
        FireKey("REACT:COMBATSTART")

    elseif event == "PLAYER_REGEN_ENABLED" then
        FireKey("REACT:COMBATEND")

    elseif event == "UNIT_HEALTH" then
        local unit = ...
        if unit ~= "player" then return end
        local hp, max = UnitHealth("player"), UnitHealthMax("player")
        if max == 0 then return end
        local pct = hp / max
        if pct <= 0.25 and lowHealthArmed and hp > 0 then
            lowHealthArmed = false
            FireKey("REACT:LOWHEALTH")
        elseif pct > 0.4 then
            lowHealthArmed = true   -- re-arm once you recover
        end

    elseif event == "UNIT_SPELLCAST_SENT" then
        -- Kept for the debug trace only. This fires on the keypress, before
        -- the server has agreed to anything, so it also fires when the target
        -- is out of range, missing, behind you or immune -- which is why lines
        -- used to go out for casts that never happened. Speech moved to
        -- UNIT_SPELLCAST_SUCCEEDED below.
        --
        -- It was originally used because SendChatMessage needs a hardware
        -- event and the keypress was the only moment one was available. Since
        -- 4.4 lines travel as addon messages, which carry no such rule, so
        -- there is nothing left to trade accuracy for.
        local unit, _, _, spellID = ...
        if unit ~= "player" then return end
        local spellName = GetSpellInfo(spellID)
        if type(spellName) == "string" then
            Debug("cast sent |", spellName, "-- waiting to see if it lands")
        end

    elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unit = ...
        if unit == "player" then FireKey("REACT:INTERRUPTED") end

    elseif event == "PLAYER_LEVEL_UP" then
        FireKey("REACT:LEVELUP")

    elseif event == "CHAT_MSG_SYSTEM" then
        -- zone discovery has no event of its own in this client
        local msg = ...
        if type(msg) == "string" and msg:find("Discovered") then
            FireKey("IDLE:DISCOVERY")
        end

    elseif event == "QUEST_ACCEPTED" then
        FireKey("IDLE:QUESTACCEPT")

    elseif event == "QUEST_TURNED_IN" or event == "QUEST_FINISHED" then
        -- QUEST_FINISHED also fires on closing the window, so gate it: only
        -- the first of the pair inside a second counts.
        local now = GetTime()
        if now - (lastSeen["__quest"] or 0) > 1 then
            lastSeen["__quest"] = now
            FireKey("IDLE:QUEST")
        end

    elseif event == "PLAYER_MOUNT_DISPLAY_CHANGED" then
        if IsMounted and IsMounted() then FireKey("IDLE:MOUNT") end

    elseif event == "UPDATE_INVENTORY_DURABILITY" then
        local worst = 1
        for slot = 1, 19 do
            local cur, max = GetInventoryItemDurability(slot)
            if cur and max and max > 0 then
                worst = math.min(worst, cur / max)
            end
        end
        if worst <= 0.2 and durabilityArmed then
            durabilityArmed = false
            FireKey("REACT:DURABILITY")
        elseif worst > 0.4 then
            durabilityArmed = true      -- re-arm once repaired
        end

    -- Idle --------------------------------------------------------------
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        if unit ~= "player" then return end

        -- Mount fallback: this client may not have the mount event, so watch
        -- for the state flipping after any successful cast.
        if IsMounted then
            local mounted = IsMounted()
            if mounted and not wasMounted then FireKey("IDLE:MOUNT") end
            wasMounted = mounted
        end

        local spellName = GetSpellInfo(spellID)
        if not spellName then return end

        local lower = spellName:lower()

        local gather = SPELLNAME_TRIGGERS[lower]
        if gather then FireKey(gather) return end

        local itemKey = MatchItemTrigger(spellName)
        if itemKey then FireKey(itemKey) return end

        -- The spell line itself. This event only fires once the cast has
        -- actually gone off, so range, target, facing and line of sight have
        -- all already been decided by the server -- a failed cast never
        -- reaches here, and the chance roll is only spent on a real cast.
        --
        -- What the cast then did is a separate question, and one this event
        -- cannot answer: a Fireball that leaves the hand can still be resisted
        -- a second later. A trigger with outcome lines therefore waits for the
        -- combat log instead of speaking here.
        local now = GetTime()
        local t = spellIndex[lower]

        -- Either way the cast arms and waits for the combat log. With an
        -- override it already knows what it will say; without one, the row
        -- decides which of the five moments this cast turned out to be.
        if now - (lastSeen[spellName] or 0) >= DEDUPE_WINDOW then
            lastSeen[spellName] = now
            if t and not HasOutcomeLines(t) then
                -- An override with no outcome lines wants nothing from the log.
                Debug("cast landed |", spellName, "-- override, no outcomes")
                Fire(t)
            else
                ArmCast(spellName, t)
            end
        end
        if t then return end

        local line = CurrentCraftLine()
        if line then
            local t2 = keyIndex["IDLE:CRAFT:" .. line]
            if t2 then Fire(t2) end
        end

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        -- Positional, and what each slot means depends on the subevent. Slots
        -- 12-14 are the prefix (spell id, name, school) for SPELL_ and RANGE_
        -- rows, and the first of the suffix for SWING_ rows, which have no
        -- prefix at all. Hence the flat names: p13 is a spell name only
        -- sometimes, and p12 is a missType, an aura name or a damage type
        -- depending on where you are reading it.
        local _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _,
              p12, p13, p14, p15, p16, p17, p18, p19, p20, p21 =
            CombatLogGetCurrentEventInfo()

        -- Food / drink auras land on you, not on your target
        if subEvent == "SPELL_AURA_APPLIED" and destGUID == playerGUID then
            local aura = type(p13) == "string" and p13:lower() or ""
            if aura == "food" then
                FireKey("IDLE:EAT")
            elseif aura == "drink" then
                FireKey("IDLE:DRINK")
            end
        end

        -- Falling and drowning have no source, so they are checked before the
        -- "was it me?" test below.
        if subEvent == "ENVIRONMENTAL_DAMAGE" and destGUID == playerGUID then
            if p12 == "FALLING" then
                FireKey("REACT:FALLING")
            elseif p12 == "DROWNING" then
                FireKey("REACT:DROWNING")
            end
            return
        end

        if sourceGUID ~= playerGUID then return end

        if subEvent == "PARTY_KILL" then
            FireKey("REACT:KILLINGBLOW")

        -- Melee needs no arming step: a swing is resolved the instant it is
        -- reported, so the row itself is both the trigger and the outcome.
        elseif subEvent == "SWING_DAMAGE" then
            Fire(meleeTrigger, p18 and "crit" or "hit")
        elseif subEvent == "SWING_MISSED" then
            Fire(meleeTrigger, MISS_OUTCOMES[p12] or "miss")

        -- The outcome of a cast that armed itself above. Nothing is looked up
        -- in spellIndex here on purpose: a spell without outcome lines has
        -- already spoken, and firing off its damage row as well would give it
        -- two lines for one cast.
        elseif subEvent == "SPELL_DAMAGE" then
            if type(p13) == "string" then
                local o = p21 and "crit" or "hit"
                ResolveOutcome(p13, o, SpellMoment(o))
            end
        elseif subEvent == "SPELL_MISSED" then
            if type(p13) == "string" then
                local o = MISS_OUTCOMES[p15] or "miss"
                ResolveOutcome(p13, o, SpellMoment(o))
            end
        elseif subEvent == "SPELL_AURA_APPLIED" then
            -- Polymorph, a shield, a DoT going up: nothing was damaged, but the
            -- spell plainly did what it does. Only a spell that armed itself is
            -- looked at, so this cannot fire anything on its own -- and a
            -- resisted Polymorph still arrives as SPELL_MISSED above, which is
            -- the whole reason tagging CC is worth doing.
            --
            -- Which moment depends on what kind of aura it was: a buff landing
            -- on somebody is COMBAT:BUFF, a debuff is something being held
            -- down, which is COMBAT:CC. Held briefly either way, so a damage
            -- row from the same cast still overtakes it -- see ResolveOnAura.
            if type(p13) == "string" then
                ResolveOnAura(p13, (p15 == "BUFF") and "COMBAT:BUFF"
                                                    or "COMBAT:CC")
            end
        elseif subEvent == "SPELL_HEAL" then
            -- A heal crits too, and a healer wanting a line for it should not
            -- have to go without. The suffix is shorter than a damage row, so
            -- the critical flag sits in a different slot.
            if type(p13) == "string" then
                ResolveOutcome(p13, p18 and "crit" or "hit", "COMBAT:HEAL")
            end

        elseif SPELL_EVENTS[subEvent] then
            local spellName = p13
            if type(spellName) ~= "string" then return end

            local outcome
            if subEvent == "RANGE_DAMAGE" then
                outcome = p21 and "crit" or "hit"
            else
                outcome = MISS_OUTCOMES[p15] or "miss"
            end

            -- Turning a wand on does send one cast, so this can be the row an
            -- arm is waiting for. Resolve it there if so -- firing here as
            -- well would speak twice for the one shot, and leave the arm to
            -- time out and speak a third time.
            if ResolveOutcome(spellName, outcome, SpellMoment(outcome)) then return end

            -- Every shot after that repeats on its own and sends no cast at
            -- all, so the log is the only signal there is. No arming step: it
            -- already carries the outcome with it.
            local t = spellIndex[spellName:lower()]
            if not t then
                Debug(subEvent, "|", spellName, "-- no trigger configured")
                return
            end

            local now = GetTime()
            if now - (lastSeen[spellName] or 0) < DEDUPE_WINDOW then return end
            lastSeen[spellName] = now

            Debug(subEvent, "|", spellName, "-- matched", outcome)
            Fire(t, outcome)
        end
    end
end)

-- Slash -------------------------------------------------------------------

SLASH_RPVox1 = "/rpvox"
SLASH_RPVox2 = "/vox"
SLASH_RPVox3 = "/rpcry"   -- the old name, kept so muscle memory still works
SlashCmdList["RPVox"] = function(input)
    local cmd, rest = (input or ""):match("^%s*(%S*)%s*(.-)%s*$")
    cmd = cmd:lower()

    if cmd == "on" then
        P.enabled = true
        print("|cff00ff00RPVox:|r enabled.")

    elseif cmd == "off" then
        P.enabled = false
        print("|cff00ff00RPVox:|r disabled.")

    elseif cmd == "bubble" then
        if not RPVox.Bubble then
            print("|cffff0000RPVox:|r bubble module did not load.")
        elseif rest == "demo" then
            RPVox.Bubble:Demo()
        elseif rest == "diag" then
            RPVox.Bubble:Diagnose()
        elseif rest == "mine" then
            RPVox.Bubble:Mine()
        elseif rest == "client" then
            RPVox.Bubble:Client()
        elseif rest == "cvars" then
            RPVox.Bubble:CVars()
        elseif rest:match("^test") then
            RPVox.Bubble:TestOn(rest:match("^test%s+(.+)"))
        elseif rest == "world" then
            RPVox.Bubble:World()
        elseif rest == "others" then
            RPVoxDB.hideOthers = not RPVoxDB.hideOthers
            print("|cff00ff00RPVox:|r bubbles from other players "
                .. (RPVoxDB.hideOthers and "|cffff8800hidden|r -- their lines "
                    .. "still arrive in chat." or "|cff00ff00shown|r."))
        else
            RPVox.Bubble:TogglePin()
        end

    elseif cmd == "debug" then
        RPVoxDB.debug = not RPVoxDB.debug
        print("|cff00ff00RPVox:|r debug "
            .. (RPVoxDB.debug and "ON -- act now and watch this window."
                                       or "off."))

    elseif cmd == "why" then
        RPVox:Why(rest)

    elseif cmd == "trace" then
        RPVoxDB.trace = not RPVoxDB.trace
        if RPVoxDB.trace then
            print("|cff00ff00RPVox:|r trace |cffffff00ON|r. Every swing and "
                .. "every cast now prints the line it would have said, and "
                .. "|cffffff00nothing is sent|r -- chance, the quiet gap and "
                .. "the group rules are all ignored. Go and fight something.")
            print("  Read it as: |cff888888trigger|r |cffffff00outcome|r "
                .. "|cff00ff00which lines it drew from|r.")
        else
            print("|cff00ff00RPVox:|r trace off -- speaking normally again.")
        end

    elseif cmd == "profile" then
        if rest == "" then
            print("|cff00ff00RPVox|r profiles:")
            for _, n in ipairs(RPVox:ProfileNames()) do
                print(("  %s%s"):format(n,
                    n == RPVoxDB.activeProfile and "  |cffffff00<- in use|r" or ""))
            end
        elseif RPVox:UseProfile(rest) then
            print("|cff00ff00RPVox:|r now using '" .. rest
                .. "' on " .. CharKey() .. ".")
        else
            print("|cffff0000RPVox:|r no profile named '" .. rest .. "'.")
        end

    elseif cmd == "mood" then
        local moods = RPVox:MoodsInProfile()
        if rest == "" then
            print("|cff00ff00RPVox:|r mood is "
                .. (RPVox:GetMood() or "|cffffff00Any|r") .. ".")
            print("  available: any, " .. (#moods > 0 and table.concat(moods, ", ")
                or "|cff808080none tagged in this profile|r"))
            print("  tag a line like this:  [grim] Nothing lasts.")
        elseif rest:lower() == "any" then
            RPVox:SetMood(nil)
            print("|cff00ff00RPVox:|r mood cleared -- every line is eligible.")
        elseif rest:lower():match("^add%s+") then
            local name, err = RPVox:AddMood(P, rest:match("^%a+%s+(.*)$"))
            if name then
                print("|cff00ff00RPVox:|r mood '" .. name .. "' added. Tag lines"
                    .. " with |cffffff00[" .. name .. "]|r to use it.")
            else
                print("|cffff0000RPVox:|r " .. tostring(err))
            end
        elseif rest:lower():match("^remove%s+") then
            local name = rest:match("^%a+%s+(.*)$")
            print("|cff00ff00RPVox:|r "
                .. (RPVox:RemoveMood(P, name)
                    and ("mood '" .. tostring(name):lower() .. "' removed from the list."
                         .. " Lines still tagged with it are untouched.")
                    or ("no mood called '" .. tostring(name) .. "'.")))
        else
            RPVox:SetMood(rest)
            print("|cff00ff00RPVox:|r mood set to '" .. rest:lower() .. "'.")
        end
        if RPVox.UI and RPVox.UI.frame and RPVox.UI.frame:IsShown() then
            RPVox.UI:Refresh()
        end

    elseif cmd == "copy" then
        -- Same job as the Copy button, without the popup in the way.
        if rest == "" then
            print("|cff00ff00RPVox:|r use  /rpvox copy <new name>")
        else
            local from = RPVox:ProfileName()
            local ok, p, err = pcall(RPVox.CreateProfile, RPVox, rest, from)
            if not ok then
                print("|cffff0000RPVox copy failed:|r " .. tostring(p))
            elseif not p then
                print("|cffff0000RPVox:|r " .. tostring(err))
            else
                RPVox:UseProfile(rest)
                if RPVox.UI and RPVox.UI.Refresh then pcall(RPVox.UI.Refresh, RPVox.UI) end
                print(("|cff00ff00RPVox:|r copied '%s' to '%s' and switched to it.")
                    :format(tostring(from), rest))
            end
        end

    elseif cmd == "rebuild" then
        -- Throws away every stock line in this profile and seeds it again from
        -- the current packs. The only way to be certain a profile holds exactly
        -- what the addon defines today and nothing inherited from old builds.
        local before = 0
        for _, t in ipairs(P.triggers or {}) do before = before + #(t.words or {}) end
        local mine = {}
        for _, t in ipairs(P.triggers or {}) do
            if not t.builtin then table.insert(mine, t) end
        end
        P.triggers = mine
        RPVox:Reseed(P)
        local after = 0
        for _, t in ipairs(P.triggers) do after = after + #(t.words or {}) end
        print(("|cff00ff00RPVox:|r rebuilt '%s' -- %d lines across %d triggers"
            .. " (was %d). Custom triggers kept.")
            :format(tostring(RPVoxDB.activeProfile), after, #P.triggers, before))

    elseif cmd == "nettest" then
        -- Answers one question: does an addon message actually leave this
        -- client and reach another one, and over which distribution.
        local reg = (C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix)
                 or RegisterAddonMessagePrefix
        local okReg = reg and select(1, pcall(reg, RPVox.AddonPrefix))
        print("|cff00ff00RPVox nettest|r")
        print("  prefix '" .. tostring(RPVox.AddonPrefix) .. "' registered: "
            .. tostring(okReg and true or false))
        local me = UnitName("player") or "?"
        for _, dist in ipairs({ "SAY", "YELL", "PARTY", "RAID", "GUILD" }) do
            local ok = RPVox:SendAddonRaw("T|" .. dist .. "|" .. me, dist)
            print(("  %-6s -> %s"):format(dist, ok and "accepted by client"
                                                    or "|cffff0000refused|r"))
        end
        print("  Stand next to the other player and have them run it too.")
        print("  Whatever arrives will print here as 'got a ping'.")

    elseif cmd == "status" then
        print("|cff00ff00RPVox status|r")
        print("  profile:    " .. tostring(RPVoxDB.activeProfile)
            .. "  (class: " .. tostring(P and P.class or "none") .. ")")
        print("  character:  " .. CharKey()
            .. "  (" .. tostring(select(2, UnitClass("player"))) .. ")")
        print("  mood:       " .. (RPVox:GetMood() or "Any"))
        local total = 0
        for _, t in ipairs(P.triggers) do total = total + #(t.words or {}) end
        print("  lines:      " .. total .. " across " .. #P.triggers .. " triggers")
        print("  enabled:    " .. tostring(P and P.enabled))
        print("  global gap: " .. tostring(P and P.globalCooldown) .. "s")
        print("  output:     nearby players running RPVox (say range)")
        local inInstance, kind = IsInInstance()
        if IsInRaid and IsInRaid() then
            print("  |cffff8800context:    in a raid group -- silenced|r")
        elseif inInstance and kind == "raid" then
            print("  |cffff8800context:    inside a raid -- silenced|r")
        elseif inInstance and kind == "party" then
            print(("  |cffff8800context:    in a dungeon -- capped at %g%%|r")
                :format(DUNGEON_MAX_CHANCE))
        end
        local n = 0
        for _, t in ipairs(P.triggers) do
            if t.enabled ~= false and #(t.words or {}) > 0 then
                n = n + 1
                print(("  |cffffff00%s|r  %s%%  %d lines")
                    :format(t.name, tostring(t.weight or 1), #t.words))
            end
        end
        if n == 0 then print("  |cffff0000nothing armed|r") end

    elseif cmd == "testfire" then
        local t
        for _, tr in ipairs(P.triggers) do
            if tr.enabled ~= false and #(tr.words or {}) > 0 then t = tr break end
        end
        if not t then
            print("|cffff0000RPVox:|r nothing armed to test.")
            return
        end
        local raw = PickLine(t) or t.words[1]
        local _, body = StripTags(raw)
        local msg, channel = SplitChannel(body)
        Say(ForOutput(Expand(msg), channel))

    -- "autotest" lived here: it sent a probe to SAY, EMOTE, PARTY, RAID and
    -- GUILD from a timer and asked which ones had arrived, to find a channel
    -- that worked without a hardware event. Removed with the rest of that
    -- problem -- every line is an addon message and none of them can be
    -- refused.

    elseif cmd == "help" then
        print("|cff00ff00RPVox|r")
        print("  /rpvox                 open the settings window")
        print("  /rpvox on | off        kill switch for this profile")
        print("  /rpvox profile         list profiles")
        print("  /rpvox profile <name>  use that profile on this character")
        print("  /rpvox mood            show moods in this profile")
        print("  /rpvox mood <name>     only say lines tagged [name] (or 'any')")
        print("  /rpvox status          what is armed right now")
        print("  /rpvox bubble          pin the speech bubble to move it")
        print("  /rpvox bubble demo     step through the text effects")
        print("  /rpvox bubble world    float lines above the character model")
        print("  /rpvox bubble test     test a bubble on your target")
        print("  /rpvox bubble cvars    list this client's nameplate settings")
        print("  /rpvox bubble client   what client and nameplate support exist")
        print("  /rpvox bubble others   show or hide other players' bubbles")
        print("  /rpvox bubble mine     show or hide your own bubble")
        print("  /rpvox debug           log why lines do or do not fire")
        print("  /rpvox testfire        send one line immediately")
        print("  /rpvox trace           show every decision, send nothing")
        print("  /rpvox why             what stopped each trigger speaking")

    else
        RPVox:ToggleUI()
    end
end
