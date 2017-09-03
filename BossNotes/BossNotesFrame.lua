--[[

$Revision: 358 $

(C) Copyright 2009 Bethink (bethink at naef dot com)
See LICENSE.txt for license terms.

]]


----------------------------------------------------------------------
-- Initialization

local L = LibStub("AceLocale-3.0"):GetLocale("BossNotes")


----------------------------------------------------------------------
-- Constants

BOSS_NOTES_SOURCE_HEIGHT = 16
BOSS_NOTES_SOURCE_TEXT_WIDTH = 275
BOSS_NOTES_SOURCE_DISPLAYED_COUNT = 8
BOSS_NOTES_REFRESH_COOLDOWN = 10

-- Chats
local CHATS = {
	{
		text = L["RAID"],
		value = "RAID"
	},
	{
		text = L["PARTY"],
		value = "PARTY"
	},
	{
		text = L["INSTANCE"],
		value = "INSTANCE_CHAT"
	},
	{
		text = L["SAY"],
		value = "SAY"
	},
	{
		text = L["YELL"],
		value = "YELL"
	},
	{
		text = L["GUILD"],
		value = "GUILD"
	},
	{
		text = L["OFFICER"],
		value = "OFFICER"
	}
}

local ALL_ELEMENTS = { }

	
---------------------------------------------------------------------
-- Subsystem

-- Initializes the Boss Notes frame subsystem
function BossNotes:InitializeBossNotesFrame ()
	self:InitializeInstances()
	self:InitializeEncounters()
	self:InitializeChats()
end

-- Enable the Boss Notes frame subsystem
function BossNotes:EnableBossNotesFrame ()
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE")
	self:RegisterMessage("BOSS_NOTES_ACTIVATION")
	self:RegisterMessage("BOSS_NOTES_UPDATE_SOURCES")
end

-- Disables the Boss Notes frame subsystem
function BossNotes:DisableBossNotesFrame ()
end


----------------------------------------------------------------------
-- APIs

-- Returns the current selection
function BossNotes:GetSelection ()
	return self.selectedInstance, self.selectedEncounter, self.selectedSource
end


----------------------------------------------------------------------
-- Event handlers

-- OnLoad handler
function BossNotes:OnLoadBossNotesFrame (frame)
	-- Make the Boss Notes frame pushable
	UIPanelWindows["BossNotesFrame"] = {
		area = "left",
		pushable = 0,
		xoffset = -16,
        yoffset = 12, 
		whileDead = 1
	}
	
	-- Translations
	BossNotesFrameTitleText:SetText(L["BOSS_NOTES"])
	BossNotesRefreshButton:SetText(L["REFRESH"])
end

-- OnShow handler
function BossNotes:OnShowBossNotesFrame (frame)
	--PlaySound("igCharacterInfoOpen")
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
	SetPortraitTexture(BossNotesFramePortrait, "player")
	self:UpdateSources()
end

-- OnHide handler
function BossNotes:OnHideBossNotesFrame (frame)
	--PlaySound("igCharacterInfoClose")
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

-- Handles the clicking of the note scroll frame
function BossNotes:OnClickNoteScrollFrame (frame, button)
	if self.selectedSource and self.selectedSource.callbacks.OnClick then
		self.selectedSource.callbacks.OnClick(self.selectedInstance,
				self.selectedEncounter, self.selectedSource, button)
	end
end

-- Handles the entering into a hyperlink
function BossNotes:OnHyperlinkEnterNote (frame, link, text)
	if self.selectedSource and self.selectedSource.showHyperlinkTooltip then
		GameTooltip:SetOwner(frame:GetParent(), "ANCHOR_BOTTOMRIGHT", 48, 200)
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end
end

-- Handles the leaving of a hyperllink
function BossNotes:OnHyperlinkLeaveNote (frame, link, text)
	if self.selectedSource and self.selectedSource.showHyperlinkTooltip then
		GameTooltip:Hide()
	end
end

-- Handles the clicking of a hyperllink
function BossNotes:OnHyperlinkClickNote (frame, link, text, button)
	if IsModifiedClick("CHATLINK") then
		ChatEdit_InsertLink(text)
	end
	if self.selectedSource and self.selectedSource.callbacks.OnHyperlinkClick then
		self.selectedSource.callbacks.OnHyperlinkClick(self.selectedInstance,
				self.selectedEncounter, self.selectedSource, link, text, button)
	end
end

-- Handles the clicking of the refresh button
function BossNotes:OnClickRefresh (frame)
	-- Refrsh the sources
	self:RefreshSources(self.selectedInstance, self.selectedEncounter)
	
	-- Disable the button and set a timer
	frame:Disable()
	self:ScheduleTimer("EnableRefresh", BOSS_NOTES_REFRESH_COOLDOWN)
end

-- Enables the refresh button
function BossNotes:EnableRefresh ()
	BossNotesRefreshButton:Enable()
end

-- Handles an activation evevent from the data subsystem
function BossNotes:BOSS_NOTES_ACTIVATION (message, instance, encounter)
	-- Update instance
	Lib_UIDropDownMenu_SetSelectedValue(BossNotesInstanceDropDown, instance)
	Lib_UIDropDownMenu_SetText(BossNotesInstanceDropDown, instance.name)
	self.selectedInstance = instance
	self:UpdateEncounters(true)
	
	-- Update encounter
	if encounter then
		Lib_UIDropDownMenu_SetSelectedValue(BossNotesEncounterDropDown, encounter)
		Lib_UIDropDownMenu_SetText(BossNotesEncounterDropDown, encounter.name)
	else
		Lib_UIDropDownMenu_SetSelectedValue(BossNotesEncounterDropDown, ALL_ELEMENTS)
		Lib_UIDropDownMenu_SetText(BossNotesEncounterDropDown, L["ALL_ENCOUNTERS"])
	end
		
	self.selectedEncounter = encounter
	self:UpdateSources()
end

-- Handles the BOSS_NOTES_UPDATE_SOURCES message from the data subsystem
function BossNotes:BOSS_NOTES_UPDATE_SOURCES (message, keys)
	if keys[self.selectedKey] or keys["all"] then
		self:UpdateSources()
	end
end

-- Handles the UNIT_PORTRAIT_UPDATE event
function BossNotes:UNIT_PORTRAIT_UPDATE (message, unit)
	if unit == "player" then
		SetPortraitTexture(BossNotesFramePortrait, "player")
	end
end


----------------------------------------------------------------------
-- Chats

-- Updates the chat drop down
function BossNotes:InitializeChats ()
	Lib_UIDropDownMenu_Initialize(BossNotesChatDropDown, BossNotesChatDropDown_Initialize)
	Lib_UIDropDownMenu_SetText(BossNotesChatDropDown, L["SEND_TO"])
end

-- Initializes the chat drop down
function BossNotesChatDropDown_Initialize ()
	-- Add static chats
	for _, chat in ipairs(CHATS) do
		info = Lib_UIDropDownMenu_CreateInfo()
		info.text = chat.text
		info.value = chat.value
		info.func = BossNotes_OnChatDropDownClick
		Lib_UIDropDownMenu_AddButton(info)
	end
	
	-- Whisper
	if UnitIsPlayer("target") then
		info = Lib_UIDropDownMenu_CreateInfo()
		info.text = UnitName("target")
		info.value = "WHISPER"
		info.arg1 = UnitName("target")
		info.func = BossNotes_OnChatDropDownClick
		Lib_UIDropDownMenu_AddButton(info)
	end
	
	-- Channels
	for i = 1, MAX_WOW_CHAT_CHANNELS do
		local id = select(i * 2 - 1, GetChannelList())
		if id then
			info = Lib_UIDropDownMenu_CreateInfo()
			info.text = select(i * 2, GetChannelList())
			info.value = "CHANNEL"
			info.arg1 = id
			info.func = BossNotes_OnChatDropDownClick
			Lib_UIDropDownMenu_AddButton(info)
		end
	end
end

-- Handles the selection of a chat
function BossNotes_OnChatDropDownClick (button, destination)
	-- Get the source and content
	local source = BossNotes.selectedSource
	local content = source.content
	if not content then
		return
	end
	content = strtrim(content)
	content = BossNotes:StripHtml(content)
	if not source.chatSafe then
		content = BossNotes:StripUiEscapes(content)
	end
	if string.len(content) == 0 then
		return
	end
	
	-- Get the chat to send to
	local chat = button.value
	
	-- Send via ChatThrottleLib which is hard-embedded into AceComm-3.0
	local instance = BossNotes.selectedInstance
	local encounter = BossNotes.selectedEncounter
	if BossNotes.db.global.header and (encounter or instance) then
		ChatThrottleLib:SendChatMessage("NORMAL", "", string.format(L["CHAT_SOURCE_ON_CONTEXT"],
				source.title, BossNotes:GetContextText(instance, encounter)), chat, nil,
				destination)
	end
	for line in string.gmatch(content, "[^\r\n]+") do
		local pos = 1
		local escapeLength = 0
		for prev, start, word, stop in string.gmatch(line, "()%s*()(%S+)()") do
			local wordEscapeLength = BossNotes:GetEscapeLength(word)
			escapeLength = escapeLength + wordEscapeLength
			if stop - pos - escapeLength > 255 then
				ChatThrottleLib:SendChatMessage("NORMAL", "", string.sub(line, pos, prev - 1),
						chat, nil, destination)
				pos = start
				escapeLength = wordEscapeLength
			end
		end
		ChatThrottleLib:SendChatMessage("NORMAL", "", string.sub(line, pos),
				chat, nil, destination)
	end
end


----------------------------------------------------------------------
-- Content and selection managment

-- Initializes the instances
function BossNotes:InitializeInstances ()
	Lib_UIDropDownMenu_Initialize(BossNotesInstanceDropDown, BossNotesInstanceDropDown_Initialize, nil, 1)
	Lib_UIDropDownMenu_SetSelectedValue(BossNotesInstanceDropDown, ALL_ELEMENTS)
end

-- Updates the instances drop down
function BossNotes:UpdateInstances (limited)
	Lib_UIDropDownMenu_SetSelectedValue(BossNotesInstanceDropDown, ALL_ELEMENTS)
	Lib_UIDropDownMenu_SetText(BossNotesInstancesDropDown, L["ALL_INSTANCES"])
	self.selectedInstance = nil
	if not limited then
		self:UpdateEncounters()
	end
end

-- Initializes the instances drop down
function BossNotesInstanceDropDown_Initialize (frame, level)
	if level == 1 then
		-- Add "All Instances"
		local info = Lib_UIDropDownMenu_CreateInfo()
		info.text = L["ALL_INSTANCES"]
		info.value = ALL_ELEMENTS
		info.func = BossNotes_OnInstanceDropDownClick
		Lib_UIDropDownMenu_AddButton(info, level)
		
		-- Add instance sets
		for _, instanceSet in ipairs(BOSS_NOTES_ENCOUNTERS) do
			info = Lib_UIDropDownMenu_CreateInfo()
			info.text = instanceSet.name
			info.value = instanceSet
			info.hasArrow = true
			info.notCheckable = true
			Lib_UIDropDownMenu_AddButton(info, level)
		end
	elseif level == 2 then
		local instanceSet = LIB_UIDROPDOWNMENU_MENU_VALUE
		for _, instance in ipairs(instanceSet.instances) do 
			info = Lib_UIDropDownMenu_CreateInfo()
			info.text = BossNotes:GetContextText(instance, nil)
			info.value = instance
			info.func = BossNotes_OnInstanceDropDownClick
			Lib_UIDropDownMenu_AddButton(info, level)
		end
	end
end

-- Handles the selection of an instance
function BossNotes_OnInstanceDropDownClick (button)
	CloseDropDownMenus()
	if button.value == ALL_ELEMENTS then
		LIB_UIDROPDOWNMENU_MENU_LEVEL = 1
	end
	Lib_UIDropDownMenu_SetSelectedValue(BossNotesInstanceDropDown, button.value)
	if button.value ~= ALL_ELEMENTS then
		BossNotes.selectedInstance = button.value
	else
		BossNotes.selectedInstance = nil
	end
	BossNotes:UpdateEncounters()
end

-- Initializes the encounters drop down
function BossNotes:InitializeEncounters ()
	Lib_UIDropDownMenu_Initialize(BossNotesEncounterDropDown, BossNotes_InitializeEncounterDropDown)
	Lib_UIDropDownMenu_SetSelectedValue(BossNotesEncounterDropDown, ALL_ELEMENTS)
end

-- Updates the encounters drop down
function BossNotes:UpdateEncounters (limited)
	Lib_UIDropDownMenu_SetSelectedValue(BossNotesEncounterDropDown, ALL_ELEMENTS)
	Lib_UIDropDownMenu_SetText(BossNotesEncounterDropDown, L["ALL_ENCOUNTERS"])
	self.selectedEncounter = nil
	if not limited then
		self:UpdateSources()
	end
end

-- Initializes the encounters drop down
function BossNotes_InitializeEncounterDropDown ()
	-- Add "All Encounters"
	local info = Lib_UIDropDownMenu_CreateInfo()
	info.text = L["ALL_ENCOUNTERS"]
	info.value = ALL_ELEMENTS
	info.func = BossNotes_OnEncounterDropDownClick
	Lib_UIDropDownMenu_AddButton(info)
	
	-- Add effective encounters
	if BossNotes.selectedInstance then
		for _, encounter in ipairs(BossNotes.selectedInstance.encounters) do
			info = Lib_UIDropDownMenu_CreateInfo()
			info.text = BossNotes:GetContextText(BossNotes.selectedInstance, encounter)
			info.value = encounter
			info.func = BossNotes_OnEncounterDropDownClick
			Lib_UIDropDownMenu_AddButton(info)
		end
	end
end

-- Handles the selection of an encounter
function BossNotes_OnEncounterDropDownClick (button)
	Lib_UIDropDownMenu_SetSelectedValue(BossNotesEncounterDropDown, button.value)
	if button.value ~= ALL_ELEMENTS then
		BossNotes.selectedEncounter = button.value
	else
		BossNotes.selectedEncounter = nil
	end
	BossNotes:UpdateSources()
end

-- Update the list of sources
function BossNotes:UpdateSources (limited)
	-- Send selection change message
	local oldSelectedKey = self.selectedKey
	self.selectedKey = self:GetContextKey(self.selectedInstance, self.selectedEncounter)
	if self.selectedKey ~= oldSelectedKey then
		self:SendMessage("BOSS_NOTES_SELECTION", self.selectedInstance, self.selectedEncounter)
	end
	
	-- Do not update if the frame is not shown
	if not BossNotesFrame:IsShown() then
		return
	end
	
	-- Update sources
	self.selectedSources = self:GetSources(self.selectedInstance, self.selectedEncounter)
	
	-- Maintain selection
	local oldSelectedSource = self.selectedSource
	self.selectedSource = nil
	if oldSelectedSource then
		for _, source in ipairs(self.selectedSources) do
			if source.title  == oldSelectedSource.title then
				self.selectedSource = source
				break
			end
		end
	end
	if not self.selectedSource then
		self.selectedSource = self.selectedSources[1]
	end

	-- Update source
	if not limited then
		self:UpdateSourceList()
	end
end

-- Update the source list
function BossNotes:UpdateSourceList (limited)
	-- Update the scroll framne
	local numSources = #self.selectedSources
	FauxScrollFrame_Update(BossNotesSourceListScrollFrame, numSources, BOSS_NOTES_SOURCE_DISPLAYED_COUNT,
			BOSS_NOTES_SOURCE_HEIGHT, nil, nil, nil, BossNotesSourceHighlightFrame, 293, 316)
	local sourceOffset = FauxScrollFrame_GetOffset(BossNotesSourceListScrollFrame)
	BossNotesSourceHighlightFrame:Hide()
	for i = 1, BOSS_NOTES_SOURCE_DISPLAYED_COUNT do
		local sourceButton = _G["BossNotesSource" .. i]
		local sourceButtonText = _G["BossNotesSource" .. i .. "Text"]
		local sourceButtonTag = _G["BossNotesSource" .. i .. "Tag"]
		local sourceIndex = i + sourceOffset
		local source = self.selectedSources[sourceIndex]
		if sourceIndex <= numSources then
			sourceButtonText:SetText(" " .. source.title)
			sourceButtonText:SetTextColor(source.color.r, source.color.g, source.color.b)
			if source.tag then
				sourceButtonTag:SetText("(" .. source.tag .. ")")
				sourceButtonTag:SetTextColor(source.color.r, source.color.g, source.color.b)
				tagWidth = sourceButtonTag:GetWidth() + 15
			else
				sourceButtonTag:SetText("")
				tagWidth = 0
			end
			if BossNotesSourceListScrollFrame:IsShown() then
				sourceButton:SetWidth(293)
				sourceButtonText:SetWidth(293 - tagWidth)
			else
				sourceButton:SetWidth(316)
				sourceButtonText:SetWidth(316 - tagWidth)
			end
			sourceButton:SetID(sourceIndex)
			sourceButton:Show()
			if source == self.selectedSource then
				BossNotesSourceHighlightFrame:SetPoint("TOPLEFT", "BossNotesSource" .. i, "TOPLEFT", 2, 0)
				BossNotesSourceHighlightFrame:Show()
				sourceButton:LockHighlight()
				sourceButton.isHighlighted = true
			else
				sourceButton:UnlockHighlight()
				sourceButton.isHighlighted = false
			end
		else
			sourceButton:Hide()
		end
	end
	
	-- Update the source
	if not limited then
		self:UpdateSource()
	end
end

-- Regular function invoked by the scroll bar
function BossNotesFrame_UpdateSourceList ()
	BossNotes:UpdateSourceList()
end

-- Handles the clicking of a source button
function BossNotes:OnMouseDownSourceButton (frame, button)
	self.selectedSource = self.selectedSources[frame:GetID()]
	self:UpdateSourceList()
	if button == "RightButton" then
		if self.selectedSource and self.selectedSource.callbacks.OnClick then
			self.selectedSource.callbacks.OnClick(self.selectedInstance,
					self.selectedEncounter, self.selectedSource, button)
		end
	end
end

-- Update the source
function BossNotes:UpdateSource (limited)
	local source = self.selectedSource
	if source and source.content then
		BossNotesNote:SetText(source.content)
	elseif source and source.placeholder then
		BossNotesNote:SetText(source.placeholder)
	else
		BossNotesNote:SetText("")
	end
	if source and source.time and source.clientVersion then
		BossNotesMetaData:SetText(string.format("%s (%s)",
				date("%Y-%m-%d %H:%M", source.time),
				source.clientVersion))
	else
		BossNotesMetaData:SetText("")
	end
end