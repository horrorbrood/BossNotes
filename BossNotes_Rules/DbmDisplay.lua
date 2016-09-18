--[[

$Revision: 206 $

(C) Copyright 2009 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

BossNotesRulesDbmDisplay = BossNotesRules:NewModule("Dbm",
		"AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")


----------------------------------------------------------------------
-- Core handlers

function BossNotesRulesDbmDisplay:OnInitialize ()
	self.supported = IsAddOnLoaded("DBM-Core")
	if self.supported then
		self.mod = DBM:NewMod("BossNotesRules")
		self.specialWarning = self.mod:NewSpecialWarning("%s")
		self.announces = { }
		self.timers = { }
	end
end

function BossNotesRulesDbmDisplay:OnEnable ()
	if self.supported then
		self:RegisterMessage("BOSS_NOTES_RULES_NOTIFICATION")
		self:RegisterMessage("BOSS_NOTES_RULES_TIMER_START")
		self:RegisterMessage("BOSS_NOTES_RULES_TIMER_STOP")
		self.mod:EnableMod()
	end
end

function BossNotesRulesDbmDisplay:OnDisable ()
	if self.supported then
		self.mod:DisableMod()
	end
end


----------------------------------------------------------------------
-- Event handlers

function BossNotesRulesDbmDisplay:BOSS_NOTES_RULES_NOTIFICATION (
		id, message, text, important, spellId)
	if important then
		self.specialWarning:Show(text)
	else
		local announce = self.announces[id]
		if not announce then
			announce = self.mod:NewAnnounce("%s", nil, spellId)
			self.announces[id] = announce
		end
		announce:Show(text)
	end
end
				
function BossNotesRulesDbmDisplay:BOSS_NOTES_RULES_TIMER_START (
		message, id, text, duration, spellId)
	local timer = self.timers[id]
	if not timer then
		timer = self.mod:NewTimer(0, "%s")
		self.timers[id] = timer
	end
	timer:Stop()
	timer:UpdateIcon(spellId)
	timer:Start(duration, text)
end

function BossNotesRulesDbmDisplay:BOSS_NOTES_RULES_TIMER_STOP (
		message, id)
	if self.timers[id] then
		self.timers[id]:Stop()
	end
end


----------------------------------------------------------------------
-- Display Module

-- Mark this module as a display module.
BossNotesRulesDbmDisplay.BOSS_NOTES_RULES_DISPLAY_MODULE = true

-- Returns information about this display module.
function BossNotesRulesDbmDisplay:GetDisplayInfo ()
	return "dbm", L["DBM_DISPLAY"], L["DBM_DISPLAY_DESC"]
end
