-- RPVox -- configuration UI
-- /rpvox opens this window.

local ROW_HEIGHT   = 22

-- How tall the list inset is, where its first row starts -- the search box
-- lives in that gap -- and how much clear space to leave above the bottom
-- border. The row count is worked out from them rather than written down
-- separately: the two were independent numbers, the inset was shortened to
-- make room for the buttons beneath it, and the twelfth row carried on being
-- drawn 8 points across the border it no longer fitted inside.
local LIST_HEIGHT  = 286
local LIST_TOP     = 30
local LIST_BOTTOM  = 8
local VISIBLE_ROWS = math.floor((LIST_HEIGHT - LIST_TOP - LIST_BOTTOM) / ROW_HEIGHT)
-- No channel picker: each line decides for itself. "/em ..." emotes,
-- everything else is said. Say and emote are the only two, deliberately.

local UI = {}
-- Opens on Moments rather than on the first tab. Spells Override is first
-- because that is where it belongs in the order, but a fresh profile has none,
-- and a window that opens on an empty list looks broken.
UI.category = "MOMENT"
UI.search = ""      -- matches entry names; "" means show everything
local selected      -- currently selected trigger table

-- Helpers -----------------------------------------------------------------

-- The visible list is the current tab's triggers, narrowed by the search box
-- and sorted by name. Sorting is safe here because TriggersInCategory hands
-- back a fresh table -- the profile's own trigger order is never touched.
local function Triggers()
    if not RPVoxDB then return {} end
    local list = RPVox:TriggersInCategory(UI.category)

    -- Filter before sorting; there is no point ordering entries about to be
    -- thrown away. `find` is given plain=true throughout so that typing a "("
    -- or a "%" is treated as text rather than as a malformed Lua pattern.
    if UI.search ~= "" then
        local kept = {}
        for _, t in ipairs(list) do
            if (t.name or ""):lower():find(UI.search, 1, true) then
                table.insert(kept, t)
            end
        end
        list = kept
    end

    table.sort(list, function(a, b)
        return (a.name or ""):lower() < (b.name or ""):lower()
    end)
    return list
end

local function WordsToText(words)
    return table.concat(words or {}, "\n")
end

-- The chance slider used to be logarithmic, because it ran from 0.01% and a
-- linear scale crammed every useful value into the first pixel. It runs 1-100
-- now and one percent per step is exactly right, so the four-decade mapping
-- and its log helpers are gone with it.

-- "90", "90s", "2m", "1m30s", "1:30" -> seconds. nil if unparsable.
local function ParseTime(str)
    str = (str or ""):lower():gsub("%s+", "")
    if str == "" then return nil end

    local mm, ss = str:match("^(%d+):(%d%d)$")
    if mm then return tonumber(mm) * 60 + tonumber(ss) end

    local m, s = str:match("^(%d+)m(%d+)s?$")
    if m then return tonumber(m) * 60 + tonumber(s) end

    local n = str:match("^([%d%.]+)m$")
    if n then return math.floor(tonumber(n) * 60 + 0.5) end

    n = str:match("^([%d%.]+)s?$")
    if n then return math.floor(tonumber(n) + 0.5) end

    return nil
end

local function FormatTime(sec)
    sec = math.floor((sec or 0) + 0.5)
    if sec < 60 then return sec .. "s" end
    local m, s = math.floor(sec / 60), sec % 60
    if s == 0 then return m .. "m" end
    return ("%dm%ds"):format(m, s)
end

-- Small edit box that pairs with a slider.
local function MakeValueBox(parent, anchorTo, width, onCommit)
    local box = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    box:SetSize(width or 54, 20)
    box:SetPoint("LEFT", anchorTo, "RIGHT", 14, 0)
    box:SetAutoFocus(false)
    box:SetJustifyH("CENTER")
    box:SetMaxLetters(8)
    box:SetFontObject(ChatFontNormal)

    local function commit(self)
        onCommit(self:GetText())
        self:ClearFocus()
        self:HighlightText(0, 0)
    end
    box:SetScript("OnEnterPressed", commit)
    box:SetScript("OnEditFocusLost", commit)
    box:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        UI:RefreshDetail()
    end)
    box:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    return box
end

local function TextToWords(text)
    local words = {}
    for line in (text or ""):gmatch("[^\r\n]+") do
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" then
            table.insert(words, line)
        end
    end
    return words
end

-- Spell info from whatever the cursor is carrying -------------------------

local function SpellFromCursor()
    local kind, a, b, c = GetCursorInfo()
    if kind ~= "spell" then return nil end

    -- Retail-style: (spell, spellIndex, bookType, spellID)
    local id = tonumber(c) or tonumber(a)
    if id then
        local name, _, icon = GetSpellInfo(id)
        if name then return name, icon end
    end
    if type(b) == "string" then
        local name = GetSpellBookItemName(a, b)
        if name then
            local _, _, icon = GetSpellInfo(name)
            return name, icon
        end
    end
    return nil
end

-- Frame -------------------------------------------------------------------

local function CreateUI()
    local f = CreateFrame("Frame", "RPVoxFrame", UIParent,
                          "BasicFrameTemplateWithInset")
    f:SetSize(640, 540)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    f:Hide()
    tinsert(UISpecialFrames, "RPVoxFrame")   -- Esc closes it

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.title:SetPoint("TOP", f.TitleBg, "TOP", 0, -5)
    f.title:SetText("RPVox")

    -- Profile bar -----------------------------------------------------------
    local plabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    plabel:SetPoint("TOPLEFT", 16, -34)
    plabel:SetText("Profile")

    local pdd = CreateFrame("Frame", "RPVoxProfileDropdown", f, "UIDropDownMenuTemplate")
    pdd:SetPoint("LEFT", plabel, "RIGHT", -6, -2)
    UIDropDownMenu_SetWidth(pdd, 150)
    UIDropDownMenu_Initialize(pdd, function(self, level)
        for _, name in ipairs(RPVox:ProfileNames()) do
            local info = UIDropDownMenu_CreateInfo()
            info.text    = name
            info.checked = (name == RPVox:ProfileName())
            info.func    = function()
                RPVox:UseProfile(name)
                CloseDropDownMenus()
                UI:Refresh()
                print("|cff00ff00RPVox:|r " .. RPVox.CharKey()
                    .. " now uses '" .. name .. "'.")
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    f.profileDD = pdd

    local function profileButton(text, width, anchor, dx, onClick)
        local b = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        b:SetSize(width, 20)
        b:SetPoint("LEFT", anchor, "RIGHT", dx, 0)
        b:SetText(text)
        b:SetScript("OnClick", onClick)
        return b
    end

    -- "New" offers a class pack, so a profile arrives with that class's
    -- abilities and voice already filled in.
    local newMenu = CreateFrame("Frame", "RPVoxNewProfileMenu", f, "UIDropDownMenuTemplate")
    local bNew = profileButton("New", 46, pdd, -8, function(self)
        UIDropDownMenu_Initialize(newMenu, function(_, level)
            local head = UIDropDownMenu_CreateInfo()
            head.text, head.isTitle, head.notCheckable = "Start from class", true, true
            UIDropDownMenu_AddButton(head, level)

            for _, classKey in ipairs(RPVox:ClassKeys()) do
                local info = UIDropDownMenu_CreateInfo()
                info.text         = RPVox:ClassName(classKey)
                info.notCheckable = true
                info.func = function()
                    local name = RPVox:CreateClassProfile(classKey)
                    if not name then return end
                    RPVox:UseProfile(name)
                    UI:Refresh()
                    print("|cff00ff00RPVox:|r created '" .. name
                        .. "' and switched to it.")
                end
                UIDropDownMenu_AddButton(info, level)
            end

            local blank = UIDropDownMenu_CreateInfo()
            blank.text         = "Blank (generic lines)"
            blank.notCheckable = true
            blank.func         = function() StaticPopup_Show("RPVox_NEW_PROFILE") end
            UIDropDownMenu_AddButton(blank, level)
        end, "MENU")
        ToggleDropDownMenu(1, nil, newMenu, self, 0, 0)
    end)
    local bCopy = profileButton("Copy", 50, bNew, 2, function()
        StaticPopup_Show("RPVox_COPY_PROFILE")
    end)
    local bRen = profileButton("Rename", 66, bCopy, 2, function()
        StaticPopup_Show("RPVox_RENAME_PROFILE")
    end)
    local bDel = profileButton("Delete", 60, bRen, 2, function()
        StaticPopup_Show("RPVox_DELETE_PROFILE")
    end)
    f.deleteProfileButton = bDel

    local pnote = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    pnote:SetPoint("TOPLEFT", plabel, "BOTTOMLEFT", 4, -16)
    pnote:SetJustifyH("LEFT")
    pnote:SetText("This character uses the selected profile. "
        .. "Other characters keep their own.")

    -- Master enable ---------------------------------------------------------
    local master = CreateFrame("CheckButton", "$parentMaster", f,
                               "UICheckButtonTemplate")
    master:SetPoint("TOPLEFT", pnote, "BOTTOMLEFT", -2, -4)
    master:SetSize(24, 24)
    master.text = master:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    master.text:SetPoint("LEFT", master, "RIGHT", 2, 0)
    master.text:SetText("Addon enabled")
    master:SetScript("OnClick", function(self)
        RPVox:Profile().enabled = self:GetChecked() and true or false
    end)
    f.master = master

    -- Where the lines go is not a choice any more: always other RPVox users,
    -- never public chat. This just says so, so nobody has to wonder.
    local outNote = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    outNote:SetPoint("TOPLEFT", master, "BOTTOMLEFT", 26, -4)
    outNote:SetJustifyH("LEFT")
    outNote:SetText("Heard only by nearby players who also run RPVox.")

    -- Chattiness ------------------------------------------------------------
    -- One timer for the whole profile: after any line, everything stays quiet
    -- until it expires. Dragging left talks more, right talks less.
    local ggap = CreateFrame("Slider", "RPVoxGlobalSlider", f, "OptionsSliderTemplate")
    ggap:SetPoint("TOPLEFT", outNote, "BOTTOMLEFT", -22, -16)
    ggap:SetWidth(126)
    ggap:SetMinMaxValues(0, 600)
    ggap:SetValueStep(5)
    ggap:SetObeyStepOnDrag(true)
    _G["RPVoxGlobalSliderLow"]:SetText("|cff00ff00<- chatty|r")
    _G["RPVoxGlobalSliderHigh"]:SetText("|cffff8080quiet ->|r")
    -- Left-aligned to the slider instead of centred on it, so the long label
    -- stops hanging off the left edge of the column.
    local gtext = _G["RPVoxGlobalSliderText"]
    gtext:ClearAllPoints()
    gtext:SetPoint("BOTTOMLEFT", ggap, "TOPLEFT", 0, 3)
    gtext:SetJustifyH("LEFT")
    ggap:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / 5 + 0.5) * 5
        _G["RPVoxGlobalSliderText"]:SetText("One line every " .. FormatTime(value))
        if not UI.updating then
            RPVox:Profile().globalCooldown = value
            f.globalBox:SetText(FormatTime(value))
        end
    end)
    f.globalSlider = ggap

    -- How talkative, for the whole profile. This used to sit on each trigger,
    -- where it could not mean anything: seventy-five spell triggers competed
    -- for one quiet gap, so a spell set to 100% still missed most of its casts.
    -- One number, and the addon scales it per moment -- a swing and a level-up
    -- are not the same event and never wanted the same percentage.
    local chance = CreateFrame("Slider", "RPVoxChanceSlider", f, "OptionsSliderTemplate")
    -- Clear of the quiet-gap slider's own value box, which MakeValueBox hangs
    -- 14 points off that slider's right edge at 48 wide. 52 put this slider's
    -- left end and its "1%" label on top of it; 100 leaves a real gap between
    -- the two controls so they read as two settings rather than one row.
    chance:SetPoint("TOPLEFT", ggap, "TOPRIGHT", 100, 0)
    chance:SetWidth(126)
    chance:SetMinMaxValues(RPVox.MIN_CHANCE or 1, RPVox.MAX_CHANCE or 100)
    chance:SetValueStep(1)
    chance:SetObeyStepOnDrag(true)
    _G["RPVoxChanceSliderLow"]:SetText("|cffff80801%|r")
    _G["RPVoxChanceSliderHigh"]:SetText("|cff00ff00100%|r")
    local ctext = _G["RPVoxChanceSliderText"]
    ctext:ClearAllPoints()
    ctext:SetPoint("BOTTOMLEFT", chance, "TOPLEFT", 0, 3)
    ctext:SetJustifyH("LEFT")
    chance:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        ctext:SetText("Speaks on " .. value .. "% of the moments")
        if not UI.updating then
            RPVox:SetChance(value)
            f.chanceBox:SetText(tostring(value))
        end
    end)
    f.chanceSlider = chance

    f.chanceBox = MakeValueBox(f, chance, 44, function(text)
        -- Two lines, and it has to be two. gsub returns the string *and* the
        -- number of replacements it made, so tonumber(s:gsub(...)) hands that
        -- count over as the number base and throws "base out of range" the
        -- moment you type in the box. The gap slider's box below carries the
        -- same note, from the first time this was fixed.
        local cleaned = (text or ""):gsub("[%%%s]", "")
        local n = tonumber(cleaned)
        if n then
            local set = RPVox:SetChance(n)
            UI.updating = true
            chance:SetValue(set)
            UI.updating = false
            f.chanceBox:SetText(tostring(set))
        end
    end)

    -- Instructions ----------------------------------------------------------
    -- A window of its own, not an overlay on this one. As an overlay it
    -- covered the thing it was explaining: you could read the markup guide or
    -- write a line using it, never both at once. It is a reference, and a
    -- reference belongs open beside the work.
    --
    -- Parented to UIParent rather than to the settings window so it survives
    -- that window closing, and can be dragged anywhere on screen.
    local help = CreateFrame("Frame", "RPVoxHelpFrame", UIParent,
                             "BasicFrameTemplateWithInset")
    help:SetSize(460, 540)
    help:SetPoint("TOPLEFT", f, "TOPRIGHT", 8, 0)
    help:SetFrameStrata("DIALOG")
    help:SetMovable(true)
    help:EnableMouse(true)
    help:RegisterForDrag("LeftButton")
    help:SetScript("OnDragStart", help.StartMoving)
    help:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        self.moved = true          -- stop re-anchoring it to the main window
    end)
    help:SetClampedToScreen(true)
    help:Hide()
    tinsert(UISpecialFrames, "RPVoxHelpFrame")   -- Esc closes it too

    help.title = help:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    help.title:SetPoint("TOP", help.TitleBg, "TOP", 0, -5)
    help.title:SetText("RPVox — Instructions")

    -- Put the button back to "Instructions" however the window was closed:
    -- the title bar X and Escape both bypass the button's own handler.
    help:SetScript("OnHide", function()
        if f.helpButton then f.helpButton:SetText("Instructions") end
    end)

    local hscroll = CreateFrame("ScrollFrame", "RPVoxHelpScroll", help,
                                "UIPanelScrollFrameTemplate")
    hscroll:SetPoint("TOPLEFT", 12, -32)
    hscroll:SetPoint("BOTTOMRIGHT", -32, 12)
    local hbody = CreateFrame("Frame", nil, hscroll)
    hbody:SetSize(400, 10)
    hscroll:SetScrollChild(hbody)

    local htext = hbody:CreateFontString(nil, "OVERLAY", "GameFontHighlightLeft")
    htext:SetPoint("TOPLEFT")
    htext:SetWidth(400)
    htext:SetJustifyH("LEFT")
    htext:SetSpacing(3)
    htext:SetText(table.concat({
        "|cff3fd0ffWHAT RPVOX DOES|r",
        "It says things for you. When you cast a spell, take a bad hit, die,",
        "come back, land a killing blow, eat, fish, mine, mount up or find",
        "somewhere new, it may speak a line in your character's voice.",
        "",
        "|cff3fd0ffWHO CAN HEAR IT|r",
        "Only players standing near you who also run RPVox. The range is the",
        "same as /say. Nothing is ever sent to public chat, so you cannot spam",
        "strangers with it -- but they cannot read your character either.",
        "Lines arrive tagged |cffedd994[RP]|r and coloured, so nobody confuses",
        "them with something you typed yourself.",
        "",
        "|cff3fd0ffHOW OFTEN|r",
        "|cffffff00Speaks on ...% of the moments|r is one number for the whole",
        "character, from 1% to 100%. It used to sit on every trigger, where it",
        "could not mean much -- dozens of them competed for one quiet gap, so a",
        "spell set to 100% still missed most of its casts.",
        "",
        "Rare moments count for more than common ones automatically. A swing",
        "happens twenty-five times a minute and a level-up once an evening, so",
        "they were never going to want the same percentage, and you should not",
        "have to work that out. Crits are three times likelier to be worth",
        "saying than an ordinary hit, for the same reason.",
        "",
        "|cffffff00One line every...|r is the other half: after anything is said,",
        "everything stays quiet for that long. Start low on both. A character",
        "who comments on every fireball stops being a character and becomes",
        "noise.",
        "",
        "Inside |cffffff00dungeons, raids, battlegrounds and arenas|r RPVox",
        "switches off entirely -- no lines, no bubbles -- until you step back",
        "out. Not optional: group content is not the place for it.",
        "",
        "|cff3fd0ffPROFILES|r",
        "One per character. Each holds its own class, mood, lines and settings.",
        "|cffffff00New|r builds one from a class pack, already full of lines for",
        "that class. Your character remembers which profile it uses.",
        "",
        "|cff3fd0ffWRITING LINES|r",
        "Pick a trigger on the left, type in the box on the right, one line per",
        "row. The moment you type, that trigger is yours and updates will never",
        "overwrite it.",
        "",
        "  |cffffff00%t|r  becomes whoever you are targeting. A line containing",
        "      %t will not fire when you have no target, so keep a few lines",
        "      without it in every set.",
        "  |cffffff00%s|r  becomes your own name.",
        "",
        "|cff3fd0ffSPEECH BUBBLES OVER CHARACTERS|r",
        "Your lines can float above your character on the screens of other",
        "people running RPVox, and theirs above them, following as you move.",
        "",
        "|cffff8800This needs friendly nameplates turned on.|r Nothing on this",
        "client will tell an addon where a character is on screen, so their",
        "nameplate is the only handle there is. Turn it on with:",
        "",
        "    |cffffff00/rpvox bubble world|r",
        "",
        "That switches friendly player nameplates on, switches them on out of",
        "combat too, and hides the health bars and names they would draw -- so",
        "you see the bubble and nothing else. Turning it off puts every setting",
        "back as it was. It will not run mid-fight; the client locks those",
        "settings during combat.",
        "",
        "Enemy nameplates, friendly NPCs, pets and minions are never touched.",
        "Your enemy health bars stay exactly as you have them.",
        "",
        "Without it, bubbles still work -- they stack in the corner of the",
        "screen with the speaker's name on them. With it on, a line from",
        "somebody you cannot see is not shown at all rather than dropping to",
        "the corner. It is still in your chat frame either way.",
        "",
        "Your own bubble stays on screen: there is no nameplate above your own",
        "head, so there is nowhere in the world to put it.",
        "|cffffff00/rpvox bubble mine|r hides it -- your lines still appear",
        "above your character for everybody else.",
        "",
        "Not appearing? |cffffff00/rpvox bubble test|r with a player targeted",
        "walks the whole chain and names the step that failed.",
        "",
        "|cff3fd0ffEMPHASIS IN THE SPEECH BUBBLE|r",
        "These change how a word looks in the bubble. Chat cannot show them, so",
        "they are stripped there -- write them freely, chat stays clean.",
        "",
        "  |cffffff00*loud*|r      bigger, heavy outline",
        "  |cffffff00_quiet_|r     smaller and faded",
        "  |cffffff00~wavy~|r      rides a slow wave",
        "  |cffffff00#shaky#|r     jitters   (# not !, so real punctuation is safe)",
        "  |cffffff00^tall^|r      squashes and stretches",
        "",
        "Colour a span with a school tag, closed by |cffffff00{/}|r:",
        "",
        "  |cffffff00{fire}|r |cffffff00{frost}|r |cffffff00{arcane}|r"
            .. " |cffffff00{holy}|r |cffffff00{shadow}|r |cffffff00{nature}|r",
        "",
        "  Come on baby, |cffffff00{fire}#LIGHT MY FIRE#{/}|r, %t.",
        "",
        "Everything outside a tag stays white and still. Used sparingly it",
        "reads as the character leaning on a word; used on a whole line it",
        "just looks restless.",
        "",
        "|cff3fd0ffMOODS|r",
        "A mood is a version of your character. Put a tag in front of a line:",
        "",
        "    |cffffff00[grim] Nothing stops now.|r",
        "",
        "That line only fires while the mood is set to grim. Untagged lines",
        "always fire. Set the mood to |cffffff00Any|r and everything is eligible.",
        "",
        "Make your own with |cffffff00New mood...|r at the bottom of the mood",
        "list, or |cffffff00/rpvox mood add brooding|r. Then tag lines with",
        "[brooding] and select it. Any name works -- it is just a label.",
        "",
        "|cff3fd0ffMOMENTS, NOT SPELLS|r",
        "Combat is a handful of entries rather than one per spell -- a spell or",
        "skill hitting, critting or missing, a swing, a heal, a buff, something",
        "held down. One set of lines covers your whole spellbook, including",
        "spells you have not learned yet. Drag a spell in from your spellbook",
        "and it gets its own lines that override the general ones, for the few",
        "worth it.",
        "",
        "|cff3fd0ffHITS, CRITS AND MISSES|r",
        "A combat line can be written for how the blow actually landed:",
        "",
        "    |cffffff00<crit> Ash. Nothing left of %t but ash.|r",
        "    |cffffff00<miss> ... and it goes wide. Again.|r",
        "",
        "Tag one line in a spell that way and that spell stops speaking when",
        "the cast goes off, and waits for the combat log instead -- so it can",
        "tell a crit from a resist. When something happens that you have lines",
        "for, only those lines are eligible; otherwise the untagged ones are",
        "used as always. Spells with no tagged lines are untouched and still",
        "speak the moment the cast lands.",
        "",
        "Tags: |cffffff00<hit> <crit> <miss> <dodge> <parry> <block> <resist>|r",
        "|cffffff00<immune> <absorb> <reflect>|r. Anything without its own lines",
        "falls back to <miss> (or <hit> for a block), so <crit> and <miss>",
        "alone will cover most of it. Melee and wands work the same way.",
        "",
        "A mood and an outcome can be combined, in either order:",
        "",
        "    |cffffff00[grim] <miss> Even the fire has stopped listening.|r",
        "",
        "|cff3fd0ffCOMMANDS|r",
        "  /rpvox                  open this window",
        "  /rpvox on | off         silence this profile, or wake it",
        "  /rpvox mood <name>      switch mood, or 'any'",
        "  /rpvox mood add <name>  create a mood",
        "  /rpvox rebuild          reset this profile's stock lines",
        "  /rpvox status           what is loaded and armed",
        "  /rpvox testfire         say something right now",
        "  /rpvox trace            print every decision, send nothing",
        "  /rpvox why              what stopped each trigger speaking",
        "  /rpvox bubble world     float lines above the character models",
        "  /rpvox bubble mine      show or hide your own bubble",
        "  /rpvox bubble others    show or hide other players' bubbles",
        "  /rpvox bubble test      test a bubble on your target",
        "  /rpvox debug            explain why lines do or do not fire",
        "  /rpvox nettest          check other players are receiving you",
    }, "\n"))
    hbody:SetHeight(math.max(10, htext:GetStringHeight() + 20))
    f.helpPanel = help

    local hbtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    hbtn:SetSize(96, 20)
    hbtn:SetPoint("TOPRIGHT", -14, -34)
    hbtn:SetText("Instructions")
    hbtn:SetScript("OnClick", function()
        if help:IsShown() then
            help:Hide()
        else
            -- Re-anchor each time it opens: the settings window can be dragged
            -- while this is shut, and a reference that opens behind the thing
            -- it explains is no use. Only if it has not been moved itself.
            if not help.moved then
                help:ClearAllPoints()
                help:SetPoint("TOPLEFT", f, "TOPRIGHT", 8, 0)
            end
            help:Show()
            hbtn:SetText("Close")
        end
    end)
    f.helpButton = hbtn

    -- Mood picker -----------------------------------------------------------
    -- Lines tagged [grim], [weary] and so on only fire in that mood.
    local mlabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mlabel:SetPoint("LEFT", master.text, "RIGHT", 40, 0)
    mlabel:SetText("Mood")

    local mdd = CreateFrame("Frame", "RPVoxMoodDropdown", f, "UIDropDownMenuTemplate")
    mdd:SetPoint("LEFT", mlabel, "RIGHT", -12, -2)
    UIDropDownMenu_SetWidth(mdd, 110)
    UIDropDownMenu_Initialize(mdd, function(self, level)
        local current = RPVox:GetMood()

        local any = UIDropDownMenu_CreateInfo()
        any.text    = "Any"
        any.checked = (current == nil)
        any.func    = function()
            RPVox:SetMood(nil)
            UIDropDownMenu_SetText(mdd, "Any")
            CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(any, level)

        for _, mood in ipairs(RPVox:MoodsInProfile()) do
            local info = UIDropDownMenu_CreateInfo()
            info.text    = mood
            info.checked = (current == mood)
            info.func    = function()
                RPVox:SetMood(mood)
                UIDropDownMenu_SetText(mdd, mood)
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info, level)
        end

        -- A mood you have not tagged anything with yet cannot appear above,
        -- so there has to be a way to bring one into being.
        local add = UIDropDownMenu_CreateInfo()
        add.text         = "|cff00ff00New mood...|r"
        add.notCheckable = true
        add.func         = function()
            CloseDropDownMenus()
            StaticPopup_Show("RPVox_NEW_MOOD")
        end
        UIDropDownMenu_AddButton(add, level)
    end)
    f.moodDD = mdd

    f.globalBox = MakeValueBox(f, ggap, 48, function(text)
        local secs = ParseTime(text)
        if secs then
            RPVox:Profile().globalCooldown = math.max(0, math.min(3600, secs))
        end
        UI:Refresh()
    end)

    -- Left: trigger list ----------------------------------------------------
    local listBG = CreateFrame("Frame", "RPVoxListInset", f, "InsetFrameTemplate")
    -- Anchored under the slider rather than at a fixed offset, so the slider's
    -- own "chatty/quiet" labels can never overlap the list.
    listBG:SetPoint("TOPLEFT", ggap, "BOTTOMLEFT", -12, -22)
    -- Everything below the list hangs off its bottom edge -- the buttons, then
    -- the hint -- and the category tabs own the lowest 40 points of the window,
    -- the same clearance the detail pane on the right reserves. At the old 320
    -- the hint ended up underneath the tab strip and unreadable, so the list
    -- gives up the rows the text below it needs. See LIST_HEIGHT.
    listBG:SetSize(200, LIST_HEIGHT)

    local scroll = CreateFrame("ScrollFrame", "RPVoxListScroll", listBG,
                               "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", -26, 4)
    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT,
                                         function() UI:RefreshList() end)
    end)
    f.scroll = scroll

    -- Search box in the top of the list inset, narrowing the list by name.
    -- Right edge stops short of the scrollbar so the two never overlap.
    local function MakeFilterBox(name, label, yOffset, apply)
        local box = CreateFrame("EditBox", name, listBG, "InputBoxTemplate")
        box:SetPoint("TOPLEFT", 12, yOffset)
        box:SetPoint("TOPRIGHT", -30, yOffset)
        box:SetHeight(18)
        box:SetAutoFocus(false)
        box:SetMaxLetters(40)
        box:SetFontObject(ChatFontNormal)
        box:SetTextInsets(2, 16, 0, 0)

        local hint = box:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        hint:SetPoint("LEFT", 4, 0)
        hint:SetText(label)

        -- Escape only drops focus, so an explicit clear is worth having.
        local clear = CreateFrame("Button", nil, box)
        clear:SetSize(16, 16)
        clear:SetPoint("RIGHT", -2, 0)
        clear:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
        clear:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
        clear:Hide()
        clear:SetScript("OnClick", function()
            box:SetText("")
            box:ClearFocus()
        end)

        box:SetScript("OnTextChanged", function(self)
            local text = (self:GetText() or ""):lower()
            apply(text)
            hint:SetShown(text == "")
            clear:SetShown(text ~= "")
            -- A narrower list must not stay scrolled past its own end.
            FauxScrollFrame_SetOffset(scroll, 0)
            local bar = _G[scroll:GetName() .. "ScrollBar"]
            if bar then bar:SetValue(0) end
            -- UI.frame is only assigned once CreateUI returns, so this can in
            -- principle fire before the window is fully built.
            if UI.frame then UI:RefreshList() end
        end)
        box:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
        box:SetScript("OnEscapePressed", function(self)
            self:SetText("")
            self:ClearFocus()
        end)
        return box
    end

    f.search = MakeFilterBox("RPVoxListSearch", "Search names", -6,
        function(text) UI.search = text end)

    f.rows = {}
    for i = 1, VISIBLE_ROWS do
        local row = CreateFrame("Button", nil, listBG)
        row:SetSize(168, ROW_HEIGHT)
        if i == 1 then
            row:SetPoint("TOPLEFT", 6, -LIST_TOP)
        else
            row:SetPoint("TOPLEFT", f.rows[i - 1], "BOTTOMLEFT", 0, 0)
        end

        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(16, 16)
        row.icon:SetPoint("LEFT", 2, 0)

        row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        row.label:SetPoint("LEFT", row.icon, "RIGHT", 4, 0)
        row.label:SetPoint("RIGHT", -2, 0)
        row.label:SetJustifyH("LEFT")

        row.hl = row:CreateTexture(nil, "BACKGROUND")
        row.hl:SetAllPoints()
        row.hl:SetColorTexture(0.4, 0.4, 0.8, 0.4)
        row.hl:Hide()

        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        row:SetScript("OnClick", function(self)
            UI:Select(self.trigger)
        end)
        f.rows[i] = row
    end

    -- Add / remove buttons --------------------------------------------------
    local add = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    add:SetSize(96, 22)
    add:SetPoint("TOPLEFT", listBG, "BOTTOMLEFT", 0, -6)
    add:SetText("Add spell")
    add:SetScript("OnClick", function()
        local name, icon = SpellFromCursor()
        if name then
            ClearCursor()
            UI:AddSpell(name, icon)
        else
            StaticPopup_Show("RPVox_ADD_SPELL")
        end
    end)

    local del = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    del:SetSize(96, 22)
    del:SetPoint("LEFT", add, "RIGHT", 6, 0)
    del:SetText("Remove")
    del:SetScript("OnClick", function()
        if not selected then return end
        if not RPVox:IsRemovable(selected) then
            print("|cff00ff00RPVox:|r built-in entries can't be removed -- untick Enabled, or clear their lines.")
            return
        end
        RPVox:DeleteTrigger(selected)
        selected = Triggers()[1]
        UI:Refresh()
    end)
    f.deleteButton = del
    f.addButton = add


    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", add, "BOTTOMLEFT", 0, -6)
    hint:SetPoint("RIGHT", listBG, "RIGHT", 0, 0)
    hint:SetJustifyH("LEFT")
    hint:SetText("Drag a spell from your spellbook onto this window to add it.")
    hint:SetWordWrap(true)
    f.hint = hint

    -- Accept spellbook drags anywhere on the frame
    f:SetScript("OnReceiveDrag", function()
        local name, icon = SpellFromCursor()
        if name then
            ClearCursor()
            UI:AddSpell(name, icon)
        end
    end)
    f:SetScript("OnMouseUp", function()
        local name, icon = SpellFromCursor()
        if name then
            ClearCursor()
            UI:AddSpell(name, icon)
        end
    end)

    -- Right: detail pane ----------------------------------------------------
    local pane = CreateFrame("Frame", nil, f)
    pane:SetPoint("TOPLEFT", listBG, "TOPRIGHT", 12, 0)
    pane:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -14, 40)
    f.pane = pane

    pane.header = pane:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    pane.header:SetPoint("TOPLEFT", 0, 0)
    pane.header:SetText("")

    local on = CreateFrame("CheckButton", "RPVoxTriggerEnabled", pane,
                           "UICheckButtonTemplate")
    on:SetSize(22, 22)
    on:SetPoint("TOPLEFT", pane.header, "BOTTOMLEFT", -2, -4)
    on.text = on:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    on.text:SetPoint("LEFT", on, "RIGHT", 2, 0)
    on.text:SetText("Enabled")
    on:SetScript("OnClick", function(self)
        if selected then
            selected.enabled = self:GetChecked() and true or false
            UI:RefreshList()
        end
    end)
    pane.enabled = on

    -- Chance slider

    -- Sayings box
    local sayLabel = pane:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sayLabel:SetPoint("TOPLEFT", on, "BOTTOMLEFT", 0, -22)
    sayLabel:SetText("Sayings -- one per line:")

    local syntax = pane:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    syntax:SetPoint("LEFT", sayLabel, "RIGHT", 8, 0)
    syntax:SetText("|cff909090/em = emote   %t = target   [mood]   <crit> <miss>|r")

    local boxBG = CreateFrame("Frame", nil, pane, "InsetFrameTemplate")
    boxBG:SetPoint("TOPLEFT", sayLabel, "BOTTOMLEFT", 0, -4)
    boxBG:SetPoint("BOTTOMRIGHT", pane, "BOTTOMRIGHT", 0, 0)

    local boxScroll = CreateFrame("ScrollFrame", "RPVoxSayingsScroll", boxBG,
                                  "UIPanelScrollFrameTemplate")
    boxScroll:SetPoint("TOPLEFT", 6, -6)
    boxScroll:SetPoint("BOTTOMRIGHT", -26, 6)


    local edit = CreateFrame("EditBox", "RPVoxSayingsEdit", boxScroll)
    -- Blizzard's ScrollingEdit_OnUpdate does arithmetic on cursorOffset, and
    -- the only thing that ever sets it is their OnCursorChanged. Selecting a
    -- trigger calls SetText on a box nobody has clicked in, so it was still
    -- nil and the error came out of their file rather than ours.
    --
    -- On the *edit box*. They are read from the edit box and written to the
    -- edit box; the scroll frame passed alongside is only used for its height
    -- and scroll range. Seeding them on the scroll frame instead looked right,
    -- changed nothing, and cost a round trip -- the error dump gives it away,
    -- with the frame carrying cursorOffset=0 while the value read came out nil.
    edit.cursorOffset = 0
    edit.cursorHeight = 0
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(300)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    edit:SetScript("OnTextChanged", function(self, userInput)
        if userInput and selected then
            selected.words = TextToWords(self:GetText())
            selected.custom = true   -- yours now; stock updates leave it alone
        end
        -- Belt to the braces above, and only when there is a cursor to keep
        -- in view at all. This call exists to scroll to wherever you are
        -- typing; setting the text from code is not typing, and asking it to
        -- chase a cursor nobody has placed is what broke it.
        self.cursorOffset = self.cursorOffset or 0
        self.cursorHeight = self.cursorHeight or 0
        if self:HasFocus() then
            ScrollingEdit_OnTextChanged(self, self:GetParent())
        end
    end)
    edit:SetScript("OnCursorChanged", ScrollingEdit_OnCursorChanged)
    boxScroll:SetScrollChild(edit)
    boxScroll:SetScript("OnSizeChanged", function(self, w)
        edit:SetWidth(w)
    end)
    -- Only grab focus when the editor is the thing on screen; while a filter
    -- is up the editor is hidden behind the read-only view.
    boxBG:SetScript("OnMouseDown", function()
        if boxScroll:IsShown() then edit:SetFocus() end
    end)
    pane.edit = edit

    -- Find within the sayings of the entry on screen. This only ever reads the
    -- editor and moves the cursor: it must never filter what the editor shows,
    -- because the editor's OnTextChanged writes whatever is displayed straight
    -- back over selected.words, so hiding a line would delete it.
    local find = CreateFrame("EditBox", "RPVoxSayingsFind", pane, "InputBoxTemplate")
    find:SetPoint("BOTTOMLEFT", sayLabel, "TOPLEFT", 6, 6)
    find:SetSize(190, 18)
    find:SetAutoFocus(false)
    find:SetMaxLetters(60)
    find:SetFontObject(ChatFontNormal)
    find:SetTextInsets(2, 16, 0, 0)

    local findHint = find:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    findHint:SetPoint("LEFT", 4, 0)
    findHint:SetText("Find in sayings")

    local findCount = pane:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    findCount:SetPoint("LEFT", find, "RIGHT", 8, 0)

    local findClear = CreateFrame("Button", nil, find)
    findClear:SetSize(16, 16)
    findClear:SetPoint("RIGHT", -2, 0)
    findClear:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    findClear:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    findClear:Hide()
    findClear:SetScript("OnClick", function()
        find:SetText("")
        find:ClearFocus()
    end)

    -- The filtered result gets its own read-only view rather than being put
    -- into the editor. Two reasons: the editor writes back whatever it shows,
    -- so a filtered editor would delete the hidden lines on the next
    -- keystroke; and an EditBox will not render colour escapes, so the matches
    -- could not be highlighted in it. A FontString does both safely.
    local filterScroll = CreateFrame("ScrollFrame", "RPVoxSayingsFilterScroll",
                                     boxBG, "UIPanelScrollFrameTemplate")
    filterScroll:SetPoint("TOPLEFT", 6, -6)
    filterScroll:SetPoint("BOTTOMRIGHT", -26, 6)
    filterScroll:Hide()

    local filterBody = CreateFrame("Frame", nil, filterScroll)
    filterBody:SetSize(300, 10)
    filterScroll:SetScrollChild(filterBody)

    filterScroll:SetScript("OnSizeChanged", function(self, w)
        filterBody:SetWidth(w)
        for _, r in ipairs(filterBody.rows or {}) do r:SetWidth(w) end
    end)

    -- One frame per matching line. Each remembers the index it came from in
    -- selected.words, which is what makes editing a filtered line possible:
    -- the commit writes back to that index rather than replacing the lot.
    filterBody.rows = {}
    local ApplyFilter   -- forward declaration; rows re-run it after a commit

    local function FilterRow(i)
        local r = filterBody.rows[i]
        if r then return r end

        r = CreateFrame("Button", nil, filterBody)
        r:SetWidth(filterBody:GetWidth())
        if i == 1 then
            r:SetPoint("TOPLEFT", 0, 0)
        else
            r:SetPoint("TOPLEFT", filterBody.rows[i - 1], "BOTTOMLEFT", 0, -2)
        end
        r.text = r:CreateFontString(nil, "OVERLAY", "ChatFontNormal")
        r.text:SetPoint("TOPLEFT", 2, 0)
        r.text:SetPoint("RIGHT", -2, 0)
        r.text:SetJustifyH("LEFT")

        r.box = CreateFrame("EditBox", nil, r, "InputBoxTemplate")
        r.box:SetPoint("TOPLEFT", 4, 0)
        r.box:SetPoint("RIGHT", -4, 0)
        r.box:SetHeight(20)
        r.box:SetAutoFocus(true)
        r.box:SetFontObject(ChatFontNormal)
        r.box:Hide()

        local function commit(self)
            if r.committing then return end
            r.committing = true
            local text = (self:GetText() or ""):match("^%s*(.-)%s*$")
            local idx = r.wordIndex
            if idx and selected and selected.words then
                if text == "" then
                    table.remove(selected.words, idx)
                else
                    selected.words[idx] = text
                end
                selected.custom = true   -- yours now, as with the main editor
                -- Keep the hidden editor in step, or it would later write its
                -- own stale copy back over what was just changed here.
                pane.edit:SetText(WordsToText(selected.words))
            end
            self:Hide()
            r.text:Show()
            r.committing = false
            ApplyFilter()
        end

        r.box:SetScript("OnEnterPressed", commit)
        r.box:SetScript("OnEditFocusLost", commit)
        r.box:SetScript("OnEscapePressed", function(self)
            r.committing = true          -- abandon, do not write
            self:Hide()
            r.text:Show()
            self:ClearFocus()
            r.committing = false
        end)

        r:SetScript("OnClick", function()
            r.text:Hide()
            r.box:SetText(r.raw or "")
            r.box:Show()
            r.box:SetFocus()
            r.box:HighlightText()
        end)
        r:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")

        filterBody.rows[i] = r
        return r
    end

    -- Wrap every occurrence of the needle in the line, keeping the original
    -- capitalisation of the text around and inside the match.
    local function Highlight(line, needle)
        local lower = line:lower()
        local out, at = {}, 1
        while true do
            local a, b = lower:find(needle, at, true)
            if not a then break end
            out[#out + 1] = line:sub(at, a - 1)
            out[#out + 1] = "|cffffd100" .. line:sub(a, b) .. "|r"
            at = b + 1
        end
        out[#out + 1] = line:sub(at)
        return table.concat(out)
    end

    function ApplyFilter()
        local needle = (find:GetText() or ""):lower()
        findHint:SetShown(needle == "")
        findClear:SetShown(needle ~= "")

        if needle == "" or not selected then
            filterScroll:Hide()
            boxScroll:Show()
            findCount:SetText("")
            sayLabel:SetText("Sayings -- one per line:")
            return
        end

        local words = selected.words or {}
        local shown, total = 0, #words
        for idx, w in ipairs(words) do
            if w:lower():find(needle, 1, true) then
                shown = shown + 1
                local r = FilterRow(shown)
                r.wordIndex = idx        -- where this line lives in the profile
                r.raw = w
                r.text:SetText(Highlight(w, needle))
                r.text:Show()
                r.box:Hide()
                r:SetHeight(math.max(14, r.text:GetStringHeight() + 4))
                r:Show()
            end
        end
        for i = shown + 1, #filterBody.rows do
            filterBody.rows[i]:Hide()
        end

        if shown == 0 then
            findCount:SetText("|cffd08080no match|r")
        else
            findCount:SetText(("%d of %d lines"):format(shown, total))
        end

        local h = 0
        for i = 1, shown do h = h + filterBody.rows[i]:GetHeight() + 2 end
        filterBody:SetHeight(math.max(10, h))

        sayLabel:SetText("Sayings -- |cffffd100filtered|r, click a line to edit:")
        boxScroll:Hide()
        filterScroll:Show()
    end

    find:SetScript("OnTextChanged", ApplyFilter)
    find:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    find:SetScript("OnEscapePressed", function(self)
        self:SetText("")
        self:ClearFocus()
    end)
    pane.find = find

    -- Bottom buttons --------------------------------------------------------
    local test = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    test:SetSize(110, 22)
    test:SetPoint("BOTTOMRIGHT", -14, 12)
    test:SetText("Test line")
    test:SetScript("OnClick", function()
        if not selected or #(selected.words or {}) == 0 then
            print("|cff00ff00RPVox:|r no lines to test.")
            return
        end
        -- Preview exactly what would go out: same picker, same parsing.
        local msg, channel = RPVox:PreviewLine(selected)
        if not msg then
            print("|cff00ff00RPVox:|r every line here needs a target.")
            return
        end
        print(("|cff00ff00RPVox|r [%s / %s]: %s")
            :format(selected.name, channel, msg))
    end)

    -- Category tabs ---------------------------------------------------------
    f.tabs = {}
    for i, cat in ipairs(RPVox.CATEGORIES) do
        local tab = CreateFrame("Button", "RPVoxFrameTab" .. i, f,
                                "CharacterFrameTabButtonTemplate")
        tab:SetID(i)
        tab:SetText(RPVox.CATEGORY_NAME[cat])
        tab.category = cat
        if i == 1 then
            tab:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 14, 2)
        else
            tab:SetPoint("LEFT", f.tabs[i - 1], "RIGHT", -14, 0)
        end
        tab:SetScript("OnClick", function(self)
            PanelTemplates_SetTab(f, self:GetID())
            UI:SetCategory(self.category)
            PlaySound(SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_TAB or 841)
        end)
        PanelTemplates_TabResize(tab, 0)
        f.tabs[i] = tab
    end
    PanelTemplates_SetNumTabs(f, #RPVox.CATEGORIES)
    -- Highlight whichever tab UI.category actually starts on, rather than
    -- hard-coding the first: the two disagreeing leaves the window showing one
    -- tab's list with another tab lit up.
    for i, cat in ipairs(RPVox.CATEGORIES) do
        if cat == UI.category then PanelTemplates_SetTab(f, i) end
    end

    return f
end

-- Refresh -----------------------------------------------------------------

function UI:RefreshList()
    local f = self.frame
    local list = Triggers()
    FauxScrollFrame_Update(f.scroll, #list, VISIBLE_ROWS, ROW_HEIGHT)
    local offset = FauxScrollFrame_GetOffset(f.scroll)

    for i = 1, VISIBLE_ROWS do
        local row = f.rows[i]
        local t = list[i + offset]
        if t then
            row.trigger = t
            row.icon:SetTexture(t.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            local label = t.name
            if t.enabled == false then
                label = "|cff808080" .. label .. " (off)|r"
            end
            row.label:SetText(label)
            row.hl:SetShown(t == selected)
            row:Show()
        else
            row.trigger = nil
            row.hl:Hide()
            row:Hide()
        end
    end
end

function UI:RefreshDetail()
    local pane = self.frame.pane
    if not selected then
        pane:Hide()
        return
    end
    pane:Show()

    self.updating = true
    pane.header:SetText(selected.name)
    pane.enabled:SetChecked(selected.enabled ~= false)
    pane.edit:SetText(WordsToText(selected.words))
    pane.edit:ClearFocus()
    -- A match found in the previous entry means nothing in this one, and its
    -- highlight would sit over unrelated text. Clearing re-runs the find with
    -- an empty needle, which drops both the count and the selection.
    if pane.find then pane.find:SetText("") end
    self.frame.deleteButton:SetEnabled(RPVox:IsRemovable(selected) and true or false)
    self.updating = false
end

local CATEGORY_HINT = {
    SPELL    = "Drag a spell from your spellbook onto this window to add it. "
            .. "A spell with lines here speaks instead of the Moments entries.",
    MOMENT   = "What happens in a fight, whichever spell caused it. These cover "
            .. "your whole spellbook.",
    REACTION = "Things that happen to you. An entry with no lines never fires.",
    IDLE     = "Everyday actions. Professions match the window you have open.",
}

function UI:SetCategory(cat)
    self.category = cat
    -- A filter left over from another tab reads as a broken, empty list, so
    -- switching tabs starts clean. Setting the text fires OnTextChanged,
    -- which resets UI.search and the scroll offset for us.
    if self.frame and self.frame.search then
        self.frame.search:SetText("")
    end
    self.lastSelected = self.lastSelected or {}
    if selected then
        self.lastSelected[selected.category or "MOMENT"] = selected
    end
    selected = self.lastSelected[cat]
    -- make sure the remembered entry still belongs to this tab
    if not selected or (selected.category or "MOMENT") ~= cat then
        selected = Triggers()[1]
    end
    FauxScrollFrame_SetOffset(self.frame.scroll, 0)
    _G[self.frame.scroll:GetName() .. "ScrollBar"]:SetValue(0)

    -- Adding and removing belongs to one tab. Everywhere else the list is
    -- fixed, and a live Add button on a tab that cannot take one is a promise
    -- the window does not keep.
    local overrides = (cat == "SPELL")
    self.frame.addButton:SetEnabled(overrides)
    self.frame.addButton:SetShown(overrides)
    self.frame.deleteButton:SetShown(overrides)
    self.frame.hint:SetText(CATEGORY_HINT[cat] or "")

    self:Refresh()
end

function UI:Refresh()
    if not self.frame then return end
    local profile = RPVox:Profile()
    if not profile then return end

    self.frame.master:SetChecked(profile.enabled)

    UIDropDownMenu_SetText(self.frame.profileDD, RPVox:ProfileName() or "?")
    UIDropDownMenu_SetText(self.frame.moodDD, RPVox:GetMood() or "Any")
    self.frame.deleteProfileButton:SetEnabled(#RPVox:ProfileNames() > 1)

    local g = profile.globalCooldown or 180
    local c = RPVox:GetChance()
    self.updating = true
    self.frame.globalSlider:SetValue(math.max(0, math.min(600, g)))
    _G["RPVoxGlobalSliderText"]:SetText("At most one line every " .. FormatTime(g))
    self.frame.globalBox:SetText(FormatTime(g))
    self.frame.chanceSlider:SetValue(c)
    _G["RPVoxChanceSliderText"]:SetText("Speaks on " .. c .. "% of the moments")
    self.frame.chanceBox:SetText(tostring(c))
    self.updating = false

    local overrides = (self.category == "SPELL")
    self.frame.addButton:SetEnabled(overrides)
    self.frame.addButton:SetShown(overrides)
    self.frame.deleteButton:SetShown(overrides)
    self.frame.hint:SetText(CATEGORY_HINT[self.category] or "")
    if not selected or (selected.category or "MOMENT") ~= self.category then
        selected = Triggers()[1]
    end
    self:RefreshList()
    self:RefreshDetail()
end

function UI:Select(trigger)
    if not trigger then return end
    selected = trigger
    self:RefreshList()
    self:RefreshDetail()
end

function UI:AddSpell(name, icon)
    if self.category ~= "SPELL" then
        PanelTemplates_SetTab(self.frame, 1)
        self:SetCategory("SPELL")
    end
    local existing = RPVox:FindTrigger(name)
    if existing then
        self:Select(existing)
        print("|cff00ff00RPVox:|r " .. name .. " is already in the list.")
        return
    end
    local t = RPVox:NewTrigger(name, icon)
    self:Select(t)
    self.frame.pane.edit:SetFocus()
end

-- Popups -------------------------------------------------------------------
--
-- The anniversary client rebuilt StaticPopup: the edit box is reached as
-- self.EditBox, where it used to be self.editBox. Every popup here silently
-- did nothing on the old name, because WoW hides Lua errors by default -- the
-- buttons looked dead. Resolve it whichever way the client spells it.
local function PopupEdit(popup)
    if not popup then return nil end
    return popup.EditBox
        or popup.editBox
        or (popup.GetName and popup:GetName() and _G[popup:GetName() .. "EditBox"])
end

-- The dialog rebuild also means an edit box's parent is not necessarily the
-- popup any more, so walk up until something owns a dialog. Used by the
-- enter-to-accept handlers.
local function PopupOf(frame)
    for _ = 1, 6 do
        if not frame then return nil end
        if frame.which then return frame end
        frame = frame.GetParent and frame:GetParent() or nil
    end
    return nil
end

-- Add-by-name popup --------------------------------------------------------

StaticPopupDialogs["RPVox_ADD_SPELL"] = {
    text = "Type a spell name, or drag a spell from your spellbook onto the window.",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 60,
    OnShow = function(self)
        PopupEdit(self):SetText("")
        PopupEdit(self):SetFocus()
    end,
    OnAccept = function(self)
        local name = PopupEdit(self):GetText():match("^%s*(.-)%s*$")
        if name ~= "" then
            local real, _, icon = GetSpellInfo(name)
            UI:AddSpell(real or name, icon)
        end
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = PopupOf(self) or self:GetParent()
        StaticPopupDialogs["RPVox_ADD_SPELL"].OnAccept(parent)
        parent:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

-- Profile popups -----------------------------------------------------------

local function AfterProfileChange(msg)
    UI:Refresh()
    if msg then print("|cff00ff00RPVox:|r " .. msg) end
end

StaticPopupDialogs["RPVox_NEW_PROFILE"] = {
    text = "Name for the new profile (starts with the stock lines):",
    button1 = ACCEPT, button2 = CANCEL,
    hasEditBox = true, maxLetters = 40,
    OnShow = function(self) PopupEdit(self):SetText("") PopupEdit(self):SetFocus() end,
    OnAccept = function(self)
        local name = PopupEdit(self):GetText():match("^%s*(.-)%s*$")
        local p, err = RPVox:CreateProfile(name)
        if not p then
            print("|cffff0000RPVox:|r " .. (err or "could not create."))
            return
        end
        RPVox:UseProfile(name)
        AfterProfileChange("created '" .. name .. "' and switched to it.")
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = PopupOf(self) or self:GetParent()
        StaticPopupDialogs["RPVox_NEW_PROFILE"].OnAccept(parent)
        parent:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}

StaticPopupDialogs["RPVox_NEW_MOOD"] = {
    text = "Name your mood.\nTag lines with [name] and they only fire in it.",
    button1 = ACCEPT, button2 = CANCEL,
    hasEditBox = true, maxLetters = 24,
    OnShow = function(self) PopupEdit(self):SetText("") PopupEdit(self):SetFocus() end,
    OnAccept = function(self)
        local name, err = RPVox:AddMood(nil, PopupEdit(self):GetText())
        if not name then
            print("|cffff0000RPVox:|r " .. (err or "could not add that mood."))
            return
        end
        RPVox:SetMood(name)
        UI:Refresh()
        print("|cff00ff00RPVox:|r mood '" .. name .. "' created and selected."
            .. " Put |cffffff00[" .. name .. "]|r in front of a line to use it.")
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = PopupOf(self) or self:GetParent()
        StaticPopupDialogs["RPVox_NEW_MOOD"].OnAccept(parent)
        parent:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}

StaticPopupDialogs["RPVox_COPY_PROFILE"] = {
    text = "Name for the copy of this profile:",
    button1 = ACCEPT, button2 = CANCEL,
    hasEditBox = true, maxLetters = 40,
    OnShow = function(self)
        PopupEdit(self):SetText((RPVox:ProfileName() or "") .. " copy")
        PopupEdit(self):SetFocus()
        PopupEdit(self):HighlightText()
    end,
    OnAccept = function(self)
        -- Wrapped because WoW hides Lua errors by default: without this, any
        -- fault in here looks exactly like the button doing nothing at all.
        local name = PopupEdit(self):GetText():match("^%s*(.-)%s*$")
        local ok, p, err = pcall(RPVox.CreateProfile, RPVox, name,
                                 RPVox:ProfileName())
        if not ok then
            print("|cffff0000RPVox copy failed:|r " .. tostring(p))
            return
        end
        if not p then
            print("|cffff0000RPVox:|r " .. (err or "could not copy."))
            return
        end
        local ok2, err2 = pcall(function()
            RPVox:UseProfile(name)
            AfterProfileChange("copied to '" .. name .. "'.")
        end)
        if not ok2 then
            print("|cffff0000RPVox copied, but refreshing failed:|r "
                .. tostring(err2))
        end
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = PopupOf(self) or self:GetParent()
        StaticPopupDialogs["RPVox_COPY_PROFILE"].OnAccept(parent)
        parent:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}

StaticPopupDialogs["RPVox_RENAME_PROFILE"] = {
    text = "New name for this profile:",
    button1 = ACCEPT, button2 = CANCEL,
    hasEditBox = true, maxLetters = 40,
    OnShow = function(self)
        PopupEdit(self):SetText(RPVox:ProfileName() or "")
        PopupEdit(self):SetFocus()
        PopupEdit(self):HighlightText()
    end,
    OnAccept = function(self)
        local name = PopupEdit(self):GetText():match("^%s*(.-)%s*$")
        local ok, err = RPVox:RenameProfile(RPVox:ProfileName(), name)
        if not ok then
            print("|cffff0000RPVox:|r " .. (err or "could not rename."))
            return
        end
        AfterProfileChange("renamed to '" .. name .. "'.")
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = PopupOf(self) or self:GetParent()
        StaticPopupDialogs["RPVox_RENAME_PROFILE"].OnAccept(parent)
        parent:Hide()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}

StaticPopupDialogs["RPVox_DELETE_PROFILE"] = {
    text = "Delete this profile and every line in it? This cannot be undone.",
    button1 = YES, button2 = NO,
    OnAccept = function()
        local name = RPVox:ProfileName()
        local ok, err = RPVox:DeleteProfile(name)
        if not ok then
            print("|cffff0000RPVox:|r " .. (err or "could not delete."))
            return
        end
        AfterProfileChange("deleted '" .. name .. "'.")
    end,
    timeout = 0, whileDead = true, hideOnEscape = true,
}

-- Entry point --------------------------------------------------------------

function RPVox:ToggleUI()
    if not UI.frame then
        -- Building sliders fires OnValueChanged at their starting value. Without
        -- this guard those handlers write over saved settings before Refresh
        -- has had a chance to load them.
        UI.updating = true
        UI.frame = CreateUI()
        UI.updating = false
    end
    if UI.frame:IsShown() then
        UI.frame:Hide()
    else
        UI:Refresh()
        UI.frame:Show()
    end
end

RPVox.UI = UI
