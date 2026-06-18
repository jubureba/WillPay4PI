local addonName, ns = ...

-- Bootstrap: create main addon object with Ace3 mixins
local PA = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0")
ns.PA      = PA
_G["WillPay4PI"] = PA

local L = ns.L

PA.version = "1.1.0"

-- ─── Default Database ─────────────────────────────────────────────────────────

PA.defaults = {
    profile = {
        enabled = true,

        minimapIcon = {
            hide     = false,
            minimapPos = 220,
        },

        ui = {
            scale  = 1.0,
            point  = "CENTER",
            x      = 0,
            y      = 0,
            width  = 680,
            height = 480,
        },

        alert = {
            visual   = true,
            sound    = true,
            volume   = 0.5,
            scale    = 1.0,
            posX     = 0,
            posY     = 200,
            duration = 2.5,
            soundFile = "",
        },

        burst = {
            enabled = true,
            spells  = {},  -- list of { id, name, enabled, weight, priority, cd, events={} }
        },

        message = {
            template = "PI please - {spec} bursting ({time})",
            channel  = "WHISPER",
            cooldown = 90,
        },

        priests = {
            priority = {},   -- ordered list of "Name-Realm" keys
            selected = nil,  -- "Name-Realm" of manually selected priest
        },

        debug = {
            enabled  = false,
            logLevel = 2,
            filters  = { events = true, spells = true, priests = true,
                         messages = true, cooldowns = true, errors = true },
        },

        statistics = {
            burstsDetected = 0,
            requestsSent   = 0,
            piReceived     = 0,
            piFailed       = 0,
            priestCounts   = {},
            responseTimes  = {},
            history        = {},
        },
    }
}

-- ─── Lifecycle ────────────────────────────────────────────────────────────────

function PA:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("WillPay4PIDB", self.defaults, true)
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied",  "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset",   "OnProfileChanged")

    self:RegisterOptions()
    self:InitializeMinimapIcon()
    self:RegisterChatCommand("pi", "SlashCommand")
    self:RegisterChatCommand("wp4pi", "SlashCommand")

    self:InitializeStatistics()
    self:InitializeDebug()
end

function PA:OnEnable()
    -- Defer out of the ADDON_LOADED execution chain.
    -- Calling RegisterEvent() directly here triggers ADDON_ACTION_FORBIDDEN
    -- because AceEvent30Frame is created inside a Blizzard-protected context
    -- during the initial load sequence. C_Timer.After(0) breaks that chain.
    C_Timer.After(0, function()
        PA:RegisterEvents()
        PA:InitializeBurstDetector()
        PA:InitializePriestManager()
        PA:InitializeMessageManager()
        PA:Print("|cffaa55ffWill Pay 4 PI|r v" .. PA.version .. " loaded. |cffffffff/pi|r or |cffffffff/wp4pi|r to open.")
    end)
end

function PA:OnDisable()
    if self.rawEventFrame then
        self.rawEventFrame:UnregisterAllEvents()
    end
    self:UnregisterAllEvents()  -- AceEvent cleanup (safe to call even if unused)
    if self.mainFrame then
        self.mainFrame:Hide()
    end
end

function PA:OnProfileChanged()
    self:LoadSpecProfile()
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshMainWindow()
    end
    if self.optionsFrame then
        LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
    end
end

-- ─── Slash Command ────────────────────────────────────────────────────────────

function PA:SlashCommand(input)
    input = input and input:match("^%s*(.-)%s*$") or ""
    if input == "test" then
        self:TestBurst()
    elseif input == "debug" then
        self:ToggleDebugWindow()
    elseif input == "reset" then
        self:ResetUI()
    elseif input == "options" or input == "config" then
        LibStub("AceConfigDialog-3.0"):Open(addonName)
    elseif input == "snoop" then
        self:StartCLEUSnoop()
    elseif input == "status" then
        self:PrintStatus()
    else
        self:ToggleMainWindow()
    end
end

-- Print current addon state to chat for diagnostics.
function PA:PrintStatus()
    self:Print("|cffaa55ffWill Pay 4 PI — Status|r")
    self:Print("  Addon enabled: " .. (self:IsAddonEnabled() and "|cff00ff00yes|r" or "|cffff4444no|r"))
    self:Print("  Burst detection: " .. (self.db.profile.burst.enabled and "|cff00ff00yes|r" or "|cffff4444no|r"))

    local spells = self.db.profile.burst.spells or {}
    if #spells == 0 then
        self:Print("  Burst spells: |cffff4444none configured|r")
    else
        local ids = {}
        for _, s in ipairs(spells) do
            ids[#ids + 1] = string.format("%d%s", s.id, s.enabled and "" or "(off)")
        end
        self:Print("  Burst spells: " .. table.concat(ids, ", "))
    end

    local mapSize = 0
    if self.burstSpellMap then
        for _ in pairs(self.burstSpellMap) do mapSize = mapSize + 1 end
    end
    self:Print("  burstSpellMap entries: " .. mapSize)

    local priest = self:GetSelectedPriest()
    if priest then
        self:Print("  Selected priest: |cff00ff00" .. priest.name .. "|r")
    else
        self:Print("  Selected priest: |cffff4444none|r")
    end
    self:Print("  Available priests: " .. #self:GetAvailablePriests() ..
               " / " .. self:CountPriests())
    self:Print("  Use |cfffffff/pi snoop|r to watch spell events for 10 seconds.")
end

-- Snoop: prints spell/aura events for 10 seconds (delegates to Events.lua).
-- Kept here so /pi snoop continues to work via SlashCommand.
-- The actual implementation is PA:StartCLEUSnoop() in Events.lua.

-- ─── Enable / Disable Toggle ─────────────────────────────────────────────────

function PA:IsAddonEnabled()
    return self.db.profile.enabled
end

function PA:ToggleAddon()
    self.db.profile.enabled = not self.db.profile.enabled
    if self.db.profile.enabled then
        self:Enable()
    else
        self:Disable()
    end
    if self.mainFrame and self.mainFrame:IsShown() then
        self:RefreshMainWindow()
    end
end

-- ─── Minimap Icon ─────────────────────────────────────────────────────────────

function PA:InitializeMinimapIcon()
    local LDB     = LibStub("LibDataBroker-1.1")
    local LDBIcon = LibStub("LibDBIcon-1.0")

    self.dataObject = LDB:NewDataObject(addonName, {
        type = "launcher",
        text = "Will Pay 4 PI",
        icon = "Interface\\Icons\\Spell_Holy_PowerInfusion",

        OnClick = function(_, button)
            if button == "LeftButton" then
                PA:ToggleMainWindow()
            elseif button == "RightButton" then
                PA:ShowMinimapMenu()
            end
        end,

        OnTooltipShow = function(tooltip)
            tooltip:AddLine("|cffaa55ffWill Pay 4 PI|r")
            tooltip:AddLine(" ")
            tooltip:AddLine("|cffaaaaaa[Left Click]|r Open Window",    1, 1, 1)
            tooltip:AddLine("|cffaaaaaa[Right Click]|r Quick Menu",    1, 1, 1)
        end,
    })

    LDBIcon:Register(addonName, self.dataObject, self.db.profile.minimapIcon)
end

-- ─── Minimap Context Menu ─────────────────────────────────────────────────────

function PA:ShowMinimapMenu()
    -- EasyMenu / UIDropDownMenuTemplate were removed in TWW/Midnight.
    -- Use MenuUtil.CreateContextMenu (available since Dragonflight 10.2).
    if MenuUtil and MenuUtil.CreateContextMenu then
        MenuUtil.CreateContextMenu(nil, function(_, rootDescription)
            rootDescription:CreateTitle(L["PI_ASSISTANT"])
            rootDescription:CreateDivider()
            rootDescription:CreateButton(PA:IsAddonEnabled() and L["DISABLE"] or L["ENABLE"],
                function() PA:ToggleAddon() end)
            rootDescription:CreateButton(L["BURST_TEST"],
                function() PA:TestBurst() end)
            rootDescription:CreateButton(L["MENU_RESET_UI"],
                function() PA:ResetUI() end)
            rootDescription:CreateButton("Debug Window",
                function() PA:ToggleDebugWindow() end)
        end)
    elseif EasyMenu then
        -- Fallback: legacy clients that still have EasyMenu
        if not self.minimapMenu then
            self.minimapMenu = CreateFrame("Frame", "PIAssistantMinimapMenu", UIParent, "UIDropDownMenuTemplate")
        end
        local menu = {
            { text = L["PI_ASSISTANT"], isTitle = true, notCheckable = true },
            { text = PA:IsAddonEnabled() and L["DISABLE"] or L["ENABLE"],
              func = function() PA:ToggleAddon() end, notCheckable = true },
            { text = L["BURST_TEST"],   func = function() PA:TestBurst() end,        notCheckable = true },
            { text = L["MENU_RESET_UI"],func = function() PA:ResetUI() end,          notCheckable = true },
            { text = "Debug Window",    func = function() PA:ToggleDebugWindow() end, notCheckable = true },
            { text = CLOSE,             func = function() CloseDropDownMenus() end,  notCheckable = true },
        }
        EasyMenu(menu, self.minimapMenu, "cursor", 0, 0, "MENU")
    end
end

-- ─── WeakAuras Event Bridge ───────────────────────────────────────────────────

function PA:FireWeakAuraEvent(event, ...)
    if WeakAuras and WeakAuras.ScanEvents then
        WeakAuras.ScanEvents(event, ...)
    end
end

-- ─── Utility ─────────────────────────────────────────────────────────────────

-- Returns "Name-Realm" key for a unit, or just "Name" if same realm.
-- In Midnight 12.x, UnitName() can return "secret" values for certain units
-- (e.g. targettarget). We use pcall to safely handle these without taint.
function PA:GetUnitKey(unit)
    local ok, name, realm = pcall(UnitName, unit)
    if not ok or not name then return nil end
    -- realm may be secret; wrap the comparison in pcall
    local useRealm = false
    if realm then
        local ok2, result = pcall(function() return realm ~= "" end)
        useRealm = ok2 and result
    end
    if useRealm then
        return name .. "-" .. realm
    end
    return name
end

-- Returns current player class (English uppercase), specID (locale-independent),
-- and specNameLocalized (display only – changes per client language).
-- GetSpecialization/GetSpecializationInfo deprecated in 11.2 but available in 12.x.
function PA:GetPlayerClassSpec()
    local _, class = UnitClass("player")

    local specIndex = GetSpecialization and GetSpecialization() or nil
    local specID, specNameLocalized
    if specIndex then
        -- GetSpecializationInfo returns: id, name, desc, icon, role, ...
        specID, specNameLocalized = GetSpecializationInfo(specIndex)
    end

    -- specID is numeric and locale-independent; specNameLocalized varies by client language
    return class, specID, specNameLocalized
end

-- Returns current hero talent name (Midnight-era API).
-- C_ClassTalents.GetActiveHeroTalentSpec() returns a numeric SubTreeID.
-- We map it to a display name via a static lookup table.
local HERO_TALENT_NAMES = {
    -- Death Knight
    [31] = "San'layn", [32] = "Rider of the Apocalypse", [33] = "Deathbringer",
    -- Demon Hunter
    [34] = "Fel-Scarred", [35] = "Aldrachi Reaver", [124] = "Annihilator",
    -- Druid
    [21] = "Druid of the Claw", [22] = "Wildstalker", [23] = "Keeper of the Grove", [24] = "Elune's Chosen",
    -- Evoker
    [36] = "Scalecommander", [37] = "Flameshaper", [38] = "Chronowarden",
    -- Hunter
    [42] = "Sentinel", [43] = "Pack Leader", [44] = "Dark Ranger",
    -- Mage
    [39] = "Sunfury", [40] = "Spellslinger", [41] = "Frostfire",
    -- Monk
    [64] = "Conduit of the Celestials", [65] = "Shado-pan", [66] = "Master of Harmony",
    -- Paladin
    [48] = "Templar", [49] = "Lightsmith", [50] = "Herald of the Sun",
    -- Priest
    [18] = "Voidweaver", [19] = "Archon", [20] = "Oracle",
    -- Rogue
    [51] = "Trickster", [52] = "Fatebound", [53] = "Deathstalker",
    -- Shaman
    [54] = "Totemic", [55] = "Stormbringer", [56] = "Farseer",
    -- Warlock
    [57] = "Soul Harvester", [58] = "Hellcaller", [59] = "Diabolist",
    -- Warrior
    [60] = "Slayer", [61] = "Mountain Thane", [62] = "Colossus",
}

function PA:GetHeroTalentName()
    if C_ClassTalents and C_ClassTalents.GetActiveHeroTalentSpec then
        local heroSpecID = C_ClassTalents.GetActiveHeroTalentSpec()
        if heroSpecID then
            return HERO_TALENT_NAMES[heroSpecID] or ("Hero #" .. heroSpecID)
        end
    end
    return nil
end

-- Formats a duration in seconds as a human-readable string.
function PA:FormatDuration(seconds)
    if seconds < 60 then
        return string.format("%.0fs", seconds)
    elseif seconds < 3600 then
        return string.format("%.0fm", seconds / 60)
    else
        return string.format("%.1fh", seconds / 3600)
    end
end
