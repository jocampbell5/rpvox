-- RPVox -- speech bubble
--
-- Draws its own bubble because the engine only makes real chat bubbles for
-- real chat messages, and RPVox sends addon messages. It also cannot follow
-- your head: this client has no world-to-screen call, so it sits where you
-- drag it. Only you see it -- it is a frame on your screen, not a world object.
--
-- Text is laid out one character at a time, and every character carries its
-- own size, outline, colour, alpha and effect. That is what makes inline
-- emphasis possible: one clause can whisper while the next shouts.
--
--   *loud*      bigger, heavy outline
--   _quiet_     smaller, faded
--   ~wavy~      rides a sine wave
--   #shaky#     jitters   (# and not !, which real lines use 754 times)
--   ^tall^      squashes and stretches vertically
--
-- A line may also open with a scheme tag, which sets colour and motion for
-- the whole line -- the same shape as the existing [mood] prefix:
--
--   Come on baby, {fire}#LIGHT MY FIRE#{/}, %t.
--
-- The tag colours only the span it wraps, so the rest of the line stays the
-- pack's ordinary colour. Left unclosed it runs to the end of the line.
--
-- Markers are stripped before the line reaches the chat frame, which can only
-- render colour and would otherwise show the punctuation raw.

local HOLD_SECONDS = 4
local FADE_SECONDS = 1.5
local MAX_WIDTH    = 320
-- Added to the tallest glyph on a line. Small on purpose: the layout already
-- reserves headroom for stretch, so a generous gap here reads as double
-- spacing on ordinary lines.
local LINE_GAP     = 2
-- Peak of the stretch pulse. The effect and the layout must agree on it:
-- the layout reserves this much room so a swelling letter has somewhere
-- to go instead of climbing over its neighbour.
local STRETCH_PEAK = 1.35

-- Ordinary speech is white. The parchment used in the chat frame exists to
-- separate RPVox lines from real /say; inside the bubble there is nothing to
-- confuse it with, and a tinted base leaves coloured spans nothing to stand
-- out against. Packs still differ by size, outline and motion -- colour is
-- reserved for the words that earn it, via {fire}, {frost} and the rest.
local WHITE = { 1.00, 1.00, 1.00 }

local STYLES = {
    MAGE_LYRICS       = { size = 15, outline = "OUTLINE",
                          colour = WHITE, effect = "none"   },
    MAGE_ANIMATED     = { size = 15, outline = "OUTLINE",
                          colour = WHITE, effect = "none"   },
    PRIEST_LYRICS     = { size = 14, outline = "",
                          colour = WHITE, effect = "none"   },
    PRIEST_RHYMING    = { size = 14, outline = "",
                          colour = WHITE, effect = "wave"   },
    -- Drift, not wave: a slow sway with the alpha breathing under it. The
    -- rhyming priest lilts; this one should look like it is not quite there.
    PRIEST_DIRGE      = { size = 14, outline = "",
                          colour = WHITE, effect = "drift"  },
    HUNTER_VALLEYGIRL = { size = 14, outline = "",
                          colour = WHITE, effect = "bounce" },
    WARRIOR_BARBARIAN = { size = 20, outline = "THICKOUTLINE",
                          colour = WHITE, effect = "shake"  },
}
local DEFAULT_STYLE = { size = 14, outline = "", colour = WHITE, effect = "none" }

-- Inline markers. Each adjusts the base style for the span it wraps.
local MARKERS = {
    ["*"] = { sizeMul = 1.35, outline = "THICKOUTLINE", effect = "none"   },
    ["_"] = { sizeMul = 0.82, alpha = 0.65,             effect = "none"   },
    ["~"] = { effect = "wave"  },
    ["#"] = { effect = "shake"   },
    ["^"] = { effect = "stretch" },
}

-- Line-level schemes. Colour and motion together, so a frost line reads cold
-- and a fire line reads hot without either being spelled out per character.
-- Schemes set colour only. Motion belongs on the word that earns it, via the
-- inline markers -- a whole line in permanent motion reads as a screensaver,
-- not as speech. "Great balls of *FIIIRE*!" is the shape being aimed at.
local SCHEMES = {
    frost   = { colour = { 0.55, 0.85, 1.00 }, effect = "none" },
    fire    = { colour = { 1.00, 0.45, 0.20 }, effect = "none" },
    arcane  = { colour = { 0.78, 0.55, 1.00 }, effect = "none" },
    holy    = { colour = { 1.00, 0.94, 0.70 }, effect = "none" },
    shadow  = { colour = { 0.62, 0.45, 0.85 }, effect = "none" },
    nature  = { colour = { 0.55, 0.95, 0.55 }, effect = "none" },
    plain   = { colour = nil,                  effect = "none" },
}

-- Reveal speed. Seconds per character: 0.022 was 45 characters a second,
-- which arrives faster than it reads; this is closer to a dialogue box.
--
-- There is no audio here any more. The bubble had a typewriter tick and a
-- one-off accent when a coloured span opened, both built from whatever sound
-- kits happened to exist on this client rather than from anything that suited
-- the character -- every race, every class and every spell school sounded the
-- same, and the accents were placeholders from the day they went in.
--
-- Racial voices were the fix and the client will not support them cheaply: a
-- sound kit is a bare number with no way to ask what it holds, so every race
-- would have to be found by ear, one id at a time. Doing it properly means
-- bundling short .ogg files with the addon, which puts download weight on
-- everybody for something most players would turn off. Until that trade is
-- worth making, the bubble is silent.
local CHAR_TIME  = 0.055

-- RPVox.lua keeps Debug as a file-local and hangs a copy on the addon table.
-- A bare Debug() in this file therefore reaches a global that does not exist,
-- and throws the moment that line runs -- which shipped in 4.6 and fired every
-- time a bubble had no nameplate to sit on. Wrapped once, here, rather than
-- left to be got right at each call site.
local function Debug(...)
    if RPVox and RPVox.Debug then RPVox.Debug(...) end
end

local pinned, demoIndex, scaleMode

-- One bubble per speaker -----------------------------------------------------
-- Yours, plus one for anybody nearby whose lines arrive. The frame, the fade
-- timer and the generation counter used to be three module-level locals, which
-- is precisely why there could only ever be one bubble on screen: a second
-- speaker overwrote the first one's frame and cancelled its timers.
--
-- They live on a record per speaker now. The key is the speaker's name, except
-- for yours, which uses a sentinel no player name can collide with.
local MINE = "\0you"
local bubbles = {}      -- [owner] = { frame, fadeTimer, showId, owner, slot }

-- Who currently has a nameplate, by name. Built from NAME_PLATE_UNIT_ADDED and
-- _REMOVED at the bottom of this file, which hand over the unit token directly.
--
-- The obvious alternative is to read `namePlateUnitToken` off the plate frame,
-- and that is what this used to do. It is not documented, it is not present on
-- every client, and when it is missing every check that reads it silently
-- decides the plate is wrong -- which took the bubble off the character's head
-- one frame after it landed there, so the anchor looked like it never worked
-- at all. The events are the supported way to learn the same thing.
local plateUnit = {}    -- [name] = unit token

-- One name for both sides. Bubble keys come from Ambiguate(sender, "none"),
-- which keeps "-Realm" for anyone not on your own realm; UnitName hands the
-- realm back separately. Building the same shape from a unit is what lets a
-- cross-realm speaker's bubble find their plate at all -- on a pooled
-- anniversary cluster that is most of the people around you -- and it also
-- stops two same-named strangers from different realms sharing one map entry.
local function FullName(unit)
    local n, r = UnitName(unit)
    if not n then return nil end
    if r and r ~= "" then return n .. "-" .. r end
    return n
end

-- Per-frame drivers, applied per character.
local EFFECTS = {
    none   = function(c) c:SetPoint("BOTTOMLEFT", c.bx, c.by) end,
    wave   = function(c, i, t)
        c:SetPoint("BOTTOMLEFT", c.bx, c.by + math.sin(t * 4 + i * 0.45) * 3.5)
    end,
    bounce = function(c, i, t)
        c:SetPoint("BOTTOMLEFT", c.bx, c.by + math.abs(math.sin(t * 6 + i * 0.6)) * 5)
    end,
    drift  = function(c, i, t)
        c:SetPoint("BOTTOMLEFT", c.bx, c.by + math.sin(t * 1.6 + i * 0.3) * 2)
        c.text:SetAlpha((c.baseAlpha or 1) * (0.75 + 0.25 * math.sin(t * 2 + i * 0.4)))
    end,
    -- math.abs, not a plain subtraction. `t` is the bubble's age and resets to
    -- zero on every new line, while jitterAt lives on the reused character
    -- frame. After a long line, t - jitterAt is a large negative number, the
    -- re-roll never fires, and the glyph freezes at whatever offset the
    -- previous line left it holding. Layout clears these too; this is the belt
    -- to that pair of braces.
    shake  = function(c, i, t)
        if math.abs(t - (c.jitterAt or -1)) > 0.05 then
            c.jitterAt = t
            c.jx, c.jy = (math.random() - 0.5) * 3, (math.random() - 0.5) * 3
        end
        c:SetPoint("BOTTOMLEFT", c.bx + (c.jx or 0), c.by + (c.jy or 0))
    end,
    -- Emissive: no movement, only brightness. Arcane and holy read as lit
    -- from within rather than restless.
    glow   = function(c, i, t)
        c:SetPoint("BOTTOMLEFT", c.bx, c.by)
        c.text:SetAlpha((c.baseAlpha or 1) * (0.62 + 0.38 * math.sin(t * 3 + i * 0.25)))
    end,
    -- Fire: fast, small, irregular. Jitter alone reads as fear, so the
    -- brightness moves with it.
    flicker = function(c, i, t)
        if math.abs(t - (c.jitterAt or -1)) > 0.07 then
            c.jitterAt = t
            c.jx, c.jy = (math.random() - 0.5) * 1.6, (math.random() - 0.5) * 1.6
            c.ja = 0.72 + math.random() * 0.28
        end
        c:SetPoint("BOTTOMLEFT", c.bx + (c.jx or 0), c.by + (c.jy or 0))
        c.text:SetAlpha((c.baseAlpha or 1) * (c.ja or 1))
    end,
    -- Driven from OnUpdate rather than by a Scale animation. The animation
    -- route reported working on this client -- SetScaleFrom present, group
    -- built, IsPlaying true -- and still rendered nothing, so the scale was
    -- not reaching the child FontString. Doing it by hand is one line and
    -- cannot silently no-op.
    --
    -- SetScale is uniform, so this is a staggered per-letter pulse rather
    -- than a true horizontal squash. Read across the word it gives the
    -- rippling squash-and-stretch that the effect is named for.
    stretch = function(c, i, t)
        local s = 1 + (STRETCH_PEAK - 1) * math.sin(t * 5 + i * 0.5)
        c:SetScale(s)
        -- A frame's point offsets are measured in its own scaled space, so
        -- dividing keeps the glyph anchored where it started instead of
        -- sliding off as it grows.
        c:SetPoint("BOTTOMLEFT", c.bx / s, c.by / s)
    end,
}

-- Probe once: the Scale setter was renamed across client versions, and on
-- some it is missing altogether.
local function ScaleMode()
    if scaleMode then return scaleMode end
    local probe = CreateFrame("Frame", nil, UIParent)
    local ok, anim = pcall(function()
        return probe:CreateAnimationGroup():CreateAnimation("Scale")
    end)
    if not ok or not anim then
        scaleMode = "pulse"
    elseif anim.SetScaleFrom then
        scaleMode = "SetScaleFrom"
    elseif anim.SetFromScale then
        scaleMode = "SetFromScale"
    elseif anim.SetScale then
        scaleMode = "SetScale"
    else
        scaleMode = "pulse"
    end
    return scaleMode
end

-- Scale animations are no longer used for stretch; EFFECTS.stretch drives it
-- from OnUpdate instead. Any group built by an older session is stopped so it
-- cannot fight the manual scaling.
local function PrepareStretch(c, on)
    if c.ag then c.ag:Stop() end
    c.wantStretch = false
end

local function Chars(s)
    local out, i = {}, 1
    while i <= #s do
        local b = s:byte(i)
        local n = (b < 0x80 and 1) or (b < 0xE0 and 2) or (b < 0xF0 and 3) or 4
        out[#out + 1] = s:sub(i, i + n - 1)
        i = i + n
    end
    return out
end

-- Split into characters, each carrying the style in force where it appears.
local function Parse(text, base)
    local out, active, scheme = {}, nil, nil
    local chars = Chars(text)
    local i = 1
    while i <= #chars do
        local ch = chars[i]

        -- {fire}...{/} colours just that span. Left open, it runs to the end
        -- of the line, which is what a leading tag relies on.
        if ch == "{" then
            local j, name = i + 1, ""
            while j <= #chars and chars[j] ~= "}" do
                name = name .. chars[j]
                j = j + 1
            end
            if j <= #chars then
                if name == "/" then
                    scheme = nil
                else
                    scheme = SCHEMES[name:lower()]
                end
                i = j + 1
            else
                i = i + 1          -- unmatched brace: drop it, do not hang
            end
        else
            local m = MARKERS[ch]
            if m and (active == nil or active == m) then
                -- Written long-hand on purpose. The obvious
                --     active = (active == m) and nil or m
                -- is the classic Lua and/or trap: "true and nil" is nil, so
                -- the "or" arm always wins and closing a marker reopened it.
                if active == m then
                    active = nil
                else
                    active = m
                end
            else
                local a = active
                out[#out + 1] = {
                    ch      = ch,
                    size    = math.floor(base.size * ((a and a.sizeMul) or 1) + 0.5),
                    outline = (a and a.outline) or base.outline,
                    alpha   = (a and a.alpha) or 1,
                    effect  = (a and a.effect ~= "none" and a.effect) or base.effect,
                    -- {plain} carries no colour, so it falls through to the
                    -- pack's own rather than blanking the text.
                    colour  = (scheme and scheme.colour) or base.colour,
                }
            end
            i = i + 1
        end
    end
    return out
end

-- The chat frame renders colour and nothing else, so markers must come out.
local function Strip(text)
    text = text:gsub("{/?%a*}", "")      -- scheme tags never reach chat
    return (text:gsub("[%*_~#%^]", ""))
end
RPVox.StripMarkup = function(_, t) return Strip(t or "") end

local function SavePosition(f)
    local point, _, _, x, y = f:GetPoint()
    RPVoxDB.bubble = { point = point, x = x, y = y }
end

local function ApplyPosition(f)
    local p = RPVoxDB and RPVoxDB.bubble
    f:ClearAllPoints()
    if p and p.point then
        f:SetPoint(p.point, UIParent, p.point, p.x, p.y)
    else
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    end
end

local function Create(owner)
    local mine = (owner == MINE)
    local template = BackdropTemplateMixin and "BackdropTemplate" or nil
    -- Only yours takes the global name. A second frame claiming it would
    -- silently replace the first in _G, and /rpvox bubble would then be
    -- dragging whichever stranger spoke last.
    local f = CreateFrame("Frame", mine and "RPVoxBubbleFrame" or nil,
                          UIParent, template)
    f:SetFrameStrata("HIGH")
    f:SetClampedToScreen(true)
    f:Hide()

    if f.SetBackdrop then
        f:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\ChatBubble-Background",
            edgeFile = "Interface\\Tooltips\\ChatBubble-Backdrop",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 16, right = 16, top = 16, bottom = 16 },
        })
        f:SetBackdropColor(0, 0, 0, 0.75)
        f:SetBackdropBorderColor(1, 1, 1, 0.9)
    end

    f.chars = {}
    f.measure = f:CreateFontString(nil, "ARTWORK")
    f.measure:Hide()

    if mine then
        f:SetMovable(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", function(self) if pinned then self:StartMoving() end end)
        f:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            SavePosition(self)
        end)
    else
        -- Somebody else's bubble says whose it is. Above the backdrop rather
        -- than inside it, so it cannot be mistaken for part of what they said
        -- and the layout never has to make room for it.
        f.who = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        f.who:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 16, 2)
        f.who:SetJustifyH("LEFT")
    end

    f:SetScript("OnUpdate", function(self, elapsed)
        self.age = (self.age or 0) + elapsed

        -- A bubble pinned over somebody's head has to keep checking that the
        -- head is still theirs. Nameplates are pooled: the one this is hanging
        -- off can be handed to a different unit, or hidden, while the bubble is
        -- still up -- and a line then sits over a stranger, or over nothing.
        -- Checked here rather than on a timer because this is already running.
        local rec = self.record
        if rec and rec.plate then
            -- Only give up when the plate can be *shown* to be wrong. Anything
            -- unknown leaves it where it is: a check that treats "cannot tell"
            -- as "wrong" pulls the bubble off the character every frame.
            local unit = plateUnit[rec.owner]
            local gone = not rec.plate:IsShown()
                      or (unit and FullName(unit) ~= rec.owner)
            if gone then
                rec.plate = nil
                -- Only other players' bubbles carry a re-placer; your own is
                -- positioned by ShowOn and has no slot to fall back into.
                if rec.replace then rec.replace(rec) end
            end
        end

        local n = self.charCount or 0
        if n == 0 then return end

        -- Reveal a character at a time, the way a dialogue box does.
        local want = math.min(n, math.floor(self.age / CHAR_TIME) + 1)
        local done = self.revealed or 0
        if want > done then
            for k = done + 1, want do
                self.chars[k]:Show()
            end
            self.revealed = want
        end

        for i = 1, want do
            local c = self.chars[i]
            local fn = EFFECTS[c.effect or "none"]
            if fn then fn(c, i, self.age) end
        end
    end)

    ApplyPosition(f)
    return f
end

local function CharFrame(f, i)
    local c = f.chars[i]
    if c then return c end
    c = CreateFrame("Frame", nil, f)
    c:SetSize(1, 1)
    c.text = c:CreateFontString(nil, "OVERLAY")
    c.text:SetPoint("BOTTOMLEFT", 0, 0)
    f.chars[i] = c
    return c
end

local function Layout(f, text, style)
    local font = STANDARD_TEXT_FONT
    local glyphs = Parse(text, style)

    -- Widths are measured cumulatively, not one glyph at a time. Measuring
    -- "W" then "A" separately throws away the kerning pair between them, and
    -- every letter ends up padded to its own bounding box -- which is what
    -- made the text look spaced out. Measuring "W" then "WA" and taking the
    -- difference gives the real advance, kerning included.
    --
    -- Only glyphs sharing a font can be measured in one run, so the string is
    -- walked in runs of matching size and outline. Spaces are measured as
    -- non-breaking, because GetStringWidth trims a trailing ordinary space.
    --
    -- `advance` is how much room the layout leaves after a glyph, which is
    -- wider than the drawn width for stretch: laid out at rest size, a
    -- swelling letter would climb over its neighbour.
    local widths, advance = {}, {}
    local i = 1
    while i <= #glyphs do
        local j = i
        while j < #glyphs
              and glyphs[j + 1].size == glyphs[i].size
              and glyphs[j + 1].outline == glyphs[i].outline do
            j = j + 1
        end
        f.measure:SetFont(font, glyphs[i].size, glyphs[i].outline)
        local acc, prev = "", 0
        for k = i, j do
            local ch = glyphs[k].ch
            acc = acc .. (ch == " " and "\194\160" or ch)
            f.measure:SetText(acc)
            local total = f.measure:GetStringWidth()
            widths[k] = total - prev
            prev = total
            advance[k] = widths[k]
                       * (glyphs[k].effect == "stretch" and STRETCH_PEAK or 1)
        end
        i = j + 1
    end

    local biggest = style.size
    for _, g in ipairs(glyphs) do
        -- A stretched line also needs the taller row, or the peak clips.
        local h = g.size * (g.effect == "stretch" and STRETCH_PEAK or 1)
        biggest = math.max(biggest, h)
    end
    local lineH = biggest + LINE_GAP

    local x, maxX, line, placed, i = 0, 0, 1, {}, 1
    while i <= #glyphs do
        local wordEnd, wordW = i, 0
        while wordEnd <= #glyphs and glyphs[wordEnd].ch ~= " " do
            wordW = wordW + advance[wordEnd]
            wordEnd = wordEnd + 1
        end
        if x > 0 and x + wordW > MAX_WIDTH then x, line = 0, line + 1 end
        for j = i, math.min(wordEnd, #glyphs) do
            placed[j] = { x = x, line = line }
            x = x + advance[j]
        end
        maxX = math.max(maxX, x)
        i = wordEnd + 1
    end

    for idx, g in ipairs(glyphs) do
        local p, c = placed[idx], CharFrame(f, idx)
        c.text:SetFont(font, g.size, g.outline)
        c.text:SetText(g.ch)
        local col = g.colour or style.colour
        c.text:SetTextColor(col[1], col[2], col[3])
        c.text:SetAlpha(g.alpha)
        c.baseAlpha, c.baseSize, c.outline, c.effect = g.alpha, g.size, g.outline, g.effect
        c.ch = g.ch
        -- Character frames are pooled, so anything an effect stashed on this
        -- frame belongs to the previous line and must not be inherited.
        c.jitterAt, c.jx, c.jy, c.ja, c.pulseAt = nil, 0, 0, 1, nil
        c:SetSize(math.max(1, widths[idx]), g.size)
        c.bx = 18 + p.x
        c.by = 16 + (line - p.line) * lineH
        c:SetPoint("BOTTOMLEFT", c.bx, c.by)
        c:SetScale(1)
        PrepareStretch(c, g.effect == "stretch")
        c:Hide()          -- the reveal in OnUpdate shows it
    end
    for idx = #glyphs + 1, #f.chars do
        PrepareStretch(f.chars[idx], false)
        f.chars[idx]:Hide()
    end

    f.charCount = #glyphs
    f.age = 0
    f.revealed = 0
    f:SetSize(math.min(MAX_WIDTH, maxX) + 40, line * lineH + 30)
end

local Bubble = {}

local function Get(owner)
    local b = bubbles[owner]
    if not b then
        b = { owner = owner, showId = 0, frame = Create(owner) }
        bubbles[owner] = b
    end
    return b
end

-- Where somebody else's bubble goes ------------------------------------------
-- Over their head, if the client will say where their head is. That needs a
-- nameplate for them, and friendly nameplates are off by default on this
-- client, so most of the time it will not -- which is why there is a fallback
-- rather than a requirement.
--
-- Failing that they stack under your own bubble, one slot each, newest into
-- the first free slot. Slots rather than a running total because bubbles
-- expire in whatever order they were spoken, and a list that renumbered itself
-- would make everybody else's bubble jump every time one faded.
-- The gap between stacked bubbles, and the room an empty slot keeps for
-- itself. A fixed step per slot was the obvious version and it was wrong: a
-- bubble is as tall as the line is long, so a three-line one ran straight
-- through whatever sat under it.
local STACK_GAP  = 8
local STACK_STEP = 56       -- an unused slot holds this much space open
local MAX_OTHERS = 6
local slots = {}

local function UnitFor(name)
    local function is(u)
        return UnitExists(u) and FullName(u) == name and u or nil
    end

    -- Nameplates first. They are the only source that covers everybody in
    -- sight rather than the one unit you happen to be pointing at, and a plate
    -- is the thing being looked for in the first place.
    local tracked = plateUnit[name]
    if tracked and is(tracked) then return tracked end

    local u = is("target") or is("mouseover") or is("focus")
    if u then return u end
    for i = 1, 4 do
        u = is("party" .. i)
        if u then return u end
    end
    for i = 1, 40 do
        u = is("raid" .. i)
        if u then return u end
    end
    return nil
end

-- Floating above the 3D character ------------------------------------------
-- A nameplate is not a HUD element. The engine places that frame at the unit's
-- head in the world and moves it as they run, which makes it the only handle
-- an addon has on a world position -- there is no WorldToScreen call to do it
-- ourselves. Anchoring to it is what puts a bubble over the character model.
--
-- The price is that the plate has to exist, and friendly player plates are off
-- by default. So this turns them on, and hides the health bar and name the
-- plate would otherwise draw, leaving the positioned frame and nothing else to
-- look at. That is the whole feature: the anchor without the clutter.
--
-- If a nameplate addon is installed it owns that art and this will not fight
-- it -- the bubble still anchors correctly, you just get their nameplates too.
--
-- Two CVars, not one. nameplateShowFriends is the obvious half; the other is
-- nameplateShowAll, and with it off this client only draws plates for units in
-- combat at all -- which is exactly "my nameplates only come on when I fight".
-- World mode setting only the first produced no plates whatsoever out of
-- combat, so there was nothing to anchor to and every bubble fell back to the
-- stack, looking as if the anchoring itself were broken.
-- CVar access that works whichever API this client carries. The plain GetCVar
-- global read back nil here -- the in-game test printed "friendly plates ....
-- nil" -- so go through C_CVar first, the old globals second, and the console
-- as a last resort. Every set is verified by reading the value back: a pcall
-- wrapped around a function that turned out not to exist is how world mode
-- shipped doing nothing and saying nothing.
local function CVarGet(name)
    if C_CVar and C_CVar.GetCVar then
        local ok, v = pcall(C_CVar.GetCVar, name)
        if ok and v ~= nil then return v end
    end
    if GetCVar then
        local ok, v = pcall(GetCVar, name)
        if ok and v ~= nil then return v end
    end
    return nil
end

local function CVarSet(name, value)
    value = tostring(value)
    if C_CVar and C_CVar.SetCVar then pcall(C_CVar.SetCVar, name, value) end
    if CVarGet(name) == value then return true end
    if SetCVar then pcall(SetCVar, name, value) end
    if CVarGet(name) == value then return true end
    if ConsoleExec then pcall(ConsoleExec, name .. " " .. value) end
    return CVarGet(name) == value
end

-- The names are NOT hardcoded, because guessing them is how this feature spent
-- an evening doing nothing: "nameplateShowFriends" does not exist on this
-- client, every set was silently discarded, and the readback said nil while the
-- addon reported success. The client is asked what it actually has instead.
--
-- C_Console.GetAllCommands lists every console command and CVar this build
-- registers. Anything with "nameplate" and "friend" in its name is what draws
-- plates for friendly units, whatever it happens to be called here, and
-- "nameplateShowAll" is the separate out-of-combat switch.
-- Names to probe when the client will not enumerate its own commands, which
-- is the case here: C_Console.GetAllCommands came back empty on 2.5.6. Reading
-- a CVar that exists returns a value; one that does not returns nil, so the
-- list below costs nothing to try and tells us exactly what this build has.
local CANDIDATE_CVARS = {
    -- friendly units, in every spelling the various clients have used
    "nameplateShowFriends",
    "nameplateShowFriendlyNPCs",
    "nameplateShowFriendlyMinions",
    "nameplateShowFriendlyTotems",
    "nameplateShowFriendlyGuardians",
    "nameplateShowFriendlyPets",
    "nameplateShowFriendlyUnits",
    "nameplateShowFriendlyPlayers",
    -- your own, if this client has one at all
    "nameplateShowSelf",
    -- and the ones that decide whether plates show at all
    "nameplateShowAll",
    "nameplateShowEnemies",
    "ShowClassColorInNameplate",
    "UnitNameFriendlyPlayerName",
}

local function PlateCVarNames()
    local out, seen = {}, {}

    -- Enumeration first, when the client offers it.
    if C_Console and C_Console.GetAllCommands then
        local ok, cmds = pcall(C_Console.GetAllCommands)
        if ok and type(cmds) == "table" then
            for _, c in ipairs(cmds) do
                local n = type(c) == "table" and c.command or c
                if type(n) == "string" and n:lower():find("nameplate", 1, true)
                   and not seen[n] then
                    seen[n] = true
                    table.insert(out, n)
                end
            end
        end
    end

    -- Then probe the candidates. On this client the list above comes back
    -- empty, so this is the path that actually reports anything.
    for _, n in ipairs(CANDIDATE_CVARS) do
        if not seen[n] and CVarGet(n) ~= nil then
            seen[n] = true
            table.insert(out, n)
        end
    end

    table.sort(out)
    return out
end

-- Which of them world mode should set, and to what. Only ones this client
-- really registers, so a set can no longer vanish into a name that is not there.
local function WorldCVars()
    local want, names = {}, PlateCVarNames()
    for _, n in ipairs(names) do
        local l = n:lower()
        -- "show friends", "showFriendlyPlayers", "showFriendlyUnits" ...
        -- whichever shape this build uses, it has both words in it.
        --
        -- Players only. This client splits friendly plates into players, NPCs,
        -- minions, totems and pets, and RPVox lines only ever come from a
        -- player -- switching the rest on would put a nameplate over every
        -- vendor, guard and hunter pet in town for no benefit at all.
        local everythingElse = l:find("npc", 1, true) or l:find("minion", 1, true)
                            or l:find("totem", 1, true) or l:find("guardian", 1, true)
                            or l:find("pet", 1, true)
        if l:find("show", 1, true) and l:find("friend", 1, true)
           and not everythingElse then
            want[n] = "1"
        elseif l == "nameplateshowall" or l == "nameplateshowself" then
            want[n] = "1"
        end
    end
    return want, names
end

local function AllPlates()
    if not (C_NamePlate and C_NamePlate.GetNamePlates) then return {} end
    local ok, list = pcall(C_NamePlate.GetNamePlates)
    return (ok and type(list) == "table") and list or {}
end

-- Only friendly players' plates lose their art. The first version hid every
-- plate that appeared while world mode was on -- including the mob you had
-- just pulled, which took its health bar with it. A mob's plate is not
-- carrying a bubble and its bar is combat information; leave it alone.
--
-- What was hidden is remembered, because nothing else puts it back: turning
-- world mode off restores the CVars but any plate that survives that (a mob
-- in combat, or plates that were already on) would stay artless for as long
-- as the frame lives.
local hiddenArt = {}    -- [plate frame] = true while its art is hidden by us

local function HidePlateArt(plate, unit)
    if not (RPVoxDB and RPVoxDB.world) then return end
    if not (unit and UnitIsPlayer and UnitIsPlayer(unit)
            and UnitIsFriend and UnitIsFriend("player", unit)) then
        return
    end
    local art = plate and plate.UnitFrame
    if art and art.Hide then
        pcall(art.Hide, art)
        hiddenArt[plate] = true
    end
end

local function ShowPlateArt(plate)
    local art = plate and plate.UnitFrame
    if art and art.Show then pcall(art.Show, art) end
    hiddenArt[plate] = nil
end

local function ShowAllPlateArt()
    for plate in pairs(hiddenArt) do ShowPlateArt(plate) end
end

-- Writes the settings world mode depends on and hides the friendly plate art.
-- Split out of the toggle, because the toggle is not the only time it has to
-- run: RPVoxDB.world is saved to disk, so a session starting with world mode
-- already on loaded with the flag set and the settings untouched -- world mode
-- reporting "on" while the nameplates it needs stayed off. Every reload after
-- the CVar names were corrected sat in exactly that state, which is why
-- turning friendly nameplates on by hand was the only thing that worked.
--
-- Returns: refused list, the targets table (nil if this client has none),
-- and every nameplate setting found, for the caller to report on.
local function ApplyWorldCVars()
    local targets, allNames = WorldCVars()
    if not next(targets) then return {}, nil, allNames end

    -- Never overwrite a snapshot that is already there: if the last turn-off
    -- could not restore a value, the true original is still in worldPrev, and
    -- re-reading the CVar now would capture the forced "1" and lose it.
    RPVoxDB.worldPrev = RPVoxDB.worldPrev or {}
    local refused = {}
    for cvar, want in pairs(targets) do
        if RPVoxDB.worldPrev[cvar] == nil then
            RPVoxDB.worldPrev[cvar] = CVarGet(cvar)
        end
        if not CVarSet(cvar, want) then table.insert(refused, cvar) end
    end

    for _, unit in pairs(plateUnit) do
        if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if ok then HidePlateArt(plate, unit) end
        end
    end
    return refused, targets, allNames
end

-- Called at login. World mode surviving a reload has to mean the settings it
-- depends on survive it too.
function Bubble:Mine()
    RPVoxDB.hideMine = not RPVoxDB.hideMine
    print("|cff00ff00RPVox:|r your own bubble is "
        .. (RPVoxDB.hideMine
            and "|cffff8800hidden|r -- your lines still go out and still reach "
                .. "other people's screens."
            or "|cff00ff00shown|r."))
end

function Bubble:Reapply()
    if not (RPVoxDB and RPVoxDB.world) then return end
    if InCombatLockdown and InCombatLockdown() then return end
    local refused = ApplyWorldCVars()
    if refused and #refused > 0 then
        table.sort(refused)
        print("|cffff0000RPVox:|r world mode is on but this client refused: "
            .. table.concat(refused, ", ") .. " -- lines will stay stacked.")
    end
end

function Bubble:World(state)
    -- Long-hand deliberately. The obvious
    --     RPVoxDB.world = (state == nil) and not RPVoxDB.world or state
    -- is the and/or trap this addon has been bitten by before: switching it
    -- off makes the middle arm false, so the "or" wins and the flag ends up as
    -- whatever `state` was rather than as false.
    if state == nil then
        RPVoxDB.world = not RPVoxDB.world
    else
        RPVoxDB.world = state and true or false
    end

    if RPVoxDB.world then
        if InCombatLockdown and InCombatLockdown() then
            print("|cffff0000RPVox:|r cannot change nameplate settings in "
                .. "combat. Try again once you are out.")
            RPVoxDB.world = false
            return
        end
        local refused, targets, allNames = ApplyWorldCVars()
        if not targets then
            print("|cffff0000RPVox:|r this client registers no nameplate "
                .. "visibility settings I can find"
                .. (#allNames > 0 and (" (it has: " .. table.concat(allNames, ", ") .. ")")
                                   or " and exposes no command list")
                .. ". Run |cffffd100/rpvox bubble cvars|r and send me that.")
            RPVoxDB.world = false
            return
        end

        if #refused > 0 then
            -- Said out loud, with the readback to prove it. The last version
            -- failed here silently and the symptom surfaced two features away.
            table.sort(refused)
            print("|cffff0000RPVox:|r this client refused: "
                .. table.concat(refused, ", ")
                .. " -- lines will stay stacked. Worth trying by hand:")
            for _, cvar in ipairs(refused) do
                print("  |cffffd100/console " .. cvar .. " 1|r")
            end
        else
            print("|cff00ff00RPVox:|r lines now float above the character. "
                .. "Friendly nameplates are on -- and on out of combat -- to "
                .. "hold them there, with their bars and names hidden.")
            print("  |cffffd100/rpvox bubble world|r again to put it back.")
        end
    else
        -- The same combat lock the ON branch guards against. Without this,
        -- turning world mode off mid-fight silently failed every restore,
        -- then threw away the saved originals while printing "restored" --
        -- leaving nameplates forced on with no record of the old values.
        if InCombatLockdown and InCombatLockdown() then
            RPVoxDB.world = true      -- the toggle did not happen
            print("|cffff0000RPVox:|r cannot change nameplate settings in "
                .. "combat. Try again once you are out.")
            return
        end

        -- The first build of this feature saved only the one CVar, under the
        -- old key. Fold it in so those settings restore too.
        if not RPVoxDB.worldPrev and RPVoxDB.worldPrevCVar then
            RPVoxDB.worldPrev = { nameplateShowFriends = RPVoxDB.worldPrevCVar }
        end

        -- Only forget an original once it has verifiably been put back. A
        -- value the client refuses stays saved for the next attempt.
        local kept = {}
        for cvar, prev in pairs(RPVoxDB.worldPrev or {}) do
            if not CVarSet(cvar, prev) then kept[cvar] = prev end
        end
        RPVoxDB.worldPrevCVar = nil
        RPVoxDB.worldPrev = next(kept) and kept or nil

        ShowAllPlateArt()

        if next(kept) then
            local names = {}
            for cvar in pairs(kept) do table.insert(names, cvar) end
            table.sort(names)
            print("|cffff0000RPVox:|r back to stacked bubbles, but the client "
                .. "refused to restore: " .. table.concat(names, ", ")
                .. ". Your original values are kept and will be retried the "
                .. "next time world mode is turned off.")
        else
            print("|cff00ff00RPVox:|r back to stacked bubbles. "
                .. "Nameplate settings restored.")
        end
    end
end

local function PlateForUnit(unit)
    if not (C_NamePlate and C_NamePlate.GetNamePlateForUnit) then return nil end
    if not (unit and UnitExists(unit)) then return nil end
    local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
    if ok and plate and plate.IsShown and plate:IsShown() then return plate end
    return nil
end

local function PlateFor(name)
    if not (C_NamePlate and C_NamePlate.GetNamePlateForUnit) then return nil end
    local unit = UnitFor(name)
    if not unit then return nil end
    local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
    if ok and plate and plate.IsShown and plate:IsShown() then return plate end
    return nil
end

local function TakeSlot(b)
    if b.slot then return b.slot end
    for i = 1, MAX_OTHERS do
        if not slots[i] then
            slots[i], b.slot = b.owner, i
            return i
        end
    end
    b.slot = MAX_OTHERS      -- everyone is talking at once; share the last one
    return b.slot
end

local function FreeSlot(b)
    if b.slot and slots[b.slot] == b.owner then slots[b.slot] = nil end
    b.slot = nil
end

-- Where the stack starts: below your own bubble when it is up, not at its
-- anchor point. The drop used to start at zero, so a tall bubble of your own
-- sat on top of the first stranger's.
local function StackBase()
    local mine = bubbles[MINE]
    if mine and mine.frame and mine.frame:IsShown() then
        return mine.frame:GetHeight() + STACK_GAP
    end
    return 0
end

local function PlaceOther(b)
    local f = b.frame
    f.record = b
    b.replace = PlaceOther     -- so the frame can re-place itself, see Create
    f:ClearAllPoints()

    local plate = PlateFor(b.owner)
    b.plate = plate
    if plate then
        -- Anchored to the plate itself, so it follows them as they move
        -- without this file running anything every frame.
        FreeSlot(b)
        f:SetPoint("BOTTOM", plate, "TOP", 0, 10)
        return
    end

    local slot = TakeSlot(b)

    -- Measured from the real heights of whatever is above, so a long line
    -- pushes the ones below it down instead of sitting on top of them. Slots
    -- nobody is using hold their space rather than collapsing, or every bubble
    -- on screen would jump each time one faded.
    local drop = StackBase()
    for i = 1, slot - 1 do
        local above = slots[i] and bubbles[slots[i]]
        if above and above.frame:IsShown() and not above.plate then
            drop = drop + above.frame:GetHeight() + STACK_GAP
        else
            drop = drop + STACK_STEP
        end
    end
    drop = drop + f:GetHeight() + STACK_GAP

    local p = RPVoxDB and RPVoxDB.bubble
    local point = (p and p.point) or "CENTER"
    local x = (p and p.x) or 0
    local y = (p and p.y) or 200
    f:SetPoint(point, UIParent, point, x, y - drop)
end

-- Re-measure the whole stack. Positions are computed from the heights of the
-- bubbles above, and heights change every time somebody speaks again -- a
-- one-line greeting replaced by a three-line monologue in the same slot used
-- to overrun the bubble beneath it, which kept its stale position.
local function RestackOthers()
    for i = 1, MAX_OTHERS do
        local owner = slots[i]
        local b = owner and bubbles[owner]
        if b and b.frame:IsShown() and not b.plate then
            PlaceOther(b)
        end
    end
end

local function StyleFor()
    local p = RPVox.Profile and RPVox:Profile()
    return (p and STYLES[p.class]) or DEFAULT_STYLE
end

local function ShowOn(owner, text, styleOverride, holdFor)
    if not text or text == "" then return end
    local b = Get(owner)
    local frame = b.frame
    if b.fadeTimer then b.fadeTimer:Cancel() b.fadeTimer = nil end

    -- Every line gets a number, and every timer it schedules checks that the
    -- number is still current before touching anything.
    --
    -- C_Timer.After cannot be cancelled. The hide below used to be scheduled
    -- with it, so when a new line arrived during the previous line's fade,
    -- cancelling the fade timer did nothing to the pending hide -- it fired
    -- anyway and hid the *new* bubble, sometimes mid-reveal. That is why
    -- messages vanished early, why the reveal sometimes never appeared to run,
    -- and why the ticks could still be arriving after the text had gone.
    --
    -- The counter is per speaker now. A shared one meant anybody speaking
    -- invalidated everybody's pending timers.
    b.showId = b.showId + 1
    local myId = b.showId

    Layout(frame, text, styleOverride or StyleFor())
    if owner == MINE then
        -- There is no nameplate above your own head on this client, so your
        -- own bubble is the one that cannot be lifted off the screen. If you
        -- want nothing in the interface at all, this turns it off rather than
        -- leaving it as the last thing floating in the corner.
        if RPVoxDB and RPVoxDB.hideMine and not pinned then
            frame:Hide()
            return
        end

        -- Try your own character first. Where a client draws a self nameplate
        -- it is the personal resource display, which sits at your feet rather
        -- than over your head -- hence the large lift. If this client has no
        -- such plate, and Burning Crusade very likely does not, nothing here
        -- succeeds and the saved screen position is used exactly as before.
        b.plate = (not pinned) and RPVoxDB and RPVoxDB.world
                  and PlateForUnit("player") or nil
        if b.plate then
            frame:ClearAllPoints()
            frame:SetPoint("BOTTOM", b.plate, "TOP", 0, 90)
        else
            ApplyPosition(frame)
        end
    else
        -- The realm stays in the key; nobody needs it over the bubble.
        frame.who:SetText(owner:match("^[^-]+") or owner)
        PlaceOther(b)

        -- Over the character or not at all. Somebody out of view -- behind
        -- you, round a corner, too far away -- has no nameplate, and putting
        -- their line in the corner of the screen is the exact thing world mode
        -- is for avoiding. The chat frame still has it.
        if RPVoxDB and RPVoxDB.world and not b.plate then
            FreeSlot(b)
            frame:Hide()
            Debug("no plate for", owner, "-- world mode, so no bubble")
            return
        end
    end
    UIFrameFadeRemoveFrame(frame)     -- cancel any fade still in flight
    frame:SetAlpha(1)
    frame:Show()

    -- This bubble's new height changes where everything below it belongs.
    RestackOthers()

    if pinned and owner == MINE then return end
    local reveal = (frame.charCount or 0) * CHAR_TIME
    b.fadeTimer = C_Timer.NewTimer((holdFor or HOLD_SECONDS) + reveal, function()
        b.fadeTimer = nil
        if myId ~= b.showId or (pinned and owner == MINE) then return end
        UIFrameFadeOut(frame, FADE_SECONDS, frame:GetAlpha(), 0)
        C_Timer.After(FADE_SECONDS + 0.1, function()
            if myId ~= b.showId or (pinned and owner == MINE) then return end
            UIFrameFadeRemoveFrame(frame)
            frame:Hide()
            frame:SetAlpha(1)
            FreeSlot(b)
        end)
    end)
end

function Bubble:Show(text, styleOverride, holdFor)
    ShowOn(MINE, text, styleOverride, holdFor)
end

-- A line that arrived from somebody else nearby. Their inline markup is kept
-- -- it is theirs, and it is most of what makes the line sound like them --
-- but the base style is yours, because their class pack is not on this
-- machine and the payload does not carry one.
function Bubble:ShowFrom(name, text)
    if type(name) ~= "string" or name == "" then return end
    if RPVoxDB and RPVoxDB.hideOthers then return end
    ShowOn(name, text)
end

function Bubble:TogglePin()
    local frame = Get(MINE).frame
    pinned = not pinned
    if pinned then
        frame:EnableMouse(true)
        self:Show("Drag me where you want your lines to appear.")
        print("|cff00ff00RPVox:|r bubble pinned -- drag it, then"
            .. " |cffffd100/rpvox bubble|r again.")
    else
        frame:EnableMouse(false)
        UIFrameFadeRemoveFrame(frame)
        frame:Hide()
        frame:SetAlpha(1)
        print("|cff00ff00RPVox:|r bubble unpinned. Position saved.")
    end
end

-- Demo holds for 12 seconds rather than pinning: pinning left the bubble
-- stuck on screen and looking like the fade was broken.
function Bubble:Demo()
    local samples = {
        "Plain speech, nothing applied.",
        "Ice, ice, ~baby~. Cold as ice.",
        "Stand back. *GET TO DA CHOPPA!*",
        "_I would rather not_, but *FINE*.",
        "#Everything is shaking# and this is not.",
        "^Squash and stretch^ next to text that does not.",
        "Normal, *loud*, _quiet_, ~wavy~, #shaky#, ^tall^.",
        -- Colour spans, so this can be checked without loading a pack.
        "Come on baby, {fire}#LIGHT MY FIRE#{/}, and the rest stays plain.",
        "{frost}~Cold as ice~{/}. {arcane}*SAY MY NAME*{/}. Plain again.",
    }
    demoIndex = (demoIndex or 0) % #samples + 1
    -- Neutral base, not the pack's. On Mage-Lyrics the default effect is
    -- drift, which made "plain" text visibly move and hid the contrast the
    -- samples exist to show.
    local base = StyleFor()
    local neutral = { size = base.size, outline = base.outline,
                      colour = base.colour, effect = "none" }
    self:Show(samples[demoIndex], neutral, 12)
    print("|cff00ff00RPVox:|r sample " .. demoIndex .. "/" .. #samples
        .. " (base effect forced to none) -- |cffffd100/rpvox bubble demo|r next.")
    -- Stretch is the one effect that depends on a client capability, so say
    -- which path it took rather than leaving a dead effect to be puzzled over.
    if samples[demoIndex]:find("%^") then
        print("  stretch is driven manually from OnUpdate:"
            .. " a staggered per-letter pulse, uniform per glyph."
            .. " Scale animations report as working on this client"
            .. " but render nothing.")
    end
end

-- What client is this, really -------------------------------------------------
-- Asked because the .toc claiming Interface 20506 proves nothing: that is what
-- we declare, not what we are running on. GetBuildInfo and WOW_PROJECT_ID come
-- from the client itself.
--
-- It matters because the whole world-anchoring approach rests on friendly
-- player nameplates existing. Original Burning Crusade had enemy nameplates
-- only; if this client kept that, there is no frame over a friendly player's
-- head to anchor to and no CVar will conjure one.
local function ClientReport()
    local version, build, date, toc = "?", "?", "?", "?"
    if GetBuildInfo then
        local ok, a, b, c, d = pcall(GetBuildInfo)
        if ok then version, build, date, toc = a or "?", b or "?", c or "?", d or "?" end
    end

    local project = "unknown"
    if WOW_PROJECT_ID then
        local known = {
            [WOW_PROJECT_MAINLINE or -1]                 = "Retail",
            [WOW_PROJECT_CLASSIC or -2]                  = "Classic Era / Anniversary (vanilla)",
            [WOW_PROJECT_BURNING_CRUSADE_CLASSIC or -3]  = "Burning Crusade Classic",
            [WOW_PROJECT_WRATH_CLASSIC or -4]            = "Wrath Classic",
            [WOW_PROJECT_CATA_CLASSIC or -5]             = "Cataclysm Classic",
        }
        project = (known[WOW_PROJECT_ID] or "id " .. tostring(WOW_PROJECT_ID))
    end

    return version, build, date, toc, project
end

function Bubble:Client()
    local version, build, date, toc, project = ClientReport()
    print("|cff00ff00RPVox:|r client report")
    print("  version .......... " .. tostring(version) .. " (build " .. tostring(build) .. ")")
    print("  interface ........ " .. tostring(toc) .. "   |cff888888(our .toc declares 20506)|r")
    print("  project .......... " .. project)
    print("  built ............ " .. tostring(date))

    -- Does the friendly-nameplate machinery exist at all on this build?
    local names = PlateCVarNames()
    local friendly = {}
    for _, n in ipairs(names) do
        local l = n:lower()
        if l:find("friend", 1, true) then
            table.insert(friendly, n .. "=" .. tostring(CVarGet(n)))
        end
    end
    table.sort(friendly)
    print("  friendly-plate settings: "
        .. (#friendly > 0 and table.concat(friendly, "  ")
            or "|cffff0000none -- this client has no friendly nameplates|r"))
    print("  nameplates on screen right now: " .. #AllPlates())
    print("  |cff888888Run this again while a hostile mob is on screen: if that|r")
    print("  |cff888888count is still 0, nameplates are off entirely (press V).|r")
end

-- Every nameplate setting this client actually registers, with its value.
-- The one diagnostic that ends a naming argument rather than continuing it.
function Bubble:CVars()
    local names = PlateCVarNames()
    if #names == 0 then
        print("|cffff0000RPVox:|r this client exposes no console command list "
            .. "(C_Console.GetAllCommands is missing), so the names cannot be "
            .. "discovered. World mode will fall back to the documented ones.")
        return
    end
    local version, _, _, toc, project = ClientReport()
    print("|cff00ff00RPVox:|r " .. project .. " " .. tostring(version)
        .. " (interface " .. tostring(toc) .. ")")
    print("  nameplate settings this client registers:")
    for _, n in ipairs(names) do
        print(("  |cffffd100%s|r = %s"):format(n, tostring(CVarGet(n))))
    end
    local targets = WorldCVars()
    local picked = {}
    for n in pairs(targets) do table.insert(picked, n) end
    table.sort(picked)
    print("  world mode would set: "
        .. (#picked > 0 and table.concat(picked, ", ") or "|cffff0000nothing|r"))
end

-- Walks the whole chain for one player and says which link broke, rather than
-- leaving "no bubble appeared" to be guessed at. Target them and run it.
function Bubble:TestOn(name)
    if (not name or name == "") and UnitExists("target") then
        name = UnitName("target")
    end
    if not name or name == "" then
        print("|cffff0000RPVox:|r target the player first, or "
            .. "|cffffd100/rpvox bubble test <name>|r.")
        return
    end

    Bubble:Reapply()

    print("|cff00ff00RPVox:|r testing a bubble on |cffffff00" .. name .. "|r")
    print("  world mode ......... " .. ((RPVoxDB and RPVoxDB.world) and "on"
        or "|cffff8800off|r -- run /rpvox bubble world"))
    local targets = WorldCVars()
    local shown = {}
    for cvar in pairs(targets) do
        table.insert(shown, cvar .. "=" .. tostring(CVarGet(cvar)))
    end
    table.sort(shown)
    print("  plate settings ..... "
        .. (#shown > 0 and table.concat(shown, "  ")
            or "|cffff0000none found on this client|r"))
    print("  C_NamePlate ........ " .. ((C_NamePlate and C_NamePlate.GetNamePlateForUnit)
        and "present" or "|cffff0000missing|r"))
    print("  plates on screen ... " .. #AllPlates())
    print("  a plate for you .... " .. (PlateForUnit("player")
        and "|cff00ff00yes -- your own lines can sit on your character|r"
        or "|cffff8800no -- this client draws no nameplate for you, so your "
           .. "own bubble stays on screen|r"))

    local tracked = plateUnit[name]
    print("  plate for them ..... " .. (tracked and ("yes, " .. tracked)
        or "|cffff8800no -- they need to be in sight and in nameplate range|r"))

    -- The full lookup, not the map alone -- it also tries your target, which
    -- is how this works the first time, before any plate event has fired. An
    -- earlier version short-circuited on the map and reported "none" for
    -- anchors the real path would have found.
    local plate = PlateFor(name)
    print("  anchor frame ....... " .. (plate and "found" or "|cffff8800none|r"))

    ShowOn(name, "Testing. One, two.")
    local b = bubbles[name]
    if b and b.plate then
        print("  result ............. |cff00ff00above their character|r")
    elseif RPVoxDB and RPVoxDB.world then
        print("  result ............. |cffff8800not shown -- no nameplate for "
            .. "them, and world mode never falls back to the screen|r")
        print("  |cff888888They have to be on your screen for the client to|r")
        print("  |cff888888give them a nameplate. Behind you means no plate.|r")
    else
        print("  result ............. stacked under your own bubble")
    end
end

function Bubble:Diagnose()
    -- Kept for the record: this client reports SetScaleFrom, builds the group
    -- and returns IsPlaying true, yet nothing renders -- the animated scale
    -- never reaches the child FontString. Stretch is therefore driven from
    -- OnUpdate instead, and this only reports what the client claims.
    print("|cff00ff00RPVox bubble:|r Scale animation reported as: |cffffd100"
        .. tostring(ScaleMode()) .. "|r (unused -- stretch is manual)")
    local frame = Get(MINE).frame
    local others = 0
    for owner in pairs(bubbles) do
        if owner ~= MINE then others = others + 1 end
    end
    local seen = {}
    for who in pairs(plateUnit) do table.insert(seen, who) end
    table.sort(seen)
    print("  world mode: " .. ((RPVoxDB and RPVoxDB.world) and "on" or "off")
        .. " | plate cvars: " .. #PlateCVarNames()
        .. " | plates in sight: "
        .. (#seen > 0 and table.concat(seen, ", ") or "none"))
    print("  bubbles: yours"
        .. (others > 0 and (" + " .. others .. " from other players") or "")
        .. " | nameplate anchoring "
        .. ((C_NamePlate and C_NamePlate.GetNamePlateForUnit) and "available"
                                                              or "absent")
        .. " | others " .. ((RPVoxDB and RPVoxDB.hideOthers) and "hidden" or "shown"))
    local c = frame and frame.chars and frame.chars[1]
    print("  chars laid out: " .. tostring(frame and frame.charCount or 0)
        .. " | first char scale: " .. tostring(c and c:GetScale() or "n/a")
        .. " | effect: " .. tostring(c and c.effect or "n/a"))
end

-- Plates come and go as people walk in and out of view. Two things have to
-- happen when one appears: its art gets hidden if world mode is on, and
-- anybody already mid-sentence gets moved from the stack onto their own head.
-- Without the second, somebody who spoke as they rounded a corner would finish
-- their line down in the stack even though the anchor had arrived.
local plates = CreateFrame("Frame")
plates:RegisterEvent("NAME_PLATE_UNIT_ADDED")
plates:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
plates:SetScript("OnEvent", function(_, event, unit)
    if not unit then return end
    local name = FullName(unit)
    if not name then return end

    if event == "NAME_PLATE_UNIT_ADDED" then
        plateUnit[name] = unit
        if C_NamePlate and C_NamePlate.GetNamePlateForUnit then
            local ok, plate = pcall(C_NamePlate.GetNamePlateForUnit, unit)
            if ok and plate then
                -- Pooled frame: if this frame was hidden for its previous
                -- occupant, give the new one its art back before deciding
                -- whether this occupant should lose it too.
                if hiddenArt[plate] then ShowPlateArt(plate) end
                HidePlateArt(plate, unit)
            end
        end
        local b = bubbles[name]
        if b and b.frame:IsShown() and not b.plate then PlaceOther(b) end
    else
        if plateUnit[name] == unit then plateUnit[name] = nil end
        -- Their plate has gone. Anything of theirs still on screen drops back
        -- to the stack rather than hanging in mid-air where they used to be.
        local b = bubbles[name]
        if b and b.frame:IsShown() and b.plate then
            b.plate = nil
            PlaceOther(b)
        end
    end
end)

RPVox.Bubble = Bubble
