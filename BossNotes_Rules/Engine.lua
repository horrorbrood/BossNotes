--[[

$Revision: 348 $

(C) Copyright 2009,2011 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

BossNotesRulesEngine = BossNotesRules:NewModule("Engine",
		"AceEvent-3.0",
		"AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")


----------------------------------------------------------------------
-- Constants

-- Game client locale
local LOCALE = GetLocale()

-- Event catgegories
local CATEGORIES = { "spell", "emote", "entercombat", "changetarget", "death" }

-- Event suffixes
local EVENT_SUFFIXES = BossNotesAbilities:GetEventSuffixes()

-- The heavy bandage of each major game release, in decending order for
-- efficient matching.
local BANDAGES = { 34722, 21991, 14530 }

-- Aura filters
local AURA_FILTERS = { "HELPFUL", "HARMFUL" }


----------------------------------------------------------------------
-- Core handlers

-- One-time initialization
function BossNotesRulesEngine:OnInitialize ()
	-- Call the subsystem initializers.
	self:InitializeEncounter()
	self:InitializeEventsAndCancels()
	self:InitializeActions()
	self:InitializeInCombatModel()
	self:InitializeUnitIdStateModel()
	self:InitializeRtaModel()
end

-- Handles the (re-)enabling of module
function BossNotesRulesEngine:OnEnable ()
	self:RegisterEvent("UNIT_TARGET")
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE")
	self:RegisterEvent("UNIT_EXITED_VEHICLE")
	self:RegisterEvent("PARTY_MEMBERS_CHANGED")
	self:RegisterEvent("RAID_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE", "HandleEmote")
	self:RegisterEvent("CHAT_MSG_RAID_BOSS_WHISPER", "HandleEmote")
	self:RegisterEvent("CHAT_MSG_MONSTER_YELL", "HandleEmote")
end

-- Handles the disabling of this module
function BossNotesRulesEngine:OnDisable ()
end


----------------------------------------------------------------------
-- API

-- Fires a rule by name.
function BossNotesRulesEngine:FireRuleByName (name)
	if self.inEncounter then
		for _, rule in ipairs(self.rules) do
			if rule.name == name then
				BossNotes:Print(string.format(L["FIRING_RULE"], rule.name))
				self:FireRule(rule)
				break
			end
		end
	end
end


----------------------------------------------------------------------
-- Game Events

--[[

The engine uses the following game events to detect events and cancels
of rules:

Event or Cancel Type               Game Event
----------------------------------------------------------------------
cast                               COMBAT_LOG_EVENT_UNFILTERED
aura                               COMBAT_LOG_EVENT_UNFILTERED
emote                              CHAT_MSG_RAID_BOSS_EMOTE,
                                   CHAT_MGS_RAID_BOSS_WHIPSER,
                                   CHAT_MSG_MONSTER_YELL
unit                               COMBAT_LOG_EVENT_UNFILTERED,
                                   UNIT_TARGET

In order to maintain the various game state models required by the engine,
the following game events are processed:

Game Event                         Units
----------------------------------------------------------------------
UNIT_TARGET                        all
UPDATE_MOUSEOVER_UNIT              player
UNIT_PET                           player
PLAYER_FOCUS_CHANGED               player
UNIT_ENTERED_VEHICLE               player
UNIT_EXITED_VEHICLE                player
PARTY_MEMBERS_CHANGED              party
RAID_ROSTER_UPDATE                 raid

Finally, the begin of an encounter is detected by PLAYER_REGEN_DISABLED
and the (possible) end of an encounter is detected by
PLAYER_REGEN_ENABLED.

]]

function BossNotesRulesEngine:UNIT_TARGET (message, unitId)
	-- Update the newly targeted unit ID. For consistency, we use "target"
	-- and not "playertarget".
	local targetUnitId = unitId ~= "player" and unitId .. "target" or "target"
	self:UpdateUnitId(targetUnitId)
	
	if self.inEncounter then
		-- If the unit ID that is changing target is the target or the focus of the
		-- of the player, check for entry into combat.
		if unitId == "target" or unitId == "focus" then
			self:UpdateInCombat(unitId, nil)
		end
		
		-- Process target change
		if #self.events.changetarget > 0 or #self.cancels.changetarget > 0 then
			self.sourceGuid = UnitGUID(unitId)
			self.sourceUnitId = unitId
			self.destGuid = UnitGUID(targetUnitId)
			self.destUnitId = targetUnitId
			self.spellId = nil
			self:TriggerRules(self.events.changetarget)
			self:CancelRules(self.cancels.changetarget)
		end
	end
end

function BossNotesRulesEngine:UPDATE_MOUSEOVER_UNIT (message)
	self:UpdateUnitId("mouseover")
end

function BossNotesRulesEngine:UNIT_PET (message, unitId)
	if unitId == "player" then
		self:UpdateUnitIdAndTarget("pet")
	end
end

function BossNotesRulesEngine:PLAYER_FOCUS_CHANGED (message, unitId)
	self:UpdateUnitIdAndTarget("focus")
end

function BossNotesRulesEngine:UNIT_ENTERED_VEHICLE (message, unitId)
	if unitId == "player" then
		self:UpdateUnitId("vehicle")
	end
end

function BossNotesRulesEngine:UNIT_EXITED_VEHICLE (message, unitId)
	if unitId == "player" then
		self:UpdateUnitId("vehicle")
	end
end

function BossNotesRulesEngine:PARTY_MEMBERS_CHANGED (message)
	for i = 1, MAX_PARTY_MEMBERS do
		self:UpdateUnitIdAndTarget("party" .. tostring(i))
		self:UpdateUnitIdAndTarget("partypet" .. tostring(i))
	end
end

function BossNotesRulesEngine:RAID_ROSTER_UPDATE (message)
	for i = 1, MAX_RAID_MEMBERS do
		self:UpdateUnitIdAndTarget("raid" .. tostring(i))
		self:UpdateUnitIdAndTarget("raidpet" .. tostring(i))
	end
end

function BossNotesRulesEngine:PLAYER_REGEN_DISABLED (message)
	self:BeginEncounter()
end

function BossNotesRulesEngine:PLAYER_REGEN_ENABLED (message)
	self:CheckEncounter()
end

function BossNotesRulesEngine:COMBAT_LOG_EVENT_UNFILTERED (message, timestamp,
		event, hideCaster, sourceGuid, sourceName, sourceFlags,
		sourceRaidFlags, destGuid, destName, destFlags, destRaidFlags, spellId)
	-- This event needs to be processed efficiently due to its high
	-- delivery frequency. To that end, processing is mostly limited
	-- to constant time table lookups.
	if self.inEncounter then
		-- Process spells
		local suffix = EVENT_SUFFIXES[event]
		if suffix then
			local eventRules
			local rulesBySuffix = self.events.spell[spellId]
			if rulesBySuffix then
				eventRules = rulesBySuffix[suffix]
			end
			local cancelRules
			local rulesBySuffix = self.cancels.spell[spellId]
			if rulesBySuffix then
				cancelRules = rulesBySuffix[suffix]
			end
			if eventRules or cancelRules then
				self.sourceUnitId = self:GetUnitIdByGuid(sourceGuid)
				self.sourceGuid = sourceGuid
				self.destUnitId = self:GetUnitIdByGuid(destGuid)
				self.destGuid = destGuid
				self.spellId = spellId
				if eventRules then
					self:TriggerRules(eventRules)
				end
				if cancelRules then
					self:CancelRules(cancelRules)
				end
			end
		end
		
		-- Process entry into combat
		self:UpdateInCombat(nil, sourceGuid)
		
		-- Process unit death
		if event == "UNIT_DEATH" then
			if #self.events.death > 0 or #self.cancels.death > 0 then
				self.sourceUnitId = "none"
				self.sourceGuid = nil
				self.destUnitId = self:GetUnitIdByGuid(destGuid)
				self.destGuid = destGuid
				self.spellId = nil
				self:TriggerRules(self.events.death)
				self:CancelRules(self.cancels.death)
			end
		end
	end
end

function BossNotesRulesEngine:HandleEmote (message, text, name)
	if self.inEncounter then
		for pattern, rules in pairs(self.events.emote) do
			local start, _, destName = string.find(text, pattern)
			if start then
				self.sourceUnitId = self:GetUnitIdByName(name)
				self.sourceGuid = UnitGUID(self.sourceUnitId)
				self.destUnitId = self:GetUnitIdByName(destName)
				self.destGuid = UnitGUID(self.destUnitId)
				self.spellId = nil
				self:TriggerRules(rules)
			end
		end
		for pattern, rules in pairs(self.cancels.emote) do
			local start, _, destName = string.find(text, pattern)
			if start then
				self.sourceUnitId = self:GetUnitIdByName(name)
				self.sourceGuid = UnitGUID(self.sourceUnitId)
				self.destUnitId = self:GetUnitIdByName(destName)
				self.destGuid = UnitGUID(self.destUnitId)
				self.spellId = nil
				self:CancelRules(rules)
			end
		end
	end
end

-- Triggers a list of rules.
function BossNotesRulesEngine:TriggerRules (rules)
	for _, rule in ipairs(rules) do
		if self:CheckConditions(rule.conditions) then
			self:FireRule(rule)
		end
	end
end

-- Cancels a list of rules.
function BossNotesRulesEngine:CancelRules (rules)
	for _, rule in ipairs(rules) do
		self:CancelRule(rule)
	end
end

-- Updates a unit ID and its target.
function BossNotesRulesEngine:UpdateUnitIdAndTarget (unitId)
	self:UpdateUnitId(unitId)
	self:UpdateUnitId(unitId .. "target")
end

-- Updates a unit ID.
function BossNotesRulesEngine:UpdateUnitId (unitId)
	-- Invoke the processing methods on the models. The unit ID state
	-- model is maintained continuously. Other models are only
	-- maintained while an encounter is active.
	self:UpdateUnitIdState(unitId)
	if self.inEncounter then
		self:UpdateInCombat(unitId)
		self:ApplyPendingRta(unitId)
	end
end


----------------------------------------------------------------------
-- Encounter

--[[

The encounter subsystem manages the begin and end of an encounter.

Beginning an encounter involves fixing on the encounter wide data
which is stored in 'self.instance', 'self.encounter', 'self.key'
and 'self.rules'. Next, setup is performed on the relevant
subsystems and the in encounter status is asserted.

Ending an encounter involves cacneling all rules in order to stop
any pending actions. Next, the in encoutner status is cleared, the
relevant subsystems are cleared and the encounter wide data is
cleared.

]]

-- Initializes the encounter data structures.
function BossNotesRulesEngine:InitializeEncounter ()
	self.inEncounter = false
	self.rules = { }
end

-- Begins an encounter.
function BossNotesRulesEngine:BeginEncounter  ()
	-- Begin the encounter unless it is already running.
	if not self.inEncounter then
		-- Set the instance, encounter and key
		self.instance, self.encounter = BossNotes:GetSelection()
		self.key = BossNotes:GetContextKey(self.instance, self.encounter)
		
		-- Retrieve the rules
		for _, rule in ipairs(BossNotesRules:GetRules(self.key)) do
			if rule.enabled then
				table.insert(self.rules, rule)
			end
		end
		if self.encounter then
			local instanceKey = BossNotes:GetContextKey(self.instance, nil)
			for _, rule in ipairs(BossNotesRules:GetRules(instanceKey)) do
				if rule.enabled then
					table.insert(self.rules, rule)
				end
			end
			if self.instance then
				local generalKey = BossNotes:GetContextKey(nil, nil)
				for _, rule in ipairs(BossNotesRules:GetRules(generalKey)) do
					if rule.enabled then
						table.insert(self.rules, rule)
					end
				end
			end
		end
		
		-- Perform setup
		self:SetupEventsAndCancels()
		self:SetupRtaModel()
		
		-- Assert the "in encounter" flag
		self.inEncounter = true
	end
end

-- Checks whether an encounter is ongoing, ending it if not.
function BossNotesRulesEngine:CheckEncounter (timerCallback)
	-- Clear the timer handle if this is a timer callback.
	if timerCallback then
		self.checkEncounterTimer = nil
	end
	
	-- Perform the check if the encounter is still ongoing.
	if self.inEncounter then
		-- Test the encounter status on the player, then on the raid
		-- or party.
		local inEncounter = UnitAffectingCombat("player")
		if not inEncounter then
			if (UnitInRaid("player")) then
				for i = 1, MAX_RAID_MEMBERS do
					if UnitAffectingCombat("raid" .. tostring(i)) then
						inEncounter = true
						break
					end
				end
			elseif GetNumGroupMembers() > 0 then
				for i = 1, MAX_PARTY_MEMBERS do
					if UnitAffectingCombat("party" .. tostring(i)) then
						inEncounter = true
						break
					end
				end
			end
		end
	
		-- End the encounter, or reschedule a check if the encounter
		-- is still ongoing.
		if not inEncounter then
			-- Cancel all rules.
			self:CancelRules(self.rules)
			
			-- Clear the "in encounter" flag.
			self.inEncounter = false
			
			-- Perform cleanup.
			self:ClearEventsAndCancels()
			self:ClearActions()
			self:ClearInCombatModel()
			self:ClearRtaModel()
			
			-- Clear encounter-wide data
			table.wipe(self.rules)
			self.instance = nil
			self.encounter = nil
			self.key = nil
		else
			if not self.checkEncounterTimer then
				self.checkEncounterTimer = self:ScheduleTimer(
						"CheckEncounter", 1.0, true)
			end
		end
	end
end


----------------------------------------------------------------------
-- Events and cancels

--[[

Fundamentally, the engine evaluates event-condition-action (ECA) rules.
The non-functional requirement is to do that in an efficient way. To
that end, the engine uses a table-driven approach to game event
handling. This allows the game event handling code to do constant
time table lookups in order to determine what rules are triggered
or canceled by each event.

The tables 'self.events' and 'self.cancels' are identically structured
and serve as the entry points for the game event handling code.

]]

-- Initializes events and cancels
function BossNotesRulesEngine:InitializeEventsAndCancels ()
	self.spells = { }
	self.events = { }
	self.cancels = { }
	for _, category in ipairs(CATEGORIES) do
		self.events[category] = { }
		self.cancels[category] = { }
	end
end

-- Clears and then configures the events and cancels for the current
-- encounter.
function BossNotesRulesEngine:SetupEventsAndCancels ()
	-- Consolidate spells by name. Consider both spells from the
	-- Abilities module and from the rules.
	local function AddSpell (spellId, spellName)
		spellName = spellName or GetSpellInfo(spellId)
		if not self.spells[spellName] then
			self.spells[spellName] = { }
		end
		self.spells[spellName][spellId] = true
	end
	local npcIds = BossNotes:GetNpcIds(self.instance, self.encounter)
	for _, npcId in ipairs(npcIds) do
		local npcSpells = BossNotesAbilities:GetSpells(npcId)
		for _, spell in ipairs(npcSpells) do
			AddSpell(spell.spellId, spell.name)
		end
	end
	local editor = BossNotesRules:GetModule("Editor")
	for _, rule in ipairs(self.rules) do
		for _, event in pairs(rule.events) do
			if editor:IsValidEventOrCancel(event) then
				if event.type == "cast" or event.type == "aura" then
					AddSpell(event.spellId)
				end
			end
		end
		for _, cancel in pairs(rule.cancels) do
			if editor:IsValidEventOrCancel(cancel) then
				if cancel.type == "cast" or cancel.type == "aura" then
					AddSpell(cancel.spellId)
				end
			end
		end
		for _, spell in pairs(rule.spells) do
			if editor:IsValidSpell(spell) then
				AddSpell(spell.spellId)
			end
		end
	end
	
	-- Setup events and cancels.
	for _, rule in ipairs(self.rules) do
		self:SetupEventsOrCancels(self.events, rule.events, rule)
		self:SetupEventsOrCancels(self.cancels, rule.cancels, rule)
	end
end

-- Creates an event map.
function BossNotesRulesEngine:SetupEventsOrCancels (map, events, rule)
	local editor = BossNotesRules:GetModule("Editor")
	for _, event in ipairs(events) do
		if editor:IsValidEventOrCancel(event) then
			if event.type == "cast" or event.type == "aura" then
				local spellName = GetSpellInfo(event.spellId)
				for spellId in pairs(self.spells[spellName]) do
					local rulesBySuffix = map.spell[spellId]
					if not rulesBySuffix then
						rulesBySuffix = { }
						map.spell[spellId] = rulesBySuffix
					end
					local rules = rulesBySuffix[event.suffix]
					if not rules then
						rules = { }
						rulesBySuffix[event.suffix] = rules
					end
					table.insert(rules, rule)
				end
			elseif event.type == "emote" then
				if event.locale == LOCALE then
					local pattern = event.text
					pattern = string.gsub(pattern, "%%", "%%%%")
					pattern = string.gsub(pattern, "%%%%p", "([^%%s]+)")
					local rules = map.emote[pattern]
					if not rules then
						rules = { }
						map.emote[pattern] = rules
					end
					table.insert(rules, rule)
				end
			elseif event.type == "unit" then
				table.insert(map[event.action], rule)
			end
		end
	end
end

-- Clears and events and cancels.
function BossNotesRulesEngine:ClearEventsAndCancels ()
	table.wipe(self.spells)
	for _, category in ipairs(CATEGORIES) do
		table.wipe(self.events[category])
		table.wipe(self.cancels[category])
	end
end


----------------------------------------------------------------------
-- Conditions

--[[

Conditions are evaluated when a rule is triggered. Only is all of its
conditions are satisfied, the rule fires.

]]

-- Checks a list of conditions.
function BossNotesRulesEngine:CheckConditions (conditions)
	for _, condition in ipairs(conditions) do
		if not self:CheckCondition(condition) then
			return false
		end
	end
	return true
end

-- Checks a condition
function BossNotesRulesEngine:CheckCondition (condition)
	-- Ignore invalid conditions, i.e. assume that they are valid.
	if not BossNotesRules:GetModule("Editor"):IsValidCondition(condition) then
		return true
	end
	
	-- Declare a local function to return a unit ID given a condition
	-- and a suffix.
	local function GetUnitId (unit, unitSuffix)
		local unitId
		if unit == "eventsource" then
			unitId = self.sourceUnitId
		elseif unit == "eventdest" then
			unitId = self.destUnitId
		elseif string.sub(unit, 1, 4) == "npc:" then
			unitId = self:GetUnitIdByNpcId(tonumber(string.sub(unit, 5)))
		else
			unitId = unit
		end
		if unitId ~= "none" and unitSuffix ~= "none" then
			unitId = unitId .. unitSuffix
		end
		return unitId
	end
	
	if condition.type == "unit" then
		local unitId1 = GetUnitId(condition.unit, condition.unitSuffix)
		local unitId2 = GetUnitId(condition.secondUnit, "none")
		local same = UnitIsUnit(unitId1, unitId2) and true or false
		return condition.operator == "is" and same and true or
				condition.operator == "isnot" and not same
	end
	if condition.type == "property" then
		local unitId = GetUnitId(condition.unit, condition.unitSuffix)
		local hasProperty
		if condition.property == "player" then
			hasProperty = UnitIsPlayer(unitId)
		elseif condition.property == "playercontrolled" then
			hasProperty = UnitPlayerControlled(unitId)
		elseif condition.property == "party" then
			hasProperty = UnitPlayerOrPetInParty(unitId)
		elseif condition.property == "raid" then
			hasProperty = UnitPlayerOrPetInRaid(unitId)
		elseif condition.property == "maintank" 
				or condition.property == "mainassist" then
			for i = 1, MAX_RAID_MEMBERS do
				if UnitIsUnit(unitId, "raid" .. tostring(i)) then
					local role = select(10, GetRaidRosterInfo(i))
					break
				end
			end
			hasProperty = role == condition.property
		end
		return condition.operator == "is" and hasProperty and true or
				condition.operator == "isnot" and not hasProperty
	end
	if condition.type == "npc" then
		local unitId = GetUnitId(condition.unit, condition.unitSuffix)
		local isNpc = BossNotes:GetNpcId(UnitGUID(unitId)) == condition.npcId
		return condition.operator == "is" and isNpc or
				condition.operator == "isnot" and not isNpc
	end
	if condition.type == "aura" then
		local unitId = GetUnitId(condition.unit, condition.unitSuffix)
		local spellName = GetSpellInfo(condition.spellId)
		local count = 0
		local doseMatch = false
		for _, auraFilter in ipairs(AURA_FILTERS) do
			local auraIndex = 1
			while true do
				local name, _, _, dose = UnitAura(unitId, auraIndex, auraFilter)
				if not name then
					-- A nil return marks the end of the aura list.
					break
				end
				if name == spellName then
					count = count + 1
					if dose == condition.dose then
						doseMatch = true
					end
				end
				auraIndex = auraIndex + 1
			end
		end
		local hasAura = count > 0
		if condition.dose then
			hasAura = hasAura and doseMatch
		end
		if condition.count then
			hasAura = hasAura and count == condition.count
		end
		return condition.operator == "has" and hasAura or
				condition.operator == "hasnot" and not hasAura
	end
	if condition.type == "range" then
		-- As more and more instances have associated instance maps,
		-- could this mess be modified to calculate the distance
		-- directly?
		local unitId = GetUnitId(condition.unit, condition.unitSuffix)
		local inRange
		if condition.range == 10 then
			inRange = CheckInteractDistance(unitId, 3) 
		elseif condition.range == 11 then
			inRange = CheckInteractDistance(unitId, 2)
		elseif condition.range == 18 then
			for _, itemId in ipairs(BANDAGES) do
				local result = IsItemInRange(itemId, unitId)
				if result then
					inRange = result == 1
					break
				end
			end
		elseif condition.range == 28 then
			inRange = CheckInteractDistance(unitId, 1)
		end
		return condition.operator == "inrange" and inRange and true or
				condition.operator == "notinrange" and not inRange
	end
end


----------------------------------------------------------------------
-- Actions

--[[

Most actions require some state for proper operation. That state is
stored in 'self.actionStates' with the action as the key.

Firing a rule involves executing all of its actions; canceling a rule
involves cancelign all of its actions.

The engine handles raid target actions internally. For notifications
and timers however, the engine simply sends out messages. This design
decouples the Boss Notes Rules add-on from the actual display add-on.

When a notification is to be displayed, the add-on message
BOSS_NOTES_RULES_NOTIFICATIION is sent with the following arguments:

Argument                      Description
-----------------------------------------------------------------------
ID                            The ID of the notification
text                          The notification text
important                     Whether the notification is "important"
spellId                       The spell ID (may be nil)

When a timer is started, the add-on message BOSS_NOTES_RULES_TIMER_START
is sent with the following arguments:

Argument                      Description
-----------------------------------------------------------------------
ID                            ID of the timer
text                          Timer text.
duration                      Timer duration in seconds
spellId                       Spell ID (may be nil)

Note that this message may be sent when the timer has not yet expired.
Recipients must restart the timer in this case.

When a timer is stopped, the add-on message BOSS_NOTES_RULES_TIMER_STOP
is sent with the following arguments:

Argument                      Description
-----------------------------------------------------------------------
ID                            ID of the timer

Note that this message may be sent when the timer has already expired.
Recipient must silently discard the message in this case.

The ID can be compared to another ID for equivalence or non-equivalence
and it can be used as a table key. Beside that, the ID must be treated
in an opaque way by recipients of the message.

]]

-- Initializes the actions.
function BossNotesRulesEngine:InitializeActions ()
	self.actionStates = { }
end

-- Clears the actions.
function BossNotesRulesEngine:ClearActions ()
	table.wipe(self.actionStates)
end

-- Fires a rule.
function BossNotesRulesEngine:FireRule (rule)
	for _, action in ipairs(rule.actions) do
		self:ExecuteAction(action, rule)
	end
end

-- Executes an action.
function BossNotesRulesEngine:ExecuteAction (action)
	-- Ignore invalid actions.
	if not BossNotesRules:GetModule("Editor"):IsValidAction(action) then
		return
	end
	
	if action.type == "raidtarget" then
		local state = self.actionStates[action]
		if not state then
			state = { rtas = { } }
			self.actionStates[action] = state
		end
		
		-- Determine the GUID.
		local guid
		if action.setOnSuffix == "none" then
			-- Use the GUID from the event directly.
			guid = action.setOn == "eventsource" and self.sourceGuid or self.destGuid
		else
			-- Append the suffix to the unit ID from the event, then resolve
			-- the corresponding unit. This yields a nil GUID if the base unit
			-- ID cannot be resolved. It is the best we can do as the target
			-- lookup cannot be deferred.
			local unitId = action.setOn == "eventsource" and self.sourceUnitId or self.destUnitId
			unitId = unitId .. action.setOnSuffix
			guid = UnitGUID(unitId)
		end
		
		-- Determine the raid target.
		local raidTarget
		if action.collapse then
			if state.lastRaidTarget then
				-- For collapsed raid targets, set the next raid target,
				-- or set the first raid target and schedule a timer
				-- that closes the collapse interval.
				raidTarget = state.lastRaidTarget + 1
				if raidTarget <= action.lastRaidTarget then
					state.lastRaidTraget = raidTarget
				else
					raidTarget = 0
				end
			else
				raidTarget = action.firstRaidTarget
				state.lastRaidTarget = raidTarget
				self:ScheduleTimer(
						function () state.lastRaidTarget = nil end,
						action.collapse)
			end
		else
			raidTarget = action.firstRaidTarget
		end
		
		-- The guid may be nil and the raid target may be 0 at this point. Any
		-- of these conditions abort further action processing.
		if guid and raidTarget ~= 0 then
			if action.distributed and BossNotesRules:CanBroadcast() then
				-- Perform distributed raid target assignement if requested.
				-- We explicitly do not set an RTA directly because there are
				-- race conditions and tie breaking involved that are handled
				-- at the messaging layer.
				local message = {
					type = "raidtarget",
					guid = guid,
					raidTarget = raidTarget,
					duration = action.duration
				}
				BossNotesRules:Broadcast(message)
			else
				-- Set the RTA. Put it into the action state for cancel
				-- processing. Set a callback to remove the RTA when it
				-- is cleared.
				local rta = self:SetRta(guid, raidTarget, action.duration)
				state.rtas[rta] = true
				rta.callback = function (rta) state.rtas[rta] = nil end
			end
		end
	elseif action.type == "notification" then
		local sourceName = tostring(UnitName(self.sourceUnitId))
		local destName = tostring(UnitName(self.destUnitId))
		local spellId = self.spellId
		if action.collapse then
			-- Collect sources and destinations during the collapse window.
			-- Schedule a timer to send the notification once the window
			-- has elapsed.
			local state = self.actionStates[action]
			if not state then
				state = { sources = { }, dests = { } }
				self.actionStates[action] = state
			end
			table.insert(state.sources, sourceName)
			table.insert(state.dests, destName)
			if not state.collapseTimer then
				state.collapseTimer = self:ScheduleTimer(
						function ()
							local text = action.text
							text = string.gsub(text, "%%s",
									table.concat(state.sources, ", "))
							text = string.gsub(text, "%%d",
									table.concat(state.dests, ", "))
							self:SendNotification(action, text,
									spellId)
							table.wipe(state.sources)
							table.wipe(state.dests)
							state.collapseTimer = nil
						end,
						action.collapse)
			end
		else
			-- Send notification directly.
			local text = action.text
			text = string.gsub(text, "%%s", sourceName)
			text = string.gsub(text, "%%d", destName)
			self:SendNotification(action, text, spellId)
		end
	elseif action.type == "timer" then
		local sourceName = tostring(UnitName(self.sourceUnitId))
		local destName = tostring(UnitName(self.destUnitId))
		local spellId = self.spellId
		local state = self.actionStates[action]
		if not state then
			state = { sources = { }, dests = { } }
			self.actionStates[action] = state
		end
		if action.collapse then
			-- Collect sources and destinations during the collapse window.
			-- Schedule a timer to start the timer once the window has
			-- ellapsed.
			table.insert(state.sources, sourceName)
			table.insert(state.dests, destName)
			if not state.collapseTimer then
				state.collapseTimer = self:ScheduleTimer(
						function ()
							local text = action.text
							text = string.gsub(text, "%%s",
									table.concat(state.sources, ", "))
							text = string.gsub(text, "%%d",
									table.concat(state.dests, ", "))
							self:StartTimer(action, text, action.duration,
									spellId)
							table.wipe(state.sources)
							table.wipe(state.dests)
							state.collapseTimer = nil
						end,
						action.collapse)
			end
		else
			-- Start the timer directly.
			local text = action.text
			text = string.gsub(text, "%%s", sourceName)
			text = string.gsub(text, "%%d", destName)
			self:StartTimer(action, text, action.duration, spellId)
		end
	elseif action.type == "yell" then
		-- Format the yell text and do the yell.
		local text = action.text
		text = string.gsub(text, "%%s", tostring(UnitName(self.sourceUnitId)))
		text = string.gsub(text, "%%d", tostring(UnitName(self.destUnitId)))
		ChatThrottleLib:SendChatMessage("NORMAL", "", text, "YELL")
	end
end

-- Cancels a rule.
function BossNotesRulesEngine:CancelRule (rule)
	-- Canceling a rule involves canceling all of its actions.
	for _, action in ipairs(rule.actions) do
		self:CancelAction(action)
	end
end

-- Cancels an action.
function BossNotesRulesEngine:CancelAction (action)
	local state = self.actionStates[action]
	if state then
		if action.type == "raidtarget" then
			for rta in pairs(state.rtas) do
				self:ClearRta(rta)
			end
			table.wipe(state.rtas)
		elseif action.type == "notification" then
			if state.collapseTimer then
				self:CancelTimer(state.collapseTimer)
				table.wipe(state.sources)
				table.wipe(state.dests)
				state.collapseTimer = nil
			end
		elseif action.type == "timer" then
			if state.collapseTimer then
				self:CancelTimer(state.collapseTimer)
				table.wipe(state.sources)
				table.wipe(state.dests)
				state.collapseTimer = nil
			end
			self:StopTimer(action)
		end
	end
end

-- Sends a notification.
function BossNotesRulesEngine:SendNotification (action, text, spellId)
	-- Display the notification.
	self:SendMessage("BOSS_NOTES_RULES_NOTIFICATION", action, text,
			action.important, spellId)
			
	-- Send a raid warning if this is requested and if the player is allowed to
	-- do so.
	if action.raidWarning and (IsRaidLeader() or IsRaidOfficer()) then
		ChatThrottleLib:SendChatMessage("NORMAL", "", text, "RAID_WARNING")
	end
end

-- (Re)starts a timer.
function BossNotesRulesEngine:StartTimer (action, text, duration, spellId)
	-- Start the timer.
	self:SendMessage("BOSS_NOTES_RULES_TIMER_START", action, text, duration,
			spellId)
	
	-- As the timer may have been restarted, a prewarning and/or repeat may
	-- yet be pending. If so, cancel them.
	local state = self.actionStates[action]
	if state.prewarnTimer then
		self:CancelTimer(state.prewarnTimer)
		state.prewarnTimer = nil
	end
	if state.repeatTimer then
		self:CancelTimer(state.repeatTimer)
		state.repeatTimer = nil
	end
	
	-- If a meaningful prewarning has been requested, schedule it.
	if action.prewarn and action.prewarn < duration then
		state.prewarnTimer = self:ScheduleTimer(
				function ()
					self:SendNotification(action,
							string.format(L["SOON"], text),
							spellId)
					state.prewarnTimer = nil
				end,
				duration - action.prewarn)
	end
	
	-- If the timer is repating, schedule a restart.
	if action.repeatDuration then
		state.repeatTimer = self:ScheduleTimer(
				function ()
					-- The rule may have been edited in the meantime. Recheck.
					if action.repeatDuration then
						self:StartTimer(action, text, action.repeatDuration,
								spellId)
					else
						state.repeatTimer = nil
					end
				end,
				duration)
	end
end

-- Stops a timer.
function BossNotesRulesEngine:StopTimer (action)
	-- Stop the timer.
	self:SendMessage("BOSS_NOTES_RULES_TIMER_STOP", action)
		
	-- Cancel the pending pre-warn and repeat timers, if any.
	local state = self.actionStates[action]
	if state then
		if state.prewarnTimer then
			self:CancelTimer(state.prewarnTimer)
			state.prewarnTimer = nil
		end
		if state.repeatTimer then
			self:CancelTimer(state.repeatTimer)
			state.repeatTimer = nil
		end
	end
end


----------------------------------------------------------------------
-- In combat model

--[[ 

The in combat model is maintained on a per-GUID basis. For each GUID,
the model tracks whether that GUID is in combat.

]]

-- Initializes the in combat model.
function BossNotesRulesEngine:InitializeInCombatModel ()
	self.inCombat = { }
end

-- Clears the in combat model.
function BossNotesRulesEngine:ClearInCombatModel ()
	table.wipe(self.inCombat)
end

-- Updates the in combat status for a unit ID and/or a GUID.
function BossNotesRulesEngine:UpdateInCombat (unitId, guid)
	guid = guid or UnitGUID(unitId)
	if guid and not self.inCombat[guid] then
		unitId = unitId or self:GetUnitIdByGuid(guid)
		-- We assume that all units are in combat when we obtain a unit ID.
		-- Using the UnitAffectingCombat function or testing whether the unit
		-- has a target may not work reliably.
		if unitId ~= "none" then
			self.inCombat[guid] = true
			if #self.events.entercombat > 0 or #self.cancels.entercombat > 0 then
				self.sourceUnitId = unitId
				self.sourceGuid = guid
				self.destUnitId = "none"
				self.destGuid = nil
				self.spellId = nil
				self:TriggerRules(self.events.entercombat)
				self:CancelRules(self.cancels.entercombat)
			end
		end
	end
end


----------------------------------------------------------------------
-- Unit ID state model

--[[

Most WoW APIs require a unit ID to function and input parameters to
the engine are generally _not_ unit IDs. Rather, these input parameters
are GUIDs, NPC IDs and unit names. The unit ID state model closes this
gap by efficiently mainaining a state model that allows for the dynamic
lookup of unit IDs by GUID, NPC ID or unit name.

For each unit ID there is a unit ID state table which in enqueued
in linked lists on per GUID, per NPC ID and per unit name basis.
The linked lists are maintained in a data structure called list map.
A list map is a table using GUID, NPC ID or unit name as its key and
pointing to the most recently enqueued unit ID state table for that
key.

Enqueueing and dequeueing unit ID state tables among the lists are
efficient constant time operations.

]]

-- Initializes the unit model.
function BossNotesRulesEngine:InitializeUnitIdStateModel ()
	-- Create data structures
	self.unitIdStates = { }
	self.unitIdStatesByGuid = self:CreateListMap("guid")
	self.unitIdStatesByNpcId = self:CreateListMap("npcId")
	self.unitIdStatesByName = self:CreateListMap("name")
	
	-- Create unit IDs
	self:CreateUnitIdState("player")
	self:CreateUnitIdState("mouseover")
	self:CreateUnitIdStateAndTarget("target")
	self:CreateUnitIdStateAndTarget("pet")
	self:CreateUnitIdStateAndTarget("focus")
	self:CreateUnitIdState("vehicle")
	for i = 1, MAX_PARTY_MEMBERS do
		self:CreateUnitIdStateAndTarget("party" .. tostring(i))
		self:CreateUnitIdStateAndTarget("partypet" .. tostring(i))
	end
	for i = 1, MAX_RAID_MEMBERS do
		self:CreateUnitIdStateAndTarget("raid" .. tostring(i))
		self:CreateUnitIdStateAndTarget("raidpet" .. tostring(i))
	end
	
	-- Sync player
	self:UpdateUnitIdState("player")
end

-- Creates a unit ID and its target.
function BossNotesRulesEngine:CreateUnitIdStateAndTarget (unitId)
	self:CreateUnitIdState(unitId)
	self:CreateUnitIdState(unitId .. "target")
end

-- Creates a unit ID.
function BossNotesRulesEngine:CreateUnitIdState (unitId)
	self.unitIdStates[unitId] = {
		unitId = unitId
	}
end

-- Provides an iterator on all managed unit IDs.
function BossNotesRulesEngine:UnitIds ()
	return pairs(self.unitIdStates)
end

-- Returns a unit ID by GUID.
function BossNotesRulesEngine:GetUnitIdByGuid (guid)
	for unitIdState in self.unitIdStatesByGuid:Entries(guid) do
		if UnitGUID(unitIdState.unitId) == guid then
			return unitIdState.unitId
		end
	end
	return "none"
end

-- Returns a unit by NPC ID.
function BossNotesRulesEngine:GetUnitIdByNpcId (npcId)
	for unitIdState in self.unitIdStatesByNpcId:Entries(npcId) do
		if BossNotes:GetNpcId(UnitGUID(unitIdState.unitId)) == npcId then
			return unitIdState.unitId
		end
	end
	return "none"
end
	
-- Returns a unit ID by name.
function BossNotesRulesEngine:GetUnitIdByName (name)
	for unitIdState in self.unitIdStatesByName:Entries(name) do
		if UnitName(unitIdState.unitId) == name then
			return unitIdState.unitId
		end
	end
	return "none"
end

-- Updates a unit ID state.
function BossNotesRulesEngine:UpdateUnitIdState (unitId)
	local unitIdState = self.unitIdStates[unitId]
	if unitIdState then
		-- Update GUID model
		local guid = UnitGUID(unitId)
		if guid ~= unitIdState.guid then
			self.unitIdStatesByGuid:Remove(unitIdState)
			unitIdState.guid = guid
			self.unitIdStatesByGuid:Add(unitIdState)
		end
		
		-- Update NPC ID model
		local npcId = BossNotes:GetNpcId(guid)
		if npcId ~= unitIdState.npcId then
			self.unitIdStatesByNpcId:Remove(unitIdState)
			unitIdState.npcId = npcId
			self.unitIdStatesByNpcId:Add(unitIdState)
		end

		-- Update name model
		local name = UnitName(unitId)
		if name ~= unitIdState.name then
			self.unitIdStatesByName:Remove(unitIdState)
			unitIdState.name = name
			self.unitIdStatesByName:Add(unitIdState)
		end
	end
end


----------------------------------------------------------------------
-- Raid target assignment (RTA) model

--[[

Raid targets are manged by a data structure called Raid Target
Assignment, or RTA for short. Each RTA assigns a raid target
to a GUID.

RTAs are managed in list maps on a per GUID and on a per raid
target basis. This allows to correctly resolve conflicting
raid target assignments. Conflicts may happen if a unit is
assigned multiple raid targets or if a raid target is assigned
to multiple units. In these cases, the engine operates on a
"most recent RTA wins" basis. Once an RTA expires and is cleared,
the previous RTA is restored.

At the beginning of an encounter, the current raid targets are
captured. This ensures that manually set raid targets are restored
once rule based raid targets assigned to a unit have expired.

]]

-- Initializes the RTA model.
function BossNotesRulesEngine:InitializeRtaModel ()
	self.rtaByGuid = self:CreateListMap("guid")
	self.rtaByRaidTarget = self:CreateListMap("raidTarget")
end

-- Marks the RTA model to the current raid targets.
function BossNotesRulesEngine:SetupRtaModel ()
	for unitId in self:UnitIds() do
		local raidTarget = GetRaidTargetIndex(unitId)
		if raidTarget and not self.rtaByRaidTarget[raidTarget] then
			self:SetRta(unitId, raidTarget, 0, true)
		end
	end
end

-- Clears the RTA model.
function BossNotesRulesEngine:ClearRtaModel ()
	-- Wipe the list maps. We deliberately do not invoke ClearRta on
	-- each RTA as this would also clear RTAs from the mark phase.
	-- When this method is invoked, the regular RTAs have already
	-- been cleared as the rules and associated actions have been
	-- canceled.
	table.wipe(self.rtaByGuid)
	table.wipe(self.rtaByRaidTarget)
end

-- Set an RTA. If the optional mark flag is asserted, the RTA is
-- created, but not set. This is used when marking the RTA model
-- to the current raid targets.
function BossNotesRulesEngine:SetRta (guid, raidTarget, duration, mark)
	-- An RTA assigns a raid target to a GUID. If there is no GUID,
	-- for example because the unit ID is "none", no RTA is created.
	-- The same applies if the raid target is 0.
	if guid and raidTarget ~= 0 then
		local rta = {
			guid = guid,
			raidTarget = raidTarget,
		}
		
		if not mark then
			-- Set the raid target, or mark the assignment as pending.
			local unitId = self:GetUnitIdByGuid(guid)
			if unitId ~= "none" then
				self:SetRaidTarget(unitId, raidTarget)
			else
				rta.pending = true
			end
			
			-- Schedule a timer to clear the RTA.
			rta.timer = self:ScheduleTimer(
					function ()
						rta.timer = nil
						self:ClearRta(rta)
					end,
					duration)
		end
		
		-- Enqueue the RTA on both list maps.
		self.rtaByGuid:Add(rta)
		self.rtaByRaidTarget:Add(rta)
		
		return rta
	end
end

-- Applies a pending raid target assignment for a unit ID.
function BossNotesRulesEngine:ApplyPendingRta (unitId)
	local rta = self.rtaByGuid[UnitGUID(unitId)]
	if rta and rta.pending and self.rtaByRaidTarget[rta.raidTarget] == rta then
		self:SetRaidTarget(unidId, rta.raidTarget)
		rta.pending = nil
	end
end

-- Clears an RTA, restoring state for both the GUID and the raid
-- target.
function BossNotesRulesEngine:ClearRta (rta)
	-- Only RTAs that have been applied must be cleared. Also, an RTA
	-- that already been cleared must not be cleared again.
	if not rta.pending and not rta.cleared then
		-- Determine if the RTA is current for the GUID and/or for
		-- the raid target. If so, the GUID and/or raid target may
		-- need to be reassigned.
		local currentForGuid = self.rtaByGuid[rta.guid] == rta
		local currentForRaidTarget = self.rtaByRaidTarget[rta.raidTarget] == rta
		
		-- Dequeue the RTA from both list maps and assert its cleared
		-- status.
		self.rtaByGuid:Remove(rta)
		self.rtaByRaidTarget:Remove(rta)
		rta.cleared = true
		
		-- Cancel the RTA timer if this RTA is cleared ahead of time.
		if rta.timer then
			self:CancelTimer(rta.timer)
			rta.timer = nil
		end
		
		-- Invoke the RTA callback, if any.
		if rta.callback then
			rta.callback(rta)
			rta.callback = nil
		end
		
		-- Fixup the GUID. If the cleared RTA was current for the GUID,
		-- check the last RTA for this GUID, if any, and restore it
		-- if the RTA is also current for the raid target. Otherwise,
		-- clear the raid target on the GUID.
		if currentForGuid then
			local unitId = self:GetUnitIdByGuid(rta.guid)
			local lastRta = self.rtaByGuid[rta.guid]
			if lastRta and self.rtaByRaidTarget[lastRta.raidTarget] == lastRta then
				if unitId ~= "none" then
					self:SetRaidTarget(unitId, lastRta.raidTarget)
					lastRta.pending = nil
				else
					lastRta.pending = true
				end
			else
				if unitId ~= "none" then
					self:SetRaidTarget(unitId, 0)
				end
			end
		end
		
		-- Fixup the raid target. If the cleared RTA was current for
		-- the raid target, check the last RTA for this raid target,
		-- if any, and restore it if the RTA is also current for the
		-- GUID.
		if currentForRaidTarget then
			local lastRta = self.rtaByRaidTarget[rta.raidTarget]
			if lastRta and self.rtaByGuid[lastRta.guid] == lastRta then
				local unitId = self:GetUnitIdByGuid(lastRta.guid)
				if unitId ~= "none" then
					self:SetRaidTarget(unitId, lastRta.raidTarget)
					lastRta.pending = nil
				else
					lastRta.pending = true
				end
			end
		end
	end
end

-- Sets a raid target.
function BossNotesRulesEngine:SetRaidTarget (unitId, raidTarget)
	if IsRaidLeader() or IsRaidOfficer() or not(UnitInRaid("player"))
			and GetNumPartyMembers() > 0 then
		SetRaidTarget(unitId, raidTarget)
	end
end


----------------------------------------------------------------------
-- List Map

--[[

The list map data structure represents a map with a linked list in each
of its keys. The linked lists contain the currently enqueued nodes.

The data structure uses a sentinel node to ease boundary condition
checks. Writes to the sentinel are discarded.

Each list map is created for a specific field in the enqueued nodes.
The field is used to lookup the current key of a node and thus
determine if and in which list a node is enqueued. Also, the field
extended by "Prev" and "Next" suffixes determines the fields where
the linked list is maintained. This design allows for a node to be
enqueued in multiple list maps at once.

The methods of a list map are kept in a separate table indexed by the
metatable of the list map. This is to ease operations on the list map.

The heavy weight nature of this data structure is acceptable as there
is only a small, static number of instances during the life cycle of
the engine.

]]

local SENTINEL = { }
setmetatable(SENTINEL, {
	__newindex = function ()
	end
})

-- Creates a new list map.		
function BossNotesRulesEngine:CreateListMap (field)
	local listMap = { }
	local prevField = field .. "Prev"
	local nextField = field .. "Next"
	local methods = { }
	function methods:Add (node)
		local key = node[field]
		if key then
			node[prevField] = self[key] or SENTINEL
			node[nextField] = SENTINEL
			node[prevField][nextField] = node
			self[key] = node
		end
	end
	function methods:Remove (node)
		local key = node[field]
		if key then
			if node[nextField] == SENTINEL then
				self[key] = node[prevField] ~= SENTINEL and node[prevField] or nil
			end
			node[prevField][nextField] = node[nextField]
			node[nextField][prevField] = node[prevField]
			node[prevField] = nil
			node[nextField] = nil
		end
	end
	local function next (first, current)
		if current then
			return current[prevField] ~= SENTINEL and current[prevField] or nil
		else
			return first
		end
	end
	function methods:Entries (key)
		return next, self[key], nil
	end
	setmetatable(listMap, { __index = methods })
	return listMap
end