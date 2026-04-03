local addonName, AddonTable = ...

AddonTable.Core = AddonTable.Core or {}

local function setGuild(value)
    AddonTable.SetCVarSafe("UnitNamePlayerGuild", value and "1" or "0")
end

local function setTitle(value)
    AddonTable.SetCVarSafe("UnitNamePlayerPVPTitle", value and "1" or "0")
end

function AddonTable.Core.UpdateNames()
    AddonTable.State.EnsureInitialized()

    local inInstance, instanceType = IsInInstance()
    if inInstance then
        local guildValue = ToggleNames.guild[instanceType]
        local titleValue = ToggleNames.title[instanceType]

        if guildValue == nil then guildValue = ToggleNames.guild.outside end
        if titleValue == nil then titleValue = ToggleNames.title.outside end

        setGuild(guildValue)
        setTitle(titleValue)
    else
        if AddonTable.IsResting() then
            setGuild(ToggleNames.guild.city)
            setTitle(ToggleNames.title.city)
        else
            setGuild(ToggleNames.guild.outside)
            setTitle(ToggleNames.title.outside)
        end
    end
end
