--[[

$Revision: 393 $

(C) Copyright 2009 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")


----------------------------------------------------------------------
-- Constants

-- Orders
BOSS_NOTES_ORDER_PERSONAL = 100
BOSS_NOTES_ORDER_COLLECTION = 200
BOSS_NOTES_ORDER_COMMUNITY = 300

-- Default color (0xc4a600)
local DEFAULT_COLOR = { r = 0.77,  g = 0.64, b = 0.0 }

-- Filtered NPCs
local FILTERED_NPC_IDS = {
	[510] = true,   -- Water Elemental
	[2523] = true,  -- Searing Totem
	[2630] = true,  -- Earthbind Totem
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
	[100943] = true,	--Earthen Shield Totem
	[100820] = true,	--sprit wolf
	[55659] = true,	--wild imp
	[97369] = true,	--magma totem
	[78001] = true,	--cloudburst totem
	[104818] = true,	--Ancestral Protection Totem
	[100943] = true,	--Earthen Sheild
	[53006] = true,	--Spirit Link totem
	[59764] = true,	--Healing Tide Totem
	[95255] = true,	--Earthquake Totem
	[60561] = true,	--Earthgrab Totem
	[91245] = true,	--Lightning Surge Totem
	[100099] = true,	--Voodoo Totem
	[97285] = true,	--wind rush totem
	[3527] = true,	--Healing Stream
	[102392] = true,	--Resonace Totem
	[106317] = true,	--Storm totem
	[106319] = true,	--Ember Totem
	[106321] = true,	--tailwind totem
	[113845] = true,	--totem mastery
	[78116] = true, --water elemental
	[61146] = true, --black ox
	[63508] = true, --Xuen
	[100820] = true, --"Spirit Wolf"
	[416] = true --"Imp"
	
}

-- An empty table
local EMPTY = { }


---------------------------------------------------------------------
-- Subsystem

-- Initializes the data subsystem
function BossNotes:InitializeData ()
	-- Collections
	self.providers = { }
	
	-- NPC to instance/encounter map
	self:UpdateInstanceEncounters()
	
	-- Prune learned that are now in the encounter database
	for key, instanceEncounter in pairs(self.db.global.instanceEncounters) do
		local empty = true
		for npcId in pairs(instanceEncounter.npcIds) do
			if BossNotes:GetInstanceAndEncounter(npcId) then
				instanceEncounter.npcIds[npcId] = nil
			else
				empty = false
			end
		end
		if empty then 
			self.db.global.instanceEncounters[key] = nil
		end
	end
end

-- Enables the data subsystem
function BossNotes:EnableData ()
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "MainAddonMessageBN")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "MainAddonMessageBN")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "MainAddonMessageBN")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("CHAT_MSG_ADDON", "VERSIONUPDATE")
end

-- Disables the data subsystem
function BossNotes:DisableData  ()

end


----------------------------------------------------------------------
-- APIs

-- Registers a provider
function BossNotes:RegisterProvider (name, callbacks)
	self.providers[name] = callbacks
	self:InvalidateContextKey("all")
end

-- Unregisters a provder
function BossNotes:UnregisterProvider (name)
	if self.providers[name] then
		self.providers[name] = nil
		self:InvalidateContextKey("all")
	end
end

-- Returns the instance and an encounter for an NPC ID
function BossNotes:GetInstanceAndEncounter (npcId)
	local instanceEncounter = self.instanceEncounters[npcId]
	if not instanceEncounter then
		return
	end
	return instanceEncounter.instance, instanceEncounter.encounter, true
end

-- Returns the instance and encounter for an NPC ID, associating the NPC ID
-- with the current instance and encounter if it is unknown
function BossNotes:GetOrLearnInstanceAndEncounter (npcId, npcName) 
	local instance, encounter = self:GetInstanceAndEncounter(npcId)
	if not instance then
		if not self.learningZone or self.learningZone ~= GetRealZoneText() then
			return
		end
		if FILTERED_NPC_IDS[npcId] then
			return
		end
		instance, encounter = BossNotes:GetSelection()
		local key = self:GetContextKey(instance, encounter)
		local instanceEncounter = self.db.global.instanceEncounters[key]
		if not instanceEncounter then
			instanceEncounter = {
				contextText = BossNotes:GetContextText(instance, encounter),
				npcIds = { }
			}
			self.db.global.instanceEncounters[key] = instanceEncounter
		end
		if not instanceEncounter.npcIds[npcId] then
			self:Print(string.format(L["LEARNING"],
					npcName, npcId, instanceEncounter.contextText))
			instanceEncounter.npcIds[npcId] = npcName
			self:InvalidateContextKey(key)
		end
	end
	return instance, encounter, true
end

-- Returns the NPC IDs for an instance and encounter
function BossNotes:GetNpcIds (instance, encounter)
	local npcIds = (encounter and encounter.npcIds) or (instance and instance.npcIds)
	local key = self:GetContextKey(instance, encounter)
	local instanceEncounter = self.db.global.instanceEncounters[key]
	if instanceEncounter then
		-- Merge
		local mergedNpcIds = { }
		if npcIds then
			for _, npcId in ipairs(npcIds) do
				if not instanceEncounter.npcIds[npcId] then
					table.insert(mergedNpcIds, npcId)
				end
			end
		end
		for npcId in pairs(instanceEncounter.npcIds) do
			table.insert(mergedNpcIds, npcId)
		end
		npcIds = mergedNpcIds
	end
	return npcIds or EMPTY
end

-- Returns a key for a context
function BossNotes:GetContextKey (instance, encounter) 
	return encounter and "encounter:" .. tostring(encounter.encounterId)
			or instance and "instance:" .. instance.instanceId
			or "general"
end

-- Returns a text representation for a context
function BossNotes:GetContextText (instance, encounter)
	return encounter and encounter.name
			or instance and instance.name
			or L["GENERAL"]
end

-- Invalidates a context key and schedules an (asynchronous) UI update
function BossNotes:InvalidateContextKey (key, immediate)
	-- Clear sources, manage keys
	if key == "all" then	
		self.sources = { }
	else
		self.sources[key] = nil
	end
	if not self.updateSourcesKeys then
		self.updateSourcesKeys = { }
	end
	self.updateSourcesKeys[key] = true
		
	-- Update
	if immediate then
		if self.updateSourcesTimer then
			self:CancelTimer(self.updateSourcesTimer)
			self.updateSourcesTimer = nil
		end
		self:SendUpdateSources()
	else
		if not self.updateSourcesTimer then
			self.updateSourcesTimer = self:ScheduleTimer("SendUpdateSources", 2.0)
		end
	end
end


----------------------------------------------------------------------
-- Data management

-- Returns the sources
function BossNotes:GetSources (instance, encounter)
	local sources = { }
		
	-- Query providers
	for name, callbacks in pairs(self.providers) do
		if callbacks.OnSources then
			local providerSources = callbacks.OnSources(instance, encounter)
			if providerSources then
				-- Handle string sources
				if type(providerSources) ~= "table" then
					providerSources = {
						note = tostring(providerSources)
					}
				end
				
				-- Handle single-entry sources
				if #providerSources == 0 then
					providerSources = {
						providerSources
					}
				end
				
				-- Process each source
				for _, source in ipairs(providerSources) do
					source.callbacks = callbacks
					if not source.order then
						source.order = BOSS_NOTES_ORDER_COLLECTION
					end
					if not source.title then
						source.title = name
					end
					if not source.color then
						source.color = DEFAULT_COLOR
					end
					table.insert(sources, source)
				end
			end
		end
	end
	
	-- Sort
	table.sort(sources, function (a, b)
		if a.order ~= b.order then
			return a.order < b.order
		end
		return a.title < b.title
	end)
	
	return sources
end

-- Refreshes the sources
function BossNotes:RefreshSources (instance, encounter)
	-- Refresh providers
	for name, callbacks in pairs(self.providers) do
		if callbacks.OnRefresh then
			callbacks.OnRefresh(instance, encounter)
		end
	end
end

-- Updates the instance/encounter map
function BossNotes:UpdateInstanceEncounters ()
	self.instanceEncounters = { }
	for _, instanceSet in ipairs(BOSS_NOTES_ENCOUNTERS) do
		for _, instance in ipairs(instanceSet.instances) do
			local instanceEncounter = {
				instance = instance
			}
			for _, npcId in ipairs(instance.npcIds) do
				self.instanceEncounters[npcId] = instanceEncounter
			end
			for _, encounter in ipairs(instance.encounters) do
				local instanceEncounter = {
					instance = instance,
					encounter = encounter
				}
				for _, npcId in ipairs (encounter.npcIds) do
					self.instanceEncounters[npcId] = instanceEncounter
				end
			end
		end
	end
end

-- Sends the sources update message once the timer has expired
function BossNotes:SendUpdateSources ()
	-- Clean
	self.updateSourcesTimer = nil
	local keys = self.updateSourcesKeys
	self.updateSourcesKeys = nil
	
	-- Send message
	self:SendMessage("BOSS_NOTES_UPDATE_SOURCES", keys)
end


----------------------------------------------------------------------
-- Event handlers
local BNN = "|cffe1a500Boss|cff69ccf0Notes|cffffffff" 
local MYVERSION = GetAddOnMetadata("BossNotes", "Version")
local VERSION = MYVERSION:gsub('[%.]', '')
local curVer = "|cffffffff "..MYVERSION.."|cffe1a500"

-- function max(a)
  -- local values = {}
  -- for k,v in pairs(a) do
    -- if type(k) == "number" and type(v) == "number" then
      -- values[#values+1] = v
    -- end
  -- end
  -- table.sort(values) -- automatically sorts lowest to highest

  -- return values[#values]
  
-- end
local ENTERCBN 
function BossNotes:MainAddonMessageBN ()
RegisterAddonMessagePrefix("BossNotes")
if ENTERCBN == nil then
ENTERCBN = 1
end
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInInstance() and not C_Garrison:IsOnGarrisonMap() then
				if (ENTERCBN >= 1 and ENTERCBN <= 9) then
				ENTERCBN = ENTERCBN + 1
			
				SendAddonMessage("BossNotes", VERSION, "INSTANCE_CHAT")	
				end
				if (ENTERCBN >= 10 and ENTERCBN <=15) then
				ENTERCBN = ENTERCBN + 1
				end
				if (ENTERCBN == 16) then
				ENTERCBN = 1
				end
	else
		if IsInRaid() then
				if (ENTERCBN >= 1 and ENTERCBN <= 9) then
				ENTERCBN = ENTERCBN + 1
				SendAddonMessage("BossNotes", VERSION, "RAID");
				
				end
				if (ENTERCBN >= 10 and ENTERCBN <=15) then
				ENTERCBN = ENTERCBN + 1
				end
				if (ENTERCBN == 16) then
				ENTERCBN = 1
				end
			
		elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		if (ENTERCBN >= 1 and ENTERCBN <= 9) then
				ENTERCBN = ENTERCBN + 1
				SendAddonMessage("BossNotes", VERSION, "PARTY");
				
				end
				if (ENTERCBN >= 10 and ENTERCBN <=15) then
				ENTERCBN = ENTERCBN + 1
				end
				if (ENTERCBN == 16) then
				ENTERCBN = 1
				end
			
		end
	end
if (ENTERCBN >= 1 and ENTERCBN <= 9) then
				ENTERCBN = ENTERCBN + 1
				SendAddonMessage("BossNotes", VERSION, "PARTY");
			
				end
				if (ENTERCBN >= 10 and ENTERCBN <=15) then
				ENTERCBN = ENTERCBN + 1
				end
				if (ENTERCBN == 16) then
				ENTERCBN = 1
				end
end
-- Handles the UPDATE_MOUSEOVER_UNIT event
local count --stop addon from sending to many messages
local counts
function BossNotes:UPDATE_MOUSEOVER_UNIT ()
self:CheckUnit("mouseover")
local playerFactionIndexbn
local mousoverfactionbn
local isPlayerbn = UnitIsPlayer("mouseover")
local name = GetUnitName("mouseover", true)
total, equipped, pvp = GetAverageItemLevel("mouseover")

	if UnitFactionGroup("player") == "Horde" then 
	playerFactionIndex = 1 
		else 
		playerFactionIndex = 0 
	end
	--player is horde so ignore alliance players to avoid player not online because that player isnt in horde
		if (UnitFactionGroup("mouseover") == "Horde" and playerFactionIndexbn == 1 and isPlayerbn == true) then
		GameTooltip:AddLine("BossNotes: Player ilevel"..equipped, true)
		GameTooltip:Show()
			if count == nil then
			count = 1
			end
					if (count >= 1 and count <= 9) then
					count = count + 1
					SendAddonMessage("BossNotes", VERSION, "WHISPER", name)		
					end
				if (count >= 10 and count <=60) then
				count = count + 1
				end
			if (count == 61) then
			count = 1
			end
		end	
	--player is alliance so ignore horde players to avoid player not online because that player isnt in alliance
	if(UnitFactionGroup("mouseover") == "Alliance" and playerFactionIndexbn == 0 and isPlayerbn == true) then
	GameTooltip:AddLine("BossNotes: Player ilevel"..equipped, true)
	GameTooltip:Show()
		if counts == nil then
		counts = 1
		end
				if (counts == 1 and counts <= 9) then
				SendAddonMessage("BossNotes", VERSION, "WHISPER", name)
				counts = counts + 1
				end
			if (counts >= 10 and counts <=60) then
			counts = counts + 1
			end
		if (counts == 61) then
		counts = 1				
		end
	end	
end		


local ADDON_BN_C
function BossNotes:VERSIONUPDATE (event, arg1, VERSIONS, arg3, arg4)
	-- arg1: prefix
	-- VERSIONS: message
	-- arg3: channel
	-- arg4: sender
	if arg1 == "BossNotes" then
		if(VERSIONS > VERSION) then
			if ADDON_BN_C == nil then
			ADDON_BN_C = 1
			end
			if (ADDON_BN_C >= 1 and ADDON_BN_C <= 5) then
			ADDON_BN_C = ADDON_BN_C + 1
			print(""..BNN.." A New version is avaiable please download")
			return
			end
			if (ADDON_BN_C >= 6 and ADDON_BN_C <=40) then
			ADDON_BN_C = ADDON_BN_C + 1
			end
			if (ADDON_BN_C == 41) then
			ADDON_BN_C = 1
			end
		end
		--if the version recived from another addon is lower then ours do nothing and clear table
		if(VERSIONS < VERSION) then
		return
		end
		--if the version is the same do nothing and clear table
		if(VERSIONS == VERSION) then
		--VERSIONS = nil
		return
		end
		if(VERSIONS == nil) then
		return
		end
	
	end
end




-- Handles the PLAYER_TARGET_CHANGED event
function BossNotes:PLAYER_TARGET_CHANGED ()
	self:CheckUnit("target")
end


----------------------------------------------------------------------
-- Support methods

-- Checks a unit
function BossNotes:CheckUnit (unit)
	-- Ignore corpses
	if UnitIsDead(unit) then
		return
	end
	
	-- Get the NPC ID
	local npcId = self:GetNpcId(UnitGUID(unit))
	if not npcId then
		return
	end
	
	-- Find and process a mapped instance encounter
	local instance, encounter = self:GetInstanceAndEncounter(npcId)
	if instance then
		self:SendMessage("BOSS_NOTES_ACTIVATION", instance, encounter)
	end
end

-- Returns the NPC ID of a GUID
function BossNotes:GetNpcId (guid)

if (guid == nil) then
return
else
local type, zero, server_id, instance_id, zone_uid, npc_id, spawn_uid = strsplit("-", guid)
	-- Check GUID
	if not guid then
		return nil
	end
	
	-- Check unit type
	local unitType = type
	if unitType ~= "Creature" and unitType ~= "Pet" then
		return nil
	end
	local guid = npc_id
	

	-- Check unit NPC ID
	return npc_id
	end
end