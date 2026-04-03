local addonName, AddonTable = ...

AddonTable.name = addonName or "ToggleNamesResurrected"
AddonTable.title = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(AddonTable.name, "Title")) or AddonTable.name
AddonTable.version = (C_AddOns and C_AddOns.GetAddOnMetadata and C_AddOns.GetAddOnMetadata(AddonTable.name, "Version")) or "dev"

AddonTable.defaultSettings = {
    debug = false,
}

function AddonTable.getSettingsTable()
    ToggleNames = ToggleNames or {}
    ToggleNames.meta = ToggleNames.meta or {}
    return ToggleNames.meta
end

function AddonTable.initSettings()
    local settings = AddonTable.getSettingsTable()
    for key, value in pairs(AddonTable.defaultSettings) do
        if settings[key] == nil then
            settings[key] = value
        end
    end
end

local bootstrapFrame = CreateFrame("Frame")
bootstrapFrame:RegisterEvent("ADDON_LOADED")
bootstrapFrame:SetScript("OnEvent", function(self, _, loadedAddon)
    if loadedAddon ~= AddonTable.name then
        return
    end

    if AddonTable.initSettings then AddonTable.initSettings() end
    if AddonTable.initOptionsPanel then AddonTable.initOptionsPanel() end
    if AddonTable.initCommands then AddonTable.initCommands() end

    self:UnregisterEvent("ADDON_LOADED")
end)
