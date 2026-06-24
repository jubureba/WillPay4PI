local addonName, ns = ...

-- ClassProfiles: default burst spell sets per class/spec for Midnight 12.x.
-- Spell IDs verified for patch 12.0.7.

ns.ClassProfiles = {
    DEATHKNIGHT = {
        BLOOD = {
            name = "Death Knight - Blood",
            description = "Dancing Rune Weapon as primary.",
            spells = {
                { id = 49028, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        FROST = {
            name = "Death Knight - Frost",
            description = "Pillar of Frost + Empower Rune Weapon.",
            spells = {
                { id = 51271, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
                { id = 47568, enabled = true, weight = 60, priority = 2, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        UNHOLY = {
            name = "Death Knight - Unholy",
            description = "Army of the Dead + Dark Transformation.",
            spells = {
                { id = 42650, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
                { id = 63560, enabled = true, weight = 70, priority = 2, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
    },

    DEMONHUNTER = {
        DEVOUR = {
            name = "Demon Hunter - Devour",
            description = "Chaos Metamorphosis as primary burst.",
            spells = {
                { id = 1217605, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        HAVOC = {
            name = "Demon Hunter - Havoc",
            description = "Metamorphosis + Essence Break.",
            spells = {
                { id = 191427, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
                { id = 258860, enabled = true, weight = 60, priority = 2, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        VENGEANCE = {
            name = "Demon Hunter - Vengeance",
            description = "Metamorphosis (tank).",
            spells = {
                { id = 187827, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
    },

    DRUID = {
        BALANCE = {
            name = "Druid - Balance",
            description = "Celestial Alignment / Incarnation.",
            spells = {
                { id = 194223, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
                { id = 102560, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        FERAL = {
            name = "Druid - Feral",
            description = "Berserk / Incarnation: Avatar of Ashamane.",
            spells = {
                { id = 106951, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
                { id = 102543, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        GUARDIAN = {
            name = "Druid - Guardian",
            description = "Incarnation: Guardian of Ursoc.",
            spells = {
                { id = 102558, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        RESTORATION = {
            name = "Druid - Restoration",
            description = "No default DPS burst.",
            spells = {},
        },
    },

    EVOKER = {
        DEVASTATION = {
            name = "Evoker - Devastation",
            description = "Dragonrage as primary burst.",
            spells = {
                { id = 375087, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        AUGMENTATION = {
            name = "Evoker - Augmentation",
            description = "Breath of Eons.",
            spells = {
                { id = 403631, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        PRESERVATION = {
            name = "Evoker - Preservation",
            description = "No default DPS burst.",
            spells = {},
        },
    },

    HUNTER = {
        BEASTMASTERY = {
            name = "Hunter - Beast Mastery",
            description = "Bestial Wrath + Call of the Wild.",
            spells = {
                { id = 19574, enabled = true, weight = 80, priority = 2, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
                { id = 359844, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        MARKSMANSHIP = {
            name = "Hunter - Marksmanship",
            description = "Trueshot as primary burst.",
            spells = {
                { id = 288613, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        SURVIVAL = {
            name = "Hunter - Survival",
            description = "Coordinated Assault.",
            spells = {
                { id = 360952, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
    },

    MAGE = {
        ARCANE = {
            name = "Mage - Arcane",
            description = "Arcane Surge as primary burst.",
            spells = {
                { id = 365350, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        FIRE = {
            name = "Mage - Fire",
            description = "Combustion as primary burst.",
            spells = {
                { id = 190319, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        FROST = {
            name = "Mage - Frost",
            description = "Icy Veins as primary burst.",
            spells = {
                { id = 12472, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
    },

    MONK = {
        WINDWALKER = {
            name = "Monk - Windwalker",
            description = "Storm, Earth, and Fire + Invoke Xuen.",
            spells = {
                { id = 137639, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
                { id = 123904, enabled = true, weight = 80, priority = 2, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        BREWMASTER = {
            name = "Monk - Brewmaster",
            description = "Invoke Niuzao.",
            spells = {
                { id = 132578, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        MISTWEAVER = {
            name = "Monk - Mistweaver",
            description = "No default DPS burst.",
            spells = {},
        },
    },

    PALADIN = {
        RETRIBUTION = {
            name = "Paladin - Retribution",
            description = "Avenging Wrath / Crusade.",
            spells = {
                { id = 31884, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
                { id = 231895, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        PROTECTION = {
            name = "Paladin - Protection",
            description = "Avenging Wrath.",
            spells = {
                { id = 31884, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        HOLY = {
            name = "Paladin - Holy",
            description = "No default DPS burst.",
            spells = {},
        },
    },

    PRIEST = {
        SHADOW = {
            name = "Priest - Shadow",
            description = "Void Eruption / Dark Ascension.",
            spells = {
                { id = 228260, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
                { id = 391109, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        DISCIPLINE = {
            name = "Priest - Discipline",
            description = "No default DPS burst.",
            spells = {},
        },
        HOLY = {
            name = "Priest - Holy",
            description = "No default DPS burst.",
            spells = {},
        },
    },

    ROGUE = {
        ASSASSINATION = {
            name = "Rogue - Assassination",
            description = "Deathmark as primary burst.",
            spells = {
                { id = 360194, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        OUTLAW = {
            name = "Rogue - Outlaw",
            description = "Adrenaline Rush as primary burst.",
            spells = {
                { id = 13750, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        SUBTLETY = {
            name = "Rogue - Subtlety",
            description = "Shadow Dance + Shadow Blades.",
            spells = {
                { id = 121471, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
                { id = 185313, enabled = true, weight = 70, priority = 2, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
    },

    SHAMAN = {
        ELEMENTAL = {
            name = "Shaman - Elemental",
            description = "Stormkeeper + Ascendance.",
            spells = {
                { id = 191634, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
                { id = 114050, enabled = true, weight = 90, priority = 2, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        ENHANCEMENT = {
            name = "Shaman - Enhancement",
            description = "Feral Spirit + Ascendance.",
            spells = {
                { id = 51533, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
                { id = 114051, enabled = true, weight = 90, priority = 2, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        RESTORATION = {
            name = "Shaman - Restoration",
            description = "No default DPS burst.",
            spells = {},
        },
    },

    WARLOCK = {
        AFFLICTION = {
            name = "Warlock - Affliction",
            description = "Summon Darkglare.",
            spells = {
                { id = 205180, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        DEMONOLOGY = {
            name = "Warlock - Demonology",
            description = "Summon Demonic Tyrant.",
            spells = {
                { id = 265187, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        DESTRUCTION = {
            name = "Warlock - Destruction",
            description = "Summon Infernal.",
            spells = {
                { id = 1122, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
    },

    WARRIOR = {
        ARMS = {
            name = "Warrior - Arms",
            description = "Colossus Smash + Bladestorm.",
            spells = {
                { id = 167105, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
                { id = 227847, enabled = true, weight = 80, priority = 2, cd = 0,
                  events = { "SPELL_CAST_SUCCESS" } },
            },
        },
        FURY = {
            name = "Warrior - Fury",
            description = "Recklessness as primary burst.",
            spells = {
                { id = 1719, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
        PROTECTION = {
            name = "Warrior - Protection",
            description = "Avatar.",
            spells = {
                { id = 401150, enabled = true, weight = 100, priority = 1, cd = 0,
                  events = { "SPELL_CAST_SUCCESS", "SPELL_AURA_APPLIED" } },
            },
        },
    },
}

-- --- Spec ID to Profile Key (locale-independent) -----------------------------
ns.SpecIDToProfile = {
    -- Death Knight
    [250] = { class = "DEATHKNIGHT", spec = "BLOOD"    },
    [251] = { class = "DEATHKNIGHT", spec = "FROST"    },
    [252] = { class = "DEATHKNIGHT", spec = "UNHOLY"   },
    -- Demon Hunter
    [1480] = { class = "DEMONHUNTER", spec = "DEVOUR"    },
    [577]  = { class = "DEMONHUNTER", spec = "HAVOC"     },
    [581]  = { class = "DEMONHUNTER", spec = "VENGEANCE" },
    -- Druid
    [102] = { class = "DRUID", spec = "BALANCE"     },
    [103] = { class = "DRUID", spec = "FERAL"       },
    [104] = { class = "DRUID", spec = "GUARDIAN"    },
    [105] = { class = "DRUID", spec = "RESTORATION" },
    -- Evoker
    [1467] = { class = "EVOKER", spec = "DEVASTATION"  },
    [1468] = { class = "EVOKER", spec = "PRESERVATION" },
    [1473] = { class = "EVOKER", spec = "AUGMENTATION" },
    -- Hunter
    [253] = { class = "HUNTER", spec = "BEASTMASTERY"  },
    [254] = { class = "HUNTER", spec = "MARKSMANSHIP"  },
    [255] = { class = "HUNTER", spec = "SURVIVAL"      },
    -- Mage
    [62]  = { class = "MAGE", spec = "ARCANE" },
    [63]  = { class = "MAGE", spec = "FIRE"   },
    [64]  = { class = "MAGE", spec = "FROST"  },
    -- Monk
    [268] = { class = "MONK", spec = "BREWMASTER"  },
    [270] = { class = "MONK", spec = "MISTWEAVER"  },
    [269] = { class = "MONK", spec = "WINDWALKER"  },
    -- Paladin
    [65]  = { class = "PALADIN", spec = "HOLY"        },
    [66]  = { class = "PALADIN", spec = "PROTECTION"  },
    [70]  = { class = "PALADIN", spec = "RETRIBUTION" },
    -- Priest
    [256] = { class = "PRIEST", spec = "DISCIPLINE" },
    [257] = { class = "PRIEST", spec = "HOLY"       },
    [258] = { class = "PRIEST", spec = "SHADOW"     },
    -- Rogue
    [259] = { class = "ROGUE", spec = "ASSASSINATION" },
    [260] = { class = "ROGUE", spec = "OUTLAW"       },
    [261] = { class = "ROGUE", spec = "SUBTLETY"     },
    -- Shaman
    [262] = { class = "SHAMAN", spec = "ELEMENTAL"   },
    [263] = { class = "SHAMAN", spec = "ENHANCEMENT" },
    [264] = { class = "SHAMAN", spec = "RESTORATION" },
    -- Warlock
    [265] = { class = "WARLOCK", spec = "AFFLICTION"  },
    [266] = { class = "WARLOCK", spec = "DEMONOLOGY"  },
    [267] = { class = "WARLOCK", spec = "DESTRUCTION" },
    -- Warrior
    [71]  = { class = "WARRIOR", spec = "ARMS"       },
    [72]  = { class = "WARRIOR", spec = "FURY"       },
    [73]  = { class = "WARRIOR", spec = "PROTECTION" },
}

-- --- Localized Spec Name Aliases ---------------------------------------------
ns.SpecNameAliases = {
    -- English
    DEVOUR = "DEVOUR", DEVOURER = "DEVOUR", HAVOC = "HAVOC", VENGEANCE = "VENGEANCE",
    BLOOD = "BLOOD", UNHOLY = "UNHOLY",
    BALANCE = "BALANCE", FERAL = "FERAL", GUARDIAN = "GUARDIAN", RESTORATION = "RESTORATION",
    DEVASTATION = "DEVASTATION", AUGMENTATION = "AUGMENTATION", PRESERVATION = "PRESERVATION",
    FURY = "FURY", ARMS = "ARMS", PROTECTION = "PROTECTION",
    FIRE = "FIRE", FROST = "FROST", ARCANE = "ARCANE",
    BEASTMASTERY = "BEASTMASTERY", MARKSMANSHIP = "MARKSMANSHIP", SURVIVAL = "SURVIVAL",
    ASSASSINATION = "ASSASSINATION", OUTLAW = "OUTLAW", SUBTLETY = "SUBTLETY",
    ELEMENTAL = "ELEMENTAL", ENHANCEMENT = "ENHANCEMENT",
    AFFLICTION = "AFFLICTION", DEMONOLOGY = "DEMONOLOGY", DESTRUCTION = "DESTRUCTION",
    WINDWALKER = "WINDWALKER", BREWMASTER = "BREWMASTER", MISTWEAVER = "MISTWEAVER",
    RETRIBUTION = "RETRIBUTION", HOLY = "HOLY", DISCIPLINE = "DISCIPLINE", SHADOW = "SHADOW",
    -- Portuguese
    DEVORADOR = "DEVOUR", FURIA = "FURY", ARMAS = "ARMS", FOGO = "FIRE", GELO = "FROST",
    ARCANO = "ARCANE", ASSASSINATO = "ASSASSINATION", SUTILEZA = "SUBTLETY",
    SANGUE = "BLOOD", PROFANO = "UNHOLY", EQUILIBRIO = "BALANCE", SELVAGEM = "FERAL",
    GUARDIAO = "GUARDIAN", ELEMENTAL_ = "ELEMENTAL", APRIMORAMENTO = "ENHANCEMENT",
    DESTRUICAO = "DESTRUCTION", DEMONOLOGIA = "DEMONOLOGY", AFLICAO = "AFFLICTION",
    ANDARILHODOVENTO = "WINDWALKER", CERVEJEIRO = "BREWMASTER", TECENEBRINA = "MISTWEAVER",
    RETRIBUICAO = "RETRIBUTION", SAGRADO = "HOLY", DISCIPLINA = "DISCIPLINE", SOMBRA = "SHADOW",
    -- German
    RACHE = "VENGEANCE", VERWUESTUNG = "DEVOUR",
    -- Spanish
    EQUILIBRIO = "BALANCE", FEROZ = "FERAL",
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
    -- Deep copy
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
