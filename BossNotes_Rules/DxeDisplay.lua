--[[

$Revision: 206 $

(C) Copyright 2009 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

BossNotesRulesDxeDisplay = BossNotesRules:NewModule("Dxe",
		"AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")


----------------------------------------------------------------------
-- Core handlers

function BossNotesRulesDxeDisplay:OnInitialize ()
	self.supported = IsAddOnLoaded("DXE")
	if self.supported then
		self.alerts = DXE:GetModule("Alerts")
	end
end

function BossNotesRulesDxeDisplay:OnEnable ()
	if self.supported then
		self:RegisterMessage("BOSS_NOTES_RULES_NOTIFICATION")
		self:RegisterMessage("BOSS_NOTES_RULES_TIMER_START")
		self:RegisterMessage("BOSS_NOTES_RULES_TIMER_STOP")
	end
end

function BossNotesRulesDxeDisplay:OnDisable ()
	
end


----------------------------------------------------------------------
-- Event handlers

function BossNotesRulesDxeDisplay:BOSS_NOTES_RULES_NOTIFICATION (
		message, id, text, important, spellId)
	local color, sound
	if important then
		color = "RED"
		sound = "ALERT10"
	else
		color = "YELLOW"
		sound = "ALERT4"
	end
	self.alerts:Simple(text, 5, sound, color, important, DXE.ST[spellId])
end
				
function BossNotesRulesDxeDisplay:BOSS_NOTES_RULES_TIMER_START (
		message, id, text, duration, spellId)
	self.alerts:QuashByPattern(tostring(id))
	self.alerts:CenterPopup(tostring(id), text, duration, nil, nil, "GOLD", nil, nil, DXE.ST[spellId])
end

function BossNotesRulesDxeDisplay:BOSS_NOTES_RULES_TIMER_STOP (
		message, id)
	self.alerts:QuashByPattern(tostring(id))
end


----------------------------------------------------------------------
-- Display Module

-- Mark this module as a display module.
BossNotesRulesDxeDisplay.BOSS_NOTES_RULES_DISPLAY_MODULE = true

-- Returns information about this display module.
function BossNotesRulesDxeDisplay:GetDisplayInfo ()
	return "dxe", L["DXE_DISPLAY"], L["DXE_DISPLAY_DESC"]
end
