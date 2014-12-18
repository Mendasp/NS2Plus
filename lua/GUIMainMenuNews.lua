// ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =====
//
// lua\menu\GUIMainMenuNews.lua
//
//    Created by:   Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

local widthFraction = 0.4
local newsAspect = 1.2/1
local kTextureName = "*mainmenu_news"
local fadeColor = Color(1,1,1,0)
local lastUpdatedtime = 0
local playAnimation = ""

-- Non local so modders can easily change the URL.
kMainMenuNewsURL = "http://unknownworlds.com/ns2/ingamenews/"

class 'GUIMainMenuNews' (GUIScript)

function GUIMainMenuNews:Initialize()

    local layer = kGUILayerMainMenuNews

    self.logo = GUIManager:CreateGraphicItem()
    self.logo:SetTexture("ui/menu/logo.dds")
    self.logo:SetLayer(layer)
    
    local width = widthFraction * Client.GetScreenWidth()
    local newsHt = width/newsAspect
    self.webView = Client.CreateWebView(width, newsHt)
    self.webView:SetTargetTexture(kTextureName)
    self.webView:LoadUrl(kMainMenuNewsURL)
    self.webContainer = GUIManager:CreateGraphicItem()
    self.webContainer:SetTexture(kTextureName)
    self.webContainer:SetLayer(layer)
    self.webContainer:SetColor(fadeColor)

    self.reinforceButton = GUIManager:CreateGraphicItem()
    self.reinforceButton:SetLayer(layer)
    self.reinforceButton:SetColor(fadeColor)

    self.storeButton = GUIManager:CreateGraphicItem()
    self.storeButton:SetLayer(layer)
    self.storeButton:SetColor(fadeColor)
    self.logo:SetColor(fadeColor)

    self.buttonDown = { [InputKey.MouseButton0] = false, [InputKey.MouseButton1] = false, [InputKey.MouseButton2] = false }

    self.isVisible = true
    playAnimation = "show"

end

function GUIMainMenuNews:Uninitialize()

    GUI.DestroyItem(self.webContainer)
    self.webContainer = nil
    
    Client.DestroyWebView(self.webView)
    self.webView = nil

    GUI.DestroyItem(self.logo)
    self.logo = nil
    GUI.DestroyItem(self.reinforceButton)
    self.reinforceButton = nil
    GUI.DestroyItem(self.storeButton)
    self.storeButton = nil
    
end

function GUIMainMenuNews:SendKeyEvent(key, down, amount)

    if not self.isVisible or not MainMenu_GetIsOpened() then
        return
    end

    local isReleventKey = false
    
    if type(self.buttonDown[key]) == "boolean" then
        isReleventKey = true
    end
    
    local mouseX, mouseY = Client.GetCursorPosScreen()
    if isReleventKey then
    
        local containsPoint, withinX, withinY = GUIItemContainsPoint(self.webContainer, mouseX, mouseY)
        
        // If we pressed the button inside the window, always send it the button up
        // even if the cursor was outside the window.
        if containsPoint or (not down and self.buttonDown[key]) then
        
            local buttonCode = key - InputKey.MouseButton0
            if down then
                self.webView:OnMouseDown(buttonCode)
            else
                self.webView:OnMouseUp(buttonCode)
            end
            
            self.buttonDown[key] = down
            
            return true
            
        end

        if GUIItemContainsPoint( self.reinforceButton, mouseX, mouseY ) then
            Client.ShowWebpage("www.naturalselection2.com/reinforced/")
        end

        if GUIItemContainsPoint( self.storeButton, mouseX, mouseY ) then
            Client.ShowWebpage("www.redbubble.com/people/unknownworlds/shop")
        end
        
        if GUIItemContainsPoint( self.logo, mouseX, mouseY ) then
            Client.ShowWebpage("http://forums.unknownworlds.com/")
        end
        
    -- This isn't working currently as the input is blocked by the main menu code in
    -- MouseTracker_SendKeyEvent(). But it is a nice thought.  
    elseif key == InputKey.MouseWheelUp then
        self.webView:OnMouseWheel(30, 0)
        MainMenu_OnSlide()
    elseif key == InputKey.MouseWheelDown then
        self.webView:OnMouseWheel(-30, 0)
        MainMenu_OnSlide()
    end
    
    return false
    
end

function GUIMainMenuNews:Update(deltaTime)
    
    if fadeColor.a <= 0 then
        self:SetIsVisible(false)
    elseif fadeColor.a > 0 then
        self:SetIsVisible(true)
    end
    
    self:PlayFadeAnimation()
    
    if not self.isVisible then
        return
    end

    local mouseX, mouseY = Client.GetCursorPosScreen()
    local containsPoint, withinX, withinY = GUIItemContainsPoint(self.webContainer, mouseX, mouseY)
    if containsPoint or self.buttonDown[InputKey.MouseButton0] or self.buttonDown[InputKey.MouseButton1] or self.buttonDown[InputKey.MouseButton2] then
        self.webView:OnMouseMove(withinX, withinY)
    end

    if GUIItemContainsPoint( self.webContainer, mouseX, mouseY ) then
        SetKeyEventBlocker(self)
    else
        SetKeyEventBlocker(nil)
    end
    
    if GUIItemContainsPoint( self.reinforceButton, mouseX, mouseY ) then
        self.reinforceButton:SetTexture("ui/leftbox_mouseover.dds")
    else
        self.reinforceButton:SetTexture("ui/leftbox.dds")
    end

    if GUIItemContainsPoint( self.storeButton, mouseX, mouseY ) then
        self.storeButton:SetTexture("ui/rightbox_mouseover.dds")
    else
        self.storeButton:SetTexture("ui/rightbox.dds")
    end

    //----------------------------------------
    //  Re-position/size everything, always
    //----------------------------------------
    local width = widthFraction * Client.GetScreenWidth()
    local newsHt = width/newsAspect

    local rightMargin = math.min( 150, Client.GetScreenWidth()*0.05 )
    local y = 10    // top margin

    local logoAspect = 600/192

    self.logo:SetSize( Vector(width, width/logoAspect, 0) )
    self.logo:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.logo:SetPosition(Vector( -width-rightMargin, y, 0))
    y = y + width/logoAspect

    local logoAspect = 300/100
    local buttonSpacing = 10
    local logoWidth = width/2.0 - buttonSpacing/2
    local buttonHeight = logoWidth / logoAspect
    y = y - 8
    
    self.reinforceButton:SetSize( Vector(logoWidth, buttonHeight, 0) )
    self.reinforceButton:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.reinforceButton:SetPosition(Vector( -width-rightMargin, y, 0))

    self.storeButton:SetSize( Vector(logoWidth, buttonHeight, 0) )
    self.storeButton:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.storeButton:SetPosition(Vector( -width-rightMargin+logoWidth+buttonSpacing, y, 0))

    y = y + buttonHeight + buttonSpacing

    //
    self.webContainer:SetSize(Vector(width, newsHt, 0))
    self.webContainer:SetAnchor(GUIItem.Right, GUIItem.Top)
    self.webContainer:SetPosition(Vector(-width-rightMargin, y, 0))
    
    y = y + newsHt
    
end

function GUIMainMenuNews:SetIsVisible(visible)
    self.webContainer:SetIsVisible(visible)
    self.logo:SetIsVisible(visible)
    self.reinforceButton:SetIsVisible(visible)
    self.storeButton:SetIsVisible(visible)
    self.isVisible = visible
    
    if visible == false then
        SetKeyEventBlocker(nil)
    end
    
end

function GUIMainMenuNews:ShowAnimation()

    if fadeColor.a <= 1 and Shared.GetTime() - lastUpdatedtime > 0.005 then
        fadeColor.a = fadeColor.a + 0.075
        self.webContainer:SetColor(fadeColor)
        self.logo:SetColor(fadeColor)
        self.reinforceButton:SetColor(fadeColor)
        self.storeButton:SetColor(fadeColor)
        lastUpdatedtime = Shared.GetTime()
    end

end

function GUIMainMenuNews:HideAnimation()

    if fadeColor.a >= 0 and Shared.GetTime() - lastUpdatedtime > 0.005 then
        fadeColor.a = fadeColor.a - 0.075
        self.webContainer:SetColor(fadeColor)
        self.logo:SetColor(fadeColor)
        self.reinforceButton:SetColor(fadeColor)
        self.storeButton:SetColor(fadeColor)
        lastUpdatedtime = Shared.GetTime()
    end
   
end
function GUIMainMenuNews:PlayFadeAnimation()

    if playAnimation == "show" then
        self:ShowAnimation()
    elseif playAnimation == "hide" then
        self:HideAnimation()
    end
   
end

function GUIMainMenuNews:SetPlayAnimation(animType)
    playAnimation = animType
end

function GUIMainMenuNews:LoadURL(url)
    self.webView:LoadUrl(url)
end

Event.Hook("Console_refreshnews", function() MainMenu_LoadNewsURL(kMainMenuNewsURL) end)