local name, addon = ...

local uiScale = 768 / UIParent:GetHeight()

local function defineBossAndArenaAnchor()
	if _G["Minimap"] then
		local minimapAnchor = {
			bitt = "BOTTOM",
			frame = "Minimap",
			anchor = "TOP",
			pos = {
				horizontal = 0,
				vertical = 0,
			},
		}
		return minimapAnchor
	end
	return nil
end

local default = {
	splitLevel = {
		health = {
			art = {
				left = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/LeftHealthArt]],
				right = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/RightHealthArt]],
				texCoord = {0, 377/512, 0, 60/64},
			},
			bar = {
				left = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/LeftHealthBar]],
				right = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/RightHealthBar]],
			},
			bg = {
				left = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/LeftHealthBg]],
				right = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/RightHealthBg]],
			},
			inset = {
				vertical = 14/60,
				horizontal = 29/377,
			},
		},
		mana = {
			upset = {
				vertical = 6/60,
				horizontal = 0,
			},
		},
		selection = {
			[ 0] = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/colors/RightHostile]],
			[ 1] = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/colors/RightUnfriendly]],
			[ 2] = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/colors/RightNeutral]],
			[ 3] = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/colors/RightFriendly]],
			[ 4] = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/colors/RightPlayerSimple]],
			[ 5] = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/colors/RightPlayerExtended]],
			[ 6] = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/colors/RightParty]],
			[ 7] = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/colors/RightPartyPvp]],
			[ 8] = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/colors/RightFriend]],
			[ 9] = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/colors/RightDead]],
			[10] = "", -- COMMENTATOR_TEAM_1, unavailable to players
			[11] = "", -- COMMENTATOR_TEAM_2, unavailable to players
			[12] = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/colors/RightSelf]],
			[13] = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/colors/RightBattlegroundFriendlyPvp2]],
			texCoord = {
				left = {377/512, 0, 0, 60/64},
				right = {0, 377/512, 0, 60/64},
			},
		},
		class = {
			DEATHKNIGHT = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/classes/RightDeathKnight]],
			DEMONHUNTER = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/classes/RightDemonHunter]],
			DRUID = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/classes/RightDruid]],
			HUNTER = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/classes/RightHunter]],
			PALADIN = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/classes/RightPaladin]],
			PRIEST = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/classes/RightPriest]],
			MAGE = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/classes/RightMage]],
			MONK = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/classes/RightMonk]],
			ROGUE = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/classes/RightRogue]],
			SHAMAN = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/classes/RightShaman]],
			WARLOCK = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/classes/RightWarlock]],
			WARRIOR = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/classes/RightWarrior]],
			texCoord = {
				left = {377/512, 0, 0, 60/64},
				right = {0, 377/512, 0, 60/64},
			},
		},
		dispel = {
			Curse = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/afflictions/RightGeneric]],
			Disease = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/afflictions/RightGeneric]],
			Magic = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/afflictions/RightGeneric]],
			Poison = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/afflictions/RightPoison]],
			Generic = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/afflictions/RightGeneric]],
			texCoord = {
				left = {377/512, 0, 0, 60/64},
				right = {0, 377/512, 0, 60/64},
			},
		},
		purge = {
			Enrage = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/afflictions/RightGeneric]],
			Magic = [[Interface/AddOns/oUF_Hiui/textures/splitLevel/afflictions/RightGeneric]],
			texCoord = {
				left = {377/512, 0, 0, 60/64},
				right = {0, 377/512, 0, 60/64},
			},
		},
		hitInsets = { -- reduce the clickable area of the frame.
			vertical = 9/60,
			horizontal = 19/377,
		},
	},
	thin = {
		health = {
			art = {
				left = [[Interface/AddOns/oUF_Hiui/textures/thin/OmniHealthArt]],
				right = [[Interface/AddOns/oUF_Hiui/textures/thin/OmniHealthArt]],
				texCoord = {0, 252/256, 0, 36/64},
			},
			bar = {
				left = [[Interface/AddOns/oUF_Hiui/textures/thin/OmniHealthBar]],
				right = [[Interface/AddOns/oUF_Hiui/textures/thin/OmniHealthBar]],
			},
			bg = {
				left = [[Interface/AddOns/oUF_Hiui/textures/thin/OmniHealthBg]],
				right = [[Interface/AddOns/oUF_Hiui/textures/thin/OmniHealthBg]],
			},
			inset = {
				vertical = 10/36,
				horizontal = 29/252,
			},
		},
		mana = {
			upset = {
				vertical = 6/36,
				horizontal = 0,
			},
		},
		hitInsets = { -- 
			vertical = 8/60,
			horizontal = 18/377,
		},
	},
	mini = {
		health = {
			art = {
				left = [[Interface/AddOns/oUF_Hiui/textures/mini/OmniHealthArt]],
				right = [[Interface/AddOns/oUF_Hiui/textures/mini/OmniHealthArt]],
				texCoord = {0, 145/256, 0, 36/64},
			},
			bar = {
				left = [[Interface/AddOns/oUF_Hiui/textures/mini/OmniHealthBar]],
				right = [[Interface/AddOns/oUF_Hiui/textures/mini/OmniHealthBar]],
			},
			bg = {
				left = [[Interface/AddOns/oUF_Hiui/textures/mini/OmniHealthBg]],
				right = [[Interface/AddOns/oUF_Hiui/textures/mini/OmniHealthBg]],
			},
			inset = {
				vertical = 10/36,
				horizontal = 29/145,
			},
		},
		mana = {
			upset = {
				vertical = 6/36,
				horizontal = 0,
			},
		},
		hitInsets = { -- 
			vertical = 8/60,
			horizontal = 18/377,
		},
	},
	player = {
		frequent = {
			health = true,
			power = true,
		},
		frame = {
			width = 377 / uiScale,
			height = 60 / uiScale,
			anchor = {
				bitt = "TOPLEFT",
				frame = "UIParent",
				anchor = "TOPLEFT",
				pos = {
					top = ceil(16 / uiScale),
					bottom = nil,
					left = ceil(215 / uiScale),
					right = nil,
				},
			},
		},
		create = function() return end,
	},
	target = {
		frequent = {
			health = true,
			power = true,
		},
		frame = {
			width = 377 / uiScale,
			height = 60 / uiScale,
			anchor = {
				bitt = "TOPRIGHT",
				frame = "UIParent",
				anchor = "TOPRIGHT",
				pos = {
					top = ceil(16 / uiScale),
					bottom = nil,
					left = nil,
					right = ceil(215 / uiScale),
				},
			},
		},
	},
	pet = {
		frequent = {
			health = true,
			power = true,
		},
		frame = {
			width = ceil(145 / uiScale), -- 33.72% of player
			height = ceil(36 / uiScale),
			-- health = 20
			anchor = {
				bitt = "TOPLEFT",
				frame = "oUF_HiuiplayerFrame",
				anchor = "BOTTOMLEFT",
				pos = {
					top = 0,
					bottom = nil,
					left = 29/377,
					right = nil,
				},
			},
		},
	},
	targettarget = {
		frequent = {
			health = true,
			power = false,
		},
		frame = {
			width = ceil(145 / uiScale),
			height = ceil(36 / uiScale),
			-- health = 20
			anchor = {
				bitt = "TOPLEFT",
				frame = "oUF_HiuitargetFrame",
				anchor = "BOTTOMLEFT",
				pos = {
					top = 0,
					bottom = nil,
					left = 29/377,
					right = nil,
				},
			},
		},
	},
	focus = {
		frequent = {
			health = true,
			power = false,
		},
		frame = {
			width = ceil(147.927 / uiScale), -- original 220
			height = ceil(39 / uiScale), -- original 58
			anchor = {
				bitt = "TOP",
				frame = "UIParent",
				anchor = "TOP",
				pos = {
					top = ceil(16 / uiScale),
					bottom = nil,
					left = 0,
					right = nil,
				},
			},
		},
	},
	boss = {
		frequent = {
			health = false,
			power = true,
		},
		frame = {
			width = ceil(145 / uiScale),
			height = ceil(35 / uiScale),
			-- health = 20
			anchor = {
				bitt = "RIGHT",
				frame = "UIParent",
				anchor = "RIGHT",
				pos = {
					top = 0,
					bottom = nil,
					--left = 29/377,
					left = 0,
					right = nil,
				},
			},
			defineAnchor = defineBossAndArenaAnchor,
		},
	},
	arena = {
		frequent = {
			health = true,
			power = false,
		},
		frame = {
			width = ceil(145 / uiScale),
			height = ceil(35 / uiScale),
			-- health = 20
			anchor = {
				bitt = "RIGHT",
				frame = "UIParent",
				anchor = "RIGHT",
				pos = {
					top = 0,
					bottom = nil,
					left = 0,
					right = nil,
				},
			},
			defineAnchor = defineBossAndArenaAnchor,
		},
	},
}

addon.default = default
