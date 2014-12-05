// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIHoverMenu.lua
//
//    Created by:   Juanjo Alfaro
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIHoverMenu' (GUIAnimatedScript)

local kBackgroundColor = kMarineFontColor
local kEntryBackgroundColor = Color(0, 0.25, 1, 1)
local kPadding = 10
local kRowSize = 20
local kRowPadding = 2
local kBackgroundSize = Vector(100, kRowPadding, 0)

function GUIHoverMenu:Initialize()
	
	GUIAnimatedScript.Initialize(self)
	
	self.background = self:CreateAnimatedGraphicItem()
	self.background:SetColor(kBackgroundColor)
	self.background:SetLayer(kGUILayerOptionsTooltips)
	self.background:SetIsScaling(false)
	self.background:SetSize(Vector(kBackgroundSize.x+4, kBackgroundSize.y+4, 0))
	
	self.backgroundFiller = self:CreateAnimatedGraphicItem()
	self.backgroundFiller:SetColor(kBackgroundColor)
	self.backgroundFiller:SetIsScaling(false)
	self.backgroundFiller:SetSize(kBackgroundSize)
	self.backgroundFiller:SetPosition(Vector(2, 2, 0))
	self.background:AddChild(self.backgroundFiller)
	
	self.links = {}
	
	self.down = false
end

function GUIHoverMenu:AddButton(text, callback)
	
	local button = {}
	
	local background = self:CreateAnimatedGraphicItem()
	background:SetAnchor(GUIItem.Left, GUIItem.Top)
	background:SetIsScaling(false)
	self.backgroundFiller:AddChild(background)
	
	local link = self:CreateAnimatedTextItem()
	link:SetColor(Color(1,1,1,1))
	link:SetPosition(Vector(kPadding, 0, 0))
	link:SetText(text)
	link:SetAnchor(GUIItem.Left, GUIItem.Middle)
	link:SetTextAlignmentY(GUIItem.Align_Center)
	link:SetIsScaling(false)
	background:AddChild(link)
	
	button.background = background
	button.link = link
	if callback then
		button.callback = callback
	else
		link:SetColor(Color(0,0,0,1))
	end
	
	table.insert(self.links, button)
	
	local ySize = #self.links * kRowSize + (#self.links-1) * kRowPadding
	local xSize = link:GetTextWidth(text) + kPadding * 2
	
	if xSize > self.backgroundFiller:GetSize().x then
		for _, entry in ipairs(self.links) do
			entry.background:SetSize(Vector(xSize, kRowSize, 0))
		end
	else
		xSize = self.backgroundFiller:GetSize().x
	end
	
	background:SetPosition(Vector(0, ySize - kRowSize, 0))
	background:SetSize(Vector(xSize, kRowSize, 0))
	self.backgroundFiller:SetSize(Vector(xSize, ySize, 0))
	self.background:SetSize(Vector(xSize + 4, ySize + 4, 0))
end

function GUIHoverMenu:ResetButtons()
	for index, button in ipairs(self.links) do
		button.background:Destroy()
	end
	self.links = {}
end

function GUIHoverMenu:Uninitialize()
	
	GUIAnimatedScript.Uninitialize(self)
	
	GUI.DestroyItem(self.background)
	self.background = nil
	
end

function GUIHoverMenu:Update(deltaTime)
	
	GUIAnimatedScript.Update(self, deltaTime)
	
	if self.background:GetIsVisible() then
		local mouseX, mouseY = Client.GetCursorPosScreen()
		
		for index, button in pairs(self.links) do
			if not button.callback then
				button.background:SetColor(kBackgroundColor)
			elseif GUIItemContainsPoint(button.background, mouseX, mouseY) then
				button.background:SetColor(kEntryBackgroundColor*0.75)
			else
				button.background:SetColor(kEntryBackgroundColor*0.5)
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

function GUIHoverMenu:SetIsVisible(visible)
	self.background:SetIsVisible(visible)
end

function GUIHoverMenu:Show()
	self.background:SetIsVisible(true)
	self.background:FadeIn(0.25, "MENU_SHOW")
	
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