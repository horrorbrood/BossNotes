--[[

$Revision: 206 $

(C) Copyright 2009 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

BossNotesRulesSimpleDisplay = BossNotesRules:NewModule("Simple",
		"AceEvent-3.0",
		"AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")


----------------------------------------------------------------------
-- Core handlers

-- One-time initialization
function BossNotesRulesSimpleDisplay:OnInitialize ()
	self.timers = { }
end

-- Handles the (re-)enabling of module
function BossNotesRulesSimpleDisplay:OnEnable ()
	self:RegisterMessage("BOSS_NOTES_RULES_NOTIFICATION")
	self:RegisterMessage("BOSS_NOTES_RULES_TIMER_START")
	self:RegisterMessage("BOSS_NOTES_RULES_TIMER_STOP")
end

-- Handles the disabling of this module
function BossNotesRulesSimpleDisplay:OnDisable ()
end


----------------------------------------------------------------------
-- Event handlers

function BossNotesRulesSimpleDisplay:BOSS_NOTES_RULES_NOTIFICATION (
		message, id, text, important, spellId)
	self:ShowNotification(text, important, spellId)
end
				
function BossNotesRulesSimpleDisplay:BOSS_NOTES_RULES_TIMER_START (
		message, id, text, duration, spellId)
	-- Cancel as needed, then schedule.
	if self.timers[id] then
		self:CancelTimer(self.timers[id])
		self.timers[id] = nil
	end
	self.timers[id] = self:ScheduleTimer(
			function ()
				self:ShowNotification(text, false, spellId)
				self.timers[id] = nil
			end,
			duration)
end

function BossNotesRulesSimpleDisplay:BOSS_NOTES_RULES_TIMER_STOP (
		message, id)
	if self.timers[id] then
		self:CancelTimer(self.timers[id])
		self.timers[id] = nil
	end
end


----------------------------------------------------------------------
-- Display Module

-- Mark this module as a display module.
BossNotesRulesSimpleDisplay.BOSS_NOTES_RULES_DISPLAY_MODULE = true

-- Returns information about this display module.
function BossNotesRulesSimpleDisplay:GetDisplayInfo ()
	return "simple", L["SIMPLE_DISPLAY"], L["SIMPLE_DISPLAY_DESC"], true
end


----------------------------------------------------------------------
-- Utilities

-- Shows a notification
function BossNotesRulesSimpleDisplay:ShowNotification (text, important, spellId)
	-- If a spell ID is present, prepend the icon of the spell.
	if spellID then
		local iconPath = select(3, GetSpellInfo(spellId))
		text = string.format("|T%s:0|t %s", iconPath, text)
	end
	
	-- Add the notification to the standard raid warning frame and
	-- play a sound depending on the importance of the notification.
	RaidNotice_AddMessage(RaidWarningFrame, text,
			ChatTypeInfo["RAID_WARNING"])
	PlaySound(important and "RaidBossEmoteWarning" or "RaidWarning")
end
