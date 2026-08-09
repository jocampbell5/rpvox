-- RPVox -- configuration UI
-- /rpcry opens this window.

local ROW_HEIGHT   = 22
local VISIBLE_ROWS = 13
-- No channel picker: each line decides for itself. "/em ..." emotes,
-- everything else is said. Say and emote are the only two, deliberately.

local UI = {}
UI.category = "COMBAT"
local selected      -- currently selected trigger table

-- Helpers -----------------------------------------------------------------

-- The visible list is always just the current tab's triggers.
local function Triggers()
    if not RPVoxDB then return {} end
    return RPVox:TriggersInCategory(UI.category)
end

local function WordsToText(words)
    return table.concat(words or {}, "\n")
end

-- The chance slider is logarithmic. A linear 0-100 slider would cram every
-- useful value into the first pixel, so slider position 0-100 maps onto
-- 0.01% - 100% across four decades: 0 = 0.01, 25 = 0.1, 50 = 1, 75 = 10, 100 = 100.
local function Log10(x)
    if math.log10 then return math.log10(x) end
    return math.log(x) / math.log(10)
end

local function PosToChance(pos)
    local v = 0.01 * (10 ^ (pos / 25))
    -- coarser steps as the numbers get bigger, so the readout stays sane
    if v < 1 then
        v = math.floor(v * 100 + 0.5) / 100
    elseif v < 10 then
        v = math.floor(v * 10 + 0.5) / 10
    else
        v = math.floor(v + 0.5)
    end
    return math.max(0.01, math.min(100, v))
end

local function ChanceToPos(chance)
    chance = math.max(0.01, math.min(100, chance or 0.5))
    return math.max(0, math.min(100, 25 * (Log10(chance) + 2)))
end

-- Percentages here run from 0.01 to 100, so trailing zeros are noise.
-- No trailing zeros: 0.20 reads as 0.2, 3.00 as 3. Values under a tenth keep
-- their second decimal, since the scale bottoms out at 0.01.
local function FormatPct(v, bare)
    v = v or 0
    local s
    if v >= 10 then
        s = ("%d"):format(v + 0.5)
    else
        s = ("%.2f"):format(v)
        s = s:gsub("0+$", "")     -- 0.20 -> 0.2, 3.00 -> 3.
        s = s:gsub("%.$", "")     -- 3. -> 3
        if s == "" or s == "0" then s = ("%.2f"):format(v) end
    end
    return bare and s or (s .. "%")
end

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

    -- Where the lines go ------------------------------------------------------
    -- Ticked (the default): everything goes to the Vox channel, so a talkative
    -- character never fills public chat. Unticked: /say and /em as before.
    local voxBox = CreateFrame("CheckButton", "$parentVox", f, "UICheckButtonTemplate")
    voxBox:SetPoint("TOPLEFT", master, "BOTTOMLEFT", 0, -2)
    voxBox:SetSize(24, 24)
    voxBox.text = voxBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    voxBox.text:SetPoint("LEFT", voxBox, "RIGHT", 2, 0)
    voxBox.text:SetText("Speak in the " .. (RPVox.VOX_CHANNEL or "Vox")
        .. " channel, not /say")
    voxBox:SetScript("OnClick", function(self)
        local p = RPVox:Profile()
        if self:GetChecked() then
            p.output = "VOX"
            RPVox:JoinVox()
        else
            p.output = "PUBLIC"
        end
    end)
    f.voxBox = voxBox

    -- Chattiness ------------------------------------------------------------
    -- One timer for the whole profile: after any line, everything stays quiet
    -- until it expires. Dragging left talks more, right talks less.
    local ggap = CreateFrame("Slider", "RPVoxGlobalSlider", f, "OptionsSliderTemplate")
    ggap:SetPoint("TOPLEFT", voxBox, "BOTTOMLEFT", 4, -16)
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
    listBG:SetSize(200, 320)

    local scroll = CreateFrame("ScrollFrame", "RPVoxListScroll", listBG,
                               "FauxScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -4)
    scroll:SetPoint("BOTTOMRIGHT", -26, 4)
    scroll:SetScript("OnVerticalScroll", function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT,
                                         function() UI:RefreshList() end)
    end)
    f.scroll = scroll

    f.rows = {}
    for i = 1, VISIBLE_ROWS do
        local row = CreateFrame("Button", nil, listBG)
        row:SetSize(168, ROW_HEIGHT)
        if i == 1 then
            row:SetPoint("TOPLEFT", 6, -6)
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
    local chance = CreateFrame("Slider", "RPVoxChanceSlider", pane,
                               "OptionsSliderTemplate")
    chance:SetPoint("TOPLEFT", on, "BOTTOMLEFT", 4, -24)
    chance:SetWidth(180)
    -- Slider position is 0-100; the value it represents is logarithmic.
    chance:SetMinMaxValues(0, 100)
    chance:SetValueStep(0.5)
    chance:SetObeyStepOnDrag(true)
    _G[chance:GetName() .. "Low"]:SetText("0.01%")
    _G[chance:GetName() .. "High"]:SetText("100%")
    chance:SetScript("OnValueChanged", function(self, pos)
        local value = PosToChance(pos)
        _G[self:GetName() .. "Text"]:SetText("Chance: " .. FormatPct(value))
        if selected and not UI.updating then
            selected.chance = value
            selected.chanceCustom = true  -- yours now; updates leave it alone
            pane.chanceBox:SetText(FormatPct(value, true))
        end
    end)
    pane.chance = chance

    pane.chanceBox = MakeValueBox(pane, chance, 54, function(text)
        if not selected then return end
        -- gsub returns the string AND a replacement count. Passing that
        -- straight into tonumber() made the count look like a number base,
        -- which errored out and silently discarded whatever you typed.
        local cleaned = (text or ""):gsub("[%%%s]", "")
        local n = tonumber(cleaned)
        if n then
            selected.chance = math.max(0.01, math.min(100, math.floor(n * 100 + 0.5) / 100))
            selected.chanceCustom = true  -- yours now; updates leave it alone
        end
        UI:RefreshDetail()
    end)
    local pct = pane:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    pct:SetPoint("LEFT", pane.chanceBox, "RIGHT", 3, 0)
    pct:SetText("%")

    -- Sayings box
    local sayLabel = pane:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sayLabel:SetPoint("TOPLEFT", chance, "BOTTOMLEFT", -4, -30)
    sayLabel:SetText("Sayings -- one per line:")

    local syntax = pane:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    syntax:SetPoint("LEFT", sayLabel, "RIGHT", 8, 0)
    syntax:SetText("|cff909090/em = emote   %t = target   [mood] = only in that mood|r")

    local boxBG = CreateFrame("Frame", nil, pane, "InsetFrameTemplate")
    boxBG:SetPoint("TOPLEFT", sayLabel, "BOTTOMLEFT", 0, -4)
    boxBG:SetPoint("BOTTOMRIGHT", pane, "BOTTOMRIGHT", 0, 0)

    local boxScroll = CreateFrame("ScrollFrame", "RPVoxSayingsScroll", boxBG,
                                  "UIPanelScrollFrameTemplate")
    boxScroll:SetPoint("TOPLEFT", 6, -6)
    boxScroll:SetPoint("BOTTOMRIGHT", -26, 6)

    local edit = CreateFrame("EditBox", "RPVoxSayingsEdit", boxScroll)
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
        ScrollingEdit_OnTextChanged(self, self:GetParent())
    end)
    edit:SetScript("OnCursorChanged", ScrollingEdit_OnCursorChanged)
    boxScroll:SetScrollChild(edit)
    boxScroll:SetScript("OnSizeChanged", function(self, w)
        edit:SetWidth(w)
    end)
    boxBG:SetScript("OnMouseDown", function() edit:SetFocus() end)
    pane.edit = edit

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
    PanelTemplates_SetTab(f, 1)

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
    local chanceVal = selected.chance or 0.5
    pane.chance:SetValue(ChanceToPos(chanceVal))
    -- the slider snaps to its own steps, so label from the stored value
    _G["RPVoxChanceSliderText"]:SetText("Chance: " .. FormatPct(chanceVal))
    pane.chanceBox:SetText(FormatPct(chanceVal, true))
    pane.edit:SetText(WordsToText(selected.words))
    pane.edit:ClearFocus()
    self.frame.deleteButton:SetEnabled(RPVox:IsRemovable(selected) and true or false)
    self.updating = false
end

local CATEGORY_HINT = {
    COMBAT   = "Drag a spell from your spellbook onto this window to add it.",
    REACTION = "Things that happen to you. An entry with no lines never fires.",
    IDLE     = "Everyday actions. Professions match the window you have open.",
}

function UI:SetCategory(cat)
    self.category = cat
    self.lastSelected = self.lastSelected or {}
    if selected then
        self.lastSelected[selected.category or "COMBAT"] = selected
    end
    selected = self.lastSelected[cat]
    -- make sure the remembered entry still belongs to this tab
    if not selected or (selected.category or "COMBAT") ~= cat then
        selected = Triggers()[1]
    end
    FauxScrollFrame_SetOffset(self.frame.scroll, 0)
    _G[self.frame.scroll:GetName() .. "ScrollBar"]:SetValue(0)

    local combat = (cat == "COMBAT")
    self.frame.addButton:SetEnabled(combat)
    self.frame.hint:SetText(CATEGORY_HINT[cat] or "")

    self:Refresh()
end

function UI:Refresh()
    if not self.frame then return end
    local profile = RPVox:Profile()
    if not profile then return end

    self.frame.master:SetChecked(profile.enabled)
    self.frame.voxBox:SetChecked((profile.output or "VOX") == "VOX")

    UIDropDownMenu_SetText(self.frame.profileDD, RPVox:ProfileName() or "?")
    UIDropDownMenu_SetText(self.frame.moodDD, RPVox:GetMood() or "Any")
    self.frame.deleteProfileButton:SetEnabled(#RPVox:ProfileNames() > 1)

    local g = profile.globalCooldown or 180
    self.updating = true
    self.frame.globalSlider:SetValue(math.max(0, math.min(600, g)))
    _G["RPVoxGlobalSliderText"]:SetText("At most one line every " .. FormatTime(g))
    self.frame.globalBox:SetText(FormatTime(g))
    self.updating = false

    self.frame.addButton:SetEnabled(self.category == "COMBAT")
    self.frame.hint:SetText(CATEGORY_HINT[self.category] or "")
    if not selected or (selected.category or "COMBAT") ~= self.category then
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
    if self.category ~= "COMBAT" then
        PanelTemplates_SetTab(self.frame, 1)
        self:SetCategory("COMBAT")
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

-- Add-by-name popup --------------------------------------------------------

StaticPopupDialogs["RPVox_ADD_SPELL"] = {
    text = "Type a spell name, or drag a spell from your spellbook onto the window.",
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 60,
    OnShow = function(self)
        self.editBox:SetText("")
        self.editBox:SetFocus()
    end,
    OnAccept = function(self)
        local name = self.editBox:GetText():match("^%s*(.-)%s*$")
        if name ~= "" then
            local real, _, icon = GetSpellInfo(name)
            UI:AddSpell(real or name, icon)
        end
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
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
    OnShow = function(self) self.editBox:SetText("") self.editBox:SetFocus() end,
    OnAccept = function(self)
        local name = self.editBox:GetText():match("^%s*(.-)%s*$")
        local p, err = RPVox:CreateProfile(name)
        if not p then
            print("|cffff0000RPVox:|r " .. (err or "could not create."))
            return
        end
        RPVox:UseProfile(name)
        AfterProfileChange("created '" .. name .. "' and switched to it.")
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
        StaticPopupDialogs["RPVox_NEW_PROFILE"].OnAccept(parent)
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
        self.editBox:SetText((RPVox:ProfileName() or "") .. " copy")
        self.editBox:SetFocus()
        self.editBox:HighlightText()
    end,
    OnAccept = function(self)
        local name = self.editBox:GetText():match("^%s*(.-)%s*$")
        local p, err = RPVox:CreateProfile(name, RPVox:ProfileName())
        if not p then
            print("|cffff0000RPVox:|r " .. (err or "could not copy."))
            return
        end
        RPVox:UseProfile(name)
        AfterProfileChange("copied to '" .. name .. "'.")
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
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
        self.editBox:SetText(RPVox:ProfileName() or "")
        self.editBox:SetFocus()
        self.editBox:HighlightText()
    end,
    OnAccept = function(self)
        local name = self.editBox:GetText():match("^%s*(.-)%s*$")
        local ok, err = RPVox:RenameProfile(RPVox:ProfileName(), name)
        if not ok then
            print("|cffff0000RPVox:|r " .. (err or "could not rename."))
            return
        end
        AfterProfileChange("renamed to '" .. name .. "'.")
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent()
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
