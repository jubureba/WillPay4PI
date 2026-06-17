local addonName, ns = ...

-- SpellDatabase: static spell metadata used by BurstDetector and UI
-- IDs are from current retail; will need updating if Midnight changes them.
ns.SpellDB = {
    -- Power Infusion (Priest buff received by player)
    [10060] = {
        name      = "Power Infusion",
        class     = "PRIEST",
        type      = "BUFF",
        icon      = 135939,
        important = true,
    },

    -- Demon Hunter - Havoc / Devour (Midnight spec name)
    [191427] = {
        name     = "Metamorphosis",
        class    = "DEMONHUNTER",
        spec     = "DEVOUR",
        type     = "BURST_PRIMARY",
        icon     = 1247264,
        events   = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" },
        weight   = 100,
        priority = 1,
        cd       = 0,  -- internal request cooldown override (0 = use global)
    },
    [258860] = {
        name     = "Essence Break",
        class    = "DEMONHUNTER",
        spec     = "DEVOUR",
        type     = "BURST_SECONDARY",
        icon     = 1380904,
        events   = { "SPELL_CAST_SUCCESS" },
        weight   = 60,
        priority = 2,
        cd       = 0,
    },
    [198013] = {
        name     = "Eye Beam",
        class    = "DEMONHUNTER",
        spec     = "DEVOUR",
        type     = "BURST_TERTIARY",
        icon     = 1305156,
        events   = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" },
        weight   = 40,
        priority = 3,
        cd       = 0,
    },

    -- Demon Hunter - Vengeance
    [187827] = {
        name     = "Metamorphosis",
        class    = "DEMONHUNTER",
        spec     = "VENGEANCE",
        type     = "BURST_PRIMARY",
        icon     = 1247264,
        events   = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" },
        weight   = 100,
        priority = 1,
        cd       = 0,
    },

    -- Warrior - Fury
    [1719] = {
        name     = "Recklessness",
        class    = "WARRIOR",
        spec     = "FURY",
        type     = "BURST_PRIMARY",
        icon     = 458972,
        events   = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" },
        weight   = 100,
        priority = 1,
        cd       = 0,
    },

    -- Warrior - Arms
    [227847] = {
        name     = "Bladestorm",
        class    = "WARRIOR",
        spec     = "ARMS",
        type     = "BURST_PRIMARY",
        icon     = 236303,
        events   = { "SPELL_CAST_SUCCESS" },
        weight   = 100,
        priority = 1,
        cd       = 0,
    },

    -- Mage - Fire
    [190319] = {
        name     = "Combustion",
        class    = "MAGE",
        spec     = "FIRE",
        type     = "BURST_PRIMARY",
        icon     = 135824,
        events   = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" },
        weight   = 100,
        priority = 1,
        cd       = 0,
    },

    -- Mage - Frost
    [12472] = {
        name     = "Icy Veins",
        class    = "MAGE",
        spec     = "FROST",
        type     = "BURST_PRIMARY",
        icon     = 135838,
        events   = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" },
        weight   = 100,
        priority = 1,
        cd       = 0,
    },

    -- Hunter - Beast Mastery
    [193530] = {
        name     = "Aspect of the Wild",
        class    = "HUNTER",
        spec     = "BEASTMASTERY",
        type     = "BURST_PRIMARY",
        icon     = 136074,
        events   = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" },
        weight   = 100,
        priority = 1,
        cd       = 0,
    },

    -- Hunter - Marksmanship
    [288613] = {
        name     = "Trueshot",
        class    = "HUNTER",
        spec     = "MARKSMANSHIP",
        type     = "BURST_PRIMARY",
        icon     = 132329,
        events   = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" },
        weight   = 100,
        priority = 1,
        cd       = 0,
    },

    -- Rogue - Assassination
    [360194] = {
        name     = "Deathmark",
        class    = "ROGUE",
        spec     = "ASSASSINATION",
        type     = "BURST_PRIMARY",
        icon     = 3578228,
        events   = { "SPELL_CAST_SUCCESS" },
        weight   = 100,
        priority = 1,
        cd       = 0,
    },

    -- Rogue - Outlaw
    [13750] = {
        name     = "Adrenaline Rush",
        class    = "ROGUE",
        spec     = "OUTLAW",
        type     = "BURST_PRIMARY",
        icon     = 136206,
        events   = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" },
        weight   = 100,
        priority = 1,
        cd       = 0,
    },

    -- Rogue - Subtlety
    [121471] = {
        name     = "Shadow Blades",
        class    = "ROGUE",
        spec     = "SUBTLETY",
        type     = "BURST_PRIMARY",
        icon     = 376022,
        events   = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" },
        weight   = 100,
        priority = 1,
        cd       = 0,
    },
}

-- Helper: get spell name from ID, using DB first then WoW API
function ns.GetSpellName(spellID)
    if ns.SpellDB[spellID] then
        return ns.SpellDB[spellID].name
    end
    local info = C_Spell and C_Spell.GetSpellInfo(spellID)
    return info and info.name or tostring(spellID)
end

-- Helper: get spell icon from ID
function ns.GetSpellIcon(spellID)
    if ns.SpellDB[spellID] then
        return ns.SpellDB[spellID].icon
    end
    local info = C_Spell and C_Spell.GetSpellInfo(spellID)
    return info and info.iconID or 134400
end
