--[[

$Revision: 320 $

(C) Copyright 2009 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

BossNotesTactics = LibStub("AceAddon-3.0"):NewAddon("BossNotesTactics")
local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")
local T = LibStub("AceLocale-3.0"):GetLocale("BossNotesTactics")
local AceGUI = LibStub("AceGUI-3.0")

	
----------------------------------------------------------------------
-- Constants

-- Provider name
BOSS_NOTES_TACTICS_PROVIDER = "TACTICS"


----------------------------------------------------------------------
-- Core handlers

-- One-time initialization
function BossNotesTactics:OnInitialize()
end

-- Handles the (re-)enabling of this add-on
function BossNotesTactics:OnEnable ()
	-- Register provider
	BossNotes:RegisterProvider(BOSS_NOTES_TACTICS_PROVIDER, {
		OnSources = function (instance, encounter)
			return self:OnSources(instance, encounter)
		end,
		OnClick = function (instance, encounter, source, button)
			return self:OnClick(instance, encounter, source, button)
		end
	})
end

-- Handles the disabling of this add-on
function BossNotesTactics:OnDisable ()
	BossNotes:UnregisterProvider(BOSS_NOTES_TACTICS_PROVIDER)
end


----------------------------------------------------------------------
-- Event handlers

-- Returns the tactics note
function BossNotesTactics:OnSources (instance, encounter)
	local key = BossNotes:GetContextKey(instance, encounter)
	local content = T[key]
	if content == key then
		return nil
	end
	return {
		title = L["TACTICS"],
		content = content
	}
end

-- Handles the Boss Notes click notification
function BossNotesTactics:OnClick (instance, encounter, source, button)
	if button == "RightButton" then
		-- Setup
		self.contextSource = source
		
		-- Show
		local menu = BossNotesTacticsContextMenu
		menu:Hide()
		local x, y = GetCursorPosition()
		menu:ClearAllPoints()
		menu:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", x, y)
		menu:Show()
		--UIMenu_StartCounting(menu)
	end
end

-- Handles the loading of the context menu
function BossNotesTactics:OnLoadContextMenu (frame)
	frame:SetBackdropBorderColor(TOOLTIP_DEFAULT_COLOR.r,
			TOOLTIP_DEFAULT_COLOR.g, TOOLTIP_DEFAULT_COLOR.b)
	frame:SetBackdropColor(TOOLTIP_DEFAULT_BACKGROUND_COLOR.r,
			TOOLTIP_DEFAULT_BACKGROUND_COLOR.g,
			TOOLTIP_DEFAULT_BACKGROUND_COLOR.b)
	UIMenu_Initialize(frame)
	UIMenu_AddButton(frame, L["COPY"], nil, function ()
		local copyFrame = AceGUI:Create("Frame")
		copyFrame:SetWidth(400)
		copyFrame:SetHeight(300)
		copyFrame:SetTitle(L["COPY"])
		copyFrame:SetLayout("Fill")

		local contentEditBox = AceGUI:Create("MultiLineEditBox")
		contentEditBox:DisableButton(true)
		contentEditBox:SetLabel("")
		contentEditBox:SetText(self.contextSource.content)
		copyFrame:AddChild(contentEditBox)
		
		copyFrame:Show()
		contentEditBox.editBox:HighlightText()
		contentEditBox.editBox:SetFocus()
	end)
	UIMenu_FinishInitializing(frame)
end