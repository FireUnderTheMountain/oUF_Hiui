local addonName, Hiui = ...
local oUF_Hiui = LibStub("AceAddon-3.0"):GetAddon("oUF_Hiui")
local default = Hiui.custom or Hiui.default
local oUF = oUF

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local floor = floor
local strmatch = strmatch
local unpack = (table.unpack or unpack)

local _, yourClass = UnitClass("player")

--[[	Frame style functions
These functions can draw any frame and format its data according to their
style.

There's deliberately no easy way to show elements in a style that
doesn't support it. For example, "Thin" style bars are designed for pet and
target-of-target frames and therefore don't support mana/power bars. Similarly,
split level frames are quite large and show unit hostility as part of the frame
art, because they're designed to be used for your target.

Instead of forcing a style to fit your needs, you should choose another one.
--]]
function SplitLevelFrame(self, unit, screenSide)
	local splitLevel = default.splitLevel
	local subj = default[unit]
	local frame = subj.frame

	self.hiuiStyle = "splitLevel"
	local this = addonName .. unit

	if screenSide ~= "left" and screenSide ~= "right" then
		DEFAULT_CHAT_FRAME:AddMessage("Tried to initialize " .. (this or "a split level unit frame") .. " on an invalid side. Side needs to be left or right.")
	end


	--[[	Health Bar
	Some shenanigans will ensue.
	--]]
	local Health = CreateFrame("StatusBar", this .. "InvisibleHealthBar", self)

	--[[	Health Art (Border)
	Art frame keeping the health bar in check.
	--]]
	local HealthArt = Health:CreateTexture(this .. "HealthArt", "ARTWORK", nil, 2)
	HealthArt:SetTexture(splitLevel.health.art[screenSide])
	HealthArt:SetTexCoord(unpack(splitLevel.health.art.texCoord))
	HealthArt:SetPoint("TOPLEFT", self, "TOPLEFT")
	HealthArt:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")

	self.HealthArt = HealthArt



	--[[	Class Highlighting
	Provides a highlight to the top of the frame based on unit class.
	This texture necessarily needs a name to be passed to the highlighting
	function (which is currently part of an oUF tag function.)
	--]]
	local ClassHighlight = Health:CreateTexture(this .. "ClassHighlight", "ARTWORK", nil, 3)
	ClassHighlight:SetAllPoints(HealthArt)
	if screenSide == "left" then
		ClassHighlight:SetTexCoord(unpack(splitLevel.class.texCoord.left))
	else
		ClassHighlight:SetTexCoord(unpack(splitLevel.class.texCoord.right))
	end

	self.ClassHighlight = ClassHighlight



	--[[	Selection Highlighting
	Provides a highlight to the underside of the frame based on unit
	reaction. This texture necessarily needs a name to be passed to the
	highlighting function (which is currently part of an oUF tag function.)
	--]]
	local hostility = Health:CreateTexture(this .. "SelectionHighlight", "ARTWORK", nil, 3)
	hostility:SetAllPoints(HealthArt)
	if screenSide == "left" then
		hostility:SetTexCoord(unpack(splitLevel.selection.texCoord.left))
	else
		hostility:SetTexCoord(unpack(splitLevel.selection.texCoord.right))
	end

	self.SelectionHighlight = hostility



	--[[	Player Health Status Bar
	Dark bar that moves when you take damage.
	--]]
	Health:SetStatusBarTexture(splitLevel.health.bar[screenSide])
	Health:GetStatusBarTexture():SetColorTexture(0, 0, 0, 0)
	Health:GetStatusBarTexture():SetDrawLayer("BACKGROUND", -8)


	local topInset, bottomInset = -1 * floor(splitLevel.health.inset.vertical * frame.height), floor(splitLevel.health.inset.vertical * frame.height)
	local leftInset, rightInset = floor(splitLevel.health.inset.horizontal * frame.width), -1 * floor(splitLevel.health.inset.horizontal * frame.width)
	Health:SetPoint("TOPLEFT", self, "TOPLEFT", leftInset, topInset)
	Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", rightInset, bottomInset)
	-- Debugging
	--Health:GetStatusBarTexture():SetColorTexture(1, 0, 1, 1)
	if screenSide == "left" then
		Health:SetReverseFill(true);
	end
	Health.frequentUpdates = subj.frequent.health or false



	--[[	Visible Health Bar
	This bar clips its texture instead of shifting it.
	--]]
	local visibleHealthBar = Health:CreateTexture(this .. "VisibleHealthBar", "ARTWORK", nil, 1)
	visibleHealthBar:SetTexture(splitLevel.health.bar[screenSide])
	if screenSide == "left" then
		visibleHealthBar:SetPoint("TOPRIGHT", Health, "TOPRIGHT")
		visibleHealthBar:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT")
	else
		visibleHealthBar:SetPoint("TOPLEFT", Health, "TOPLEFT")
		visibleHealthBar:SetPoint("BOTTOMLEFT", Health, "BOTTOMLEFT")
	end
	self.VisibleHealthBar = visibleHealthBar

	function Health.PostUpdate(self, unit, cur, max)
		local percCur = cur/max
		local percMissing = 1 - percCur -- %percentage
		local inset = percMissing * Health:GetWidth()

		if screenSide == "left" then
			visibleHealthBar:SetTexCoord(percMissing, 1, 0, 1)
			visibleHealthBar:SetPoint("LEFT", Health, "LEFT", inset, 0)
		else
			visibleHealthBar:SetTexCoord(0, percCur, 0, 1)
			visibleHealthBar:SetPoint("RIGHT", Health, "RIGHT", -inset, 0)
		end

		-- Color the enemy background healthbar according to hostility?

		--DEFAULT_CHAT_FRAME:AddMessage("Updating Health to " .. move .. ".\nLeft: " .. visibleHealthBar:GetLeft() .. "\nRight: " .. visibleHealthBar:GetRight() .. ".")
	end



	--[[	Health Bar Background
	Bright background that's revealed as damage is taken.
	--]]
	local HealthBg = Health:CreateTexture(this .. "HealthBg", "ARTWORK", nil, -1)
	HealthBg:SetTexture(splitLevel.health.bg[screenSide])
	HealthBg:SetAllPoints(Health)

	Health.bg = HealthBg


	self.Health = Health



	--[[	Power Bar
	A colored status bar for mana/energy/rage
	--]]
	local Power = CreateFrame("StatusBar", this .. "PowerBar", self)
	Power:SetStatusBarTexture([[Interface/AddOns/Details/images/bar_flat]])

	local artSeparator = floor(6/60 * frame.height)
	Power:SetHeight(4)
	Power:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, artSeparator)
	Power:SetPoint("BOTTOMRIGHT", Health, "TOPRIGHT", 0, artSeparator)

	if screenSide == "left" then
		Power:SetReverseFill(true)
	end
	Power.frequentUpdates = subj.frequent.power or false
	Power.colorPower = true

	Power.bg = Power:CreateTexture(nil, "ARTWORK", nil)

	self.Power = Power



	--[[	Health Texts
	Both percentage and absolutes
	--]]
	local HealthPercent = Health:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	HealthPercent:SetTextColor(1, 1, 1)
	Health.perc = HealthPercent -- not a managed structure

	local HealthAbsolute = Health:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	HealthAbsolute:SetTextColor(1, 1, 1)
	self:Tag(HealthAbsolute, '[$>hiui:curhp<$]')

	Health.value = HealthAbsolute

	if screenSide == "left" then
		HealthPercent:SetPoint("BOTTOMRIGHT", Health, "RIGHT", 0, 1)
		HealthAbsolute:SetPoint("TOPRIGHT", Health, "RIGHT", 0, -1)
		self:Tag(HealthPercent, '[|cff999999$>offline<$|r    ][$>hiui:perhp<$%]')
	else
		HealthPercent:SetPoint("BOTTOMLEFT", Health, "LEFT", 0, 1)
		HealthAbsolute:SetPoint("TOPLEFT", Health, "LEFT", 0, -1)
		self:Tag(HealthPercent, '[$>hiui:perhp<$%][    |cff999999$>offline<$|r]')
	end



	--[[	Level Text
	It looks like level is part of name, but we keep it independent for frame
	positioning.

	Contains magic numbers that need fixing.

	The colored texture bordering (highlighting) is part of level only because
	of convenience.
	--]]
	local level = Health:CreateFontString(this .. "LevelText", "OVERLAY")
	level:SetFont([[Fonts\FRIZQT__.TTF]], 16, "THICKOUTLINE")
	if screenSide == "left" then
		level:SetJustifyH("RIGHT")
		level:SetPoint("TOPRIGHT", self, "CENTER", -6/377 * frame.width - 2, -6/60 * frame.height - 1)
	else
		level:SetJustifyH("LEFT")
		level:SetPoint("TOPLEFT", self, "CENTER", 6/377 * frame.width + 2, -6/60 * frame.height - 1)
	end

	level:SetTextColor(1, 1, 1)
	local diff = (unit == "player" and "" or "[difficulty]")
	local clHilite = (unit == "player" and "" or "[hiui:splitLevelClass(" .. this .. "ClassHighlight)]")
	local selHilite = (unit == "player" and "" or "[hiui:splitLevelSelection(" .. this .. "SelectionHighlight)]")
	self:Tag(level, clHilite .. selHilite .. diff .. "[level]|r")
	self.Level = level



	--[[	Name Text
	Need to find a way to color level text. Inside tag maybe?
	--]]
	local name = Health:CreateFontString(nil, "OVERLAY")
	name:SetFont([[Fonts\FRIZQT__.TTF]], 16, "THICKOUTLINE")
	name:SetTextColor(1, 1, 1)

	-- Unused because it's probably better to have consistent coloring on a transparent background.
	-- if unit == "player" then
	-- 	local reaction = ""
	-- else
	-- 	local reaction = "[hiui:reaction]"
	-- end

	if screenSide == "left" then
		name:SetJustifyH("RIGHT")
		name:SetPoint("RIGHT", level, "LEFT")

		self:Tag(name, '[$>name<$|r:]')
	else
		name:SetJustifyH("LEFT")
		name:SetPoint("LEFT", level, "RIGHT")

		self:Tag(name, '[:$>name<$|r]')
	end

	self.Name = name



	--[[	Dispel highlighting
	Highlight dispelling in an obvious way.
	--]]
	local DispelHighlight = Health:CreateTexture(nil, "OVERLAY")
	DispelHighlight.filter = true
	if screenSide == "left" then
		DispelHighlight:SetTexCoord(unpack(splitLevel.dispel.texCoord.left))
	else
		DispelHighlight:SetTexCoord(unpack(splitLevel.dispel.texCoord.right))
	end
	DispelHighlight:SetAllPoints(self)
	--DispelHighlight.DispelMagic = 
	--DispelHighlight.DispelCurse = 
	--DispelHighlight.DispelDisease =
	--DispelHighlight.DispelPoison = [[SomeTexturePath]]
	--DispelHighlight.PurgeMagic = 
	--DispelHighlight.PurgeEnrage =
	self.DispelHighlight = DispelHighlight



	--[[	NOW ENTERING. THE PLAYER. ZONE.
	ALL THE BELOW FEATURES ARE ONLY AVAILABLE TO THE PLAYER FRAME.
	--]]
	if unit == "player" then
		--[[	Class Power
				Combo/Chi/Holy Power/Runes
		--]]
		local ClassPower

		if yourClass == "PALADIN" and oUF_Hiui.db.profile.use_new_holypower then
			ClassPower = Hiui.splitLevel_HolyPower(self, this)
		else
			ClassPower = Hiui.splitLevel_DefaultClassPower(self, this)
		end

		self.ClassPower = ClassPower

		--[[ 	Druid Mana
				A temporary text field to contain druid's mana when they're in form.
		--]]
		if yourClass == "DRUID" or yourClass == "PRIEST" then
			local druidMana = Health:CreateFontString(nil, "OVERLAY")
			druidMana:SetFont([[Fonts\FRIZQT__.TTF]], 16, "THICKOUTLINE")
			druidMana:SetTextColor(1, 1, 1)

			if screenSide == "left" then
				druidMana:SetJustifyH("LEFT")
				druidMana:SetPoint("BOTTOMLEFT", Health, "BOTTOM")
			else
				druidMana:SetJustifyH("RIGHT")
				druidMana:SetPoint("BOTTOMRIGHT", Health, "BOTTOM")
			end

			self:Tag(druidMana, '[hiui:druidMana<$%]')
			self.DruidMana = druidMana
		end


		--[[	PvP/Warmode Icon
				"Badge" is populated by oUF with the icon for your pvp rank.
		--]]
		local PvPIndicator = self:CreateTexture(nil, 'OVERLAY', nil, -1)
		PvPIndicator:SetSize(30, 30)
		PvPIndicator:SetPoint("CENTER", level, "CENTER")

		local Badge = self:CreateTexture(nil, 'ARTWORK')
		Badge:SetSize(25, 26)
		Badge:SetPoint('CENTER', PvPIndicator, 'CENTER')

		PvPIndicator.Badge = Badge
		self.PvPIndicator = PvPIndicator



		--[[	Combat and Resting Icons
				These icons overlap in default UI, so I think it's okay here too.
		--]]
		local bgSquareSize = 35 -- TODO: magic number


		local restingIndicator = CreateFrame("Frame", nil, self)

		local restIconBg = restingIndicator:CreateTexture(nil, "OVERLAY", nil, 0)
		restIconBg:SetTexture([[Interface/AddOns/oUF_Hiui/textures/iconbg]])
		restIconBg:SetSize(bgSquareSize-1, bgSquareSize)

		local restIcon = restingIndicator:CreateTexture(nil, "OVERLAY", nil, 1)
		restIcon:SetTexture(130936)
		restIcon:SetTexCoord(0, 0.5, 0, 0.5)
		restIcon:SetSize(24, 24)
		restIcon:SetPoint("CENTER", restIconBg, "CENTER", -1, -3)

		restingIndicator.restIcon = restIcon
		restingIndicator.restIconBg = restIconBg
		self.RestingIndicator = restingIndicator


		local combatIndicator = CreateFrame("Frame", nil, self)

		local combatIconBg = combatIndicator:CreateTexture(nil, "OVERLAY", nil, 2)
		combatIconBg:SetTexture([[Interface/AddOns/oUF_Hiui/textures/iconbg]])
		combatIconBg:SetSize(bgSquareSize-1, bgSquareSize)

		local combatIcon = combatIndicator:CreateTexture(nil, "OVERLAY", nil, 3)
		combatIcon:SetTexture(130936)
		combatIcon:SetTexCoord(0.5, 1, 0, 0.5)
		combatIcon:SetSize(24, 24)
		combatIcon:SetPoint("CENTER", combatIconBg, "CENTER", (screenSide == "left") and 1 or -1, 0)

		combatIndicator.combatIcon = combatIcon
		combatIndicator.combatIconBg = combatIconBg
		self.CombatIndicator = combatIndicator

		if screenSide == "left" then
			restIconBg:SetPoint("TOPLEFT", self, "LEFT")
			combatIconBg:SetPoint("TOPLEFT", self, "LEFT")
		else
			restIconBg:SetPoint("TOPRIGHT", self, "RIGHT")
			combatIconBg:SetPoint("TOPRIGHT", self, "RIGHT")
		end

	end



	--[[	Finalization and Cleanup
	--]]
	self:SetSize(frame.width, frame.height)
	self.screenSide = screenSide
end

function ThinFrame(self, unit, screenSide)
	local thin = default.thin
	local subj = default[unit]
	local frame = subj.frame

	self.hiuiStyle = "thin"
	local this = addonName .. unit

	if screenSide ~= "left" and screenSide ~= "right" then
		DEFAULT_CHAT_FRAME:AddMessage("Tried to initialize " .. (this or "oUF_Hiui unit frame") .. " on an invalid side. Side needs to be left or right.")
	end


	--[[	Health Bar
	Some shenanigans will ensue.
	--]]
	local Health = CreateFrame("StatusBar", this .. "HealthBar", self)

	--[[	Health Art (Border)
	Art frame keeping the health bar in check.
	--]]
	local HealthArt = Health:CreateTexture(this .. "HealthArt", "ARTWORK", nil, 2)
	HealthArt:SetTexture(thin.health.art[screenSide])
	HealthArt:SetTexCoord(unpack(thin.health.art.texCoord))
	HealthArt:SetPoint("TOPLEFT", self, "TOPLEFT")
	HealthArt:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")



	--[[	Player Health Status Bar
	Dark bar that moves when you take damage.
	--]]
	Health:SetStatusBarTexture(thin.health.bar[screenSide])

	-- Note: all insets floored to keep the health bar as big as possible
	local topInset, bottomInset = -1 * floor(thin.health.inset.vertical * frame.height), floor(thin.health.inset.vertical * frame.height)
	local leftInset, rightInset = floor(thin.health.inset.horizontal * frame.width), -1 * floor(thin.health.inset.horizontal * frame.width)
	Health:SetPoint("TOPLEFT", self, "TOPLEFT", leftInset, topInset)
	Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", rightInset, bottomInset)

	if screenSide == "left" then
		Health:SetReverseFill(true);
	end
	Health.frequentUpdates = subj.frequent.health or false
	Health.colorHealth = false



	--[[	Health Bar Background
	Bright background that's revealed as damage is taken.
	--]]
	local HealthBg = Health:CreateTexture(this .. "HealthBg", "ARTWORK", nil, -1)
	HealthBg:SetTexture(thin.health.bg[screenSide])
	HealthBg:SetAllPoints(Health)

	Health.bg = HealthBg


	self.Health = Health



	local nameAndLevel = Health:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	if screenSide == "left" then
		nameAndLevel:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT")
		nameAndLevel:SetJustifyH("RIGHT")
	else
		nameAndLevel:SetPoint("BOTTOMLEFT", Health, "BOTTOMLEFT")
		nameAndLevel:SetJustifyH("LEFT")
	end

	nameAndLevel:SetTextColor(1, 1, 1)
	self:Tag(nameAndLevel, '[$>level<$:][name]')

	self.Name = nameAndLevel


	local HealthText = Health:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	if screenSide == "left" then
		HealthText:SetPoint("LEFT", Health, "LEFT")
		HealthText:SetJustifyH("LEFT")
	else
		HealthText:SetPoint("RIGHT", Health, "RIGHT")
		HealthText:SetJustifyH("RIGHT")
	end

	HealthText:SetTextColor(1, 1, 1)
	self:Tag(HealthText, '[|cffc41f3b$>dead<$|r][$>perhp<$%]')

	Health.value = HealthText



	--[[	Finalization and Cleanup
	--]]
	self:SetSize(frame.width, frame.height)
	self.screenSide = screenSide
end

function MiniFrame(self, unit, screenSide)
	local mini = default.mini
	local subj = default[unit]
	local frame = subj.frame

	self.hiuiStyle = "mini"
	local this = addonName .. unit

	if screenSide ~= "left" and screenSide ~= "right" then
		DEFAULT_CHAT_FRAME:AddMessage("Tried to initialize " .. this or "oUF_Hiui unit frame" .. " on an invalid side. Side needs to be left or right.")
	end


	--[[	Health Bar
	Some shenanigans will ensue.
	--]]
	local Health = CreateFrame("StatusBar", this .. "HealthBar", self)

	--[[	Health Art (Border)
	Art frame keeping the health bar in check.
	--]]
	local HealthArt = Health:CreateTexture(this .. "HealthArt", "ARTWORK", nil, 2)
	HealthArt:SetTexture(mini.health.art[screenSide])
	HealthArt:SetTexCoord(unpack(mini.health.art.texCoord))
	HealthArt:SetPoint("TOPLEFT", self, "TOPLEFT")
	HealthArt:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")



	--[[	Player Health Status Bar
	Dark bar that moves when you take damage.
	--]]
	Health:SetStatusBarTexture(mini.health.bar[screenSide])
	--Health:GetStatusBarTexture():SetColorTexture(1, 0, 1, 0.2) -- Debug

	-- Note: all insets floored to keep the health bar as big as possible
	local topInset, bottomInset = -1 * floor(mini.health.inset.vertical * frame.height), floor(mini.health.inset.vertical * frame.height)
	local leftInset, rightInset = floor(mini.health.inset.horizontal * frame.width), -1 * floor(mini.health.inset.horizontal * frame.width)
	Health:SetPoint("TOPLEFT", self, "TOPLEFT", leftInset, topInset)
	Health:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", rightInset, bottomInset)

	if screenSide == "left" then
		Health:SetReverseFill(true);
	end
	Health.frequentUpdates = subj.frequent.health or false
	Health.colorHealth = false



	--[[	Health Bar Background
	Bright background that's revealed as damage is taken.
	--]]
	local HealthBg = Health:CreateTexture(this .. "HealthBg", "ARTWORK", nil, -1)
	HealthBg:SetTexture(mini.health.bg[screenSide])
	HealthBg:SetAllPoints(Health)

	Health.bg = HealthBg


	self.Health = Health



	--local HealthText = Health:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	--if screenSide == "left" then
	--	HealthText:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT")
	--	HealthText:SetJustifyH("LEFT")
	--	self:Tag(HealthText, '[:$>hiui:perhp<$%|r]')
	--else
	--	HealthText:SetPoint("BOTTOMLEFT", Health, "BOTTOMLEFT")
	--	HealthText:SetJustifyH("RIGHT")
	--	self:Tag(HealthText, '[$>hiui:perhp<$%|r:]')
	--end

	--HealthText:SetTextColor(1, 1, 1)
	--Health.value = HealthText


	local level = Health:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	if screenSide == "left" then
		level:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT")
		level:SetJustifyH("RIGHT")
	else
		level:SetPoint("BOTTOMLEFT", Health, "BOTTOMLEFT")
		level:SetJustifyH("LEFT")
	end

	if unit == "pet" then
		self:Tag(level, '[level]')
	elseif unit == "targettarget" then
		self:Tag(level, '[raidcolor][difficulty][level]|r')
	else
		self:Tag(level, '[raidcolor][difficulty][level]|r') -- placeholder
	end

-- 	level:SetTextColor(1, 1, 1)
-- 	self.Level = level

	local arenaspec = Health:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	if screenSide == "left" then
		arenaspec:SetPoint("BOTTOMLEFT", level, "BOTTOMRIGHT")
		arenaspec:SetJustifyH("RIGHT")
		self:Tag(arenaspec, '[raidcolor][arenaspec]|r')
	else
		arenaspec:SetPoint("BOTTOMRIGHT", level, "BOTTOMLEFT")
		arenaspec:SetJustifyH("LEFT")
		self:Tag(arenaspec, '[raidcolor][arenaspec]|r')
	end

	arenaspec:SetTextColor(1, 1, 1)
	self.Spec = arenaspec




	--[[	Unit Name
	Mini frames are designed for pet, target-of-target, and other frames where
	the most important information is the name, level, and healthbar. But your
	pet's name is readily apparent in other parts of your ui, so we don't need
	to see it most of the time.
	--]]
	local name = Health:CreateFontString(nil, "OVERLAY", "GameFontNormal")

	if unit == "pet" then
		if screenSide == "left" then
			self:Tag(name, '[name<$:]')
		else
			self:Tag(name, '[:$>name]')
		end
	else
		if screenSide == "left" then
			self:Tag(name, '[hiui:reaction][name<$:]')
		else
			self:Tag(name, '[:$>hiui:reaction][name]')
		end
	end

	if screenSide == "left" then
		name:SetPoint("BOTTOMRIGHT", level, "BOTTOMLEFT")
		name:SetPoint("LEFT", Health, "LEFT")
		name:SetJustifyH("RIGHT")
	else
		name:SetPoint("BOTTOMLEFT", level, "BOTTOMRIGHT")
		name:SetPoint("RIGHT", Health, "RIGHT")
		name:SetJustifyH("LEFT")
	end
	name:SetWordWrap(false)
	name:SetTextColor(1, 1, 1)

	self.Name = name



	--[[	Finalization and Cleanup
	--]]
	self:SetSize(frame.width, frame.height)
	self.screenSide = screenSide
end

local UnitSpecific = { }
local UnitSpecific = {

	player = function(self)

		SplitLevelFrame(self, "player", "left")

	end,

	pet = function(self)

		MiniFrame(self, "pet", "left")

	end,

	target = function(self)

		SplitLevelFrame(self, "target", "right")

	end,

	targettarget = function(self)

		MiniFrame(self, "targettarget", "right")

	end,

	--[[
	Focus is a center frame and is therefore difficult to position properly. But it likely can be a mini frame.
	--]]
	focus = function(self)

		--HealthText:SetTextColor(1, 1, 1)
		--self:Tag(HealthText, '[|cffc41f3b$>dead<$|r][|cff999999$>offline<$|r][$>perhp<$%][ || $>hiui:curhp<$]')

		--Health.value = HealthText

		---- MISCELLANEOUS --
		---- Elite, Rare,
		---- Text: Name (name), Class (smartclass), Level (smartlevel), XP, group # (group)
		---- Icons: pvp (pvp), resting (resting), leader (leader)

		---- smartlevel

		---- need baby frame to anchor Text to, not self.
		--local LevelText = self:CreateFontString(nil, "OVERLAY")
		--LevelText:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
		--LevelText:SetFontObject(GameFontNormalSmall)
		--LevelText:SetTextColor(1, 1, 1)
		--self:Tag(LevelText, '[$>smartlevel<$]')

		MiniFrame(self, "focus", "left")

		self:SetSize(default.focus.frame.width, default.focus.frame.height)

	end,

	focustarget = function(self)
		return
	end,

	party = function(self)
		return
	end,

	arena = function(self)
		MiniFrame(self, "arena", "right")
	end,

	boss = function(self)
		ThinFrame(self, "boss", "right")
	end,
}

local function Shared(self, unit)
	-- Shared layout code.

	-- self:SetScript("OnEnter", UnitFrame_OnEnter)
	-- self:SetScript("OnLeave", UnitFrame_OnLeave)

	-- self:RegisterForClicks("AnyUp")

	if (UnitSpecific[unit]) then
		return UnitSpecific[unit](self)
	elseif strmatch(unit, "arena(%d)$") then
		UnitSpecific.arena(self)
	elseif strmatch(unit, "boss(%d)$") then
		UnitSpecific.boss(self)
	end
end

local blueprints = function(self)
	local function setInsets(self)
		local s = self.hiuiStyle
		if default[s].hitInsets then
			local h, v = default[s].hitInsets.horizontal * self:GetWidth(), default[s].hitInsets.vertical * self:GetHeight()
			self:SetHitRectInsets(h, h, v, v)
		else
			print("Oops no default. " .. s .. ".hitInsets!")
		end
	end


	self:SetActiveStyle("Hiui")


	local fAnch = default.focus.frame.anchor
	self:Spawn("focus", addonName .. "focusFrame"):SetPoint(fAnch.bitt, fAnch.frame, fAnch.anchor, fAnch.pos.left or -fAnch.pos.right, -fAnch.pos.top or fAnch.pos.bottom)
	self:Spawn("focustarget", "hiuiFocusTargetFrame"):Hide()


	local fAnch = default.player.frame.anchor
	local you = self:Spawn("player", addonName .. "playerFrame")
	you:SetPoint(
		fAnch.bitt, fAnch.frame, fAnch.anchor,
		fAnch.pos.left or -fAnch.pos.right, -fAnch.pos.top or fAnch.pos.bottom)
	setInsets(you)


	local pet = self:Spawn("pet", addonName .. "petFrame")
	pet:SetFrameLevel(you:GetFrameLevel()+1)
	if you.screenSide == "left" then
		pet:SetPoint("TOPLEFT", you, "BOTTOMLEFT", 0, pet:GetHeight()*0.35)
	else
		pet:SetPoint("TOPRIGHT", you, "BOTTOMRIGHT", 0, pet:GetHeight()*0.35)
	end
	setInsets(pet)


	local fAnch = default.target.frame.anchor
	local them = self:Spawn("target", addonName .. "targetFrame")
	them:SetPoint(
		fAnch.bitt, fAnch.frame, fAnch.anchor,
		fAnch.pos.left or -fAnch.pos.right, -fAnch.pos.top or fAnch.pos.bottom)
	setInsets(them)


	local tt = self:Spawn("targettarget", addonName .. "targetTargetFrame")
	tt:SetFrameLevel(them:GetFrameLevel()+1)
	if them.screenSide == "left" then
		--tt:SetPoint("TOPLEFT", them, "BOTTOMLEFT", 13/377 * them:GetWidth(), 0)
		tt:SetPoint("TOPLEFT", them, "BOTTOMLEFT", 0, tt:GetHeight()*0.35)
	else
		--tt:SetPoint("TOPRIGHT", them, "BOTTOMRIGHT",-13/377 * them:GetWidth(), 0)
		tt:SetPoint("TOPRIGHT", them, "BOTTOMRIGHT", 0, tt:GetHeight()*0.35)
	end
	setInsets(tt)


	--self:Spawn("party", "hiuiPartyFrame")
	-- oUF:SpawnHeader(overrideName, overrideTemplate, visibility, attributes ...)
	local party = self:SpawnHeader(nil, nil, 'raid,party,solo',
		-- http://wowprogramming.com/docs/secure_template/Group_Headers
		-- Set header attributes
		'showParty', true,
		'showPlayer', true,
		'yOffset', -20
	)
	party:SetPoint("RIGHT")
	-- setInsets(party) ??


	local function oldPosBossOrArena(frame, n, anchorSet, height)
		local height = height or 0
		if n < 2.5 then
			frame:SetPoint(anchorSet.bitt, anchorSet.frame, anchorSet.anchor, anchorSet.pos.left or -anchorSet.pos.right, ((n == 1 and 2) or (n == 2 and 1)) * frame.height)
		elseif n > 3.5 then
			frame:SetPoint(anchorSet.bitt, anchorSet.frame, anchorSet.anchor, anchorSet.pos.left or -anchorSet.pos.right, ((n == 4 and 1) or (n == 5 and 2)) * -frame.height)
		else
			frame:SetPoint(anchorSet.bitt, anchorSet.frame, anchorSet.anchor, anchorSet.pos.left or -anchorSet.pos.right)
		end
	end

	local Boss = {}
	do -- boss frames
		local frame = default.boss.frame
		local anch = frame.anchor
		local newAnchor = frame.defineAnchor()
		if newAnchor then anch = newAnchor end
		local MAX_BOSS_FRAMES = 5
		for n=1, MAX_BOSS_FRAMES or 5 do
			Boss[n] = self:Spawn("boss" .. n, addonName .. "BossFrame" .. n)
			setInsets(Boss[n])

			if newAnchor then
				if n == 5 then
					Boss[n]:SetPoint(anch.bitt, anch.frame, anch.anchor, anch.pos.horizontal, anch.pos.vertical)
				else
					Boss[n]:SetPoint(anch.bitt, Boss[n+1], anch.anchor)
				end
			else
				oldPosBossOrArena(Boss[n], n, anch, frame.height)
			end
		end
	end


	local Arena = {}
	do -- arena frames
		local frame = default.arena.frame
		local anch = frame.anchor
		local newAnchor = frame.defineAnchor()
		if newAnchor then anch = newAnchor end

		local MAX_ARENA_FRAMES = 5
		for n=1, MAX_ARENA_FRAMES or 5 do
			Arena[n] = self:Spawn("arena" .. n, addonName .. "arenaFrame" .. n)
			setInsets(Arena[n])

			if newAnchor then
				if n == 5 then
					Arena[n]:SetPoint(anch.bitt, anch.frame, anch.anchor, anch.pos.horizontal, anch.pos.vertical)
				else
					Arena[n]:SetPoint(anch.bitt, Arena[n+1], anch.anchor)
				end
			else
				oldPosBossOrArena(Arena[n], n, anch, frame.height)
			end
		end
	end
end

oUF:RegisterStyle("Hiui", Shared)
oUF:Factory(blueprints)
