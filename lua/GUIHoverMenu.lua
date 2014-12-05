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
	
	local longest = 0
	for _, entry in ipairs(self.links) do
		local length = entry.link:GetTextWidth(entry.link:GetText())
		if longest < length then
			longest = length
		end
	end
	
	local ySize = #self.links * kRowSize + (#self.links-1) * kRowPadding
	local xSize = longest + kPadding * 2
	
	for _, entry in ipairs(self.links) do
		entry.background:SetSize(Vector(xSize, kRowSize, 0))
	end
	
	background:SetPosition(Vector(2, 2 + ySize - kRowSize, 0))
	background:SetSize(Vector(xSize, kRowSize, 0))
	self.background:SetSize(Vector(xSize + 4, ySize + 4, 0))
end

function GUIHoverMenu:ResetButtons()
	for index, button in ipairs(self.links) do
		GUI.DestroyItem(button.background)
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
		
		for index, button in pairs(self.links) do
			if GUIItemContainsPoint(button.background, mouseX, mouseY) then
				button.background:SetColor(button.bgHighlightColor)
			else
				button.background:SetColor(button.bgColor)
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
			
			for index, button in pairs(self.links) do
				if GUIItemContainsPoint(button.background, mouseX, mouseY) and button.callback then
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