local oUF_Hiui = LibStub("AceAddon-3.0"):NewAddon("oUF_Hiui", "AceEvent-3.0", "AceConsole-3.0") -- AceConfigDialog-3.0 not embeddable but used.
oUF_Hiui:SetDefaultModuleState(false) -- Remember to run :Enable() on each module.
local optionsName = "oUF_Hiui Options"
oUF_Hiui.optionsName = optionsName
local db

local defaults = {
	global = {
		debug = false,
	},
	profile = {
		use_new_holypower = true
	},
	char = {},
}
--local defaults = Hiui.defaults

local options = {
	name = "oUF_hiui",
	type = "group",
	args = {
		debug = {
			order = 0,
			name = "Print verbose debugging messages.",
			type = "toggle",
			width = "full",
			get = function() return db.global.debug end,
			set = function(_, value) db.global.debug = value end,
		},
		use_new_holypower = {
			order = 1,
			name = "Use unitframe holy power",
			desc = "You must reload the UI to put this into effect.",
			type = "toggle",
			width = "full",
			get = function() return db.profile.use_new_holypower end,
			set = function(_, value) db.profile.use_new_holypower = value end,
		},
	},
}

function oUF_Hiui:CommandHandler(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionFrames.main)
		InterfaceOptionsFrame_OpenToCategory(self.optionFrames.main)
	else
		for k,v in pairs(oUF_Hiui.optionFrames) do
			if v.name:lower():find(input:lower()) then
				InterfaceOptionsFrame_OpenToCategory(v)
				InterfaceOptionsFrame_OpenToCategory(v)
				return
			end
		end
		LibStub("AceConfigCmd-3.0"):HandleCommand("oufhiui", optionsName, input)
    end
end

function oUF_Hiui:OnInitialize()
	-- Hook AceDB up to SavedVars
	self.db = LibStub("AceDB-3.0"):New("oUF_HiuiDB", defaults, "Hiui")
	db = self.db

	-- Turn profile selection into an options window
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(db)
	options.args.profiles.guiHidden = true

	LibStub("AceConfig-3.0"):RegisterOptionsTable(optionsName, options)

	-- Create a GUI for your options table.
	self.optionFrames = {}
	self.optionFrames.main = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(optionsName)
end

function oUF_Hiui:OnEnable()
	self.optionFrames.profiles = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(optionsName, tostring(options.args.profiles.name), optionsName, "profiles")

	self:RegisterChatCommand("oufhiui", "CommandHandler")
	self:RegisterChatCommand("ouf_hiui", "CommandHandler")
end

function oUF_Hiui:OnDisable()
end
