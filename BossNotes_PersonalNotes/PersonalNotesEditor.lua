--[[

$Revision: 243 $

(C) Copyright 2009 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")



----------------------------------------------------------------------
-- Constants

-- Static popup dialog for confirming the editing of a public note
StaticPopupDialogs["BOSS_NOTES_PERSONAL_NOTES_PUBLIC_NOTES"] = {
	text = L["PUBLIC_NOTES"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function (self)
		BossNotesPersonalNotes.db.char.publicNotesNotificationSeen = true
		BossNotesPersonalNotes_OnClickEditorAccept(BossNotesPersonalNotesEditor.accept)
	end,
	OnCancel = function (self) end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
}


----------------------------------------------------------------------
-- API

-- Shows the editor on the selected source
function BossNotesPersonalNotes:ShowEditor (instance, encounter, source, maxBytes)
	-- Store edit key
	self.editSource = source
	
	-- Set text
	BossNotesPersonalNotesEditor.text:SetText(string.format(L["UI_SOURCE_ON_CONTEXT"],
			source.color.r * 255, source.color.g * 255, source.color.b * 255,
			source.title, BossNotes:GetContextText(instance, encounter)))
			
	-- Limit content
	BossNotesPersonalNotesEditor.editBox:SetMaxBytes(maxBytes)

	-- Set content
	local notes = self:GetNotes(source.xNoteKey)
	local note = notes[source.xNoteTitle]
	BossNotesPersonalNotesEditor.editBox:SetText(note and note.content or "")
	
	-- Show
	BossNotesPersonalNotesEditor:Show()
end


----------------------------------------------------------------------
-- Handlers (adopted from Khaos)

-- Handles the loading of the multline edit box popup
function BossNotesPersonalNotes:OnLoadEditor (frame)
	local name = frame:GetName()

	-- Get and store child frames
	frame.text = getglobal(name .. "Text")
	frame.accept = getglobal(name .. "Button1")
	frame.cancel = getglobal(name .. "Button2")
	frame.scrollFrameBackground = getglobal(name .. "ScrollFrameBackground")
	frame.editBox = getglobal(name .. "ScrollFrameEditBox")
	
	-- Accept button
	frame.accept:SetText(ACCEPT)
	frame.accept:SetPoint("TOPRIGHT", frame.scrollFrameBackground, "BOTTOM", -6, -8)
	frame.accept:Show()
	frame.accept:SetScript("OnClick", BossNotesPersonalNotes_OnClickEditorAccept)
	
	-- Cancel button
	frame.cancel:SetText(CANCEL)
	frame.cancel:SetPoint("LEFT", frame.accept, "RIGHT", 13, 0)
	frame.cancel:Show()
	frame.cancel:SetScript("OnClick", BossNotesPersonalNotes_OnClickEditorCancel)

	-- Hide unused frames
	getglobal(name .. "AlertIcon"):Hide()
	getglobal(name .. "MoneyInputFrame"):Hide()
end

-- Handles the showing of the edit box popup
function BossNotesPersonalNotes:OnShowEditor (frame)
	-- Update height
	local textHeight = frame.text:GetHeight()
	local buttonHeight = frame.accept:GetHeight()
	local editBoxHeight = frame.scrollFrameBackground:GetHeight()
	frame:SetHeight(16 + textHeight + 8 + editBoxHeight + 8 + buttonHeight + 36)
	
	-- Set focus
	frame.editBox:SetFocus()
	
	-- Play sound
	PlaySound("igMainMenuOpen")
end
	
-- Handles the hiding of the edit box popup
function BossNotesPersonalNotes:OnHideEditor (frame)
	-- Close public notes notification
	if StaticPopup_Visible("BOSS_NOTES_PERSONAL_NOTES_PUBLIC_NOTES") then
		StaticPopup_Hide("BOSS_NOTES_PERSONAL_NOTES_PUBLIC_NOTES")
	end
	
	-- Play sound
	PlaySound("igMainMenuClose")
end
	
-- Handles the clicking of the accept button
function BossNotesPersonalNotes_OnClickEditorAccept (frame)
	-- Public notes notification
	local source = BossNotesPersonalNotes.editSource
	if not source.private and not BossNotesPersonalNotes.db.char.publicNotesNotificationSeen then
		StaticPopup_Show("BOSS_NOTES_PERSONAL_NOTES_PUBLIC_NOTES")
		return
	end
	
	-- Hide editor
	BossNotesPersonalNotesEditor:Hide()
	
	-- Set note
	local text = frame:GetParent().editBox:GetText()
	BossNotesPersonalNotes:SetNote(source.xNoteKey, source.xNoteTitle, text)
end

-- Handles the clicking of the cancel button
function BossNotesPersonalNotes_OnClickEditorCancel (frame)
	BossNotesPersonalNotesEditor:Hide()
end

-- Handles the pressing of the escape button
function BossNotesPersonalNotes:OnEscapePressedEditBox (frame)
	BossNotesPersonalNotesEditor:Hide()
end
