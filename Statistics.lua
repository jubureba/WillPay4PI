local addonName, ns = ...
local PA = ns.PA
local L  = ns.L

local MAX_HISTORY = 200

-- ─── Initialization ───────────────────────────────────────────────────────────

function PA:InitializeStatistics()
    -- Stats are stored in db.profile.statistics (persisted)
    -- Ensure table structure is present
    local s = self.db.profile.statistics
    s.burstsDetected = s.burstsDetected or 0
    s.requestsSent   = s.requestsSent   or 0
    s.piReceived     = s.piReceived     or 0
    s.piFailed       = s.piFailed       or 0
    s.priestCounts   = s.priestCounts   or {}
    s.responseTimes  = s.responseTimes  or {}
    s.history        = s.history        or {}

    -- Session-only tracking
    self.sessionBursts   = 0
    self.sessionRequests = 0
    self.sessionReceived = 0
    self.sessionFailed   = 0
    self.pendingBurstTime = nil  -- time of last burst, for response time calc
end

-- ─── Recording ────────────────────────────────────────────────────────────────

function PA:RecordBurstDetected()
    local s = self.db.profile.statistics
    s.burstsDetected = s.burstsDetected + 1
    self.sessionBursts = (self.sessionBursts or 0) + 1
    self.pendingBurstTime = GetTime()
end

function PA:RecordRequestSent(priest, channel, message)
    local s   = self.db.profile.statistics
    s.requestsSent = s.requestsSent + 1
    self.sessionRequests = (self.sessionRequests or 0) + 1

    local priestKey = priest and priest.key or "unknown"
    s.priestCounts[priestKey] = (s.priestCounts[priestKey] or 0) + 1

    self:AddToHistory({
        timestamp = time(),
        priest    = priest and (priest.name .. (priest.realm ~= GetRealmName() and "-"..priest.realm or "")) or "?",
        channel   = channel or "?",
        message   = message or "",
        result    = L["STAT_SUCCESS"],
    })
end

function PA:RecordPIReceived(sourceName, receivedAt)
    local s = self.db.profile.statistics
    s.piReceived = s.piReceived + 1
    self.sessionReceived = (self.sessionReceived or 0) + 1

    -- Calculate response time if we have a burst timestamp
    if self.pendingBurstTime and receivedAt then
        local responseTime = receivedAt - self.pendingBurstTime
        if responseTime > 0 and responseTime < 60 then
            s.responseTimes[#s.responseTimes + 1] = responseTime
            -- Keep last 100 response times
            while #s.responseTimes > 100 do
                table.remove(s.responseTimes, 1)
            end
        end
        self.pendingBurstTime = nil
    end
end

function PA:RecordPIFailed(reason)
    local s = self.db.profile.statistics
    s.piFailed = s.piFailed + 1
    self.sessionFailed = (self.sessionFailed or 0) + 1

    self:AddToHistory({
        timestamp = time(),
        priest    = self.db.profile.priests.selected or "?",
        channel   = self.db.profile.message.channel or "?",
        message   = reason or L["STAT_FAILED"],
        result    = L["STAT_FAILED"],
    })
end

function PA:AddToHistory(entry)
    local s = self.db.profile.statistics
    s.history[#s.history + 1] = entry
    -- Prune oldest entries
    while #s.history > MAX_HISTORY do
        table.remove(s.history, 1)
    end
end

-- ─── Accessors ────────────────────────────────────────────────────────────────

function PA:GetStatistics()
    local s   = self.db.profile.statistics
    local total   = s.requestsSent
    local success = s.piReceived
    local rate    = (total > 0) and (success / total * 100) or 0

    local avgResponse = 0
    if #s.responseTimes > 0 then
        local sum = 0
        for _, t in ipairs(s.responseTimes) do sum = sum + t end
        avgResponse = sum / #s.responseTimes
    end

    -- Find most used priest
    local topPriest, topCount = nil, 0
    for key, count in pairs(s.priestCounts) do
        if count > topCount then
            topPriest = key
            topCount  = count
        end
    end

    return {
        burstsDetected = s.burstsDetected,
        requestsSent   = s.requestsSent,
        piReceived     = s.piReceived,
        piFailed       = s.piFailed,
        successRate    = rate,
        topPriest      = topPriest,
        topPriestCount = topCount,
        avgResponseTime = avgResponse,
        -- Session
        sessionBursts   = self.sessionBursts   or 0,
        sessionRequests = self.sessionRequests or 0,
        sessionReceived = self.sessionReceived or 0,
        sessionFailed   = self.sessionFailed   or 0,
    }
end

function PA:GetHistory()
    return self.db.profile.statistics.history
end

function PA:GetPriestStats()
    local stats   = {}
    local counts  = self.db.profile.statistics.priestCounts
    for key, count in pairs(counts) do
        stats[#stats + 1] = { key = key, count = count }
    end
    table.sort(stats, function(a, b) return a.count > b.count end)
    return stats
end

-- ─── Reset ───────────────────────────────────────────────────────────────────

function PA:ResetStatistics()
    local s = self.db.profile.statistics
    s.burstsDetected = 0
    s.requestsSent   = 0
    s.piReceived     = 0
    s.piFailed       = 0
    s.priestCounts   = {}
    s.responseTimes  = {}
    s.history        = {}

    self.sessionBursts    = 0
    self.sessionRequests  = 0
    self.sessionReceived  = 0
    self.sessionFailed    = 0
    self.pendingBurstTime = nil

    self:Print("PI Assistant: Statistics reset.")
end

-- ─── Format Helpers ───────────────────────────────────────────────────────────

-- Formats a timestamp as "YYYY-MM-DD HH:MM:SS"
function PA:FormatTimestamp(ts)
    if not ts then return "—" end
    return date("%Y-%m-%d %H:%M:%S", ts)
end

function PA:FormatTimestampDate(ts)
    if not ts then return "—" end
    return date("%Y-%m-%d", ts)
end

function PA:FormatTimestampTime(ts)
    if not ts then return "—" end
    return date("%H:%M:%S", ts)
end
