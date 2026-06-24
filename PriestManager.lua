local addonName, ns = ...
local PA = ns.PA
local L  = ns.L

-- --- Initialization -----------------------------------------------------------

function PA:InitializePriestManager()
    self.priests = {}  -- [key] = priestInfo table
    self:ScanGroupForPriests()
end

-- --- Group Scanning -----------------------------------------------------------

-- Full rescan of the current group for Priest class members.
function PA:ScanGroupForPriests()
    local found = {}

    local function processUnit(unit)
        if not UnitExists(unit) then return end
        local _, class = UnitClass(unit)
        if class ~= "PRIEST" then return end

        local name, realm = UnitName(unit)
        if not name then return end
        local realmOk, hasRealm = pcall(function() return realm and realm ~= "" end)
        realm = (realmOk and hasRealm) and realm or GetRealmName()
        local key = name .. "-" .. realm

        local specName = self:GetUnitSpecName(unit)

        found[key] = {
            key      = key,
            name     = name,
            realm    = realm,
            unit     = unit,
            spec     = specName,
            online   = UnitIsConnected(unit),
            alive    = not UnitIsDeadOrGhost(unit),
            inRange  = self:IsUnitInRange(unit),
            selected = (self.db.profile.priests.selected == key),
        }
    end

    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            processUnit("raid" .. i)
        end
    elseif IsInGroup() then
        processUnit("player")
        for i = 1, GetNumGroupMembers() - 1 do
            processUnit("party" .. i)
        end
    else
        processUnit("player")
    end

    -- Merge: preserve existing entries, add new, remove gone ones
    -- (keep entries for priests that just went offline so UI doesn't flash)
    for key, info in pairs(found) do
        if self.priests[key] then
            -- Update dynamic fields
            self.priests[key].unit    = info.unit
            self.priests[key].spec    = info.spec
            self.priests[key].online  = info.online
            self.priests[key].alive   = info.alive
            self.priests[key].inRange = info.inRange
        else
            self.priests[key] = info
        end
    end

    -- Remove priests no longer in group at all
    for key in pairs(self.priests) do
        if not found[key] then
            self.priests[key] = nil
        end
    end

    -- Validate selected priest still valid
    local sel = self.db.profile.priests.selected
    if sel and not self.priests[sel] then
        self.db.profile.priests.selected = nil
        self:SelectNextAvailablePriest()
    end

    -- Auto-select if none chosen
    if not self.db.profile.priests.selected then
        self:SelectNextAvailablePriest()
    end

    self:DebugPriest("ScanGroupForPriests: found " .. self:CountPriests() .. " priests")
end

-- --- Unit Helpers -------------------------------------------------------------

function PA:GetUnitSpecName(unit)
    -- GetInspectSpecialization requires a prior NotifyInspect(unit) call; returns 0 if unavailable.
    if GetInspectSpecialization then
        local specID = GetInspectSpecialization(unit)
        if specID and specID > 0 then
            local _, name = GetSpecializationInfoByID(specID)
            return name
        end
    end
    -- For the local player we can get spec directly
    if UnitIsUnit(unit, "player") then
        local idx = GetSpecialization and GetSpecialization() or nil
        if idx then
            local _, name = GetSpecializationInfo(idx)
            return name
        end
    end
    return nil
end

function PA:IsUnitInRange(unit)
    -- UnitInRange works for group members
    if UnitInRange then
        return UnitInRange(unit) == 1
    end
    -- Fallback: assume in range
    return true
end

-- --- Priest Accessors ---------------------------------------------------------

function PA:GetAllPriests()
    local list = {}
    for _, info in pairs(self.priests) do
        list[#list + 1] = info
    end
    -- Sort by priority list, then alphabetically
    local priority = self.db.profile.priests.priority or {}
    local posMap   = {}
    for i, key in ipairs(priority) do posMap[key] = i end

    table.sort(list, function(a, b)
        local pa = posMap[a.key] or 9999
        local pb = posMap[b.key] or 9999
        if pa ~= pb then return pa < pb end
        return a.name < b.name
    end)
    return list
end

function PA:GetAvailablePriests()
    local list = {}
    for _, info in pairs(self.priests) do
        if self:IsPriestAvailable(info) then
            list[#list + 1] = info
        end
    end
    return list
end

function PA:CountPriests()
    local n = 0
    for _ in pairs(self.priests) do n = n + 1 end
    return n
end

function PA:IsPriestAvailable(info)
    return info
        and info.online
        and info.alive
        and info.unit ~= nil
        and UnitExists(info.unit)
        and UnitIsConnected(info.unit)
        and not UnitIsDeadOrGhost(info.unit)
end

-- --- Selection ----------------------------------------------------------------

function PA:GetSelectedPriest()
    local key = self.db.profile.priests.selected
    if key then
        return self.priests[key]
    end
    return nil
end

function PA:SetSelectedPriest(key)
    -- Deselect previous
    for _, info in pairs(self.priests) do
        info.selected = false
    end

    if key and self.priests[key] then
        self.db.profile.priests.selected = key
        self.priests[key].selected = true
        self:DebugPriest("Selected priest: " .. key)
    else
        self.db.profile.priests.selected = nil
    end

    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshPriestsTab()
        self:RefreshDashboard()
    end
end

-- Automatically selects the highest-priority available priest.
function PA:SelectNextAvailablePriest()
    local priority = self.db.profile.priests.priority or {}
    local posMap   = {}
    for i, key in ipairs(priority) do posMap[key] = i end

    local best, bestPos = nil, 9999
    for key, info in pairs(self.priests) do
        if self:IsPriestAvailable(info) then
            local pos = posMap[key] or 8888
            if pos < bestPos then
                bestPos = pos
                best    = key
            end
        end
    end

    if best then
        self:SetSelectedPriest(best)
    else
        self.db.profile.priests.selected = nil
        for _, info in pairs(self.priests) do
            info.selected = false
        end
        self:DebugPriest("No available priest found for auto-selection")
    end
end

-- --- Priority Management ------------------------------------------------------

-- Sets the priest priority order from a list of keys.
function PA:SetPriestPriority(orderedKeys)
    self.db.profile.priests.priority = {}
    for i, key in ipairs(orderedKeys) do
        self.db.profile.priests.priority[i] = key
    end
    self:DebugPriest("Priority updated: " .. table.concat(orderedKeys, ", "))
end

-- Moves a priest one step up (lower index) in priority.
function PA:MovePriestUp(key)
    local priority = self.db.profile.priests.priority
    for i, k in ipairs(priority) do
        if k == key and i > 1 then
            priority[i]   = priority[i - 1]
            priority[i-1] = key
            return
        end
    end
    -- If not in list yet, add it at top
    if not self:IsInPriority(key) then
        table.insert(priority, 1, key)
    end
end

-- Moves a priest one step down (higher index) in priority.
function PA:MovePriestDown(key)
    local priority = self.db.profile.priests.priority
    for i, k in ipairs(priority) do
        if k == key and i < #priority then
            priority[i]   = priority[i + 1]
            priority[i+1] = key
            return
        end
    end
    -- If not in list, add it at bottom
    if not self:IsInPriority(key) then
        priority[#priority + 1] = key
    end
end

function PA:IsInPriority(key)
    local priority = self.db.profile.priests.priority
    for _, k in ipairs(priority) do
        if k == key then return true end
    end
    return false
end

-- Ensures all current priests are represented in the priority list.
function PA:SyncPriorityList()
    local priority = self.db.profile.priests.priority
    for key in pairs(self.priests) do
        if not self:IsInPriority(key) then
            priority[#priority + 1] = key
        end
    end
    -- Remove stale keys
    for i = #priority, 1, -1 do
        if not self.priests[priority[i]] then
            table.remove(priority, i)
        end
    end
end

-- --- Status Update (called from Events.lua) -----------------------------------

function PA:UpdatePriestUnit(unit)
    local name, realm = UnitName(unit)
    if not name then return end
    local realmOk, hasRealm = pcall(function() return realm and realm ~= "" end)
    realm = (realmOk and hasRealm) and realm or GetRealmName()
    local key = name .. "-" .. realm

    local info = self.priests[key]
    if not info then return end

    info.online  = UnitIsConnected(unit)
    info.alive   = not UnitIsDeadOrGhost(unit)
    info.inRange = self:IsUnitInRange(unit)

    -- If this was the selected priest and became unavailable
    if info.selected and not self:IsPriestAvailable(info) then
        self:SelectNextAvailablePriest()
    end
end
