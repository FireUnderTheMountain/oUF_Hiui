local addonName, addon = ...
-- local siValue = function(val)
-- 	if(val >= 1e6) then
-- 		return ('%.1f'):format(val / 1e6):gsub('%.', 'm')
-- 	elseif(val >= 1e4) then
-- 		return ("%.1f"):format(val / 1e3):gsub('%.', 'k')
-- 	else
-- 		return val
-- 	end
-- end

--local tags = oUF.Tags.Methods or oUF.Tags -- legacy
--local tagevents = oUF.TagEvents or oUF.Tags.Events -- legacy
local oUF = oUF
local tags = oUF.Tags.Methods
local tagevents = oUF.Tags.Events
local sharedevents = oUF.Tags.SharedEvents
--[[ Should an event fire without unit information, then it should also be listed
in the `oUF.Tags.SharedEvents` table as follows: `oUF.Tags.SharedEvents.EVENT_NAME = true`. --]]
local colors = oUF.colors

local function Hex(r, g, b)
	if(type(r) == 'table') then
		if(r.r) then
			r, g, b = r.r, r.g, r.b
		else
			r, g, b = unpack(r)
		end
	end
	return string.format('|cff%02x%02x%02x', r * 255, g * 255, b * 255)
end



tags['hiui:curhp'] = function(u)
	local uh = UnitHealth(u)

	if uh >= 1e6 then
		return ('%.1f'):format(uh / 1e6):gsub('%.0', ''):gsub('$', 'm')
	elseif uh >= 1e4 then
		return ("%.1f"):format(uh / 1e3):gsub('%.0', ''):gsub('$', 'k')
	elseif uh > 0 then
		return uh
	else
		return "0"
	end
end
tagevents['hiui:curhp'] = tagevents.curhp


tags['hiui:perhp'] = function(u)
	local m = UnitHealthMax(u)
	local h = UnitHealth(u)
	if m == 0 then
		return "|cffc41f3b0"
	else
		return math.floor(UnitHealth(u) / m * 100 + .5)
	end
end
tagevents['hiui:perhp'] = tagevents.perhp


tags['hiui:reaction'] = function(u)
	local s = UnitSelectionType(u, true)

	--if u.parent.hiuiStyle ~= "splitLevel" then
		return Hex(unpack(colors.selection[s]))
	--end
end
tagevents['hiui:reaction'] = tagevents.difficulty


--[[	splitLevel Frame hostility color.
Runtime determination is costly, so you'll get spammed with lua errors
if frame is not splitLevel. That's on you.
--]]
tags['hiui:splitLevelSelection'] = function(u, _, f, elem)
	local s = UnitSelectionType(u, false)
	_G[f][elem]:SetTexture(addon.default.splitLevel.selection[s])

	return nil
end
tagevents['hiui:splitLevelSelection'] = "UNIT_FACTION GROUP_ROSTER_UPDATE"
-- UNIT_CONNECTION UNIT_HEALTH for offline detection


--[[	splitLevel Frame class color.
Runtime determination is costly, so you'll get spammed with lua errors
if frame is not splitLevel. That's on you.
--]]
tags['hiui:splitLevelClass'] = function(u, _, f, elem)
	local n = nil

	if UnitIsPlayer(u) then
		local _, cl = UnitClass(u)
		n = addon.default.splitLevel.class[cl]
	end

	_G[f][elem]:SetTexture(n)

	return nil
end
tagevents['hiui:splitLevelClass'] = "UNIT_CLASSIFICATION_CHANGED GROUP_ROSTER_UPDATE"


--[[	Druid Mana
This doesn't exist for some reason.
We don't test for unit == player here because it's costly; instead check when
creating the element. Only the player has "druid mana" so check for both unit and class when making it.
--]]
tags['hiui:druidMana'] = function(unit)
	if UnitInVehicle(unit) then return end

	local mana = Enum.PowerType.Mana

	if UnitPowerType(unit) == mana then return end
	--if unit ~= "player" or powerType == 0 (mana) then return end

	return floor(UnitPower(unit, mana)/UnitPowerMax(unit, mana) * 100 + 0.5)
end
tagevents['hiui:druidMana'] = "UNIT_POWER_UPDATE UNIT_MAXPOWER UNIT_DISPLAYPOWER"


--tags['hiui:arenaclass'] = function(u)
--end
--tagevents['hiui:arenaclass'] = tagevents.arenaspec

tags['hiui:petname'] = function(u)
end
tagevents['hiui:petname'] = tagevents.name
