// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIHoverMenu.lua
//
//    Created by:   Juanjo Alfaro
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIHoverMenu' (GUIScript)

local kBackgroundColor = Color(0, 0, 0, 0.9)
local kPadding = 10
local kRowSize = 20
local kRowPadding = 2
local kSeparatorSize = 4
local kDiffSepRow = kRowSize-kSeparatorSize
local kBackgroundSize = Vector(100, kRowPadding, 0)

function GUIHoverMenu:Initialize()
	
	self.background = GUIManager:CreateGraphicItem()
	self.background:SetColor(kBackgroundColor)
	self.background:SetLayer(kGUILayerOptionsTooltips)
	self.background:SetSize(Vector(kBackgroundSize.x+4, kBackgroundSize.y+4, 0))
	
	self.links = {}
	
	self.down = false
end

function GUIHoverMenu:SetBackgroundColor(bgColor)
	self.background:SetColor(bgColor)
end

function GUIHoverMenu:AdjustMenuSize()
	local longest = 0
	local separatorsSize = 0
	for _, entry in ipairs(self.links) do
		if not entry.isSeparator then
			local length = entry.link:GetTextWidth(entry.link:GetText())
			if longest < length then
				longest = length
			end
		else
			separatorsSize = separatorsSize + kDiffSepRow
		end
	end
	
	local ySize = #self.links * kRowSize + (#self.links-1) * kRowPadding - separatorsSize
	local xSize = longest + kPadding * 2
	
	local yPos = 0
	
	for _, entry in ipairs(self.links) do
		if entry.isSeparator then
			yPos = yPos + kSeparatorSize
		else
			entry.background:SetPosition(Vector(kRowPadding, kRowPadding + yPos, 0))
			entry.background:SetSize(Vector(xSize, kRowSize, 0))
			yPos = yPos + kRowSize + kRowPadding
		end
	end
	
	self.background:SetSize(Vector(xSize + 4, ySize + 4, 0))
end

function GUIHoverMenu:AddButton(text, bgColor, bgHighlightColor, textColor, callback)
	
	local button = {}
	
	local background = GUIManager:CreateGraphicItem()
	background:SetAnchor(GUIItem.Left, GUIItem.Top)
	self.background:AddChild(background)
	
	local link = GUIManager:CreateTextItem()
	link:SetColor(textColor)
	link:SetPosition(Vector(kPadding, 0, 0))
	link:SetText(text)
	link:SetAnchor(GUIItem.Left, GUIItem.Middle)
	link:SetTextAlignmentY(GUIItem.Align_Center)
	background:AddChild(link)
	
	button.background = background
	button.link = link
	if callback then
		button.callback = callback
	end
	button.bgColor = bgColor
	button.bgHighlightColor = bgHighlightColor
	
	table.insert(self.links, button)
	
	self:AdjustMenuSize()
end

-- Just to add some extra space between option blocks
function GUIHoverMenu:AddSeparator(name)
	
	local separator = {}
	separator.isSeparator = true
	separator.name = name
	
	table.insert(self.links, separator)
	
	self:AdjustMenuSize()
	
end

-- Only remove the first result in the table
-- Separators have a name so we can delete those too
-- Return the result of the operation in case someone wants to do a while loop
-- with this to remove all entries with the same text
function GUIHoverMenu:RemoveButtonByText(text)
	local indexToRemove
	for index, entry in ipairs(self.links) do
		if entry.isSeparator and entry.name == text then
			indexToRemove = index
			break
		elseif entry.link and entry.link:GetText() == text then
			GUI.DestroyItem(entry.background)
			indexToRemove = index
			break
		end
	end
	
	if indexToRemove then
		table.remove(self.links, indexToRemove)
		self:AdjustMenuSize()
	end
	
	-- Return the result of the operation
	return indexToRemove ~= nil
end

function GUIHoverMenu:ResetButtons()
	for _, button in ipairs(self.links) do
		if not button.isSeparator then
			GUI.DestroyItem(button.background)
		end
	end
	self.links = {}
end

function GUIHoverMenu:Uninitialize()
	
	GUI.DestroyItem(self.background)
	self.background = nil
	
end

function GUIHoverMenu:Update(deltaTime)
	
	if self.background:GetIsVisible() then
		local mouseX, mouseY = Client.GetCursorPosScreen()
		
		for _, button in pairs(self.links) do
			if not button.isSeparator then
				if GUIItemContainsPoint(button.background, mouseX, mouseY) then
					button.background:SetColor(button.bgHighlightColor)
				else
					button.background:SetColor(button.bgColor)
				end
			end
		end
	end
end

function GUIHoverMenu:SendKeyEvent(key, down)

	local ret = false
	if key == InputKey.Escape and self.background:GetIsVisible() then
		self:Hide()
		
		ret = true
	end

	if key == InputKey.MouseButton0 and self.down ~= down then
		self.down = down
		
		if down and self.background:GetIsVisible() then
			local mouseX, mouseY = Client.GetCursorPosScreen()
			
			for _, button in pairs(self.links) do
				if not button.isSeparator and GUIItemContainsPoint(button.background, mouseX, mouseY) and button.callback then
					button.callback()
				end
			end
			
			self:Hide()
			
			ret = true
		end
	end
	
	return ret
end

function GUIHoverMenu:Show()
	self.background:SetIsVisible(true)
	
	local mouseX, mouseY = Client.GetCursorPosScreen()
	local xPos, yPos
	if mouseX > Client.GetScreenWidth() - self.background:GetSize().x then
		xPos = mouseX - self.background:GetSize().x
	else
		xPos = mouseX
	end
	
	if mouseY > Client.GetScreenHeight() - self.background:GetSize().y then
		yPos = mouseY - self.background:GetSize().y
	else
		yPos = mouseY
	end
	
	self.background:SetPosition(Vector(xPos, yPos, 0))
end

function GUIHoverMenu:Hide()
	self.background:SetIsVisible(false)
end