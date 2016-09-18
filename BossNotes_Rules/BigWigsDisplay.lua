--[[

$Revision: 391 $

(C) Copyright 2009 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]

----------------------------------------------------------------------
-- Initialization

local BossNotesRulesBigWigsDisplay = BossNotesRules:NewModule("BigWigs", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")

----------------------------------------------------------------------
-- Core handlers

function BossNotesRulesBigWigsDisplay:OnEnable()
	if BigWigsLoader then
		self:RegisterMessage("BOSS_NOTES_RULES_NOTIFICATION")
		self:RegisterMessage("BOSS_NOTES_RULES_TIMER_START")
		self:RegisterMessage("BOSS_NOTES_RULES_TIMER_STOP")
		self.barTexts = {}
	end
end

----------------------------------------------------------------------
-- Event handlers

function BossNotesRulesBigWigsDisplay:BOSS_NOTES_RULES_NOTIFICATION(message, id, text, important, spellId)
	local _, _, icon = GetSpellInfo(spellId)
	BigWigsLoader.SendMessage(self, "BigWigs_Message", self, nil, text, important and "Important" or "Attention", nil, icon)
end

function BossNotesRulesBigWigsDisplay:BOSS_NOTES_RULES_TIMER_START(message, id, text, duration, spellId)
	-- Stop the previous bar, if any.
	if self.barTexts[id] then
		BigWigsLoader.SendMessage(self, "BigWigs_StopBar", self, self.barTexts[id])
	end

	-- Start the bar.
	self.barTexts[id] = text
	local _, _, icon = GetSpellInfo(spellId)
	BigWigsLoader.SendMessage(self, "BigWigs_StartBar", self, nil, text, duration, icon)
end

function BossNotesRulesBigWigsDisplay:BOSS_NOTES_RULES_TIMER_STOP(message, id)
	if self.barTexts[id] then
		BigWigsLoader.SendMessage(self, "BigWigs_StopBar", self, self.barTexts[id])
		self.barTexts[id] = nil
	end
end

----------------------------------------------------------------------
-- Display Module

-- Mark this module as a display module.
BossNotesRulesBigWigsDisplay.BOSS_NOTES_RULES_DISPLAY_MODULE = true

-- Returns information about this display module.
function BossNotesRulesBigWigsDisplay:GetDisplayInfo()
	return "bigWigs", L["BIGWIGS_DISPLAY"], L["BIGWIGS_DISPLAY_DESC"]
end

