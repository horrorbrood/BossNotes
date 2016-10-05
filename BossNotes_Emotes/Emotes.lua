--[[

$Revision: 348 $

(C) Copyright 2009 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

BossNotesEmotes = LibStub("AceAddon-3.0"):NewAddon("BossNotesEmotes",
	"AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")




----------------------------------------------------------------------
-- Constants

-- Database version
BOSS_NOTES_EMOTES_DATABASE_VERSION = 1

-- Provider name
BOSS_NOTES_EMOTES_PROVIDER = "EMOTES"

-- Flags
BOSS_NOTES_EMOTES_USAGE =               0x000000ff
BOSS_NOTES_EMOTES_RAID_BOSS_EMOTE =     0x00000001
BOSS_NOTES_EMOTES_RAID_BOSS_WHISPER =   0x00000002
BOSS_NOTES_EMOTES_MONSTER_YELL =        0x00000004

-- DB defaults
local DB_DEFAULTS = {
	global = {
		npcs = { }
	}
}

-- An empty table
local EMPTY = { }


----------------------------------------------------------------------
-- Core handlers

-- One-time initialization
function BossNotesEmotes:OnInitialize ()
	-- Database
	self.db = LibStub("AceDB-3.0"):New("BossNotesEmotesDB", DB_DEFAULTS, true)
	self:MigrateDatabase(BOSS_NOTES_EMOTES_DATABASE_VERSION)
	
	-- Members
	self.npcIds = { }
	self.members = { }
end

-- Handles the (re-)enabling of this add-on
function BossNotesEmotes:OnEnable ()
	-- Register provider
	BossNotes:RegisterProvider(BOSS_NOTES_EMOTES_PROVIDER, {
		OnSources = function (instance, encounter) return self:OnSources(instance, encounter) end
	})

	-- Register events
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "HandleEmote")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_WHISPER", "HandleEmote")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "HandleEmote")
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	
end

-- Handles the disabling of this add-on
function BossNotesEmotes:OnDisable ()
	-- Unregister provider
	BossNotes:UnregisterProvider(BOSS_NOTES_EMOTES_PROVIDER)
end


----------------------------------------------------------------------
-- BossNotes provider

-- Returns the emotes source
function BossNotesEmotes:OnSources (instance, encounter)
	-- Get and sort NPC IDs
	local npcIds = BossNotes:GetNpcIds(instance, encounter)
	if #npcIds == 0 then
		return
	end
	local encounterId = encounter and encounter.encounterId
	table.sort(npcIds, function (a, b)
		if encounterId then
			if a == encounterId then
				return true
			end
			if b == encounterId then
				return false
			end
		end
		local npcA = self.db.global.npcs[a]
		local npcB = self.db.global.npcs[b]
		if npcA and npcB then
			return npcA.name < npcB.name
		end
		return npcA and not npcB
	end)
	
	-- Build HTML
	local html = { }
	local emotes = { }
	table.insert(html, "<html><body>")
	for _, npcId in ipairs(npcIds) do
		local npc = self.db.global.npcs[npcId]
		if npc then
			table.insert(html, "<h1>" .. npc.name .. "</h1>")
			table.wipe(emotes)
			for _, emote in ipairs(npc.emotes) do
				table.insert(emotes, emote)
			end
			table.sort(emotes, function (a, b)
				if a.flags < b.flags then
					return true
				end
				if a.flags > b.flags then
					return false
				end
				return a.text < b.text
			end)
			for _, emote in ipairs(emotes) do
				local color
				if bit.band(emote.flags, BOSS_NOTES_EMOTES_RAID_BOSS_EMOTE +
						BOSS_NOTES_EMOTES_RAID_BOSS_WHISPER) ~= 0 then
					color = "fedc00"
				else
					color = "fe4040"
				end
				table.insert(html, string.format("<p>|cff%s%s|r</p>",
						color, emote.text))
			end
			table.insert(html, "<br />")
		end
	end
	if #html == 1 then
		table.insert(html, "<p>" .. L["EMOTES_NOT_RECORDED"] .. "</p>")
	end
	table.insert(html, "</body></html>")
	
	return {
		title = L["EMOTES"],
		content = table.concat(html, "\n")
	}
end


----------------------------------------------------------------------
-- API

-- Returns the emotes of an NPC
function BossNotesEmotes:GetEmotes (npcId)
	local npc = self.db.global.npcs[npcId]
	return npc and npc.emotes or EMPTY
end

-- Returns the name of an NPC
function BossNotesEmotes:GetNpcName (npcId)
	local npc = self.db.global.npcs[npcId]
	return npc and npc.name
end


----------------------------------------------------------------------
-- Events

-- Handles a combat log event
function BossNotesEmotes:HandleEmote (message, msg, unitName)
	-- Get NPC ID
	local npcId = self.npcIds[unitName]
	if not npcId then
		return
	end
	
	-- Filter out empty emotes
	if string.len(msg) == 0 then
	
		return
	end
		
	-- Get (or learn) instance and encounter
	-- local instance, encounter, process = BossNotes:GetInstanceAndEncounter(unitName)
	-- if not process then
	-- print("not process")
		-- return
	-- end
	local instance, encounter, process = BossNotes:GetInstanceAndEncounter(npcId)
	if not process then
		-- Do not track NPCs until one of their spells matches one of the
		-- usage patterns. This is to prevent empty NPC entries.
		instance, encounter, process = BossNotes:GetOrLearnInstanceAndEncounter(npcId, unitName)
		if not process then
		
			return
		end
	end
	
	-- Track NPC
	local npc = self.db.global.npcs[npcId]
	if not npc then
	
		npc = {
			name = unitName,
			emotes = { }
		}
		self.db.global.npcs[npcId] = npc
	end
	
	-- Track usage
	local flags
	if message == "CHAT_MSG_RAID_BOSS_EMOTE" then

		flags = BOSS_NOTES_EMOTES_RAID_BOSS_EMOTE
	elseif message == "CHAT_MSG_RAID_BOSS_WHISPER" then
	
		flags = BOSS_NOTES_EMOTES_RAID_BOSS_WHISPER
	else

		flags = BOSS_NOTES_EMOTES_MONSTER_YELL
	end

	-- Track text, isolating player name
	local player = nil
	local count = 0
	local text = string.gsub(msg, "([^%s%p]+)", function (word)
		if self.members[word] then
			player = word
			count = count + 1
			return "%p"
		end
	end)
	
	if count > 1 then
		-- Do not process texts with multiple player names
		return
	end
	for _, emote in ipairs(npc.emotes) do
		if emote.flags == flags then
			-- Check for direct match
			if emote.text == text then
				if emote.player and player and emote.player ~= player then
					-- Validated
					emote.player = nil
				end
				return
			end
			
			-- Check for reduction match on existing emote
			if emote.player and not player and
				string.gsub(emote.text, "%%p", emote.player) == text then
				-- Replace
				emote.text = text
				emote.player = nil
				BossNotes:InvalidateContextKey(BossNotes:GetContextKey(instance, encounter))
				return
			end
			
			-- Check for reduction match on new emote
			if player and not emote.player and
					string.gsub(text, "%%p", player) == emote.text then
				-- Already tracked
				return
			end
		end
	end
	
	-- Track emote
	local emote = {
		text = text,
		flags = flags,
		player = player
	}
	table.insert(npc.emotes, emote)
	BossNotes:InvalidateContextKey(BossNotes:GetContextKey(instance, encounter))
end

-- Handles the UPDATE_MOUSEOVER_UNIT event
function BossNotesEmotes:UPDATE_MOUSEOVER_UNIT ()
	-- Map NPC names to NPC IDs for emote tracking
	local guid = UnitGUID("mouseover")
	if guid then
		local npcId = BossNotes:GetNpcId(guid)
		if npcId then
			self.npcIds[UnitName("mouseover")] = npcId
		end
	end
end

-- Handles combat log events
function BossNotesEmotes:COMBAT_LOG_EVENT_UNFILTERED (message, _, event, _, sourceGuid, sourceName, _, _, _, _, _, _, ...)
	-- Map NPC names to NPC IDs for emote tracking
	local npcId = BossNotes:GetNpcId(sourceGuid)
	if npcId then
		self.npcIds[sourceName] = npcId
	end
end

-- Handle changes in the party or raid roster
function BossNotesEmotes:PARTY_MEMBERS_CHANGED (message)
 --table.wipe(self.members)
	if (UnitInRaid("player")) then
		for i = 1, MAX_RAID_MEMBERS do
			local member = UnitName("raid" .. i)
			if member then
				self.members[member] = true
			end
		end
	else
		self.members[UnitName("player")] = true
		for i = 1, MAX_PARTY_MEMBERS do
			local member = UnitName("party" .. i)
			
			if member then
				self.members[member] = true
			end
		end
	end
end




----------------------------------------------------------------------
-- Utilities

-- Migrates the database
function BossNotesEmotes:MigrateDatabase (targetVersion)
	local version = self.db.global.databaseVersion or targetVersion

	-- Set to target version
	self.db.global.databaseVersion = version
end
