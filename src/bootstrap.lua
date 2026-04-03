local addonName, AddonTable = ...

local function onEvent(self, event)
  if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_UPDATE_RESTING" then
    AddonTable.Core.UpdateNames()
  end
end

function AddonTable.OnAddonLoaded()
  -- ADDON_LOADED has already fired by the time this is called from the loader,
  -- so initialize state directly here instead of re-registering for the event.
  AddonTable.State.EnsureInitialized()

  local frame = CreateFrame("Frame", "ToggleNamesFrame")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  frame:RegisterEvent("PLAYER_UPDATE_RESTING")
  frame:SetScript("OnEvent", onEvent)
end
