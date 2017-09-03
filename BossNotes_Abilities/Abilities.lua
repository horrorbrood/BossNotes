--[[

$Revision: 365 $

(C) Copyright 2009,2011 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

BossNotesAbilities = LibStub("AceAddon-3.0"):NewAddon("BossNotesAbilities",
	"AceEvent-3.0",
	"AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")
local FILTERED_NPC_IDS = {
	[416] = true, --"Imp"
	[510] = true,   -- Water Elemental
	[2523] = true,  -- Searing Totem
	[2630] = true,  -- Earthbind Totem\
	[3527] = true,	--Healing Stream
	[5929] = true,  -- Magma Totem
	[5950] = true,  -- Flametongue Totem
	[15438] = true, -- Greater Fire Elemental
	[15439] = true, -- Fire Elemental Totem
	[19668] = true, -- Shadowfiend
	[24207] = true, -- Army of the Dead Ghoul
	[26125] = true, -- Risen Ghoul
	[27829] = true, -- Ebon Gargoyle
	[27893] = true, -- Rune Weapon
	[28017] = true, -- Bloodworm
	[28306] = true, -- Anti-Magic Zone
	[29264] = true, -- Spirit Wolf
	[29998] = true, -- Desecrated Ground V
	[31165] = true, -- Searing Totem X
	[31185] = true, -- Healing Stream Totem IX
	[31216] = true, -- Mirror Image
	[31167] = true, -- Magma Totem VII
	[32775] = true, -- Fire Nova Totem IX
	[33753] = true, -- Desecrated Ground IV
	[35642] = true, -- Jeeves
	[46157] = true, -- Hand of Gul'dan
	[46954] = true, -- Shadowy Apparition
	[47244] = true,  -- Mirror Image
	[53006] = true,	--Spirit Link totem
	[55659] = true,	--wild imp
	[59764] = true,	--Healing Tide Totem
	[60561] = true,	--Earthgrab Totem
	[61146] = true, --black ox
	[63508] = true, --Xuen
	[78001] = true,	--cloudburst totem
	[78116] = true, --water elemental
	[95255] = true,	--Earthquake Totem
	[97369] = true,	--magma totem
	[91245] = true,	--Lightning Surge Totem
	[97285] = true,	--wind rush totem
	[100099] = true,	--Voodoo Totem
	[100820] = true, --"Spirit Wolf"
	[100943] = true,	--Earthen Shield Totem
	[102392] = true,	--Resonace Totem
	[113845] = true,	--totem mastery
	[104818] = true,	--Ancestral Protection Totem
	[106317] = true,	--Storm totem
	[106319] = true,	--Ember Totem
	[106321] = true	--tailwind totem



	
	
	
}

----------------------------------------------------------------------
-- Constants

-- Database version
BOSS_NOTES_ABILITIES_DATABASE_VERSION = 3

-- Provider name
BOSS_NOTES_ABILITIES_PROVIDER = "ABILITIES"

-- Flags
BOSS_NOTES_ABILITIES_DIFFICULTY =                 0x000000ff
BOSS_NOTES_ABILITIES_USAGE =                      0x0000ff00
BOSS_NOTES_ABILITIES_CAST =                       0x00000100
BOSS_NOTES_ABILITIES_BUFF =                       0x00000200
BOSS_NOTES_ABILITIES_DEBUFF =                     0x00000400
BOSS_NOTES_ABILITIES_AURA =                       0x00000600
BOSS_NOTES_ABILITIES_STACK =                      0x00000800

-- Suffixes
BOSS_NOTES_ABILITIES_DAMAGE =                     0x00000001
BOSS_NOTES_ABILITIES_MISSED =                     0x00000002
BOSS_NOTES_ABILITIES_HEAL =                       0x00000004
BOSS_NOTES_ABILITIES_ENERGIZE =                   0x00000008
BOSS_NOTES_ABILITIES_DRAIN =                      0x00000010
BOSS_NOTES_ABILITIES_LEECH =                      0x00000020
BOSS_NOTES_ABILITIES_INTERRUPT =                  0x00000040
BOSS_NOTES_ABILITIES_DISPEL =                     0x00000080
BOSS_NOTES_ABILITIES_DISPEL_FAILED =              0x00000100
BOSS_NOTES_ABILITIES_STOLEN =                     0x00000200
BOSS_NOTES_ABILITIES_EXTRA_ATTACKS =              0x00000400
BOSS_NOTES_ABILITIES_AURA_APPLIED =               0x00000800
BOSS_NOTES_ABILITIES_AURA_REMOVED =               0x00001000
BOSS_NOTES_ABILITIES_AURA_APPLIED_DOSE =          0x00002000
BOSS_NOTES_ABILITIES_AURA_REMOVED_DOSE =          0x00004000
BOSS_NOTES_ABILITIES_AURA_REFRESH =               0x00008000
BOSS_NOTES_ABILITIES_AURA_BROKEN =                0x00010000
BOSS_NOTES_ABILITIES_AURA_BROKEN_SPELL =          0x00020000
BOSS_NOTES_ABILITIES_CAST_START =                 0x00040000
BOSS_NOTES_ABILITIES_CAST_SUCCESS =               0x00080000
BOSS_NOTES_ABILITIES_CAST_FAILED =                0x00100000
BOSS_NOTES_ABILITIES_INSTAKILL =                  0x00200000
BOSS_NOTES_ABILITIES_DURABILITY_DAMAGE =          0x00400000
BOSS_NOTES_ABILITIES_DURABILITY_DAMAGE_ALL =      0x00800000
BOSS_NOTES_ABILITIES_CREATE =                     0x01000000
BOSS_NOTES_ABILITIES_SUMMON =                     0x02000000
BOSS_NOTES_ABILITIES_RESURRECT =                  0x04000000

-- Ace configuration options
local ACE_OPTS = {
	name = L["ABILITIES"],
	desc = L["ABILITIES_DESC"],
	handler = BossNotesAbilities,
	type = "group",
	args = {
		tooltipInfo = {
			name = L["TOOLTIP_INFO"],
			desc = L["TOOLTIP_INFO_DESC"],
			order = 1,
			type = "toggle",
			get = "IsTooltipInfo",
			set = "SetTooltipInfo"
		}
	}
}
BossNotes:MergeOptions("abilities", ACE_OPTS)

-- DB defaults
local DB_DEFAULTS = {
	global = {
		tooltipInfo = true,
		npcs = { }
	}
}

-- Tracked usages. We explicity do not track SPELL_HEAL as this would cause
-- spells such as the warlock Haunt spell to be tracked. Also, we do not
-- track SPELL_AURA_REMOVED as this would associate player spells with
-- NPCs that remove beneficial auras when controlling a player.
local EVENT_USAGES = {
	SPELL_DAMAGE = BOSS_NOTES_ABILITIES_CAST,
	SPELL_MISSED =  BOSS_NOTES_ABILITIES_CAST,
	SPELL_ENERGIZE =  BOSS_NOTES_ABILITIES_CAST,
	SPELL_DRAIN =  BOSS_NOTES_ABILITIES_CAST,
	SPELL_LEECH =  BOSS_NOTES_ABILITIES_CAST,
	SPELL_EXTRA_ATTACKS =  BOSS_NOTES_ABILITIES_CAST,
	SPELL_CAST_START =  BOSS_NOTES_ABILITIES_CAST,
	SPELL_CAST_SUCCESS =  BOSS_NOTES_ABILITIES_CAST,
	SPELL_CAST_FAILED =  BOSS_NOTES_ABILITIES_CAST,
	SPELL_AURA_APPLIED =  BOSS_NOTES_ABILITIES_AURA,
	SPELL_AURA_APPLIED_DOSE =  BOSS_NOTES_ABILITIES_STACK,
	SPELL_SUMMON = BOSS_NOTES_ABILITIES_CAST
}

-- Tracked suffixes
local PREFIX_STRINGS = {
	"SPELL",
	"SPELL_PERIODIC"
}
local SUFFIXES = {
	DAMAGE = BOSS_NOTES_ABILITIES_DAMAGE,
	MISSED = BOSS_NOTES_ABILITIES_MISSED,
	HEAL = BOSS_NOTES_ABILITIES_HEAL,
	ENERGIZE = BOSS_NOTES_ABILITIES_ENERGIZE,
	DRAIN = BOSS_NOTES_ABILITIES_DRAIN,
	LEECH = BOSS_NOTES_ABILITIES_LEECH,
	INTERRUPT = BOSS_NOTES_ABILITIES_INTERRUPT,
	DISPEL = BOSS_NOTES_ABILITIES_DISPEL,
	DISPEL_FAILED = BOSS_NOTES_ABILITIES_DISPEL_FAILED,
	STOLEN = BOSS_NOTES_ABILITIES_STOLEN,
	EXTRA_ATTACKS = BOSS_NOTES_ABILITIES_EXTRA_ATTACKS,
	AURA_APPLIED = BOSS_NOTES_ABILITIES_AURA_APPLIED,
	AURA_REMOVED = BOSS_NOTES_ABILITIES_AURA_REMOVED,
	AURA_APPLIED_DOSE = BOSS_NOTES_ABILITIES_AURA_APPLIED_DOSE,
	AURA_REMOVED_DOSE = BOSS_NOTES_ABILITIES_AURA_REMOVED_DOSE,
	AURA_REFRESH = BOSS_NOTES_ABILITIES_AURA_REFRESH,
	AURA_BROKEN = BOSS_NOTES_ABILITIES_AURA_BROKEN,
	AURA_BROKEN_SPELL = BOSS_NOTES_ABILITIES_AURA_BROKEN_SPELL,
	CAST_START = BOSS_NOTES_ABILITIES_CAST_START,
	CAST_SUCCESS = BOSS_NOTES_ABILITIES_CAST_SUCCESS,
	CAST_FAILED = BOSS_NOTES_ABILITIES_CAST_FAILED,
	INSTAKILL = BOSS_NOTES_ABILITIES_INSTAKILL,
	DURABILITY_DAMAGE = BOSS_NOTES_ABILITIES_DURABILITY_DAMAGE,
	DURABILITY_DAMAGE_ALL = BOSS_NOTES_ABILITIES_DURABILITY_DAMAGE_ALL,
	CREATE = BOSS_NOTES_ABILITIES_CREATE,
	SUMMON = BOSS_NOTES_ABILITIES_SUMMON,
	RESURRECT = BOSS_NOTES_ABILITIES_RESURRECT
}
local EVENT_SUFFIXES = { }
for _, prefixString in ipairs(PREFIX_STRINGS) do
	for suffixString, suffix in pairs(SUFFIXES) do
		EVENT_SUFFIXES[prefixString .. "_" .. suffixString] = suffix
	end
end


----------------------------------------------------------------------
-- Core handlers

-- One-time initialization
function BossNotesAbilities:OnInitialize ()
	-- Database
	self.db = LibStub("AceDB-3.0"):New("BossNotesAbilitiesDB", DB_DEFAULTS, true)
	self:MigrateDatabase(BOSS_NOTES_ABILITIES_DATABASE_VERSION)
end

-- Handles the (re-)enabling of this add-on
function BossNotesAbilities:OnEnable ()
	-- Register provider
	BossNotes:RegisterProvider(BOSS_NOTES_ABILITIES_PROVIDER, {
		OnSources = function (instance, encounter) return self:OnSources(instance, encounter) end
	})

	-- Register events
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	
	
	-- Hooks
	self:HookScript(GameTooltip, "OnTooltipSetUnit")
end

-- Handles the disabling of this add-on
function BossNotesAbilities:OnDisable ()
	-- Unregister provider
	BossNotes:UnregisterProvider(BOSS_NOTES_ABILITIES_PROVIDER)
end


----------------------------------------------------------------------
-- BossNotes provider

-- Returns the abilities note
function BossNotesAbilities:OnSources (instance, encounter)
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
	local html = { }
	local difficulty = self:GetDifficulty(instance and instance.raid)
	table.insert(html, "<html><body>")
	for _, npcId in ipairs(npcIds) do
		local npc = self.db.global.npcs[npcId]	
		
		--end
		if npc then
			-- Get and sort spells
			local spells = { }
			for _, spell in pairs(npc.spells) do
				if bit.band(spell.flags, difficulty) ~= 0 then
					table.insert(spells, spell)
				end
			end
			
			-- Add NPC to HTML if there is at least one spell
			if #spells > 0 then
				table.sort(spells, function (a, b)
					return a.name < b.name
				end)
				table.insert(html, "<h1>" .. npc.name .. "</h1>")
				for _, spell in ipairs(spells) do
					local line = string.format(L["SPELL"], spell.spellId, spell.name)
					local usage = { }
					if bit.band(spell.flags, BOSS_NOTES_ABILITIES_CAST) ~= 0 then
						table.insert(usage, L["CAST"])
					end
					if bit.band(spell.flags, BOSS_NOTES_ABILITIES_BUFF) ~= 0 then
						table.insert(usage, L["BUFF"])
					end
					if bit.band(spell.flags, BOSS_NOTES_ABILITIES_DEBUFF) ~= 0 then
						table.insert(usage, L["DEBUFF"])
					end
					if bit.band(spell.flags, BOSS_NOTES_ABILITIES_STACK) ~= 0 then
						table.insert(usage, L["STACK"])
					end
					if #usage > 0 then
						line = line .. " (" .. table.concat(usage, ", ") .. ")"
					end
					table.insert(html, "<p>" .. line .. "</p>")
				end
				table.insert(html, "<br />")
			end
		end
	end
	if #html == 1 then
		table.insert(html, "<p>" .. L["ABILITIES_NOT_RECORDED"] .. "</p>")
	end
	table.insert(html, "</body></html>")
	
	return {
		title = L["ABILITIES"],
		content = table.concat(html, "\n"),
		showHyperlinkTooltip = true,
		chatSafe = true
	}
end


----------------------------------------------------------------------
-- API

-- Returns the spells of an NPC.
function BossNotesAbilities:GetSpells (npcId)
	local spells = { }
	local npc = self.db.global.npcs[npcId]
	if npc then
		for _, spell in pairs(npc.spells) do
			table.insert(spells, spell)
		end
	end
	return spells
end

-- Returns the name of an NPC.
function BossNotesAbilities:GetNpcName (npcId)
	local npc = self.db.global.npcs[npcId]
	return npc and npc.name
end

-- Returns the supported suffixes mapped by suffix strings.
function BossNotesAbilities:GetSuffixes ()
	return SUFFIXES
end

-- Returns the supported suffixes mapped by event strings.
function BossNotesAbilities:GetEventSuffixes ()
	return EVENT_SUFFIXES
end


----------------------------------------------------------------------
-- Events

-- Handles a combat log event
function BossNotesAbilities:COMBAT_LOG_EVENT_UNFILTERED (message, timestamp,
		event, hideCaster, sourceGuid, sourceName, sourceFlags,
		sourceRaidFlags, destGuid, destName, destFlags, destRaidFlags, ...)
	-- Check event
	local usage = EVENT_USAGES[event]
	local suffix = EVENT_SUFFIXES[event]
	
	-- Check unit affiliation
	if bit.band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) ~= COMBATLOG_OBJECT_AFFILIATION_OUTSIDER then
		return
	end

	-- Check unit NPC ID
	local npcId = BossNotes:GetNpcId(sourceGuid)
	if not npcId then
		return
	end
	if FILTERED_NPC_IDS[npcId] then
				return
	end
	-- Get (or learn) instance and encounter
	local instance, encounter, process = BossNotes:GetInstanceAndEncounter(npcId)
	if not process then
		-- Do not track NPCs until one of their spells matches one of the
		-- usage patterns. This is to prevent empty NPC entries.
		if not usage then
			return
		end
		instance, encounter, process = BossNotes:GetOrLearnInstanceAndEncounter(npcId, sourceName)
		if not process then
			return
		end
	end
	
	-- Track NPC
	local npc = self.db.global.npcs[npcId]
	if not npc then
		npc = {
			name = sourceName,
			spells = { }
		}
		self.db.global.npcs[npcId] = npc
	end
	
	-- Track spell
	local spellId = select(1, ...)
	local spellName = select(2, ...)
	local spell = npc.spells[spellId]
	if not spell then
		-- Do not track a spell unless it matches one of the usage patterns.
		-- This is to prevent the tracking of spells such as Haunt, which are
		-- reported as a SPELL_HEAL from the NPC to the player.
		if not usage then
			return
		end
		spell = {
			spellId = spellId,
			name = spellName,
			flags = 0,
			suffixes = 0
		}
		npc.spells[spellId] = spell
	end
	
	-- Track usages and difficulties
	if usage then
		if usage == BOSS_NOTES_ABILITIES_AURA then
			usage = 0
			local auraType = select(4, ...)
			if auraType == "BUFF" then
				usage = BOSS_NOTES_ABILITIES_BUFF
			elseif auraType == "DEBUFF" then
				usage = BOSS_NOTES_ABILITIES_DEBUFF
			end
		end
		local flags = bit.bor(self:GetDifficulty(instance and instance.raid), usage)
		if bit.band(spell.flags, flags) ~= flags then
			spell.flags = bit.bor(spell.flags, flags)
			BossNotes:InvalidateContextKey(BossNotes:GetContextKey(instance, encounter))
		end
	end
	
	-- Track suffixes
	if suffix then
		if bit.band(spell.suffixes, suffix) ~= suffix then
			spell.suffixes = bit.bor(spell.suffixes, suffix)
			BossNotes:InvalidateContextKey(BossNotes:GetContextKey(instance, encounter))
		end
	end
end

-- Handles chat messages
function BossNotesAbilities:CHAT_MSG_SYSTEM (message, msg)
	if self:MatchFormat(msg, ERR_DUNGEON_DIFFICULTY_CHANGED_S) or
			self:MatchFormat(msg, ERR_RAID_DIFFICULTY_CHANGED_S) or
			self:MatchFormat(msg, ERR_PLAYER_DIFFICULTY_CHANGED_S) then
		BossNotes:InvalidateContextKey("all")
	end
end


----------------------------------------------------------------------
-- Hooks

-- Adds the abilities to the tooltip
function BossNotesAbilities:OnTooltipSetUnit (gameTooltip)
	if self.db.global.tooltipInfo then 
		local npcId = BossNotes:GetNpcId(UnitGUID("mouseover"))
		
		if npcId then
		
			local npc = self.db.global.npcs[npcId]
			if FILTERED_NPC_IDS[npcId] then
				return
				end
			if npc then
				-- Get current dungeon difficulty bit
				local _, instanceType = GetInstanceInfo()
				local difficulty = self:GetDifficulty(instanceType == "raid")

				-- Acquire and sort spell names
				local spellNameSet = { }
				for _, spell in pairs(npc.spells) do
					if bit.band(spell.flags, difficulty) ~= 0 then
						spellNameSet[spell.name] = true
					end
				end
				spellNames = { }
				for spellName in pairs(spellNameSet) do
					table.insert(spellNames, spellName)
				end
				table.sort(spellNames, function (a, b)
					return a < b
				end)
				
				-- Add to tooltip
				local abilities = table.concat(spellNames, ", ")
				local pos = 1
				abilities = string.gsub(abilities, "%s+()(%S+)()", function (start, word, stop)
					if stop - pos > 40 then
						pos = start
						return "\n" .. word
					end
				end)
				gameTooltip:AddLine(abilities, 0.91, 0.44, 0.0)
			end
		end
	end
end


----------------------------------------------------------------------
-- Options

-- Returns whether the tooltip information is enabled
function BossNotesAbilities:IsTooltipInfo (info)
	return self.db.global.tooltipInfo
end

-- Toggles the tooltip information
function BossNotesAbilities:SetTooltipInfo (info, tooltipInfo)
	self.db.global.tooltipInfo = tooltipInfo
end

----------------------------------------------------------------------
-- Utilities

-- Migrates the database
function BossNotesAbilities:MigrateDatabase (targetVersion)
	local version = self.db.global.databaseVersion or targetVersion
	
	-- Migrate version 1 -> 2
	if version == 1 and targetVersion >= 2 then
		for _, npc in pairs(self.db.global.npcs) do
			for _, spell in pairs(npc.spells) do
				if not spell.flags then
					spell.flags = spell.difficulty
				end
				spell.difficulty = nil
			end
		end
		version = 2
		self.db.global.databaseVersion = version
	end
	
	-- Migrate version 2 -> 3
	if version == 2 and targetVersion >= 3 then
		for _, npc in pairs(self.db.global.npcs) do
			for _, spell in pairs(npc.spells) do
				if not spell.suffixes then
					spell.suffixes = 0
				end
			end
		end
		self.db.global.instanceEncounters = nil
		version = 3
		self.db.global.databaseVersion = version
	end
	
	
	-- Set to target version
	self.db.global.databaseVersion = version
end

-- Returns the dungeon difficulty bit
function BossNotesAbilities:GetDifficulty (raid)
	local rawDifficulty
	if IsInInstance() then
		rawDifficulty = select(3, GetInstanceInfo())
	else
		rawDifficulty = raid and GetRaidDifficultyID() or GetDungeonDifficultyID()
	end
	return bit.lshift(1, rawDifficulty - 1)
end

-- Matches a format
function BossNotesAbilities:MatchFormat (msg, fmt)
	-- Create pattern
	local pattern = string.gsub(fmt, "%.", "%.")
	pattern = string.gsub(pattern, "%%s", "(.+)")
	pattern = string.gsub(pattern, "%%d", "(%d+)")
	pattern = "^" .. pattern .. "$"
	
	-- Match
	local found, _, capture = string.find(msg, pattern)
	return found, capture
end