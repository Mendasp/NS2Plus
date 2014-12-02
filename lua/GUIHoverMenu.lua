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
local kBackgroundSize = Vector(100, kRowSize * 2 + kRowPadding * 3, 0)

local kSteamProfileURL = "http://steamcommunity.com/profiles/"
local kHiveProfileURL = "http://hive.naturalselection2.com/profile/"

function GUIHoverMenu:Initialize()
    
    GUIAnimatedScript.Initialize(self)

    self.background = self:CreateAnimatedGraphicItem()
    self.background:SetColor(kMarineFontColor)
    self.background:SetLayer(kGUILayerOptionsTooltips)
    self.background:SetIsScaling(false)
    self.background:SetSize(Vector(kBackgroundSize.x+4, kBackgroundSize.y+4, 0))
	
    self.backgroundFiller = self:CreateAnimatedGraphicItem()
    self.backgroundFiller:SetColor(kBackgroundColor*0.25)
    self.backgroundFiller:SetIsScaling(false)
    self.backgroundFiller:SetSize(kBackgroundSize)
    self.backgroundFiller:SetPosition(Vector(2, 2, 0))
	self.background:AddChild(self.backgroundFiller)
	
    self.steamLinkBg = self:CreateAnimatedGraphicItem()
    self.steamLinkBg:SetSize(Vector(kBackgroundSize.x, kRowSize, 0))
    self.steamLinkBg:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.steamLinkBg:SetPosition(Vector(0, kRowPadding, 0))
    self.steamLinkBg:SetIsScaling(false)
	self.backgroundFiller:AddChild(self.steamLinkBg)
	
    self.steamLink = self:CreateAnimatedTextItem()
    self.steamLink:SetColor(Color(1,1,1,1))
    self.steamLink:SetPosition(Vector(kPadding, 0, 0))
    self.steamLink:SetText("Steam profile")
    self.steamLink:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.steamLink:SetTextAlignmentY(GUIItem.Align_Center)
    self.steamLink:SetIsScaling(false)
	self.steamLinkBg:AddChild(self.steamLink)
	
    self.hiveLinkBg = self:CreateAnimatedGraphicItem()
    self.hiveLinkBg:SetSize(Vector(kBackgroundSize.x, kRowSize, 0))
    self.hiveLinkBg:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.hiveLinkBg:SetPosition(Vector(0, kRowSize + kRowPadding + kRowPadding, 0))
    self.hiveLinkBg:SetIsScaling(false)
	self.backgroundFiller:AddChild(self.hiveLinkBg)
	
    self.hiveLink = self:CreateAnimatedTextItem()
    self.hiveLink:SetColor(Color(1,1,1,1))
    self.hiveLink:SetPosition(Vector(kPadding, 0, 0))
    self.hiveLink:SetText("Hive profile")
    self.hiveLink:SetAnchor(GUIItem.Left, GUIItem.Middle)
    self.hiveLink:SetTextAlignmentY(GUIItem.Align_Center)
    self.hiveLink:SetIsScaling(false)
	self.hiveLinkBg:AddChild(self.hiveLink)
	
	self.down = false
    
    self.mirrored = false
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
		
		self.steamLinkBg:SetColor(kBackgroundColor*0.5)
		self.hiveLinkBg:SetColor(kBackgroundColor*0.5)
		if GUIItemContainsPoint(self.steamLinkBg, mouseX, mouseY) then
			self.steamLinkBg:SetColor(kBackgroundColor*0.75)
		elseif GUIItemContainsPoint(self.hiveLinkBg, mouseX, mouseY) then
			self.hiveLinkBg:SetColor(kBackgroundColor*0.75)
		end
	end
end

function GUIHoverMenu:SendKeyEvent(key, down)

	local ret = false
	if key == InputKey.Escape then
		self:Hide()
		
		ret = true
	end

	if key == InputKey.MouseButton0 and self.down ~= down then
		self.down = down
		
		if down and self.background:GetIsVisible() then
			local mouseX, mouseY = Client.GetCursorPosScreen()
			
			if GUIItemContainsPoint(self.steamLinkBg, mouseX, mouseY) then
				Client.ShowWebpage(kSteamProfileURL .. "[U:1:" .. self.steamId .. "]")
			elseif GUIItemContainsPoint(self.hiveLinkBg, mouseX, mouseY) then
				Client.ShowWebpage(kHiveProfileURL .. self.steamId)
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

function GUIHoverMenu:Show(steamId)
	self.steamId = steamId
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