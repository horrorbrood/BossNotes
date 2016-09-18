--[[

$Revision: 361 $

(C) Copyright 2009,2010 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

BossNotes = LibStub("AceAddon-3.0"):NewAddon("BossNotes",
	"AceConsole-3.0",
	"AceEvent-3.0",
	"AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")
local icon = LibStub("LibDBIcon-1.0")

	
----------------------------------------------------------------------
-- Constants

-- Ace configuration options
local ACE_OPTS = {
	name = "Boss Notes",
	handler = BossNotes,
	type = "group",
	args = {
		toggle = {
			name = L["TOGGLE"],
			desc = L["TOGGLE_DESC"],
			order = 1,
			guiHidden = true,
			type = "execute",
			func = "ToggleBossNotesFrame"
		},
		options = {
			name = L["OPTIONS"],
			desc = L["OPTIONS_DESC"],
			order = 2,
			guiHidden = true,
			type = "execute",
			func = "ShowOptions",
		},
		minimap = {
			name = L["MINIMAP"],
			desc = L["MINIMAP_DESC"],
			order = 3,
			type = "toggle",
			get = "GetMinimap",
			set = "SetMinimap"
		},
		header = {
			name = L["HEADER"],
			desc = L["HEADER_DESC"],
			order = 4,
			type = "toggle",
			get = "GetHeader",
			set = "SetHeader"
		},
		learn = {
			name = L["LEARN"],
			desc = L["LEARN_DESC"],
			order = 5,
			type = "toggle",
			get = "IsLearning",
			set = "ToggleLearning"
		},
		clear = {
			name = L["CLEAR"],
			desc = L["CLEAR_DESC"],
			order = 6,
			type = "execute",
			func = "ClearLearned"
		}
	}
}

-- DB defaults
local DB_DEFAULTS = {
	global = {
		minimap = {
			hide = false
		},
		header = true,
		instanceEncounters = { },
	}
}

-- Database version
BOSS_NOTES_DATABASE_VERSION = 2

-- Bindings
BINDING_HEADER_BOSS_NOTES = L["BOSS_NOTES"]
BINDING_NAME_BOSS_NOTES = L["TOGGLE"]


----------------------------------------------------------------------
-- Core handlers

-- One-time initialization
function BossNotes:OnInitialize()
	-- Database
	self.db = LibStub("AceDB-3.0"):New("BossNotesDB", DB_DEFAULTS, true)
	self:MigrateDatabase(BOSS_NOTES_DATABASE_VERSION)
	
	-- Subsystems
	self:InitializeData()
	self:InitializeBossNotesFrame()
		
	-- Options
	LibStub("AceConfig-3.0"):RegisterOptionsTable("BossNotes", ACE_OPTS, L["SLASH_COMMANDS"])
	self.options = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("BossNotes", L["BOSS_NOTES"])

	-- LDB
	self.dataObject = LibStub("LibDataBroker-1.1"):NewDataObject("BossNotes", { 
		type = "data source",
		text = "General",
		icon = "Interface\\Icons\\INV_Misc_Note_06.blp",
		OnClick = function (frame, button)
			if button == "RightButton" then
				self:ShowOptions()
			else
				self:ToggleBossNotesFrame()
			end
		end,
		OnTooltipShow = function (tooltip)
			self:OnTooltipShow(tooltip)
		end
	})
	
	-- Minimap icon
	icon:Register("BossNotes", self.dataObject, self.db.global.minimap)
end

-- Handles (re-)enabling of the addon
function BossNotes:OnEnable ()
	-- Register
	self:RegisterMessage("BOSS_NOTES_SELECTION")
	
	-- Subsystems
	self:EnableData()
	self:EnableBossNotesFrame()
end

-- Handles disabling of the addon
function BossNotes:OnDisable ()
	-- Subsystems
	self:DisableBossNotesFrame()
	self:DisableData()
end


----------------------------------------------------------------------
-- Event handlers

-- Handles the BOSS_NOTES_SELECTION event
function BossNotes:BOSS_NOTES_SELECTION (message, instance, encounter)
	self.dataObject.text = self:GetContextText(instance, encounter)
end

-- Handles the LDB show tooltip request
function BossNotes:OnTooltipShow (tooltip)
	-- Get the selection
	local instance, encounter, source = self:GetSelection()
	if not source then
		return
	end
	
	-- Format the header line
	tooltip:AddLine(string.format(L["UI_SOURCE_ON_CONTEXT"],
			source.color.r * 255, source.color.g * 255, source.color.b * 255,
			source.title, self:GetContextText(instance, encounter)))
	tooltip:AddLine(" ")
	
	-- Try to add the tactics
	local tactics = BossNotesTactics:OnSources(instance, encounter)
	

	-- Format the note
	if tactics then
		if tactics.content then
			for line in string.gmatch(self:StripHtml(tactics.content), "[^\r\n]+") do
				local pos = 1
				local escapeLength = 0
				line = string.gsub(line, "%s*()(%S+)()", function (start, word, stop)
					local wordEscapeLength = self:GetEscapeLength(word)
					escapeLength = escapeLength + wordEscapeLength
					if stop - pos - escapeLength > 60 then
						pos = start
						escapeLength = wordEscapeLength
						return "\n" .. word
					end
				end)
				tooltip:AddLine(line)
			end
		else
			tooltip:AddLine(L["NO_NOTE"])
		end
	else
		if source.content then
			for line in string.gmatch(self:StripHtml(source.content), "[^\r\n]+") do
				local pos = 1
				local escapeLength = 0
				line = string.gsub(line, "%s*()(%S+)()", function (start, word, stop)
					local wordEscapeLength = self:GetEscapeLength(word)
					escapeLength = escapeLength + wordEscapeLength
					if stop - pos - escapeLength > 60 then
						pos = start
						escapeLength = wordEscapeLength
						return "\n" .. word
					end
				end)
				tooltip:AddLine(line)
			end
		else
			tooltip:AddLine(L["NO_NOTE"])
		end
	end
end


----------------------------------------------------------------------
-- Utilities

-- Prints a message
function BossNotes:Print (message)
	DEFAULT_CHAT_FRAME:AddMessage("|cffe76f00" .. L["BOSS_NOTES"] .. ":|r " .. message)
end

-- Removes HTML from a string.
function BossNotes:StripHtml (s)
	if string.sub(s, 1, 1) ~= "<" then
		return s
	end
	return string.gsub(s, "<[^>]+>",
			function (tag)
				if tag == "</p>" or tag == "<br />" then
					return "\n"
				else
					return ""
				end
			end)
end

-- Removes the UI escapes sequences from a string.
function BossNotes:StripUiEscapes (s)
	s = string.gsub(s, "|c%x%x%x%x%x%x%x%x", "")
	s = string.gsub(s, "|r", "")
	s = string.gsub(s, "|H.-|h", "")
	s = string.gsub(s, "|h", "")
	return s
end

-- Returns the length of the escapes contained in a string
function BossNotes:GetEscapeLength (s)
	local result = 0
	if string.find(s, "|") then
		for escape in string.gmatch(s, "|c%x%x%x%x%x%x%x%x") do
			result = result + string.len(escape)
		end
		for escape in string.gmatch(s, "|r") do
			result = result + string.len(escape)
		end
		for escape in string.gmatch(s, "(|H.-)|h") do
			result = result + string.len(escape)
		end
		for escape in string.gmatch(s, "|h") do
			result = result + string.len(escape)
		end
	end
	return result
end


----------------------------------------------------------------------
-- Utilities

-- Migrates the database
function BossNotes:MigrateDatabase (targetVersion)
	local version = self.db.global.databaseVersion or targetVersion
	
	-- Migrate version 1 -> 2
	if version == 1 and targetVersion >= 2 then
		self.db.global.instanceEncounters = { }
		self.db.global.npcs = nil
		version = 2
		self.db.global.databaseVersion = version
	end
	
	-- Set to target version
	self.db.global.databaseVersion = version
end


----------------------------------------------------------------------
-- Options

-- Merges module  options
function BossNotes:MergeOptions (key, opts)
	local order = 1
	for _, opt in pairs(ACE_OPTS.args) do
		if opt.order >= order then
			order = opt.order + 1
		end
	end
	opts.order = order
	ACE_OPTS.args[key] = opts
end

-- Shows or hides the Boss Notes frame
function BossNotes:ToggleBossNotesFrame ()
	if BossNotesFrame:IsShown() then
		HideUIPanel(BossNotesFrame)
	else
		ShowUIPanel(BossNotesFrame)
	end
end

-- Shows the options panel
function BossNotes:ShowOptions ()
	InterfaceOptionsFrame_OpenToCategory(self.options)
end

-- Returns the minimap option
function BossNotes:GetMinimap ()
	return not self.db.global.minimap.hide
end

-- Sets the minimap option
function BossNotes:SetMinimap (info, value)
	self.db.global.minimap.hide = not value
	if self.db.global.minimap.hide then
		icon:Hide("BossNotes")
	else
		icon:Show("BossNotes")
	end
end

-- Returns the header option
function BossNotes:GetHeader ()
	return self.db.global.header
end

-- Sets the header option
function BossNotes:SetHeader (info, header)
	self.db.global.header = header
end

-- Returns whether the module is learning about NPCs
function BossNotes:IsLearning (info)
	return self.learningZone
end

-- Toggles learning about NPCs
function BossNotes:ToggleLearning (info)
	if not self.learningZone then
		self.learningZone = GetRealZoneText()
		BossNotes:Print(string.format(L["START_LEARNING"], self.learningZone))
	else
		self.learningZone = nil
		BossNotes:Print(L["STOP_LEARNING"])
	end
end

-- Clears learned instance encounters
function BossNotes:ClearLearned ()
	-- Clear
	local instanceEncounters = self.db.global.instanceEncounters
	self.db.global.instanceEncounters = { }
	BossNotes:Print(L["CLEAR_LEARNED"])
	
	-- Invalidate
	for key in pairs(instanceEncounters) do
		BossNotes:InvalidateContextKey(key)
	end
end