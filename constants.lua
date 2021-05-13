local addonName, addon = ...

Enum.AuraTypes = {
    Curse = "Curse",
    Disease = "Disease",
    Enrage = "Enrage",
    Magic = "Magic",
    Poison = "Poison",
}

--[[ dispel_types
    A list of debuff types that can be dispeled by this class. These can be use to provide a highlight border.
    In the event a debuff can only be cleaned by a specific spell ID that isn't obvious, "MyDebuffType" should equal spell id.
--]]
local dispelTypes = {
    DEATHKNIGHT = {
        Frost = {}, -- specs
        Unholy = {},
        Blood = {},
    },
    DEMONHUNTER = {
        Havoc = {
            Magic = {}, -- Reverse Magic (Self, PvP)
            Offensive_Magic = {}, -- Consume Magic
        },
        Vengeance = {
            Magic = {}, -- Reverse Magic (Self, PvP)
            Offensive_Magic = {}, -- Consume Magic
        },
    },
    DRUID = { --[[ Curse, Magic, Poison? --]]
        Balance = {
            Curse = {}, -- Remove Corruption
            Offensive_Enrage = {}, -- Soothe
        }, -- specs
        Feral = {
            Curse = {}, -- Remove Corruption
            Offensive_Enrage = {}, -- Soothe
        },
        Guardian = {
            Curse = {}, -- Remove Corruption
            Offensive_Enrage = {}, -- Soothe
        },
        Restoration = {
            Curse = {}, -- Nature's Cure
            Magic = {}, -- Nature's Cure
            Offensive_Enrage = {}, -- Soothe
            Poison = {}, -- Nature's Cure

        },
    },
    HUNTER = {
        ["Beast Mastery"] = {
            Offensive_Magic = {}, -- Tranquilizing Shot
            Offensive_Enrage = {}, -- Tranquilizing Shot
        },
        Marksman = {
            Offensive_Magic = {}, -- Tranquilizing Shot
            Offensive_Enrage = {}, -- Tranquilizing Shot
        },
        Survival = {
            Disease = {}, -- Mending Bandage (PvP)
            Offensive_Magic = {}, -- Tranquilizing Shot
            Offensive_Enrage = {}, -- Tranquilizing Shot
            Poison = {}, -- Mending Bandage (PvP)
        },
    },
    MAGE = {
        Arcane = {
            Curse = {}, -- Remove Curse
            Offensive_Magic = {}, -- Spellsteal
        },
        Fire = {
            Curse = {}, -- Remove Curse
            Offensive_Magic = {}, -- Spellsteal
        },
        Frost = {
            Curse = {}, -- Remove Curse
            Offensive_Magic = {}, -- Spellsteal
        },
    },
    MONK = {
        Brewmaster = {
            Disease = {}, -- Detox
            Poison = {}, -- Detox
        },
        Mistweaver = {
            Disease = {}, -- Detox, Revival
            Magic = {}, -- Detox, Revival
            Poison = {}, -- Detox, Revival
        },
        Windwalker = {
            Disease = {}, -- Detox
            Poison = {}, -- Detox
        },
    },
    PALADIN = {
        Holy = {
            Disease = {}, -- Cleanse
            Magic = {}, -- Cleanse
            Poison = {}, -- Cleanse
        },
        Protection = {
            Disease = {}, -- Cleanse Toxins
            Poison = {}, -- Cleanse Toxins
        },
        Retribution = {
            Disease = {}, -- Cleanse Toxins
            Poison = {}, -- Cleanse Toxins
        },
    },
    PRIEST = { -- Mass Dispel Invulnerability Break
        Discipline = {
            Disease = {}, -- Purify
            Magic = {}, -- Purify
            Offensive_Magic = {}, -- Dispel Magic
        },
        Holy = {
            Disease = {}, -- Purify
            Magic = {}, -- Purify
            Offensive_Magic = {}, -- Dispel Magic
        },
        Shadow = {
            Disease = {}, -- Purify Disease
            Offensive_Magic = {}, -- Dispel Magic
        },
    },

    ROGUE = {
        Assassination = {
            Magic = {}, -- Cloak of Shadows
        },
        Combat = {
            Magic = {}, -- Cloak of Shadows
        },
        Subtlety = {
            Magic = {}, -- Cloak of Shadows
        },
    },
    SHAMAN = {
        Elemental = {
            Curse = {}, -- Cleanse Spirit
            Offensive_Magic = {}, -- Purge
        },
        Enhancement = {
            Curse = {}, -- Cleanse Spirit
            Offensive_Magic = {}, -- Purge
        },
        Restoration = {
            Curse = {}, -- Purify Spirit
            Magic = {}, -- Purify Spirit
            Offensive_Magic = {}, -- Purge
        },
    },
    WARLOCK = { -- Felhunter Offensive dispel?
        Destruction = {
            Magic = {}, -- Imp's Singe Magic
            Offensive_Magic = {}, -- Felhunter's Devour Magic
        },
        Affliction = {},
        Demonology = {},
    },
    WARRIOR = { -- Shattering Throw Invulnerability Break
        Arms = {},
        Fury = {},
        Protection = {},
    },
}

--Offensive dispel
-- warlock w felhunter?

-- Register player for talent swap, get new spec, get dispel types from list. 
-- Register pet summon for Warlocks, hunters(?)
--  PLAYER_SPECIALIZATION_CHANGED (check against nil). Newly created characters return 5 (???)
--  specID = GetSpecialization()
-- if specID then
--  specName = GetSpecializationInfo(specID)

-- register frame for UNIT_AURA "target" and "player" (gain or lose an aura) and UNIT_TARGET "player" (change target)
-- check friend or enemy
--  check debuffs on friends, buffs on enemies UnitAura("target", 1, "HELPFUL HARMFUL")
-- skip buffs/debuffs in "currently watched" array
-- check others debuff type against CLASS.SPEC[bufftype][buffid]

addon.dispelTypes = dispelTypes
