local addonName, ns = ...
local PA = ns.PA
local L  = ns.L

-- ─── Event Registration ───────────────────────────────────────────────────────
-- WoW Midnight 12.x blocks COMBAT_LOG_EVENT_UNFILTERED completely.
-- We now use:
--   • UNIT_SPELLCAST_SUCCEEDED  → detect player burst casts
--   • UNIT_AURA                 → detect PI received/expired (via C_UnitAuras)
-- These events are NOT restricted and work in all contexts.

local PA_EVENTS = {
    "UNIT_SPELLCAST_SUCCEEDED",
    "UNIT_AURA",
    "GROUP_ROSTER_UPDATE",
    "ZONE_CHANGED_NEW_AREA",
    "PLAYER_ENTERING_WORLD",
    "UNIT_CONNECTION",
    "PLAYER_SPECIALIZATION_CHANGED",
    "PLAYER_TALENT_UPDATE",
}

-- Power Infusion spell ID
local PI_SPELL_ID = 10060

function PA:RegisterEvents()
    if not self.rawEventFrame then
        self.rawEventFrame = CreateFrame("Frame", "PIAssistantEventFrame")
    end
    local ef = self.rawEventFrame
    ef:UnregisterAllEvents()

    self._deferredEvents = {}
    for _, event in ipairs(PA_EVENTS) do
        local ok = pcall(ef.RegisterEvent, ef, event)
        if not ok then
            self._deferredEvents[#self._deferredEvents + 1] = event
        end
    end

    ef:SetScript("OnEvent", function(_, event, ...)
        PA:DispatchEvent(event, ...)
    end)
end

-- Retry any events that failed to register during initial load.
function PA:RetryDeferredEvents()
    if not self._deferredEvents or #self._deferredEvents == 0 then return end
    local ef = self.rawEventFrame
    if not ef then return end
    for _, event in ipairs(self._deferredEvents) do
        pcall(ef.RegisterEvent, ef, event)
    end
    self._deferredEvents = nil
end

function PA:DispatchEvent(event, ...)
    -- Retry deferred registrations once we are fully in-game
    if event == "PLAYER_ENTERING_WORLD" then
        PA:RetryDeferredEvents()
        PA:PLAYER_ENTERING_WORLD()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        PA:OnUnitSpellcastSucceeded(...)
    elseif event == "UNIT_AURA" then
        PA:OnUnitAura(event, ...)
    elseif event == "GROUP_ROSTER_UPDATE" then
        PA:GROUP_ROSTER_UPDATE()
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        PA:ZONE_CHANGED_NEW_AREA()
    elseif event == "UNIT_CONNECTION" then
        PA:OnUnitConnection(event, ...)
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        PA:OnSpecChanged()
    elseif event == "PLAYER_TALENT_UPDATE" then
        PA:OnTalentUpdate()
    end
end

-- ─── Burst Detection via UNIT_SPELLCAST_SUCCEEDED ─────────────────────────────
-- Fires for: unitTarget, castGUID, spellID
-- This replaces the old CLEU SPELL_CAST_SUCCESS routing.

function PA:OnUnitSpellcastSucceeded(unit, castGUID, spellID)
    if not self:IsAddonEnabled() then return end
    if unit ~= "player" then return end

    -- Snoop mode: print detected casts for diagnostics
    if self.snoopEndTime and GetTime() < self.snoopEndTime then
        local spellName = ns.GetSpellName(spellID)
        local inMap = self.burstSpellMap and self.burstSpellMap[spellID] ~= nil
        self:Print(string.format(
            "|cff88aaff[SNOOP]|r UNIT_SPELLCAST_SUCCEEDED id=|cffffcc00%d|r name=%s map=%s",
            spellID, tostring(spellName),
            inMap and "|cff00ff00YES|r" or "|cffff4444no|r"))
    end

    -- Route to BurstDetector
    self:OnPlayerSpellEvent("SPELL_CAST_SUCCESS", spellID, ns.GetSpellName(spellID))
end

-- ─── PI Detection via UNIT_AURA ───────────────────────────────────────────────
-- UNIT_AURA fires for: unit, updateInfo (table with addedAuras, updatedAuraInstanceIDs, etc.)
-- We check for Power Infusion buff on the player using C_UnitAuras.

function PA:OnUnitAura(event, unit, updateInfo)
    if not self:IsAddonEnabled() then return end

    -- ── Player aura changes: detect PI applied/removed ────────────────────
    if unit == "player" then
        self:CheckPlayerForPI(updateInfo)
        return
    end

    -- Only process group units (party1-4, raid1-40), skip things like targettarget
    if not unit or (not unit:match("^party%d") and not unit:match("^raid%d")) then
        return
    end

    -- ── Group member aura changes: refresh priest status ──────────────────
    local key = self:GetUnitKey(unit)
    if key and self.priests and self.priests[key] then
        self:UpdatePriestUnit(unit)
    end
end

-- Checks if Power Infusion was just applied or removed from the player.
-- In Midnight 12.x, auraData fields (spellId, name, etc.) from UNIT_AURA
-- payloads and C_UnitAuras.GetAuraDataByAuraInstanceID are "secret" values
-- that CANNOT be compared with == (causes taint errors).
--
-- Safe approach: use C_UnitAuras.GetPlayerAuraBySpellID which returns
-- non-secret data for the local player's own auras lookup by spell ID.
function PA:CheckPlayerForPI(updateInfo)
    local hadPI = self.piActive
    local hasPI = self:PlayerHasPI()

    -- PI just appeared
    if hasPI and not hadPI then
        -- Try to get source from the aura data (GetPlayerAuraBySpellID is safe)
        local sourceName = "Unknown"
        local aura = C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID(PI_SPELL_ID)
        if aura and aura.sourceUnit then
            sourceName = UnitName(aura.sourceUnit) or "Unknown"
        end
        self:OnPIReceived(sourceName, GetTime())
        self:OnPlayerSpellEvent("SPELL_AURA_APPLIED", PI_SPELL_ID, "Power Infusion")
        return
    end

    -- PI just disappeared
    if hadPI and not hasPI then
        self:OnPIExpired()
        return
    end

    -- Detect burst spells applied as auras on the player.
    -- Since we can't read spellId from addedAuras (secret), we scan for
    -- each known burst spell using GetPlayerAuraBySpellID (safe API).
    if updateInfo and (updateInfo.addedAuras or updateInfo.updatedAuraInstanceIDs) then
        if self.burstSpellMap then
            for spellID, spellCfg in pairs(self.burstSpellMap) do
                -- Only check spells that track SPELL_AURA_APPLIED
                local tracksAura = false
                for _, ev in ipairs(spellCfg.events or {}) do
                    if ev == "SPELL_AURA_APPLIED" then
                        tracksAura = true
                        break
                    end
                end
                if tracksAura then
                    local aura = C_UnitAuras.GetPlayerAuraBySpellID(spellID)
                    if aura then
                        -- Only trigger if we haven't already triggered for this aura recently
                        local lastTrigger = self.burstSpellCooldowns and self.burstSpellCooldowns[spellID] or 0
                        if (GetTime() - lastTrigger) > 1.0 then
                            self:OnPlayerSpellEvent("SPELL_AURA_APPLIED", spellID, aura.name or ns.GetSpellName(spellID))
                        end
                    end
                end
            end
        end
    end
end

-- Scans player buffs for Power Infusion. Used as fallback when updateInfo
-- doesn't have enough data (or on older API versions).
function PA:PlayerHasPI()
    if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
        local aura = C_UnitAuras.GetPlayerAuraBySpellID(PI_SPELL_ID)
        return aura ~= nil
    end
    -- Legacy fallback: AuraUtil.FindAuraByName
    if AuraUtil and AuraUtil.FindAuraByName then
        local name = AuraUtil.FindAuraByName("Power Infusion", "player", "HELPFUL")
        return name ~= nil
    end
    return false
end

-- ─── Snoop Command (updated for new event system) ─────────────────────────────

function PA:StartCLEUSnoop()
    self.snoopEndTime = GetTime() + 10
    self:Print("|cffffcc00PI Snoop ativo por 10 segundos.|r Use sua skill agora.")

    local ef = self.rawEventFrame
    if ef then
        local hasSpellcast = ef:IsEventRegistered("UNIT_SPELLCAST_SUCCEEDED")
        local hasAura = ef:IsEventRegistered("UNIT_AURA")
        self:Print("  Frame: ok")
        self:Print("  UNIT_SPELLCAST_SUCCEEDED registrado: " ..
            (hasSpellcast and "|cff00ff00sim|r" or "|cffff4444NAO|r"))
        self:Print("  UNIT_AURA registrado: " ..
            (hasAura and "|cff00ff00sim|r" or "|cffff4444NAO|r"))
    else
        self:Print("  |cffff4444rawEventFrame não existe! Execute /reload|r")
    end
end

-- ─── Group / Zone Events ──────────────────────────────────────────────────────

function PA:GROUP_ROSTER_UPDATE()
    self:ScanGroupForPriests()
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshPriestsTab()
        self:RefreshDashboard()
    end
end

function PA:ZONE_CHANGED_NEW_AREA()
    self:ScanGroupForPriests()
end

function PA:PLAYER_ENTERING_WORLD()
    self:ScanGroupForPriests()
    self:LoadSpecProfile()

    -- Check if PI is already active (e.g., after /reload mid-combat)
    if self:PlayerHasPI() and not self.piActive then
        self.piActive = true
    end

    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshMainWindow()
    end
end

-- ─── Unit Events ──────────────────────────────────────────────────────────────

function PA:OnUnitConnection(event, unit, isConnected)
    local key = self:GetUnitKey(unit)
    if key and self.priests and self.priests[key] then
        self.priests[key].online = isConnected
        if self.mainFrame and self.mainFrame:IsShown() then
            self:RefreshPriestsTab()
        end
        -- If selected priest just went offline, select next
        if not isConnected and self.db.profile.priests.selected == key then
            self:SelectNextAvailablePriest()
        end
    end
end

function PA:OnUnitHealth(event, unit)
    local key = self:GetUnitKey(unit)
    if key and self.priests and self.priests[key] then
        local alive = not UnitIsDeadOrGhost(unit)
        self.priests[key].alive = alive
        if not alive and self.db.profile.priests.selected == key then
            self:SelectNextAvailablePriest()
        end
    end
end

-- ─── Spec / Talent Events ─────────────────────────────────────────────────────

function PA:OnSpecChanged()
    self:LoadSpecProfile()
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshMainWindow()
    end
end

function PA:OnTalentUpdate()
    -- Hero talent may have changed
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshDashboard()
    end
end

-- ─── PI Detection Callbacks ───────────────────────────────────────────────────

function PA:OnPIReceived(sourceName, timestamp)
    local now = GetTime()
    self.lastPIReceivedTime   = now
    self.lastPIReceivedSource = sourceName
    self.piActive             = true

    self:RecordPIReceived(sourceName, now)
    self:FireWeakAuraEvent("PI_RECEIVED", sourceName)

    if self.db.profile.alert.visual then
        self:ShowAlert(L["ALERT_PI_RECEIVED"])
    end
    if self.db.profile.alert.sound then
        self:PlayAlertSound()
    end

    self:DebugLog(1, "PI received from: %s", tostring(sourceName))

    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshMainWindow()
    end
end

function PA:OnPIExpired()
    self.piActive = false
    self:DebugLog(1, "PI expired")
end
