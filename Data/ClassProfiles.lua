local addonName, ns = ...

-- ClassProfiles: default burst spell sets per class/spec.
-- Keys match UnitClass() returns (English, uppercase) and spec names.
-- Each entry lists spell IDs enabled by default for burst detection.

ns.ClassProfiles = {
    DEMONHUNTER = {
        -- Midnight 12.x new spec
        DEVOUR = {
            name        = "Demon Hunter - Devour",
            description = "Chaos Metamorphosis (1217605) as primary burst cooldown.",
            spells = {
                { id = 1217605, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        -- Pre-Midnight spec
        HAVOC = {
            name        = "Demon Hunter - Havoc",
            description = "Metamorphosis as primary burst with Essence Break and Eye Beam as secondaries.",
            spells = {
                { id = 191427, enabled = true,  weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
                { id = 258860, enabled = true,  weight = 60,  priority = 2, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
                { id = 198013, enabled = false, weight = 40,  priority = 3, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        VENGEANCE = {
            name        = "Demon Hunter - Vengeance",
            description = "Metamorphosis as primary defensive cooldown / burst.",
            spells = {
                { id = 187827, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
    },

    WARRIOR = {
        FURY = {
            name        = "Warrior - Fury",
            description = "Recklessness as primary burst cooldown.",
            spells = {
                { id = 1719, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        ARMS = {
            name        = "Warrior - Arms",
            description = "Bladestorm as primary burst cooldown.",
            spells = {
                { id = 227847, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        PROTECTION = {
            name        = "Warrior - Protection",
            description = "No default burst profile. Add spells manually.",
            spells      = {},
        },
    },

    MAGE = {
        FIRE = {
            name        = "Mage - Fire",
            description = "Combustion as primary burst cooldown.",
            spells = {
                { id = 190319, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        FROST = {
            name        = "Mage - Frost",
            description = "Icy Veins as primary burst cooldown.",
            spells = {
                { id = 12472, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        ARCANE = {
            name        = "Mage - Arcane",
            description = "No default burst profile. Add spells manually.",
            spells      = {},
        },
    },

    HUNTER = {
        BEASTMASTERY = {
            name        = "Hunter - Beast Mastery",
            description = "Aspect of the Wild as primary burst cooldown.",
            spells = {
                { id = 193530, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        MARKSMANSHIP = {
            name        = "Hunter - Marksmanship",
            description = "Trueshot as primary burst cooldown.",
            spells = {
                { id = 288613, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        SURVIVAL = {
            name        = "Hunter - Survival",
            description = "No default burst profile. Add spells manually.",
            spells      = {},
        },
    },

    ROGUE = {
        ASSASSINATION = {
            name        = "Rogue - Assassination",
            description = "Deathmark as primary burst cooldown.",
            spells = {
                { id = 360194, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        OUTLAW = {
            name        = "Rogue - Outlaw",
            description = "Adrenaline Rush as primary burst cooldown.",
            spells = {
                { id = 13750, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        SUBTLETY = {
            name        = "Rogue - Subtlety",
            description = "Shadow Blades as primary burst cooldown.",
            spells = {
                { id = 121471, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
    },
}

-- ─── Spec ID → Profile Key (locale-independent) ──────────────────────────────
-- Maps WoW specID (numeric, locale-independent) to { class, spec } profile keys.
-- Add new Midnight specIDs here as they become known.
ns.SpecIDToProfile = {
    -- Demon Hunter
    [1480] = { class = "DEMONHUNTER", spec = "DEVOUR"    },  -- Devour (new in Midnight 12.x)
    [577]  = { class = "DEMONHUNTER", spec = "HAVOC"     },  -- Havoc (pre-Midnight)
    [581]  = { class = "DEMONHUNTER", spec = "VENGEANCE" },
    -- Warrior
    [71]  = { class = "WARRIOR",     spec = "ARMS"           },
    [72]  = { class = "WARRIOR",     spec = "FURY"           },
    [73]  = { class = "WARRIOR",     spec = "PROTECTION"     },
    -- Mage
    [62]  = { class = "MAGE",        spec = "ARCANE"         },
    [63]  = { class = "MAGE",        spec = "FIRE"           },
    [64]  = { class = "MAGE",        spec = "FROST"          },
    -- Hunter
    [253] = { class = "HUNTER",      spec = "BEASTMASTERY"   },
    [254] = { class = "HUNTER",      spec = "MARKSMANSHIP"   },
    [255] = { class = "HUNTER",      spec = "SURVIVAL"       },
    -- Rogue
    [259] = { class = "ROGUE",       spec = "ASSASSINATION"  },
    [260] = { class = "ROGUE",       spec = "OUTLAW"         },
    [261] = { class = "ROGUE",       spec = "SUBTLETY"       },
    -- Priest (for PriestManager display)
    [256] = { class = "PRIEST",      spec = "DISCIPLINE"     },
    [257] = { class = "PRIEST",      spec = "HOLY"           },
    [258] = { class = "PRIEST",      spec = "SHADOW"         },
}

-- ─── Localized Spec Name Aliases ─────────────────────────────────────────────
-- Maps uppercased ASCII localized spec names to profile keys.
-- Keys are produced by:  specNameLocalized:upper():gsub("[%s%-]", "")
-- Only include ASCII-safe names (Lua string.upper doesn't handle UTF-8).
ns.SpecNameAliases = {
    -- English
    DEVOUR          = "DEVOUR",
    DEVOURER        = "DEVOUR",
    HAVOC           = "HAVOC",
    VENGEANCE       = "VENGEANCE",
    FURY            = "FURY",
    ARMS            = "ARMS",
    PROTECTION      = "PROTECTION",
    FIRE            = "FIRE",
    FROST           = "FROST",
    ARCANE          = "ARCANE",
    BEASTMASTERY    = "BEASTMASTERY",
    MARKSMANSHIP    = "MARKSMANSHIP",
    SURVIVAL        = "SURVIVAL",
    ASSASSINATION   = "ASSASSINATION",
    OUTLAW          = "OUTLAW",
    SUBTLETY        = "SUBTLETY",
    -- Portuguese (PT) – ASCII-only names (accented chars skipped; use specID lookup instead)
    DEVORADOR       = "DEVOUR",
    FURIA           = "FURY",
    ARMAS           = "ARMS",
    FOGO            = "FIRE",
    GELO            = "FROST",
    ARCANO          = "ARCANE",
    ASSASSINATO     = "ASSASSINATION",
    SUTILEZA        = "SUBTLETY",
    -- German (DE) – ASCII-only
    RACHE           = "VENGEANCE",
    VERWUESTUNG     = "DEVOUR",
}

-- Returns the default profile for the given class/spec, or an empty profile.
function ns.GetDefaultClassProfile(class, spec)
    local classProfiles = ns.ClassProfiles[class]
    if not classProfiles then
        return { name = class .. " - " .. (spec or "Unknown"), description = "", spells = {} }
    end
    local specProfile = classProfiles[spec]
    if not specProfile then
        return { name = class .. " - " .. (spec or "Unknown"), description = "", spells = {} }
    end
    -- Deep copy to avoid mutating the template
    local copy = { name = specProfile.name, description = specProfile.description, spells = {} }
    for _, spell in ipairs(specProfile.spells) do
        local sc = {}
        for k, v in pairs(spell) do
            if type(v) == "table" then
                sc[k] = {}
                for i, ev in ipairs(v) do sc[k][i] = ev end
            else
                sc[k] = v
            end
        end
        copy.spells[#copy.spells + 1] = sc
    end
    return copy
end
