--[[

$Revision: 325 $

(C) Copyright 2009,2010 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Documentation

--[[

The rule editor edits rules. The current rule is stored in 'self.rule'.
The associated instance, encounter and key are stored in 'self.instance',
'self.encounter' and 'self.key' respectively.

A rule is a nested table structure as described in the following sections.

Rule : {
	name : string,
		-- The rule name. This name is unique per key.
	enabled : boolean,
		-- Whether the rule is enabled.
	events = { Event, ... },
		-- An array of events.
	conditions = { Condition, ... },
		-- An array of conditions.
	actions = { Action, ... },
		-- An array of actions.
	cancels = { Event, ... },
		-- An array of cancels. Cancels share structure with events.
	spells = { Spell, ... },
		-- An array of custom spells.
	new : boolean or nil,
		-- If present, indicates the the rule is new (true). This is used
		-- by the editor to cause an insert operation into the collection
		-- of rules when the rule name becomes valid.
}

Rules follow the event-condition-action (ECA) praradigm and are inherently
stateless.

A rule is _triggered_ when any of its events occurs. Next, the rule
conditions are _evaluated_. If and only if all rule conditions evaluate
as true, the rule _fires_. Firing  the rule involves the _execution_
of all actions of the rule. Actions may be stateful, such as setting
a raid target. If any of the events listed as cancels occurs, any
stateful actions in progress are _canceled_.

The rule editor presents encounter-specific spells as recorded by the
Boss Notes Abilities module. However, in some cases custom player spells
are required in a rule definition. For example, a rule may need to 
trigger when a player gains Hand of Protection. Such player spells are
listed in the spells array. They are treated in the same way as spells
provided by Boss Notes Abilities.

In the following sections, the sub data structures making up a rule
are described in detail

Event : {
	type : Enum("cast", "aura", "emote", "unit"),
	
	type = "cast",
		-- Triggered on a matching _cast_ combatlog event. Suffixes of cast
		-- combatlog events are defined as BOSS_NOTES_RULES_CASTS.
	spellId : number,
		-- The ID of the spell. If the value is 0, the event is removed.
	suffix : number,
		-- One of the BOSS_NOTES_ABILITIES_* suffix constants, such as
		-- BOSS_NOTES_ABILITIES_CAST_SUCCESS. The suffix is matched to
		-- combat log events with a SPELL, SPELL_PERIODIC or RANGE prefix.
	
	type = "aura",
		-- Triggered on a matching _aura_ combatlog event. Suffxies of aura
		-- combatlog are defined as BOSS_NOTES_RULES_AURAS.
	spellId : number,
		-- The ID of the spell. If the value is 0, the event is removed.
	suffix : number,
		-- One of the BOSS_NOTES_ABILITIES_* suffix constants, such as
		-- BOSS_NOTES_ABILITIES_AURA_APPLIED. The suffix is matched to
		-- combat log events with a SPELL, SPELL_PERIODIC or RANGE prefix.
	
	type = "emote",
		-- Triggered on a matching boss emote.
	text : string,
		-- The emote text. Note that this cannot be stored in a locale
		-- independent way at this time. If the text is the empty string,
		-- the event is removed.
	locale : Sting,
		-- The locale, such as enUS.
	
	type = "unit",
		-- Triggered on a unit event.
	action = Enum("", "entercombat", "changetarget", "death")
		-- Identifies an action performed by a unit. If the value is the
		-- empty string, the event is removed.
}

Condition : {
	type : Enum("unit", "property", "npc", "aura", "range"),
	
	type = "unit",
		-- Compares two units.
	unit : Enum("", player", "focus", "pet", "eventsource", "eventdest"),
		-- Identifies the first root unit. If the value is the empty string,
		-- the condition is removed.
	unitSuffix : Enum("none", "target", "targettarget"),
		-- Suffix appended to the first root unit.
	operator : Enum("is", "isnot"),
		-- Whether the test is for equivalence or difference.
	secondUnit : Enum("player", "focus", "pet", "eventsource", "eventdest",
		-- Identifies the second unit.
		
	type = "property",
		-- Tests a unit for a property.
	unit : Enum("", "player", "focus", "pet", "eventsource", "eventdest"),
		-- Identifies the root unit. If the value is the empty string, the
		-- condition is removed.
	unitSuffix : Enum("none", "target", "targettarget"),
		-- Suffix appended to the first root unit.
	operator : Enum("is", "isnot"),
		-- Whether the test is for being or not being of the specified property.
	property : Enum("player", "playercontrolled", "party", "raid", "maintank", "mainassist"),
		-- Unit property to test: a player, a player controlled unit, a member of the party or raid,
		-- a main tank, a main assit or a specific NPC.
		
	type = "npc",
		-- Tests a unit for an NPC ID.
	unit : Enum("", "player", "focus", "pet", "eventsource", "eventdest"),
		-- Identifies the root unit. If the value is the empty string, the
		-- condition is removed.
	unitSuffix : Enum("none", "target", "targettarget"),
		-- Suffix appended to the first root unit.
	operator : Enum("is", "isnot"),
		-- Whether the test is for being or not being of the specified NPC ID.
	npcId : number,
		-- The NPC ID.
		
	type = "aura",
		-- Tests a unit for an aura.
	unit : Enum("", "player", "focus", "pet", "eventsource", "eventdest", "npc:%d"),
		-- Identifies the root unit which may be a specific NPC identified
		-- by its NPC ID. If the value is the empty string, the condition is removed.
	unitSuffix : Enum("none", "target", "targettarget"),
		-- Suffix appended to the root unit.
	operator : Enum("has", "hasnot"),
		-- Whether the test for the presence or absence of an aura.
	spellId : number,
		-- The ID of the spell.
	dose : number or nil,
		-- If present, requires that the specified number of stacks is matched.
		-- This value applies to auras that stack.
	count : number or nil,
		-- If present, requires that the specified number of instances is matched.
		-- This value applies to auras that are applied by multiple units.
	
	type = "range",
		-- Tests a unit for its distance to the player.
	unit : Enum("", "player", "focus", "pet", "eventsource", "eventdest"),
		-- Identifies the root unit. If the value is the empty string, the condition
		-- is removed.
	unitSuffix : Enum("none", "target", "targettarget"),
		-- Suffix appended to the root unit.
	operator : Enum("inrange", "notinrange"),
		-- Whether the test is for in range or out of range.
	range : Enum(10, 11, 18, 28),
		-- The range to test for.
}

Action : {
	type : Enum("raidtarget", "notification", "timer", "yell"),
	
	type = "raidtarget",
		-- Sets raid tagets(s).
	firstRaidTarget : number,
		-- The first raid target to set (1-8). If the value is 0, the
		-- action is removed.
	lastRaidTarget : number,
		-- The last raid target to set (1-8).
	setOn : Enum("eventsource", "eventdest"),
		-- Whether to set the raid targets on the event sources or
		-- event destinations.
	setOnSuffix : Enum("none", "target", "targettarget")
		-- The suffix appended to the unit from above.
	duration: number,
		-- Specifies an interval in seconds during which the raid
		-- target is assigned.
	collapse : number or nil,
		-- If present, specifies an interval in seconds during which
		-- the execution of this action causes the next raid target in
		-- the sequence to be set. After the interval has elapsed, the
		-- action resets to the first raid target. If not present, the
		-- first raid target is set each time this action is executed.
	distributed : boolean,
		-- If asserted, specifies that raid targets are to be set using
		-- the distributed raid target assignment protocol.
	
	type = "notification",
		-- Displays a textual notification.
	text : string,
		-- The text to display. %s and %d are substitued with the
		-- sources and destinations of the triggering events. If the
		-- value is the empty string, the action is removed.
	collapse : number or nil,
		-- If present, specifies an interval in seconds during which
		-- the execution of this action merely accumulates sources and
		-- destinations. Once the interval has elapsed, a single
		-- notification summarizing all souces and destinations
		-- affected is displayed. If not present, a notification is
		-- displayed each time this action is executed.
	important : boolean,
		-- Whether this notification may require immediate action by
		-- the player. Depending on the presentation add-on, this flag
		-- may trigger special treatment, such as a prominent sound or
		-- presentation in the middle of the the screen.
	raidWarning : boolean,
		-- Whether this notification is sent as a raid warning.
		
	type = "timer",
		-- Displays a timer.
	text : string, 
		-- The text to display. %s and %d are substitued with the source
		-- and destination of the triggering event. If the value is the empty
		-- string, the action is removed.
	duration : number,
		-- The initial interval of the timer in seconds.
	repeatDuration : number or nil,
		-- The repeat interval of the timer in seconds.
	prewarn : number or nil,
		-- If specified, causes a warning to be displayed before the timer
		-- expires. The	parameter specifies the interval between the warning
		-- and the expiration of the timer.
	collapse : number or nil,
		-- If present, specifies an interval in seconds during which
		-- the execution of this action merely accumulates sources and
		-- destinations. Once the interval has elapsed, a single
		-- timer summarizing all souces and destinations affected is started.
		-- If not present, the timer is (re)started each time this action is
		-- executed.
		
	type = "yell",
		-- Yells.
	text : string,
		-- The text to yell. %s and %d are substituted with the source
		-- and desination of the triggering event. If the value is the
		-- empty string, the action is removed.
}

Spell : {
	type : Enum("cast", "aura"),
	
	type = "cast",
		-- Indicates a custom spell used with cast suffixes as defined by
		-- the BOSS_NOTES_RULES_CASTS constant.
	spellId: number or nil,
		-- The ID of the custom spell. If the spell ID is not present,
		-- the spell is removed.

	type = "aura",
		-- Indicates a custom spell used with aura suffixes as defined by
		-- the BOSS_NOTES_RULES_AURAS constant.
	spellId: number or nil,
		-- The ID of the custom spell. If the spell ID is not present,
		-- the spell is removed.
}

NOTE: At runtime, spell IDs are matched by all spells with an equivalent
spell name. This is to ease the rule definition in situations where an
encounter involves multiple spells with the same name. The use of a specific
spell ID instead of a spell name is to facilitate the exchange of rules between
game clients with different locales.

]]


----------------------------------------------------------------------
-- Initialization

BossNotesRulesEditor = BossNotesRules:NewModule("Editor")
local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")
local AceGUI = LibStub("AceGUI-3.0")


----------------------------------------------------------------------
-- Constants

-- An empty spell
local EMPTY_SPELL = {
	name = "",
	suffixes = 0,
	spellId = 0,
	spellIds = { }
}

-- An empty emote
local EMPTY_EMOTE = {
	text = "",
	locale = GetLocale()
}

-- Map of suffixes to their names (number => string).
local SUFFIX_NAMES = { }
do 
	for name, suffix in pairs(BossNotesAbilities:GetSuffixes()) do
		SUFFIX_NAMES[suffix] = name
	end
end


----------------------------------------------------------------------
-- Rule Editor API

-- Shows the rule editor with a specified rule. If the rule parameter
-- is nil, a new rule is created.
function BossNotesRulesEditor:ShowRuleEditor (instance, encounter, rule)
	-- Close an already open editor
	self:CloseRuleEditor()

	-- Set data
	self.instance = instance
	self.encounter = encounter
	self.key = BossNotes:GetContextKey(instance, encounter)
	self.rule = rule
	
	-- Create the rule editor. An explicit Show() is required as the frame
	-- may be returned in hidden state from the AceGUI pool.
	self:CreateRuleEditor()
	self.ruleEditor:Show()
end

-- Closes the open rule editor (if any)
function BossNotesRulesEditor:CloseRuleEditor ()
	if self.ruleEditor then
		-- Release the rule editor back to the widget pool. Drop the
		-- reference to indidcate that no rule editor is currenlty open.
		self.ruleEditor:Release()
		self.ruleEditor = nil
		
		-- Clean up the rule by removing unused elements.
		self:RemoveInvalidElements()
		
		-- Invalidate the rule to update the display in case of changes.
		BossNotesRules:InvalidateRule(self.key, self.rule)
		
		-- Clear the rule
		self.instance = nil
		self.encounter = nil
		self.key = nil
		self.rule = nil
	end
end

-- Returns whether the rule editor is currenlty open on a specified rule.
function BossNotesRulesEditor:IsRuleEditorOpenOnRule (rule)
	return self.ruleEditor and self.rule == rule
end


----------------------------------------------------------------------
-- Rule Editor

-- Creates the rule editor. The rule editor frame contains some always visible
-- elements and a tab group with the rule elements.
function BossNotesRulesEditor:CreateRuleEditor ()
	self.ruleEditor = AceGUI:Create("Frame")
	self.ruleEditor:SetWidth(800)
	self.ruleEditor:SetTitle(L["RULE_EDITOR"])
	self.ruleEditor:SetCallback("OnClose",
			function (widget) self:CloseRuleEditor() end)
	self.ruleEditor:SetLayout("Flow")

	local nameEditBox = AceGUI:Create("EditBox")
	nameEditBox:DisableButton(true)
	nameEditBox:SetLabel(L["RULE_NAME"])
	nameEditBox:SetWidth(200)
	nameEditBox:SetUserData("validator", function (widget)
		-- Disallow empty rule names and ensure the rule name is unique.
		local name = strtrim(nameEditBox.editbox:GetText())
		if string.len(name) == 0 then
			return L["EMPTY_RULE_NAME"]
		end
		local rules = BossNotesRules:GetRules(self.key)
		for _, rule in ipairs(rules) do
			if rule ~= self.rule and rule.name == name then
				return L["DUPLICATE_RULE_NAME"]
			end
		end
	end)
	nameEditBox:SetCallback("OnTextChanged",
			function (widget, e, text)
				self:ValidateRuleEditor()
				if nameEditBox:GetUserData("valid") then
					self.rule.name = text
					BossNotesRules:InvalidateRule(self.key, self.rule)
				end
			end)
	nameEditBox:SetText(self.rule.name)
	self.ruleEditor:AddChild(nameEditBox)
	
	local enabledCheckBox = AceGUI:Create("CheckBox")
	enabledCheckBox:SetLabel(L["ENABLED"])
	enabledCheckBox:SetCallback("OnValueChanged",
			function (widget, e, value)
				self.rule.enabled = value
				BossNotesRules:InvalidateRule(self.key, self.rule)
			end)
	enabledCheckBox:SetValue(self.rule.enabled)
	self.ruleEditor:AddChild(enabledCheckBox)
	
	self.tabGroup = AceGUI:Create("TabGroup")
	self.tabGroup:SetFullWidth(true)
	self.tabGroup:SetLayout("Flow")
	self.tabGroup:SetTabs({
		{
			text = L["TAB_EVENT"],
			value ="event"
		},
		{
			text = L["TAB_CONDITION"],
			value = "condition"
		},
		{
			text = L["TAB_ACTION"],
			value = "action"
		},
		{
			text = L["TAB_CANCEL"],
			value = "cancel"
		},
		{
			text = L["TAB_SPELL"],
			value = "spell"
		}
	})
	self.tabGroup:SetCallback("OnGroupSelected",
			function (container, event, group)
				-- When switching tabs, cleanup the rule by removing
				-- unused elements. Then update the tab container to
				-- the new selection. Updating the tab container also
				-- causes a validation of the rule editor, thus
				-- updating the status text.
				self:RemoveInvalidElements()
				
				-- Invalidate the rule to update the display in case
				-- of changes.
				BossNotesRules:InvalidateRule(self.key, self.rule)
				
				-- Calculate the encounter elements as they may have
				-- changed by adding custom spells on the spell tab.
				self:CalculateEncounterElements()
				
				self:UpdateTabContainer(container, group)
			end)
	self.ruleEditor:AddChild(self.tabGroup)

	-- Select initial tab
	self.tabGroup:SelectTab("event")
end

-- Updates the tab container
function BossNotesRulesEditor:UpdateTabContainer (container, group)
	-- Re-initialize the tab container by releasing its children and then repopulating it
	-- based on the selected tab (group). Each tab consists of a heading, the current
	-- elements and a widget to add aditional element. Up to 5 elements can be added.
	self.container = container
	container:ReleaseChildren()
	
	-- Use a local function for events and cancels as these share structure.
	local function AddAddEventDropdown (events, tabGroup, addLabel)
		if #events < 5 then
			local addDropdown = AceGUI:Create("Dropdown")
			addDropdown:SetList({ })
			addDropdown:AddItem("", addLabel)
			addDropdown:AddItem("cast", L["TYPE_CAST"])
			addDropdown:AddItem("aura", L["TYPE_AURA"])
			addDropdown:AddItem("emote", L["TYPE_EMOTE"])
			addDropdown:AddItem("unit", L["TYPE_UNIT"])
			addDropdown:SetCallback("OnValueChanged",
					function (widget, e, value)
						local event
						if value == "cast" then
							event = {
								type = "cast",
								spellId = 0,
								suffix = 0
							}
						elseif value == "aura" then
							event = {
								type = "aura",
								spellId = 0,
								suffix = 0
							}
						elseif value == "emote" then
							event = {
								type = "emote",
								text = "",
								locale = GetLocale()
							}
						elseif value == "unit" then
							event = {
								type = "unit",
								action = "entercombat"
							}
						end
						if event then
							events[#events + 1] = event
						end
						self:UpdateTabContainer(container, tabGroup)
					end)
			addDropdown:SetValue("")
			container:AddChild(addDropdown)
		end
	end
	
	if group == "event" then
		local heading = AceGUI:Create("Heading")
		heading:SetText(L["EVENT_HEADING"])
		heading:SetFullWidth(true)
		container:AddChild(heading)
		
		for _, event in ipairs(self.rule.events) do
			self:AddEvent(container, event)
		end
		
		AddAddEventDropdown(self.rule.events, "event", L["ADD_EVENT"])
	elseif group == "condition" then
		local heading = AceGUI:Create("Heading")
		heading:SetText(L["CONDITION_HEADING"])
		heading:SetFullWidth(true)
		container:AddChild(heading)
		
		for _, condition in ipairs(self.rule.conditions) do
			self:AddCondition(container, condition)
		end
		
		if #self.rule.conditions < 5 then
			local addDropdown = AceGUI:Create("Dropdown")
			addDropdown:SetList({ })
			addDropdown:AddItem("", L["ADD_CONDITION"])
			addDropdown:AddItem("unit", L["TYPE_UNIT"])
			addDropdown:AddItem("property", L["TYPE_PROPERTY"])
			addDropdown:AddItem("npc", L["TYPE_NPC"])
			addDropdown:AddItem("aura", L["TYPE_AURA"])
			addDropdown:AddItem("range", L["TYPE_RANGE"])
			addDropdown:SetCallback("OnValueChanged",
					function (widget, e, value)
						local condition
						if value == "unit" then
							condition = {
								type = "unit",
								unit = "eventdest",
								unitSuffix = "none",
								operator = "is",
								secondUnit = "player"
							}
						elseif value == "property" then
							condition = {
								type = "property",
								unit = "eventdest",
								unitSuffix = "none",
								operator = "is",
								property = "player"
							}
						elseif value == "npc" then
							condition = {
								type = "npc",
								unit = "eventdest",
								unitSuffix = "none",
								operator = "is",
								npcId = 0
							}
						elseif value == "aura" then
							condition = {
								type = "aura",
								unit = "eventdest",
								unitSuffix = "none",
								operator = "has",
								spellId = 0
							}
						elseif value == "range" then
							condition = {
								type = "range",
								unit = "eventdest",
								unitSuffix = "none",
								operator = "inrange",
								range = 10
							}
						end
						if condition then
							self.rule.conditions[#self.rule.conditions + 1] = condition
						end
						self:UpdateTabContainer(container, "condition")
					end)
			addDropdown:SetValue("")
			container:AddChild(addDropdown)
		end
	elseif group == "action" then
		local heading = AceGUI:Create("Heading")
		heading:SetText(L["ACTION_HEADING"])
		heading:SetFullWidth(true)
		container:AddChild(heading)
		
		for _, action in ipairs(self.rule.actions) do
			self:AddAction(container, action)
		end

		if #self.rule.actions < 5 then
			local addDropdown = AceGUI:Create("Dropdown")
			addDropdown:SetList({ })
			addDropdown:AddItem("", L["ADD_ACTION"])
			addDropdown:AddItem("raidtarget", L["TYPE_RAID_TARGET"])
			addDropdown:AddItem("notification", L["TYPE_NOTIFICATION"])
			addDropdown:AddItem("timer", L["TYPE_TIMER"])
			addDropdown:AddItem("yell", L["TYPE_YELL"])
			addDropdown:SetCallback("OnValueChanged",
					function (widget, e, value)
						local action
						if value == "raidtarget" then
							action = {
								type = "raidtarget",
								setOn = "eventdest",
								setOnSuffix = "none",
								firstRaidTarget = 1,
								lastRaidTarget = 1,
								duration = 10.0,
								distributed = false
							}
						elseif value == "notification" then
							action = {
								type = "notification",
								text = "",
								important = false,
								raidWarning = false
							}
						elseif value == "timer" then
							action = {
								type = "timer",
								text = "",
								duration = 10.0
							}
						elseif value == "yell" then
							action = {
								type = "yell",
								text = ""
							}
						end
						if action then
							self.rule.actions[#self.rule.actions + 1] = action
						end
						self:UpdateTabContainer(container, "action")
					end)
			addDropdown:SetValue("")
			container:AddChild(addDropdown)
		end
	elseif group == "cancel" then
		local heading = AceGUI:Create("Heading")
		heading:SetText(L["CANCEL_HEADING"])
		heading:SetFullWidth(true)
		container:AddChild(heading)
		
		for _, cancel in ipairs(self.rule.cancels) do
			self:AddEvent(container, cancel)
		end
		
		AddAddEventDropdown(self.rule.cancels, "cancel", L["ADD_CANCEL"])
	elseif group == "spell" then
		local heading = AceGUI:Create("Heading")
		heading:SetText(L["SPELL_HEADING"])
		heading:SetFullWidth(true)
		container:AddChild(heading)
		
		for _, spell in ipairs(self.rule.spells) do
			self:AddSpell(container, spell)
		end
		
		if #self.rule.spells < 5 then
			local addDropdown = AceGUI:Create("Dropdown")
			addDropdown:SetList({ })
			addDropdown:AddItem("", L["ADD_SPELL"])
			addDropdown:AddItem("cast", L["TYPE_CAST"])
			addDropdown:AddItem("aura", L["TYPE_AURA"])
			addDropdown:SetCallback("OnValueChanged",
					function (widget, e, value)
						local spell
						if value == "cast" then
							spell = {
								type = "cast"
							}
						elseif value == "aura" then
							spell = {
								type = "aura"
							}
						end
						if spell then
							self.rule.spells[#self.rule.spells + 1] = spell
						end
						self:UpdateTabContainer(container, "spell")
					end)
			addDropdown:SetValue("")
			container:AddChild(addDropdown)
		end
	end
	
	-- (Re-)validate the editor after a container rebuild.
	self:ValidateRuleEditor()
end

-- Adds an event or cancel element to the tab container
function BossNotesRulesEditor:AddEvent (container, event)
	-- Local functions to add a spell/suffix pair
	local function AddSpellAndSuffix (filter, spellLabel)
		-- Declare the dropdowns
		local spellDropdown = AceGUI:Create("Dropdown")
		local suffixDropdown = AceGUI:Create("Dropdown") -- pre-create upvalue
		
		-- Declare a local function to set the suffix list
		local function SetSuffixList (spell)
			-- Iterate over all suffixes supported by the Boss Notes Abilities module.
			-- A suffix must match both the spell suffixes set and the filter to be added.
			-- As spells are only added to the spell dropdown if they have at least one
			-- suffix matching the filter, the suffix list is guaranteed to be non-empty.
			local selectedSuffix
			local firstSuffix
			local list = { }
			for suffix, name in pairs(SUFFIX_NAMES) do
				if bit.band(spell.suffixes, filter, suffix) ~= 0 then
					list[suffix] = name
					if suffix == event.suffix then
						selectedSuffix = suffix
					end
					if not firstSuffix or suffix < firstSuffix then
						firstSuffix = suffix
					end
				end
			end
			suffixDropdown:SetList(list)
			if not selectedSuffix then
				selectedSuffix = firstSuffix
			end
			event.suffix = selectedSuffix
			suffixDropdown:SetValue(event.suffix)
		end
	
		spellDropdown:SetLabel(spellLabel)
		spellDropdown:SetList({ })
		spellDropdown:AddItem(EMPTY_SPELL, L["LABEL_REMOVE"])
		local selectedSpell = EMPTY_SPELL
		for _, spell in ipairs(self.spells) do
			if bit.band(spell.suffixes, filter) ~= 0 then
				spellDropdown:AddItem(spell, spell.name)
				if spell.spellIds[event.spellId] then
					selectedSpell = spell
				end
			end
		end
		spellDropdown:SetCallback("OnValueChanged",
				function (widget, e, value)
					event.spellId = value.spellId
					SetSuffixList(value)
				end)
		event.spellId = selectedSpell.spellId
		spellDropdown:SetValue(selectedSpell)
		container:AddChild(spellDropdown)
		
		suffixDropdown:SetLabel(L["SUFFIX"])
		suffixDropdown:SetCallback("OnValueChanged",
				function (widget, e, value)	event.suffix = value end)
		SetSuffixList(selectedSpell)
		container:AddChild(suffixDropdown)
	end
	
	-- Each event adds a line to the tab container. Events are polymorphic. 
	-- The type of an event is determined by its 'type' field.
	if event.type == "cast" then
		AddSpellAndSuffix(BOSS_NOTES_RULES_CASTS, L["TYPE_CAST"])
		
		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	elseif event.type == "aura" then
		AddSpellAndSuffix(BOSS_NOTES_RULES_AURAS, L["TYPE_AURA"])

		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	elseif event.type == "emote" then
		local emoteDropdown = AceGUI:Create("Dropdown")
		emoteDropdown:SetLabel(L["TYPE_EMOTE"])
		emoteDropdown:SetWidth(400)
		emoteDropdown:SetList({ })
		emoteDropdown:AddItem(EMPTY_EMOTE, L["LABEL_REMOVE"])
		local selectedEmote = EMPTY_EMOTE
		for _, emote in ipairs(self.emotes) do
			emoteDropdown:AddItem(emote, emote.text)
			if emote.text == event.text then
				selectedEmote = emote
			end
		end
		emoteDropdown:SetCallback("OnValueChanged",
				function (widget, e, value)
					event.text = value.text
					event.locale = GetLocale()
				end)
		event.text = selectedEmote.text
		emoteDropdown:SetValue(selectedEmote)
		container:AddChild(emoteDropdown)

		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	elseif event.type == "unit" then
		local actionDropdown = AceGUI:Create("Dropdown")
		actionDropdown:SetLabel(L["TYPE_UNIT"])
		actionDropdown:SetList({ })
		actionDropdown:AddItem("", L["LABEL_REMOVE"])
		actionDropdown:AddItem("entercombat", L["ENTER_COMBAT"])
		actionDropdown:AddItem("changetarget", L["CHANGE_TARGET"])
		actionDropdown:AddItem("death", L["DEATH"])
		actionDropdown:SetCallback("OnValueChanged",
				function (widget, e, value)	event.action = value end)
		actionDropdown:SetValue(event.action)
		container:AddChild(actionDropdown)

		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	end
end

-- Adds a condition element to the tab container
function BossNotesRulesEditor:AddCondition (container, condition)
	-- Local function to add a unit dropdown
	local function AddUnitDropdown (field, primary, includeNpcs)
		local unitDropdown = AceGUI:Create("Dropdown")
		unitDropdown:SetLabel(L["UNIT"])
		unitDropdown:SetWidth(160)
		unitDropdown:SetList({ })
		if primary then
			unitDropdown:AddItem("", L["LABEL_REMOVE"])
		end
		unitDropdown:AddItem("player", L["PLAYER"])
		unitDropdown:AddItem("focus", L["FOCUS"])
		unitDropdown:AddItem("pet", L["PET"])
		unitDropdown:AddItem("eventsource", L["EVENT_SOURCE"])
		unitDropdown:AddItem("eventdest", L["EVENT_DEST"])
		if includeNpcs then
			local selectedNpcUnit
			for _, npc in ipairs(self.npcs) do
				local npcUnit = "npc:" .. tostring(npc.npcId)
				unitDropdown:AddItem(npcUnit, npc.name)
				if condition[field] == npcUnit then
					selectedNpcUnit = npcUnit
				end
			end
			if not selectedNpcUnit and string.sub(condition.unit, 1, 4) == "npc:" then
				condition[field] = ""
			end
		end
		unitDropdown:SetCallback("OnValueChanged",
				function (widget, e, value)	condition[field] = value end)
		unitDropdown:SetValue(condition[field])
		container:AddChild(unitDropdown)
		
		if primary then
			local suffixDropdown = AceGUI:Create("Dropdown")
			suffixDropdown:SetLabel(L["SUFFIX"])
			suffixDropdown:SetWidth(100)
			suffixDropdown:SetList({ })
			suffixDropdown:AddItem("none", L["NONE"])
			suffixDropdown:AddItem("target", L["TARGET"])
			suffixDropdown:AddItem("targettarget", L["TARGET_TARGET"])
			suffixDropdown:SetCallback("OnValueChanged",
					function (widget, e, value) condition[field .. "Suffix"] = value end)
			suffixDropdown:SetValue(condition[field .. "Suffix"])
			container:AddChild(suffixDropdown)
		end
	end

	-- Local function to add an operator drop down
	local function AddOperatorDropdown (...)
		local operatorDropdown = AceGUI:Create("Dropdown")
		operatorDropdown:SetLabel(L["OPERATOR"])
		operatorDropdown:SetWidth(100)
		operatorDropdown:SetList({ })
		for i = 1, select("#", ...), 2 do
			operatorDropdown:AddItem(select(i, ...), (select(i + 1, ...)))
		end
		operatorDropdown:SetCallback("OnValueChanged",
				function (widget, e, value) condition.operator = value end)
		operatorDropdown:SetValue(condition.operator)
		container:AddChild(operatorDropdown)
	end
	
	-- Local function to add an existing an integer edit box
	local function AddIntegerEditBox (integerEditBox, field, label, invalidLabel)
		integerEditBox:DisableButton(true)
		integerEditBox:SetLabel(label)
		integerEditBox:SetWidth(40)
		integerEditBox:SetUserData("validator", function (widget)
			local text = strtrim(widget.editbox:GetText())
			if string.len(text) > 0 then
				local integer = tonumber(text)
				if not integer or integer < 1 or integer % 1.0 ~= 0.0 then
					return invalidLabel
				end
			end
		end)
		integerEditBox:SetCallback("OnTextChanged",
				function (widget, e, text)
					self:ValidateRuleEditor()
					if integerEditBox:GetUserData("valid") then
						condition[field] = tonumber(text) -- may set field to nil
					end
				end)
		integerEditBox:SetText(condition[field] and tostring(condition[field]))
		container:AddChild(integerEditBox)
	end
	
	-- Each condition adds a line to the tab container. Conditions are
	-- polymorphic. The type of a condition is determined by its 'type'
	-- field.
	if condition.type == "unit" then
		AddUnitDropdown("unit", true, false)
		
		AddOperatorDropdown("is", L["OPERATOR_IS"], "isnot", L["OPERATOR_ISNOT"])

		AddUnitDropdown("secondUnit", false, false)
		
		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	elseif condition.type == "property" then
		AddUnitDropdown("unit", true, false)
		
		AddOperatorDropdown("is", L["OPERATOR_IS"], "isnot", L["OPERATOR_ISNOT"])
		local propertyDropdown = AceGUI:Create("Dropdown")
		propertyDropdown:SetLabel(L["TYPE_PROPERTY"])
		propertyDropdown:SetWidth(160)
		propertyDropdown:SetList({ })
		propertyDropdown:AddItem("player", L["PROP_PLAYER"])
		propertyDropdown:AddItem("playercontrolled", L["PROP_PLAYER_CONTROLLED"])
		propertyDropdown:AddItem("party", L["PROP_PARTY"])
		propertyDropdown:AddItem("raid", L["PROP_RAID"])
		propertyDropdown:AddItem("maintank", L["PROP_MAIN_TANK"])
		propertyDropdown:AddItem("mainassist", L["PROP_MAIN_ASSIST"])
		propertyDropdown:SetCallback("OnValueChanged",
				function (widget, e, value) condition.property = value end)
		propertyDropdown:SetValue(condition.property)
		container:AddChild(propertyDropdown)
		
		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	elseif condition.type == "npc" then
		AddUnitDropdown("unit", true, false)
		
		AddOperatorDropdown("is", L["OPERATOR_IS"], "isnot", L["OPERATOR_ISNOT"])
		
		local npcDropdown = AceGUI:Create("Dropdown")
		npcDropdown:SetLabel(L["TYPE_NPC"])
		npcDropdown:SetWidth(160)
		npcDropdown:SetList({ })
		local selectedNpcId
		for _, npc in ipairs(self.npcs) do
			npcDropdown:AddItem(npc.npcId, npc.name)
			if condition.npcId == npc.npcId or not selectedNpcId then
				selectedNpcId = npc.npcId
			end
		end
		if not selectedNpcId then
			npcDropdown:AddItem(0, "")
			selectedNpcId = 0
		end
		npcDropdown:SetCallback("OnValueChanged",
				function (widget, e, value)	condition.npcId = value end)
		condition.npcId = selectedNpcId
		npcDropdown:SetValue(selectedNpcId)
		container:AddChild(npcDropdown)
		
		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	elseif condition.type == "aura" then
		AddUnitDropdown("unit", true, true)
		
		AddOperatorDropdown("has", L["OPERATOR_HAS"], "hasnot", L["OPERATOR_HASNOT"])
		
		local spellDropdown = AceGUI:Create("Dropdown")
		local doseEditBox = AceGUI:Create("EditBox") -- pre-create upvalue
		local countEditBox = AceGUI:Create("EditBox")
		spellDropdown:SetLabel(L["TYPE_AURA"])
		spellDropdown:SetWidth(160)
		spellDropdown:SetList({ })
		local selectedSpell
		for _, spell in ipairs(self.spells) do
			if bit.band(spell.suffixes, BOSS_NOTES_RULES_AURAS) ~= 0 then
				spellDropdown:AddItem(spell, spell.name)
				if spell.spellIds[condition.spellId] or not selectedSpell then
					selectedSpell = spell
				end
			end
		end
		if not selectedSpell then
			spellDropdown:AddItem(EMPTY_SPELL, "")
			selectedSpell = EMPTY_SPELL
		end
		spellDropdown:SetCallback("OnValueChanged",
				function (widget, e, value)
					condition.spellId = value.spellId
					countEditBox:SetDisabled(value == EMPTY_SPELL)
					doseEditBox:SetDisabled(bit.band(value.suffixes, BOSS_NOTES_RULES_DOSES) == 0)
				end)
		condition.spellId = selectedSpell.spellId
		spellDropdown:SetValue(selectedSpell)
		countEditBox:SetDisabled(selectedSpell == EMPTY_SPELL)
		doseEditBox:SetDisabled(bit.band(selectedSpell.suffixes, BOSS_NOTES_RULES_DOSES) == 0)
		container:AddChild(spellDropdown)

		AddIntegerEditBox(countEditBox, "count", L["COUNT"], L["INVALID_COUNT"])
		
		AddIntegerEditBox(doseEditBox, "dose", L["DOSE"], L["INVALID_DOSE"])

		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	elseif condition.type == "range" then
		AddUnitDropdown("unit", true, false)
		
		AddOperatorDropdown("inrange", L["OPERATOR_INRANGE"],
				"notinrange", L["OPERATOR_NOTINRANGE"])
		
		local rangeDropdown = AceGUI:Create("Dropdown")
		rangeDropdown:SetLabel(L["TYPE_RANGE"])
		rangeDropdown:SetWidth(160)
		rangeDropdown:SetList({ })
		rangeDropdown:AddItem(10, L["RANGE_10"])
		rangeDropdown:AddItem(11, L["RANGE_11"])
		rangeDropdown:AddItem(18, L["RANGE_18"])
		rangeDropdown:AddItem(28, L["RANGE_28"])
		rangeDropdown:SetCallback("OnValueChanged",
				function (widget, e, value)	condition.range = value end)
		rangeDropdown:SetValue(condition.range)
		container:AddChild(rangeDropdown)

		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	end
end

-- Adds an action element to the tab container.
function BossNotesRulesEditor:AddAction (container, action)
	-- Declare a local function to add a time edit box
	local function AddTimeEditBox(field, label, invalidLabel, requiredLabel)
		local timeEditBox = AceGUI:Create("EditBox")
		timeEditBox:DisableButton(true)
		timeEditBox:SetLabel(label)
		timeEditBox:SetWidth(60)
		timeEditBox:SetUserData("validator", function (widget)
			local text = strtrim(widget.editbox:GetText())
			if string.len(text) > 0 then
				local time = tonumber(text)
				if not time or time < 0.1 then
					return invalidLabel
				end
			elseif requiredLabel then
				return requiredLabel
			end
		end)
		timeEditBox:SetCallback("OnTextChanged",
				function (widget, e, text)
					self:ValidateRuleEditor()
					if timeEditBox:GetUserData("valid") then
						action[field] = tonumber(text) -- may set field to nil
					end
				end)
		timeEditBox:SetText(action[field] and tostring(action[field]) or "")
		container:AddChild(timeEditBox)
	end
	
	-- Each action adds a line to the tab container. Actions are polymorphic. 
	-- The type of an action is determined by its 'type' field.
	if action.type == "raidtarget" then
		-- Local function for raid target dropdown initialization
		local function SetRaidTargetDropdownList (dropdown, from, includeRemove)
			dropdown:SetList({ })
			if includeRemove then
				dropdown:AddItem(0, L["LABEL_REMOVE"])
			end
			for i = from, 8 do
				dropdown:AddItem(i, BossNotesRules:GetRaidTargetTextureString(i, 10))
			end
		end
	
		local firstRaidTargetDropdown = AceGUI:Create("Dropdown")
		local lastRaidTargetDropdown = AceGUI:Create("Dropdown") -- pre-declare upvalue
		firstRaidTargetDropdown:SetLabel(L["FIRST_RAID_TARGET"])
		firstRaidTargetDropdown:SetWidth(100)
		SetRaidTargetDropdownList(firstRaidTargetDropdown, 1, true)
		firstRaidTargetDropdown:SetCallback("OnValueChanged",
				function (widget, e, value)
					action.firstRaidTarget = value
					SetRaidTargetDropdownList(lastRaidTargetDropdown, action.firstRaidTarget, false)
					if action.lastRaidTarget < action.firstRaidTarget then
						action.lastRaidTarget = action.firstRaidTarget
					end
					lastRaidTargetDropdown:SetValue(action.lastRaidTarget)
				end)
		firstRaidTargetDropdown:SetValue(action.firstRaidTarget)
		container:AddChild(firstRaidTargetDropdown)
		
		lastRaidTargetDropdown:SetLabel(L["LAST_RAID_TARGET"])
		lastRaidTargetDropdown:SetWidth(100)
		SetRaidTargetDropdownList(lastRaidTargetDropdown, action.firstRaidTarget, false)
		lastRaidTargetDropdown:SetCallback("OnValueChanged",
				function (widget, e, value)	action.lastRaidTarget = value end)
		lastRaidTargetDropdown:SetValue(action.lastRaidTarget)
		container:AddChild(lastRaidTargetDropdown)
		
		local setOnDropdown = AceGUI:Create("Dropdown")
		setOnDropdown:SetLabel(L["SET_ON"])
		setOnDropdown:SetWidth(140)
		setOnDropdown:SetList({ })
		setOnDropdown:AddItem("eventsource", L["EVENT_SOURCE"])
		setOnDropdown:AddItem("eventdest", L["EVENT_DEST"])
		setOnDropdown:SetCallback("OnValueChanged",
				function (widget, e, value)	action.setOn = value end)
		setOnDropdown:SetValue(action.setOn)
		container:AddChild(setOnDropdown)
		
		local setOnSuffixDropdown = AceGUI:Create("Dropdown")
		setOnSuffixDropdown:SetLabel(L["SUFFIX"])
		setOnSuffixDropdown:SetWidth(100)
		setOnSuffixDropdown:SetList({ })
		setOnSuffixDropdown:AddItem("none", L["NONE"])
		setOnSuffixDropdown:AddItem("target", L["TARGET"])
		setOnSuffixDropdown:AddItem("targettarget", L["TARGET_TARGET"])
		setOnSuffixDropdown:SetCallback("OnValueChanged",
				function (widget, e, value) action.setOnSuffix = value end)
		setOnSuffixDropdown:SetValue(action.setOnSuffix)
		container:AddChild(setOnSuffixDropdown)
		
		AddTimeEditBox("duration", L["DURATION"], L["INVALID_DURATION"], L["EMPTY_DURATION"])
		
		AddTimeEditBox("collapse", L["COLLAPSE"], L["INVALID_COLLAPSE"])
		
		local distributedCheckBox = AceGUI:Create("CheckBox")
		distributedCheckBox:SetLabel(L["DISTRIBUTED"])
		distributedCheckBox:SetWidth(100)
		distributedCheckBox:SetCallback("OnValueChanged",
				function (widget, e, value) action.distributed = value end)
		distributedCheckBox:SetValue(action.distributed)
		container:AddChild(distributedCheckBox)
		
		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	elseif action.type == "notification" then
		local textEditBox = AceGUI:Create("EditBox")
		textEditBox:DisableButton(true)
		textEditBox:SetLabel(L["TYPE_NOTIFICATION"])
		textEditBox:SetWidth(300)
		textEditBox:SetCallback("OnTextChanged",
				function (widget, e, text) action.text = strtrim(text) end)
		textEditBox:SetText(action.text)
		container:AddChild(textEditBox)
		
		AddTimeEditBox("collapse", L["COLLAPSE"], L["INVALID_COLLAPSE"])
		
		local importantCheckBox = AceGUI:Create("CheckBox")
		importantCheckBox:SetLabel(L["IMPORTANT"])
		importantCheckBox:SetWidth(100)
		importantCheckBox:SetCallback("OnValueChanged",
				function (widget, e, value) action.important = value end)
		importantCheckBox:SetValue(action.important)
		container:AddChild(importantCheckBox)
		
		local raidWarningCheckBox = AceGUI:Create("CheckBox")
		raidWarningCheckBox:SetLabel(L["RAID_WARNING"])
		raidWarningCheckBox:SetWidth(120)
		raidWarningCheckBox:SetCallback("OnValueChanged",
				function (widget, e, value) action.raidWarning = value end)
		raidWarningCheckBox:SetValue(action.raidWarning)
		container:AddChild(raidWarningCheckBox)
		
		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	elseif action.type == "timer" then
		local textEditBox = AceGUI:Create("EditBox")
		textEditBox:DisableButton(true)
		textEditBox:SetLabel(L["TYPE_TIMER"])
		textEditBox:SetWidth(300)
		textEditBox:SetCallback("OnTextChanged",
				function (widget, e, text) action.text = strtrim(text) end)
		textEditBox:SetText(action.text)
		container:AddChild(textEditBox)

		AddTimeEditBox("duration", L["DURATION"], L["INVALID_DURATION"], L["EMPTY_DURATION"])
		
		AddTimeEditBox("repeatDuration", L["REPEAT"], L["INVALID_REPEAT"])
		
		AddTimeEditBox("prewarn", L["PREWARN"], L["INVALID_PREWARN"])
		
		AddTimeEditBox("collapse", L["COLLAPSE"], L["INVALID_COLLAPSE"])
		
		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	elseif action.type == "yell" then
		local textEditBox = AceGUI:Create("EditBox")
		textEditBox:DisableButton(true)
		textEditBox:SetLabel(L["TYPE_YELL"])
		textEditBox:SetWidth(300)
		textEditBox:SetCallback("OnTextChanged",
				function (widget, e, text) action.text = strtrim(text) end)
		textEditBox:SetText(action.text)
		container:AddChild(textEditBox)

		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	end
end

-- Adds a spell to the tab container
function BossNotesRulesEditor:AddSpell (container, spell)
	-- Each spell  adds a line to the tab container. Spells are polymorphic. 
	-- The type of a spell is determined by its 'type' field.
	if spell.type == "cast" or spell.type == "aura" then
		-- Pre-create widgets for direct upvalued references from within
		-- callbacks.
		local spellIdEditBox = AceGUI:Create("EditBox")
		local spellIcon = AceGUI:Create("Icon")
		local spellLabel = AceGUI:Create("Label")

		-- Declare a local function to update spell details
		local function UpdateSpellDetails (spellId)
			spellId = spellId or 0
			local name, _, iconPath = GetSpellInfo(spellId)
			if name and iconPath then
				spellIcon:SetImage(iconPath)
				spellLabel:SetText(name)
			else
				spellIcon:SetImage("Interface\\Icons\\Temp.blp")
				spellLabel:SetText(" ")
			end
		end
		
		local typeLabel = AceGUI:Create("Label")
		typeLabel:SetWidth(100)
		typeLabel:SetText(spell.type == "cast" and L["TYPE_CAST"] or L["TYPE_AURA"])
		container:AddChild(typeLabel)
		
		spellIdEditBox:DisableButton(true)
		spellIdEditBox:SetLabel(L["SPELL_ID"])
		spellIdEditBox:SetWidth(60)
		spellIdEditBox:SetUserData("validator", function (widget)
			local text = strtrim(widget.editbox:GetText())
			if string.len(text) == 0 then
				return
			end
			local spellId = tonumber(text)
			if not spellId or not GetSpellInfo(spellId) then
				return L["INVALID_SPELL_ID"]
			end
		end)
		spellIdEditBox:SetCallback("OnTextChanged",
				function (widget, e, text)
					self:ValidateRuleEditor()
					if spellIdEditBox:GetUserData("valid") then
						spell.spellId = tonumber(strtrim(text)) -- may set spellId to nil
						UpdateSpellDetails(spell.spellId)
					else
						UpdateSpellDetails(nil)
					end
				end)
		spellIdEditBox:SetText(spell.spellId or "")
		container:AddChild(spellIdEditBox)

		spellIcon:SetWidth(22)
		spellIcon:SetHeight(22)
		spellIcon:SetImageSize(16, 16)
		container:AddChild(spellIcon)
		
		spellLabel:SetWidth(128)
		container:AddChild(spellLabel)
		UpdateSpellDetails(spell.spellId)

		local fillLabel = AceGUI:Create("Label")
		fillLabel:SetFullWidth(true)
		container:AddChild(fillLabel)
	end
end

-- Removes invalid elements from the current rule.
function BossNotesRulesEditor:RemoveInvalidElements ()
	for i = #self.rule.events, 1, -1 do
		if not self:IsValidEventOrCancel(self.rule.events[i]) then
			table.remove(self.rule.events, i)
		end
	end
	for i = #self.rule.conditions, 1, -1 do
		if not self:IsValidCondition(self.rule.conditions[i]) then
			table.remove(self.rule.conditions, i)
		end
	end
	for i = #self.rule.actions, 1, -1 do
		if not self:IsValidAction(self.rule.actions[i]) then
			table.remove(self.rule.actions, i)
		end
	end
	for i = #self.rule.cancels, 1, -1 do
		if not self:IsValidEventOrCancel(self.rule.cancels[i]) then
			table.remove(self.rule.cancels, i)
		end
	end
	for i = #self.rule.spells, 1, -1 do
		if not self:IsValidSpell(self.rule.spells[i]) then
			table.remove(self.rule.spells, i)
		end
	end
end


----------------------------------------------------------------------
-- Validation

-- Validates the status of the rule editor.
function BossNotesRulesEditor:ValidateRuleEditor ()
	-- Recusively validate the widgets.
	local valid = true
	valid = self:ValidateWidgetRecursive(self.ruleEditor, valid)
	
	-- Clear the status text if the editor is valid
	if valid then
		self.ruleEditor:SetStatusText("")
	end
	
	return valid
end

-- Recusively validates widgets. A widget is flagged for validation by
-- setting a user data element with key 'validator'. The validator is a
-- function that returns an error string if the widget is invalid.
-- The first invalid widget encountered sets the status text to the error
-- string. A user data element 'valid' is set in all widgets with a
-- validator, indiciating the status of the validation. The method
-- returns the outcome of the validation
function BossNotesRulesEditor:ValidateWidgetRecursive (widget, valid)
	local validator = widget:GetUserData("validator")
	if validator then
		local statusText = validator(widget)
		if statusText and valid then
			self.ruleEditor:SetStatusText(statusText)
			valid = false
		end
		widget:SetUserData("valid", not statusText)
	end
	
	if widget.children then
		for _, child in ipairs(widget.children) do
			valid = self:ValidateWidgetRecursive(child, valid)
		end
	end
	
	return valid
end


----------------------------------------------------------------------
-- Data management

-- Creates a new rule.
function BossNotesRulesEditor:CreateRule (name)
	return {
		name = name,
		enabled = true,
		events = { },
		conditions = { },
		actions = { },
		cancels = { },
		spells = { }
	}
end

-- Tests whether a rule is entriely valid.
function BossNotesRulesEditor:IsValidRule (rule)
	if string.len(rule.name) == 0 then
		return false
	end
	for _, event in ipairs(rule.events) do
		if not self:IsValidEventOrCancel(event) then
			return false
		end
	end
	for _, condition in ipairs(rule.conditions) do
		if not self:IsValidCondition(condition) then
			return false
		end
	end
	for _, action in ipairs(rule.actions) do
		if not self:IsValidAction(action) then
			return false
		end
	end
	for _, cancel in ipairs(rule.cancels) do
		if not self:IsValidEventOrCancel(cancel) then
			return false
		end
	end
	for _, spell in ipairs(rule.spells) do
		if not self:IsValidSpell(spell) then
			return false
		end
	end
	return true
end
	
-- Returns whether an event or cancel is valid.
function BossNotesRulesEditor:IsValidEventOrCancel (event)
	return event.type == "cast" and event.spellId ~= 0 or
			event.type == "aura" and event.spellId ~= 0 or
			event.type == "emote" and event.text ~= "" or
			event.type == "unit" and event.action ~= ""
end

-- Returns whether a condition is valid.
function BossNotesRulesEditor:IsValidCondition (condition)
	return condition.unit ~= "" and (
		condition.type == "unit" or
		condition.type == "property" or
		condition.type == "npc" and condition.npcId ~= 0 or
		condition.type == "aura" and condition.spellId ~= 0 or
		condition.type == "range")
end

-- Returns whether an action is valid.
function BossNotesRulesEditor:IsValidAction (action)
	return action.type == "raidtarget" and action.firstRaidTarget ~= 0 or
			action.type == "notification" and action.text ~= "" or
			action.type == "timer" and action.text ~= "" or
			action.type == "yell" and action.text ~= ""
end

-- Returns whether a spell is valid.
function BossNotesRulesEditor:IsValidSpell (spell)
	return spell.spellId ~= nil
end

-- Calculates the known NPCs, spells and emotes of an encounter.
function BossNotesRulesEditor:CalculateEncounterElements ()
	-- Consolidate NPCs by name.
	self.npcs = { }
	local npcIds = BossNotes:GetNpcIds(self.instance, self.encounter)
	local npcs = { }
	for _, npcId in ipairs(npcIds) do
		local npcName = BossNotesAbilities:GetNpcName(npcId)
				or BossNotesEmotes:GetNpcName(npcId)
				or tostring(npcId)
		if not npcs[npcName] then
			npcs[npcName] = {
				name = npcName,
				npcId = npcId,
				npcIds = { }
			}
		end
		npcs[npcName].npcIds[npcId] = true
	end
	for _, npc in pairs(npcs) do
		table.insert(self.npcs, npc)
	end
	table.sort(self.npcs, function (a, b) return a.name < b.name end)
	
	-- Consolidate spells by name. We assume that choosing a spell by
	-- name provides provides sufficient precision in practice. We
	-- retain the ability for the efficient implementation of a rule
	-- interpreter by mapping spell names back to a set of spell IDs.
	self.spells = { }
	local spells = { }
	
	-- Consolidate spells from the Abilities module
	local npcIds = BossNotes:GetNpcIds(self.instance, self.encounter)
	for _, npcId in ipairs(npcIds) do
		local npcSpells = BossNotesAbilities:GetSpells(npcId)
		for _, spell in ipairs(npcSpells) do
			if not spells[spell.name] then
				spells[spell.name] = {
					name = spell.name,
					suffixes = 0,
					spellId = spell.spellId,
					spellIds = { }
				}
			end
			spells[spell.name].suffixes = bit.bor(
					spells[spell.name].suffixes,
					spell.suffixes)
			spells[spell.name].spellIds[spell.spellId] = true
		end
	end
	
	-- Consolidate custom spells
	for _, spell in pairs(self.rule.spells) do
		local name = GetSpellInfo(spell.spellId)
		local suffixes = spell.type == "cast" and BOSS_NOTES_RULES_CASTS
				or spell.type == "aura" and BOSS_NOTES_RULES_AURAS
				or 0
		if not spells[name] then
			spells[name] = {
				name = name,
				suffixes = 0,
				spellId = spell.spellId,
				spellIds = { }
			}
		end
		spells[name].suffixes = bit.bor(spells[name].suffixes, suffixes)
		spells[name].spellIds[spell.spellId] = true
	end
	
	-- Sort spells by name
	for _, spell in pairs(spells) do
		table.insert(self.spells, spell)
	end
	table.sort(self.spells, function (a, b) return a.name < b.name end)
	
	-- Directly consolidate emotes from all NPCs involved with the
	-- encounter.
	self.emotes = { }
	if npcIds then
		for _, npcId in ipairs(npcIds) do
			local npcEmotes = BossNotesEmotes:GetEmotes(npcId)
			for _, emote in ipairs(npcEmotes) do
				table.insert(self.emotes, emote)
			end
		end
		table.sort(self.emotes, function (a, b) return a.text < b.text end)
	end
end
