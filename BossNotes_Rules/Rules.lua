--[[

$Revision: 348 $

(C) Copyright 2009,2010 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

BossNotesRules = LibStub("AceAddon-3.0"):NewAddon("BossNotesRules",
		"AceTimer-3.0",
		"AceComm-3.0",
		"AceSerializer-3.0",
		"LibSchema-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")


----------------------------------------------------------------------
-- Constants

-- Database version
BOSS_NOTES_RULES_DATABASE_VERSION = 2

-- Provider name
BOSS_NOTES_RULES_PROVIDER = "RULES"

-- Comm prefix
BOSS_NOTES_RULES_COMM_PREFIX = "BossNotesRules"

-- Suffixes used with casts
BOSS_NOTES_RULES_CASTS = 
	BOSS_NOTES_ABILITIES_DAMAGE +
	BOSS_NOTES_ABILITIES_MISSED +
	BOSS_NOTES_ABILITIES_HEAL +
	BOSS_NOTES_ABILITIES_ENERGIZE +
	BOSS_NOTES_ABILITIES_DRAIN +
	BOSS_NOTES_ABILITIES_LEECH +
	BOSS_NOTES_ABILITIES_INTERRUPT +
	BOSS_NOTES_ABILITIES_DISPEL +
	BOSS_NOTES_ABILITIES_DISPEL_FAILED +
	BOSS_NOTES_ABILITIES_STOLEN +
	BOSS_NOTES_ABILITIES_EXTRA_ATTACKS +
	BOSS_NOTES_ABILITIES_CAST_START + 
	BOSS_NOTES_ABILITIES_CAST_SUCCESS +
	BOSS_NOTES_ABILITIES_CAST_FAILED +
	BOSS_NOTES_ABILITIES_INSTAKILL +
	BOSS_NOTES_ABILITIES_DURABILITY_DAMAGE +
	BOSS_NOTES_ABILITIES_DURABILITY_DAMAGE_ALL +
	BOSS_NOTES_ABILITIES_CREATE +
	BOSS_NOTES_ABILITIES_SUMMON +
	BOSS_NOTES_ABILITIES_RESURRECT 
	
-- Suffixes used with auras
BOSS_NOTES_RULES_AURAS = 
	BOSS_NOTES_ABILITIES_AURA_APPLIED +
	BOSS_NOTES_ABILITIES_AURA_REMOVED +
	BOSS_NOTES_ABILITIES_AURA_APPLIED_DOSE +
	BOSS_NOTES_ABILITIES_AURA_REMOVED_DOSE +
	BOSS_NOTES_ABILITIES_AURA_REFRESH +
	BOSS_NOTES_ABILITIES_AURA_BROKEN +
	BOSS_NOTES_ABILITIES_AURA_BROKEN_SPELL
	
-- Suffixes used with auras supporting a dose
BOSS_NOTES_RULES_DOSES =
	BOSS_NOTES_ABILITIES_AURA_APPLIED_DOSE +
	BOSS_NOTES_ABILITIES_AURA_REMOVED_DOSE

-- DB defaults
local DB_DEFAULTS = {
	char = {
		rules = { }
	},
	global = {
		globalRules = false,
		display = {
			SimpleDisplay = true
		},
		rules = { }
	}
}

-- Ace configuration options
local ACE_OPTS = {
	name = L["RULES"],
	desc = L["RULES_DESC"],
	handler = BossNotesRules,
	type = "group",
	args = {
		global = {
			name = L["GLOBAL_RULES"],
			desc = L["GLOBAL_RULES_DESC"],
			order = 1,
			type = "toggle",
			get = "GetGlobalRules",
			set = "SetGlobalRules"
		},
		fire  = {
			name = L["FIRE"],
			desc = L["FIRE_DESC"],
			order = 2,
			guiHidden = true,
			type = "input",
			set = "FireRule"
		}
	}
}
BossNotes:MergeOptions("rules", ACE_OPTS)

-- Empty table
local EMPTY = { }

-- Static popup dialog for confirming the removal of a rule.
StaticPopupDialogs["BOSS_NOTES_RULES_REMOVE_RULE"] = {
	text = L["REMOVE_RULE_PROMPT"],
	button1 = YES,
	button2 = NO,
	OnCancel = function (self) end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}

-- Static popup dialog for confirming the replacing of a single rule
StaticPopupDialogs["BOSS_NOTES_RULES_ACCEPT_RULE"] = {
	text = L["ACCEPT_RULE_PROMPT"],
	button1 = YES,
	button2 = NO,
	OnCancel = function (self) end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}

-- Static popup dialog for confirming the replacing of a multiple rules
StaticPopupDialogs["BOSS_NOTES_RULES_ACCEPT_RULES"] = {
	text = L["ACCEPT_RULES_PROMPT"],
	button1 = YES,
	button2 = NO,
	OnCancel = function (self) end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}


----------------------------------------------------------------------
-- Core handlers

-- One-time initialization
function BossNotesRules:OnInitialize ()
	-- Database
	self.db = LibStub("AceDB-3.0"):New("BossNotesRulesDB", DB_DEFAULTS, true)
	self:MigrateDatabase(BOSS_NOTES_RULES_DATABASE_VERSION)
	
	-- Schemas
	self:CreateSchemas()
	
	-- Calculate the initial order value for display modules.
	local order = 1
	for _, value in pairs(ACE_OPTS.args) do
		local existingOrder = value.order or 0
		if existingOrder >= order then
			order = existingOrder + 1
		end
	end
	ACE_OPTS.args.displays = {
		name = L["DISPLAYS"],
		order = order,
		type = "header"
	}
	order = order + 1
	
	-- Process all display modules
	for moduleName, module in self:IterateModules() do
		if module.BOSS_NOTES_RULES_DISPLAY_MODULE then
			-- Add the display module to the Ace options table if it is
			-- supported.
			local key, name, desc = module:GetDisplayInfo()
			ACE_OPTS.args[key] = {
				name = name,
				desc = desc,
				order = order,
				arg = moduleName,
				type = "toggle",
				get = "GetDisplayModuleState",
				set = "SetDisplayModuleState"
			}
			order = order + 1
			
			-- If the module is not not enabled, set its enabled state
			-- to false to prevent enabling.
			local enabled = self.db.global.display[moduleName]
			if not enabled then
				module:SetEnabledState(false)
			end
		end
	end
	
	-- Setup distributed raid target assignments
	self.raidTargets = { }
	for i = 1, 8 do
		self.raidTargets[i] = { }
	end
end

-- Handles the (re-)enabling of this add-on
function BossNotesRules:OnEnable ()
	-- Register for comm
	self:RegisterComm(BOSS_NOTES_RULES_COMM_PREFIX)

	-- Register provider
	BossNotes:RegisterProvider(BOSS_NOTES_RULES_PROVIDER, {
		OnSources = function (instance, encounter)
			return self:OnSources(instance, encounter)
		end,
		OnHyperlinkClick = function (instance, encounter, source, link, text, button)
			return self:OnHyperlinkClick(instance, encounter, source, link, text, button)
		end
	})
end

-- Handles the disabling of this add-on
function BossNotesRules:OnDisable ()
	-- Unregister provider
	BossNotes:UnregisterProvider(BOSS_NOTES_RULES_PROVIDER)
end


----------------------------------------------------------------------
-- BossNotes provider

-- Returns the rules source
function BossNotesRules:OnSources (instance, encounter)
	-- Build HTML
	local html = { }
	table.insert(html, "<html><body>")

	-- Add rules
	local key = BossNotes:GetContextKey(instance, encounter)
	local rules = self:GetRules(key)
	for index, rule in ipairs(rules) do
		table.insert(html, string.format("<h1>%s</h1>", self:EscapeXmlEntities(rule.name)))
		if rule.enabled then
			for _, action in ipairs(rule.actions) do
				if action.type == "raidtarget" then
					if action.lastRaidTarget == action.firstRaidTarget or
							not action.collapse then
						table.insert(html, "<p>" .. string.format(L["RULE_ACTION_RAID_TARGET"],
								self:GetRaidTargetTextureString(action.firstRaidTarget))
								.. "</p>")
					else
						table.insert(html, "<p>" .. string.format(L["RULE_ACTION_RAID_TARGETS"],
								self:GetRaidTargetTextureString(action.firstRaidTarget),
								self:GetRaidTargetTextureString(action.lastRaidTarget))
								.. "</p>")
					end
				elseif action.type == "notification" then
					table.insert(html, "<p>" .. string.format(L["RULE_ACTION_NOTIFICATION"],
							self:EscapeXmlEntities(action.text)) .. "</p>")
				elseif action.type == "timer" then
					table.insert(html, "<p>" .. string.format(L["RULE_ACTION_TIMER"],
							self:EscapeXmlEntities(action.text),
							action.duration or 0.0) .. "</p>")
				elseif action.type == "yell" then
					table.insert(html, "<p>" .. string.format(L["RULE_ACTION_YELL"],
							self:EscapeXmlEntities(action.text)) .. "</p>")
				end
			end
			if #rule.actions ==0 then
				table.insert(html, "<p>" .. L["RULE_NO_ACTIONS"] .. "</p>")
			end
		else
			table.insert(html, "<p>" .. L["RULE_DISABLED"] .. "</p>")
		end
		table.insert(html,  "<p>"
				.. self:GetHyperlink(string.format("edit_rule:%d", index), L["EDIT_RULE"]) .. " "
				.. self:GetHyperlink(string.format("remove_rule:%d", index), L["REMOVE_RULE"]) .. " "
				.. self:GetHyperlink(string.format("broadcast_rule:%d", index), L["BROADCAST_RULE"])
				.. "</p>")
		table.insert(html, "<br />")
	end
	if #rules == 0 then
		table.insert(html, "<p>" .. L["NO_RULES"] .. "</p>")
		table.insert(html, "<br />")
	end
	
	-- Rule operations
	table.insert(html, "<p>"
			.. self:GetHyperlink("add_rule", L["ADD_RULE"])
			.. (#rules > 0 and " " .. self:GetHyperlink("broadcast_rules", L["BROADCAST_RULES"]) or "")
			.. "</p>")
	
	-- Close
	table.insert(html, "</body></html>")
	
	return {
		title = L["RULES"],
		content = table.concat(html, "\n"),
		xKey = key
	}
end

-- Handles hyperlink clicks
function BossNotesRules:OnHyperlinkClick (instance, encounter, source, link, text, button)
	-- Edit rule
	local editIndex = string.match(link, "edit_rule:(%d+)")
	if editIndex then
		self:GetModule("Editor"):ShowRuleEditor(instance, encounter,
				self:GetRules(source.xKey)[tonumber(editIndex)])
		return
	end
	
	-- Remove rule
	local removeIndex = string.match(link, "remove_rule:(%d+)")
	if removeIndex then
		local rule = self:GetRules(source.xKey)[tonumber(removeIndex)]
		StaticPopupDialogs["BOSS_NOTES_RULES_REMOVE_RULE"].OnAccept = function ()
			self:RemoveRule(source.xKey, rule)
		end
		StaticPopup_Show("BOSS_NOTES_RULES_REMOVE_RULE", rule.name)
		return
	end
	
	-- Broadcast rule
	local broadcastIndex = string.match(link, "broadcast_rule:(%d+)")
	if broadcastIndex then
		local rule = self:GetRules(source.xKey)[tonumber(broadcastIndex)]
		if self:GetModule("Editor"):IsValidRule(rule) then
			if self:CanBroadcast() then
				BossNotes:Print(string.format(L["SENDING_RULE"], rule.name))
				self:Broadcast({
					type = "rule",
					key = source.xKey,
					rule = rule
				})
			else
				BossNotes:Print(L["NOT_IN_RAID_OR_PARTY"])
			end
		else
			BossNotes:Print(string.format(L["INVALID_RULE"], rule.name))
		end
	end
	
	-- Add rule
	if link == "add_rule" then
		-- Find an unused rule name.
		local name
		local rules = self:GetRules(source.xKey)
		local i = 0
		repeat
			i = i + 1
			name = L["NEW_RULE"]
			if i > 1 then
				name = name .. " (" .. tostring(i) .. ")"
			end
			local exists = false
			for _, rule in ipairs(rules) do
				if rule.name == name then
					exists = true
					break
				end
			end
		until not exists
		
		-- Create and add the rule
		local editor = self:GetModule("Editor")
		local rule = editor:CreateRule(name)
		self:AddRule(source.xKey, rule)
		
		-- Show the editor.
		editor:ShowRuleEditor(instance, encounter, rule)
		
		return
	end
	
	-- Broadcast rules
	if link == "broadcast_rules" then
		local rules = self:GetRules(source.xKey)
		local validRules = { }
		for _, rule in ipairs(rules) do
			if self:GetModule("Editor"):IsValidRule(rule) then
				table.insert(validRules, rule)
			end
		end
		if #validRules > 0 then
			if self:CanBroadcast() then
				BossNotes:Print(string.format(L["SENDING_RULES"], #validRules))
				self:Broadcast({
					type = "rules",
					key = source.xKey,
					rules = validRules
				})
			else
				BossNotes:Print(L["NOT_IN_RAID_OR_PARTY"])
			end
		end
		if #rules - #validRules > 0 then
			BossNotes:Print(string.format(L["INVALID_RULES"], #rules - #validRules))
		end
	end
end


----------------------------------------------------------------------
-- API

-- Returns the rules for a key.
function BossNotesRules:GetRules (key)
	local rules = self.db.global.globalRules and self.db.global.rules[key]
			or not self.db.global.globalRules and self.db.char.rules[key]
	return rules or EMPTY
end
	
-- Adds a rule.
function BossNotesRules:AddRule (key, rule)
	local rules = self.db.global.globalRules and self.db.global.rules
			or not self.db.global.globalRules and self.db.char.rules
	if not rules[key] then
		rules[key] = { }
	end
	table.insert(rules[key], rule)
	BossNotes:InvalidateContextKey(key)
end

-- Removes a rule.
function BossNotesRules:RemoveRule (key, rule)
	-- Close the rule editor if it is open on the rule to be deleted.
	local editor = self:GetModule("Editor")
	if editor:IsRuleEditorOpenOnRule(rule) then
		editor:CloseRuleEditor()
	end

	local rules = self.db.global.globalRules and self.db.global.rules[key]
			or not self.db.global.globalRules and self.db.char.rules[key]
	for i = 1, #rules do
		if rules[i] == rule then
			table.remove(rules, i)
			BossNotes:InvalidateContextKey(key)
			break
		end
	end
end

-- Invalidates a rule.
function BossNotesRules:InvalidateRule (key, rule)
	-- For the moment, just invalildate the context key. In the future,
	-- this operation may involve the runtime.
	BossNotes:InvalidateContextKey(key)
end


----------------------------------------------------------------------
-- Events

-- Handles received comm messages.
function BossNotesRules:OnCommReceived (prefix, message, distribution, sender)
	-- Check distribution
	if distribution == "PARTY" or distribution == "RAID" then
		local success, messageObj  = self:Deserialize(message)
		if success then
			local success, errorMessage = self:GetSchema("Message"):Validate(messageObj)
			if success then
				if messageObj.type == "rule" then
					self:ProcessRuleMessage(messageObj, sender)
				elseif messageObj.type == "rules" then
					self:ProcessRulesMessage(messageObj, sender)
				elseif messageObj.type == "raidtarget" then
					self:ProcessRaidTargetMessage(messageObj, sender)
				end
			else
				BossNotes:Print(string.format(L["VALIDATION_FAILED"], errorMessage))
			end
		end
	end
end


----------------------------------------------------------------------
-- Communication

-- Processes a rule message.
function BossNotesRules:ProcessRuleMessage (message, sender)
	-- Ignore our own rules.
	if sender == UnitName("player") then
		return
	end
	
	-- Bring up the confirmation popup.
	StaticPopupDialogs["BOSS_NOTES_RULES_ACCEPT_RULE"].OnAccept =
			function ()
				local rules = self:GetRules(message.key)
				for _, existingRule in ipairs(rules) do
					if existingRule.name == message.rule.name then
						self:RemoveRule(message.key, existingRule)
						break
					end
				end
				self:AddRule(message.key, message.rule)
			end
	StaticPopup_Show("BOSS_NOTES_RULES_ACCEPT_RULE", message.rule.name, sender)
end	
	
-- Processes a rules message.
function BossNotesRules:ProcessRulesMessage (message, sender)
	-- Ignore our own rules.
	if sender == UnitName("player") then
		return
	end
	
	-- Bring up the confirmation popup.
	StaticPopupDialogs["BOSS_NOTES_RULES_ACCEPT_RULES"].OnAccept =
			function ()
				local rules = self:GetRules(message.key)
				for _, rule in ipairs(message.rules) do
					for _, existingRule in ipairs(rules) do
						if existingRule.name == rule.name then
							self:RemoveRule(message.key, existingRule)
							break
						end
					end
					self:AddRule(message.key, rule)
				end
			end
	StaticPopup_Show("BOSS_NOTES_RULES_ACCEPT_RULES", #message.rules, sender)
end

-- Processes a distributed raid target assignment message.
function BossNotesRules:ProcessRaidTargetMessage (message, sender)
	-- Check priority by sender. To resolve conflicts, we use the sender
	-- name to imply a total order on distributed RTAs per raid target.
	-- This order is then used as a tie breaker.
	local raidTarget = self.raidTargets[message.raidTarget]
	if not raidTarget.sender or sender <= raidTarget.sender then
		-- Clear the RTA, if it exists. By callback, this also
		-- clears the 'rta' and 'sender' fields.
		if raidTarget.rta then
			self:GetModule("Engine"):ClearRta(raidTarget.rta)
		end
		
		-- Set the sender
		raidTarget.sender = sender
		
		-- Set an RTA in the engine. Then set a callback to clear the raid
		-- target when it expires.
		raidTarget.rta = self:GetModule("Engine"):SetRta(message.guid,
				message.raidTarget, message.duration)
		raidTarget.rta.callback =
				function (rta)
					raidTarget.sender = nil
					raidTarget.rta = nil
				end
	end
end

-- Returns whether comm messages can be sent.
function BossNotesRules:CanBroadcast ()
	return GetNumGroupMembers() > 0
end

-- Sends a comm message to the appropriate channel.
function BossNotesRules:Broadcast (messageObj)
	local message = self:Serialize(messageObj)
	if (UnitInRaid("player")) then
		self:SendCommMessage(BOSS_NOTES_RULES_COMM_PREFIX, message, "RAID")
	elseif GetNumGroupMembers() > 0 then
		self:SendCommMessage(BOSS_NOTES_RULES_COMM_PREFIX, message, "PARTY")
	end
end


----------------------------------------------------------------------
-- Schema

-- Creates the schemas.
function BossNotesRules:CreateSchemas ()
	-- Declare the rule schema
	local rule = self:NewSchema("Rule")
	rule:Field("name"):Type("string"):Length(1, "*")
	rule:Field("enabled"):Type("boolean")
	local events = rule:Field("events"):Array()
	local conditions = rule:Field("conditions"):Array()
	local actions = rule:Field("actions"):Array()
	local spells = rule:Field("spells"):Array()
	local cancels = rule:Field("cancels"):Array()
	local cast, aura, emote, unit = spells:Union("type", "cast", "aura", "emote", "unit")
	cast:Field("spellId"):Integer():Range(1, "*")
	cast:Field("suffix"):Integer():Range(1, "*")
	aura:Field("spellId"):Integer():Range(1, "*")
	aura:Field("spellId"):Integer():Range(1, "*")
	emote:Field("text"):Type("string"):Length(1, "*")
	emote:Field("locale"):Type("string"):Length(4, 4)
	unit:Field("action"):Type("string"):Enum("entercombat", "changetarget", "death")
	local unit, property, npc, aura, range = conditions:Union("type", "unit", "property", "npc", "aura", "range")
	unit:Field("unit"):Type("string"):Enum("player", "focus", "pet", "eventsource", "eventdest")
	unit:Field("unitSuffix"):Type("string"):Enum("none", "target", "targettarget")
	unit:Field("operator"):Type("string"):Enum("is", "isnot")
	unit:Field("secondUnit"):Type("string"):Enum("player", "focus", "pet", "eventsource", "eventdest")
	property:Field("unit"):Type("string"):Enum("player", "focus", "pet", "eventsource", "eventdest")
	property:Field("unitSuffix"):Type("string"):Enum("none", "target", "targettarget")
	property:Field("operator"):Type("string"):Enum("is", "isnot")
	property:Field("property"):Type("string"):Enum("player", "playercontrolled", "party", "raid", "maintank", "mainassist")
	npc:Field("unit"):Type("string"):Enum("player", "focus", "pet", "eventsource", "eventdest")
	npc:Field("unitSuffix"):Type("string"):Enum("none", "target", "targettarget")
	npc:Field("operator"):Type("string"):Enum("is", "isnot")
	npc:Field("npcId"):Integer():Range(1, "*")
	aura:Field("unit"):Type("string"):Enum("player", "focus", "pet", "eventsource", "eventdest")
	aura:Field("unitSuffix"):Type("string"):Enum("none", "target", "targettarget")
	aura:Field("operator"):Type("string"):Enum("has", "hasnot")
	aura:Field("spellId"):Integer():Range(1, "*")
	aura:Field("dose"):Optional():Integer():Range(1, "*")
	aura:Field("count"):Optional():Integer():Range(1, "*")
	range:Field("unit"):Type("string"):Enum("player", "focus", "pet", "eventsource", "eventdest")
	range:Field("unitSuffix"):Type("string"):Enum("none", "target", "targettarget")
	range:Field("operator"):Type("string"):Enum("inrange", "notinrange")
	range:Field("range"):Integer():Enum(10, 11, 18, 28)
	local raidtarget, notification, timer, yell = actions:Union("type", "raidtarget", "notification", "timer", "yell")
	raidtarget:Field("firstRaidTarget"):Integer():Range(1, 8)
	raidtarget:Field("lastRaidTarget"):Integer():Range(1, 8)
	raidtarget:Field("setOn"):Type("string"):Enum("eventsource", "eventdest")
	raidtarget:Field("setOnSuffix"):Type("string"):Enum("none", "target", "targettarget")
	raidtarget:Field("duration"):Type("number"):Range(0, "*")
	raidtarget:Field("collapse"):Optional():Type("number"):Range(0, "*")
	notification:Field("text"):Type("string"):Length(1, "*")
	notification:Field("important"):Type("boolean")
	notification:Field("raidWarning"):Type("boolean")
	notification:Field("collapse"):Optional():Type("number"):Range(0, "*")
	timer:Field("text"):Type("string"):Length(1, "*")
	timer:Field("duration"):Type("number"):Range(0, "*")
	timer:Field("repeatDuration"):Optional():Type("number"):Range(0, "*")
	timer:Field("prewarn"):Optional():Type("number"):Range(0, "*")
	timer:Field("collapse"):Optional():Type("number"):Range(0, "*")
	yell:Field("text"):Type("string"):Length(1, "*")
	cancels:Type(spells)
	local cast, aura = spells:Union("type", "cast", "aura")
	cast:Field("spellId"):Integer():Range(1, "*")
	aura:Field("spellId"):Integer():Range(1, "*")
	
	-- Declare the message schema
	local message = self:NewSchema("Message")
	local rule, rules, raidtarget = message:Union("type", "rule", "rules", "raidtarget")
	rule:Field("key"):Type("string"):Length(1, "*")
	rule:Field("rule"):Type(self:GetSchema("Rule"))
	rules:Field("key"):Type("string"):Length(1, "*")
	rules:Field("rules"):Length(1, "*"):Array():Type(self:GetSchema("Rule"))
	raidtarget:Field("guid"):Type("string"):Length(18, 18)
	raidtarget:Field("raidTarget"):Integer():Range(1, 8)
	raidtarget:Field("duration"):Type("number"):Range(0, "*")
end

	
----------------------------------------------------------------------
-- Options

-- Returns whether rules are global.
function BossNotesRules:GetGlobalRules (info) 
	return self.db.global.globalRules
end

-- Sets whether rules are global.
function BossNotesRules:SetGlobalRules (info, value)
	if value ~= self.db.global.globalRules then
		self.db.global.globalRules = value
		BossNotes:InvalidateContextKey("all", true)
	end
end

-- Fires a rule
function BossNotesRules:FireRule (info, value)
	self:GetModule("Engine"):FireRuleByName(value)
end

-- Gets the enabled state of a display module.
function BossNotesRules:GetDisplayModuleState (info)
	return self.db.global.display[info.arg]
end

-- Sets the enabled state of a display module.
function BossNotesRules:SetDisplayModuleState (info, value)
	self.db.global.display[info.arg] = value
	if value then
		self:EnableModule(info.arg)
	else
		self:DisableModule(info.arg)
	end
end


----------------------------------------------------------------------
-- Utilities

-- Returns the texture string of a raid target (1-8).
function BossNotesRules:GetRaidTargetTextureString (raidTarget)
	return string.format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t", raidTarget)
end

-- Returns a hyperlink
function BossNotesRules:GetHyperlink (href, text)
	return string.format("|cff71d5ff[<a href=\"%s\">%s</a>]|r",
			self:EscapeXmlEntities(href), self:EscapeXmlEntities(text))
end

-- Escape XML entities
function BossNotesRules:EscapeXmlEntities (text)
	text = string.gsub(text, "\"", "&quot;")
	text = string.gsub(text, "<", "&lt;")
	text = string.gsub(text, ">", "&gt;")
	text = string.gsub(text, "&", "&amp;")
	return text
end

-- Migrates the database
function BossNotesRules:MigrateDatabase (targetVersion)
	local version = self.db.global.databaseVersion or targetVersion
	
	-- 1 -> 2
	if version == 1 and targetVersion >= 2 then
		self:MigrateRules(
				function (rule)
					for _, action in ipairs(rule.actions) do
						if action.type == "raidtarget" then
							action.setOnSuffix = "none"
						end
					end
				end)
		version = 2
		self.db.global.databaseVersion = version
	end
	
	-- Set to target version
	self.db.global.databaseVersion = version
end

-- Invokes a function on each rule.
function BossNotesRules:MigrateRules (func)
	if BossNotesRulesDB.char then
		for _, char in pairs(BossNotesRulesDB.char) do
			if char.rules then
				for _, encounterRules in pairs(char.rules) do
					for _, rule in ipairs(encounterRules) do
						func(rule)
					end
				end
			end
		end
	end
end