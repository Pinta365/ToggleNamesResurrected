local ADDON_NAME, AddonTable = ...

-- Ensure the SavedVariables table exists. The name `ToggleNames` is declared in the TOC.
ToggleNames = ToggleNames or {}

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, name)
    if name == ADDON_NAME then
        AddonTable.OnAddonLoaded()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
