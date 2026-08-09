-- RPVox -- core
-- Roleplay lines fired from combat, personal reactions, and idle activity.
--
-- Settings live in named profiles. Each character remembers which profile it
-- uses, so an Undead priest and a Gnome warrior can carry different voices.

local ADDON = "RPVox"

RPVox = {}                       -- shared namespace (core <-> UI)
RPVox.MELEE_KEY = "MELEE"

RPVox.CATEGORIES = { "COMBAT", "REACTION", "IDLE" }
RPVox.CATEGORY_NAME = {
    COMBAT   = "Combat",
    REACTION = "Reactions",
    IDLE     = "Idle",
}

-- Combat log subevents grouped by trigger type ----------------------------
local MELEE_EVENTS = {
    SWING_DAMAGE = true,
    SWING_MISSED = true,
}

-- Casts are handled by UNIT_SPELLCAST_SENT, which fires the instant you press
-- the key -- while the client is still processing that input, so the line goes
-- out on the same keystroke. Waiting for the combat log meant a 3 second
-- Fireball queued its line long after the key was released, and it then went
-- out on whatever you pressed next.
--
-- The combat log is still used for wand shots, which repeat on their own and
-- never send a fresh cast.
local SPELL_EVENTS = {
    RANGE_DAMAGE = true,
    RANGE_MISSED = true,
}

-- A single spell can produce several of these for one cast. Only the first
-- one inside this window counts, so a cast never fires two rolls.
local DEDUPE_WINDOW = 0.6

-- At most one chance roll per this many seconds, whatever was pressed. Players
-- mash a key while it is still on cooldown, and every one of those dead presses
-- used to buy another roll -- so a 20% trigger fired almost every time for
-- anyone who taps quickly. 1.5s is the global cooldown, so nobody loses a roll
-- for an action they actually took.
local ROLL_THROTTLE = 1.5

local SEED_VERSION   = 17 -- bump to offer a fresh set of stock lines
local CHANCE_VERSION = 2   -- bump to re-apply stock chances over saved ones
local LINE_VERSION   = 2   -- bump to rewrite saved lines in place

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
    -- Combat ------------------------------------------------------------
    { key = "MELEE", category = "COMBAT", name = "Melee attacks",
      icon = "Interface\\Icons\\INV_Sword_04", chance = 10 },

    -- Reactions ---------------------------------------------------------
    { key = "REACT:LOWHEALTH", category = "REACTION", name = "Badly wounded (below 25%)",
      icon = "Interface\\Icons\\Ability_Creature_Cursed_02", chance = 3 },
    { key = "REACT:DEATH", category = "REACTION", name = "You die",
      icon = "Interface\\Icons\\Ability_Rogue_FeignDeath", chance = 5 },
    { key = "REACT:RESURRECT", category = "REACTION", name = "You return to life",
      icon = "Interface\\Icons\\Spell_Holy_Resurrection", chance = 3 },
    { key = "REACT:KILLINGBLOW", category = "REACTION", name = "You land a killing blow",
      icon = "Interface\\Icons\\Ability_Warrior_Riposte", chance = 0.5 },
    { key = "REACT:COMBATSTART", category = "REACTION", name = "You enter combat",
      icon = "Interface\\Icons\\Ability_DualWield", chance = 0.5 },
    { key = "REACT:COMBATEND", category = "REACTION", name = "You leave combat",
      icon = "Interface\\Icons\\Spell_Nature_Sleep", chance = 0.5 },
    { key = "REACT:INTERRUPTED", category = "REACTION", name = "Your cast is interrupted",
      icon = "Interface\\Icons\\Spell_Frost_IceShock", chance = 2 },
    { key = "REACT:LEVELUP", category = "REACTION", name = "You gain a level",
      icon = "Interface\\Icons\\Spell_Nature_EnchantArmor", chance = 50 },
    { key = "REACT:FALLING", category = "REACTION", name = "You take falling damage",
      icon = "Interface\\Icons\\Ability_Rogue_Sprint", chance = 15 },
    { key = "REACT:DROWNING", category = "REACTION", name = "You are drowning",
      icon = "Interface\\Icons\\Spell_Shadow_DemonBreath", chance = 20 },
    { key = "REACT:DURABILITY", category = "REACTION", name = "Your gear is nearly broken",
      icon = "Interface\\Icons\\INV_Hammer_20", chance = 25 },

    -- Idle --------------------------------------------------------------
    { key = "IDLE:EAT", category = "IDLE", name = "Eating",
      icon = "Interface\\Icons\\INV_Misc_Food_15", chance = 2 },
    { key = "IDLE:DRINK", category = "IDLE", name = "Drinking",
      icon = "Interface\\Icons\\INV_Drink_07", chance = 2 },
    { key = "IDLE:HEALTHSTONE", category = "IDLE", name = "Healthstone / healing potion",
      icon = "Interface\\Icons\\INV_Stone_04", chance = 3 },
    { key = "IDLE:MANAPOTION", category = "IDLE", name = "Mana potion",
      icon = "Interface\\Icons\\INV_Potion_76", chance = 2 },
    { key = "IDLE:FISHING", category = "IDLE", name = "Fishing",
      icon = "Interface\\Icons\\Trade_Fishing", chance = 0.5 },
    { key = "IDLE:MINING", category = "IDLE", name = "Mining",
      icon = "Interface\\Icons\\Trade_Mining", chance = 0.5 },
    { key = "IDLE:HERBALISM", category = "IDLE", name = "Herb gathering",
      icon = "Interface\\Icons\\Trade_Herbalism", chance = 0.5 },
    { key = "IDLE:SKINNING", category = "IDLE", name = "Skinning",
      icon = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01", chance = 0.5 },
    { key = "IDLE:MOUNT", category = "IDLE", name = "Mounting up",
      icon = "Interface\\Icons\\Ability_Mount_RidingHorse", chance = 3 },
    { key = "IDLE:QUESTACCEPT", category = "IDLE", name = "Accepting a quest",
      icon = "Interface\\Icons\\INV_Misc_Note_02", chance = 5 },
    { key = "IDLE:QUEST", category = "IDLE", name = "Turning in a quest",
      icon = "Interface\\Icons\\INV_Misc_Note_01", chance = 5 },
    { key = "IDLE:DISCOVERY", category = "IDLE", name = "Discovering a new place",
      icon = "Interface\\Icons\\INV_Misc_Map_01", chance = 25 },
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
        name = p[1], icon = p[2], chance = 1, craftLine = p[1],
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
    return out
end

local function DefsFor(profile)
    local defs = {}
    for _, d in ipairs(BUILTIN) do table.insert(defs, d) end

    local pack = ClassPack(profile)
    if pack and pack.spells then
        for _, s in ipairs(pack.spells) do
            table.insert(defs, {
                key       = "SPELL:" .. s.spell,
                category  = "COMBAT",
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

local DEFAULT_CHANCE   = 0.5
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
        if (t.category or "COMBAT") == category then
            table.insert(out, t)
        end
    end
    return out
end

function RPVox:NewTrigger(spellName, icon)
    local t = {
        key       = "SPELL:" .. spellName,
        category  = "COMBAT",
        name      = spellName,
        spellName = spellName,
        icon      = icon or "Interface\\Icons\\INV_Misc_QuestionMark",
        chance    = DEFAULT_CHANCE,
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
-- SendChatMessage to public channels is refused unless the call happens while
-- the client is processing real input. A combat log event is not that, and the
-- refusal is silent: no Lua error, just ADDON_ACTION_BLOCKED. So we hold the
-- line and send it from a key or mouse handler.
--
-- Do NOT flush straight after queuing -- that runs in the very context the
-- client rejects, and it throws the line away.

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

function RPVox:MoodsInProfile(profile)
    profile = profile or P
    local seen, out = {}, {}
    if not profile then return out end
    for _, t in ipairs(profile.triggers or {}) do
        for _, w in ipairs(t.words or {}) do
            local mood = SplitMood(w)
            if mood and not seen[mood] then
                seen[mood] = true
                table.insert(out, mood)
            end
        end
    end
    table.sort(out)
    return out
end

function RPVox:SetMood(mood)
    if not P then return false end
    P.mood = (mood and mood ~= "" and mood:lower()) or nil
    return true
end

function RPVox:GetMood()
    return P and P.mood
end

local function MoodFits(mood)
    if not mood then return true end          -- untagged: always fine
    local active = P and P.mood
    if not active then return true end        -- "Any": everything is eligible
    return mood == active
end

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

local function PickLine(trigger)
    local words = trigger.words
    local hasTarget = TargetName() ~= nil

    -- eligible = fits the current mood, and has a target if it needs one
    local eligible = {}
    for i, w in ipairs(words) do
        local mood, body = SplitMood(w)
        if MoodFits(mood) and (hasTarget or not body:find("%%t")) then
            table.insert(eligible, i)
        end
    end
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

    return words[index]
end

-- Carries the say-or-emote decision through to the sender, which needs it to
-- tag the payload so the receiving side can render an action as an action.
-- In /say and /em mode nothing changes: the client formats emotes itself.
local function ForOutput(msg, channel, output)
    if (output or "VOX") ~= "VOX" then return msg, channel end
    return msg, (channel == "EMOTE") and "VOXEMOTE" or "VOXSAY"
end

-- Used by the Test line button so a preview matches what would really be said.
function RPVox:PreviewLine(trigger)
    local raw = PickLine(trigger)
    if not raw then return nil end
    local _, body = SplitMood(raw)
    local msg, channel = SplitChannel(body)
    return ForOutput(Expand(msg), channel, P and P.output)
end

-- Idle triggers can fire while you are standing perfectly still, so give a
-- queued line a reasonable while to find an input before discarding it.
local PENDING_TTL = 12  -- seconds; a stale line is dropped rather than said late
local pending

-- Set by ADDON_ACTION_BLOCKED, which is how the client tells us a send was
-- refused. It is the only signal available: a blocked SendChatMessage returns
-- no error at all.
local blockedAt = 0
local attemptedAt = 0
function RPVox:NoteBlocked() blockedAt = GetTime() end

-- When an immediate send is refused, the client puts "Interface action failed
-- because of an AddOn" on screen. The refusal is expected and already handled
-- by falling back to the queue, so swallow that one message when it is ours.
-- Anything else, including other addons' failures, still shows normally.
if UIErrorsFrame and UIErrorsFrame.AddMessage then
    local originalAddMessage = UIErrorsFrame.AddMessage
    UIErrorsFrame.AddMessage = function(self, message, ...)
        if type(message) == "string"
           and GetTime() - attemptedAt < 1
           and (message == ADDON_ACTION_BLOCKED
                or message == ADDON_ACTION_FORBIDDEN
                or message:find("AddOn")) then
            return
        end
        return originalAddMessage(self, message, ...)
    end
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

-- Every line leaves through here.
local function RawSend(msg, channel)
    if channel == "VOXSAY" or channel == "VOXEMOTE" then
        local kind = (channel == "VOXEMOTE") and "E" or "S"
        return SendAddon(kind .. "|" .. msg)
    end
    return pcall(SendChatMessage, msg, channel)
end

-- Receiving. Tagged so it is never mistaken for real /say: this is a line an
-- addon chose, not something the player typed, and readers should be able to
-- tell at a glance.
-- The whole line is coloured, not just the tag. White text reading
-- "Name says: ..." is indistinguishable from real /say at a glance, which is
-- exactly the confusion this is meant to avoid.
local RP_TAG   = "|cffb48ee6[RP]|r "
local RP_R, RP_G, RP_B = 0.78, 0.62, 0.95     -- soft purple, unlike any
local EM_R, EM_G, EM_B = 0.62, 0.48, 0.80     -- default chat colour

local rx = CreateFrame("Frame")
rx:RegisterEvent("CHAT_MSG_ADDON")
rx:SetScript("OnEvent", function(_, _, prefix, payload, dist, sender)
    if prefix ~= ADDON_PREFIX or type(payload) ~= "string" then return end
    local kind, text = payload:match("^(%a)|(.*)$")
    if not kind or text == "" then return end
    local name = (Ambiguate and Ambiguate(sender, "none"))
              or sender:match("^[^-]+") or sender

    -- Diagnostic pings always print, whatever the debug setting.
    if kind == "T" then
        local sentOver, who = text:match("^([^|]+)|(.*)$")
        print(("|cff00ff00RPVox nettest:|r got a ping from |cffffff00%s|r"
            .. " sent over %s, arrived as %s")
            :format(who or name, sentOver or "?", tostring(dist)))
        return
    end
    Debug("received", kind, "from", name, "over", tostring(dist))
    if kind == "E" then
        -- Stock lines carry no emotes any more, but a player can still write
        -- one in the line editor, so the path stays.
        DEFAULT_CHAT_FRAME:AddMessage(RP_TAG .. name .. " " .. text,
                                      EM_R, EM_G, EM_B)
    else
        DEFAULT_CHAT_FRAME:AddMessage(RP_TAG .. name .. " says: " .. text,
                                      RP_R, RP_G, RP_B)
    end
end)

function RPVox:Queue(msg, channel, ttl)
    pending = { msg = msg, channel = channel, at = GetTime(), ttl = ttl or PENDING_TTL }

    -- Try to say it right now. A cast begins while the client is still
    -- handling the keypress, so this often succeeds outright -- which is the
    -- difference between speaking as you cast and speaking a keystroke later.
    local before = blockedAt
    attemptedAt = GetTime()
    RawSend(msg, channel)

    -- Next frame, decide what happened. A block sets blockedAt; no block
    -- means it went out and the queued copy must be discarded so it cannot
    -- be said twice.
    C_Timer.After(0, function()
        if not pending then return end
        if blockedAt > before then
            Debug("immediate send refused; waiting for input:", msg)
        else
            Debug("sent immediately:", msg)
            pending = nil
        end
    end)
end

function RPVox:Flush()
    if not pending then return end

    if GetTime() - pending.at > (pending.ttl or PENDING_TTL) then
        Debug("dropped stale line:", pending.msg)
        pending = nil
        return
    end

    local msg, channel = pending.msg, pending.channel
    pending = nil
    local ok, err = RawSend(msg, channel)
    if ok then
        Debug("sent:", msg)
    else
        print("|cffff0000RPVox:|r could not send -- " .. tostring(err))
    end
end

-- Firing from inside the button press ------------------------------------
-- The reliable way to speak at the moment of a cast is to do it while the
-- client is running the action the player just triggered. UseAction is called
-- for every action button -- keyboard binding, mouse click, or a controller
-- through ConsolePort -- so hooking it covers every input device, and code
-- running inside that hook is still within the input the client accepts.
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
        local function attempt(trigger, name)
            if not trigger or not name then return end
            local now = GetTime()
            if now - (lastSeen[name] or 0) < DEDUPE_WINDOW then return end
            lastSeen[name] = now
            Debug("action used |", name, "-- matched")
            fire(trigger)
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

-- Input sources. The queued line goes out on the next real input of any kind,
-- so the more surfaces we watch, the less it feels like a delay. Keyboard
-- input is propagated untouched so nothing is ever stolen from the game.
local hw = CreateFrame("Frame", "RPVoxInputGate", UIParent)
hw:EnableKeyboard(true)
hw:SetPropagateKeyboardInput(true)
hw:SetScript("OnKeyDown",    function() RPVox:Flush() end)
hw:SetScript("OnKeyUp",      function() RPVox:Flush() end)   -- releasing counts too

-- Never touch the mouse wheel. There is no SetPropagateMouseWheelInput, so any
-- frame that handles OnMouseWheel swallows the event, and the camera zoom
-- bindings (MOUSEWHEELUP/MOUSEWHEELDOWN) never fire. Clicks and keys are
-- plentiful enough as flush triggers; stealing the player's zoom is not worth
-- the extra surface.

-- Controllers do not produce key events, so watch gamepad buttons too where
-- the client supports them.
if hw.EnableGamePadButton then
    pcall(hw.EnableGamePadButton, hw, true)
    hw:SetScript("OnGamePadButtonDown", function() RPVox:Flush() end)
    hw:SetScript("OnGamePadButtonUp",   function() RPVox:Flush() end)
end

if WorldFrame then
    WorldFrame:HookScript("OnMouseDown",  function() RPVox:Flush() end)
    WorldFrame:HookScript("OnMouseUp",    function() RPVox:Flush() end)
    -- No OnMouseWheel hook here: it eats camera zoom. See the note above.
end

-- Clicks on the UI (action bars included) never reach WorldFrame. These events
-- fire for any mouse press anywhere, which covers click-casting.
local mouseWatcher = CreateFrame("Frame")
mouseWatcher:SetScript("OnEvent", function() RPVox:Flush() end)
pcall(mouseWatcher.RegisterEvent, mouseWatcher, "GLOBAL_MOUSE_DOWN")
pcall(mouseWatcher.RegisterEvent, mouseWatcher, "GLOBAL_MOUSE_UP")

-- Firing ------------------------------------------------------------------

local function Fire(trigger)
    if not P or not P.enabled then
        Debug("skip: profile disabled")
        return
    end
    if not trigger then return end
    if trigger.enabled == false then
        Debug("skip:", trigger.name, "is unticked")
        return
    end

    local words = trigger.words
    if not words or #words == 0 then
        Debug("skip:", trigger.name, "has no lines")
        return
    end

    local now = GetTime()

    -- One gap to rule them all: nothing may be said until this has elapsed
    -- since the last line, whichever trigger produced it.
    local wait = (P.globalCooldown or 0) - (now - lastAnyCry)
    if wait > 0 then
        Debug(("skip: still quiet for %.0fs"):format(wait))
        return
    end

    -- Mashing a key must not buy extra rolls. See ROLL_THROTTLE.
    if now - lastRollAt < ROLL_THROTTLE then
        Debug("skip: already rolled this global cooldown -- input spam")
        return
    end
    lastRollAt = now

    local roll = math.random() * 100
    if roll >= (trigger.chance or 0) then
        Debug(("skip: %s rolled %.2f, needed under %.2f")
            :format(trigger.name, roll, trigger.chance or 0))
        return
    end

    local raw = PickLine(trigger)
    if not raw then
        Debug("skip:", trigger.name, "-- every line needs a target and you have none")
        return
    end

    lastAnyCry = now
    local _, body = SplitMood(raw)
    -- The line decides whether it is speech or an action; the profile decides
    -- where it goes and how an action is marked once it gets there.
    local msg, channel = SplitChannel(body)
    msg, channel = ForOutput(Expand(msg), channel, P.output)
    Debug("FIRE:", trigger.name, "->", channel, "->", msg)

    -- A combat line belongs to the spell that caused it. If it cannot go out
    -- almost immediately, drop it rather than let it surface during a later
    -- cast and describe the wrong spell.
    local ttl = (trigger.category == "COMBAT") and 4 or PENDING_TTL
    RPVox:Queue(msg, channel, ttl)
end

local function FireKey(key)
    Fire(keyIndex[key])
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
                chance  = def.chance,
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
        if t.chance  == nil then t.chance  = def.chance end
        if t.channel == nil then t.channel = "SAY"      end
        if t.words   == nil then t.words   = {}         end
        t.cooldown = nil   -- per-trigger gaps are gone; one global gap now

        -- Refresh stock lines on a seed bump, but never touch a list you have
        -- edited yourself (the UI stamps t.custom the moment you type in it).
        if seeding and stock and not t.custom then
            t.words = CopyTable(stock)
        end

        -- Re-apply stock chances on a rebalance, but never over a number the
        -- player set themselves. Before this, every content update that bumped
        -- CHANCE_VERSION silently reset everybody's sliders back to stock.
        if rebalancing and not t.chanceCustom then
            t.chance = def.chance
        end
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
        if not t.category then t.category = "COMBAT" end
        t.cooldown = nil
        -- anything saved from an older build (YELL, PARTY) comes back to SAY
        t.channel = SafeChannel(t.channel)
        -- Old one-off migration that capped hand-made triggers at 0.5%. It must
        -- not touch a chance the player has set, or their own triggers get
        -- quietly turned down on every update.
        if rebalancing and not t.builtin and not t.chanceCustom
           and (t.chance or 0) > 0.5 then
            t.chance = 0.5
        end
    end
end

-- Exposed so /rpvox rebuild can force a clean reseed of one profile.
function RPVox:Reseed(profile)
    EnsureBuiltins(profile, true, false)
    RepairLines(profile)
end

local function NewProfileTable()
    return {
        enabled       = true,
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
            { key = "MELEE", category = "COMBAT", name = "Melee attacks",
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
    local rebalancing = (db.chanceVersion or 0) < CHANCE_VERSION
    db.seedVersion   = SEED_VERSION
    db.chanceVersion = CHANCE_VERSION

    local repairing = (db.lineVersion or 0) < LINE_VERSION
    db.lineVersion = LINE_VERSION

    for _, p in pairs(db.profiles) do
        EnsureBuiltins(p, seeding, rebalancing)
        if repairing then RepairLines(p) end
        if p.globalCooldown == nil then p.globalCooldown = DEFAULT_GLOBALCD end
        if p.enabled        == nil then p.enabled        = true             end
        if p.output         == nil then p.output         = "VOX"            end
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
        playerGUID = UnitGUID("player")
        local db = RPVoxDB
        local myClass = select(2, UnitClass("player"))

        -- This character's own choice wins. Failing that, prefer a profile
        -- built for this character's class -- falling through to "whatever was
        -- used last" silently loads a profile meant for someone else.
        local wanted = db.characters[CharKey()]
        if not wanted or not db.profiles[wanted] then
            for _, name in ipairs(RPVox:ProfileNames()) do
                if db.profiles[name].class == myClass then wanted = name break end
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
        if pclass and myClass and pclass ~= myClass then
            print(("|cffff8800RPVox:|r using profile '%s' (%s) on a %s. "
                .. "Its spells will never fire -- pick another in /rpcry.")
                :format(tostring(db.activeProfile), RPVox:ClassName(pclass),
                        RPVox:ClassName(myClass)))
        else
            print(("|cff00ff00RPVox:|r profile '%s' loaded for %s.")
                :format(tostring(db.activeProfile), CharKey()))
        end

    elseif event == "ADDON_ACTION_BLOCKED" or event == "ADDON_ACTION_FORBIDDEN" then
        local who = ...
        if who == ADDON then RPVox:NoteBlocked() end
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
        -- Fires on the keypress itself, so the queued line rides out on the
        -- release of that same key rather than the next one.
        local unit, _, _, spellID = ...
        if unit ~= "player" then return end
        local spellName = GetSpellInfo(spellID)
        if type(spellName) ~= "string" then return end

        local t = spellIndex[spellName:lower()]
        if not t then
            Debug("cast sent |", spellName, "-- no trigger configured")
            return
        end

        local now = GetTime()
        if now - (lastSeen[spellName] or 0) < DEDUPE_WINDOW then return end
        lastSeen[spellName] = now

        Debug("cast sent |", spellName, "-- matched")
        Fire(t)

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

        local line = CurrentCraftLine()
        if line then
            local t = keyIndex["IDLE:CRAFT:" .. line]
            if t then Fire(t) end
        end

    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, sourceGUID, _, _, _, destGUID, _, _, _, p12, p13 =
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
        elseif MELEE_EVENTS[subEvent] then
            Fire(meleeTrigger)
        elseif SPELL_EVENTS[subEvent] then
            local spellName = p13
            if type(spellName) ~= "string" then return end
            local t = spellIndex[spellName:lower()]
            if not t then
                Debug(subEvent, "|", spellName, "-- no trigger configured")
                return
            end

            local now = GetTime()
            if now - (lastSeen[spellName] or 0) < DEDUPE_WINDOW then return end
            lastSeen[spellName] = now

            Debug(subEvent, "|", spellName, "-- matched")
            Fire(t)
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

    elseif cmd == "debug" then
        RPVoxDB.debug = not RPVoxDB.debug
        print("|cff00ff00RPVox:|r debug "
            .. (RPVoxDB.debug and "ON -- act now and watch this window."
                                       or "off."))

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
        else
            RPVox:SetMood(rest)
            print("|cff00ff00RPVox:|r mood set to '" .. rest:lower() .. "'.")
        end
        if RPVox.UI and RPVox.UI.frame and RPVox.UI.frame:IsShown() then
            RPVox.UI:Refresh()
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

    elseif cmd == "output" then
        local want = (rest or ""):lower()
        if want == "vox" or want == "channel" then
            P.output = "VOX"
            print("|cff00ff00RPVox:|r speaking to nearby players who run RPVox."
                .. " Nothing goes to public chat.")
        elseif want == "say" or want == "public" then
            P.output = "PUBLIC"
            print("|cff00ff00RPVox:|r speaking in /say and /em.")
        else
            print("|cff00ff00RPVox:|r output is "
                .. ((P.output or "VOX") == "VOX"
                    and "nearby RPVox users" or "/say and /em")
                .. ".  Use: /rpvox output vox | say")
        end

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
        if (P and P.output or "VOX") == "VOX" then
            print("  output:     nearby players running RPVox (say range)")
        else
            print("  output:     /say and /em")
        end
        local n = 0
        for _, t in ipairs(P.triggers) do
            if t.enabled ~= false and #(t.words or {}) > 0 then
                n = n + 1
                print(("  |cffffff00%s|r  %s%%  %d lines")
                    :format(t.name, tostring(t.chance), #t.words))
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
        -- Typing this command is itself input, so it can send straight away.
        local raw = PickLine(t) or t.words[1]
        local _, body = SplitMood(raw)
        local msg, channel = SplitChannel(body)
        RPVox:Queue(ForOutput(Expand(msg), channel, P.output))
        RPVox:Flush()

    elseif cmd == "autotest" then
        -- Fires two seconds from now, from a timer, with no input involved.
        -- Whatever actually arrives in chat is a channel we can use without
        -- waiting for a keypress.
        print("|cff00ff00RPVox:|r testing in 2 seconds. "
            .. "|cffff8800Do not touch the keyboard or mouse until it reports.|r")
        C_Timer.After(2, function()
            local results = {}
            for _, c in ipairs({ "SAY", "EMOTE", "PARTY", "RAID", "GUILD" }) do
                local ok = pcall(SendChatMessage, "RPVox auto-test: " .. c, c)
                table.insert(results, c .. (ok and "" or " (lua error)"))
            end
            print("|cff00ff00RPVox:|r attempted " .. table.concat(results, ", "))
            print("  Which of those actually appeared in chat? Those are the "
                .. "channels that work without input.")
        end)

    elseif cmd == "help" then
        print("|cff00ff00RPVox|r")
        print("  /rpcry                 open the settings window")
        print("  /rpcry on | off        kill switch for this profile")
        print("  /rpcry profile         list profiles")
        print("  /rpcry profile <name>  use that profile on this character")
        print("  /rpcry mood            show moods in this profile")
        print("  /rpcry mood <name>     only say lines tagged [name] (or 'any')")
        print("  /rpcry status          what is armed right now")
        print("  /rpcry debug           log why lines do or do not fire")
        print("  /rpcry testfire        send one line immediately")

    else
        RPVox:ToggleUI()
    end
end
