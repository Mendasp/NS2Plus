// ======= Copyright (c) 2003-2014, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIHoverMenu.lua
//
//    Created by:   Juanjo Alfaro
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIAnimatedScript.lua")

class 'GUIHoverMenu' (GUIAnimatedScript)

local kBackgroundColor = Color(0, 0.25, 1, 1)
local kPadding = 10
local kRowSize = 20
local kRowPadding = 2
local kBackgroundSize = Vector(100, kRowPadding, 0)

function GUIHoverMenu:Initialize()
	
	GUIAnimatedScript.Initialize(self)

	self.background = self:CreateAnimatedGraphicItem()
	self.background:SetColor(kMarineFontColor)
	self.background:SetLayer(kGUILayerOptionsTooltips)
	self.background:SetIsScaling(false)
	self.background:SetSize(Vector(kBackgroundSize.x+4, kBackgroundSize.y+4, 0))
	
	self.backgroundFiller = self:CreateAnimatedGraphicItem()
	self.backgroundFiller:SetColor(kMarineFontColor)
	self.backgroundFiller:SetIsScaling(false)
	self.backgroundFiller:SetSize(kBackgroundSize)
	self.backgroundFiller:SetPosition(Vector(2, 2, 0))
	self.background:AddChild(self.backgroundFiller)
	
	self.links = {}
	
	self.down = false
	
	self.mirrored = false
end

function GUIHoverMenu:AddButton(text, callback)
	
	local button = {}
	
	local background = self:CreateAnimatedGraphicItem()
	background = self:CreateAnimatedGraphicItem()
	background:SetSize(Vector(kBackgroundSize.x, kRowSize, 0))
	background:SetAnchor(GUIItem.Left, GUIItem.Top)
	background:SetIsScaling(false)
	self.backgroundFiller:AddChild(background)
	
	local link = self:CreateAnimatedTextItem()
	link = self:CreateAnimatedTextItem()
	link:SetColor(Color(1,1,1,1))
	link:SetPosition(Vector(kPadding, 0, 0))
	link:SetText(text)
	link:SetAnchor(GUIItem.Left, GUIItem.Middle)
	link:SetTextAlignmentY(GUIItem.Align_Center)
	link:SetIsScaling(false)
	background:AddChild(link)
	
	button.background = background
	button.link = link
	button.callback = callback
	
	table.insert(self.links, button)
	
	local ySize = #self.links * kRowSize + (#self.links-1) * kRowPadding
	
	background:SetPosition(Vector(0, ySize - kRowSize, 0))
	self.backgroundFiller:SetSize(Vector(kBackgroundSize.x, ySize, 0))
	self.background:SetSize(Vector(kBackgroundSize.x + 4, ySize + 4, 0))
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
			if GUIItemContainsPoint(button.background, mouseX, mouseY) then
				button.background:SetColor(kBackgroundColor*0.75)
			else
				button.background:SetColor(kBackgroundColor*0.5)
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
	if mouseX > Client.GetScreenWidth() - kBackgroundSize.x then
		self.mirrored = true
		self.background:SetPosition(Vector(mouseX - kBackgroundSize.x, mouseY, 0))
	else
		self.mirrored = false
		self.background:SetPosition(Vector(mouseX + 20, mouseY, 0))
	end
end

function GUIHoverMenu:Hide()
	self.background:SetIsVisible(false)
end