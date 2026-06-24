local addonName, ns = ...
local PA = ns.PA
local L  = ns.L

-- --- Initialization -----------------------------------------------------------

function PA:InitializeMessageManager()
    self.lastRequestTime = 0
    self.requestCount    = 0
end

-- --- Pre-flight Checks --------------------------------------------------------

-- Returns true + nil if the request can be sent, or false + reason string.
function PA:CanSendMessage()
    if not self.db.profile.enabled then
        return false, "Addon disabled"
    end

    local priest = self:GetSelectedPriest()
    if not priest then
        return false, L["ERR_NO_GROUP"]
    end

    if not self:IsPriestAvailable(priest) then
        if not priest.online then
            return false, L["ERR_PRIEST_OFFLINE"]
        end
        if not priest.alive then
            return false, L["ERR_PRIEST_DEAD"]
        end
        return false, L["ERR_PRIEST_NOT_IN_GROUP"]
    end

    local cooldown = self.db.profile.message.cooldown or 30
    local now      = GetTime()
    local elapsed  = now - (self.lastRequestTime or 0)
    if elapsed < cooldown then
        return false, string.format(L["ERR_ON_COOLDOWN"], cooldown - elapsed)
    end

    return true
end

-- --- Send PI Request ---------------------------------------------------------

-- Sends the PI request message. manual=true means user triggered it explicitly.
function PA:SendPIRequest(manual)
    local canSend, reason = self:CanSendMessage()
    if not canSend then
        if manual then
            self:Print("|cffff4444PI Assistant:|r " .. (reason or "Cannot send"))
        end
        self:DebugMessage("Blocked: " .. (reason or "unknown"), nil)
        self:FireWeakAuraEvent("PI_FAILED", reason)
        if manual then
            self:RecordPIFailed(reason)
        end
        return false
    end

    local priest   = self:GetSelectedPriest()
    local channel  = self.db.profile.message.channel
    local template = self.db.profile.message.template
    local message  = self:FormatMessage(template, { priest = priest.name })

    local sent, err = self:DeliverMessage(message, channel, priest)
    if sent then
        self.lastRequestTime = GetTime()
        self.requestCount    = (self.requestCount or 0) + 1

        self:RecordRequestSent(priest, channel, message)
        self:FireWeakAuraEvent("PI_REQUESTED", priest.name, message)
        self:DebugMessage(message, channel)

        self:Print(string.format(L["MSG_SENT"], priest.name))

        if self.db.profile.alert.visual then
            self:ShowAlert(string.format(L["ALERT_PI_REQUESTED"], priest.name))
        end
        if self.db.profile.alert.sound then
            self:PlayAlertSound()
        end

        if self.mainFrame and self.mainFrame:IsShown() then
            self:RefreshMainWindow()
        end

        return true
    else
        self:Print(string.format(L["MSG_FAILED"], err or "unknown error"))
        self:RecordPIFailed(err)
        self:FireWeakAuraEvent("PI_FAILED", err)
        return false
    end
end

-- --- Message Delivery ---------------------------------------------------------

function PA:DeliverMessage(message, channel, priest)
    if not message or message == "" then
        return false, "Empty message"
    end

    local ok, err = pcall(function()
        if channel == "WHISPER" then
            if not priest or not priest.name then
                error("No priest for whisper")
            end
            local target = priest.name
            if priest.realm and priest.realm ~= GetRealmName() then
                target = priest.name .. "-" .. priest.realm
            end
            SendChatMessage(message, "WHISPER", nil, target)

        elseif channel == "PARTY" then
            SendChatMessage(message, "PARTY")

        elseif channel == "RAID" then
            if IsInRaid() then
                SendChatMessage(message, "RAID")
            elseif IsInGroup() then
                SendChatMessage(message, "PARTY")
            end

        elseif channel == "INSTANCE_CHAT" or channel == "INSTANCE" then
            SendChatMessage(message, "INSTANCE_CHAT")

        elseif channel == "SAY" then
            SendChatMessage(message, "SAY")

        elseif channel == "YELL" then
            SendChatMessage(message, "YELL")

        elseif channel == "ADDON" then
            -- Addon channel for addon-to-addon communication
            C_ChatInfo.SendAddonMessage("PIAssistant", "PI_REQUEST:" .. message, "RAID")
            if IsInGroup() and not IsInRaid() then
                C_ChatInfo.SendAddonMessage("PIAssistant", "PI_REQUEST:" .. message, "PARTY")
            end

        else
            error("Unknown channel: " .. tostring(channel))
        end
    end)

    if ok then
        return true
    else
        return false, tostring(err)
    end
end

-- --- Message Formatting -------------------------------------------------------

-- Available variables: {player} {spec} {class} {priest} {instance} {group} {time}
function PA:FormatMessage(template, extra)
    if not template then return "" end

    extra = extra or {}

    local class = self:GetPlayerClassSpec()
    local spec       = self.playerSpec or class or "Unknown"   -- use resolved locale-independent key
    local playerName = UnitName("player") or "Player"
    local priestName  = extra.priest or (self:GetSelectedPriest() and self:GetSelectedPriest().name) or "Priest"

    local instanceName
    if IsInInstance then
        local name = GetInstanceInfo()
        instanceName = name or ""
    else
        instanceName = GetZoneText() or ""
    end

    local groupType = "Solo"
    if IsInRaid()  then groupType = "Raid"
    elseif IsInGroup() then groupType = "Party"
    end

    local timeStr = date("%H:%M")

    local result = template
    result = result:gsub("{player}",   playerName)
    result = result:gsub("{spec}",     spec or class or "Unknown")
    result = result:gsub("{class}",    class or "Unknown")
    result = result:gsub("{priest}",   priestName)
    result = result:gsub("{instance}", instanceName)
    result = result:gsub("{group}",    groupType)
    result = result:gsub("{time}",     timeStr)

    return result
end

-- --- Cooldown Info ------------------------------------------------------------

function PA:GetCooldownRemaining()
    local cooldown = self.db.profile.message.cooldown or 90
    local elapsed  = GetTime() - (self.lastRequestTime or 0)
    return math.max(0, cooldown - elapsed)
end

function PA:GetLastRequestTime()
    return self.lastRequestTime
end

function PA:ResetMessageCooldown()
    self.lastRequestTime = 0
    self:DebugLog(2, "Message cooldown reset")
end

-- --- Alert Sound -------------------------------------------------------------

-- Built-in sound presets (using WoW SOUNDKIT IDs that always work)
ns.ALERT_SOUNDS = {
    { id = "RAID_WARNING",    name = "Raid Warning",       soundkit = "RAID_WARNING" },
    { id = "READY_CHECK",     name = "Ready Check",        soundkit = "READY_CHECK" },
    { id = "PVP_FLAG",        name = "PvP Flag Captured",  soundkit = "PVP_THROUGH_QUEUE" },
    { id = "ALARM1",          name = "Alarm Clock 1",      soundkit = "ALARM_CLOCK_WARNING_1" },
    { id = "ALARM2",          name = "Alarm Clock 2",      soundkit = "ALARM_CLOCK_WARNING_2" },
    { id = "ALARM3",          name = "Alarm Clock 3",      soundkit = "ALARM_CLOCK_WARNING_3" },
    { id = "LEVELUP",         name = "Level Up",           soundkit = "LEVEL_UP" },
    { id = "LOOT_EPIC",       name = "Epic Loot",          soundkit = "UI_EPICLOOT_TOAST" },
    { id = "LOOT_RARE",       name = "Rare Loot",          soundkit = "UI_RARELOOT_TOAST" },
    { id = "QUEST_COMPLETE",  name = "Quest Complete",     soundkit = "QUEST_COMPLETED" },
    { id = "PET_BATTLE_WIN",  name = "Victory Fanfare",    soundkit = "UI_PET_BATTLES_TRAP_READY" },
}

function PA:PlayAlertSound()
    local cfg = self.db.profile.alert
    if not cfg.sound then return end

    local channel = cfg.audioChannel or "Master"
    local file = cfg.soundFile

    -- Custom .ogg file path
    if file and file ~= "" and file:find("\\") then
        local ok = pcall(PlaySoundFile, file, channel)
        if not ok then
            PlaySound(SOUNDKIT.RAID_WARNING, channel)
        end
        return
    end

    -- Built-in preset by ID
    if file and file ~= "" then
        for _, preset in ipairs(ns.ALERT_SOUNDS) do
            if preset.id == file then
                local sk = SOUNDKIT[preset.soundkit]
                if sk then
                    PlaySound(sk, channel)
                    return
                end
            end
        end
    end

    -- Default fallback
    PlaySound(SOUNDKIT.RAID_WARNING, channel)
end
