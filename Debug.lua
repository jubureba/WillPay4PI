local addonName, ns = ...
local PA = ns.PA
local L  = ns.L

local MAX_LOG_ENTRIES = 500

-- ─── Initialization ───────────────────────────────────────────────────────────

function PA:InitializeDebug()
    self.debugLog     = {}
    self.debugFrame   = nil
    self.debugVisible = false
end

-- ─── Logging ─────────────────────────────────────────────────────────────────

-- Levels: 1=Info, 2=Verbose, 3=Trace
function PA:DebugLog(level, msg, ...)
    if not self.db.profile.debug.enabled then return end
    if level > (self.db.profile.debug.logLevel or 2) then return end

    local formatted = select("#", ...) > 0 and string.format(msg, ...) or msg
    local entry = {
        time    = date("%H:%M:%S"),
        level   = level,
        type    = "LOG",
        message = formatted,
    }
    self:AppendDebugEntry(entry)
end

function PA:DebugEvent(event, spellID, spellName, isPlayer)
    if not self.db.profile.debug.enabled then return end
    if not self.db.profile.debug.filters.events then return end
    if self.db.profile.debug.logLevel < 3 then return end
    if not isPlayer then return end

    local entry = {
        time    = date("%H:%M:%S"),
        level   = 3,
        type    = "EVENT",
        message = string.format("[EVT] %s spellID=%s name=%s", event, tostring(spellID), tostring(spellName)),
    }
    self:AppendDebugEntry(entry)
end

function PA:DebugSpell(spellID, event, weight, priority)
    if not self.db.profile.debug.enabled then return end
    if not self.db.profile.debug.filters.spells then return end

    local entry = {
        time    = date("%H:%M:%S"),
        level   = 2,
        type    = "SPELL",
        message = string.format("[SPELL] id=%d event=%s weight=%d prio=%d", spellID, event, weight, priority),
    }
    self:AppendDebugEntry(entry)
end

function PA:DebugPriest(msg)
    if not self.db.profile.debug.enabled then return end
    if not self.db.profile.debug.filters.priests then return end

    local entry = {
        time    = date("%H:%M:%S"),
        level   = 2,
        type    = "PRIEST",
        message = "[PRIEST] " .. tostring(msg),
    }
    self:AppendDebugEntry(entry)
end

function PA:DebugMessage(msg, channel)
    if not self.db.profile.debug.enabled then return end
    if not self.db.profile.debug.filters.messages then return end

    local entry = {
        time    = date("%H:%M:%S"),
        level   = 1,
        type    = "MSG",
        message = string.format("[MSG] channel=%s msg=%s", tostring(channel), tostring(msg)),
    }
    self:AppendDebugEntry(entry)
end

function PA:DebugCooldown(cdType, timeLeft)
    if not self.db.profile.debug.enabled then return end
    if not self.db.profile.debug.filters.cooldowns then return end

    local entry = {
        time    = date("%H:%M:%S"),
        level   = 2,
        type    = "CD",
        message = string.format("[CD] %s %.1fs remaining", tostring(cdType), timeLeft or 0),
    }
    self:AppendDebugEntry(entry)
end

function PA:DebugError(msg, ...)
    -- Always log errors regardless of enabled flag
    local formatted = select("#", ...) > 0 and string.format(msg, ...) or msg
    local entry = {
        time    = date("%H:%M:%S"),
        level   = 1,
        type    = "ERROR",
        message = "|cffff4444[ERROR]|r " .. formatted,
    }
    self:AppendDebugEntry(entry)
end

function PA:AppendDebugEntry(entry)
    self.debugLog[#self.debugLog + 1] = entry
    while #self.debugLog > MAX_LOG_ENTRIES do
        table.remove(self.debugLog, 1)
    end
    if self.debugFrame and self.debugFrame:IsShown() then
        self:AppendToDebugWindow(entry)
    end
end

-- ─── Debug Window ─────────────────────────────────────────────────────────────

function PA:ToggleDebugWindow()
    if self.debugFrame and self.debugFrame:IsShown() then
        self.debugFrame:Hide()
        self.debugVisible = false
    else
        self:ShowDebugWindow()
    end
end

function PA:ShowDebugWindow()
    if not self.debugFrame then
        self:CreateDebugWindow()
    end
    self.debugFrame:Show()
    self.debugVisible = true
    self:PopulateDebugWindow()
end

function PA:CreateDebugWindow()
    local frame = CreateFrame("Frame", "PIAssistantDebugFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(700, 450)
    frame:SetPoint("CENTER", UIParent, "CENTER", 200, -100)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop",  frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()

    frame.TitleText:SetText(L["DEBUG_TITLE"])

    -- Enable toggle checkbox
    local enableCB = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    enableCB:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -30, -28)
    enableCB:SetSize(24, 24)
    enableCB.text:SetText("Enable Debug")
    enableCB:SetChecked(self.db.profile.debug.enabled)
    enableCB:SetScript("OnClick", function(self_cb)
        PA.db.profile.debug.enabled = self_cb:GetChecked()
    end)
    frame.enableCB = enableCB

    -- Log level slider
    local slider = CreateFrame("Slider", "PIAssistantDebugSlider", frame, "OptionsSliderTemplate")
    slider:SetPoint("TOPRIGHT", enableCB, "TOPLEFT", -80, 5)
    slider:SetMinMaxValues(1, 3)
    slider:SetValueStep(1)
    slider:SetWidth(100)
    slider:SetValue(self.db.profile.debug.logLevel or 2)
    SliderLow:SetText("1")
    SliderHigh:SetText("3")
    _G[slider:GetName() .. "Text"]:SetText("Log Level: " .. (self.db.profile.debug.logLevel or 2))
    slider:SetScript("OnValueChanged", function(self_s, value)
        PA.db.profile.debug.logLevel = math.floor(value)
        _G[self_s:GetName() .. "Text"]:SetText("Log Level: " .. math.floor(value))
    end)
    frame.logSlider = slider

    -- Clear button
    local clearBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    clearBtn:SetSize(80, 24)
    clearBtn:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 10)
    clearBtn:SetText(L["DEBUG_CLEAR"])
    clearBtn:SetScript("OnClick", function()
        PA:ClearDebugLog()
    end)

    -- Scroll frame for log output
    local scrollFrame = CreateFrame("ScrollFrame", "PIAssistantDebugScroll", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT",    frame, "TOPLEFT",    10, -55)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 40)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(scrollFrame:GetWidth(), 1)
    scrollFrame:SetScrollChild(content)

    local logText = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    logText:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -4)
    logText:SetWidth(scrollFrame:GetWidth() - 8)
    logText:SetJustifyH("LEFT")
    logText:SetJustifyV("TOP")
    logText:SetText("")
    content.logText = logText

    frame.scrollFrame = scrollFrame
    frame.content     = content
    frame.logText     = logText

    self.debugFrame = frame
end

function PA:PopulateDebugWindow()
    if not self.debugFrame then return end

    local lines = {}
    for _, entry in ipairs(self.debugLog) do
        lines[#lines + 1] = self:FormatDebugEntry(entry)
    end
    self.debugFrame.logText:SetText(table.concat(lines, "\n"))
    self.debugFrame.content:SetHeight(math.max(1, self.debugFrame.logText:GetHeight() + 8))
    self.debugFrame.scrollFrame:SetVerticalScroll(
        self.debugFrame.scrollFrame:GetVerticalScrollRange()
    )
end

function PA:AppendToDebugWindow(entry)
    if not self.debugFrame or not self.debugFrame:IsShown() then return end
    local current = self.debugFrame.logText:GetText() or ""
    local new     = self:FormatDebugEntry(entry)
    if current == "" then
        self.debugFrame.logText:SetText(new)
    else
        self.debugFrame.logText:SetText(current .. "\n" .. new)
    end
    self.debugFrame.content:SetHeight(math.max(1, self.debugFrame.logText:GetHeight() + 8))
    self.debugFrame.scrollFrame:SetVerticalScroll(
        self.debugFrame.scrollFrame:GetVerticalScrollRange()
    )
end

function PA:FormatDebugEntry(entry)
    local typeColor = {
        LOG    = "|cffaaaaaa",
        EVENT  = "|cff88aaff",
        SPELL  = "|cffffaa00",
        PRIEST = "|cff88ff88",
        MSG    = "|cff00ffff",
        CD     = "|cffff88ff",
        ERROR  = "|cffff4444",
    }
    local col = typeColor[entry.type] or "|cffaaaaaa"
    return string.format("|cff666666[%s]|r %s%s|r", entry.time, col, entry.message)
end

function PA:ClearDebugLog()
    self.debugLog = {}
    if self.debugFrame and self.debugFrame:IsShown() then
        self.debugFrame.logText:SetText("")
        self.debugFrame.content:SetHeight(1)
    end
end
