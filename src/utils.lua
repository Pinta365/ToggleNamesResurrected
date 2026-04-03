local addonName, AddonTable = ...

--- Returns true if the player is currently resting.
function AddonTable.IsResting()
    if IsResting and type(IsResting) == "function" then
        return IsResting()
    end
    if GetRestState and type(GetRestState) == "function" then
        local ok, a = pcall(GetRestState)
        if ok then
            if type(a) == "boolean" then return a end
            if type(a) == "number" then return a > 0 end
        end
    end
    return false
end

--- Print debug message if debug mode is enabled.
--- @param ... any Message parts
function AddonTable.Debug(...)
    local settings = AddonTable.getSettingsTable and AddonTable.getSettingsTable()
    if settings and settings.debug then
        print("|cff888888[ToggleNames Debug]|r", ...)
    end
end
