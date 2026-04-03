local addonName, AddonTable = ...

local INDENT = 16
local SECTION_GAP = 14
local AFTER_HEADER = 8
local ROW_CHECK = 28

local CONTEXT_OPTIONS = {
    { key = "outside", label = "Outside" },
    { key = "city", label = "City / Resting" },
    { key = "party", label = "Party (5-man)" },
    { key = "raid", label = "Raid" },
    { key = "pvp", label = "Battleground" },
    { key = "arena", label = "Arena" },
}

local function sectionHeader(parent, label, yOffset)
    local fs = parent:CreateFontString(nil, "overlay", "GameFontNormal")
    fs:SetPoint("TOPLEFT", INDENT, yOffset)
    fs:SetText(label)
    local line = parent:CreateTexture(nil, "BACKGROUND")
    line:SetColorTexture(0.4, 0.4, 0.4, 0.6)
    line:SetHeight(1)
    line:SetPoint("LEFT", fs, "RIGHT", 6, 0)
    line:SetPoint("RIGHT", parent, "RIGHT", -INDENT, 0)
    return yOffset - AFTER_HEADER
end

local function checkbox(parent, label, yOffset)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(26, 26)
    cb:SetPoint("TOPLEFT", INDENT, yOffset)
    cb.Text:SetText(label)
    cb.Text:SetFontObject("GameFontHighlightSmall")
    return cb, yOffset - ROW_CHECK
end

local function applyToggle(section, key, value)
    AddonTable.State.EnsureInitialized()
    local checked = value == true
    ToggleNames[section][key] = checked
    AddonTable.State.TempValues[section][key] = checked
    AddonTable.Core.UpdateNames()
end

local function initOptionsPanel()
    if AddonTable.optionsInitialized then
        return
    end

    local panel = CreateFrame("Frame", "ToggleNamesResurrectedOptionsPanel")
    panel.name = "ToggleNames Resurrected"

    local header = panel:CreateFontString(nil, "overlay", "GameFontHighlightLarge")
    header:SetPoint("TOPLEFT", INDENT, -INDENT)
    header:SetText("ToggleNames Resurrected")

    local y = -46
    y = sectionHeader(panel, "Guild Name Visibility", y - SECTION_GAP)
    y = y - AFTER_HEADER

    panel.guildCheckboxes = panel.guildCheckboxes or {}
    for _, context in ipairs(CONTEXT_OPTIONS) do
        local cb
        cb, y = checkbox(panel, context.label, y)
        cb:SetScript("OnClick", function(self)
            applyToggle("guild", context.key, self:GetChecked())
        end)
        panel.guildCheckboxes[context.key] = cb
    end

    y = sectionHeader(panel, "Title Visibility", y - SECTION_GAP)
    y = y - AFTER_HEADER

    panel.titleCheckboxes = panel.titleCheckboxes or {}
    for _, context in ipairs(CONTEXT_OPTIONS) do
        local cb
        cb, y = checkbox(panel, context.label, y)
        cb:SetScript("OnClick", function(self)
            applyToggle("title", context.key, self:GetChecked())
        end)
        panel.titleCheckboxes[context.key] = cb
    end

    y = sectionHeader(panel, "Utilities", y - SECTION_GAP)
    y = y - AFTER_HEADER

    local debugCb
    debugCb, y = checkbox(panel, "Show debug messages", y)
    debugCb:SetScript("OnClick", function(self)
        local settings = AddonTable.getSettingsTable and AddonTable.getSettingsTable()
        if settings then
            settings.debug = self:GetChecked() == true
        end
    end)
    panel.debugCheckbox = debugCb

    local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    resetBtn:SetSize(140, 22)
    resetBtn:SetPoint("TOPLEFT", INDENT, y)
    resetBtn:SetText("Reset ToggleNames")
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("TOGGLENAMESR_RESET_CONFIRM")
    end)

    local function RefreshOptions()
        AddonTable.State.EnsureInitialized()

        for _, context in ipairs(CONTEXT_OPTIONS) do
            local key = context.key
            local guildCb = panel.guildCheckboxes and panel.guildCheckboxes[key]
            local titleCb = panel.titleCheckboxes and panel.titleCheckboxes[key]

            if guildCb then guildCb:SetChecked(ToggleNames.guild[key] == true) end
            if titleCb then titleCb:SetChecked(ToggleNames.title[key] == true) end
        end

        local settings = AddonTable.getSettingsTable and AddonTable.getSettingsTable()
        debugCb:SetChecked(settings and settings.debug == true)
    end

    panel:SetScript("OnShow", RefreshOptions)
    RefreshOptions()

    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
    AddonTable.settingsCategory = category

    AddonTable.optionsInitialized = true
end

AddonTable.initOptionsPanel = initOptionsPanel
