--[[

$Revision: 347 $

(C) Copyright 2009,2010 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

BossNotesPersonalNotes = LibStub("AceAddon-3.0"):NewAddon("BossNotesPersonalNotes",
	"AceEvent-3.0",
	"AceHook-3.0",
	"AceSerializer-3.0",
	"AceComm-3.0",
	"LibSchema-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")

	
----------------------------------------------------------------------
-- Constants

-- Provider name
BOSS_NOTES_PERSONAL_NOTES_PROVIDER = "PERSONAL_NOTES"

-- Database version
BOSS_NOTES_PERSONAL_NOTES_DATABASE_VERSION = 2

-- Comm prefix
BOSS_NOTES_PREFIX = "BossNotes"

-- Cache TTL
local CACHE_TTL = 300

-- Limits
local TITLE_LENGTH = 60
local CONTENT_LENGTH = 2000
local PRIVATE_CONTENT_LENGTH = 10000

-- Empty notes
local EMPTY_NOTES = {
	[""] = { }
}

-- Ace configuration options
local ACE_OPTS = {
	name = L["PERSONAL_NOTES"],
	desc = L["PERSONAL_NOTES_DESC"],
	handler = BossNotesPersonalNotes,
	type = "group",
	args = {
		allCharacters = {
			name = L["ALL_CHARACTERS"],
			desc = L["ALL_CHARACTERS_DESC"],
			order = 1,
			type = "toggle",
			get = "GetAllCharacters",
			set = "SetAllCharacters"
		},
		syndication = {
			name = L["SYNDICATION"],
			order = 2,
			type = "header"
		},
		guild = {
			name = L["GUILD"],
			order = 3,
			arg = "syndicationGuild",
			type = "toggle",
			get = "GetSyndication",
			set = "SetSyndication"
		},
		party = {
			name = L["PARTY"],
			order = 4,
			arg = "syndicationParty",
			type = "toggle",
			get = "GetSyndication",
			set = "SetSyndication"
		},
		raid = {
			name = L["RAID"],
			order = 5,
			arg = "syndicationRaid",
			type = "toggle",
			get = "GetSyndication",
			set = "SetSyndication"
		}
	}
}
BossNotes:MergeOptions("syndication", ACE_OPTS)

-- DB defaults
local DB_DEFAULTS = {
	global = {
		allCharacters = false,
		syndicationGuild = true,
		syndicationParty = true,
		syndicationRaid = true
	},
	char = {
		notes = {
		}
	}
}

-- Static poup dialog for adding a note
StaticPopupDialogs["BOSS_NOTES_PERSONAL_NOTES_ADD_NOTE"] = {
	text = L["ENTER_NOTE_NAME_PROMPT"],
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = TITLE_LENGTH,
	OnAccept = function (self)
		local text = strtrim(self.editBox:GetText())
		BossNotesPersonalNotes:SetNote(BossNotesPersonalNotes.contextSource.xNoteKey, text, nil)
		BossNotesPersonalNotes:SetNotePrivate(BossNotesPersonalNotes.contextSource.xNoteKey, text,
				BossNotesPersonalNotes.contextPrivate)
	end,
	EditBoxOnEnterPressed = function (self)
		local text = strtrim(self:GetParent().editBox:GetText())
		local notes = BossNotesPersonalNotes:GetNotes(BossNotesPersonalNotes.contextSource.xNoteKey)
		if not notes[text] then
			BossNotesPersonalNotes:SetNote(BossNotesPersonalNotes.contextSource.xNoteKey, text, nil)
			BossNotesPersonalNotes:SetNotePrivate(BossNotesPersonalNotes.contextSource.xNoteKey, text,
					BossNotesPersonalNotes.contextPrivate)
			self:GetParent():Hide()
		end
	end,
	EditBoxOnEscapePressed = function (self)
		self:GetParent():Hide()
	end,
	EditBoxOnTextChanged = function (self)
		local text = strtrim(self:GetParent().editBox:GetText())
		local notes = BossNotesPersonalNotes:GetNotes(BossNotesPersonalNotes.contextSource.xNoteKey)
		if not notes[text] then
			self:GetParent().button1:Enable();
		else
			self:GetParent().button1:Disable();
		end
	end,
	OnShow = function (self)
		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus()
	end,
	OnHide = function (self)
		ChatEdit_FocusActiveWindow()
		self.editBox:SetText("")
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}

-- Static popup dialog for confirming the removal of a note
StaticPopupDialogs["BOSS_NOTES_PERSONAL_NOTES_REMOVE_NOTE"] = {
	text = L["REMOVE_NOTE_PROMPT"],
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		BossNotesPersonalNotes:RemoveNote(BossNotesPersonalNotes.contextSource.xNoteKey,
				BossNotesPersonalNotes.contextSource.xNoteTitle)
	end,
	OnCancel = function (self) end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}


----------------------------------------------------------------------
-- Core handlers

-- One-time initialization
function BossNotesPersonalNotes:OnInitialize()
	-- Player name and class
	self.playerName = UnitName("player")
	_, self.playerClass = UnitClass("player")
	
	-- Database
	self.db = LibStub("AceDB-3.0"):New("BossNotesPersonalNotesDB", DB_DEFAULTS, true)
	if BossNotes.db.char.notes then
		-- Migration
		for key, note in pairs(BossNotes.db.char.notes) do
			note.content = note.note
			note.note = nil
			self.db.char.notes[key] = {
				[""] = note
			}
		end
		BossNotes.db.char.notes = nil
	end
	self:MigrateDatabase(BOSS_NOTES_PERSONAL_NOTES_DATABASE_VERSION)
	
	-- Persistently store the player class. This is required to properly
	-- colorize titles when showing notes from all accounts.
	self.db.char.playerClass = self.playerClass
	
	-- Schema
	self:CreateSchema()
	
	-- Cache
	self.caches = { }
	
	-- Raid roster
	self.members = { }
end

-- Handles (re-)enabling of the addon
function BossNotesPersonalNotes:OnEnable ()
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED", "RAID_ROSTER_UPDATE")
	self:RegisterComm(BOSS_NOTES_PREFIX)
	self:SecureHook("ChatEdit_InsertLink", "InsertLink")
	BossNotes:RegisterProvider(BOSS_NOTES_PERSONAL_NOTES_PROVIDER, {
		OnSources = function (instance, encounter) return self:OnSources(instance, encounter) end,
		OnRefresh = function (instance, encounter) self:OnRefresh(instance, encounter) end,
		OnClick = function (instance, encounter, source, button) self:OnClick(instance, encounter, source, button) end
	})
end

-- Handles disabling of the addon
function BossNotesPersonalNotes:OnDisable ()
	BossNotes:UnregisterProvider(BOSS_NOTES_PERSONAL_NOTES_PROVIDER)
end


----------------------------------------------------------------------
-- Event handlers

-- Handles RAID_ROSTER_UPDATE event
function BossNotesPersonalNotes:RAID_ROSTER_UPDATE ()
	-- Invalidate raid roster
	table.wipe(self.members)
	
	-- Invalildate all notes
	BossNotes:InvalidateContextKey("all")
end

-- Handles the Boss Notes sources request
function BossNotesPersonalNotes:OnSources (instance, encounter)
	local sources = { }
	
	-- Add personal notes
	local key = BossNotes:GetContextKey(instance, encounter)
	local notes = self:GetNotes(key)
	for title, note in pairs(notes) do
		local noteTitle = title
		if string.len(title) > 0 then
			title = self.playerName .. " - " .. title
		else
			title = self.playerName
		end
		table.insert(sources, {
			order = BOSS_NOTES_ORDER_PERSONAL,
			color = RAID_CLASS_COLORS[self.playerClass],
			title = title,
			tag = note.private and L["PRIVATE"],
			content = self:ColorMembers(note.content),
			placeholder = L["CLICK_TO_EDIT"],
			time = note.time,
			clientVersion = note.clientVersion,
			xNoteKey = key,
			xNoteTitle = noteTitle,
			xPrivate = note.private
		})
	end
	
	-- Add notes from other characters
	if self.db.global.allCharacters then
		for name, char in pairs(BossNotesPersonalNotesDB.char) do
			-- Do not process our own notes again.
			local charName = string.match(name, "%S+")
			if charName ~= self.playerName and char.notes
					and char.notes[key] then
				for title, note in pairs(char.notes[key]) do
					-- Only process notes with content.
					if note.content then
						local noteTitle = title
						if string.len(title) > 0 then
							title = charName .. " - " .. title
						else
							title = charName
						end
						table.insert(sources, {
							order = BOSS_NOTES_ORDER_PERSONAL + 1,
							color = RAID_CLASS_COLORS[char.playerClass],
							title = title,
							tag = note.private and L["PRIVATE"],
							content = self:ColorMembers(note.content),
							time = note.time,
							clientVersion = note.clientVersion,
							xNoteKey = key
						})
					end
				end
			end
		end
	end
	
	-- Add syndicated notes from cache
	local cache = self:GetCache(key)
	for name, player in pairs(cache.players) do
		for title, note in pairs(player.notes) do
			if string.len(title) > 0 then
				title = name .. " - " .. title
			else
				title = name
			end
			table.insert(sources, {
				order = BOSS_NOTES_ORDER_COMMUNITY,
				color = RAID_CLASS_COLORS[player.class],
				title = title,
				content = self:ColorMembers(note.content),
				time = note.time,
				clientVersion = note.clientVersion
			})
		end
	end
	
	-- Refresh asnychronously if TTL has expired
	self:RequestSources(instance, encounter, false)
	
	return sources
end

-- Handles the Boss Notes refresh request
function BossNotesPersonalNotes:OnRefresh (instance, encounter)
	self:RequestSources(instance, encounter, true)
end

-- Handles the Boss Notes click notification
function BossNotesPersonalNotes:OnClick (instance, encounter, source, button)
	if button == "LeftButton" then
		if source.xNoteKey and source.xNoteTitle then
			self:ShowEditor(instance, encounter, source,
					source.xPrivate and PRIVATE_CONTENT_LENGTH or CONTENT_LENGTH)
		end
	elseif button == "RightButton" then
		-- Setup
		self.contextSource = source
		if self.contextSource.xNoteKey and self.contextSource.xNoteTitle
				and string.len(self.contextSource.xNoteTitle) > 0 then
			self.removeNoteButton:Enable()
		else
			self.removeNoteButton:Disable()
		end

		-- Show
		local menu = BossNotesPersonalNotesContextMenu
		menu:Hide()
		local x, y = GetCursorPosition()
		menu:ClearAllPoints()
		menu:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", x, y)
		menu:Show()
		UIMenu_StartCounting(menu)
	end
end

-- Handles the loading of the context menu
function BossNotesPersonalNotes:OnLoadContextMenu (frame)
	frame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r, TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
	frame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r, TOOLTIP_DEFAULT_BACKGROUND_COLOR.g, TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
	UIMenu_Initialize(frame)
	UIMenu_AddButton(frame, L["ADD_NOTE"], nil, function ()
		self.contextPrivate = nil
		StaticPopup_Show("BOSS_NOTES_PERSONAL_NOTES_ADD_NOTE")
	end)
	UIMenu_AddButton(frame, L["ADD_PRIVATE_NOTE"], nil, function ()
		self.contextPrivate = true
		StaticPopup_Show("BOSS_NOTES_PERSONAL_NOTES_ADD_NOTE")
	end)
	UIMenu_AddButton(frame, L["REMOVE_NOTE"], nil, function ()
		StaticPopup_Show("BOSS_NOTES_PERSONAL_NOTES_REMOVE_NOTE",
				self.contextSource.title)
	end)
	UIMenu_FinishInitializing(frame)
	self.removeNoteButton = _G[frame:GetName() .. "Button3"]
end


----------------------------------------------------------------------
-- Hooks

-- Inserts a link into the Boss Notes editor
function BossNotesPersonalNotes:InsertLink (link)
	local editBox = BossNotesPersonalNotesEditorScrollFrameEditBox
	if editBox:IsVisible() and editBox:HasFocus() then
		editBox:Insert(link)
	end
end


----------------------------------------------------------------------
-- Notes management

-- Returns the personal notes for a key
function BossNotesPersonalNotes:GetNotes (key)
	if self.db.char.notes[key] then
		return self.db.char.notes[key]
	else
		return EMPTY_NOTES
	end
end

-- Sets a personal note
function BossNotesPersonalNotes:SetNote (key, title, content)
	-- Normalize content to nil if empty
	if content then
		content = strtrim(content)
		if string.len(content) == 0 then
			content = nil
		end
	end
	
	-- Set or clear, invalidating sources as needed
	local modified = false
	local notes = self.db.char.notes[key]
	if not notes then
		notes = {
			[""] = { }
		}
		self.db.char.notes[key] = notes
	end
	local note = notes[title]
	if note then
		if content ~= note.content then
			modified = true
		end
	else
		note = { }
		notes[title] = note
		modified = true
	end
	if modified then
		note.content = content
		if content then
			note.time = time()
			note.clientVersion = GetBuildInfo()
		else
			note.time = nil
			note.clientVersion = nil
		end
		BossNotes:InvalidateContextKey(key, true)
	end
end

-- Sets whether a note is private
function BossNotesPersonalNotes:SetNotePrivate (key, title, private)
	if private then
		private = true
	else
		private = nil
	end
	if self.db.char.notes[key][title].private ~= private then
		self.db.char.notes[key][title].private = private
		BossNotes:InvalidateContextKey(key, true)
	end
end
	
-- Removes a personal note
function BossNotesPersonalNotes:RemoveNote (key, title)
	-- Cannot remove default note
	if string.len(title) == 0 then
		return
	end
	
	-- Defined?
	local notes = self.db.char.notes[key]
	if not notes or not notes[title] then
		return
	end
	
	-- Remove
	notes[title] = nil
	BossNotes:InvalidateContextKey(key, true)
	
	-- Close open editor
	if self.editSource and self.editSource.xNoteKey == key
			and self.editSource.xNoteTitle == title then
		if BossNotesPersonalNotesEditor:IsShown() then
			BossNotesPersonalNotesEditor:Hide()
		end
	end
end


----------------------------------------------------------------------
-- Communications

-- Requests the sources on the network
function BossNotesPersonalNotes:RequestSources (instance, encounter, force)
	-- Request from network if TTL has expired
	local key = BossNotes:GetContextKey(instance, encounter)
	local cache = self:GetCache(key)
	local time = time()
	if time - cache.lastRequest > CACHE_TTL or force then
		-- Create message
		local request = {
			type = "request",
			key = key
		}
		local message = self:Serialize(request)
		
		-- Send
		if self.db.global.syndicationGuild and IsInGuild() then
			self:SendCommMessage(BOSS_NOTES_PREFIX, message, "GUILD")
		end
		if self.db.global.syndicationParty and UnitInParty("player") then
			self:SendCommMessage(BOSS_NOTES_PREFIX, message, "PARTY")
		end
		if self.db.global.syndicationRaid and UnitInRaid("player") then
			self:SendCommMessage(BOSS_NOTES_PREFIX, message, "RAID")
		end
	end
end

-- Handles comm messages
function BossNotesPersonalNotes:OnCommReceived (prefix, message, distribution, sender)
	-- Check distribution
	if not (distribution == "GUILD" and self.db.global.syndicationGuild or
		distribution == "PARTY" and self.db.global.syndicationParty or
		distribution == "RAID" and self.db.global.syndicationRaid) then
		return
	end
	
	-- Deserialize and validate
	local success, object = self:Deserialize(message)
	if success then
		local success, reason = self:GetSchema("Message"):Validate(object)
		if success then
			object.distribution = distribution
			object.sender = sender
			
			-- Process
			if object.type == "request" then
				self:OnCommReceivedRequest(object)
			elseif object.type == "response" then
				self:OnCommReceivedResponse(object)
			end
		else
			BossNotes:Print(string.format("Validation failed: %s", reason))
		end
	end
end

-- Handles a request
function BossNotesPersonalNotes:OnCommReceivedRequest (object)
	-- Note time of request
	local cache = self:GetCache(object.key)
	cache.lastRequest = time()
	
	-- Send response
	local notes = self:GetNotes(object.key)
	for title, note in pairs(notes) do
		if note.content and not note.private then
			-- Create message
			local response = {
				type = "response",
				key = object.key,
				class = self.playerClass,
				title = title,
				content = note.content,
				time = note.time,
				clientVersion = note.clientVersion
			}
			local message = self:Serialize(response)
			self:SendCommMessage(BOSS_NOTES_PREFIX, message, object.distribution)
		end
	end
end

-- Handles a response
function BossNotesPersonalNotes:OnCommReceivedResponse (object)
	-- Ignore our own response
	if object.sender == self.playerName then
		return
	end
	
	-- Cache response
	local modified = false
	local player = self:GetPlayer(self:GetCache(object.key), object.sender)
	if not player.class then
		player.class = object.class
		modified = true
	end
	local note = player.notes[object.title]
	if note then
		modified = modified or object.content ~= note.content
				or object.time ~= note.time
				or object.clientVersion ~= note.clientVersion
	else
		note = { }
		player.notes[object.title] = note
		modified = true
	end
	if modified then
		-- Update
		note.content = object.content
		note.time = object.time
		note.clientVersion = object.clientVersion
		
		-- Invalidate
		BossNotes:InvalidateContextKey(object.key)
	end
end

-- Returns a per-key cache
function BossNotesPersonalNotes:GetCache (key)
	local cache = self.caches[key]
	if not cache then
		cache = {
			lastRequest = 0,
			players = { }
		}
		self.caches[key] = cache
	end
	return cache
end

-- Returns a player from a cache
function BossNotesPersonalNotes:GetPlayer (cache, name)
	local player = cache.players[name]
	if not player then
		player = {
			notes = { }
		}
		cache.players[name] = player
	end
	return player
end


----------------------------------------------------------------------
-- Schema

-- Creates the message schema.
function BossNotesPersonalNotes:CreateSchema ()
	local message = self:NewSchema("Message")
	local request, response = message:Union("type", "request", "response")
	request:Field("key"):Match("^encounter:%d+$", "^instance:[%a%d]+$", "^general$")
	response:Field("key"):Match("^encounter:%d+$", "^instance:[%a%d]+$", "^general$")
	local classes = { }
	for class in pairs(RAID_CLASS_COLORS) do
		table.insert(classes, class)
	end
	response:Field("class"):Enum(unpack(classes))
	response:Field("title"):Type("string"):Length(0, TITLE_LENGTH)
	response:Field("content"):Type("string"):Length(1, CONTENT_LENGTH)
	response:Field("time"):Integer():Range(0, "*")
	response:Field("clientVersion"):Match("^%d+%.%d+%.%d+$")
end


----------------------------------------------------------------------
-- Options

-- Gets the "all characters" option.
function BossNotesPersonalNotes:GetAllCharacters (info)
	return self.db.global.allCharacters
end

-- Sets the "all notes" option.
function BossNotesPersonalNotes:SetAllCharacters (info, value)
	if value ~= self.db.global.allCharacters then
		self.db.global.allCharacters = value
		BossNotes:InvalidateContextKey("all")
	end
end
	
-- Gets a global option
function BossNotesPersonalNotes:GetSyndication (info)
	return self.db.global[info.arg]
end

-- Sets a syndication option
function BossNotesPersonalNotes:SetSyndication (info, value)
	self.db.global[info.arg] = value
end


----------------------------------------------------------------------
-- Utilities

-- Migrates the database
function BossNotesPersonalNotes:MigrateDatabase (targetVersion)
	local version = self.db.global.databaseVersion or targetVersion

	-- Migrate version 1 -> 2
	if version == 1 and targetVersion >= 2 then
		if BossNotesPersonalNotesDB.char then
			for _, char in pairs(BossNotesPersonalNotesDB.char) do
				if char.notes then
					for _, encounterNotes in pairs(char.notes) do
						if not encounterNotes[""] then
							encounterNotes[""] = { }
						end
					end
				end
			end
		end
		version = 2
		self.db.global.databaseVersion = version
	end
	
	-- Set to target version
	self.db.global.databaseVersion = version
end

-- Colorizes party or raid members with a name enclosed in double curly braces.
-- Based on a patch contributed by Valen of US-Windrunner.
function BossNotesPersonalNotes:ColorMembers (content)
	if not content then
		return content
	end

	-- Update the raid roster as needed
	if not self.members[self.playerName] then
		if (UnitInRaid("player")) then
			for i = 1, MAX_RAID_MEMBERS do 
				local name, _, subgroup = GetRaidRosterInfo(i)
				if name then
					self.members[name] = subgroup
				end
			end
		elseif GetNumGroupMembers() > 0 then
			self.members[self.playerName] = 1
			for i = 1, MAX_PARTY_MEMBERS do
				local name = UnitName("party" .. i)
				if name then
					self.members[name] = 1
				end
			end
		else
			self.members[self.playerName] = 1
		end
	end
	
	-- Colorize
	return string.gsub(content, "{{([^%s%p]+)}}", function(s)
		if self.members[s] then
			if self.members[s] <= 5 then
				return string.format("|cff00ff00%s|r", s)
			else
				return string.format("|cffff0000%s|r", s)
			end
		else
			return string.format("|cff8B8878%s|r", s)
		end
	end)
end