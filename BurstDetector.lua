local addonName, ns = ...
local PA = ns.PA
local L  = ns.L

-- --- Initialization -----------------------------------------------------------

function PA:InitializeBurstDetector()
    self.burstSpellCooldowns = {}  -- [spellID] = lastTriggeredTime
    self.currentBurstWeight  = 0
    self.burstWindowActive   = false
    self:LoadSpecProfile()
end

-- --- Spec Profile Loading -----------------------------------------------------

-- Loads (or reloads) the burst spell list from DB for current class/spec.
-- If no custom spells are saved yet, seeds from ClassProfiles defaults.
-- Lookup order (locale-independent → locale fallback):
--   1. specID numeric lookup via SpecIDToProfile
--   2. Localized spec name via SpecNameAliases
--   3. Uppercased localized name direct lookup (works on EN clients)
function PA:LoadSpecProfile()
    local class, specID, specNameLocalized = self:GetPlayerClassSpec()
    self.playerClass         = class
    self.playerSpecID        = specID
    self.playerSpecName      = specNameLocalized  -- localized, display only

    -- -- Resolve profile key (locale-independent) --------------------------
    local profileKey = nil

    -- 1. Numeric specID → guaranteed locale-independent
    if specID and ns.SpecIDToProfile and ns.SpecIDToProfile[specID] then
        local entry = ns.SpecIDToProfile[specID]
        if entry.class == class then
            profileKey = entry.spec
        end
    end

    -- 2. Localized name in alias table (covers PT, ES, DE common specs)
    if not profileKey and specNameLocalized then
        local upper = specNameLocalized:upper():gsub("[%s%-]", "")
        profileKey = ns.SpecNameAliases and ns.SpecNameAliases[upper] or nil
    end

    -- 3. Direct uppercase match (English clients; name already matches key)
    if not profileKey and specNameLocalized then
        profileKey = specNameLocalized:upper():gsub("%s+", "")
    end

    self.playerSpec = profileKey or "UNKNOWN"

    self:DebugLog(2, "BurstDetector: class=%s specID=%s localName=%s → profileKey=%s",
        tostring(class), tostring(specID), tostring(specNameLocalized), tostring(self.playerSpec))

    -- -- Seed spell list if empty -------------------------------------------
    local savedSpells = self.db.profile.burst.spells
    if not savedSpells or #savedSpells == 0 then
        if ns.GetDefaultClassProfile then
            local defaultProfile = ns.GetDefaultClassProfile(class, self.playerSpec)
            self.db.profile.burst.spells = defaultProfile.spells
        else
            self.db.profile.burst.spells = {}
        end
    end

    -- -- Build spellID → config lookup -------------------------------------
    self.burstSpellMap = {}
    for _, spell in ipairs(self.db.profile.burst.spells) do
        if spell.id and spell.id > 0 then
            self.burstSpellMap[spell.id] = spell
        end
    end

    self.burstSpellCooldowns = {}

    self:DebugLog(1, "BurstDetector: loaded %d spells for %s/%s",
        #self.db.profile.burst.spells, tostring(class), tostring(self.playerSpec))
end

-- --- Spell Event Handler ------------------------------------------------------

-- Called by Events.lua for every player spell cast/aura event.
-- In Midnight 12.x, events come from:
--   • UNIT_SPELLCAST_SUCCEEDED → mapped to "SPELL_CAST_SUCCESS"
--   • UNIT_AURA addedAuras     → mapped to "SPELL_AURA_APPLIED"
function PA:OnPlayerSpellEvent(event, spellID, spellName)
    if not self.db.profile.burst.enabled then return end
    if not self.db.profile.enabled       then return end

    local spellCfg = self.burstSpellMap and self.burstSpellMap[spellID]
    if not spellCfg then return end
    if not spellCfg.enabled then return end

    -- Check if this event type is monitored for this spell.
    -- We also accept "SPELL_AURA_REFRESH" and "SPELL_AURA_APPLIED_DOSE" as
    -- matching "SPELL_AURA_APPLIED" since they represent the same concept.
    local eventMatches = false
    local normalizedEvent = event
    if event == "SPELL_AURA_REFRESH" or event == "SPELL_AURA_APPLIED_DOSE" then
        normalizedEvent = "SPELL_AURA_APPLIED"
    end
    for _, ev in ipairs(spellCfg.events or {}) do
        if ev == normalizedEvent or ev == event then
            eventMatches = true
            break
        end
    end
    if not eventMatches then return end

    -- Internal per-spell cooldown check
    local now = GetTime()
    local spellCD = spellCfg.cd or 0
    if spellCD > 0 then
        local lastTime = self.burstSpellCooldowns[spellID] or 0
        if (now - lastTime) < spellCD then
            self:DebugLog(3, "Burst spell %d on internal cooldown (%.1fs remaining)",
                spellID, spellCD - (now - lastTime))
            return
        end
    end

    self.burstSpellCooldowns[spellID] = now

    self:DebugSpell(spellID, event, spellCfg.weight or 50, spellCfg.priority or 99)
    self:OnBurstSpellDetected(spellID, event, spellCfg)
end

-- --- Burst Trigger ------------------------------------------------------------

function PA:OnBurstSpellDetected(spellID, event, spellCfg)
    local spellName = ns.GetSpellName(spellID)
    self:DebugLog(1, "Burst detected: [%d] %s (event=%s, weight=%d)",
        spellID, spellName, event, spellCfg.weight or 0)

    self:RecordBurstDetected()
    self.burstWindowActive = true
    self.lastBurstSpellID  = spellID
    self.lastBurstTime     = GetTime()

    self:FireWeakAuraEvent("PI_BURST", spellID, spellName)

    if self.db.profile.alert.visual then
        self:ShowAlert(string.format("|cffffcc00%s|r\n%s", L["ALERT_BURST_TITLE"], spellName))
    end
    if self.db.profile.alert.sound then
        self:PlayAlertSound()
    end

    -- Attempt auto-send. If blocked, always print the reason so the user knows detection worked.
    local canSend, reason = self:CanSendMessage()
    if canSend then
        self:SendPIRequest(false)
    else
        self:Print(string.format("|cffffcc00PI Assistant:|r Burst detected! Auto-send blocked: %s",
            reason or L["ALERT_NO_PRIEST"]))
    end

    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshMainWindow()
    end
end

-- --- Burst Window State -------------------------------------------------------

function PA:IsBurstWindowActive()
    return self.burstWindowActive == true
end

function PA:ResetBurstState()
    self.burstWindowActive = false
    self.currentBurstWeight = 0
end

-- --- Test Burst ---------------------------------------------------------------

-- Simulates a burst detection for testing purposes. No real message is sent.
function PA:TestBurst()
    self:DebugLog(1, "Test burst triggered by user")

    -- Use first enabled spell or fallback
    local testSpellID   = 191427
    local testSpellName = "Metamorphosis [TEST]"

    for _, spell in ipairs(self.db.profile.burst.spells) do
        if spell.enabled and spell.id then
            testSpellID   = spell.id
            testSpellName = ns.GetSpellName(spell.id) .. " [TEST]"
            break
        end
    end

    self:RecordBurstDetected()
    self.lastBurstSpellID = testSpellID
    self.lastBurstTime    = GetTime()

    local priest     = self:GetSelectedPriest()
    local priestName = priest and priest.name or L["NONE"]
    local channel    = self.db.profile.message.channel
    local template   = self.db.profile.message.template
    local formatted  = self:FormatMessage(template, { priest = priestName })

    self:FireWeakAuraEvent("PI_TEST", testSpellID, testSpellName)

    if self.db.profile.alert.visual then
        self:ShowAlert(string.format("[TEST]\n%s\n→ %s\n%s: %s",
            testSpellName, priestName, channel, formatted))
    end

    self:Print(string.format("[PI TEST] Spell: %s | Priest: %s | Channel: %s | Msg: %s",
        testSpellName, priestName, channel, formatted))

    self:DebugLog(1, "[TEST] spell=%s priest=%s channel=%s msg=%s",
        testSpellName, priestName, channel, formatted)
end

-- --- Spell List Management ----------------------------------------------------

-- Adds a new spell to the burst list. Returns false + reason if invalid.
function PA:AddBurstSpell(spellID)
    spellID = tonumber(spellID)
    if not spellID or spellID <= 0 then
        return false, L["BURST_INVALID_ID"]
    end

    -- Check duplicate
    for _, spell in ipairs(self.db.profile.burst.spells) do
        if spell.id == spellID then
            return false, "Spell already in list"
        end
    end

    local name = ns.GetSpellName(spellID)
    local spellEntry = {
        id       = spellID,
        name     = name,
        enabled  = true,
        weight   = 50,
        priority = #self.db.profile.burst.spells + 1,
        cd       = 0,
        events   = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" },
    }

    self.db.profile.burst.spells[#self.db.profile.burst.spells + 1] = spellEntry
    self.burstSpellMap[spellID] = spellEntry

    self:DebugLog(2, "Added burst spell: [%d] %s", spellID, name)
    return true
end

-- Removes a spell from the burst list by spell ID.
function PA:RemoveBurstSpell(spellID)
    spellID = tonumber(spellID)
    local spells = self.db.profile.burst.spells
    for i, spell in ipairs(spells) do
        if spell.id == spellID then
            table.remove(spells, i)
            self.burstSpellMap[spellID] = nil
            self:DebugLog(2, "Removed burst spell: [%d]", spellID)
            return true
        end
    end
    return false
end

-- Exports current spell list as a comma-separated string of IDs.
function PA:ExportBurstSpells()
    local ids = {}
    for _, spell in ipairs(self.db.profile.burst.spells) do
        ids[#ids + 1] = tostring(spell.id)
    end
    return table.concat(ids, ",")
end

-- Imports a comma-separated list of spell IDs. Returns added count.
function PA:ImportBurstSpells(data)
    if not data or data == "" then return 0 end
    local count = 0
    for idStr in data:gmatch("(%d+)") do
        local ok = self:AddBurstSpell(tonumber(idStr))
        if ok then count = count + 1 end
    end
    return count
end
