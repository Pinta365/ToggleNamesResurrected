local addonName, AddonTable = ...

AddonTable.State = AddonTable.State or {}

local DEFAULTS = {
    guild = {
        outside = true,
        party = false,
        raid = false,
        pvp = false,
        arena = false,
        city = true,
    },
    title = {
        outside = true,
        party = false,
        raid = false,
        pvp = false,
        arena = false,
        city = true,
    },
}

local function mergeMissingKeys(dest, defaults)
    if type(dest) ~= "table" then dest = {} end
    if type(defaults) ~= "table" then return dest end

    for k, v in pairs(defaults) do
        if type(v) == "table" then
            if type(dest[k]) ~= "table" then
                dest[k] = {}
            end
            mergeMissingKeys(dest[k], v)
        elseif dest[k] == nil then
            dest[k] = v
        end
    end

    return dest
end

local function copyTable(src, dest)
    if type(dest) ~= "table" then dest = {} end
    if type(src) == "table" then
        for k, v in pairs(src) do
            if type(v) == "table" then
                dest[k] = copyTable(v, dest[k])
            else
                dest[k] = v
            end
        end
    end
    return dest
end

function AddonTable.State.GetDefaults()
    return DEFAULTS
end

function AddonTable.State.EnsureInitialized()
    ToggleNames = ToggleNames or {}
    AddonTable.State.TempValues = AddonTable.State.TempValues or {}

    local defaults = AddonTable.State.GetDefaults()
    mergeMissingKeys(ToggleNames, defaults)

    if type(ToggleNames.guild) ~= "table" or type(ToggleNames.title) ~= "table" then
        ToggleNames = copyTable(defaults, ToggleNames)
    end

    AddonTable.State.TempValues = copyTable(ToggleNames, AddonTable.State.TempValues)
    return ToggleNames
end

function AddonTable.State.SyncTempFromSaved()
    ToggleNames = ToggleNames or {}
    AddonTable.State.TempValues = copyTable(ToggleNames, AddonTable.State.TempValues)
    return AddonTable.State.TempValues
end

function AddonTable.State.CopySavedFromTemp()
    AddonTable.State.TempValues = AddonTable.State.TempValues or {}
    ToggleNames = copyTable(AddonTable.State.TempValues, ToggleNames)
    return ToggleNames
end

function AddonTable.State.ResetToDefaults()
    ToggleNames = copyTable(AddonTable.State.GetDefaults(), {})
    AddonTable.State.TempValues = copyTable(ToggleNames, AddonTable.State.TempValues)
    return ToggleNames
end
