local addonName, ns = ...
local PA = ns.PA
local L  = ns.L

-- ─── Profile Helpers ─────────────────────────────────────────────────────────
-- AceDB-3.0 handles most profile logic; these methods provide the UI bridge
-- and export/import functionality on top of it.

function PA:InitializeProfiles()
    -- Nothing to initialize; AceDB manages state
end

function PA:GetCurrentProfileName()
    return self.db:GetCurrentProfile()
end

function PA:GetProfileList()
    return self.db:GetProfiles()
end

function PA:SwitchProfile(profileName)
    if not profileName or profileName == "" then return end
    self.db:SetProfile(profileName)
end

function PA:CopyProfile(sourceProfile, destProfile)
    if not sourceProfile or not destProfile then return end
    self.db:CopyProfile(sourceProfile, destProfile)
end

function PA:DeleteProfile(profileName)
    if not profileName or profileName == self:GetCurrentProfileName() then return end
    self.db:DeleteProfile(profileName)
end

function PA:ResetCurrentProfile()
    self.db:ResetProfile()
end

function PA:DuplicateProfile(sourceName)
    if not sourceName then return end
    local newName = sourceName .. " (copy)"
    -- Ensure unique name
    local profiles = self:GetProfileList()
    local usedNames = {}
    for _, n in ipairs(profiles) do usedNames[n] = true end
    local i = 1
    while usedNames[newName] do
        newName = sourceName .. " (copy " .. i .. ")"
        i = i + 1
    end
    self.db:SetProfile(newName)
    self.db:CopyProfile(sourceName, newName)
    return newName
end

-- ─── Export / Import ─────────────────────────────────────────────────────────

-- Serializes the current profile data to a base64-encoded string.
-- Uses AceSerializer if available, otherwise a simple table-to-string approach.
function PA:ExportProfile()
    local AceSerializer = LibStub and LibStub("AceSerializer-3.0", true)
    if AceSerializer then
        local ok, data = AceSerializer:Serialize(self.db.profile)
        if ok then
            return self:Base64Encode(data)
        end
    end
    -- Fallback: export as printable Lua table (no AceSerializer)
    return self:TableToString(self.db.profile)
end

-- Attempts to import a profile from an exported string.
-- Returns true on success, false + error on failure.
function PA:ImportProfile(data)
    if not data or data == "" then
        return false, "Empty data"
    end

    local AceSerializer = LibStub and LibStub("AceSerializer-3.0", true)
    if AceSerializer then
        local decoded = self:Base64Decode(data)
        if decoded then
            local ok, profile = AceSerializer:Deserialize(decoded)
            if ok and type(profile) == "table" then
                for k, v in pairs(profile) do
                    self.db.profile[k] = v
                end
                self:OnProfileChanged()
                return true
            end
        end
    end

    return false, "AceSerializer-3.0 required for import/export"
end

-- ─── Simple Base64 ───────────────────────────────────────────────────────────
-- Minimal implementation for profile export portability.

local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

function PA:Base64Encode(data)
    local result = {}
    local pad    = 0
    for i = 1, #data, 3 do
        local b1 = string.byte(data, i)     or 0
        local b2 = string.byte(data, i + 1) or 0
        local b3 = string.byte(data, i + 2) or 0
        if i + 1 > #data then pad = 2
        elseif i + 2 > #data then pad = 1 end
        local n = bit.bor(bit.lshift(b1, 16), bit.lshift(b2, 8), b3)
        result[#result+1] = b64chars:sub(bit.rshift(n, 18) % 64 + 1, bit.rshift(n, 18) % 64 + 1)
        result[#result+1] = b64chars:sub(bit.rshift(n, 12) % 64 + 1, bit.rshift(n, 12) % 64 + 1)
        result[#result+1] = pad >= 2 and "=" or b64chars:sub(bit.rshift(n, 6) % 64 + 1, bit.rshift(n, 6) % 64 + 1)
        result[#result+1] = pad >= 1 and "=" or b64chars:sub(n % 64 + 1, n % 64 + 1)
    end
    return table.concat(result)
end

function PA:Base64Decode(data)
    local b64map = {}
    for i = 1, #b64chars do b64map[b64chars:sub(i, i)] = i - 1 end
    data = data:gsub("[^A-Za-z0-9+/=]", "")
    local result = {}
    for i = 1, #data, 4 do
        local c1 = b64map[data:sub(i,   i)]   or 0
        local c2 = b64map[data:sub(i+1, i+1)] or 0
        local c3 = b64map[data:sub(i+2, i+2)] or 0
        local c4 = b64map[data:sub(i+3, i+3)] or 0
        local n  = bit.bor(bit.lshift(c1, 18), bit.lshift(c2, 12), bit.lshift(c3, 6), c4)
        result[#result+1] = string.char(bit.rshift(n, 16) % 256)
        if data:sub(i+2, i+2) ~= "=" then
            result[#result+1] = string.char(bit.rshift(n, 8) % 256)
        end
        if data:sub(i+3, i+3) ~= "=" then
            result[#result+1] = string.char(n % 256)
        end
    end
    return table.concat(result)
end

-- Minimal table serializer for human-readable export (no deserialization support)
function PA:TableToString(t, indent)
    indent = indent or 0
    local pad = string.rep("  ", indent)
    local lines = { "{" }
    for k, v in pairs(t) do
        local keyStr = type(k) == "string" and ("[\"" .. k .. "\"]") or ("[" .. tostring(k) .. "]")
        local valStr
        if type(v) == "table" then
            valStr = self:TableToString(v, indent + 1)
        elseif type(v) == "string" then
            valStr = "\"" .. v:gsub("\\", "\\\\"):gsub("\"", "\\\"") .. "\""
        else
            valStr = tostring(v)
        end
        lines[#lines+1] = pad .. "  " .. keyStr .. " = " .. valStr .. ","
    end
    lines[#lines+1] = pad .. "}"
    return table.concat(lines, "\n")
end
