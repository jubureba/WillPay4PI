local addonName, ns = ...
local PA = ns.PA
local L  = ns.L

-- ─── Registration ─────────────────────────────────────────────────────────────

function PA:RegisterOptions()
    local AceConfig       = LibStub("AceConfig-3.0")
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local AceDBOptions    = LibStub("AceDBOptions-3.0")

    AceConfig:RegisterOptionsTable(addonName, self:GetOptionsTable())
    self.optionsFrame = AceConfigDialog:AddToBlizOptions(addonName, "Will Pay 4 PI")

    -- Profiles sub-panel
    local profilesTable = AceDBOptions:GetOptionsTable(self.db)
    AceConfig:RegisterOptionsTable(addonName .. "_Profiles", profilesTable)
    AceConfigDialog:AddToBlizOptions(addonName .. "_Profiles", L["PROFILE_TITLE"], "Will Pay 4 PI")
end

function PA:RefreshOptions()
    LibStub("AceConfigRegistry-3.0"):NotifyChange(addonName)
end

-- ─── Options Table ────────────────────────────────────────────────────────────

function PA:GetOptionsTable()
    return {
        name    = "Will Pay 4 PI",
        handler = PA,
        type    = "group",
        args    = {

            -- ── General ──────────────────────────────────────────────────────
            general = {
                name  = "General",
                type  = "group",
                order = 10,
                inline = false,
                args  = {
                    enabled = {
                        name    = L["ENABLED"],
                        desc    = "Enable or disable the entire addon.",
                        type    = "toggle",
                        order   = 1,
                        get     = function() return PA.db.profile.enabled end,
                        set     = function(_, v)
                            PA.db.profile.enabled = v
                            if v then PA:Enable() else PA:Disable() end
                        end,
                    },
                    minimapIcon = {
                        name    = "Show Minimap Icon",
                        desc    = "Show the PI Assistant icon on the minimap.",
                        type    = "toggle",
                        order   = 2,
                        get     = function() return not PA.db.profile.minimapIcon.hide end,
                        set     = function(_, v)
                            PA.db.profile.minimapIcon.hide = not v
                            local LDBIcon = LibStub("LibDBIcon-1.0", true)
                            if LDBIcon then
                                if v then LDBIcon:Show(addonName)
                                else LDBIcon:Hide(addonName) end
                            end
                        end,
                    },
                    openUI = {
                        name  = "Open Main Window",
                        desc  = "Open the PI Assistant main window.",
                        type  = "execute",
                        order = 3,
                        func  = function() PA:ToggleMainWindow() end,
                    },
                },
            },

            -- ── Burst Detection ───────────────────────────────────────────────
            burst = {
                name  = "Burst Detection",
                type  = "group",
                order = 20,
                args  = {
                    burstEnabled = {
                        name  = "Enable Burst Detection",
                        desc  = "Automatically detect burst windows from spell events.",
                        type  = "toggle",
                        order = 1,
                        get   = function() return PA.db.profile.burst.enabled end,
                        set   = function(_, v) PA.db.profile.burst.enabled = v end,
                    },
                    loadDefaults = {
                        name  = "Load Spec Defaults",
                        desc  = "Reset burst spells to the default profile for your current specialization.",
                        type  = "execute",
                        order = 2,
                        func  = function()
                            PA.db.profile.burst.spells = {}
                            PA:LoadSpecProfile()
                            PA:RefreshOptions()
                        end,
                    },
                    testBurst = {
                        name  = L["BURST_TEST"],
                        desc  = "Simulate a burst detection without sending any real message.",
                        type  = "execute",
                        order = 3,
                        func  = function() PA:TestBurst() end,
                    },
                    spellHeader = {
                        name  = "Burst Spells",
                        type  = "header",
                        order = 10,
                    },
                    addSpellID = {
                        name  = "Add Spell ID",
                        desc  = "Enter a spell ID to add to the burst detection list.",
                        type  = "input",
                        order = 11,
                        get   = function() return PA._optionNewSpellID or "" end,
                        set   = function(_, v) PA._optionNewSpellID = v end,
                    },
                    addSpellBtn = {
                        name  = "Add Spell",
                        type  = "execute",
                        order = 12,
                        func  = function()
                            local ok, err = PA:AddBurstSpell(PA._optionNewSpellID)
                            if ok then
                                PA._optionNewSpellID = ""
                                PA:RefreshOptions()
                            else
                                PA:Print("|cffff4444Error:|r " .. (err or "Failed"))
                            end
                        end,
                    },
                    exportSpells = {
                        name  = "Export Spell List",
                        desc  = "Copy this comma-separated list of spell IDs.",
                        type  = "input",
                        order = 13,
                        multiline = false,
                        width = "full",
                        get   = function() return PA:ExportBurstSpells() end,
                        set   = function() end,
                    },
                    importSpells = {
                        name  = "Import Spell List",
                        desc  = "Paste a comma-separated list of spell IDs to import.",
                        type  = "input",
                        order = 14,
                        width = "full",
                        get   = function() return PA._optionImportSpells or "" end,
                        set   = function(_, v)
                            PA._optionImportSpells = v
                            local n = PA:ImportBurstSpells(v)
                            if n > 0 then
                                PA:Print(string.format("Imported %d spells.", n))
                                PA._optionImportSpells = ""
                                PA:RefreshOptions()
                            end
                        end,
                    },
                },
            },

            -- ── Messages ──────────────────────────────────────────────────────
            messages = {
                name  = L["TAB_MESSAGES"],
                type  = "group",
                order = 30,
                args  = {
                    template = {
                        name  = L["MSG_TEMPLATE"],
                        desc  = "Message template. Variables: {player} {spec} {class} {priest} {instance} {group} {time}",
                        type  = "input",
                        order = 1,
                        width = "full",
                        get   = function() return PA.db.profile.message.template end,
                        set   = function(_, v) PA.db.profile.message.template = v end,
                    },
                    channel = {
                        name   = L["MSG_CHANNEL"],
                        desc   = "Channel to send the PI request through.",
                        type   = "select",
                        order  = 2,
                        values = {
                            WHISPER        = L["MSG_CHANNEL_WHISPER"],
                            PARTY          = L["MSG_CHANNEL_PARTY"],
                            RAID           = L["MSG_CHANNEL_RAID"],
                            INSTANCE       = L["MSG_CHANNEL_INSTANCE"],
                            SAY            = L["MSG_CHANNEL_SAY"],
                            YELL           = L["MSG_CHANNEL_YELL"],
                            ADDON          = L["MSG_CHANNEL_ADDON"],
                        },
                        get    = function() return PA.db.profile.message.channel end,
                        set    = function(_, v) PA.db.profile.message.channel = v end,
                    },
                    cooldown = {
                        name  = L["MSG_COOLDOWN"],
                        desc  = "Minimum seconds between automatic PI requests.",
                        type  = "select",
                        order = 3,
                        values = {
                            [15]  = "15s",  [30]  = "30s",  [45]  = "45s",
                            [60]  = "60s",  [90]  = "90s",  [120] = "120s",
                            [180] = "180s", [300] = "300s",
                        },
                        get   = function() return PA.db.profile.message.cooldown end,
                        set   = function(_, v) PA.db.profile.message.cooldown = v end,
                    },
                    previewHeader = {
                        name  = "Preview",
                        type  = "header",
                        order = 10,
                    },
                    preview = {
                        name  = "Formatted Message",
                        desc  = "Preview of the formatted message with current variables.",
                        type  = "input",
                        order = 11,
                        width = "full",
                        get   = function()
                            return PA:FormatMessage(PA.db.profile.message.template)
                        end,
                        set   = function() end,
                    },
                    resetCooldown = {
                        name  = "Reset Cooldown",
                        desc  = "Manually reset the message cooldown timer.",
                        type  = "execute",
                        order = 20,
                        func  = function() PA:ResetMessageCooldown() end,
                    },
                },
            },

            -- ── Alerts ────────────────────────────────────────────────────────
            alerts = {
                name  = "Alerts",
                type  = "group",
                order = 40,
                args  = {
                    desc = {
                        name  = "Configure visual and audio alerts for burst detection and PI received events.",
                        type  = "description",
                        order = 0,
                    },
                    visualHeader = {
                        name  = "Visual Alerts",
                        type  = "header",
                        order = 1,
                    },
                    visual = {
                        name = "Enable Visual Alert",
                        desc = "Show an on-screen overlay when a burst is detected or PI is received.",
                        type = "toggle",
                        order = 2,
                        width = "full",
                        get  = function() return PA.db.profile.alert.visual end,
                        set  = function(_, v) PA.db.profile.alert.visual = v end,
                    },
                    scale = {
                        name  = "Alert Scale",
                        desc  = "Size of the visual alert overlay.",
                        type  = "range",
                        order = 3,
                        min   = 0.5, max = 3.0, step = 0.1,
                        get   = function() return PA.db.profile.alert.scale end,
                        set   = function(_, v) PA.db.profile.alert.scale = v end,
                    },
                    duration = {
                        name  = "Display Duration (seconds)",
                        desc  = "How long the visual alert stays on screen before fading out.",
                        type  = "range",
                        order = 4,
                        min   = 0.5, max = 10.0, step = 0.5,
                        get   = function() return PA.db.profile.alert.duration end,
                        set   = function(_, v) PA.db.profile.alert.duration = v end,
                    },
                    posHeader = {
                        name  = "Position",
                        type  = "header",
                        order = 10,
                    },
                    posX = {
                        name  = "Horizontal Offset",
                        desc  = "Horizontal offset of the alert from screen center. Negative = left, positive = right.",
                        type  = "range",
                        order = 11,
                        min   = -800, max = 800, step = 5,
                        get   = function() return PA.db.profile.alert.posX end,
                        set   = function(_, v) PA.db.profile.alert.posX = v end,
                    },
                    posY = {
                        name  = "Vertical Offset",
                        desc  = "Vertical offset of the alert from screen center. Negative = down, positive = up.",
                        type  = "range",
                        order = 12,
                        min   = -400, max = 400, step = 5,
                        get   = function() return PA.db.profile.alert.posY end,
                        set   = function(_, v) PA.db.profile.alert.posY = v end,
                    },
                    soundHeader = {
                        name  = "Sound",
                        type  = "header",
                        order = 20,
                    },
                    sound = {
                        name = "Enable Sound Alert",
                        desc = "Play a sound when a burst is detected or PI is received.",
                        type = "toggle",
                        order = 21,
                        width = "full",
                        get  = function() return PA.db.profile.alert.sound end,
                        set  = function(_, v) PA.db.profile.alert.sound = v end,
                    },
                    volume = {
                        name  = "Volume",
                        desc  = "Alert sound volume (0 = muted, 1 = full volume).",
                        type  = "range",
                        order = 22,
                        min   = 0, max = 1, step = 0.05,
                        isPercent = true,
                        get   = function() return PA.db.profile.alert.volume end,
                        set   = function(_, v) PA.db.profile.alert.volume = v end,
                    },
                    soundFile = {
                        name  = "Custom Sound File",
                        desc  = "Path to a custom .ogg sound file (relative to WoW folder). Leave empty to use the default Raid Warning sound.\n\nExample: Interface\\AddOns\\PIAssistant\\Media\\Sounds\\ping.ogg",
                        type  = "input",
                        order = 23,
                        width = "full",
                        get   = function() return PA.db.profile.alert.soundFile or "" end,
                        set   = function(_, v)
                            PA.db.profile.alert.soundFile = (v and v ~= "") and v or ""
                        end,
                    },
                    testHeader = {
                        name  = "Testing",
                        type  = "header",
                        order = 30,
                    },
                    testAlert = {
                        name  = "Test Visual Alert",
                        desc  = "Show a test alert to preview position, scale, and duration.",
                        type  = "execute",
                        order = 31,
                        func  = function()
                            PA:ShowAlert("Power Infusion Active!\n[TEST]")
                        end,
                    },
                    testSound = {
                        name  = "Test Sound",
                        desc  = "Play the configured alert sound.",
                        type  = "execute",
                        order = 32,
                        func  = function()
                            PA:PlayAlertSound()
                        end,
                    },
                },
            },

            -- ── Debug ─────────────────────────────────────────────────────────
            debug = {
                name  = "Debug",
                type  = "group",
                order = 90,
                args  = {
                    debugEnabled = {
                        name = "Enable Debug Logging",
                        type = "toggle",
                        order = 1,
                        get  = function() return PA.db.profile.debug.enabled end,
                        set  = function(_, v) PA.db.profile.debug.enabled = v end,
                    },
                    logLevel = {
                        name   = "Log Level",
                        desc   = "1=Info, 2=Verbose, 3=Trace",
                        type   = "range",
                        order  = 2,
                        min    = 1, max = 3, step = 1,
                        get    = function() return PA.db.profile.debug.logLevel end,
                        set    = function(_, v) PA.db.profile.debug.logLevel = v end,
                    },
                    openDebug = {
                        name  = "Open Debug Window",
                        type  = "execute",
                        order = 3,
                        func  = function() PA:ToggleDebugWindow() end,
                    },
                    clearLog = {
                        name  = "Clear Log",
                        type  = "execute",
                        order = 4,
                        func  = function() PA:ClearDebugLog() end,
                    },
                },
            },
        },
    }
end
