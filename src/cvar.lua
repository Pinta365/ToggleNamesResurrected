local addonName, AddonTable = ...

local pendingCVarUpdates = {}
local pendingCVarFrame
local applyPendingCVars  -- forward declaration

local function ensurePendingCVarListener()
    if pendingCVarFrame then
        return
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function()
        applyPendingCVars()
    end)
    pendingCVarFrame = f
end

local function trySetCVar(name, value)
    local ok = pcall(SetCVar, name, value)
    return ok == true
end

applyPendingCVars = function()
    local remaining = {}
    local inCombat = (InCombatLockdown and InCombatLockdown()) or (UnitAffectingCombat and UnitAffectingCombat("player"))

    for name, value in pairs(pendingCVarUpdates) do
        if inCombat then
            remaining[name] = value
        else
            local current = GetCVar(name)
            if tostring(current) ~= tostring(value) then
                if not trySetCVar(name, value) then
                    remaining[name] = value
                end
            end
        end
    end

    pendingCVarUpdates = remaining

    if not next(pendingCVarUpdates) and pendingCVarFrame then
        pendingCVarFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        pendingCVarFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
        pendingCVarFrame:SetScript("OnEvent", nil)
        pendingCVarFrame = nil
    end
end

function AddonTable.SetCVarSafe(name, value)
    local current = GetCVar(name)
    if tostring(current) == tostring(value) then
        pendingCVarUpdates[name] = nil
        return
    end

    local inCombat = (InCombatLockdown and InCombatLockdown()) or (UnitAffectingCombat and UnitAffectingCombat("player"))

    -- In Midnight, blocked/protected CVar writes can occur in combat, so defer
    -- all writes during combat and retry on safe events.
    if inCombat then
        pendingCVarUpdates[name] = value
        ensurePendingCVarListener()
        return
    end

    if not trySetCVar(name, value) then
        pendingCVarUpdates[name] = value
        ensurePendingCVarListener()
    else
        pendingCVarUpdates[name] = nil
    end
end
