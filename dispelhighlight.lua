--[[--------------------------------------------------------------------
	This file has been fundamentally modified from its original version
	to fit with oUF_Hiui. If you want to copy such functionality you
	may also want to look at the original from oUF_Phanx:
	https://www.wowinterface.com/downloads/info13993-oUF_Phanx.html
	https://www.curseforge.com/wow/addons/ouf-phanx
	https://github.com/Phanx/oUF_Phanx
------------------------------------------------------------------------
	Element to highlight oUF frames by dispellable debuff type.
	Originally based on oUF_DebuffHighlight by Ammo.
	Some code adapted from LibDispellable-1.0 by Adirelle.

	You may embed this module in your own layout, but please do not
	distribute it as a standalone plugin.

	Usage:
	frame.DispelHighlight = frame.Health:CreateTexture(nil, "OVERLAY")
	frame.DispelHighlight:SetAllPoints(frame.Health:GetStatusBarTexture())

	Options:
	frame.DispelHighlight.filter = true
	frame.DispelHighlight.PreUpdate = function(element) end
	frame.DispelHighlight.PostUpdate = function(element, auraType, canDispel)
	frame.DispelHighlight.Override = function(element, auraType, canDispel)
----------------------------------------------------------------------]]

if select(4, GetAddOnInfo("oUF_DebuffHighlight")) then return end

local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "DispelHighlight element requires oUF")

local _, playerClass = UnitClass("player")

local dispelTexture = {
	Curse	= ns.default.splitLevel.dispel.Curse,
	Disease	= ns.default.splitLevel.dispel.Disease,
	Magic	= ns.default.splitLevel.dispel.Magic,
	Poison	= ns.default.splitLevel.dispel.Poison,
	Enrage	= ns.default.splitLevel.purge.Enrage,
	Purge	= ns.default.splitLevel.purge.Magic,
}
local displayTexture = ns.default.splitLevel.dispel.Generic
local ally = false

local colors = oUF.colors.debuff
colors.Curse   = { 0.8, 0,   1 }
colors.Disease = { 0.8, 0.6, 0 }
colors.Magic   = { 0,   0.8, 1 }
colors.Poison  = { 0,   0.8, 0 }

local DefaultDispelPriority = { Curse = 2, Disease = 4, Magic = 1, Poison = 3 }
local ClassDispelPriority   = { Curse = 3, Disease = 1, Magic = 4, Poison = 2 }

local canDispel, canPurge, canSteal = {}, {}, nil
local auraTypeCache = {}

------------------------------------------------------------------------

local Update, ForceUpdate, Enable, Disable

function Update(self, event, unit)
	if unit ~= self.unit then return end
	local element = self.DispelHighlight
	--print("DispelHighlight Update", event, unit)

	local afflictedByType, dispellable
	local ally = UnitCanAssist("player", unit)

	if ally then
		if next(canDispel) then
			for i = 1, 40 do
				local name, _, _, afflictionType = UnitDebuff(unit, i)
				if not name then break end
				--print("UnitDebuff", unit, i, tostring(name), tostring(afflictionType))
				if afflictionType and (not afflictedByType or ClassDispelPriority[afflictionType] > ClassDispelPriority[afflictedByType]) then
					--print("afflictedByType", afflictionType)
					afflictedByType = afflictionType
					dispellable = canDispel[afflictionType]
				end
			end
		end
	elseif UnitCanAttack("player", unit) then
		if canSteal or next(canPurge) then
			for i = 1, 40 do
				local name, _, _, buffType, _, _, _, stealable, _, id = UnitBuff(unit, i)
				if not name then break end
				--print("UnitBuff", unit, i, tostring(name), tostring(buffType))
				if (canSteal and stealable) or (buffType and canPurge[buffType]) then
					--print("afflictedByType", buffType)
					afflictedByType = buffType
					dispellable = true
					break
				end
			end
		end
	end

	if auraTypeCache[unit] == afflictedByType then return end

	--print("UpdateDispelHighlight", unit, tostring(auraTypeCache[unit]), "==>", tostring(afflictedByType))
	auraTypeCache[unit] = afflictedByType

	if element.Override then
		element:Override(afflictedByType, dispellable)
		return
	end

	if element.PreUpdate then
		element:PreUpdate()
	end

	if afflictedByType and (dispellable or not element.filter) then
		if ally and afflictedByType == "Magic" then
			element:SetTexture(dispelTexture.Purge)
		else
			element:SetTexture(dispelTexture[afflictedByType])
		end
		element:SetVertexColor(unpack(colors[afflictedByType]))
		element:Show()
	else
		element:Hide()
	end

	if element.PostUpdate then
		element:PostUpdate(afflictedByType, dispellable)
	end
end

function ForceUpdate(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.DispelHighlight
	if not element then return end

	--print("Enable DispelHighlight", self.unit)

	element.__owner = self
	element.ForceUpdate = ForceUpdate

	self:RegisterEvent("UNIT_AURA", Update)

	if element.GetTexture and not element:GetTexture() then
		element:SetTexture(displayTexture)
		element:Hide()
	end

	return true
end

local function Disable(self)
	local element = self.DispelHighlight
	if not element then return end

	self:UnregisterEvent("UNIT_AURA", Update)

	element:Hide()
end

oUF:AddElement("DispelHighlight", Update, Enable, Disable)

------------------------------------------------------------------------

local function SortByPriority(a, b)
	return ClassDispelPriority[a] > ClassDispelPriority[b]
end

local f = CreateFrame("Frame")
f:RegisterEvent("SPELLS_CHANGED")
f:SetScript("OnEvent", function(self, event)
	--print("DispelHighlight", event, "Checking capabilities...")
	wipe(canDispel)
	wipe(canPurge)

		--[[ Jacked from bigwigs or testing. Prefer other format. ]]
	if IsSpellKnown(32375) or IsSpellKnown(528) or IsSpellKnown(370) or IsSpellKnown(30449) or IsSpellKnown(278326) or IsSpellKnown(19505, true) or IsSpellKnown(19801) then
		-- Mass Dispel (Priest), Dispel Magic (Priest), Purge (Shaman), Spellsteal (Mage), Consume Magic (Demon Hunter), Devour Magic (Warlock Felhunter), Tranquilizing Shot (Hunter)
		canPurge.Magic = true
	end
	if IsSpellKnown(2908) or IsSpellKnown(19801) then
		-- Soothe (Druid), Tranquilizing Shot (Hunter)
		canPurge.Enrage = true
	end
	if IsSpellKnown(527) or IsSpellKnown(77130) or IsSpellKnown(115450) or IsSpellKnown(4987) or IsSpellKnown(88423) then -- XXX Add DPS priest mass dispel?
		-- Purify (Heal Priest), Purify Spirit (Heal Shaman), Detox (Heal Monk), Cleanse (Heal Paladin), Nature's Cure (Heal Druid)
		canDispel.Magic = true
	end
	if IsSpellKnown(527) or IsSpellKnown(213634) or IsSpellKnown(115450) or IsSpellKnown(218164) or IsSpellKnown(4987) or IsSpellKnown(213644) then
		-- Purify (Heal Priest), Purify Disease (Shadow Priest), Detox (Heal Monk), Detox (DPS Monk), Cleanse (Heal Paladin), Cleanse Toxins (DPS Paladin)
		canDispel.Disease = true
	end
	if IsSpellKnown(88423) or IsSpellKnown(115450) or IsSpellKnown(218164) or IsSpellKnown(4987) or IsSpellKnown(2782) or IsSpellKnown(213644) then
		-- Nature's Cure (Heal Druid), Detox (Heal Monk), Detox (DPS Monk), Cleanse (Heal Paladin), Remove Corruption (DPS Druid), Cleanse Toxins (DPS Paladin)
		canDispel.Poison = true
	end
	if IsSpellKnown(88423) or IsSpellKnown(2782) or IsSpellKnown(77130) or IsSpellKnown(51886) or IsSpellKnown(475) then
		-- Nature's Cure (Heal Druid), Remove Corruption (DPS Druid), Purify Spirit (Heal Shaman), Cleanse Spirit (DPS Shaman), Remove Curse (Mage)
		canDispel.Curse = true
	end
	-- if playerClass == "DEATHKNIGHT" then
	-- 	canPurge.Magic    = IsPlayerSpell(58631) or nil -- Glyph of Icy Touch

	-- elseif playerClass == "DRUID" then
	-- 	canDispel.Curse   = IsSpellKnown(88423) or IsSpellKnown(2782) or nil -- Nature's Cure or Remove Corruption
	-- 	canDispel.Magic   = IsSpellKnown(88423) or nil -- Nature's Cure
	-- 	canDispel.Poison  = canDispel.Curse

	-- elseif playerClass == "HUNTER" then
	-- 	canPurge.Magic    = IsSpellKnown(19801) or nil -- Tranquilizing Shot
	-- 	canPurge.Enrage   = IsSpellKnown(19801) or nil -- Tranquilizing Shot

	-- elseif playerClass == "MAGE" then
	-- 	canDispel.Curse   = IsSpellKnown(475)   or nil -- Remove Curse
	-- 	canSteal          = IsSpellKnown(30449) or nil -- Spellsteal

	-- elseif playerClass == "MONK" then
	-- 	canDispel.Disease = IsSpellKnown(115450) or nil -- Detox
	-- 	canDispel.Magic   = IsSpellKnown(115451) or nil -- Internal Medicine
	-- 	canDispel.Poison  = canDispel.Disease

	-- elseif playerClass == "PALADIN" then
	-- 	canDispel.Disease = IsSpellKnown(4987)  or nil -- Cleanse
	-- 	canDispel.Magic   = IsSpellKnown(53551) or nil -- Sacred Cleansing
	-- 	canDispel.Poison  = canDispel.Disease

	-- elseif playerClass == "PRIEST" then
	-- 	canDispel.Disease = IsSpellKnown(527) -- Purify
	-- 	canDispel.Magic   = IsSpellKnown(527) or IsSpellKnown(32375) or nil -- Purify or Mass Dispel
	-- 	canPurge.Magic    = IsSpellKnown(528) -- Dispel Magic

	-- elseif playerClass == "SHAMAN" then		
	-- 	canDispel.Curse   = IsSpellKnown(77130) or IsSpellKnown(51886) or nil -- Cleanse Spirit or Purify Spirit)
	-- 	canDispel.Magic   = IsSpellKnown(77130) or nil -- Purify Spirit
	-- 	canPurge.Magic    = IsSpellKnown(370)   or nil -- Purge

	-- elseif playerClass == "WARLOCK" then
	-- 	canDispel.Magic   = IsSpellKnown(132411) or IsSpellKnown(115276, true) or IsSpellKnown(89808, true) or nil -- Singe Magic (Imp with Grimoire of Sacrifice) or Sear Magic (Fel Imp) or Singe Magic (Imp)
	-- 	canPurge.Magic    = IsSpellKnown(19505, true) or nil -- Devour Magic (Felhunter)

	-- elseif playerClass == "WARRIOR" then
	-- 	canPurge.Magic    = IsSpellKnown(23922) or nil -- Shield Slam
	-- end

	wipe(ClassDispelPriority)
	for spellType, priority in pairs(DefaultDispelPriority) do
		ClassDispelPriority[1 + #ClassDispelPriority] = spellType
		ClassDispelPriority[spellType] = (canDispel[spellType] and 10 or 5) - priority
	end
	table.sort(ClassDispelPriority, SortByPriority)

	NoDispels = not next(canDispel)
	NoPurge = not next(canPurge)
	--NoSteal = not canSteal
--[[
	for i, v in ipairs(ClassDispelPriority) do
		print("Can dispel " .. v .. "?", canDispel[v] and "YES" or "NO")
	end
	print("Can purge?", canPurge.Magic and "YES" or "NO")
	print("Can steal?", canSteal and "YES" or "NO")
	print("Can tranq?", canPurge.Enrage and "YES" or "NO")
--]]
	for i = 1, #oUF.objects do
		local object = oUF.objects[i]
		if object.DispelHighlight and object:IsShown() then
			Update(object, event, object.unit)
		end
	end
end)
