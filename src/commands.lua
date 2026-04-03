local addonName, AddonTable = ...

StaticPopupDialogs["TOGGLENAMESR_RESET_CONFIRM"] = {
    text = "Reset ToggleNames settings to defaults and reload the UI?",
    button1 = "Reset",
    button2 = "Cancel",
    OnAccept = function()
        AddonTable.State.ResetToDefaults()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
}

function AddonTable.initCommands()
    if AddonTable.commandsInitialized then
        return
    end

    local function boolToText(v)
        return v and "|cff00FF00ON|r" or "|cffFF4444OFF|r"
    end

    local function cvarToBool(name)
        local value = GetCVar(name)
        return tostring(value) == "1"
    end

    local function printStatus()
        local c = "|cff45D388[ToggleNames]|r"
        if type(ToggleNames) ~= "table" then
            print(c, "Status unavailable: settings table not initialized yet.")
            return
        end

        local inInstance, instanceType = IsInInstance()
        local contextKey
        local contextLabel

        if inInstance then
            contextKey = instanceType or "outside"
            contextLabel = "instance:" .. tostring(instanceType or "unknown")
        elseif AddonTable.IsResting() then
            contextKey = "city"
            contextLabel = "city/resting"
        else
            contextKey = "outside"
            contextLabel = "outside"
        end

        local guildTbl = type(ToggleNames.guild) == "table" and ToggleNames.guild or {}
        local titleTbl = type(ToggleNames.title) == "table" and ToggleNames.title or {}

        local desiredGuild = guildTbl[contextKey]
        local desiredTitle = titleTbl[contextKey]
        if desiredGuild == nil then desiredGuild = guildTbl.outside end
        if desiredTitle == nil then desiredTitle = titleTbl.outside end

        local currentGuild = cvarToBool("UnitNamePlayerGuild")
        local currentTitle = cvarToBool("UnitNamePlayerPVPTitle")

        print(c, "Context:", contextLabel)
        print(c, "Guild desired/current:", boolToText(desiredGuild), "/", boolToText(currentGuild))
        print(c, "Title desired/current:", boolToText(desiredTitle), "/", boolToText(currentTitle))
    end

    local function printHelp()
        local c = "|cff45D388[ToggleNames]|r"
        print(c, "Commands:")
        print(c, "|cffFFFFFF/tnr debug|r - toggle debug output")
        print(c, "|cffFFFFFF/tnr status|r - print current context and CVar state")
        print(c, "|cffFFFFFF/tnr reset|r - reset all ToggleNames settings")
        print(c, "|cffFFFFFF/tnr update|r - apply current settings now")
    end

    SlashCmdList["TOGGLENAMESR"] = function(msg)
        local cmd = (msg and msg:match("^%s*(%S*)%s*$") or ""):lower()
        local settings = AddonTable.getSettingsTable and AddonTable.getSettingsTable()

        if cmd == "debug" then
            if settings then
                settings.debug = not settings.debug
                print("|cff45D388[ToggleNames]|r Debug", settings.debug and "|cff00FF00ON|r" or "|cffFF4444OFF|r")
            end
        elseif cmd == "reset" then
            StaticPopup_Show("TOGGLENAMESR_RESET_CONFIRM")
        elseif cmd == "update" then
            if AddonTable.Core and type(AddonTable.Core.UpdateNames) == "function" then
                AddonTable.Core.UpdateNames()
                print("|cff45D388[ToggleNames]|r Applied current settings.")
            end
        elseif cmd == "status" then
            printStatus()
        else
            printHelp()
        end
    end

    SLASH_TOGGLENAMESR1 = "/tnr"
    SLASH_TOGGLENAMESR2 = "/togglenames"
    AddonTable.commandsInitialized = true
end
