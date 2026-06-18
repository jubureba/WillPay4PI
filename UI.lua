local addonName, ns = ...
local PA = ns.PA
local L  = ns.L

-- ─── Theme Colors ─────────────────────────────────────────────────────────────

local THEME = {
    bg          = { 0.06, 0.06, 0.09, 0.97 },
    sidebar     = { 0.04, 0.04, 0.07, 1.0 },
    content     = { 0.08, 0.08, 0.11, 0.95 },
    accent      = { 0.67, 0.33, 1.0, 1.0 },       -- purple
    accentDim   = { 0.45, 0.22, 0.75, 0.8 },
    accentGlow  = { 0.67, 0.33, 1.0, 0.3 },
    text        = { 0.90, 0.90, 0.93, 1.0 },
    textDim     = { 0.55, 0.55, 0.60, 1.0 },
    textMuted   = { 0.38, 0.38, 0.42, 1.0 },
    success     = { 0.30, 0.90, 0.45, 1.0 },
    danger      = { 1.0,  0.35, 0.35, 1.0 },
    warning     = { 1.0,  0.78, 0.25, 1.0 },
    rowAlt      = { 0.10, 0.10, 0.14, 0.6 },
    rowHover    = { 0.14, 0.12, 0.22, 0.8 },
    cardBg      = { 0.10, 0.10, 0.14, 0.9 },
    cardBorder  = { 0.25, 0.18, 0.40, 0.6 },
    btnNormal   = { 0.14, 0.12, 0.20, 0.9 },
    btnHover    = { 0.22, 0.18, 0.35, 1.0 },
    btnAccent   = { 0.55, 0.28, 0.85, 1.0 },
}

-- ─── Tabs ─────────────────────────────────────────────────────────────────────

local TAB_DASHBOARD  = 1
local TAB_PRIESTS    = 2
local TAB_BURST      = 3
local TAB_MESSAGES   = 4
local TAB_STATISTICS = 5
local TAB_ALERTS     = 6

local TAB_ICONS = {
    -- FileDataID numeric textures (never break across patches)
    135939,   -- Spell_Holy_PowerInfusion (Dashboard)
    135936,   -- Spell_Holy_GuardianSpirit (Priests)
    132347,   -- Ability_Warrior_Rampage (Burst)
    133468,   -- INV_Letter_15 (Messages)
    134327,   -- INV_Misc_Note_01 (Stats)
    136116,   -- Spell_Nature_WispSplode (Alerts/Settings)
}

local TAB_LABELS = { "Dashboard", "Priests", "Burst", "Messages", "Stats", "Alerts" }


-- ─── Helpers ──────────────────────────────────────────────────────────────────

local function SetBGColor(tex, color)
    tex:SetColorTexture(color[1], color[2], color[3], color[4] or 1.0)
end

local function CreateBG(parent, color, layer)
    local tex = parent:CreateTexture(nil, layer or "BACKGROUND")
    tex:SetAllPoints()
    SetBGColor(tex, color)
    return tex
end

local function CreateCard(parent, x, y, w, h)
    local card = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    card:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    card:SetSize(w, h)
    card:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    card:SetBackdropColor(THEME.cardBg[1], THEME.cardBg[2], THEME.cardBg[3], THEME.cardBg[4])
    card:SetBackdropBorderColor(THEME.cardBorder[1], THEME.cardBorder[2], THEME.cardBorder[3], THEME.cardBorder[4])
    return card
end

local function CreateModernButton(parent, text, w, h, accent)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(w or 100, h or 28)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    local bgColor = accent and THEME.btnAccent or THEME.btnNormal
    btn:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    btn:SetBackdropBorderColor(THEME.cardBorder[1], THEME.cardBorder[2], THEME.cardBorder[3], THEME.cardBorder[4])

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER")
    label:SetText(text)
    label:SetTextColor(THEME.text[1], THEME.text[2], THEME.text[3])
    btn.label = label

    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(THEME.btnHover[1], THEME.btnHover[2], THEME.btnHover[3], THEME.btnHover[4])
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    end)

    return btn
end

local function MakeLabel(parent, text, font, color, anchor, relFrame, relPoint, ox, oy)
    local fs = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
    if anchor then
        fs:SetPoint(anchor, relFrame or parent, relPoint or anchor, ox or 0, oy or 0)
    end
    fs:SetText(text or "")
    if color then fs:SetTextColor(color[1], color[2], color[3], color[4] or 1.0) end
    return fs
end

-- Hide all objects in a list
local function HideList(list)
    if not list then return end
    for _, obj in ipairs(list) do
        if obj and obj.Hide then obj:Hide() end
    end
end

-- ─── Toggle / Reset ───────────────────────────────────────────────────────────

function PA:ToggleMainWindow()
    if self.mainFrame and self.mainFrame:IsShown() then
        self:SaveWindowPosition()
        self.mainFrame:Hide()
    else
        if not self.mainFrame then
            self:CreateMainWindow()
        end
        self:RestoreWindowPosition()
        self.mainFrame:Show()
        self:RefreshMainWindow()
    end
end

function PA:ResetUI()
    if self.mainFrame then
        self.mainFrame:Hide()
        self.mainFrame = nil
    end
    self.db.profile.ui.point  = "CENTER"
    self.db.profile.ui.x      = 0
    self.db.profile.ui.y      = 0
    self.db.profile.ui.width  = 680
    self.db.profile.ui.height = 480
    self.db.profile.ui.scale  = 1.0
    self:Print("UI reset to defaults.")
end

-- ─── Window Persistence ───────────────────────────────────────────────────────

function PA:SaveWindowPosition()
    if not self.mainFrame then return end
    local point, _, _, x, y = self.mainFrame:GetPoint()
    local ui = self.db.profile.ui
    ui.point  = point
    ui.x      = x
    ui.y      = y
    ui.width  = self.mainFrame:GetWidth()
    ui.height = self.mainFrame:GetHeight()
    ui.scale  = self.mainFrame:GetScale()
end

function PA:RestoreWindowPosition()
    if not self.mainFrame then return end
    local ui = self.db.profile.ui
    self.mainFrame:ClearAllPoints()
    self.mainFrame:SetPoint(ui.point or "CENTER", UIParent, ui.point or "CENTER", ui.x or 0, ui.y or 0)
    self.mainFrame:SetSize(ui.width or 680, ui.height or 480)
    self.mainFrame:SetScale(ui.scale or 1.0)
end

-- ─── Main Window ──────────────────────────────────────────────────────────────

function PA:CreateMainWindow()
    local frame = CreateFrame("Frame", "WillPay4PIMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(680, 480)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(580, 400, 1200, 800)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(f)
        f:StopMovingOrSizing()
        PA:SaveWindowPosition()
    end)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("HIGH")
    frame:SetScale(self.db.profile.ui.scale or 1.0)

    -- Dark backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(THEME.bg[1], THEME.bg[2], THEME.bg[3], THEME.bg[4])
    frame:SetBackdropBorderColor(THEME.cardBorder[1], THEME.cardBorder[2], THEME.cardBorder[3], 0.8)

    -- ESC to close
    tinsert(UISpecialFrames, "WillPay4PIMainFrame")

    -- ─── Title Bar ────────────────────────────────────────────────────────
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    titleBar:SetHeight(36)
    local titleBG = CreateBG(titleBar, THEME.sidebar)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 14, 0)
    titleText:SetText("|cffaa55ffWill Pay 4 PI|r")

    local versionText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    versionText:SetPoint("LEFT", titleText, "RIGHT", 8, 0)
    versionText:SetText("|cff666677v" .. self.version .. "|r")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(28, 28)
    closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -6, 0)
    local closeTex = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    closeTex:SetPoint("CENTER")
    closeTex:SetText("|cffaa5555X|r")
    closeBtn:SetScript("OnClick", function()
        PA:SaveWindowPosition()
        frame:Hide()
    end)
    closeBtn:SetScript("OnEnter", function() closeTex:SetText("|cffff6666X|r") end)
    closeBtn:SetScript("OnLeave", function() closeTex:SetText("|cffaa5555X|r") end)

    -- ─── Sidebar ──────────────────────────────────────────────────────────
    local SIDEBAR_W = 48
    local sidebar = CreateFrame("Frame", nil, frame)
    sidebar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -36)
    sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    sidebar:SetWidth(SIDEBAR_W)
    CreateBG(sidebar, THEME.sidebar)

    frame.navButtons = {}
    for i = 1, 6 do
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetSize(SIDEBAR_W, 44)
        btn:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 0, -(i - 1) * 46 - 8)

        -- Icon
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetSize(22, 22)
        icon:SetPoint("CENTER", btn, "CENTER", 0, 0)
        icon:SetTexture(TAB_ICONS[i])  -- numeric FileDataID
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- trim edges for clean look
        icon:SetDesaturated(true)
        icon:SetVertexColor(0.5, 0.5, 0.5)
        btn.icon = icon

        -- Active indicator (left bar)
        local indicator = btn:CreateTexture(nil, "OVERLAY")
        indicator:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, -8)
        indicator:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0, 8)
        indicator:SetWidth(3)
        SetBGColor(indicator, THEME.accent)
        indicator:Hide()
        btn.indicator = indicator

        -- Tooltip
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(TAB_LABELS[i], 1, 1, 1)
            GameTooltip:Show()
            if PA.activeTab ~= i then
                icon:SetVertexColor(0.8, 0.8, 0.8)
                icon:SetDesaturated(false)
            end
        end)
        btn:SetScript("OnLeave", function()
            GameTooltip:Hide()
            if PA.activeTab ~= i then
                icon:SetVertexColor(0.5, 0.5, 0.5)
                icon:SetDesaturated(true)
            end
        end)

        btn:SetScript("OnClick", function() PA:SelectTab(i) end)
        frame.navButtons[i] = btn
    end

    -- ─── Content Area ─────────────────────────────────────────────────────
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", frame, "TOPLEFT", SIDEBAR_W, -36)
    contentArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    CreateBG(contentArea, THEME.content)
    frame.contentArea = contentArea

    -- Tab panels
    frame.tabPanels = {}
    for i = 1, 6 do
        local panel = CreateFrame("Frame", nil, contentArea)
        panel:SetAllPoints(contentArea)
        panel:Hide()
        frame.tabPanels[i] = panel
    end

    -- Resize grip
    local grip = CreateFrame("Button", nil, frame)
    grip:SetSize(14, 14)
    grip:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
    local gripTex = grip:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    gripTex:SetPoint("CENTER")
    gripTex:SetText("|cff444455...|r")
    grip:SetScript("OnMouseDown", function() frame:StartSizing("BOTTOMRIGHT") end)
    grip:SetScript("OnMouseUp", function()
        frame:StopMovingOrSizing()
        PA:SaveWindowPosition()
    end)

    -- Resize handler
    frame:SetScript("OnSizeChanged", function()
        if PA._resizeTimer then PA._resizeTimer:Cancel() end
        PA._resizeTimer = C_Timer.NewTimer(0.15, function()
            PA._resizeTimer = nil
            if PA.mainFrame and PA.activeTab and PA.activeTab > 0 then
                PA:SelectTab(PA.activeTab)
            end
        end)
    end)

    self.mainFrame = frame
    self.activeTab = 0

    -- Build tabs
    self:BuildDashboardTab(frame.tabPanels[TAB_DASHBOARD])
    self:BuildPriestsTab(frame.tabPanels[TAB_PRIESTS])
    self:BuildBurstTab(frame.tabPanels[TAB_BURST])
    self:BuildMessagesTab(frame.tabPanels[TAB_MESSAGES])
    self:BuildStatisticsTab(frame.tabPanels[TAB_STATISTICS])
    self:BuildAlertsTab(frame.tabPanels[TAB_ALERTS])

    self:SelectTab(TAB_DASHBOARD)

    -- Live refresh ticker: update visible tab every 1 second for time-sensitive data
    local elapsed = 0
    frame:SetScript("OnUpdate", function(_, dt)
        elapsed = elapsed + dt
        if elapsed < 1.0 then return end
        elapsed = 0
        if not PA.mainFrame or not PA.mainFrame:IsShown() then return end
        if PA.activeTab == TAB_DASHBOARD  then PA:RefreshDashboard()  end
        if PA.activeTab == TAB_STATISTICS then PA:RefreshStatsTab()   end
    end)
end

function PA:SelectTab(index)
    if not self.mainFrame then return end
    self.activeTab = index

    for i, btn in ipairs(self.mainFrame.navButtons) do
        local active = (i == index)
        btn.indicator:SetShown(active)
        btn.icon:SetDesaturated(not active)
        btn.icon:SetVertexColor(active and 0.9 or 0.5, active and 0.7 or 0.5, active and 1.0 or 0.5)
    end

    for i, panel in ipairs(self.mainFrame.tabPanels) do
        if i == index then panel:Show() else panel:Hide() end
    end

    if index == TAB_DASHBOARD  then self:RefreshDashboard()   end
    if index == TAB_PRIESTS    then self:RefreshPriestsTab()  end
    if index == TAB_BURST      then self:RefreshBurstTab()    end
    if index == TAB_MESSAGES   then self:RefreshMessagesTab() end
    if index == TAB_STATISTICS then self:RefreshStatsTab()    end
    if index == TAB_ALERTS     then self:RefreshAlertsTab()   end
end

function PA:RefreshMainWindow()
    if not self.mainFrame then return end
    if self.activeTab == TAB_DASHBOARD  then self:RefreshDashboard()   end
    if self.activeTab == TAB_PRIESTS    then self:RefreshPriestsTab()  end
    if self.activeTab == TAB_BURST      then self:RefreshBurstTab()    end
    if self.activeTab == TAB_MESSAGES   then self:RefreshMessagesTab() end
    if self.activeTab == TAB_STATISTICS then self:RefreshStatsTab()    end
    if self.activeTab == TAB_ALERTS     then self:RefreshAlertsTab()   end
end


-- ─── Dashboard Tab ────────────────────────────────────────────────────────────

function PA:BuildDashboardTab(panel)
    panel.cards = {}
    panel.rows  = {}

    -- Header
    local header = MakeLabel(panel, "Dashboard", "GameFontNormalLarge", THEME.text,
        "TOPLEFT", panel, "TOPLEFT", 20, -16)

    -- Status pill
    local statusPill = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    statusPill:SetSize(80, 22)
    statusPill:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -20, -16)
    statusPill:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    local statusLabel = statusPill:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusLabel:SetPoint("CENTER")
    panel.statusPill  = statusPill
    panel.statusLabel = statusLabel

    -- Info cards row
    local cardY = -50
    local cardH = 60
    local cardGap = 10

    -- Card: Class/Spec
    local specCard = CreateCard(panel, 16, cardY, 200, cardH)
    local specTitle = MakeLabel(specCard, "SPEC", "GameFontNormalSmall", THEME.textMuted,
        "TOPLEFT", specCard, "TOPLEFT", 10, -8)
    local specValue = MakeLabel(specCard, "—", "GameFontNormalLarge", THEME.text,
        "TOPLEFT", specCard, "TOPLEFT", 10, -26)
    panel.rows.specValue = specValue

    -- Card: Selected Priest
    local priestCard = CreateCard(panel, 226, cardY, 200, cardH)
    local priestTitle = MakeLabel(priestCard, "TARGET PRIEST", "GameFontNormalSmall", THEME.textMuted,
        "TOPLEFT", priestCard, "TOPLEFT", 10, -8)
    local priestValue = MakeLabel(priestCard, "—", "GameFontNormalLarge", THEME.text,
        "TOPLEFT", priestCard, "TOPLEFT", 10, -26)
    panel.rows.priestValue = priestValue

    -- Card: Available
    local availCard = CreateCard(panel, 436, cardY, 160, cardH)
    local availTitle = MakeLabel(availCard, "PRIESTS AVAIL", "GameFontNormalSmall", THEME.textMuted,
        "TOPLEFT", availCard, "TOPLEFT", 10, -8)
    local availValue = MakeLabel(availCard, "—", "GameFontNormalLarge", THEME.text,
        "TOPLEFT", availCard, "TOPLEFT", 10, -26)
    panel.rows.availValue = availValue

    -- Second row of cards
    local cardY2 = cardY - cardH - cardGap

    -- Card: Last Burst
    local burstCard = CreateCard(panel, 16, cardY2, 200, cardH)
    MakeLabel(burstCard, "LAST BURST", "GameFontNormalSmall", THEME.textMuted,
        "TOPLEFT", burstCard, "TOPLEFT", 10, -8)
    local burstValue = MakeLabel(burstCard, "—", "GameFontNormal", THEME.warning,
        "TOPLEFT", burstCard, "TOPLEFT", 10, -26)
    panel.rows.burstValue = burstValue

    -- Card: Last PI
    local piCard = CreateCard(panel, 226, cardY2, 200, cardH)
    MakeLabel(piCard, "LAST PI RECEIVED", "GameFontNormalSmall", THEME.textMuted,
        "TOPLEFT", piCard, "TOPLEFT", 10, -8)
    local piValue = MakeLabel(piCard, "—", "GameFontNormal", THEME.success,
        "TOPLEFT", piCard, "TOPLEFT", 10, -26)
    panel.rows.piValue = piValue

    -- Card: Requests Sent
    local reqCard = CreateCard(panel, 436, cardY2, 160, cardH)
    MakeLabel(reqCard, "REQUESTS", "GameFontNormalSmall", THEME.textMuted,
        "TOPLEFT", reqCard, "TOPLEFT", 10, -8)
    local reqValue = MakeLabel(reqCard, "0", "GameFontNormalLarge", THEME.accent,
        "TOPLEFT", reqCard, "TOPLEFT", 10, -26)
    panel.rows.reqValue = reqValue

    -- Hero talent line
    local heroY = cardY2 - cardH - 16
    MakeLabel(panel, L["DASH_HERO_TALENT"] .. ":", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 20, heroY)
    local heroValue = MakeLabel(panel, "—", "GameFontNormalSmall", THEME.text,
        "TOPLEFT", panel, "TOPLEFT", 130, heroY)
    panel.rows.heroValue = heroValue

    -- Third row: PI status + cooldown
    local row3Y = heroY - 24

    -- PI Active indicator
    MakeLabel(panel, "PI Status:", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 20, row3Y)
    local piStatusValue = MakeLabel(panel, "Inactive", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 130, row3Y)
    panel.rows.piStatusValue = piStatusValue

    -- Cooldown remaining
    MakeLabel(panel, L["MSG_COOLDOWN"] .. ":", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 280, row3Y)
    local cdValue = MakeLabel(panel, "Ready", "GameFontNormalSmall", THEME.success,
        "TOPLEFT", panel, "TOPLEFT", 350, row3Y)
    panel.rows.cdValue = cdValue

    -- Session line
    local sessY = row3Y - 20
    MakeLabel(panel, "Session:", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 20, sessY)
    local sessValue = MakeLabel(panel, "0 bursts / 0 requests / 0 PI", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 130, sessY)
    panel.rows.sessValue = sessValue

    -- Action buttons at bottom
    local btnY = 14

    local testBtn = CreateModernButton(panel, L["BURST_TEST"], 130, 30)
    testBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, btnY)
    testBtn:SetScript("OnClick", function() PA:TestBurst() end)

    local sendBtn = CreateModernButton(panel, "Request PI", 130, 30, true)
    sendBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 156, btnY)
    sendBtn:SetScript("OnClick", function() PA:SendPIRequest(true) end)
    panel.sendBtn = sendBtn

    local toggleBtn = CreateModernButton(panel, L["DISABLE"], 100, 30)
    toggleBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, btnY)
    toggleBtn:SetScript("OnClick", function()
        PA:ToggleAddon()
        PA:RefreshDashboard()
    end)
    panel.toggleBtn = toggleBtn
end

function PA:RefreshDashboard()
    local panel = self.mainFrame and self.mainFrame.tabPanels[TAB_DASHBOARD]
    if not panel or not panel:IsShown() then return end

    local rows = panel.rows
    local class, _, specNameLocalized = self:GetPlayerClassSpec()
    local hero = self:GetHeroTalentName()
    local priest = self:GetSelectedPriest()
    local avail = #self:GetAvailablePriests()
    local total = self:CountPriests()

    -- Spec
    local specDisplay = self.playerSpec or specNameLocalized or "Unknown"
    if rows.specValue then
        rows.specValue:SetText((class or "?") .. " / " .. specDisplay)
    end

    -- Priest
    if rows.priestValue then
        if priest then
            rows.priestValue:SetText(priest.name or "?")
            rows.priestValue:SetTextColor(THEME.success[1], THEME.success[2], THEME.success[3])
        else
            rows.priestValue:SetText("None")
            rows.priestValue:SetTextColor(THEME.danger[1], THEME.danger[2], THEME.danger[3])
        end
    end

    -- Available
    if rows.availValue then
        rows.availValue:SetText(tostring(avail) .. " / " .. tostring(total))
        if avail > 0 then
            rows.availValue:SetTextColor(THEME.success[1], THEME.success[2], THEME.success[3])
        else
            rows.availValue:SetTextColor(THEME.danger[1], THEME.danger[2], THEME.danger[3])
        end
    end

    -- Last Burst
    if rows.burstValue then
        if self.lastBurstTime and self.lastBurstTime > 0 then
            local ago = GetTime() - self.lastBurstTime
            local name = self.lastBurstSpellID and ns.GetSpellName(self.lastBurstSpellID) or "?"
            rows.burstValue:SetText(name .. " (" .. self:FormatDuration(ago) .. " " .. L["DASH_AGO"] .. ")")
            rows.burstValue:SetTextColor(THEME.warning[1], THEME.warning[2], THEME.warning[3])
        else
            rows.burstValue:SetText(L["DASH_NONE_YET"])
            rows.burstValue:SetTextColor(THEME.textDim[1], THEME.textDim[2], THEME.textDim[3])
        end
    end

    -- Last PI
    if rows.piValue then
        if self.lastPIReceivedTime and self.lastPIReceivedTime > 0 then
            local ago = GetTime() - self.lastPIReceivedTime
            local src = self.lastPIReceivedSource or "?"
            rows.piValue:SetText(src .. " (" .. self:FormatDuration(ago) .. " " .. L["DASH_AGO"] .. ")")
            rows.piValue:SetTextColor(THEME.success[1], THEME.success[2], THEME.success[3])
        else
            rows.piValue:SetText(L["DASH_WAITING"])
            rows.piValue:SetTextColor(THEME.textDim[1], THEME.textDim[2], THEME.textDim[3])
        end
    end

    -- Requests
    if rows.reqValue then
        local stats = self.db.profile.statistics
        rows.reqValue:SetText(tostring(stats.requestsSent or 0))
    end

    -- Hero
    if rows.heroValue then
        rows.heroValue:SetText(hero or "None")
    end

    -- Status pill
    if panel.statusPill then
        local enabled = self:IsAddonEnabled()
        if enabled then
            panel.statusPill:SetBackdropColor(0.1, 0.25, 0.1, 0.9)
            panel.statusPill:SetBackdropBorderColor(0.2, 0.6, 0.3, 0.8)
            panel.statusLabel:SetText("|cff55ff77ON|r")
        else
            panel.statusPill:SetBackdropColor(0.25, 0.1, 0.1, 0.9)
            panel.statusPill:SetBackdropBorderColor(0.6, 0.2, 0.2, 0.8)
            panel.statusLabel:SetText("|cffff5555OFF|r")
        end
    end

    -- Toggle btn text
    if panel.toggleBtn then
        panel.toggleBtn.label:SetText(self:IsAddonEnabled() and L["DISABLE"] or L["ENABLE"])
    end

    -- PI Active status
    if rows.piStatusValue then
        if self.piActive then
            rows.piStatusValue:SetText("|cff55ff77ACTIVE|r")
            rows.piStatusValue:SetTextColor(THEME.success[1], THEME.success[2], THEME.success[3])
        else
            rows.piStatusValue:SetText("Inactive")
            rows.piStatusValue:SetTextColor(THEME.textDim[1], THEME.textDim[2], THEME.textDim[3])
        end
    end

    -- Cooldown remaining
    if rows.cdValue then
        local cdRemain = self:GetCooldownRemaining()
        if cdRemain > 0 then
            rows.cdValue:SetText(string.format(L["DASH_CD_REMAINING"], self:FormatDuration(cdRemain)))
            rows.cdValue:SetTextColor(THEME.warning[1], THEME.warning[2], THEME.warning[3])
        else
            rows.cdValue:SetText("Ready")
            rows.cdValue:SetTextColor(THEME.success[1], THEME.success[2], THEME.success[3])
        end
    end

    -- Session stats
    if rows.sessValue then
        rows.sessValue:SetText(string.format("%d bursts / %d requests / %d PI",
            self.sessionBursts or 0, self.sessionRequests or 0, self.sessionReceived or 0))
    end
end


-- ─── Priests Tab ──────────────────────────────────────────────────────────────

function PA:BuildPriestsTab(panel)
    MakeLabel(panel, "Priests", "GameFontNormalLarge", THEME.text,
        "TOPLEFT", panel, "TOPLEFT", 20, -16)

    local scanBtn = CreateModernButton(panel, "Scan Group", 100, 26)
    scanBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -14)
    scanBtn:SetScript("OnClick", function()
        PA:ScanGroupForPriests()
        PA:RefreshPriestsTab()
    end)

    -- Column headers
    local headerY = -50
    local headers = { "#", "Name", "Spec", "Status", "" }
    local headerX = { 16, 40, 180, 270, 370 }
    for i, h in ipairs(headers) do
        MakeLabel(panel, h, "GameFontNormalSmall", THEME.textMuted,
            "TOPLEFT", panel, "TOPLEFT", headerX[i], headerY)
    end

    -- Scroll area
    local sf = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, headerY - 18)
    sf:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -24, 16)

    local content = CreateFrame("Frame", nil, sf)
    content:SetWidth(sf:GetWidth())
    content:SetHeight(1)
    sf:SetScrollChild(content)

    panel.scrollFrame = sf
    panel.content     = content
    panel.priestRows  = {}
end

function PA:RefreshPriestsTab()
    local panel = self.mainFrame and self.mainFrame.tabPanels[TAB_PRIESTS]
    if not panel or not panel:IsShown() then return end

    -- Clear
    for _, row in ipairs(panel.priestRows) do
        for _, w in ipairs(row) do w:Hide() end
    end
    panel.priestRows = {}

    local sfW = panel.scrollFrame:GetWidth()
    if panel.content and sfW > 10 then panel.content:SetWidth(sfW) end

    local priests = self:GetAllPriests()
    self:SyncPriorityList()

    if #priests == 0 then
        if not panel.emptyLabel then
            panel.emptyLabel = MakeLabel(panel.content, "No priests found in your group.",
                "GameFontNormal", THEME.textDim, "TOPLEFT", panel.content, "TOPLEFT", 16, -20)
        end
        panel.emptyLabel:Show()
        panel.content:SetHeight(50)
        return
    end
    if panel.emptyLabel then panel.emptyLabel:Hide() end

    local priority = self.db.profile.priests.priority or {}
    local posMap = {}
    for i, k in ipairs(priority) do posMap[k] = i end

    local rowH = 36
    for idx, info in ipairs(priests) do
        local widgets = {}
        local y = -(idx - 1) * rowH

        -- Row background
        local bg = panel.content:CreateTexture(nil, "BACKGROUND")
        bg:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 4, y)
        bg:SetPoint("TOPRIGHT", panel.content, "TOPRIGHT", -4, y)
        bg:SetHeight(rowH - 2)
        if info.selected then
            bg:SetColorTexture(0.12, 0.22, 0.15, 0.7)
        elseif idx % 2 == 0 then
            bg:SetColorTexture(THEME.rowAlt[1], THEME.rowAlt[2], THEME.rowAlt[3], THEME.rowAlt[4])
        else
            bg:SetColorTexture(0, 0, 0, 0)
        end
        widgets[#widgets + 1] = bg

        -- Priority number
        local numFS = panel.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        numFS:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y - 10)
        numFS:SetText(tostring(posMap[info.key] or idx))
        numFS:SetTextColor(THEME.textMuted[1], THEME.textMuted[2], THEME.textMuted[3])
        widgets[#widgets + 1] = numFS

        -- Name
        local nameFS = panel.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameFS:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 40, y - 10)
        nameFS:SetText(info.name or "?")
        if info.selected then
            nameFS:SetTextColor(THEME.success[1], THEME.success[2], THEME.success[3])
        elseif not info.online then
            nameFS:SetTextColor(THEME.textMuted[1], THEME.textMuted[2], THEME.textMuted[3])
        else
            nameFS:SetTextColor(THEME.text[1], THEME.text[2], THEME.text[3])
        end
        widgets[#widgets + 1] = nameFS

        -- Spec
        local specFS = panel.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        specFS:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 180, y - 10)
        specFS:SetText(info.spec or "?")
        specFS:SetTextColor(THEME.textDim[1], THEME.textDim[2], THEME.textDim[3])
        widgets[#widgets + 1] = specFS

        -- Status indicators
        local statusFS = panel.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        statusFS:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 270, y - 10)
        local statusParts = {}
        statusParts[#statusParts + 1] = info.online and "|cff55ff77Online|r" or "|cffff5555Offline|r"
        if info.online then
            statusParts[#statusParts + 1] = info.alive and "|cff55ff77Alive|r" or "|cffff5555Dead|r"
        end
        statusFS:SetText(table.concat(statusParts, " "))
        widgets[#widgets + 1] = statusFS

        -- Action buttons
        local captureKey = info.key
        local btnX = 370

        local upBtn = CreateModernButton(panel.content, "Up", 24, 22)
        upBtn:SetPoint("TOPLEFT", panel.content, "TOPLEFT", btnX, y - 7)
        upBtn:SetScript("OnClick", function()
            PA:MovePriestUp(captureKey)
            PA:RefreshPriestsTab()
        end)
        widgets[#widgets + 1] = upBtn

        local dnBtn = CreateModernButton(panel.content, "Dn", 24, 22)
        dnBtn:SetPoint("TOPLEFT", panel.content, "TOPLEFT", btnX + 28, y - 7)
        dnBtn:SetScript("OnClick", function()
            PA:MovePriestDown(captureKey)
            PA:RefreshPriestsTab()
        end)
        widgets[#widgets + 1] = dnBtn

        local selBtn = CreateModernButton(panel.content,
            info.selected and "|cff55ff77OK|r" or "Select", info.selected and 30 or 60, 22,
            info.selected)
        selBtn:SetPoint("TOPLEFT", panel.content, "TOPLEFT", btnX + 58, y - 7)
        selBtn:SetScript("OnClick", function()
            if info.selected then
                PA:SetSelectedPriest(nil)
            else
                PA:SetSelectedPriest(captureKey)
            end
            PA:RefreshPriestsTab()
            PA:RefreshDashboard()
        end)
        widgets[#widgets + 1] = selBtn

        panel.priestRows[#panel.priestRows + 1] = widgets
    end

    panel.content:SetHeight(math.max(1, #priests * rowH + 8))
end


-- ─── Burst Tab ────────────────────────────────────────────────────────────────

function PA:BuildBurstTab(panel)
    MakeLabel(panel, "Burst Spells", "GameFontNormalLarge", THEME.text,
        "TOPLEFT", panel, "TOPLEFT", 20, -16)

    -- Add spell row
    local addBox = CreateFrame("EditBox", "WP4PIAddSpellBox", panel, "InputBoxTemplate")
    addBox:SetSize(90, 22)
    addBox:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -46)
    addBox:SetAutoFocus(false)
    addBox:SetMaxLetters(10)
    addBox:SetNumeric(true)
    addBox:SetText("")
    panel.addBox = addBox

    local addBtn = CreateModernButton(panel, "Add", 50, 24, true)
    addBtn:SetPoint("LEFT", addBox, "RIGHT", 6, 0)
    addBtn:SetScript("OnClick", function()
        local id = tonumber(addBox:GetText())
        if id then
            local ok, err = PA:AddBurstSpell(id)
            if ok then addBox:SetText(""); PA:RefreshBurstTab()
            else PA:Print("|cffff4444" .. (err or "Error") .. "|r") end
        end
    end)

    local loadBtn = CreateModernButton(panel, "Load Defaults", 100, 24)
    loadBtn:SetPoint("LEFT", addBtn, "RIGHT", 8, 0)
    loadBtn:SetScript("OnClick", function()
        PA.db.profile.burst.spells = {}
        PA:LoadSpecProfile()
        PA:RefreshBurstTab()
    end)

    local testBtn = CreateModernButton(panel, "Test", 70, 24)
    testBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -44)
    testBtn:SetScript("OnClick", function() PA:TestBurst() end)

    -- Column headers
    local headerY = -78
    local cols = { "ID", "Spell Name", "On", "Events", "Wt", "" }
    local colX = { 16, 70, 220, 254, 420, 460 }
    for i, h in ipairs(cols) do
        MakeLabel(panel, h, "GameFontNormalSmall", THEME.textMuted,
            "TOPLEFT", panel, "TOPLEFT", colX[i], headerY)
    end

    -- Scroll
    local sf = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, headerY - 16)
    sf:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -24, 40)

    local content = CreateFrame("Frame", nil, sf)
    content:SetWidth(sf:GetWidth())
    content:SetHeight(1)
    sf:SetScrollChild(content)
    panel.scrollFrame = sf
    panel.content     = content
    panel.spellRows   = {}

    -- Export bar at bottom
    local exportBox = CreateFrame("EditBox", "WP4PIExportBox", panel, "InputBoxTemplate")
    exportBox:SetSize(300, 20)
    exportBox:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 60, 12)
    exportBox:SetAutoFocus(false)
    exportBox:SetText("")
    panel.exportBox = exportBox

    MakeLabel(panel, "IDs:", "GameFontNormalSmall", THEME.textMuted,
        "BOTTOMLEFT", panel, "BOTTOMLEFT", 20, 14)
end

function PA:RefreshBurstTab()
    local panel = self.mainFrame and self.mainFrame.tabPanels[TAB_BURST]
    if not panel or not panel:IsShown() then return end

    for _, row in ipairs(panel.spellRows or {}) do
        for _, w in ipairs(row) do w:Hide() end
    end
    panel.spellRows = {}

    local sfW = panel.scrollFrame:GetWidth()
    if panel.content and sfW > 10 then panel.content:SetWidth(sfW) end

    if panel.exportBox then
        panel.exportBox:SetText(PA:ExportBurstSpells())
    end

    local spells = self.db.profile.burst.spells
    if not spells or #spells == 0 then
        if not panel.emptyLabel then
            panel.emptyLabel = MakeLabel(panel.content, "No burst spells configured. Add spell IDs or load defaults.",
                "GameFontNormal", THEME.textDim, "TOPLEFT", panel.content, "TOPLEFT", 16, -20)
        end
        panel.emptyLabel:Show()
        panel.content:SetHeight(50)
        return
    end
    if panel.emptyLabel then panel.emptyLabel:Hide() end

    local rowH = 30
    for idx, spell in ipairs(spells) do
        local widgets = {}
        local y = -(idx - 1) * rowH

        -- Row bg
        local bg = panel.content:CreateTexture(nil, "BACKGROUND")
        bg:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 4, y)
        bg:SetPoint("TOPRIGHT", panel.content, "TOPRIGHT", -4, y)
        bg:SetHeight(rowH - 2)
        if idx % 2 == 0 then
            bg:SetColorTexture(THEME.rowAlt[1], THEME.rowAlt[2], THEME.rowAlt[3], THEME.rowAlt[4])
        else
            bg:SetColorTexture(0, 0, 0, 0)
        end
        widgets[#widgets + 1] = bg

        -- ID
        local idFS = panel.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        idFS:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 16, y - 8)
        idFS:SetText(tostring(spell.id))
        idFS:SetTextColor(THEME.textDim[1], THEME.textDim[2], THEME.textDim[3])
        widgets[#widgets + 1] = idFS

        -- Name
        local nameFS = panel.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        nameFS:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 70, y - 8)
        nameFS:SetText(ns.GetSpellName(spell.id))
        if spell.enabled then
            nameFS:SetTextColor(THEME.text[1], THEME.text[2], THEME.text[3])
        else
            nameFS:SetTextColor(THEME.textMuted[1], THEME.textMuted[2], THEME.textMuted[3])
        end
        widgets[#widgets + 1] = nameFS

        -- Enabled checkbox
        local cb = CreateFrame("CheckButton", nil, panel.content, "UICheckButtonTemplate")
        cb:SetSize(20, 20)
        cb:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 218, y - 5)
        cb:SetChecked(spell.enabled ~= false)
        local captureIdx = idx
        cb:SetScript("OnClick", function(self_cb)
            PA.db.profile.burst.spells[captureIdx].enabled = self_cb:GetChecked()
            PA:LoadSpecProfile()
            PA:RefreshBurstTab()
        end)
        widgets[#widgets + 1] = cb

        -- Events (abbreviated)
        local evtText = ""
        if spell.events then
            local abbrev = {}
            for _, ev in ipairs(spell.events) do
                abbrev[#abbrev + 1] = ev:gsub("SPELL_", ""):gsub("_", " ")
            end
            evtText = table.concat(abbrev, ", ")
        end
        local evtFS = panel.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        evtFS:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 254, y - 8)
        evtFS:SetWidth(160)
        evtFS:SetText(evtText)
        evtFS:SetTextColor(THEME.textDim[1], THEME.textDim[2], THEME.textDim[3])
        widgets[#widgets + 1] = evtFS

        -- Weight
        local wtFS = panel.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        wtFS:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 420, y - 8)
        wtFS:SetText(tostring(spell.weight or 50))
        wtFS:SetTextColor(THEME.accent[1], THEME.accent[2], THEME.accent[3])
        widgets[#widgets + 1] = wtFS

        -- Remove button
        local rmBtn = CreateModernButton(panel.content, "X", 26, 22)
        rmBtn:SetPoint("TOPLEFT", panel.content, "TOPLEFT", 460, y - 4)
        local captureID = spell.id
        rmBtn:SetScript("OnClick", function()
            PA:RemoveBurstSpell(captureID)
            PA:RefreshBurstTab()
        end)
        widgets[#widgets + 1] = rmBtn

        panel.spellRows[#panel.spellRows + 1] = widgets
    end

    panel.content:SetHeight(math.max(1, #spells * rowH + 8))
end


-- ─── Messages Tab ─────────────────────────────────────────────────────────────

function PA:BuildMessagesTab(panel)
    MakeLabel(panel, "Messages", "GameFontNormalLarge", THEME.text,
        "TOPLEFT", panel, "TOPLEFT", 20, -16)

    local yOff = -50

    -- Template
    MakeLabel(panel, "Template:", "GameFontNormal", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff)

    local tplBox = CreateFrame("EditBox", "WP4PIMsgTemplate", panel, "InputBoxTemplate")
    tplBox:SetSize(380, 24)
    tplBox:SetPoint("TOPLEFT", panel, "TOPLEFT", 110, yOff)
    tplBox:SetAutoFocus(false)
    tplBox:SetMaxLetters(256)
    tplBox:SetText(self.db.profile.message.template or "")
    tplBox:SetScript("OnEnterPressed", function(self_box) self_box:ClearFocus() end)
    tplBox:SetScript("OnTextChanged", function(self_box)
        PA.db.profile.message.template = self_box:GetText()
        PA:RefreshMessagesTab()
    end)
    panel.tplBox = tplBox

    yOff = yOff - 36

    -- Channel selection
    MakeLabel(panel, "Channel:", "GameFontNormal", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff)

    local channels = { "WHISPER", "PARTY", "RAID", "INSTANCE", "SAY", "YELL" }
    local chanLabels = { "Whisper", "Party", "Raid", "Instance", "Say", "Yell" }
    panel.chanBtns = {}
    for i, ch in ipairs(channels) do
        local col = (i - 1) % 3
        local row = math.floor((i - 1) / 3)
        local isActive = (self.db.profile.message.channel == ch)

        local btn = CreateModernButton(panel, chanLabels[i], 80, 24, isActive)
        btn:SetPoint("TOPLEFT", panel, "TOPLEFT", 110 + col * 90, yOff - row * 30)
        local capCh = ch
        btn:SetScript("OnClick", function()
            PA.db.profile.message.channel = capCh
            PA:RefreshMessagesTab()
        end)
        panel.chanBtns[#panel.chanBtns + 1] = { btn = btn, channel = ch }
    end

    yOff = yOff - 72

    -- Cooldown
    MakeLabel(panel, "Cooldown:", "GameFontNormal", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff)

    local cooldowns = { 90, 105, 120, 150, 180 }
    local cdLabels  = { "1:30", "1:45", "2:00", "2:30", "3:00" }
    panel.cdBtns = {}
    for i, cd in ipairs(cooldowns) do
        local isActive = (self.db.profile.message.cooldown == cd)
        local btn = CreateModernButton(panel, cdLabels[i], 50, 24, isActive)
        btn:SetPoint("TOPLEFT", panel, "TOPLEFT", 110 + (i - 1) * 58, yOff)
        local capCD = cd
        btn:SetScript("OnClick", function()
            PA.db.profile.message.cooldown = capCD
            PA:RefreshMessagesTab()
        end)
        panel.cdBtns[#panel.cdBtns + 1] = { btn = btn, cd = cd }
    end

    yOff = yOff - 44

    -- Preview
    MakeLabel(panel, "Preview:", "GameFontNormal", THEME.accent,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff)

    local prevCard = CreateCard(panel, 16, yOff - 20, 500, 40)
    local prevText = MakeLabel(prevCard, "", "GameFontHighlight", THEME.warning,
        "TOPLEFT", prevCard, "TOPLEFT", 12, -12)
    prevText:SetWidth(476)
    panel.previewLabel = prevText

    yOff = yOff - 72

    -- Variables
    MakeLabel(panel, "Variables:", "GameFontNormalSmall", THEME.textMuted,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff)
    MakeLabel(panel, "{player}  {spec}  {class}  {priest}  {instance}  {group}  {time}",
        "GameFontNormalSmall", THEME.accentDim,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff - 18)

    -- Quick templates
    yOff = yOff - 50
    MakeLabel(panel, "Quick Templates:", "GameFontNormalSmall", THEME.textMuted,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff)

    local templates = {
        "PI please - {spec} bursting",
        "Need PI now - {priest}",
        "Burst active, PI me ({time})",
        "will pay 4 PI, am desperate",
    }
    for i, tpl in ipairs(templates) do
        local btn = CreateFrame("Button", nil, panel)
        btn:SetSize(400, 18)
        btn:SetPoint("TOPLEFT", panel, "TOPLEFT", 24, yOff - 16 - (i - 1) * 20)
        local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lbl:SetAllPoints()
        lbl:SetJustifyH("LEFT")
        lbl:SetText("|cff8866cc>|r " .. tpl)
        local capTpl = tpl
        btn:SetScript("OnClick", function()
            PA.db.profile.message.template = capTpl
            if panel.tplBox then panel.tplBox:SetText(capTpl) end
            PA:RefreshMessagesTab()
        end)
        btn:SetScript("OnEnter", function() lbl:SetTextColor(1, 1, 1) end)
        btn:SetScript("OnLeave", function() lbl:SetTextColor(0.7, 0.7, 0.7) end)
    end

    -- Send button
    local sendBtn = CreateModernButton(panel, "Send Now", 120, 30, true)
    sendBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 14)
    sendBtn:SetScript("OnClick", function() PA:SendPIRequest(true) end)
end

function PA:RefreshMessagesTab()
    local panel = self.mainFrame and self.mainFrame.tabPanels[TAB_MESSAGES]
    if not panel or not panel:IsShown() then return end

    if panel.previewLabel then
        panel.previewLabel:SetText(self:FormatMessage(self.db.profile.message.template))
    end

    -- Update channel button highlights
    if panel.chanBtns then
        for _, entry in ipairs(panel.chanBtns) do
            local isActive = (self.db.profile.message.channel == entry.channel)
            local color = isActive and THEME.btnAccent or THEME.btnNormal
            entry.btn:SetBackdropColor(color[1], color[2], color[3], color[4])
        end
    end

    -- Update cooldown button highlights
    if panel.cdBtns then
        for _, entry in ipairs(panel.cdBtns) do
            local isActive = (self.db.profile.message.cooldown == entry.cd)
            local color = isActive and THEME.btnAccent or THEME.btnNormal
            entry.btn:SetBackdropColor(color[1], color[2], color[3], color[4])
        end
    end
end


-- ─── Statistics Tab ───────────────────────────────────────────────────────────

function PA:BuildStatisticsTab(panel)
    MakeLabel(panel, "Statistics", "GameFontNormalLarge", THEME.text,
        "TOPLEFT", panel, "TOPLEFT", 20, -16)

    local resetBtn = CreateModernButton(panel, "Reset", 70, 24)
    resetBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -16, -14)
    resetBtn:SetScript("OnClick", function()
        StaticPopupDialogs["WP4PI_RESET_STATS"] = {
            text = "Reset all statistics?",
            button1 = ACCEPT,
            button2 = CANCEL,
            OnAccept = function() PA:ResetStatistics(); PA:RefreshStatsTab() end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        StaticPopup_Show("WP4PI_RESET_STATS")
    end)

    -- Stats cards
    local cardY = -50
    local cardW = 140
    local cardH = 56
    local gap   = 8

    local statDefs = {
        { key = "bursts",   title = "BURSTS",    color = THEME.warning },
        { key = "requests", title = "REQUESTS",  color = THEME.accent  },
        { key = "received", title = "PI RECV",   color = THEME.success },
        { key = "failed",   title = "FAILED",    color = THEME.danger  },
    }

    panel.statValues = {}
    for i, def in ipairs(statDefs) do
        local x = 16 + (i - 1) * (cardW + gap)
        local card = CreateCard(panel, x, cardY, cardW, cardH)
        MakeLabel(card, def.title, "GameFontNormalSmall", THEME.textMuted,
            "TOPLEFT", card, "TOPLEFT", 10, -8)
        local val = MakeLabel(card, "0", "GameFontNormalLarge", def.color,
            "TOPLEFT", card, "TOPLEFT", 10, -26)
        panel.statValues[def.key] = val
    end

    -- Extra stats row
    local extraY = cardY - cardH - 14
    MakeLabel(panel, "Success Rate:", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 20, extraY)
    panel.statValues.rate = MakeLabel(panel, "—", "GameFontNormalSmall", THEME.text,
        "TOPLEFT", panel, "TOPLEFT", 120, extraY)

    MakeLabel(panel, "Top Priest:", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 200, extraY)
    panel.statValues.topPriest = MakeLabel(panel, "—", "GameFontNormalSmall", THEME.text,
        "TOPLEFT", panel, "TOPLEFT", 290, extraY)

    MakeLabel(panel, "Avg Response:", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 420, extraY)
    panel.statValues.avgResp = MakeLabel(panel, "—", "GameFontNormalSmall", THEME.text,
        "TOPLEFT", panel, "TOPLEFT", 520, extraY)

    -- History
    local histY = extraY - 30
    MakeLabel(panel, "Recent History", "GameFontNormal", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 20, histY)

    local sf = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, histY - 20)
    sf:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -24, 12)

    local content = CreateFrame("Frame", nil, sf)
    content:SetWidth(sf:GetWidth())
    content:SetHeight(1)
    sf:SetScrollChild(content)
    panel.histScroll  = sf
    panel.histContent = content
    panel.histRows    = {}
end

function PA:RefreshStatsTab()
    local panel = self.mainFrame and self.mainFrame.tabPanels[TAB_STATISTICS]
    if not panel or not panel:IsShown() then return end

    local stats = self:GetStatistics()

    if panel.statValues.bursts   then panel.statValues.bursts:SetText(tostring(stats.burstsDetected or 0)) end
    if panel.statValues.requests then panel.statValues.requests:SetText(tostring(stats.requestsSent or 0)) end
    if panel.statValues.received then panel.statValues.received:SetText(tostring(stats.piReceived or 0)) end
    if panel.statValues.failed   then panel.statValues.failed:SetText(tostring(stats.piFailed or 0)) end
    if panel.statValues.rate     then panel.statValues.rate:SetText(string.format("%.1f%%", stats.successRate or 0)) end
    if panel.statValues.topPriest then
        panel.statValues.topPriest:SetText(stats.topPriest and (stats.topPriest .. " (" .. (stats.topPriestCount or 0) .. "x)") or "—")
    end
    if panel.statValues.avgResp then
        panel.statValues.avgResp:SetText(stats.avgResponseTime and stats.avgResponseTime > 0 and string.format("%.1fs", stats.avgResponseTime) or "—")
    end

    -- History rows
    for _, row in ipairs(panel.histRows or {}) do
        for _, w in ipairs(row) do w:Hide() end
    end
    panel.histRows = {}

    local sfW = panel.histScroll:GetWidth()
    if panel.histContent and sfW > 10 then panel.histContent:SetWidth(sfW) end

    local history = self:GetHistory()
    if #history == 0 then
        if not panel.noHistLabel then
            panel.noHistLabel = MakeLabel(panel.histContent, "No history yet.",
                "GameFontNormal", THEME.textDim, "TOPLEFT", panel.histContent, "TOPLEFT", 16, -10)
        end
        panel.noHistLabel:Show()
        panel.histContent:SetHeight(30)
        return
    end
    if panel.noHistLabel then panel.noHistLabel:Hide() end

    local rowH = 22
    local shown = math.min(50, #history)
    for i = #history, #history - shown + 1, -1 do
        local entry  = history[i]
        local rowIdx = #history - i + 1
        local y      = -(rowIdx - 1) * rowH
        local widgets = {}

        local bg = panel.histContent:CreateTexture(nil, "BACKGROUND")
        bg:SetPoint("TOPLEFT", panel.histContent, "TOPLEFT", 0, y)
        bg:SetPoint("TOPRIGHT", panel.histContent, "TOPRIGHT", 0, y)
        bg:SetHeight(rowH - 1)
        if rowIdx % 2 == 0 then
            bg:SetColorTexture(THEME.rowAlt[1], THEME.rowAlt[2], THEME.rowAlt[3], THEME.rowAlt[4])
        else
            bg:SetColorTexture(0, 0, 0, 0)
        end
        widgets[#widgets + 1] = bg

        local timeFS = panel.histContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        timeFS:SetPoint("TOPLEFT", panel.histContent, "TOPLEFT", 8, y - 4)
        timeFS:SetText(self:FormatTimestampTime(entry.timestamp) or "?")
        timeFS:SetTextColor(THEME.textMuted[1], THEME.textMuted[2], THEME.textMuted[3])
        widgets[#widgets + 1] = timeFS

        local priestFS = panel.histContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        priestFS:SetPoint("TOPLEFT", panel.histContent, "TOPLEFT", 70, y - 4)
        priestFS:SetText(entry.priest or "?")
        priestFS:SetTextColor(THEME.text[1], THEME.text[2], THEME.text[3])
        widgets[#widgets + 1] = priestFS

        local chFS = panel.histContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        chFS:SetPoint("TOPLEFT", panel.histContent, "TOPLEFT", 180, y - 4)
        chFS:SetText(entry.channel or "?")
        chFS:SetTextColor(THEME.textDim[1], THEME.textDim[2], THEME.textDim[3])
        widgets[#widgets + 1] = chFS

        local resFS = panel.histContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        resFS:SetPoint("TOPLEFT", panel.histContent, "TOPLEFT", 260, y - 4)
        local isOk = entry.result == L["STAT_SUCCESS"]
        resFS:SetText(entry.result or "?")
        resFS:SetTextColor(isOk and THEME.success[1] or THEME.danger[1],
                          isOk and THEME.success[2] or THEME.danger[2],
                          isOk and THEME.success[3] or THEME.danger[3])
        widgets[#widgets + 1] = resFS

        local msgFS = panel.histContent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        msgFS:SetPoint("TOPLEFT", panel.histContent, "TOPLEFT", 330, y - 4)
        msgFS:SetWidth(250)
        msgFS:SetText(entry.message or "")
        msgFS:SetTextColor(THEME.textMuted[1], THEME.textMuted[2], THEME.textMuted[3])
        widgets[#widgets + 1] = msgFS

        panel.histRows[#panel.histRows + 1] = widgets
    end

    panel.histContent:SetHeight(math.max(1, shown * rowH + 8))
end


-- ─── Alert Overlay ────────────────────────────────────────────────────────────
-- Slim notification bar — non-intrusive, positioned above character by default.
-- Slides in from top, stays briefly, fades out.

function PA:ShowAlert(message)
    if not self.alertFrame then
        self:CreateAlertFrame()
    end

    local cfg = self.db.profile.alert
    self.alertFrame:SetScale(cfg.scale or 1.0)
    self.alertFrame:ClearAllPoints()
    self.alertFrame:SetPoint("CENTER", UIParent, "CENTER", cfg.posX or 0, cfg.posY or 200)
    self.alertFrame.text:SetText(message)
    self.alertFrame:SetAlpha(0)
    self.alertFrame:Show()

    local duration  = cfg.duration or 2.5
    local fadeIn    = 0.2
    local fadeOut   = 0.6
    local startTime = GetTime()
    local frame     = self.alertFrame

    frame:SetScript("OnUpdate", function(self_f)
        local elapsed = GetTime() - startTime
        if elapsed < fadeIn then
            -- Slide/fade in
            self_f:SetAlpha(elapsed / fadeIn)
        elseif elapsed < duration - fadeOut then
            -- Hold
            self_f:SetAlpha(1.0)
        elseif elapsed < duration then
            -- Fade out
            self_f:SetAlpha(1.0 - (elapsed - (duration - fadeOut)) / fadeOut)
        else
            self_f:Hide()
            self_f:SetScript("OnUpdate", nil)
        end
    end)
end

function PA:HideAlert()
    if self.alertFrame then
        self.alertFrame:Hide()
        self.alertFrame:SetScript("OnUpdate", nil)
    end
end

function PA:CreateAlertFrame()
    local frame = CreateFrame("Frame", "WP4PIAlertFrame", UIParent, "BackdropTemplate")
    frame:SetSize(260, 36)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
    frame:SetFrameStrata("HIGH")
    frame:Hide()

    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0.06, 0.04, 0.12, 0.88)
    frame:SetBackdropBorderColor(THEME.accent[1], THEME.accent[2], THEME.accent[3], 0.6)

    -- Left accent bar
    local accent = frame:CreateTexture(nil, "OVERLAY")
    accent:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    accent:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
    accent:SetWidth(3)
    accent:SetColorTexture(THEME.accent[1], THEME.accent[2], THEME.accent[3], 1.0)

    -- Text
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("LEFT", frame, "LEFT", 12, 0)
    text:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("MIDDLE")
    text:SetTextColor(0.95, 0.88, 0.55)
    frame.text = text

    self.alertFrame = frame
end


-- ─── Alerts Tab ───────────────────────────────────────────────────────────────

function PA:BuildAlertsTab(panel)
    MakeLabel(panel, "Alert Settings", "GameFontNormalLarge", THEME.text,
        "TOPLEFT", panel, "TOPLEFT", 20, -16)

    local yOff = -50

    -- ── Visual Section ────────────────────────────────────────────────────
    MakeLabel(panel, "VISUAL", "GameFontNormalSmall", THEME.textMuted,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff)
    yOff = yOff - 20

    -- Enable visual
    local visualCB = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    visualCB:SetSize(22, 22)
    visualCB:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, yOff)
    visualCB:SetChecked(self.db.profile.alert.visual)
    visualCB:SetScript("OnClick", function(cb)
        PA.db.profile.alert.visual = cb:GetChecked()
    end)
    MakeLabel(panel, "Show visual alert on screen", "GameFontNormal", THEME.text,
        "TOPLEFT", panel, "TOPLEFT", 46, yOff - 3)
    panel.visualCB = visualCB

    yOff = yOff - 32

    -- Scale
    MakeLabel(panel, "Scale:", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff)
    local scaleSlider = CreateFrame("Slider", "WP4PIAlertScale", panel, "OptionsSliderTemplate")
    scaleSlider:SetPoint("TOPLEFT", panel, "TOPLEFT", 80, yOff - 2)
    scaleSlider:SetWidth(160)
    scaleSlider:SetMinMaxValues(0.5, 3.0)
    scaleSlider:SetValueStep(0.1)
    scaleSlider:SetObeyStepOnDrag(true)
    scaleSlider:SetValue(self.db.profile.alert.scale or 1.0)
    _G["WP4PIAlertScaleLow"]:SetText("0.5")
    _G["WP4PIAlertScaleHigh"]:SetText("3.0")
    _G["WP4PIAlertScaleText"]:SetText(string.format("%.1f", self.db.profile.alert.scale or 1.0))
    scaleSlider:SetScript("OnValueChanged", function(_, v)
        v = math.floor(v * 10 + 0.5) / 10
        PA.db.profile.alert.scale = v
        _G["WP4PIAlertScaleText"]:SetText(string.format("%.1f", v))
    end)
    panel.scaleSlider = scaleSlider

    yOff = yOff - 40

    -- Duration
    MakeLabel(panel, "Duration:", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff)
    local durSlider = CreateFrame("Slider", "WP4PIAlertDur", panel, "OptionsSliderTemplate")
    durSlider:SetPoint("TOPLEFT", panel, "TOPLEFT", 80, yOff - 2)
    durSlider:SetWidth(160)
    durSlider:SetMinMaxValues(0.5, 10.0)
    durSlider:SetValueStep(0.5)
    durSlider:SetObeyStepOnDrag(true)
    durSlider:SetValue(self.db.profile.alert.duration or 2.5)
    _G["WP4PIAlertDurLow"]:SetText("0.5s")
    _G["WP4PIAlertDurHigh"]:SetText("10s")
    _G["WP4PIAlertDurText"]:SetText(string.format("%.1fs", self.db.profile.alert.duration or 2.5))
    durSlider:SetScript("OnValueChanged", function(_, v)
        v = math.floor(v * 2 + 0.5) / 2
        PA.db.profile.alert.duration = v
        _G["WP4PIAlertDurText"]:SetText(string.format("%.1fs", v))
    end)
    panel.durSlider = durSlider

    yOff = yOff - 50

    -- Position
    MakeLabel(panel, "POSITION", "GameFontNormalSmall", THEME.textMuted,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff)
    yOff = yOff - 20

    MakeLabel(panel, "X Offset:", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff)
    local posXSlider = CreateFrame("Slider", "WP4PIAlertPosX", panel, "OptionsSliderTemplate")
    posXSlider:SetPoint("TOPLEFT", panel, "TOPLEFT", 80, yOff - 2)
    posXSlider:SetWidth(160)
    posXSlider:SetMinMaxValues(-800, 800)
    posXSlider:SetValueStep(5)
    posXSlider:SetObeyStepOnDrag(true)
    posXSlider:SetValue(self.db.profile.alert.posX or 0)
    _G["WP4PIAlertPosXLow"]:SetText("-800")
    _G["WP4PIAlertPosXHigh"]:SetText("800")
    _G["WP4PIAlertPosXText"]:SetText(tostring(self.db.profile.alert.posX or 0))
    posXSlider:SetScript("OnValueChanged", function(_, v)
        v = math.floor(v / 5 + 0.5) * 5
        PA.db.profile.alert.posX = v
        _G["WP4PIAlertPosXText"]:SetText(tostring(v))
    end)
    panel.posXSlider = posXSlider

    yOff = yOff - 40

    MakeLabel(panel, "Y Offset:", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 20, yOff)
    local posYSlider = CreateFrame("Slider", "WP4PIAlertPosY", panel, "OptionsSliderTemplate")
    posYSlider:SetPoint("TOPLEFT", panel, "TOPLEFT", 80, yOff - 2)
    posYSlider:SetWidth(160)
    posYSlider:SetMinMaxValues(-400, 400)
    posYSlider:SetValueStep(5)
    posYSlider:SetObeyStepOnDrag(true)
    posYSlider:SetValue(self.db.profile.alert.posY or 200)
    _G["WP4PIAlertPosYLow"]:SetText("-400")
    _G["WP4PIAlertPosYHigh"]:SetText("400")
    _G["WP4PIAlertPosYText"]:SetText(tostring(self.db.profile.alert.posY or 200))
    posYSlider:SetScript("OnValueChanged", function(_, v)
        v = math.floor(v / 5 + 0.5) * 5
        PA.db.profile.alert.posY = v
        _G["WP4PIAlertPosYText"]:SetText(tostring(v))
    end)
    panel.posYSlider = posYSlider

    yOff = yOff - 50

    -- ── Sound Section ─────────────────────────────────────────────────────
    MakeLabel(panel, "SOUND", "GameFontNormalSmall", THEME.textMuted,
        "TOPLEFT", panel, "TOPLEFT", 300, -50)

    local soundCB = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    soundCB:SetSize(22, 22)
    soundCB:SetPoint("TOPLEFT", panel, "TOPLEFT", 300, -70)
    soundCB:SetChecked(self.db.profile.alert.sound)
    soundCB:SetScript("OnClick", function(cb)
        PA.db.profile.alert.sound = cb:GetChecked()
    end)
    MakeLabel(panel, "Play sound on alert", "GameFontNormal", THEME.text,
        "TOPLEFT", panel, "TOPLEFT", 326, -73)
    panel.soundCB = soundCB

    -- Volume
    MakeLabel(panel, "Volume:", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 300, -102)
    local volSlider = CreateFrame("Slider", "WP4PIAlertVol", panel, "OptionsSliderTemplate")
    volSlider:SetPoint("TOPLEFT", panel, "TOPLEFT", 360, -104)
    volSlider:SetWidth(160)
    volSlider:SetMinMaxValues(0, 1)
    volSlider:SetValueStep(0.05)
    volSlider:SetObeyStepOnDrag(true)
    volSlider:SetValue(self.db.profile.alert.volume or 0.5)
    _G["WP4PIAlertVolLow"]:SetText("0%")
    _G["WP4PIAlertVolHigh"]:SetText("100%")
    _G["WP4PIAlertVolText"]:SetText(string.format("%.0f%%", (self.db.profile.alert.volume or 0.5) * 100))
    volSlider:SetScript("OnValueChanged", function(_, v)
        v = math.floor(v * 20 + 0.5) / 20
        PA.db.profile.alert.volume = v
        _G["WP4PIAlertVolText"]:SetText(string.format("%.0f%%", v * 100))
    end)
    panel.volSlider = volSlider

    -- Sound file
    MakeLabel(panel, "Sound File:", "GameFontNormalSmall", THEME.textDim,
        "TOPLEFT", panel, "TOPLEFT", 300, -150)
    local sfBox = CreateFrame("EditBox", "WP4PISoundFileBox", panel, "InputBoxTemplate")
    sfBox:SetSize(220, 22)
    sfBox:SetPoint("TOPLEFT", panel, "TOPLEFT", 300, -168)
    sfBox:SetAutoFocus(false)
    sfBox:SetMaxLetters(256)
    sfBox:SetText(self.db.profile.alert.soundFile or "")
    sfBox:SetScript("OnEnterPressed", function(box)
        PA.db.profile.alert.soundFile = box:GetText()
        box:ClearFocus()
    end)
    sfBox:SetScript("OnEscapePressed", function(box) box:ClearFocus() end)
    panel.soundFileBox = sfBox

    MakeLabel(panel, "Leave empty for default Raid Warning sound.\nCustom: Interface\\AddOns\\PIAssistant\\Media\\Sounds\\file.ogg",
        "GameFontNormalSmall", THEME.textMuted, "TOPLEFT", panel, "TOPLEFT", 300, -194)

    -- ── Test Buttons ──────────────────────────────────────────────────────
    local testVisBtn = CreateModernButton(panel, "Test Visual", 100, 28)
    testVisBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 16, 14)
    testVisBtn:SetScript("OnClick", function()
        PA:ShowAlert("Power Infusion Active!\n[TEST]")
    end)

    local testSndBtn = CreateModernButton(panel, "Test Sound", 100, 28)
    testSndBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 126, 14)
    testSndBtn:SetScript("OnClick", function()
        PA:PlayAlertSound()
    end)

    local aceBtn = CreateModernButton(panel, "Advanced Options", 130, 28)
    aceBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -16, 14)
    aceBtn:SetScript("OnClick", function()
        LibStub("AceConfigDialog-3.0"):Open(addonName)
    end)
end

function PA:RefreshAlertsTab()
    local panel = self.mainFrame and self.mainFrame.tabPanels[TAB_ALERTS]
    if not panel or not panel:IsShown() then return end

    -- Sync UI with current DB values
    if panel.visualCB then panel.visualCB:SetChecked(self.db.profile.alert.visual) end
    if panel.soundCB then panel.soundCB:SetChecked(self.db.profile.alert.sound) end
    if panel.scaleSlider then panel.scaleSlider:SetValue(self.db.profile.alert.scale or 1.0) end
    if panel.durSlider then panel.durSlider:SetValue(self.db.profile.alert.duration or 2.5) end
    if panel.posXSlider then panel.posXSlider:SetValue(self.db.profile.alert.posX or 0) end
    if panel.posYSlider then panel.posYSlider:SetValue(self.db.profile.alert.posY or 200) end
    if panel.volSlider then panel.volSlider:SetValue(self.db.profile.alert.volume or 0.5) end
    if panel.soundFileBox then panel.soundFileBox:SetText(self.db.profile.alert.soundFile or "") end
end
